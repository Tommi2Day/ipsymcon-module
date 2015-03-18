unit FS20PCS_Splitter;

//Thomas Dreßler (www.tdressler.net) 2012-2013
interface

uses Windows, SysUtils, Forms, StrUtils, classes,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,
     UELV2Interface,UFHZtypes;

type

TIPSFS20PCS = class(TIPSModuleObject,
                        IIPSModule,
                          IIPSReceiveHID,
                          IIPSSendFHZ,
                        IIPSFS20PCS)
 const ReportID_Send=1;
 const ReportID_Answer=2;
 const cmdVersion=$F0;
 const cmdSendOnce=$F1;
 const cmdSendMore=$F2;
 const cmdCancel=$F3;
 const cmdAnswer=$A0;


 CONST HID_STRING='FS20PCS';
  private
   //--- Basic Structures
   fquery:boolean;
   Answer        : string;
   AnswerID:integer;

   timeout:extended;
   fPCSTimeout         :boolean;
   fAnswer         :boolean;
   version:string;
   //ftimer:          TTimerID;

   //--- Custom Objects
 {
   //get/set
   function getDevice:string; stdcall;
   procedure setDevice(Device:string); stdcall;
   }
   //--- Private Procedures/Functions
   function MakeReport(text:string):boolean;
  procedure ParseReport(Data:String);
   procedure TimeOutEvent;
   procedure syncparent;


  protected
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;

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
  //--- IIPSFS20PCS implementation
 function getVersion:string; stdcall;

  //--Data Point HID
  procedure SendEvent(ReportID:Byte;Text:string); stdcall;
  procedure ReceiveEvent(ReportID:byte;Text:string);stdcall;
  //--Data Point FHZ emulated Interface
  procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
  //procedure ReceiveFHZData(Data: TFHZDataRX); stdcall;

 end;

implementation

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSFS20PCS); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetModuleName(): String;
begin
 Result := 'FS20PCS';
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendHID);
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSReceiveHID);
 Result[1] := GUIDToString(IIPSSendFHZ);
 //Result[2] := GUIDToString(IIPSReceiveFHZ);
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCS.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'ELV FS20PCS';

end;

//------------------------------------------------------------------------------
constructor TIPSFS20PCS.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 inherited;

 //RegisterProperty( 'DeviceID','');

 //RegisterVariable('StatusTextVariable','StatusText',vtString);
 //RegisterVariable('VersionVariable','Version',vtString);

 //timer
 RegisterTimer('FS20PCS_TimeOut', 0, TimeoutEvent);
 timeout := 1;
 //Check Parent
 RequireParent(IIPSHID,true);

