unit LCP100_Cmd;

interface
uses
	Windows, SysUtils, Classes, CPDrv, Graphics;

//Local use only
{
function LCP100_SendCommand(Comm:TCommPortDriver; Command: byte; Param:tstream; ReceiveData:tstream): boolean; overload;
function LCP100_SendCommand(Comm:TCommPortDriver; Command: byte; Param:byte ): boolean; overload;
function LCP100_SendCommand(Comm:TCommPortDriver; command: byte; ReceiveData:tstream ): boolean; overload;
function LCP100_SendCommand(Comm:TCommPortDriver; command: byte ): boolean; overload;
}

const LCP100_NumberOfPages = 64;
{$EXTERNALSYM LCP100_NumberOfPages}
type
TProgress=procedure (position:integer) of object;stdcall;

function LCP100_GetFirmwareVersion(Comm:TCommPortDriver; var major: byte; var minor: byte): Boolean; overload;
function LCP100_GetFirmwareVersion(Comm:TCommPortDriver): string; overload;
function LCP100_UploadImage(Comm:TCommPortDriver; PageNo:integer; BMP:TBitmap;setProgress:TProgress):Boolean;
function LCP100_DownloadImage(Comm:TCommPortDriver; PageNo:integer; var BMP:TBitmap;setProgress:TProgress):Boolean;
function LCP100_ShowPage(Comm:TCommPortDriver; PageNo: word;setProgress:TProgress): Boolean;
function LCP100_TestImage(Comm:TCommPortDriver): Boolean;
function LCP100_ClearDisplay(Comm:TCommPortDriver):Boolean;
function LCP100_BacklightOn(Comm:TCommPortDriver):Boolean;
function LCP100_BacklightOff(Comm:TCommPortDriver):Boolean;
function LCP100_ST7637Cmd(Comm:TCommPortDriver;Command: byte): boolean;
function LCP100_ST7637Data(Comm:TCommPortDriver;Data: byte): boolean;

implementation
uses LCP100_Frame;

{$define LCP100_WORKAROUND_CLEAR}

(* commands *)
const LCP100_CMD_CLEAR:byte =        $65; (* clear display                   *)
{$EXTERNALSYM LCP100_CMD_CLEAR}
const LCP100_CMD_ST7637_CMD:byte =   $69; (* send command directly to ST7637 *)
{$EXTERNALSYM LCP100_CMD_ST7637_CMD}
const LCP100_CMD_LOAD_FLASHBLOCK =    $6c; (* download page from memory       *)
{$EXTERNALSYM LCP100_CMD_LOAD_FLASHBLOCK}
const LCP100_CMD_ST7637_DATA =  $6f; (* send data directly to ST7637    *)
{$EXTERNALSYM LCP100_CMD_ST7637_DATA}
const LCP100_CMD_SAVE_FLASHBLOCK =    $70; (* upload page to memory           *)
{$EXTERNALSYM LCP100_CMD_SAVE_FLASHBLOCK}
const LCP100_CMD_SHOW_FLASHBLOCK = $73; (* display a block of flash (2 lines)                 *)
{$EXTERNALSYM LCP100_CMD_SHOW_FLASHBLOCK}
const LCP100_CMD_TEST =         $74; (* show test image                 *)
{$EXTERNALSYM LCP100_CMD_TEST}
const LCP100_CMD_VERSION =      $76; (* get version of firmware         *)
{$EXTERNALSYM LCP100_CMD_VERSION}
const LCP100_CMD_BACKLIGHT =    $7a; (* control backlight               *)
{$EXTERNALSYM LCP100_CMD_BACKLIGHT}

(* protocol stuff *)
const LCP100_MAX_PACKET_SIZE =  $ffff;
{$EXTERNALSYM LCP100_MAX_PACKET_SIZE}
const LCP100_CRC16_POLYNOM =    $8005;
{$EXTERNALSYM LCP100_CRC16_POLYNOM}
const LCP100_FLASHBLOCK_SIZE =  $200;
{$EXTERNALSYM LCP100_FLASHBLOCK_SIZE}
const LCP100_FLASHBLOCKS_PER_IMAGE = 64;
{$EXTERNALSYM LCP100_FLASHBLOCKS_PER_IMAGE}
const LCP100_NUMBER_OF_FLASHBLOCKS = 4096;
{$EXTERNALSYM LCP100_NUMBER_OF_FLASHBLOCKS}
const LCP100_ACK =              $06;
{$EXTERNALSYM LCP100_ACK}
const LCP100_NAK =              $15;
{$EXTERNALSYM LCP100_NAK}
const LCP100_BACKLIGHT_ON =     $01;
{$EXTERNALSYM LCP100_BACKLIGHT_ON}
const LCP100_BACKLIGHT_OFF =    $00;
{$EXTERNALSYM LCP100_BACKLIGHT_OFF}

