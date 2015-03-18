unit UULA200Device;
//Thomas Dreßler (www.tdressler.net) 2009 - 2013
interface

uses Windows, Messages, SysUtils, ActiveX, Classes, Forms, StdCtrls,
     Dialogs, StrUtils,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,UELV2Interface;



 const LCDBufferSize=80; //LCD Limit

type
 //Create a Interfaced Class that is derived from TIPSModuleObject and the custom defined IIPSRegVar
 TIPSULA200 = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSReceiveString,
                        IIPSULA200)
  private
   //--- Basic Structures
   USBStatus        : Integer;
   keys:integer;

   //--- Custom Objects
   //--- Private Procedures/Functions
   {
   function getKeys:integer;stdcall;
   function getKeyTimer:integer;stdcall;
   function getBacklight:boolean;stdcall;
   function getRows:integer;stdcall;
   function getCols:integer;stdcall;
   procedure setKeyTimer(t:integer); stdcall;
   procedure setKeys(k:integer); stdcall;
   procedure setBacklight(b:boolean);stdcall;
   procedure setRows(r:integer);stdcall;
   procedure setCols(c:integer);stdcall;
 }
   //procedure syncparent;
   function ULA200SendData(Data:string):boolean;
   function ULA200ReceiveData(Data:String):boolean;
   procedure KeyTimerEvent;

  public
   //--- IIPSModule implementation
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   {
   destructor  Destroy; override;
   //--- IIPSModule implementation
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

    protected
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
   //procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;


  function LCDBacklight(Status :boolean): boolean; stdcall;
  function LCDCLS:boolean; stdcall;
  function LCDGoTo(xPos:integer; yPos: Integer): boolean; stdcall;
  function LCDText(Text:string):boolean; stdcall;

  //--Data Point
  procedure SendText(Text:string); stdcall;
  procedure ReceiveText(Text:string);stdcall;

 end;

implementation
//commands
const cmdCLS =$6c; //'l' 0x6c
const cmdGOTO =$70; //'p'0x70 p1=x, p2=y
const cmdCHAR =$63; //'c' 0x63 p1=zeichen;
const cmdINT =$69; //'i' 0x69 p1=wert modulo 256, p2=wert /256
const cmdSTRING=$73; //'s' 0x73 p1=strlen, p2...px=Zeichen
const cmdBackLight=$68; //'h' 0x68 p1='1'(0x31) ein,'0'(0x30) aus
const cmdLightON=$31; //'1' 0x31 als p1
const cmdLightOFF=$30; //'0' 0x30 als p1
const cmdKey=$74; //'t' 0x74 wird gesendet, p1=Tastenwert+0x40(bit0=taste1...bit5=taste6)


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
class function TIPSULA200.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSULA200); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetModuleName(): String;
begin
 Result := 'ULA200';
end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSULA200.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'ULA200';

end;

//------------------------------------------------------------------------------
constructor TIPSULA200.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
var
  I: Integer;
  z:string;
begin

 inherited;

 //RegisterProperty('DeviceID','');
 RegisterProperty('KeyTimer', 0.5);
 RegisterProperty( 'Backlight',false);
 RegisterProperty( 'LCDRows',2);
 RegisterProperty( 'LCDCols',16);
 keys:=0;

 RegisterVariable('BacklightVariable','BackLight',vtBoolean);
 for I := 0 to 5  do
 begin
   z:=inttostr(i);
   RegisterVariable('KeyVariable'+z,'Key '+z,vtBoolean);
 end;

 RegisterTimer('ULA200_KeyTimer',0,KeyTimerEvent);
 //Check Parent
 RequireParent(IIPSFTDI,false);

end;
{
//------------------------------------------------------------------------------
destructor  TIPSULA200.Destroy;
begin
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSULA200.LoadSettings();

begin
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSULA200.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSULA200.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSULA200.ApplyChanges();
begin
 inherited;
 LCDBackLight(GetProperty('Backlight'));
end;
//--------------------------------------------------------
procedure TIPSULA200.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then

  if Status = IS_ACTIVE then
  begin
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '19200',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'Even'
    ]);

  end;

 inherited;

