unit UIPSFS20WUESplitter;
//Thomas Dreﬂler (www.tdressler.net) 2012 - 2013
interface

uses
     Classes, SysUtils, strutils,forms, windows,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,
     UWS300interface,UFHZTypes;

type


 TIPSFS20WUESplitter = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSFS20WUESplitter,
                          IIPSSendWS300,
                          IIPSSendFHZ,
                          IIPSReceiveString)
  private



   f_start         :boolean;

    wue_data:Tws300dev_data;
    indata:string;
   //--- Custom Objects
   //--- Private Procedures/Functions
    procedure parse_weather(packet:string);
    procedure parse_fs20(packet:string);
    procedure log(Device:Integer);
    function CreateWS300Device(Device:integer):IInterface;
    function CreateFS20Device(home:string;addr:string):IInterface;
    //procedure SyncParent;
    procedure ForwardWS300Data(Device:integer);
    procedure ForwardFS20Data(data:TFHZDataRX);
    procedure init_fs20wue;
    procedure TimeOutEvent;


  protected
  procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;
    procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   //destructor  Destroy; override;
   //--- IIPSModule implementation
   //procedure LoadSettings(); override;
   //procedure SaveSettings(); override;
   //procedure ResetChanges(); override;
   procedure ApplyChanges(); override;

   //Actions
   function update:boolean; stdcall;
   {
   //Public Get-Set
   procedure SetLogFile(fname: string); stdcall;
   function GetLogFile: string; stdcall;
   procedure SetComPort(ComPort: String); stdcall;
   function GetComPort: String; stdcall;
   procedure SetRainPerCount(I: integer); stdcall;
   function GetRainPerCount: integer; stdcall;
   }
   { Data Points }
   procedure SendText(Text: String); stdcall;
   procedure ReceiveText(Text: String); stdcall;
   procedure SendWS300Data(DestDevice: Integer; Data: String); stdcall;
   procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetChildRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

 end;
implementation


//--Module standards
//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSFS20WUESplitter); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetModuleName(): String;
begin
 Result := 'FS20WUE';
end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSReceiveWS300);
  Result[1] := GUIDToString(IIPSReceiveFHZ);

end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 3);
 Result[0] := GUIDToString(IIPSReceiveString);
 Result[1] := GUIDToString(IIPSSendWS300);
 Result[2] := GUIDToString(IIPSSendFHZ);
end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSFS20WUESplitter.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'FS20WUE';

end;
//--Typ implementation
//------------------------------------------------------------------------------
constructor TIPSFS20WUESplitter.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //props
 //RegisterProperty('ComPort', '');
 RegisterProperty('LogFile', '');
 RegisterProperty('RainPerCount', 295);
 RegisterProperty('AutoCreate', true);


 //Timers
 RegisterTimer('FS20WUE_Timeout', 0, TimeoutEvent);


 //Check Parent
 RequireParent(IIPSSerialPort, false);


end;
{
//------------------------------------------------------------------------------
destructor  TIPSFS20WUESplitter.Destroy;
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.ResetChanges();
begin
 inherited;
end;
}
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.ApplyChanges();
begin
 inherited;
end;
//--------------------------------------------------------
procedure TIPSFS20WUESplitter.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;
 case Runlevel of
  KR_READY:begin
    if HasActiveParent() then
    begin
    //Send an initialize sequence to your device.
    //Your I/O is active here, if not explicitly inactive or in an error state
            //syncparent;
            if GetProperty('RainPerCount')=0 then   SetProperty('RainPerCount',295);
            init_fs20wue;
      end; //if parent
    end; //Ready
  end; //case
end;
//--------------------------------------------------------
procedure TIPSFS20WUESplitter.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin
  //define any more properties as you want. see docs for IPS_SetProperty
  if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then
  begin
    if Status = IS_ACTIVE then
    begin
      ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '4800',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'None'
    ]);

    end;
  end;
  inherited;
  init_fs20wue;
