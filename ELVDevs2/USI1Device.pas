unit USI1Device;

//Thomas Dreßler (www.tdressler.net) 2009 - 2012
interface

uses Windows, SysUtils, Forms, StrUtils,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,UELV2Interface;

type
  T4Bytes = packed record case Integer of
    0: (Bytes: array[0..3] of Byte);
    1: (Total: Cardinal);
  end;
TIPSSI1 = class(TIPSModuleObject,
                        IIPSModule,
                          IIPSReceiveHID,
                        IIPSSI1)
 const ReportID=0;
 CONST HID_STRING='USB-SI1';
  private
   //--- Basic Structures
   fquery:boolean;
   Answer        : string;
   devstatus:boolean;
   HIDStatus:integer;
   timeout:integer;
   fTimeout         :boolean;
   //ftimer:          TTimerID;

   //--- Custom Objects
 {
   //get/set
   function getDevice:string; stdcall;
   procedure setDevice(Device:string); stdcall;
   function getStatus:boolean; stdcall;
   procedure setStatus(status:boolean); stdcall;
   }
   //--- Private Procedures/Functions
   function SI1SendData(Data:string):boolean;
  procedure Parse(Data:String);
   procedure TimeOutEvent;
   //procedure syncparent;

  protected
   //procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public
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
  //--- IIPSS1 implementation
 function SwitchMode(state:boolean):boolean; stdcall;
 function SwitchDuration(state:boolean;time:integer):boolean; stdcall;
 //function Timeoff(time:integer):boolean; stdcall;
 function GetDevStatus:integer;stdcall;

  //--Data Point
  procedure SendEvent(ReportID:Byte;Text:string); stdcall;
  procedure ReceiveEvent(ReportID:byte;Text:string);stdcall;


 end;

implementation

//------------------------------------------------------------------------------
class function TIPSSI1.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSSI1); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetModuleName(): String;
begin
 Result := 'SI1';
end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendHID);

end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveHID);
end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSSI1.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'SI1';

end;

//------------------------------------------------------------------------------
constructor TIPSSI1.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 inherited;

 //RegisterProperty( 'DeviceID','');

 RegisterVariable('StatusTextVariable','StatusText',vtString);
 RegisterVariable('StatusDataVariable','StatusData',vtinteger);
 RegisterVariable('StatusVariable','Status',vtBoolean,'Switch');

 //timer

 RegisterTimer('SI1_Timeout', 0, TimeoutEvent);
 timeout := 1;
 devstatus:=true;
 //Check Parent
 RequireParent(IIPSHID,false);