end;
{
//------------------------------------------------------------------------------
procedure TIPSULA200.SyncParent();
var
  DoUpdate: Boolean;
  parent:IIPSModule;
   // ftdi:IIPSFTDI;
   // ftdidev:TFTDIDevice;
   // ftdidevs:TFTDIDevices;
    desc,serial:string;
CONST ELV_STRING='ELV USB-LCD Ansteuerung';
begin
if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then
 parent:=getParent();
 if parent <>NIL then
 begin
  if supports(parent,IIPSFTDI) then
  begin
    desc:=(parent as IIPSModule).GetProperty('Port');
    serial:=GetProperty('DeviceID');
     if desc='' then
     begin
     //klammer auf
      ftdidevs:=ftdi.GetDevices();
      for ftdidev in  ftdidevs do
      begin
        desc:=ftdidev.Description;
        if (desc=ELV_STRING) then
        begin
         if not ftdidev.InUse then
         begin
           serial:=ftdidev.SerialNumber;
           if fchangedsettings.DeviceID='' then fchangedsettings.DeviceID:=serial;
           if fchangedsettings.DeviceID=serial then break;
          end;//in use
        end;
      end; //for
     //klammer zu
     if serial >'' then
       parent.SetProperty('Port',serial);
    end;//if getport


    //ftdi.SetOpen(true);
 end;//supports


    if Supports(parent, IIPSSerialControl) then
     begin
      DoUpdate := False;

      if parent.GetProperty('BaudRate') <> '19200' then
       begin
        parent.SetProperty('BaudRate','19200');
        DoUpdate := True;
       end;
      if parent.GetProperty('StopBits') <> '1' then
       begin
        parent.SetProperty('StopBits','1');
        DoUpdate := True;
       end;
      if parent.GetProperty('DataBits') <> '8' then
       begin
        parent.SetProperty('DataBits','8');
        DoUpdate := True;
       end;
      if parent.GetProperty('Parity') <> 'Even' then
       begin
        parent.SetProperty('Parity','Even');
        DoUpdate := True;
       end;
      if DoUpdate then
       begin
        parent.ApplyChanges;
       end;
    end; //parent
 end;//kernel

end;
}
{
///Get/Set
//------------------------------------------------------------------------------

function TIPSULA200.getKeys:integer;
begin
Result:=fchangedsettings.Keys;
end;
//------------------------------------------------------------------------------

function TIPSULA200.getRows:integer;
begin
Result:=fchangedsettings.LCDRows;
end;
//------------------------------------------------------------------------------

function TIPSULA200.getCols:integer;
begin
Result:=fchangedsettings.LCDCols;
end;

//------------------------------------------------------------------------------
function TIPSULA200.getBacklight:boolean;
begin
Result:=fchangedsettings.BackLight;
end;
//------------------------------------------------------------------------------
function TIPSULA200.getKeyTimer:integer;
begin
Result:=fchangedsettings.KeyTimer;
end;

//------------------------------------------------------------------------------
procedure  TIPSULA200.setKeys(k: Integer);
begin
   fchangedsettings.Keys:=k;
   fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('KeyVariable'), k);
   if (k>0) and (fKernelRunlevel = KR_READY)then
    fkernel.TimerPoolEx.SetIntervalEx(ftimer,getkeytimer);

end;
//------------------------------------------------------------------------------

procedure  TIPSULA200.setRows(r: Integer);
begin
   fchangedsettings.LCDRows:=r;
end;
//------------------------------------------------------------------------------
procedure  TIPSULA200.setCols(c: Integer);
begin
  fchangedsettings.LCDCols:=c;
end;
//------------------------------------------------------------------------------
procedure  TIPSULA200.setBacklight(b: Boolean);
begin
    fchangedsettings.BackLight:=b;
end;

//------------------------------------------------------------------------------
procedure  TIPSULA200.setKeyTimer(t:integer);
begin
    fchangedsettings.KeyTimer:=t;