end;
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.init_fs20wue();
begin
fkernel.LogMessage(0,KL_MESSAGE,'FS20WUE','Init');
sendData('Init','Enable FS20 and Weather Data');
SendText(chr(2)+chr(2)+chr($F1)+chr(1)); //enable FS20 immediate send
sleep(15);
SendText(chr(2)+chr(2)+chr($F2)+chr(1)); //enable weather immediate send
sleep(15);
Sendtext(chr(2)+chr(2)+chr($FB)+chr(0)); //use binary protocol
end;


 //parent settings
 {
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SyncParent();
var parent:IIPSModule;
    //ModuleSC: IIPSModule;
    //Module:IIPSModule;
    //Devices:TStringArray;
    port:string;
    DoUpdate:boolean;
begin
    parent := GetParent();
    if parent=NIL then exit;
    DoUpdate:=false;
    if Supports(parent, IIPSSerialPort) then
    begin
    port:=parent.GetProperty('Port');
    //klammer auf
      if port='' then begin
        Devices:=(parent as IIPSSerialPort).GetDevices;
        port:=Devices[0];

      end;
     //klammerzu
      if port<>GetProperty('ComPort') then
      begin
        //parent.setProperty('Port',GetProperty('ComPort'));
        DoUpdate:=true;
        SetProperty('ComPort',port);
        applychanges;
      end;
    end; //port
    if Supports(parent, IIPSSerialControl) then
    begin

      if parent.GetProperty('BaudRate') <> '4800' then
       begin
        parent.SetProperty('BaudRate','4800');
        DoUpdate:=true;
       end;
      if parent.GetProperty('StopBits') <> '1' then
       begin
        parent.SetProperty('StopBits','1');
        DoUpdate:=true;
       end;
      if parent.GetProperty('DataBits') <> '8' then
       begin
        parent.SetProperty('DataBits','8');
        DoUpdate:=true;
       end;
      if parent.GetProperty('Parity') <> 'None' then
       begin
        parent.SetProperty('Parity','None');
        DoUpdate:=true;
       end;
    end; //modulesc

    try

    senddata('ApplySettings','Set Port to '+Port);
    //parent.SetProperty('Open',true);
    if Doupdate then  parent.ApplyChanges;


    except
    on e:exception do
      begin
       LogMessage(KL_ERROR,'Apply:'+e.message);
      end;
    end;

end;
}
{
//  GetSet
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SetComPort(ComPort: String); stdcall;
begin
 if fChangedSettings.ComPort = ComPort then
  exit;

 fChangedSettings.ComPort := ComPort;
 SettingsChanged;

end;

//------------------------------------------------------------------------------
function TIPSFS20WUESplitter.GetComPort: string; stdcall;

begin

 Result :=fchangedsettings.ComPort;
end;
 //--------------------------------------------------------
procedure TIPSFS20WUESplitter.SetLogFile(fname:string);
begin
    if fchangedsettings.log=fname then exit;
 fchangedsettings.log:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSFS20WUESplitter.GetLogFile:string;
begin
  Result:=fchangedsettings.log;
end;


//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SetRainPerCount(I:integer);stdcall;
begin
 if fChangedSettings.rainPerCount = I then
  exit;
 fChangedSettings.RainPerCount := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSFS20WUESplitter.GetRainPerCount:integer;stdcall;
begin

   Result:=fchangedsettings.RainPerCount;
end;
}
//---Data Points
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SendText(Text: String); stdcall;
begin
//send to parent
if hasactiveparent then
(GetParent() as IIPSSerialPort).SendText(Text);
end;

//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.ReceiveText(Text: String); stdcall;
 var
 l:integer;
 dl:integer;
  bt:char;
  b:byte;
  data:string;
  line:string;
  label have_data;
begin
 //entry point for data from parent
 indata:=indata+text;
  //reduce input from prepending bytes until start byte
have_data:

  senddata('ToWork',data2hex(indata));
  if not f_start then
  begin
    line:='';
    while (length(indata)>0) do
    begin
      bt:=indata[1];
      b := ord(bt);
      if(b = 2) then
      begin
        f_start := true;
        //following data needs to be there within 100ms
        SetTimerInterval('FS20WUE_Timeout', 1);
        break;
      end //if 02
      else
      begin
        delete(data,1,1);
        continue;  //waitfor start
      end; //if 02
    end; //if while
  end; //if start

  l:=length(indata);
  if  (f_start) and (l>0) then  //have data
  begin
    line:=indata;
    indata:='';
    l:=length(line);
    if l >7 then
    begin
      dl:=ord(line[2]);
      if not (l<(dl+2)) then //enough data available, frsme may complete
      begin
        data:=copy(line,1,dl+2);
        delete(line,1,dl+2);
        f_start:=false;
        b:=ord(data[3]);
        case b of
          $A1:parse_fs20(data);
          $A2:parse_weather(data);
        else
          sendData('Receive','Unknown Typ:'+btohex(b));
        end;
      end; //l<dl+2
      //check remaining
    end; //l<6
    indata:=line+indata;
    l:=length(indata);
    if l>7 then
    begin
        b:=ord(indata[3]);
        case b of
          $A1: if l>7 then goto have_data;
          $A2: if l>13 then goto have_data;
        end;
    end;


        //restart for next frame

        //If GetCurrentThreadID = MainThreadID then
        //    Application.ProcessMessages;
     ///l>0 next
  end; //f_start

