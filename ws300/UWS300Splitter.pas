unit UWS300Splitter;
//Thomas Dreßler (www.tdressler.net) 2009 - 2013
interface


uses 
     Classes,Dateutils, SysUtils,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,UWS300interface;

type


 TIPSWS300Splitter = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSWS300Splitter,
                          IIPSSendWS300,
                          IIPSReceiveString)
  private

   timeout:extended;
   fTimeout         :boolean;

   reccount:integer;
   inbuf,recbuf:string;
   newdata,polling,history:boolean;
   config:string;
   //FTDI:IIPSFTDI;
   //--- Custom Objects
   ws300pc_data:Tws300dev_data;

    const MAXSENSORS=9;
   //--- Private Procedures/Functions
   function CreateDevice(Device:integer):IInterface;
   function parse(data:string):boolean;
   procedure log;
   procedure log2file(logfile:string);
   //procedure syncParent;
   function string2hex(s : string):string;
   function hex(value:string):integer;
   function poll(cmd:byte):boolean;

   procedure distribute;
   procedure TimeOutEvent;
   procedure UpdateEvent;


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
   function getCurrentRecord:boolean; stdcall;
   function getNextRecord(logfile:string):boolean; stdcall;
   {
   //get/set
   procedure SetReadInterval(I: integer); stdcall;
   function GetReadInterval: integer; stdcall;
   procedure SetDeviceID(DeviceID: String); stdcall;
   function GetDeviceID: String; stdcall;
   procedure SetLogFile(fname: string); stdcall;
   function GetLogFile: string; stdcall;
    procedure SetAltitude(I: integer); stdcall;
   function GetAltitude: integer; stdcall;
    procedure SetRainPerCount(I: integer); stdcall;
   function GetRainPerCount: integer; stdcall;
   procedure SetWSWINFile(fname: string); stdcall;
   function GetWSWINFile: string; stdcall;
   procedure Setws300pcinterval(I: integer); stdcall;
   function GetWs300pcInterval: integer; stdcall;

   }
   function GetHistoryCount: integer; stdcall;
   function GetVersion:string;stdcall;
   function getConfig:boolean;stdcall;
   procedure setConfig;stdcall;

   { Data Points }
   procedure SendText(Text: String); stdcall;
   procedure ReceiveText(Text: String); stdcall;
   procedure SendWS300Data(DestDevice: Integer; Data: String); stdcall;
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
 //---Module standard
//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSWS300Splitter); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetModuleName(): String;
begin
 Result := 'WS300PC';
end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveWS300);

end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSReceiveString);
 Result[1] := GUIDToString(IIPSSendWS300);
end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSWS300Splitter.GetAliases(): TStringArray;
begin

 SetLength(Result, 3);
 Result[0] := 'WS 300PC USB';
 Result[1] := 'ELV WS 300 PC';
 Result[2] := 'eQ3 WS 300 PC II'

end;

// object Implementation
//------------------------------------------------------------------------------
constructor TIPSWS300Splitter.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //props
 RegisterProperty('DeviceID', '');
 RegisterProperty('ReadInterval', 300);
 RegisterProperty('WS300PCInterval', 300);
 RegisterProperty('LogFile', '');
 RegisterProperty('WSWinFile', '');
 RegisterProperty('Altitude', 0);
 RegisterProperty('RainPerCount', 295);
 RegisterProperty('AutoCreate', true);

 //Vars
 RegisterVariable('CountHistVariable', 'History Record Count', vtInteger);
 RegisterVariable('LastHistVariable', 'Last History Record', vtString);
 RegisterVariable('MoreHistVariable', 'More History Records', vtBoolean);


 //Timers
 RegisterTimer('WS300PC_Update', 0, UpdateEvent);
 RegisterTimer('WS300PC_Timeout', 0, TimeoutEvent);

 history:=false;
 reccount:=0;
 timeout := 3.0; //1sec

//Check Parent
 RequireParent(IIPSFTDI, false);


end;
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.ApplyChanges();
begin
inherited;
end;
//--------------------------------------------------------
procedure TIPSWS300Splitter.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;

 case Runlevel of
  KR_READY:begin
    fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('CountHistVariable'), 0);
    SetTimerInterval('WS300PC_Update', GetProperty('ReadInterval'));