end;
{
//------------------------------------------------------------------------------
destructor  TIPSFS20PCS.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCS.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCS.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCS.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSFS20PCS.ApplyChanges();
begin
 inherited;
 syncparent;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCS.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;

 case Runlevel of
  KR_READY:
   if HasActiveParent() then
    //Send an initialize sequence to your device. Your I/O is active here, if not explicitly inactive or in an error state
    syncparent;
  end;
 end;
 //------------------------------------------------------------------------------
procedure TIPSFS20PCS.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 //define any more properties as you want. see docs for IPS_SetProperty
 //comaparising might be >=, =, <=
 //multiple, same properties will be threatet as an OR statement

 //either of these port is allowed. last will be configured, if current port do not match
 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then
  if Status = IS_ACTIVE then ;
  inherited;
end;


//------------------------------------------------------------------------------
procedure TIPSFS20PCS.syncparent;
var parent:IIPSModule;
    HID:IIPSHID;
    hiddev:THIDDevice;
    hiddevs:THIDDevices;
    desc,serial:string;
    //mydev:string;
    vid,pid:integer;
    InstanceID:word;

begin
  if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then parent:=getParent();
  if parent<>NIL then
  begin
    if supports(parent,IIPSHID,HID) then
    begin
{
    mydev:=getProperty('DeviceID');
     serial:=hid.GetDeviceSerial;
     if mydev='' then
     begin
}
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
           //mydev:=serial;
           hid.SetDeviceSerial(serial);
            hid.SetDeviceVendorID(vid);
            hid.SetDeviceProductID(pid);
            InstanceID:=parent.GetInstanceID;
            if fKernel.ObjectManager.GetName(InstanceID) = 'HID' then
              fKernel.ObjectManager.SetName(InstanceID,'HID '+HID_STRING);
{
            parent.SetProperty('DeviceSerial',serial);
            parent.SetProperty('DeviceVendorID',vid);
            parent.SetProperty('DeviceProductID',pid);
}
            parent.applychanges;
 //           setProperty('DeviceID',serial);
            //applychanges;
            break;
        end;
      end; //for
  //   end;//if serial
  {
     //klammer auf

      do not open if its not already done
     if serial=mydev then
     begin

       hid.SetOpen(true);
       parent.applychanges;
     end;
     // klammer zu
  }
  end; //supports
 end; //parent

end;

{
///Get/Set
//------------------------------------------------------------------------------
   function TIPSFS20PCS.getDevice:string;stdcall;
   begin
    result:=fchangedsettings.DeviceID;
   end;
   //------------------------------------------------------------------------------
   procedure TIPSFS20PCS.setDevice(Device:string);stdcall;
   begin
    fchangedsettings.DeviceID:=Device;
    settingschanged;
   end;
}
//Datapoint
//------------------------------------------------------------------------------
procedure TIPSFS20PCS.SendEvent(ReportID:byte;Text: String);stdcall;
begin
  if hasactiveparent then
    begin
      SendData('SendEvent','Data:'+data2hex(chr(ReportID)+text));
      (GetParent() as IIPSSendHID).SendEvent(ReportID,Text);
    end
  else
  begin
    SendData('SendEvent', 'No HID Parent, ignore');
    fAnswer:=true;
  end;
end;
//------------------------------------------------------------------------------
procedure TIPSFS20PCS.ReceiveEvent(ReportID:byte;Text:string); stdcall;
begin


 Answer:=chr(reportid)+Text;
 fAnswer:=true;
 SendData('Received', 'Report:'+inttostr(reportid)+' Msg:'+data2hex(Answer));
 parsereport(Answer);

end;
 //------------------------------------------------------------------------------
procedure TIPSFS20PCS.TimeOutEvent;
begin
  fPCSTimeout:=true;
  sendData('Timer','HIDTimeout');
  SetTimerInterval('FS20PCS_TimeOut', 0);
end;
//------------------------------------------------------------------------------
function TIPSFS20PCS.MakeReport(text:string):boolean;
var l,i:integer;
  r:byte;
  data:string;
begin
  Result:=false;
  if fquery then
  begin
    SendData('Send','Query Already Active');
    exit;
  end;
  //make frame
  l:=length(text);
  r:=ReportID_Send;
  data:=chr(l)+text;
  //fill to 11chars
  for I := l+2 to 10 do data:=data+#0;
  //send
  Answer:='';
  fAnswer:=false;
  fquery:=true;
  fPCStimeout:=false;
  SetTimerInterval('FS20PCS_TimeOut', timeout);

  try
   Sendevent(r,data);
  for i:=1 to 100 do
  begin
    If GetCurrentThreadID = MainThreadID then
            Application.ProcessMessages;
    sleep(20);
    if (fAnswer)  then  break;
    if fPCSTimeout then begin
      SendData('Timeout','detected');
      break;
    end;

  end; //while ende
  SetTimerInterval('FS20PCS_TimeOut', 0);

  except
  //polling finished, have data or timeout
  end;

  fquery:=false;
  l:=length(Answer);
  Result:=(l>0);
  SendData('Send','End Send l='+inttostr(l));

 end;

 //------------------------------------------------------------------------------
 function TIPSFS20PCS.GetVersion:string;stdcall;
 var buffer:string;
    v:string;
 begin
     senddata('GetVersion','entered');
if version='' then
begin
     result:='';
     buffer:=chr(cmdVersion);
     if (MakeReport(buffer)) then
     begin

        if AnswerID=1 then
        begin
          buffer:=btohex(ord(Answer[5]));
          senddata('GetVersion','Got Answer:'+buffer);
          v:='Version '+ buffer[1]+'.'+buffer[2];
          version:=v;
          SendData('GetVersion','Result:'+Version);
          result:=version;
   //       fKernel.VariableManager.WriteVariableString(GetStatusVariableID('VersionVariable'),version);
        end
        else
        begin
          senddata('GetVersion','Answer Error');
        end;
     end
     else
     begin
      senddata('GetVersion','Command Failed');
     end;
end else begin
    result:=version;
end;
 end;
  //------------------------------------------------------------------------------
 procedure TIPSFS20PCS.ParseReport(data:string);
 const answSuccess=0;
 const answVersion=1;
 const answUnknownCMD=2;
 const answErrLen=3;
 const answCancel=4;
 const answNoCancel=5;
 var buffer:string;
 l:integer;
 const AnswerHeader=chr(ReportID_Answer)+chr(3)+chr(cmdAnswer);

 begin
  l:=length(Data);
  SendData('Parse','Len:'+inttostr(l));
  if l<>5 then exit;
  buffer:=copy(Data,1,3);
  if buffer=AnswerHeader then
  begin
    AnswerID:=ord(data[4]);
    case AnswerID of
    answSuccess: Buffer:='OK';
    answVersion: Buffer:='Version';
    answUnknownCMD: Buffer:='Error:Unknown Command';
    answErrLen: Buffer:='Error:Wrong Command Len';
    answCancel: Buffer:='Cancelled';
    answNoCancel: Buffer:='No Cancellation needed';
    else
        SendData('Parse', 'Answer Error: ID='+inttostr(AnswerID));
    end;
    SendData('Parse',buffer+':'+data2hex(copy(data,4,2)));
  end;
  if AnswerID<0 then exit;
  buffer:=btohex(ord(Answer[5]));
  version:='Version '+ buffer[1]+'.'+buffer[2];
  //fKernel.VariableManager.WriteVariableString(GetStatusVariableID('StatusTextVariable'), Buffer);
  //fKernel.VariableManager.WriteVariableString(GetStatusVariableID('VersionVariable'),version);
 end; //function
//------------------------------------------------------------------------------
procedure TIPSFS20PCS.SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
var text,prot,dest,db,action,buffer:string;
begin
    action:='';
    prot:=FHZProtocol[ord(data.protocol)];
    dest:=chr(data.DestByte1)+chr(data.DestByte2)+chr(data.DestByte3);
    db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3);
    case data.Protocol of
    fhzpFS20:
      begin

        //prepare resend
        buffer:=chr(cmdSendOnce)+dest+chr(data.DataByte1)+chr(data.DataByte2);
        if (MakeReport(buffer)) then
          text:='Send OK:' else text:='Send Failed:';
        action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
        if data.databyte1>31 then
          action:=action+' Timer:'+fs20_times[data.databyte2];
         action:=action +') ';
        text:=text+Format('NumB=%d,Prot=%s,Dest=%s(HC:%s),Data=%s %s',
      [NumBytes,prot,data2hex(dest), bin2four(leftstr(dest,3)),
        data2hex(db),action]);
      end;
      else
      begin
       text:='Unimplemented:'+Format('NumB=%d,Prot=%s,Dest=%s,Data=%s',
        [NumBytes,prot,data2hex(dest), data2hex(db)]);
      end;
    end;

    senddata('FHZSend',text);
end; //procedure

end.