end; //func


//---Actions
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.TimeOutEvent;
var l,i,b,dl:integer;
    data:string;
begin
  SetTimerInterval('FS20WUE_Timeout', 0);
  sendData('Timer','Timeout');
  data:=indata;
  indata:='';
  f_start:=false;
  l:=length(data);
  if l>7 then
  begin
    dl:=ord(data[2]);
    b:=ord(data[3]);
    case b of
          $A1,$A2: begin
            for i:=l to dl+2 do data:=data+chr(0) ;
            sendData('Timer','Resend');
            ReceiveText(copy(data,1,dl+2));
          end
    end;
  end;
end;
//Action
//------------------------------------------------------------------------------
function TIPSFS20WUESplitter.update:boolean;stdcall;
begin
      //there is no function to force new data available with fs20wue
     Result:=true;
end;

//internal routines
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.parse_fs20(packet:string);
var dev,src,prot,db,action,hc,text:string;
  fs20action,fs20ext:byte;
  data:TFHZDataRX;
  l:integer;
begin
        sendData('FS20','Parse');
        SetTimerInterval('FS20WUE_Timeout', 0);

        l:=length(packet);
        if l<>8 then
        begin
          sendData('FS20 Data','Length wrong:'+inttostr(l)+'<->8');
          exit;
        end;
        //FS20 02 06 A2 HH HH HH AA EE
        src:=copy(packet,4,3);
        fs20action:=ord(packet[7]);
        fs20ext:=ord(packet[8]);

        //prepare structure
        data:=TFHZDataRX.Create;
        data.Protocol:=fhzpFS20; //pFS20
        data.Device:=fhzdFS20;
        data.DeviceByte:=1; //?

        data.SrcsByte1:=ord(src[1]);
        data.SrcsByte2:=ord(src[2]);
        data.SrcsByte3:=ord(src[3]);
        data.SrcsByte4:=0;
        data.DataByte1:=fs20action;
        data.DataByte2:=fs20ext;
        data.DataByte3:=0;
        data.DataByte4:=0;
        prot:=FHZProtocol[ord(data.protocol)];
        dev:=FHZDevice[ord(data.Device)];
        src:=chr(data.SrcsByte1)+chr(data.SrcsByte2)+chr(data.SrcsByte3)+chr(data.SrcsByte4);
        db:=chr(data.DataByte1)+chr(data.DataByte2)+chr(data.DataByte3)+chr(data.DataByte4);

        action:='(Action='+fs20_codes.Values[btohex(data.databyte1)];
        if data.databyte1>31 then
              action:=action+' Timer:'+fs20_times[data.databyte2];
        action:=action +') ';
        hc:=bin2four(copy(src,1,3));
        text:=Format('Prot=%s,Dev=%s,DevB=%d,HC:%s(Src=%s),Data=%s %s',
            [prot,dev,ord(data.DeviceByte),hc,data2hex(src),
        data2hex(db),action]);
//            fKernel.VariableManager.WriteVariableString(GetStatusVariableID('StatuspacketVariable'), hc+action);
        senddata('FS20',text);
        ForwardFS20Data(data);