//    syncparent;
  end;
 end;
 end;
  //--------------------------------------------------------
procedure TIPSWS300Splitter.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin


 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then
  if Status = IS_ACTIVE then
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '19200',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'Even'
    ]);


 inherited;


end;

{
//------------------------------------------------------------------------------
destructor  TIPSWS300Splitter.Destroy;
begin

 //Save Settings
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.ResetChanges();
begin

 inherited;
end;
}

{
//get/Set
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SetDeviceID(DeviceID: String); stdcall;
begin

 if fChangedSettings.DeviceID = DeviceID then
  exit;
 fChangedSettings.DeviceID := DeviceID;
 SettingsChanged;

end;

//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetDeviceID: string; stdcall;
var id:String;
begin
 id:=fchangedSettings.DeviceID;
 Result := id;

end;
 //--------------------------------------------------------
procedure TIPSWS300Splitter.SetLogFile(fname:string);
begin
    if fchangedsettings.log=fname then exit;
 fchangedsettings.log:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSWS300Splitter.GetLogFile:string;
begin
  Result:=fchangedsettings.log;
end;
//--------------------------------------------------------
procedure TIPSWS300Splitter.SetWswinFile(fname:string);
begin
    if fchangedsettings.wswin=fname then exit;
 fchangedsettings.wswin:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSWS300Splitter.GetWswinFile:string;
begin
  Result:=fchangedsettings.wswin;
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SetReadInterval(I:integer);stdcall;
begin
 if fChangedSettings.ReadInterval = I then
  exit;
 fChangedSettings.ReadInterval := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetReadInterval:integer;stdcall;
begin
   Result:=fchangedsettings.ReadInterval;
end;
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SetAltitude(I:integer);stdcall;
begin
 if fChangedSettings.Altitude = I then
  exit;
 fChangedSettings.Altitude := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetAltitude:integer;stdcall;
begin
    if fKernelRunlevel = KR_READY then
      if config='' then getconfig;
   Result:=fchangedsettings.Altitude;
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SetRainPerCount(I:integer);stdcall;
begin
 if fChangedSettings.rainPerCount = I then
  exit;
 fChangedSettings.RainPerCount := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetRainPerCount:integer;stdcall;
begin
  if fKernelRunlevel = KR_READY then
    if config='' then getconfig;
   Result:=fchangedsettings.RainPerCount;
end;


//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SetWS300pcInterval(I:integer);stdcall;
begin
 if fChangedSettings.ws300pcInterval = I then
  exit;
 fChangedSettings.ws300pcInterval := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetWS300pcInterval:integer;stdcall;
begin
  if fKernelRunlevel = KR_READY then
   if config='' then getconfig;
   Result:=fchangedsettings.WS300pcInterval;
end;
}
//---Actions
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.UpdateEvent;
begin
sendData('Timerevent','Update');
  update;
end;
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.TimeOutEvent;
begin
  fTimeout:=true;
  sendData('Timerevent','Timeout');
end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.update:boolean;stdcall;
begin
    SendData('Update','requested');
    Result:=getCurrentRecord;

