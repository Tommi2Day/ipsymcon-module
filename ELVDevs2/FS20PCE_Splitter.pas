unit FS20PCE_Splitter;

//Thomas Dreßler (www.tdressler.net) 2012-2013
interface

uses Windows, SysUtils, Forms, StrUtils, classes,math,
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes,
     UELV2Interface,UFHZtypes;

type

TIPSFS20PCE = class(TIPSModuleObject,
                        IIPSModule,
                          IIPSReceiveHID,
                          IIPSSendFHZ,
                        IIPSFS20PCE)
 const ReportID_Send=1;
 const ReportID_Answer=2;
 const cmdVersion=$F0;
 const cmdSendOnce=$F1;
 const cmdSendMore=$F2;
 const cmdCancel=$F3;
 const cmdAnswer=$A0;


 CONST HID_STRING='FS20PCE';
  private
   //--- Basic Structures
   version:string;
   //ftimer:          TTimerID;

   //--- Custom Objects
{
   //get/set
   function getDevice:string; stdcall;
   procedure setDevice(Device:string); stdcall;
   }
   function getVersion:string; stdcall;
   //--- Private Procedures/Functions
   procedure Parse_Event(Text:string);
   function map_timer(s:string):byte;
   function CreateFS20Device(home:string;addr:string):IInterface;
   procedure ForwardFS20Data(data:TFHZDataRX);
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
   class function GetChildRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;
  //--- IIPSFS20PCE implementation


  //--Data Point HID
  //procedure SendEvent(ReportID:Byte;Text:string); stdcall;
  procedure ReceiveEvent(ReportID:byte;Text:string);stdcall;
  //--Data Point FHZ emulated Interface
  procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
  //procedure ReceiveFHZData(Data: TFHZDataRX); stdcall;
 end;

implementation

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSFS20PCE); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetModuleName(): String;
begin
 Result := 'FS20PCE';
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendHID);
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveFHZ);
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSReceiveHID);
 Result[1] := GUIDToString(IIPSSendFHZ);

end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSFS20PCE.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'ELV FS20PCE';

end;

//------------------------------------------------------------------------------
constructor TIPSFS20PCE.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 inherited;

 //RegisterProperty( 'DeviceID','');
 //RegisterVariable('StatusTextVariable','StatusText',vtString);
 //RegisterVariable('VersionVariable','Version',vtString);

 //Check Parent
 RequireParent(IIPSHID,true);

end;
{
//------------------------------------------------------------------------------
destructor  TIPSFS20PCE.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCE.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCE.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCE.ResetChanges();
begin

 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSFS20PCE.ApplyChanges();

begin
 inherited;
 syncparent;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20PCE.ProcessKernelRunlevelChange(Runlevel: Integer);
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
procedure TIPSFS20PCE.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
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
procedure TIPSFS20PCE.syncparent;
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
 //          mydev:=serial;
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
   //         setProperty('DeviceID',serial);
   //         applyChanges;
            break;
        end;
      end; //for
 //    end;//if serial
 {klammer auf
    do not open if its not already done
     if serial=mydev then
     begin

       hid.SetOpen(true);
       parent.applychanges;
     end;
 //klammer zu }
  end; //suppoers
 end; //parent

end;

 {
///Get/Set
//------------------------------------------------------------------------------
   function TIPSFS20PCE.getDevice:string;stdcall;
   begin
    result:=fchangedsettings.DeviceID;
   end;
   //------------------------------------------------------------------------------
   procedure TIPSFS20PCE.setDevice(Device:string);stdcall;
   begin
    fchangedsettings.DeviceID:=Device;
    settingschanged;
   end;
  }
   //------------------------------------------------------------------------------
 function TIPSFS20PCE.getVersion:string; stdcall;
 begin
   result:=version;
 end;
//Datapoint
//------------------------------------------------------------------------------
procedure TIPSFS20PCE.ReceiveEvent(ReportID:byte;Text:string); stdcall;
var l:integer;
   Answer        : string;
begin
 Answer:=chr(reportid)+Text;
 SendData('Received', 'Report:'+inttostr(reportid)+' Msg:'+data2hex(Answer));
 l:=length(Answer);
 if l=13 then Parse_Event(Answer)
  else
   SendData('Received', 'Length failure:'+inttostr(l));
end;
//------------------------------------------------------------------------------
procedure TIPSFS20PCE.SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
var text,prot,dest,db,action:string;
begin
    action:='';
    prot:=FHZProtocol[ord(data.protocol)];
    dest:=chr(data.DestByte1)+chr(data.DestByte2)+chr(data.DestByte3);
    db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3);
    case data.Protocol of
    fhzpFS20:
      begin
        action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
        if data.databyte1>31 then
          action:=action+' Timer:'+fs20_times[data.databyte2];
         action:=action +') ';
        text:=Format('NumB=%d,Prot=%s,Dest=%s(HC:%s),Data=%s %s',
      [NumBytes,prot,string2hex(dest), bin2four(leftstr(dest,3)),
        string2hex(db),action]);
      end;
     fhzpFHT:
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s(HC:%02d %02d),Data=%s',
      [NumBytes,prot,string2hex(dest), data.DestByte1,data.DestByte2,
        string2hex(db)]);
      end;
      fhzpHMS:
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s(DeviceID:%02x%02x),Data=%s',
      [NumBytes,prot,string2hex(dest), data.DestByte1,data.DestByte2,
        string2hex(db)]);
      end;
      else
      begin
       text:=Format('NumB=%d,Prot=%s,Dest=%s,Data=%s',
        [NumBytes,prot,string2hex(dest), string2hex(db)]);
      end;
    end;

    senddata('SendFHZdata',text);