end;
{
//------------------------------------------------------------------------------
destructor  TIPSSI1.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSSI1.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSSI1.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSSI1.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSSI1.ApplyChanges();

begin
 inherited;

end;
{
//------------------------------------------------------------------------------
procedure TIPSSI1.syncparent;
var parent:IIPSModule;
    HID:IIPSHID;
    hiddev:THIDDevice;
    hiddevs:THIDDevices;
    desc,serial,mydev:string;
    vid,pid:integer;

begin
  if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then parent:=getParent();
  if parent<>NIL then
  begin
    if supports(parent,IIPSHID,HID) then
    begin
    mydev:=getProperty('DeviceID');
     serial:=hid.GetDeviceSerial;
     if mydev='' then
     begin
      HIDdevs:=HID.GetDevices();
      serial:='';
      for HIDdev in  HIDdevs do
      begin
        desc:=HIDdev.DeviceName;
        if (desc=HID_STRING) then
        begin
           serial:=HIDdev.DeviceSerial;
           vid:=hiddev.VendorID;
           pid:=hiddev.ProductID;
           mydev:=serial;
           setProperty('DeviceID',serial);
            hid.SetDeviceSerial(serial);
            hid.SetDeviceVendorID(vid);
            hid.SetDeviceProductID(pid);
            parent.applychanges;
            break;
        end;
      end; //for
     end;//if serial

     if serial=mydev then
     begin

       hid.SetOpen(true);
       parent.applychanges;
     end;

  end; //suppoers
 end; //parent

end;
}
 //--------------------------------------------------------
procedure TIPSSI1.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;

  case Runlevel of
      KR_READY: begin
                  //syncparent;
                  getdevstatus;
                end;
  end;
end;
{
 //--------------------------------------------------------
procedure TIPSSI1.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin
  inherited;
end;
}
{
///Get/Set
//------------------------------------------------------------------------------
   function TIPSSI1.getStatus:boolean;stdcall;
   begin
    result:=fchangedsettings.status;
   end;
   //------------------------------------------------------------------------------
   procedure TIPSSI1.setStatus(status:boolean);stdcall;
   begin
    fchangedsettings.status:=status;
    //settingschanged;
   end;

//------------------------------------------------------------------------------
   function TIPSSI1.getDevice:string;stdcall;
   begin
    result:=fchangedsettings.DeviceID;
   end;
   //------------------------------------------------------------------------------
   procedure TIPSSI1.setDevice(Device:string);stdcall;
   begin
    fchangedsettings.DeviceID:=Device;
    settingschanged;
   end;
}
//Datapoint
//------------------------------------------------------------------------------
procedure TIPSSI1.SendEvent(ReportID:byte;Text: String);stdcall;
begin
  if hasactiveparent then
    (GetParent() as IIPSSendHID).SendEvent(ReportID,Text);

end;
//------------------------------------------------------------------------------
procedure TIPSSI1.ReceiveEvent(ReportID:byte;Text:string); stdcall;
begin

 SendData('Received', 'Report:'+inttostr(reportid)+' Msg:'+Text);
  Answer:=Text;
  Parse(Text);

end;
 //------------------------------------------------------------------------------
procedure TIPSSI1.TimeOutEvent;
begin
  fTimeout:=true;
  SetTimerInterval('SI1_TimeOut', 0);
  sendData('Timer','Timeout');
end;
//------------------------------------------------------------------------------
function TIPSSI1.SI1SendData(data:string):boolean;
var l:integer;
  r:byte;
  text:string;
begin
  Result:=false;
  if fquery then
  begin
    SendData('Send','Query Already Active');
    exit;
  end;
   Answer:='';

  SendData('Send',Data);
  l:=length(data)-1;
  r:=ord(Data[1]);
  text:=copy(Data,2,l);
  HIDStatus:=-1;
  fquery:=true;
  ftimeout:=false;
    SetTimerInterval('SI1_TimeOut', timeout);

  try
   Sendevent(r,text);
  while (Answer='' ) and (not ftimeout) do
  begin
    sleep(50);
  end; //while ende
  SetTimerInterval('SI1_TimeOut', 0);


  finally
  //polling finished, have data or timeout
  end;

  fquery:=false;
  Result:=(length(Answer)>0);
 end;
 //------------------------------------------------------------------------------
 function TIPSSI1.SwitchMode(state:boolean):boolean;  stdcall;
 const cmdOnOff=#1#2#$F1;
 var buffer:string;

 begin
      if state then
        Buffer:=' On ' else Buffer:='OFF';
      senddata('SwitchMode',Buffer);
     result:=false;
     buffer:=cmdOnOff;
     if state then buffer:=buffer+chr(1) else buffer:=buffer+chr(0);
     if (SI1SendData(buffer)) then
     begin
        Result:=(HIDStatus=0)
     end;
     SendData('SwitchMode','Result:'+Answer);
     GetDevStatus;
end;
//------------------------------------------------------------------------------
 function TIPSSI1.SwitchDuration(state:boolean;time:integer):boolean;  stdcall;
 const cmdTimerOnOff=#1#6#$F2;
 var buffer:string;
  temp:T4Bytes;
  i:integer;
 begin
      if state then
        Buffer:=' On ' else Buffer:='OFF';
      Buffer:=Buffer+inttostr(time)+' Sec';
      senddata('Switchduration',Buffer);
     result:=false;
     if time<0 then exit;
     buffer:=cmdTimerOnOff;
     if state then buffer:=buffer+chr(1) else buffer:=buffer+chr(0);
     temp.Total:=time;
     for I := 3 downto 0 do buffer:=buffer+chr(temp.bytes[i]);
     if (SI1SendData(buffer)) then
     begin
        Result:=(HIDStatus=0)
     end;
     SendData('SwitchDuration','Result:'+Answer);
     getDevStatus;
 end;
 //------------------------------------------------------------------------------
 function TIPSSI1.GetDevStatus:integer;stdcall;
 const cmdStatus=#1#1#$F0;
 var buffer:string;
 begin
     senddata('GetStatus','entered');
     result:=-1;
     buffer:=cmdStatus;
     if (SI1SendData(buffer)) then
     begin
        Result:=HIDStatus;
     end;
     SendData('GetStatus','Result:'+Answer);
 end;
  //------------------------------------------------------------------------------
 procedure TIPSSI1.parse(data:string);
 var buffer:string;
 zeit:integer;
 temp:T4bytes;
 l,i:integer;
 status,current:boolean;
 const AnswerHeader1=#2#$90;
const AnswerHeader2=#6#$90;
 begin
  l:=length(Data);
  SendData('Parse','Len:'+inttostr(l));
  if l<3 then exit;
  buffer:=copy(Data,1,2);
  if buffer=AnswerHeader1 then
  begin
    HIDStatus:=ord(data[3]);
    case HIDStatus of
    0: Buffer:='OK';
    1: Buffer:='Failed';
    2: Buffer:='Manual';
    16:begin
      Buffer:='Permanent Off';
      devstatus:=false;
    end;
    17: begin
        Buffer:='Permanent On';
        devstatus:=true;
      end;
    else
        SendData('Parse', 'Error1:'+inttostr(HIDStatus));
    end;
    SendData('Parse','1');
  end;
  if buffer=AnswerHeader2 then
  begin
    HIDStatus:=-2;
    if l<7 then exit;
    HIDStatus:=ord(data[3]);
    l:=0;
    for i:=3 downto 0 do
    begin
       temp.Bytes[l]:=ord(data[i+4]);
       inc(l);
    end;
    zeit:=temp.Total;
    case HIDStatus of
    32: begin
      Buffer:='Temporary Off for '+inttostr(Zeit)+ 'Sek';
      devstatus:=false;
      end;
    33: begin
        Buffer:='Temporary On for '+inttostr(Zeit)+ 'Sek';
        devstatus:=true;
        end;
    else
      begin
        SendData('Parse', 'Error2:'+inttostr(HIDStatus));
        HIDStatus:=-3;
      end;
    end;
    SendData('Parse','2');
  end;
  if HIDStatus<0 then exit;
  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('StatusDataVariable'), HIDStatus);
  fKernel.VariableManager.WriteVariableString(GetStatusVariableID('StatusTextVariable'), Buffer);
  if HIDStatus=2 then
  begin
    fquery:=false;
    SendData('Parse','Start GetDevStatus');
    getDevstatus;
    exit;
  end;
  Answer:=Buffer;
  SendData('Parse','3');
  status:=devstatus;
  current:=fKernel.VariableManager.ReadVariableBoolean(GetStatusVariableID('StatusVariable'));
  if (status<>current) and (HIDStatus>0) then
    fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('StatusVariable'), status);

 end;

 end.