end;
//update parent
// jetzt in Instance change
{
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SyncParent();
var parent: IIPSModule;
//    ModuleSC: IIPSModule;
    DoUpdate: Boolean;
    prop:variant;

    ftdi:IIPSFTDI;
    ftdidev:TFTDIDevice;
    ftdidevs:TFTDIDevices;
    desc,serial:string;
//CONST ELV_STRING='eQ3 WS 300 PC II';
   ELV_STRING:string;
   names:TStringArray;
begin


 parent:=getParent();
 if parent=NIL then exit;

 if supports(parent,IIPSFTDI,ftdi) then
 begin
    //ftdi:=(parent as IIPSModule);
    desc:=parent.GetProperty('Port');
    serial:=GetProperty('DeviceID');

     if desc='' then
     begin

      ftdidevs:=ftdi.GetDevices();
      names:=GetAliases();
      for ftdidev in  ftdidevs do
      begin
        desc:=ftdidev.Description;
        for ELV_STRING in names do
        begin
          if (desc=ELV_STRING) then
          begin
            if not ftdidev.InUse then
            begin
              serial:=ftdidev.SerialNumber;
              if device='' then SetProperty('DeviceID',serial);
              if device=serial then break;
            end;//in use
          end;//desc
        end;//for names
        if GetProperty('DeviceID')=serial then break;
      end; //for devices
      ftdi.SetProperty('Port',serial);
      ftdi.SetProperty('Open',true);
    // klammer zu
    end;//if getport

    end;


    if Supports(parent, IIPSSerialControl) then
     begin
      DoUpdate := False;
      prop:=parent.GetProperty('BaudRate') ;
      if prop <> '19200' then
       begin
        parent.SetProperty('BaudRate','19200');
        DoUpdate := True;
       end;
      prop:=parent.GetProperty('StopBits');
      if  prop<> '1' then
       begin
        parent.SetProperty('StopBits','1');
        DoUpdate := True;
       end;
      prop:=parent.GetProperty('DataBits');
      if prop <> '8' then
       begin
        parent.SetProperty('DataBits','8');
        DoUpdate := True;
       end;
       prop:=parent.GetProperty('Parity');
      if prop <> 'Even' then
       begin
        parent.SetProperty('Parity','Even');
        DoUpdate := True;
       end;
      if DoUpdate then
       begin
        parent.ApplyChanges;
        exit;
       end;
    end;
end;
}
 //data points
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SendText(Text: String); stdcall;
begin
//forward to ftdi
if hasactiveparent then
begin
  SendData('ToFTDI',Text);
  (GetParent() as IIPSFTDI).SendText(Text);

end else    SendData('ToFTDI','No Parent');
end;
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.ReceiveText(Text: String); stdcall;
begin
  //entry for data from parent ftdi
  sendData('RECEIVED',Text);
  recbuf:=recbuf+Text;
  newdata:=true;
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.SendWS300Data(DestDevice: Integer; Data: String); stdcall;
var Intfs: TInterfaceList;
    Intf: IInterface;
    found:boolean;
    id:Integer;
    freeinst:IIPSModule;
begin

 found:=false;
 Intfs := GetChildren();
 try
  for Intf in Intfs do
   if Supports(Intf, IIPSReceiveWS300) then
   begin
   id:=(Intf as IIPSModule).GetProperty('DeviceID');

    if id=-1 then
            freeinst:=(intf as IIPSModule);
     if (Intf as IIPSModule).GetProperty('DeviceID')=DestDevice then
      begin
        sendData('SEND','Use existing ID:'+inttostr(id));
        (Intf as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
        found:=true;
        break;
      end;
   end;
 finally
  Intfs.Free;
 end;
 if not found then
 begin
 if assigned(freeinst) then
       begin
        sendData('SEND','USE FREE ID');
         freeinst.SetProperty('DeviceID',DestDevice);
         freeinst.ApplyChanges;
         (freeinst as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
       end
  else
  begin
        //no free instance available, have to create a new one
        if (GetProperty('AutoCreate')= true) then
        begin
          //new instance needed
          sendData('SENDDATA','CREATE NEW Device');
          intf:=createDevice(DestDevice);
        end
        else
        begin
          sendData('SENDDATA','Creating Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
          LogMessage(KL_MESSAGE,'Creating Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
        end;
        if assigned(intf) then
        begin
          (intf as IIPSReceiveWS300).ReceiveWS300Data(DestDevice,Data);
        end;
   end;
  end;
end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.GetHistoryCount: integer;
begin
  Result:=Reccount;
end;
//------internal implementation
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.distribute;
var datum:string;
    data:string;
    i:integer;
begin
              sendData('DISTRIBUTE','Prepare');
              DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',ws300pc_data.date);
              for i := 0 to MAXSENSORS do
              begin
                with ws300pc_data.records[i] do
                begin
                  data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost]);
                  if i=8 then
                      data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost,ws300pc_data.wind,ws300pc_data.rain,ws300pc_data.israining]);
                  if i=9 then
                      data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;;;;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost,ws300pc_data.rainc,ws300pc_data.press,ws300pc_data.willi]);
                  if temp>'' then
                  begin
                    SendData('DISTRIBUTE','Sensor:'+id+' '+data);
                    SendWS300Data(strtoint(id),data);
                  end;

                end;
              end;
               sendData('DISTRIBUTE','Finished');
