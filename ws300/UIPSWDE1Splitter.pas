unit UIPSWDE1Splitter;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2013
interface

uses
     Classes, SysUtils,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,UWS300interface;

type


 TIPSWDE1Splitter = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSWDE1Splitter,
                          IIPSSendWS300,
                          IIPSReceiveString)
  private

    wde1_data:Tws300dev_data;
    line:string;
    const MAXSENSORS=9;
   //--- Custom Objects
   //--- Private Procedures/Functions
    function parse:boolean;
    procedure log;
    function CreateDevice(Device:integer):IInterface;
    //procedure SyncParent;
  protected
    procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
    procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
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
   procedure SetWSWINFile(fname: string); stdcall;
   function GetWSWINFile: string; stdcall;
   procedure SetComPort(ComPort: String); stdcall;
   function GetComPort: String; stdcall;
   procedure SetRainPerCount(I: integer); stdcall;
   function GetRainPerCount: integer; stdcall;
   }
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


//--Module standards
//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSWDE1Splitter); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetModuleName(): String;
begin
 Result := 'WDE1';
end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveWS300);

end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 2);
 Result[0] := GUIDToString(IIPSReceiveString);
 Result[1] := GUIDToString(IIPSSendWS300);
end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSWDE1Splitter.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'WDE1';

end;
//--Typ implementation
//------------------------------------------------------------------------------
constructor TIPSWDE1Splitter.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //props
 //RegisterProperty('ComPort', '');
 RegisterProperty('LogFile', '');
 RegisterProperty('WSWinFile', '');
 RegisterProperty('RainPerCount', 295);
 RegisterProperty('AutoCreate', true);


 //Check Parent
 RequireParent(IIPSSerialPort, false);


end;
{
//------------------------------------------------------------------------------
destructor  TIPSWDE1Splitter.Destroy;
begin

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.LoadSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.ResetChanges();
begin
 inherited;

end;
}
//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.ApplyChanges();
begin
 inherited;
end;
//--------------------------------------------------------
procedure TIPSWDE1Splitter.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;
 case Runlevel of
  KR_READY:begin
    //syncparent;
    if GetProperty('RainPerCount')=0 then   SetProperty('RainPerCount',295);
  end;
 end;
 end;
  //--------------------------------------------------------
procedure TIPSWDE1Splitter.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 if InstanceID = fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) then
  if Status = IS_ACTIVE then
   ForceParentConfiguration(IIPSSerialControl,
    [
      'BaudRate', '=', '9600',
      'StopBits', '=', '1',
      'DataBits', '=', '8',
      'Parity', '=', 'None'
    ]);

 inherited;
end;

//--------------------------------------------------------
function TIPSWDE1Splitter.CreateDevice(Device:integer):IInterface;
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
      fKernel.ObjectManager.SetName(InstanceID, 'WDE1 KombiSensor')
     else
      fKernel.ObjectManager.SetName(InstanceID, 'WDE1 Sensor '+inttostr(Device));
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
        sendData('NEWInstance','Instance Interface is not assigned!')
        else
        sendData('NEWINSTANCE','ID:'+inttostr(InstanceID));