function LCP100_SendCommand(Comm:TCommPortDriver; Command: byte; Param:tstream; ReceiveData:tstream): boolean; overload;
var CmdParam:tmemorystream;
    ack:byte;
begin
  result := false;
  CmdParam := TMemoryStream.Create;
  try
    CmdParam.Write(command,1);
    Param.Position := 0;
    CmdParam.CopyFrom(Param,Param.Size);

    if Frame_Send(Comm, CmdParam) then
    begin

      ReceiveData.Position := 0;
      Frame_Receive(comm,ReceiveData);

      if ReceiveData.Size = 1 then
      begin
        ReceiveData.Position := 0;
        ReceiveData.Read(ack,1);
        result := ack=LCP100_ACK;
      end else begin
      ReceiveData.Position := 0;
        Result := true;
      end;
    end;
  finally
    CmdParam.Free;
  end;
end;

function LCP100_SendCommand(Comm:TCommPortDriver; Command: byte; Param:byte ): boolean; overload;
var ParamStream:TMemoryStream;
    ReceiveData:tmemorystream;
begin
  ParamStream := TMemoryStream.Create;
  ReceiveData := TMemoryStream.Create;
  try
    ParamStream.Write(param,1);
    result := LCP100_SendCommand(Comm, Command,ParamStream,ReceiveData);
  finally
    ReceiveData.Free;
    ParamStream.Free;
  end;
end;

function LCP100_SendCommand(Comm:TCommPortDriver; command: byte; ReceiveData:tstream ): boolean; overload;
var Param:tmemorystream;
begin
  Param := TMemoryStream.Create;
  try
    result :=  LCP100_SendCommand(Comm,command,Param,ReceiveData);
  finally
    Param.Free;
  end;
end;

function LCP100_SendCommand(Comm:TCommPortDriver; command: byte ): boolean; overload;
var Param:tmemorystream;
    ReceiveData:TMemoryStream;
begin
  Param := TMemoryStream.Create;
  ReceiveData := TMemoryStream.Create;
  try
    result :=  LCP100_SendCommand(comm,command,Param,ReceiveData);
  finally
    ReceiveData.Free;
    Param.Free;
  end;
end;

function LCP100_GetFirmwareVersion(Comm:TCommPortDriver; var Major: byte; var Minor: byte): boolean;
var param:tmemorystream;
    receivedate:tmemorystream;
begin
  result := false;
  param := TMemoryStream.Create;
  receivedate := TMemoryStream.Create;
  try
    if LCP100_SendCommand(comm, LCP100_CMD_VERSION, receivedate) then
    begin
      receivedate.Position := 0;
      receivedate.Read(major,1);
      receivedate.Read(minor,1);
      result := true;
    end;
  finally
    param.Free;
    receivedate.Free;
  end;
end;

function LCP100_GetFirmwareVersion(Comm:TCommPortDriver): string;
var major, minor:byte;
begin
  if LCP100_GetFirmwareVersion(comm,Major,Minor)=true
    then result := format('%d.%d',[major,minor])
    else result := '0.0';
end;

function LCP100_FlashBlock_Upload(Comm:TCommPortDriver; index: word; FlashBlock: tstream): boolean;
var Param:tmemorystream;
    ReceiveData:TMemoryStream;
    idxhi,idxlo:byte;
begin
  Param := TMemoryStream.Create;
  ReceiveData := TMemoryStream.Create;
  try
    if (index >= LCP100_NUMBER_OF_FLASHBLOCKS) or
       (FlashBlock.Size <> LCP100_FLASHBLOCK_SIZE ) then
    begin
      result := false;
      exit;
    end;

    SplitWord(index,idxhi,idxlo);
    param.Write(idxhi,1);
    param.Write(idxlo,1);
    FlashBlock.Position := 0;
    param.CopyFrom(FlashBlock,FlashBlock.Size);

    result:= LCP100_SendCommand(comm, LCP100_CMD_SAVE_FLASHBLOCK, Param, ReceiveData );
  finally
    ReceiveData.Free;
    Param.Free;
  end;
end;

function LCP100_FlashBlock_Download(Comm:TCommPortDriver; index: word; FlashBlock: tstream): boolean;
var Param:tmemorystream;
    ReceiveData:TMemoryStream;
    idxhi,idxlo:byte;
begin
  Param := TMemoryStream.Create;
  ReceiveData := TMemoryStream.Create;
  try
    if (index >= LCP100_NUMBER_OF_FLASHBLOCKS) then
    begin
      result := false;
      exit;
    end;

    SplitWord(index,idxhi,idxlo);
    param.Write(idxhi,1);
    param.Write(idxlo,1);
    SplitWord(512,idxhi,idxlo);
    param.Write(idxhi,1);
    param.Write(idxlo,1);

    result:= LCP100_SendCommand(comm, LCP100_CMD_LOAD_FLASHBLOCK, Param, ReceiveData );
    if ReceiveData.Size > 1
      then FlashBlock.CopyFrom(ReceiveData, ReceiveData.Size);
  finally
    ReceiveData.Free;
    Param.Free;
  end;
