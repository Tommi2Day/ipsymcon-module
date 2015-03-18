unit ULCP100Device;
 //Thomas Dreﬂler (www.tdressler.net) 2010-13
interface
uses Windows, SysUtils, Forms, classes,    Graphics,strutils,
      lcp100i,
      superobject,
     UIPSTypes,ULCP100interface,UIPSModuleTypes, UIPSDataTypes;


type
 //Create a Interfaced Class that is derived from TIPSModuleObject and the custom defined IIPSRegVar
 TIPSLCP100 = class(TIPSModuleObject,
                        IIPSModule,
                        IIPSLCP100)
  private

    //--- Custom Objects
   //--- Private Procedures/Functions
   procedure EnumerateDosDevices(List: TStrings );

  protected
//   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public

   //--- IIPSModule implementation
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   function GetConfigurationForm(): String; override;
   //--- IIPSModule implementation
   {
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   }
   procedure ApplyChanges(); override;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

   //--- IIPS implementation
  function Backlight(OnOff :boolean): boolean; stdcall;
  function CLS:boolean; stdcall;
  function Test:boolean; stdcall;
  function PushBitmap(page:integer;datei:string):boolean; stdcall;
 function GetBitmap(page:integer;datei:string):boolean; stdcall;
 function ShowPage(page:integer):boolean; stdcall;
 function GetVersion:string;stdcall;
 function GetPortList:string;stdcall;



 end;




implementation
var
LCP:TLCP100ips;


 //------------------------------------------------------------------------------
class function TIPSLCP100.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSLCP100); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetModuleName(): String;
begin
 Result := 'LCP100';
end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSLCP100.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'LCP100';

end;

//------------------------------------------------------------------------------
constructor TIPSLCP100.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 inherited;

 RegisterProperty('ComPort', '');
 RegisterProperty( 'Backlight',false);
 lcp:=TLCP100ips.Create;

end;

//------------------------------------------------------------------------------
destructor  TIPSLCP100.Destroy;
begin

 lcp.Disconnect;
 lcp.Free;
 inherited;