end;
 //parent settings
 {
//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.SyncParent();
var parent:IIPSModule;
   // ModuleSC: IIPSModule;
    //Module:IIPSModule;
    //Devices:TStringArray;
    port:string;
begin
    parent := GetParent();
    if parent=NIL then exit;

    //set Port
    if Supports(parent, IIPSSerialPort) then
    begin
    port:=parent.GetProperty('Port');

     //klammer auf
      if port='' then begin
        Devices:=(Module as IIPSSerialPort).GetDevices;
        port:=Devices[0];

      end;
      //klammer zu
      parent.setProperty('Port',port);
      if port <>GetProperty('ComPort') then SetProperty('ComPort',port);
      end; //port

    if Supports(parent, IIPSSerialControl) then
    begin

      if parent.GetProperty('BaudRate') <> '9600' then
       begin
        parent.SetProperty('BaudRate','9600');

       end;
      if parent.GetProperty('StopBits') <> '1' then
       begin
        parent.SetProperty('StopBits','1');

       end;
      if parent.GetProperty('DataBits') <> '8' then
       begin
        parent.SetProperty('DataBits','8');

       end;
      if parent.GetProperty('Parity') <> 'None' then
       begin
        parent.SetProperty('Parity','None');
       end;
    end; //modulesc
    try
      senddata('ApplySettings','Set Port to '+Port);
      parent.SetProperty('Open',true);
      parent.ApplyChanges;
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
procedure TIPSWDE1Splitter.SetComPort(ComPort: String); stdcall;
begin
 if fChangedSettings.ComPort = ComPort then
  exit;

 fChangedSettings.ComPort := ComPort;
 SettingsChanged;

end;

//------------------------------------------------------------------------------
function TIPSWDE1Splitter.GetComPort: string; stdcall;

begin

 Result :=fchangedsettings.ComPort;
end;
 //--------------------------------------------------------
procedure TIPSWDE1Splitter.SetLogFile(fname:string);
begin
    if fchangedsettings.log=fname then exit;
 fchangedsettings.log:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSWDE1Splitter.GetLogFile:string;
begin
  Result:=fchangedsettings.log;
end;

//--------------------------------------------------------
procedure TIPSWDE1Splitter.SetwswinFile(fname:string);
begin
    if fchangedsettings.wswin=fname then exit;
 fchangedsettings.wswin:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSWDE1Splitter.GetwswinFile:string;
begin
  Result:=fchangedsettings.wswin;
end;

//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.SetRainPerCount(I:integer);stdcall;
begin
 if fChangedSettings.rainPerCount = I then
  exit;
 fChangedSettings.RainPerCount := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSWDE1Splitter.GetRainPerCount:integer;stdcall;
begin

   Result:=fchangedsettings.RainPerCount;
end;
}
//---Data Points
//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.SendText(Text: String); stdcall;
begin
//send to parent
if hasactiveparent then
(GetParent() as IIPSSerialPort).SendText(Text);
end;
//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.ReceiveText(Text: String); stdcall;
 var i,z:integer;
 l:integer;
  bt:char;
  f_complete:boolean;
  data:string;
  datum:string;