end;

function LCP100_UploadImage(Comm:TCommPortDriver; PageNo:integer; BMP:TBitmap;setProgress:TProgress):boolean;
type
  tRGB = packed record
    rgbRed: Byte;
    rgbGreen: Byte;
    rgbBlue: Byte;
    rgbReserved: Byte;
  end;
var  bmp128:tbitmap;
    FlashPage,ScanLinePix,ScanLine_01:integer;
    BmpCol,BmpRow:integer;
    Pixel_RGB:tRGB;
    wRed,wGreen,wBlue:word;
    CodedColor:array[0..1] of byte;
    color:tcolor;
    ms:tmemorystream;
    r:boolean;
    v:integer;
begin
  result := true;
  bmp128 := TBitmap.Create;
  try
    //format bitmap
    bmp128.Width := 128;
    bmp128.Height := 128;
    bmp128.PixelFormat := pf24bit;
    bmp128.Canvas.StretchDraw(bmp128.Canvas.ClipRect,bmp);
    //build pages blocks
    for FlashPage := 0 to LCP100_FLASHBLOCKS_PER_IMAGE -1 do
    begin
      ms := TMemoryStream.Create;
      if assigned(setProgress) then setProgress(Flashpage+1);

      try
      //512bytes per block with 128pixel/line and 16bit=2byte color =2rows/Block
      for ScanLine_01 := 0 to 1 do
        begin
          //128 pixel/line
          for ScanLinePix := 0 to 127 do
          begin
            BmpRow := ScanLine_01 + FlashPage*2;
            BmpCol := ScanLinePix;
            //get pixel color
            color := bmp128.Canvas.Pixels[BmpCol,BmpRow];
            Pixel_RGB := tRGB(ColorToRGB(color));
            //Build 5-6-5 16bit RGB-Color
            wRed := Pixel_RGB.rgbRed;   wRed := ((wRed*31)div 255) and $1F;
            wGreen := Pixel_RGB.rgbgreen; wGreen := ((wGreen*63)div 255) and $3F;
            wBlue := Pixel_RGB.rgbblue;  wBlue := ((wBlue*31)div 255) and $1F;
            //code color RRRRRGGG GGGBBBBB
            CodedColor[0] := (wRed shl 3) or (wGreen shr 3) ;
            CodedColor[1] := (wGreen shl 5) or wBlue;
            ms.Write(CodedColor,2);
          end;
        end;
        //10trys/block=5s
        for v:=0 to 10 do
        begin
          ms.Position := 0;
          r:= LCP100_FlashBlock_Upload(comm, PageNo*LCP100_FLASHBLOCKS_PER_IMAGE + FlashPage,ms);
          if r then break;
          sleep(500);
          //wait if failure and try again
        end;

        if not r then
        begin
         //cancel if failure permanent
          result:=false;
          exit;
        end;

      finally
        ms.free;
      end;
    end;
  finally
    bmp128.Free;
  end;
end;

function LCP100_DownloadImage(Comm:TCommPortDriver; PageNo:integer; var BMP:TBitmap;setProgress:TProgress):Boolean;
var FlashPage:integer;
    ms:TMemoryStream;
    // wRed,wGreen,wBlue:word;
    CodedColor:array[0..1] of byte;
    color:tcolor;
    ret:boolean;
    v,l,x,y,R,B,G:integer;
begin

  result := true;
  //
  for FlashPage := 0 to LCP100_FLASHBLOCKS_PER_IMAGE -1 do
  begin
    ms := TMemoryStream.Create;
    if assigned(setProgress) then setProgress(Flashpage+1);
    try
        //4trys/block=2s
        for v:=0 to 3 do
        begin
          ms.Position := 0;
          ret:= LCP100_FlashBlock_Download(comm, PageNo*LCP100_FLASHBLOCKS_PER_IMAGE + FlashPage,ms);
          if ret then break;
          //wait if failure and try again
          sleep(500);
        end;

       if not ret then
        begin
          //cancel if failure permanent
          result:=false;
          exit;
        end;
      { convert Stream to Bitmap }
       ms.Position:=0;
       for l := 0 to 1 do
       begin
            y:=FlashPage shl 1;
            y:=y+l;
            for x := 0 to 127 do
             begin
              ms.Read(CodedColor,2);
              //code color RRRRRGGG GGGBBBBB
              R:=codedcolor[0] shr 3; //5bit msb=Red
              r:=r shl 3;//5bit->8bit
              b:=codedcolor[1] and $1F;//5bit lsb=blue
              b:=b shl 3; //5bit ->8bit
              G:=(codedcolor[0] and 7) shl 3; //3bit lsb code[1]->3bit msb
              G:= G or (codedcolor[1] shr 5); //3bit msb code[1]->3bit lsb with 3bit msb or from before=6bit green
              g:=g shl 2;//6bit->8bit
              color:=(R or (G shl 8) or (B shl 16));
              //set pixel with color
              bmp.Canvas.Pixels[x,y]:=color;
             end;
         end;
    finally
      ms.free;
    end;
  end;