end;

//--------------------------------------------------------
function TIPSWS300Splitter.CreateDevice(Device:integer):IInterface;
var
    InstanceID: TInstanceID;
    ModuleID:TGUID;
    Instance: TIPSInstance;
    Intf:IInterface;
begin
  Result:=NIL;
       ModuleID:=IIPSWS300Device;
       if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
      exit;
      sendData('NEWDEVICE','Device:'+inttostr(Device));

     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
     case Device of
      0..7:fKernel.ObjectManager.SetName(InstanceID, 'WS300PC Sensor '+inttostr(Device));
      8:fKernel.ObjectManager.SetName(InstanceID, 'WS300PC KombiSensor');
      9:fKernel.ObjectManager.SetName(InstanceID, 'WS300PC InnenSensor' );
     end;

     fKernel.DataHandler.ConnectInstance(InstanceID,fInstanceID);  //Parents are ourself!
     Instance := fKernel.InstanceManager.GetInstance(InstanceID);
      try
        intf := Instance.InstanceInterface;

        (intf as IIPSModule).SetProperty('DeviceID',Device);
        (intf as IIPSModule).SaveSettings;
        (intf as IIPSModule).ApplyChanges;
      finally

      end;
     Result := intf;
     if Result = nil then
        sendData('NEWDEVICE','Instance Interface is not assigned!')
        else
        sendData('NEWDEVICE','ID:'+inttostr(InstanceID));
end;
  //--------------------------------------------------------
procedure TIPSWS300Splitter.log2file(logfile:string);
var o:Textfile;
    i:integer;
    datum:string;
    dt:TDateTime;
    fname,data:string;
begin
  fname:=logfile;
  if fname='' then exit;
  sendData('Log','File:'+fname);

  if ws300pc_data.date=0 then
    dt:=now
  else
    dt:=ws300pc_data.date;
  assignfile(o,fname);
  try
    if fileexists(fname) then
      append(o)
    else
    begin
      rewrite(o);
      if (fname>'') then
            writeln(o,'Time',';','Typ',';','id',';','Name',';','Temp',';','Hum',';','Bat',';','Lost',';','Wind',';','Rain',';','IsRaining',';','RainCounter',';','Pressure',';','willi',';');
    end; //if

  //DateSeperator:='-';
    DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',dt);
    for i := 1 to MAXSENSORS do
    begin
      with ws300pc_data.records[i] do
      begin
        data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost]);
        if i=8 then
          data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost,ws300pc_data.wind,ws300pc_data.rain,ws300pc_data.israining,ws300pc_data.rainc]);
        if i=9 then
          data:=Format('%s;%s;%s;%s;%s;%s;%s;%s;;;;;%s;%s;',[datum,typ,id,sensor,temp,hum,battery,lost,ws300pc_data.press,ws300pc_data.willi]);
        if (temp>'') then
          writeln(o,data);
      end;//with
    end; //for
  finally
    closefile(o);
  end; //try

end;


//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.log;


var o:Textfile;
    i:integer;
    datum:string;
    dt:TDateTime;
    fname:string;

  function wv(v:string):string;
  begin
  if v='' then v:='0';
    wv:=v;
  end;

begin
 DecimalSeparator:='.';
  if ws300pc_data.date=0 then
    dt:=now
    else
    dt:=ws300pc_data.date;

  fname:=GetProperty('LogFile');
  if fname>'' then log2file(fname);

  //wswin-logfile
  fname:=GetProperty('WSWinFile');
  if fname>'' then
  begin
    assignfile(o,fname);
  try
    if fileexists(fname) then
      append(o)
    else
    begin
      rewrite(o);
      writeln(o,',,2,18,3,19,4,20,5,21,6,22,7,23,8,24,9,25,10,26,1,17,33,134,35');
    end;

  //DateSeperator:='.';
    DateTimetostring(datum,'dd.mm.yyyy,hh:nn',dt);
    write(o,datum);
    for i := 0 to MAXSENSORS do
    begin
      write(o,',',wv(ws300pc_data.records[i].temp),',',wv(ws300pc_data.records[i].hum));
    end;
    writeln(o,',',wv(ws300pc_data.press),',',wv(ws300pc_data.rain),',',wv(ws300pc_data.wind));
    finally
      closefile(o);
    end;//try
  end;//if