end;
}
//------------------------------------------------------------------------------
procedure  TIPSULA200.KeyTimerEvent;
begin
  keys:=0;
  SetTimerInterval('ULA200_KeyTimer',0);
end;

//Datapoint
//------------------------------------------------------------------------------
procedure TIPSULA200.SendText(Text: String);stdcall;
begin

 (GetParent() as IIPSSendString).SendText(Text);

end;


//------------------------------------------------------------------------------
procedure TIPSULA200.ReceiveText(Text:string);

begin

 SendData('Received', Text);
 ULA200ReceiveData(Text);


end;

 //------------------------------------------------------------------------------
function TIPSULA200.ULA200ReceiveData(Data:string):boolean;
  //++++ start subfunc ULA200 specific

  //+++++++ End subfunc

var index: integer;
var last:  integer;
var i,b,z,datalen: integer;
var c:char;
  v:string;

Buffer:string;

begin
 {protocol <STX> (payload)<ETX> without checksum
replace payload:
 STX -->ENQ DC2
 ETX -->ENQ DC3
 ENQ -->ENQ NAK

 answer:
 <STX><ACK><ETX> OK
 <STX><NAK><ETX> Error
}
Result:=false;
datalen:=length(data);
index := datalen ;
	// look for ETX
	while ((index >= 0) and (ord(Data[index]) <> ETX))
		do
    begin
    index:=index-1;
    end;

	if (index < 1) then		//no terminating ETX==Error
  begin
    USBStatus:=USB_ERROR_RAHMEN;
    exit;
  end;

	last := index; //position of ETX == last message byte

	// look backwards for STX
	while ((index >= 0) and (ord(Data[index]) <> STX)) do
    begin
		index:=index-1;
    end;

	if (index < 1) then   //no STX found ==Error
  begin

    USBStatus:=USB_ERROR_RAHMEN;
    exit;
  end;
	index:=index+1; //index now on position of first payload byte

	if ((last - index) < 1) then   //if no payload (<STX><ETX>) == Error
    begin

    USBStatus:=USB_ERROR_RAHMEN;
    exit;
    end;

  //decode replacements and fill target puffer
  z:=index;
  while (z<last) do
  begin
    c:=Data[z];
    if (c=chr(ENQ)) then
    begin
      z:=z+1;
      c:=Data[z];
      case ord(c) of
        DC2:c:=chr(STX);
        DC3:c:=chr(ETX);
        NAK:c:=chr(ENQ);
      end;
    end;
    Buffer:=Buffer+c;
    z:=z+1;
  end;


  Result := true; //handled
  c:=Buffer[1];
  case ord(c) of
    ACK: USBstatus:=USB_ACK;
    NAK: USBstatus:=USB_NAK;
    cmdKey:  begin
              SendData('Parse', 'Key command received');
              USBstatus:=USB_DATA;
              b:=ord(Buffer[2]);
              b:=b and $3f;
              if (b>0) then
              begin
                //set variables


                for i:=0 to 5 do
                begin
                  z:=1 shl i;
                  v:=inttostr(i);
                  if ((b and z)>0) and ((keys and z)=0) then
                        fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('KeyVariable'+v), true);

                end;
                keys:=b;
                Result:=true;
              end
              else
                begin
                USBstatus:=USB_ERROR_ANTWORT;
                Result:=false;
              end;
              If (Result) then
                  SendData('Parse', 'Keys:'+inttohex(b,2))  else
                  SendData('Parse', 'Dekoding failed');

              end;
    else
          begin
         USBstatus:=USB_ERROR_UNBEKANNT;
         Result := false;
         end
    end;

end;
 //------------------------------------------------------------------------------