end;
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.ForwardFS20Data(data:TFHZDataRX);
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
        //no free instance available, have to create a new one
        intf:=nil;
        if (GetProperty('AutoCreate')= true) then
        begin
          //new instance needed
          sendData('Distribute FS20','CREATE NEW FS20 Device');
          intf:=createFS20Device(home,addr);
        end
        else
        begin
          text:=Format('Creating FS20 Device ID (HC %s, Addr %s)  disabled by Property AutoCreate',[code,addr]);
          sendData('Distribute FS20',text);
          LogMessage(KL_MESSAGE,text);
        end;

        if assigned(intf) then
        begin
          id:=(intf as IIPSmodule).GetInstanceID;
          text:=Format('Forward to new Child ID %d (HC %s, Addr %s)',[id,code,addr]);
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
function TIPSFS20WUESplitter.CreateFS20Device(home:string;addr:string):IInterface;
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

      fKernel.ObjectManager.SetName(InstanceID, 'FS20WUE FS20 '+home);
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


//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.parse_weather(packet:string);
var l:integer;
  b:byte;
  t,h,w,c:word;
  m:double;
  device:integer;
  text:string;
{
Data:02 0C A2 P A TT FF WW NN R
P=Typ->01=T/F Sensor, 07:KS200/300
A=Adresse 0..7
TT=Temperatur /2er-Complemnt)
FF=Feuchte (0.1%)
WW=Windgeschwindigkei(0.1kmH)
NN=Niederschlag(Wippenschl‰ge)
R=Regenflag 0->Nein, 1 Ja
}
begin
    sendData('Weather','Parse');
    SetTimerInterval('FS20WUE_Timeout', 0);
    l:=length(packet);
    if l<>14 then
    begin
      sendData('Weather','Length wrong:'+inttostr(l)+'<->14');
      exit;
    end;

   //set decimal point
   DecimalSeparator:='.';
   //decode frame
   device:=ord(packet[5]);
   if (device<0) or (device>7) then
   begin
        sendData('Weather','Address '+inttostr(device)+' unknown');
        exit;
   end;

   b:=ord(packet[4]);
   case b of
    $1:device:=device;
    $7:device:=8;
    else
      begin
         sendData('Weather','Type '+inttostr(b)+' unknown');
        exit;
      end;
   end;
   t:=(ord(packet[6])*256)+ord(packet[7]);
   h:=(ord(packet[8])*256)+ord(packet[9]);
   w:=(ord(packet[10])*256)+ord(packet[11]);
   c:=(ord(packet[12])*256)+ord(packet[13]);
    //clear current values
   if device=8 then wue_data.records[device].typ:='Kombi' else wue_data.records[device].typ:='T/F';
   wue_data.records[device].id:=inttostr(device);
   wue_data.records[device].sensor:='';
   wue_data.records[device].temp:=format('%.1f',[t/10]);
   wue_data.records[device].hum:=format('%d',[round(h/10)]);
   wue_data.wind:='';
   wue_data.rain:='';
   wue_data.rainc:='';
   text:=format('ID: %d TYP:%s T: %s  H: %s',
    [device,wue_data.records[device].typ,wue_data.records[device].temp,
    wue_data.records[device].hum]);
   if device=8 then
   begin
    m:=c*GetProperty('RainPerCount');
    if m<>0 then m:=m/1000;
    wue_data.rain:=format('%.1f',[m]);
    wue_data.wind:=format('%d',[round(w/10)]);
    wue_data.rainc:=inttostr(c);
    if (ord(packet[14])=0) then wue_data.israining:='NO' else wue_data.israining:='YES';
    text:=text+format(' W: %s C: %s R: %s IsRain: %s',
      [wue_data.wind,wue_data.rainc,wue_data.rain,wue_data.israining]);
   end;
   senddata('Weather','Parsed:'+text);
   ForwardWS300Data(device);
end;
//--------------------------------------------------------
function TIPSFS20WUESplitter.CreateWS300Device(Device:integer):IInterface;
var
    InstanceID: TInstanceID;
    ModuleID:TGUID;
    Instance: TIPSInstance;
    Intf:IInterface;
begin
      //will create a new ws300device, name it and set relations
      Result:=NIL;
       ModuleID:=IIPSWS300Device;
       if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
      exit;
     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
     if Device=8 then
      fKernel.ObjectManager.SetName(InstanceID, 'FS20WUE KombiSensor')
     else
      fKernel.ObjectManager.SetName(InstanceID, 'FS20WUE Sensor '+inttostr(Device));
     fKernel.DataHandler.ConnectInstance(InstanceID,fInstanceID);  //Parents are ourself!
     Instance := fKernel.InstanceManager.GetInstance(InstanceID);
      try
        intf := Instance.InstanceInterface;

        (intf as IIPSModule).SetProperty('DeviceID',Device);
        (intf as IIPSModule).ApplyChanges;
      finally

      end;
     Result := intf;
     if Result = nil then
        sendData('NEW WS300 Instance','Instance Interface is not assigned!')
        else
        sendData('NEW WS300 INSTANCE','ID:'+inttostr(InstanceID));