end;
//###########################################

function  TIPSWS300Splitter.hex(value:string):integer;
begin
Result:=0;
try
  value:='$'+value;
  Result:=strtoint(value);
except
on e:exception do
  SendData('HEXERROR','Value: <'+value+'> '+e.message);

end;
end;
//------------------------------------------------------------------------------
function  TIPSWS300Splitter.string2hex(s : string):string;
begin
  if s = '' then
    Result := ''
  else
  begin
    SetLength(Result, Length(s)*2);
    BinToHex(PChar(s), PChar(Result), Length(s));
  end; //if
end; //function

//------------------------------------------------------------------------------
function TIPSWS300Splitter.parse(data:string):boolean;
var

      msg:string;
      hmsg:string;
      offs,p,t,s,h,lostcount,flags:integer;
      zeit:TDateTime;
      willi,wind,vpress,rainc,rainv,timediff:integer;
      alt:integer;
      b,val,ir:string;

begin
  //clear record
  for p:=0 to maxsensors do
  begin
      with ws300pc_data.records[p] do
      begin
        typ:='';
        id:='';
        sensor:='';
        temp:='';
        hum:='';
        lost:='';
      end;//with
   end;//for
   ws300pc_data.willi:='';
   ws300pc_data.wind:='';
   ws300pc_data.rain:='';
   ws300pc_data.israining:='';
  //startup values
  DecimalSeparator:='.';
  msg:=data;
  hmsg := string2hex(msg);
  val := '';
  Result:=false;
  zeit := now();
   {
  #          1         2         3         4         5         6         7         8
  # 12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    3100003F75FFF14400E41C00CF2100C91F00CC2A00EF1CFFFD530005470000000000000000CC2A03CAFC  stored
  FE310000367700D50000C73600CF2100DF2700284F00EF1C009E3300D2000000000000000000CC2303F9FB
  #       zzzztttthhtttthhtttthhtttthhtttthhtttthhtttthhtttthhtttthhrrrrwwwwtttthhpppp
  # 3300D50000C73600CF2100DF2700DA2D00EF1C009E3300983B0000000000000000E62F03E700FC  current
  #   tttthhtttthhtttthhtttthhtttthhtttthhtttthhtttthhtttthhrrrrwwwwtttthhppppss
  #   00000011111122222233333344444455555566666677777788888888888888999999999999
  # 320000000010000000000500E60127FC  config
  #   001122334455667788iihhhhmmmm
  }
   //handle differences between current and history record
   case ord(msg[1]) of
    $33: begin
            sendData ('PARSE','Current Record');
            offs:=3;
            val:=copy(hmsg,75,2);
            sendData ('PARSE','Willi:'+val);
            willi := hex(val);
            ir:='NO';
            if (willi and $80)=$80 then ir:='YES';
            ws300pc_data.israining := ir;
            willi:=willi and $0f;
            ws300pc_data.willi:=inttostr(willi);

          end; //if 33
    $31: begin
            offs:=11;
            val:=copy(hmsg,7,4);
            sendData ('PARSE','TimeDiff:'+val);
            timediff:=hex(val);
            zeit :=incminute(zeit,-timediff);
            DateTimetostring(val,'yyyy-mm-dd hh:nn:ss',zeit);
            sendData ('PARSE','history Record:-'+inttostr(timediff)+'min '+val);
            fKernel.VariableManager.WriteVariableString(GetStatusVariableID('LastHistVariable'), val);
        end; //if 33

   else
        begin
            sendData ('PARSE','WS300 illegal data ');
            exit;
        end;
   end;//case
   ws300pc_data.date:=zeit;

   //wind,press,rain
  val:=copy(hmsg,54+offs,4);
  sendData ('PARSE','RAINC:'+val);
  rainc := hex(val);
  rainv :=GetProperty('RainPerCount') * rainc;

  val:=copy(hmsg,58+offs,4);
  sendData ('PARSE','Wind:'+val);
  wind := hex(val);
  alt:=GetProperty('Altitude');

  val:=copy(hmsg,68+offs,4);
  sendData ('PARSE','Press:'+val);
  vpress := hex(val);
  if alt<>0 then
  vpress := vpress+round(alt/8.5); //korrektur nach höhe

  //handle temp+hum for each sensor
  for s:=0 to maxsensors do
  begin

    with  ws300pc_data.records[s] do
    begin
      id:=inttostr(s);
      flags:=ord(config[s+2]);
      //innensensor hat keine flags
      if s<maxsensors then
          SendData('Parse','Sensor:'+inttostr(s)+' Flags:'+string2hex(config[s+2]));
      //check presence flag
      if ((flags and $10)>0) or (s=9) then
      begin
      	p:=(s*6)+offs;
        if s=9 then  p:=p+8;
        SendData('Parse','Sensor:'+inttostr(s)+' Pos:'+inttostr(p)+' Val:'+copy(hmsg,p,6));

        //Temperature and Huminity
        val:=copy(hmsg,p,4);
        t:=hex(val);
        if t>32767  then t:=t-65535;
        val:=copy(hmsg,p+4,2);
        h := hex(val);
        temp := Format('%.1f',[t/10]);
        hum :=inttostr(h);

        //battery and lost records
        if s<9 then
        begin
        //außer Innensensor, der hat keine flags
          if (flags and $e0)<>0 then  b := 'LOW' else b := 'OK';
          lostcount := (flags and $0f);
          battery := b;
          lost := inttostr(lostcount);
        end;

          //assign values
        case s of
            0..7:val := format('T: %s  H: %s  Bat: %s  LR: %s',[temp,hum,battery,lost]);
            8:begin
                ws300pc_data.wind:=Format('%.1f',[wind/10]);
                ws300pc_data.rain := Format('%.1f',[rainv/1000]);
                ws300pc_data.rainc:=inttostr(rainc);
                val := format('T: %s  H: %s  W: %s R: %s IsRain: %s Bat: %s  LR: %s',[temp,hum,ws300pc_data.wind,ws300pc_data.rain,ws300pc_data.israining,battery,lost]);
            end;
            9:begin
               ws300pc_data.press := inttostr(vpress);
               val := format('T: %s  H: %s  P: %s  Willi: %s',[temp,hum,ws300pc_data.press,ws300pc_data.willi]);
              end;
         end; //case
         SendData ('Parse','Sensor:'+ inttostr(s)+' Result: '+val);

      end;  //if
    end; //with
  end;//for
  Result:=true;
  SendData('Parse','Finished');