end;

function LCP100_ShowFlashBlock(Comm:TCommPortDriver; Index,Length: word): boolean; overload;
var buffer:array[0..3] of byte;
    param:tmemorystream;
    receivedate:tmemorystream;

begin
  param := TMemoryStream.Create;
  receivedate := TMemoryStream.Create;
  try
    if ( index >= LCP100_NUMBER_OF_FLASHBLOCKS) or
       (length > LCP100_FLASHBLOCK_SIZE ) then
    begin
      result:= false;
      exit;
    end;

    SplitWord(index, buffer[0], buffer[1]);
    SplitWord(length, buffer[2], buffer[3]);

    param.Write(buffer,4);
    result:= LCP100_SendCommand(comm, LCP100_CMD_SHOW_FLASHBLOCK, param, receivedate);
  finally
    receivedate.Free;
    param.Free;
  end;
end;

function LCP100_ShowFlashBlock(Comm:TCommPortDriver; Index: word): boolean; overload;
begin
  result := LCP100_ShowFlashBlock(comm,index,512);
end;

function LCP100_ShowPage(Comm:TCommPortDriver; PageNo:word;setProgress:TProgress):boolean;
var i:integer;
  r:boolean;
    v:integer;
begin
  result := true;
  for I := PageNo*LCP100_FLASHBLOCKS_PER_IMAGE to PageNo*LCP100_FLASHBLOCKS_PER_IMAGE + LCP100_FLASHBLOCKS_PER_IMAGE - 1 do
  begin
  if assigned(setProgress) then setProgress(i+1);
  //4trys/block=2s
   for v:=0 to 3 do
        begin
          r:= LCP100_ShowFlashBlock(Comm,i);
          if r then break;
          sleep(500);
          //wait if failure and try again
        end;
        if not r then
        begin
          //failure is persistent
          result:=false;
          exit;
        end;

  end;

end;

function LCP100_TestImage(Comm:TCommPortDriver): boolean;
begin
	result:= LCP100_SendCommand(comm, LCP100_CMD_TEST );
end;

function LCP100_ClearDisplay(Comm:TCommPortDriver):boolean;
var
  ms:tmemorystream;
  t:byte;
  i:integer;
begin
{$ifdef LCP100_WORKAROUND_CLEAR}
  ms := TMemoryStream.Create;
  try
    //white page
    t := $FF;
    for i := 0 to 99 do ms.Write(t,1);
    //last picture
    for i := LCP100_NUMBER_OF_FLASHBLOCKS - LCP100_FLASHBLOCKS_PER_IMAGE to LCP100_NUMBER_OF_FLASHBLOCKS - 1
      do LCP100_FlashBlock_Upload(comm,i, ms);
	  //LCP100_TestImage(comm );
  finally
    ms.Free;
  end;
  //show last picture
	for i := LCP100_NUMBER_OF_FLASHBLOCKS - LCP100_FLASHBLOCKS_PER_IMAGE to LCP100_NUMBER_OF_FLASHBLOCKS - 1 do
  begin
		result := LCP100_ShowFlashBlock(Comm, i, 512 );
  end;
{$else}
  result := LCP100_SendCommand(comm, LCP100_CMD_CLEAR );
{$Endif}
end;

function LCP100_BacklightOn(Comm:TCommPortDriver):boolean;
begin
  result := LCP100_SendCommand(comm, LCP100_CMD_BACKLIGHT, LCP100_BACKLIGHT_ON );
end;

function LCP100_BacklightOff(Comm:TCommPortDriver):boolean;
begin
  result := LCP100_SendCommand(comm, LCP100_CMD_BACKLIGHT, LCP100_BACKLIGHT_OFF );
end;

function LCP100_ST7637Cmd(Comm:TCommPortDriver;Command: byte): boolean;
begin
	result:= LCP100_SendCommand(comm, LCP100_CMD_ST7637_CMD,  command );
end;

function LCP100_ST7637Data(Comm:TCommPortDriver;Data: byte): boolean;
begin
	result:= LCP100_SendCommand(comm, LCP100_CMD_ST7637_DATA,  Data );
end;

end.