begin
 //entry point for data from parent
 f_complete := false;
 data:=text;
  l:=length(data);
  wde1_data.date:=now;
  //charactor filter, rewrite decimal point
   if l>0 then
   begin
      for z:=1 to l do
      begin
        bt:=data[z];
        case bt of
           '0'..'9',';','.','-':line:=line+bt;
           ',':line:=line+'.';
           #13:f_complete:=true;
        end;

        if (f_complete) then
        begin
            //line is complete, start parsing
            if parse() then
            begin
              //parsing was OK, start distributing
              sendData('DISTRIBUTE','Prepare');
              log;
              DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',wde1_data.date);
              for i := 0 to MAXSENSORS do
              begin
                with wde1_data.records[i] do
                begin
                  data:=Format('%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum]);
                  if i=8 then
                  data:=Format('%s;%s;%s;%s;%s;%s;;;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,wde1_data.wind,wde1_data.rain,wde1_data.israining,wde1_data.rainc]);
                  //include only sensors with data
                  if temp>'' then
                  begin
                    SendData('DISTRIBUTE','Sensor:'+id+' '+data);
                    SendWS300Data(strtoint(id),data);
                  end;
                end; //with
              end;//for
            end;//if parse
          //reset status
          line:='';
          f_complete := false;
        end;//if complete
      end;//for next character
   end;
end;
//------------------------------------------------------------------------------
procedure TIPSWDE1Splitter.SendWS300Data(DestDevice: Integer; Data: String); stdcall;
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
        sendData('SEND','Use existing ID:'+inttostr(id));
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

//Action
//------------------------------------------------------------------------------
function TIPSWDE1Splitter.update:boolean;stdcall;
begin
      //there is no function to force new data available with wde1
     Result:=true;
end;

//internal routines
//------------------------------------------------------------------------------
function TIPSWDE1Splitter.parse:boolean;
var p,f:integer;
  s:string;
  r:integer;
  m:double;

begin
    Result:=false;
    DecimalSeparator:='.';
    for f:=0 to maxsensors do
    //clear current values
   begin
      with wde1_data.records[f] do
      begin
        typ:='';
        id:='';
        sensor:='';
        temp:='';
        hum:='';
      end;
   end;
   wde1_data.wind:='';
   wde1_data.rain:='';
   wde1_data.rainc:='';
   wde1_data.israining:='';

    //startparsing by splitting into fields
    f:=0;
    p:=pos(';',line);
    SendData('PARSE',line);
    while p>0 do
      begin
        inc(f);
        s:=copy(line,1,p-1);
        SendData('PARSE','Field:'+inttostr(f)+':'+s);
        case f of
        4..11:begin
              wde1_data.records[f-4].temp:=s;
              wde1_data.records[f-4].id:=inttostr(f-4);
              wde1_data.records[f-4].typ:='T/F';
            end;
        12..19:wde1_data.records[f-12].hum:=s;
        20:begin
            wde1_data.records[8].temp:=s;
            wde1_data.records[8].id:='8';
            wde1_data.records[8].typ:='Kombi';
          end;
        21:wde1_data.records[8].hum:=s;
        22:wde1_data.wind:=s;
        23:begin
            wde1_data.rainc:=s;
            if s>'' then begin
              try
              r:=strtoint(s);
              m:=r*GetProperty('RainPerCount');
              if m<>0 then
                m:=m/1000;
              s:=format('%.1f',[m]);
              finally
                  s:=s;
              end;

            end;
            wde1_data.rain:=s;
        end;

        24:if s='1' then
          begin
          wde1_data.israining:='YES';
          end else begin
            wde1_data.israining:='NO';
          end;
        end;
        delete(line,1,p);
        p:=pos(';',line);

    end;//while
    if (f=24) then begin
      SendData('PARSE','OK');
      Result:=true;
      line:='';
    end
    else
    begin
      SendData('PARSE','Field Error:'+inttostr(f));
    end;

end;
//--------------------------------------------------------
procedure TIPSWDE1Splitter.log;
var o:Textfile;
    i:integer;
    datum:string;
    dt:TDateTime;
    fname:String;

function wv(v:string):string;
  begin
  if v='' then v:='0';
  wv:=v;
  end;

begin

  if wde1_data.date=0 then
    dt:=now
    else
    dt:=wde1_data.date;

  fname:=GetProperty('LogFile');
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
  for i := 0 to MAXSENSORS do
  begin
    with wde1_data.records[i] do
    begin
      if (temp>'') then
      begin
       writeln(o,datum,';',typ,';',id,';',sensor,';',temp,';',hum,';;;',wde1_data.wind,';',wde1_data.rain,';',wde1_data.israining);
       SendData('Log','Sensor:'+id);
      end;
    end;
  end;//for

  finally
      closefile(o);
  end;   //try
  end; //if

  fname:=GetProperty('WSWinFile');
  if fname<>'' then
  begin
  assignfile(o,fname);
  try
  if fileexists(fname) then
    append(o)
  else
  begin
      rewrite(o);
      writeln(o,',,2,18,3,19,4,20,5,21,6,22,7,23,8,24,9,25,10,26,1,17,33,134,35');
  end; //if

  //DateSeperator:='.';
  DateTimetostring(datum,'dd.mm.yyyy,hh:nn',dt);
  write(o,datum);
  for i := 0 to MAXSENSORS do
  begin
    write(o,',',wv(wde1_data.records[i].temp),',',wv(wde1_data.records[i].hum));
  end;   //for
  writeln(o,',',wv(wde1_data.press),',',wv(wde1_data.rain),',',wv(wde1_data.wind));
  finally
    closefile(o);
  end; //try
  end; //if
end;

end.