end; //function

//------------------------------------------------------------------------------
function TIPSWS300Splitter.Poll(cmd:byte):boolean;
 var rcount:integer;
    inchar:char;
    ic:byte;
    escape,start,ende:boolean;
    tosend:string;
    i,z: Integer;
begin


  Result:=false;
  recbuf:='';
  if polling then
  begin
    SendData('Poll','already running, canceled');
    exit;
  end;
//send to ftdi
  tosend := chr($fe)+chr(cmd)+chr($fc);
  sendText(tosend);

//waiting for response
  rcount:=0;
  ic:=0;
  ende:=false;
  start:=false;
  newdata:=false;
  polling:=true;
  SetTimerInterval('WS300PC_Timeout', timeout);
  ftimeout:=false;
  try


  while (not ende) and (not ftimeout) do
  begin
    //sleep(500);

    if (newdata) then
    begin

      //reduce input from prepending bytes until start byte
      while (length(recbuf)>0) do
      begin
        newdata:=false;
        inchar:=recbuf[1];
        ic := ord(inchar);
        if not start then
        begin
          if(ic = $fe) then
          begin
            start := true;
            break;
          end //if fe
          else
          begin
            delete(recbuf,1,1);
            continue;  //waitfot
          end; //if fe
        end //if start
        else
        begin
          break;
        end; //if start
      end; //while inbuf

      //start recording bytes until end byte and do escapes

      escape:=false;
      inbuf:='';
      z:=0;
      for i := 1 to length(recbuf) do
      begin
        ic:=ord(recbuf[i]);
        if(ic = $f8) then
        begin
          escape := true;
          continue;
        end //f8
        else
        begin
          if(escape) then
          begin
            dec(ic);
            escape := false;
          inc(z);
          inbuf:=inbuf+chr(ic);
          end  //esc
          else
          begin
            inc(z);
            inbuf:=inbuf+chr(ic);
            if(ic = $fc) then
            begin
                setlength(inbuf,z);
                ende:=true;
                break; //for
            end; //if fc
          end; //if esc
        end; //if f8
        inc(rcount);
      end; //for

      //restart timer for next bytes
        SetTimerInterval('WS300PC_Timeout', timeout);

    end //if newdata
    else
    begin
      if (ftimeout) then
      begin
        SendData('POLL','Timeout detected');

        break;
      end; //if tout
    end; //if newdata

  end; //while ende
    SetTimerInterval('WS300PC_Timeout', 0);

  finally
  //polling finished, have data or timeout
  polling:=false;
  end;

  if(ic <> $fc) then
  begin
    if(rcount = 0)then SendData ('Poll','no data');
    if(rcount > 0) then SendData ('POLL',' wrong data: '+string2hex(inbuf)) ;

    Result:=false;
    exit;
  end; //<>fc

  Result:=true;
  delete(inbuf,1,1); //remove starting FE
  SendData('POLL','RAW: '+inttostr(length(inbuf))+' bytes: '+string2hex(inbuf));