end;

//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.ForwardWS300Data(Device:integer);
var datum:string;
  data:string;
begin
              //parsing was OK, start distributing
              sendData('DISTRIBUTE WS300','Prepare');
              wue_data.date:=now;
              log(Device);
              DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',wue_data.date);
                with wue_data.records[Device] do
                begin
                  data:=Format('%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum]);
                  if device=8 then
                  data:=Format('%s;%s;%s;%s;%s;%s;;;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,wue_data.wind,wue_data.rain,wue_data.israining,wue_data.rainc]);
                  //include only sensors with data
                  if temp>'' then
                  begin
                    SendData('DISTRIBUTE WS300','Sensor:'+id+' '+data);
                    SendWS300Data(strtoint(id),data);
                  end;
                end; //with
          //reset status

end;
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SendWS300Data(DestDevice: Integer; Data: String); stdcall;
var Intfs: TInterfaceList;
    Intf: IInterface;
    found:boolean;
    id:Integer;
    freeinst:IIPSModule;
begin
 //distribute data to childs, scan them
 found:=false;
 Intfs := GetChildren();
 try
  for Intf in Intfs do
   if Supports(Intf, IIPSReceiveWS300) then
   begin
   id:=(Intf as IIPSModule).GetProperty('DeviceID');
    if id=-1 then
            //id not set, assume free instance
            freeinst:=(intf as IIPSModule);
    //check if source and target deviceid matches
     if (Intf as IIPSModule).GetProperty('DeviceID')=DestDevice then
      begin
        sendData('SEND WS300','Use existing ID:'+inttostr(id));
        (Intf as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
        found:=true;
        break;
        //found connected child with desired id, take that one
      end;
   end;
 finally
  Intfs.Free;
 end;
 if not found then
 begin
 //no usable connected instance found
 if assigned(freeinst) then
       begin
        sendData('SEND WS300','USE FREE WS300 ID');
         freeinst.SetProperty('DeviceID',DestDevice);
         (freeinst as IIPSModule).ApplyChanges;
         (freeinst as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
       end
  else
  begin
        //no free instance available, have to create a new one
        if (GetProperty('AutoCreate')= true) then
        begin
          //new instance needed
          sendData('SENDDATA','CREATE NEW WS300 Device');
          intf:=createWS300Device(DestDevice);
        end
        else
        begin
          sendData('SENDDATA','Creating WS300 Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
          LogMessage(KL_MESSAGE,'Creating WS300 Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
        end;

        if assigned(intf) then
        begin
          (intf as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
        end;
   end;
  end;
end;


//--------------------------------------------------------
procedure TIPSFS20WUESplitter.log(Device:integer);
var o:Textfile;
    datum:string;
    dt:TDateTime;
    fname:String;

function wv(v:string):string;
  begin
  if v='' then v:='0';
  wv:=v;
  end;

begin

  if wue_data.date=0 then
    dt:=now
    else
    dt:=wue_data.date;

  fname:=getProperty('LogFile');
  if fname >'' then
  begin
  assignfile(o,fname);
  try
  if fileexists(fname) then
    append(o)
  else
  begin
      rewrite(o);
      if (fname>'') then
            writeln(o,'Time',';','Typ',';','id',';','Name',';','Temp',';','Hum',';Bat;Lost;','Wind',';','Rain',';','Raining');
  end;

  //DateSeperator:='-';
  DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',dt);

  begin
    with wue_data.records[Device] do
    begin
      if (temp>'') then
      begin
       writeln(o,datum,';',typ,';',id,';',sensor,';',temp,';',hum,';;;',wue_data.wind,';',wue_data.rain,';',wue_data.israining);
       SendData('Log','Sensor:'+id);
      end;
    end;
  end;

  finally
      closefile(o);
  end;   //try
  end; //if

end;
//------------------------------------------------------------------------------
procedure TIPSFS20WUESplitter.SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
var text,prot,dest,db,action:string;
begin
    //function to make the sendfhz interface happy
    //only logging, but should never called from connected instances
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
end.