end;
//------------------------------------------------------------------------------
procedure TIPSFS20PCE.parse_Event(Text:string);
var dev,src,prot,db,action,buffer,hc:string;
  data:TFHZDataRX;
begin

        SendData('Parse','entered');
        data:=TFHZDataRX.Create;
        data.Protocol:=fhzpFS20; //pFS20
        data.Device:=fhzdFS20;
        data.DeviceByte:=1; //?
        buffer:=bcd2string(copy(text,3,6));
        buffer:=four2bin(buffer);
        if length(buffer)=3 then
        begin
          data.SrcsByte1:=ord(buffer[1]);
          data.SrcsByte2:=ord(buffer[2]);
          data.SrcsByte3:=ord(buffer[3]);
        end;
        data.SrcsByte4:=0;
        data.DataByte1:=ord(Text[9]);
        buffer:=bcd2string(copy(Text,10,4));
        if (length(buffer)<8) or (buffer[1]='0') then
        begin
          data.DataByte2:=0;
        end
        else
        begin
          data.DataByte1:=data.DataByte1+$20;
          data.DataByte2:=map_timer(buffer);
          version:='Version '+buffer[7]+'.'+buffer[8];
          //fKernel.VariableManager.WriteVariableString(GetStatusVariableID('VersionVariable'),version);
        end;
        data.DataByte3:=0;
        data.DataByte4:=0;
        prot:=FHZProtocol[ord(data.protocol)];
        dev:=FHZDevice[ord(data.Device)];
        src:=chr(data.SrcsByte1)+chr(data.SrcsByte2)+chr(data.SrcsByte3)+chr(data.SrcsByte4);
        db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3)+chr(data.DataByte4);
        action:='';
        case data.Device of
        fhzdFS20:
          begin
            action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
            if data.databyte1>31 then
              action:=action+' Timer:'+fs20_times[data.databyte2];
            action:=action +') ';
            hc:=bin2four(leftstr(src,3));
            text:=Format('Prot=%s,Dev=%s,DevB=%d,HC:%s(Src=%s),Data=%s %s',
              [prot,dev,ord(data.DeviceByte),hc,data2hex(src),
              data2hex(db),action]);
            //fKernel.VariableManager.WriteVariableString(GetStatusVariableID('StatusTextVariable'), hc+action);
            senddata('Parse',text);
          end;//case fs20
        else
        begin
        //not an fs20 proto, not supported
          text:=Format('Not Supported: Prot=%s,Dev=%s,DevB=%d,Src=%s Data=%s',
          [prot,dev,ord(data.DeviceByte),data2hex(src),
          data2hex(db)]);
          senddata('Parse',text);
          if assigned(data) then  data.Free;
          exit;
        end; //cases
    end;
    //data OK, set devices
    ForwardFS20Data(data);
  end; //function
//------------------------------------------------------------------------------
 function TIPSFS20PCE.map_timer(s:string):byte;
 var
 r:byte;
 buffer:string;
 i,j,b,v:integer;
 f,t:double;
 begin
 Result:=0;
 if length(s)<5 then
 begin
   senddata('Map Timer','Timer Field short');
   exit;
 end;
 if s[1]='0' then
 begin
   senddata('Map Timer','Timer Field invalid');
   exit;
 end;
 r:=0;
 Buffer:=copy(s,2,5);

 v:=strtoint(Buffer);
 if v>0 then
 begin
   //fs20_times
  for I := 0 to 13 do
  begin
    f:=power(2,i);
    for j := 0 to 15 do
    begin
      if j=0 then continue; //x0 ist On
      b:=i*16+j;
      t:=int(f)*j;
      if v>t then continue;
      r:=b;
      break;
    end; //for j
    if r>0 then break; //have result

  end; //
 senddata('Map Timer','Timer: '+inttostr(r));
 result:=r;
 end; //if v

 end;  //function

 //------------------------------------------------------------------------------