end;  //function

 //------------------------------------------------------------------------------
function TIPSWS300Splitter.getConfig:boolean;
var cmd,ic:byte;
    l,alt,rainpc,interval:integer;
    cmsg,val:string;
    needapply:boolean;
begin
  result:=false;
  SendData('GetConfig','Poll CMD 32(Config)');
  cmd:=$32;
  config:='';
  needapply:=false;
  if (poll(cmd)) then
  begin
    l:=length(inbuf);
    ic := ord(inbuf[1]);
    if(ic = $32) then
    begin
      if(l = 16)then
      begin
        {  parse config
        # 320000000010000000000500E60127FC
        #   001122334455667788iihhhhmmmm
        #    Sensor flags   ,interval,höhe,regen mm    }
        config := inbuf ;
        cmsg:=string2hex(config);
        SendData('GetConfig','OK');
        val:=cmsg[21]+cmsg[22];
        interval:=hex(val);
        //PCInterval
        if getproperty('WS300PCInterval')<>interval then
        begin
          setProperty('WS300PCInterval',interval);
          needapply:=true;
        end;
        //Altitude
        val:=cmsg[23]+cmsg[24]+cmsg[25]+cmsg[26];
        alt := hex(val);
        if getproperty('Altitude')<>alt then
        begin
          setProperty('Altitude',alt);
          needapply:=true;
        end;

        //rain per Count
        val:=cmsg[27]+cmsg[28]+cmsg[29]+cmsg[30];
        rainpc := hex(val);
        if getproperty('RainPerCount')<>rainpc then
        begin
          setProperty('RainPerCount',rainpc);
          needapply:=true;
        end;

        Result:=true;
        if needapply then ApplyChanges;

      end else begin
        SendData('GetConfig','Bytecount mismatch, should 16, is'+inttostr(l));
      end;//if rcount
    end;//if ic32
  end;//if poll
end;

 //------------------------------------------------------------------------------
function TIPSWS300Splitter.getCurrentRecord:boolean;
var cmd,ic:byte;
    l:integer;

begin
  //stop update timer
  SetTimerInterval('WS300PC_Update', 0);

  //read config
  result:=getConfig;
  if (Result) then
  begin
    Result:=false;
    SendData('GetCurrent','Poll 33 (current)');
    cmd:=$33;
    if (poll(cmd)) then
    begin
      l:=length(inbuf);
      ic:=ord(inbuf[1]);
      if(ic = $33) then
      begin
      //my record
        if(l = 39)then begin
        //len is expected
          SendData('GetCurrent','Data cmd 33 valid,Parse');
          Result:=Parse(inbuf)
        end else begin
          SendData('GetCurrent','Cmd 33 Bytecount mismatch, should 39, is'+inttostr(l));
        end;
      end else begin
       SendData('GetCurrent','Cmd 33 First Byte error');
      end;//if 33
    end;//if poll
  end else begin
     SendData('GetCurrent','Reading Config Error');
  end;//if result
  if Result then
  begin
      distribute;
      log;
      Result:=true;
  end;
  //restart timer
  SetTimerInterval('WS300PC_Update', GetProperty('ReadInterval'));
end;//function

//------------------------------------------------------------------------------
function TIPSWS300Splitter.getNextRecord(logfile:string):boolean;
var cmd,ic:byte;
    l:integer;
begin
  Result:=false;
  //stop update timer
  SetTimerInterval('WS300PC_Update', 0);

  //reset more flage
  fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('MoreHistVariable'), false);
  //reset counter if not history mode
  if (not history) then reccount:=0;
  history:=false;
  if config='' then getConfig;
  if length(config)=16 then
  begin

      SendData('GetNext','Poll 31 (Stored)');
      cmd:=$31;
      if (Poll(cmd)) then
      begin
        l:=length(inbuf);
        ic:=ord(inbuf[1]);
        if(ic = $31) then
        begin
        case l of
          42: begin
                SendData('GetNext','Data valid,Parse');
                //got valid history record
                //enable history mode and record counting and set more flag
                history:=true;
                fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('MoreHistVariable'), true);
                try
                Result:=Parse(inbuf);
                except
                on e:exception do  SendData('GetNext','Parse Ex: '+e.message);

                end;
                if result then
                begin
                    try
                  SendData('GetNext','Parse OK, Log');
                  //start logging to the file
                  log2file(logfile);
                  //increment record counter
                  inc(reccount);
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('CountHistVariable'), reccount);
                  SendData('GetNext','Got Record '+inttostr(reccount));
                    except
                    on e:exception do  SendData('GetNext','Log Ex: '+e.message);

                    end;

                end;

              end;
          3:  begin
                SendData('GetNext','No more records');
              end;
          else
              begin
                SendData('GetNext','Bytecount mismatch 42:'+inttostr(l));
              end;
          end;//case
        end else begin
          SendData('GetNext','First Byte error');

        end;
      end;//poll
  end else begin
        SendData('GetNext','Config record Error');
  end;
  //restart update timer
  SetTimerInterval('WS300PC_Update', GetProperty('ReadInterval'));