end;
{
//------------------------------------------------------------------------------
procedure TIPSLCP100.LoadSettings();
begin


 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSLCP100.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSLCP100.ResetChanges();
begin
 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSLCP100.ApplyChanges();

begin

 inherited;
 BackLight(GetProperty('Backlight'));
 lcp.setComPortByName(GetProperty('ComPort'));
end;
 //--------------------------------------------------------
procedure TIPSLCP100.ProcessKernelRunlevelChange(Runlevel: Integer);
var

    device:string;

begin

 inherited;
 case Runlevel of
  KR_READY:begin
     //check with existing ports
      device:=GetProperty('ComPort');
      lcp.setComPortByName(device);

   end; //Ready
  end; //case
end;


//------------------------------------------------------------------------------
function TIPSLCP100.GetConfigurationForm(): String;
var Form, Port: ISuperObject;
    Devices: TStringlist;
    i: Integer;
    error:string;
begin

 Form := SO(inherited GetConfigurationForm());


 Devices := TStringlist.Create;
 try
  EnumerateDosDevices(Devices);
  for i := 0 to Devices.Count - 1 do
  begin
   if SameText(LeftStr(Devices[i], 3), 'COM') and (Devices[i][4] in ['0'..'9']) then
    begin
     Port := SO();
     Port.S['label'] := Devices[i];
     Port.S['value'] := Devices[i];
     Form.O['elements'].AsArray[0].O['options'].AsArray.Add(Port);
    end;
  end;

 except
 on E: Exception do
  error:=e.Message;

 end;
 Devices.Free;
 Result := Form.AsJSon();

end;




//Implementation
//------------------------------------------------------------------------------
function TIPSLCP100.Backlight(OnOff :boolean): boolean; stdcall;
var s:string;
    r:boolean;
begin
  r:=false;
  if lcp.Connect then
  begin
    lcp.BacklightOn:=OnOff;
    r:=(lcp.backlighton=OnOff);
    if onoff then s:='(ON)' else s:='(Off)';
    if r then
        s:='Success'+s else s:='failed'+s;
    senddata('Backlight',s);
    lcp.Disconnect;
  end else begin
      senddata('CLS','not Connected');
  end;
  result:=r;
end;
//------------------------------------------------------------------------------
function TIPSLCP100.CLS:boolean; stdcall;
var s:string;
  r:boolean;
begin
  r:=false;
  if lcp.Connect then
  begin
    r:=LCP.ClearDisplay;
    if r then
        s:='Success' else s:='failed';
    senddata('CLS',s);
    lcp.Disconnect;
   end else begin
      senddata('CLS','not Connected');
  end;
  result:=r;
end;
//------------------------------------------------------------------------------

function TIPSLCP100.Test:boolean; stdcall;
var s:string;
    r:boolean;
begin
  r:=false;
  if lcp.Connect then
  begin
    r:= LCP.ShowTestImage;
    if r then
        s:='Success' else s:='failed';
    senddata('TestPage',s);
    lcp.Disconnect;
  end else begin
      senddata('TestPage','not Connected');
  end;
  result:=r;
end;
//------------------------------------------------------------------------------


function TIPSLCP100.PushBitmap(page:integer;datei:string):boolean; stdcall;
var BMP:TBitmap;
      s:string;
      r:boolean;
begin
  r:=false;
  if lcp.Connect then
  begin
    BMP:=TBitmap.Create;
    try
      bmp.Height:=128;
      bmp.Width:=128;
      bmp.PixelFormat:=pf24bit;
      BMP.LoadFromFile(datei);
      bmp.Canvas.StretchDraw(bmp.Canvas.ClipRect,bmp);
      r:=LCP.UploadImage( BMP,page);
    except
      r:=false
    end;
    s:='Page:'+ inttostr(page);
    if r then
        s:=s+' Success' else s:=s+' failed';
    s:=s+' (File)'+ datei;
    senddata('PushBitmap',s);
     if assigned(bmp) then bmp.Free;
    lcp.Disconnect;
  end else begin
      senddata('PushBitmap','not Connected');
  end;
  result:=r;

end;
//------------------------------------------------------------------------------
 function TIPSLCP100.getBitmap(page:integer;datei:string):boolean; stdcall;
 var BMP:TBitmap;
  s:string;
  r:boolean;
begin
  r:=false;
  if lcp.Connect then
  begin
    BMP:=TBitmap.Create;
    bmp.Height:=128;
    bmp.Width:=128;
    bmp.PixelFormat:=pf24bit;
    r:=LCP.DownloadImage( BMP,page);
    try
      if r then bmp.SaveToFile(datei);
    except
      r:=false
    end;

    s:='Page:'+ inttostr(page);
    if r then
        s:=s+' Success' else s:=s+' failed';
    s:=s+' (File)'+ datei;
    senddata('GetBitmap',s);
    if assigned(bmp) then bmp.Free;
    lcp.Disconnect;
  end else begin
      senddata('GetBitmap','not Connected');
  end;
  result:=r;

end;

//------------------------------------------------------------------------------
 function TIPSLCP100.ShowPage(page:integer):boolean; stdcall;
 var r:boolean;
  s:string;
begin
  r:=false;
  if lcp.Connect then
  begin
      R:=LCP.ShowPageNo( Page);
      s:='Page:'+ inttostr(page);
      if r then
        s:=s+' Success' else s:=s+' failed';
      senddata('Showpage',s);
      lcp.Disconnect;
  end else begin
      senddata('Showpage','not Connected');
  end;
  result:=r;
end;
//------------------------------------------------------------------------------

 function TIPSLCP100.GetVersion():string;stdcall;
 var s:string;
begin
  s:='';
  if lcp.Connect then
  begin
     s:=LCP.FirmwareVersion;
     senddata('Version',s);
     lcp.Disconnect;
  end else begin
      senddata('Version','not Connected');
  end;
  Result:=s;
end;
//------------------------------------------------------------------------------
function TIPSLCP100.GetPortList:string;stdcall;
var
 Devices: TStrings;
 i: Integer;
  s:string;
begin
  Devices := TStringlist.Create;
 try
  EnumerateDosDevices(Devices);
  s:='';
    for i := 0 to Devices.Count - 1 do
   if SameText(LeftStr(Devices[i], 3), 'COM') and (Devices[i][4] in ['0'..'9']) then
    begin
      s:=s+'('+Devices[i]+')';
      senddata('PortList',s);
      result:=s;
    end;
 finally
   Devices.free;
 end;
end;
//------------------------------------------------------------------------------
//http://www.delphigroups.info/2/fd/417256.html
procedure TIPSLCP100.EnumerateDosDevices( List: TStrings );
var
  Buffer: pChar;
  BufLen: Cardinal;
  len: Cardinal;
  p: PChar;
  sl: TStringlist;
begin
  Assert( Assigned( List ));
  BufLen := High(Word);
  Buffer := AllocMem(BufLen);
  try
    repeat
      len:= QueryDosDevice(nil, Buffer, Buflen - 1);
      if len = ERROR_INSUFFICIENT_BUFFER then begin
        BufLen := Buflen * 2;
        ReAllocMem(Buffer, BufLen);
      end;
    until len <> ERROR_INSUFFICIENT_BUFFER;
    Buffer[Len] := #0;
    sl:= TStringlist.Create;
    try
      p:= Buffer;
      while p < @Buffer[Len] do begin
        sl.Add(p);
        p:= StrEnd(p)+1;
      end;
      sl.Sorted := true;
      List.Assign(sl);
    finally
      sl.Free;
    end; { finally }
  finally
    FreeMem(Buffer);
  end; { finally }
end;

end.