function TIPSULA200.ULA200SendData(Data:String):boolean;
var Buffer,Text :String;
var i,datalen:integer;
var c:char;
begin

  datalen:=length(Data);
  Buffer:=chr(STX);
  Text:=inttohex(STX,2)+' ';

  for i:=1 to datalen do
    begin
    c:=Data[i];
    //Translate STX,ETX and ENQ from payload according table

    case ord(c) of
      STX:begin   //STX->ENQ DC2
            Buffer:=Buffer+chr(ENQ);
            c:=chr(DC2);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
      ETX:begin    //ETX->ENQ DC3
            Buffer:=Buffer+chr(ENQ);
            c:=chr(DC3);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
      ENQ:begin  //ENQ->ENQ NAK
            Buffer:=Buffer+chr(ENQ);
            c:=chr(NAK);

            Text:=Text+inttohex(ENQ,2)+' ';
          end;
    end; //case

    Buffer :=Buffer+c;
    Text:=Text+inttohex(ord(c),2)+' ';
  end; //for

  //add ETX

  Buffer:=Buffer+chr(ETX);
  Text:=Text+inttohex(ETX,2)+' ';


  SendData('TRansmit', Text+' Len:'+inttostr(length(Buffer)));

  //send to FTDI
   SendText(Buffer);
   Result := false; //handled, default failed, wait for response
   USBstatus:=USB_PENDING;
   //wait for response
   for i:=1 to 50 do
      begin
        case USBstatus of
          USB_DATA,
          USB_ACK: begin
                Result := true;
                break;
                end;
          USB_NAK:break;
         else
         begin
          If GetCurrentThreadID = MainThreadID then
            Application.ProcessMessages;
            sleep(10); //50*10 => max 500ms
            end
        end; //case
      end; //for
      if (USBstatus=USB_PENDING) then USBstatus:=USB_ERROR_TIMEOUT;

      Buffer:='';
      case USBstatus of
            USB_ACK: Buffer:=Buffer+'OK';
            USB_NAK: Buffer:=Buffer+'FAILED';
            USB_DATA: Buffer:=Buffer+' Data received';
            USB_PENDING: Buffer:=Buffer+' waiting';
            USB_ERROR_RAHMEN: Buffer:=Buffer+' Frame Error';
            USB_ERROR_TIMEOUT: Buffer:=Buffer+'TIMEOUT';
            USB_ERROR_ANTWORT: Buffer:=Buffer+'Answer Error or not expected';
            USB_ERROR_UNBEKANNT: Buffer:=Buffer+'Unknown Answer';
      else
          Buffer:=Buffer+inttostr(USBStatus);
      end;

      SendData('Transmit','Answer for sended data: '+ Buffer);


 end;
 //------------------------------------------------------------------------------
function TIPSULA200.LCDText(Text :string):boolean; stdcall;
var textlen:integer;
var data:string;

begin
  //0x73 p1=strlen, p2...px=chars
  textlen:=length(Text);
  //command and len
  Data:=chr(cmdString);
  Data:=Data+chr(textlen);
  //copy text
  Data:=Data+Text;
  //call send routine
  Result:=ULA200SendData(Data);
end;
 //------------------------------------------------------------------------------
 function TIPSULA200.LCDBacklight(Status :boolean): boolean;
var  Data:string;
begin
  //0x68 p1='1'(0x31) on,'0'(0x30) off
  //command and value
  Data:=chr(cmdBackLight);
  if (status) then
      Data:=Data+chr(cmdLightOn)
  else
      Data:=Data+chr(cmdLightOFF);
  //call send routine
  if (ULA200SendData(Data)) then
  begin
    Result:=true;
    setProperty('Backlight',status);
    fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('BacklightVariable'), status);
  end
  else
    Result:=false;
end;
 //------------------------------------------------------------------------------
function TIPSULA200.LCDCLS: boolean; stdcall;

var
  Data:string;

begin
  //0x6c
  //command and value
    Data:=chr(cmdCLS);
  //call send routine
    Result:=ULA200SendData(Data) ;
end;

 //------------------------------------------------------------------------------
  function TIPSULA200.LCDGoTo(xPos:integer; yPos: Integer): boolean;
var
Data:string;


begin
  //0x70 p1=x, p2=y
  //command and values
  Data:=chr(cmdGoTo);
  Data:=Data+chr(xPos);
  Data:=Data+chr(yPos);
  //call send routine
  Result:=ULA200SendData(Data) ;
end;


end.