end;//getnext
//------------------------------------------------------------------------------
procedure TIPSWS300Splitter.setConfig;
var Text:string;
begin
  //write stored settings to the device
  //afterwards a reset will be done automaticly, followed by a new syncronization
  SendData('SetConfig','CMD 30(SetConfig)');
  Text:=chr($FE)+chr($30);
  Text:=Text+chr((integer(GetProperty('WS300PCInterval'))));
  Text:=Text+chr(hi(integer(GetProperty('Altitude'))))+chr(lo(integer(GetProperty('Altitude'))));
  Text:=Text+chr(hi(integer(GetProperty('RainPerCount'))))+chr(lo(integer(GetProperty('RainPerCount'))));
  Text:=Text+chr($FC);
  SendText(Text);
end;
//------------------------------------------------------------------------------
function TIPSWS300Splitter.getVersion:string;
var cmd,ic:byte;
begin
      //returns firmware version of device
      Result:='';
      SendData('GetVersion','Poll 34 (Version)');
      cmd:=$34;
      ic:=0;
      if (Poll(cmd)) then
      begin
        ic:=ord(inbuf[1]);
      end;
      if(ic = $34) then
      begin
        Result:=string2hex(inbuf[2]);
        Result:=Result[1]+'.'+Result[2];
        SendData('GetVersion','Version:'+Result);
      end else begin
         SendData('GetVersion','Failed');
      end;
end;
end.