procedure TIPSFS20PCE.ForwardFS20Data(data:TFHZDataRX);
var   Intfs: TInterfaceList;
  Intf: IInterface;
  id:integer;
  text,code,home,addr,code2:string;
  fs20_devs:TFS20Devices;
  fs20:TFS20Device;
  have_fs20:boolean;
begin
  Intfs:=nil;
  have_fs20:=false;
  home:=bin2four(chr(data.SrcsByte1)+chr(data.SrcsByte2));
  addr:=bin2four(chr(data.SrcsByte3));
  if length(home)>9 then
    home:=copy(home,2,4)+copy(home,7,4);
  if length(addr)>4 then
    addr:=copy(addr,2,4);
  try
      Intfs := GetChildren();
      if Intfs.Count>0 then
      begin
        for Intf in Intfs do
        begin
          if Supports(Intf, IIPSReceiveFHZ) then
          begin
            id:=(intf as IIPSmodule).GetInstanceID;
            code:='';
            if Supports(Intf,IIPSFS20EX) then
            begin
                 code:=(intf as IIPSFS20EX).GetHomeCode();
            end;
            if (home=code) then
            begin
              fs20_devs:=(intf as IIPSFS20EX).GetDevices();
              for fs20 in fs20_devs do
                begin
                  code2:=fs20.Address+fs20.SubAddress;
                  if code2=addr then
                  begin
                    text:=Format('Forward to Child ID %d (HC %s, Addr %s)',[id,code,addr]);
                    SendData('SEND FS20',text);
                    (Intf as IIPSReceiveFHZ).ReceiveFHZData(Data);
                    have_fs20:=true;
                    break;
                  end; //if
                end; //for
                if not have_fs20 then
                begin
                  //add new device to existing instance
                  (intf as IIPSFS20EX).addDevice(copy(addr,1,2),copy(addr,3,2));
                   (intf as IIPSmodule).applychanges;
                   text:=format('Add new Device to Child ID %d (HC %s, Addr %s)',[id,code,addr]);
                   senddata('Send FS20',text);
                   (Intf as IIPSReceiveFHZ).ReceiveFHZData(Data);
                    have_fs20:=true;
                end;
            end; //if home=code
          end; //if
        end; //for
        if not have_fs20 then
        begin
        //maybe obsolte, should not happens
          SendData('Distribute FS20','No matching Device for HC '+home+' Addr '+addr+' found');
        end;

      end else
      begin
        SendData('Distribute FS20','No FS20 Device connected');
      end; //if
      if not have_fs20 then
      begin
        //add new instance
        sendData('Distribute FS20','CREATE NEW FS20 Device');
        intf:=CreateFS20Device(home,addr);
        if assigned(intf) then
        begin
          text:=Format('Forward to new Child (HC %s, Addr %s)',[code,addr]);
          SendData('SEND FS20',text);
          (intf as IIPSReceiveFHZ).ReceiveFHZData(Data);
        end;
      end;
    finally
      if assigned(Intfs) then Intfs.Free;
      if assigned(data) then  data.Free;

    end; //try
end;
//--------------------------------------------------------
function TIPSFS20PCE.CreateFS20Device(home:string;addr:string):IInterface;
var
    InstanceID: TInstanceID;
    ModuleID:TGUID;
    Instance: TIPSInstance;
    Intf:IInterface;
begin
      //will create a new ws300device, name it and set relations
      Result:=NIL;
       ModuleID:=IIPSFS20EX;
       if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
      exit;
     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));

      fKernel.ObjectManager.SetName(InstanceID, 'FS20PCE FS20 '+home);
     fKernel.DataHandler.ConnectInstance(InstanceID,fInstanceID);  //Parents are ourself!
     Instance := fKernel.InstanceManager.GetInstance(InstanceID);
      try
        intf := Instance.InstanceInterface;

        (intf as IIPSFS20EX).SetHomeCode(home);
        (intf as IIPSFS20EX).AddDevice(copy(addr,1,2),copy(addr,3,2));
        (intf as IIPSModule).ApplyChanges;
      finally

      end;
     Result := intf;
     if Result = nil then
        sendData('NEW FS20EX Instance','Instance Interface is not assigned!')
        else
        sendData('NEW FS20EX INSTANCE','ID:'+inttostr(InstanceID));
end;

 end.
