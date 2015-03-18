unit UEM1010Device;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2012
interface
uses  sysutils, classes,dateutils, strutils,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,
     UEM1010interface,uEM1010hlp;


type
 TIPSEM1010Device = class(TIPSModuleObject,
                        IIPSModule,
                        IIPSEM1010Device,
                        IIPSReceiveEM1010)
  private
   //--- Basic Structures
   last_record:string;
   //--- Custom Objects
   //--- Private Procedures/Functions
   procedure parse(Data:string);
   function hasparent:boolean;stdcall;
   //SDK2.3 compatibility functions
    function StatusVariableExists(ident:string):integer;
 protected
   //procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;

  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   //--- IIPSModule implementation
   procedure ApplyChanges(); override;
   //--- IIPSEM1010Device implementation
   procedure update; stdcall;
   function GetEC(): Integer; stdcall;
   //function getDevBlk(archivfile:string;Blk:integer=0):integer;stdcall;
   function getDevStatus:boolean;stdcall;
  function setPrice(euro:double):boolean; stdcall;
  //function setAlarm(value:integer):boolean; stdcall;
  function setRperKW(value:integer):boolean; stdcall;
  function GetLastRecord: string; stdcall;

  //--Get/Set
  function GetLastLine:string;stdcall;
  procedure setLastLine(line:string);stdcall;

//  procedure SetLastRecordNum(reads: Integer); stdcall;
//   function GetLastRecordNum: Integer; stdcall;
//   procedure SetLastDate(datum: String); stdcall;
//   function GetLastDate: string; stdcall;
//   procedure SetRecords(reads: Integer); stdcall;
//   function GetRecords: Integer; stdcall;
   function query(querydata:string):string;stdcall;

   //Actions
   //procedure SendText(Text: String); stdcall;
   procedure ReceiveEM1010Data(DestDevice: Integer; Data: String); stdcall;
   { Data Points }
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;




 end;
implementation


//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSEM1010Device); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetModuleName(): String;
begin
 Result := 'EM1010Dev';
end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendEM1010);

end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveEM1010);
end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSEM1010Device.GetAliases(): TStringArray;
begin

 SetLength(Result, 6);

 Result[0] := 'EM1000 WZ Energy Sensor';
 Result[1] := 'EM1000 IR/S Energy Sensor';
 Result[2] := 'EM1000 FM Energy Sensor';
 Result[3] := 'EM1000 GZ Gas Sensor';
 Result[4] := 'Conrad ES-1 Sensor';
 Result[5] := 'Conrad ES-2 Sensor';

end;

//------------------------------------------------------------------------------
constructor TIPSEM1010Device.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 inherited;
//Register Profile
if not fKernel.ProfilePool.VariableProfileExists('kwh.30') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('kwh.30', 'Lightning','', ' kwh/h', 0, 30, 1, 3));
if not fKernel.ProfilePool.VariableProfileExists('kw.30') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('kw.30', 'Lightning','', ' kwh', 0, 30, 1, 3));
if not fKernel.ProfilePool.VariableProfileExists('kw.10000') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('kw.10000', 'Lightning','', ' kwh', 0, 10000, 1, 3));
if not fKernel.ProfilePool.VariableProfileExists('Gas.10000') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('Gas.10000', 'Flame','', ' m≥', 0, 10000, 1, 1));
if not fKernel.ProfilePool.VariableProfileExists('Gas.30') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('Gas.30', 'Flame','', ' m≥', 0, 30, 1, 3));
if not fKernel.ProfilePool.VariableProfileExists('Gas_hour.30') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('Gas_hour.30', 'Flame','', ' m≥/h', 0, 30, 1, 3));
if not fKernel.ProfilePool.VariableProfileExists('Eur.10') then
  RegisterProfile(TIPSVarProfile.CreateFloatProfile('Eur.10', 'Euro','', ' Eur', 0, 10, 1, 3));
 //Register Variables

 RegisterVariable('Cur_EnergyVar', 'Act_Power_5min', vtFloat, 'kw.30');
 RegisterVariable('pulsesVar', 'Act_Pulses_5min', vtInteger);
 RegisterVariable('pulses_maxVar', 'Act_Pulses_max', vtInteger);
 RegisterVariable('pulses_totalVar', 'Pulses_total', vtInteger);
 RegisterVariable('Cur_PowerVar', 'Act_Power_hour', vtFloat,  'kwh.30');
 RegisterVariable('Cur_Power_MaxVar', 'Act_Power_Max', vtFloat,  'kwh.30');
 RegisterVariable('Sum_H_EnergyVar', 'Sum_1Hour_Energy', vtFloat,  'kw.10000');
 RegisterVariable('Sum_D_EnergyVar', 'Sum_Daily_Energy', vtFloat,  'kw.10000');
 RegisterVariable('Sum_W_EnergyVar', 'Sum_Weekly_Energy', vtFloat, 'kw.10000');
 RegisterVariable('Total_EnergyVar', 'Energy_Total', vtFloat, 'kw.10000');
// RegisterVariable('Alarm_PAVar', 'Alarm_PA', vtFloat);
RegisterVariable('EnergyConstVar', 'EnergyConst', vtInteger);
RegisterVariable('Price_cfVar', 'UnitPrice', vtfloat,'Eur.10');
//RegisterVariable('LastLineVar', 'LastDeviceInfo', vtString);
RegisterVariable('LastHistoryVar', 'LastHistoryRecord', vtString);
RegisterVariable('ReadingsVar', 'HistoryRecords', vtInteger);
//RegisterVariable('FirstPageVar', 'FirstPage', vtInteger);


// register status
RegisterProperty('DeviceID', 0);
//RegisterStrProperty('LastLine', GetLastLine, SetLastLine);
RegisterProperty('EnergyConst', 0);

{*
RegisterIntProperty('Records', GetRecords, SetRecords);
RegisterIntProperty('LastPage', GetLastRecordNum, SetLastRecordNum);
*}

 //Check Parent
 RequireParent(IIPSSendEM1010, true);

end;

//------------------------------------------------------------------------------
destructor  TIPSEM1010Device.Destroy;
begin

 inherited;

end;
//------------------------------------------------------------------------------
procedure TIPSEM1010Device.ApplyChanges();
begin

 inherited;

 try
  if (GetProperty('DeviceID')<5) then
  begin
      sendData('SetEC','use SetRPerKW to store in EM1010PC');
      if not setrperkw(GetProperty('EnergyConst'))then exit;
  end else
      sendData('SetEC','No WZ,do not store in EM1010PC');
 except
  //
 end;


  //handle gas sensors
 if GetProperty('DeviceID') < 9 then
  exit;

 MaintainVariable(true,'Cur_EnergyVar', 'Act_Gas_5min', vtFloat, 'Gas.30');
 MaintainVariable(true,'Cur_PowerVar', 'Act_Gas_hour', vtFloat, 'Gas_hour.30');
 MaintainVariable(true,'Cur_Power_MaxVar', 'Act_Gas_Max', vtFloat, 'Gas_hour.30');
 MaintainVariable(true,'Sum_H_EnergyVar', 'Sum_1hour_Gas', vtFloat, 'Gas.10000');
 MaintainVariable(true,'Sum_D_EnergyVar', 'Sum_Daily_Gas', vtFloat, 'Gas.10000');
 MaintainVariable(true,'Sum_W_EnergyVar', 'Sum_Weekly_Gas', vtFloat, 'Gas.10000');
 MaintainVariable(true,'Total_EnergyVar', 'Total_Gas', vtFloat, 'Gas.10000');





end;

//--------------------------------------------------------
procedure TIPSEM1010Device.ProcessKernelRunlevelChange(Runlevel: Integer);
begin

 inherited;

 case Runlevel of
  KR_READY:begin
      fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('EnergyConstVar'), GetProperty('EnergyConst'));
      Getec();
//    syncparent;
    end;//Ready
 end;//case
end;

 //--------------------------------------------------------


function TIPSEM1010Device.GetEC(): Integer;
var ec:integer;
    device:integer;

begin
    device:=GetProperty('DeviceID');
    ec := GetProperty('EnergyConst');
    if ec = 0 then
    begin
      //load defaults
      case device of
      1..4: begin
      // Sensor 1..4 WZ
          ec:=75; // ec = U/kWh
          end;
      5..8: begin
      // Sensor 5..8 EM
          ec := 1000;  // ec = puls/kWh
          end;
      9..12: begin
      // Sensor 9..12 Gas
          ec := 100;   // ec = puls/m≥
          end;
      end;
      if (ec>0) and (device>0) then
      begin
        SetProperty('EnergyConst',ec);
        ApplyChanges;
      end;
    end;

 Result := ec;
end;

{*
//------------------------------------------------------------------------------
procedure TIPSEM1010Device.SetRecords(reads: Integer); stdcall;
var id:integer;
begin

 if fChangedSettings.reads=reads then  exit;
 fChangedSettings.reads:=reads;
 if (statusvariableexists('HistoryRecordsVar')) then
  begin
    id:=GetStatusVariableID('HistoryRecordsVar');

    fKernel.VariableManager.WriteVariableInteger(id, reads);
 end;
 SettingsChanged;
 SendData('SetReads', 'Reads:'+inttostr(reads));

end;

//------------------------------------------------------------------------------
function TIPSEM1010Device.GetRecords: Integer; stdcall;

begin
 Result:=fchangedSettings.reads;
end;
//------------------------------------------------------------------------------
procedure TIPSEM1010Device.SetLastRecordNum(reads: Integer); stdcall;
var id:integer;
begin

 if fChangedSettings.lastRecord=reads then  exit;
 fChangedSettings.lastRecord:=reads;
  if (statusvariableexists('LastRecordVar')) then
  begin
    id:=GetStatusVariableID('LastRecordVar');
    fKernel.VariableManager.WriteVariableInteger(id, reads);
 end;
 SettingsChanged;
 SendData('SetLastRecord', 'Reads:'+inttostr(reads));

end;
//------------------------------------------------------------------------------
function TIPSEM1010Device.GetLastRecordNum: Integer; stdcall;

begin
 Result:=fchangedSettings.lastRecord;
end;
//------------------------------------------------------------------------------
procedure TIPSEM1010Device.SetLastDate(datum: string); stdcall;
var id:integer;
begin

 if fChangedSettings.lastDate = datum then  exit;
 fChangedSettings.lastDate:=datum;
  if (statusvariableexists('LastHistoryVar')) then
  begin
    id:=GetStatusVariableID('LastHistoryVar');
    fKernel.VariableManager.WriteVariableString(id, datum);
 end;
 SettingsChanged;
 SendData('SetLastDate', 'Last:'+datum);

end;

*}
//------------------------------------------------------------------------------
procedure TIPSEM1010Device.SetLastLine(line: string); stdcall;
//var id:integer;
begin

 if last_record = line then  exit;
 last_record:=line;
 {*
 try
  if (statusvariableexists('LastLineVar')) then
  begin
    id:=GetStatusVariableID('LastLineVar');
    fKernel.VariableManager.WriteVariableString(id, line);
  end;
 except
 on e:exception do
            senddata('SetLine','Error:'+e.Message);
 end;
 *}
 SendData('SetLastLine', line);

end;
//------------------------------------------------------------------------------
function TIPSEM1010Device.GetLastLine: string; stdcall;
begin
 Result:=last_record;
end;

//------------------------------------------------------------------------------
procedure TIPSEM1010Device.ReceiveEM1010Data(DestDevice: Integer; Data: String); stdcall;
begin

senddata('RECEIVED',data);

 if DestDevice <> GetProperty('DeviceID') then
  begin
   SendData('Wrong DeviceID', inttostr(GetProperty('DeviceID'))+'-->'+inttostr(DestDevice));
   exit;
  end;
 SendData('PARSE', 'DeviceID OK:'+inttostr(GetProperty('DeviceID')));
 SetLastLine(data);
 parse(data);
end;
//--------------------------------------------------------
procedure TIPSEM1010Device.parse(Data:string);
type var_rec=record
    var_id:integer;
    var_ips:TIPSVariable;
    var_val:string;
    end;

var p,p2,f,id:integer;
  s,fn:string;
  datum:string;
  iv:integer;
  fv:double;
  tm:TDateTime;
  nreadings:integer;
  //r:boolean;
  svar:TIPSVariable;
  tvar:TIPSVarType;
  stats:array[0..maxfields] of var_rec;
  pd:integer;

begin
    //parse record
  senddata('PARSE',data);
  DecimalSeparator:='.';

 p:=1;//start
 f:=-1;
    while (p>0) and (f<maxfields) do
    begin
        p:=pos(';',data);
        inc(f);
        s:=copy(data,1,p-1);
        delete(data,1,p);
        stats[f].var_val:='';
        stats[f].var_id:=0;
        fn:=em1010rec_fields[f];
        SendData('PARSE',fn+'('+inttostr(f)+')->'+s);
        fn:=fn+'Var';
        id:= statusvariableexists(fn);
        if id<1  then
                  continue; //not relevant
        stats[f].var_id:=id;
        svar:=fkernel.VariableManager.GetVariable(id);
        stats[f].var_ips:=svar;
        stats[f].var_val:=s;
        if fn='pulses_totalVar' then
        begin

          p2:=fkernel.VariableManager.ReadVariableInteger(id);
          try
          iv:=strtoint(s);
          finally

          end;
          pd:=iv-p2; //pulses_total field
          senddata('PARSE',format('Pulse check id=%d: %d - %d = %d',[id,iv,p2,pd]));
          if (pd<0) or (pd>300) then
          begin
            logmessage(KL_MESSAGE,'received Record dropped, pulse difference invalid:'+inttostr(pd));
            senddata('PARSE','received Record dropped, pulse difference invalid:'+inttostr(pd));
            fKernel.VariableManager.WriteVariableInteger(id, iv); //align pulses_total storage for next check
            exit; //leave procedure, ignore record
          end;
          end;
      end;  //while
      senddata('PARSE','Step1 finished');

    f:=-1;
    while (f<maxfields+1) do
    begin
        inc(f);
        with stats[f] do
        begin
        if var_id=0 then continue; //value not relevant
        s:=var_val;

        //convert strings
        try
        if (s>'') and (f>0)  then
        begin
        id:=var_id;
        tvar:=stats[f].var_ips.VariableValue.ValueType;
          case tvar of
            vtstring:
            begin
                fKernel.VariableManager.WriteVariableString(id, s);
                //em1010rec_value[f]:=s;
            end;
            vtfloat:
            begin
              p2:=pos('.',s);
              if (p2=0) then s:=s+'.0';
              fv:=strtofloat(s);
              em1010rec_value[f]:=fv;
              fKernel.VariableManager.WriteVariableFloat(id, fv);
            end;
            vtinteger:
            begin
              iv:=strtoint(s);
              em1010rec_value[f]:=iv;
              fKernel.VariableManager.WriteVariableInteger(id, iv);
              if (fn='EneryConst') then
               begin
                if GetProperty('EnergyConst') <> iv then
                 begin
                  SetProperty('EnergyConst', iv);
                  ApplyChanges;
                 end;
               end;
           end; //typ
        end;
        end; //s/f

        except
        on e:exception do
            senddata('Parse','Error:'+e.Message);
        end; //try
        end;//with
      end;//while
      senddata('PARSE','Step2 finished');
      id:=statusvariableexists('ReadingsVar');
      if (id>0) then
      begin
        nreadings:=fKernel.VariableManager.ReadVariableInteger(id) ;
        tm := IncSecond(now(),-((nreadings-1)*300));
        DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',tm);
        id:=statusvariableexists('LastHistoryVar');
        if (id>0) then
        begin
          fKernel.VariableManager.WriteVariableString(id, datum);
        end;

      end;
      senddata('PARSE','Finished');
end;

//------------------------------------------------------------------------------
procedure TIPSEM1010Device.update; stdcall;
begin
 getDevStatus;
end;
//------------------------------------------------------------------------------
function  TIPSEM1010Device.hasparent:boolean;stdcall;
begin
 //Result:=(fKernel.DataHandler.GetInstanceParentID(fInstanceID))>0;
 Result:=(fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID))>0;
end;

//------------------------------------------------------------------------------
function TIPSEM1010Device.query(querydata:string):string; stdcall;
begin
  senddata('Query','entered');
  result:='';
  if hasparent then
    Result:=(GetParent() as IIPSSendEM1010).query(querydata)
  else
    SendData('Query','NoParent');

  SendData('Query','leaved:'+Result);

end;

//------------------------------------------------------------------------------
function TIPSEM1010Device.getDevStatus:boolean; stdcall;
begin
senddata('Status','entered');
result:=false;
if hasparent then
 Result:=(GetParent() as IIPSSendEM1010).getDevStatus(GetProperty('DeviceID'))
 else
  begin
    SendData('Status','NoParent');
    exit;
  end;
 if result then
 SendData('Status','Success')
 else
 SendData('Status','Failed');
end;
{*
//------------------------------------------------------------------------------
function TIPSEM1010Device.getDevBlk(archivfile:string;blk:integer=0):integer;stdcall;
begin
senddata('Data','entered, file='+archivfile+' Blk='+inttostr(blk));
result:=-1;
if hasparent then
    result:=(GetParent() as IIPSSendEM1010).getDevBlk(getDeviceID,archivfile,blk)
else
    SendData('Data','NoParent');
if result>-1 then
 SendData('Data','Success')
 else
 SendData('Data','Failed');
end;
*}
//------------------------------------------------------------------------------
 function TIPSEM1010Device.setPrice(euro:double):boolean; stdcall;
 var id:integer;
  begin
  SendData('Price','entered, value:'+format('%0.3f',[euro]));
  result:=false;
  if not hasparent then
  begin
    SendData('Price','NoParent');
    exit;
  end;
      result:=(GetParent() as IIPSSendEM1010).setPrice(GetProperty('DeviceID'),euro);
 if not result then
 begin
  SendData('Price','Failed');
  exit;
 end;
 id:=statusvariableexists('Price_cfVar');
  if (id>0) and result then
  begin
          fKernel.VariableManager.WriteVariablefloat(id, euro);
  end;
 SendData('Price','Success');

  end;
//------------------------------------------------------------------------------
  {*
  function TIPSEM1010Device.setAlarm(value:integer):boolean; stdcall;
  begin
  SendData('RPerKW','entered, value:'+inttostr(value));
result:=false;
if hasparent then
    result:=(GetParent() as IIPSSendEM1010).setAlarm(getDeviceID,value)
    else
    SendData('Alarm','NoParent');
if result then
 SendData('Alarm','Success')
 else
 SendData('Alarm','Failed');
  end;
  *}
//------------------------------------------------------------------------------
  function TIPSEM1010Device.setRperKW(value:integer):boolean; stdcall;
  var id:Integer;
  begin
  SendData('RPerKW','entered, value:'+inttostr(value));
  result:=false;
  if not hasparent then
  begin
    SendData('RPerKW','No Parent');
    exit;
  end;
  id:=GetProperty('DeviceID');
  if (id>4) and (id<1) then
  begin
       SendData('RperKW','Failed, only Device 1..4 allowed');
       exit;
  end;
  result:=(GetParent() as IIPSSendEM1010).setRPerKW(GetProperty('DeviceID'),value);
  if result then
  begin
    SendData('RPerKW','Success');
    id:=statusvariableexists('EnergyConstVar');
    if id>0 then
            fKernel.VariableManager.WriteVariableInteger(id, value);
  end  else
        SendData('RperKW','Failed');
  end; //function
 //------------------------------------------------------------------------------
  function TIPSEM1010Device.getlastRecord:string; stdcall;
  var s:string;
  begin
  //SendData('GetLast Record','entered');
  s:=getLastLine;
  SendData('GetLast Record',s);
  Result:=s;
  end;
//------------------------------------------------------------------------------
 function TIPSEM1010Device.StatusVariableExists(ident:string):integer;
 begin
    //senddata('StatusVarExists','entered');
    //result:=0;
    try
      result:=fKernel.ObjectManager.GetObjectIDByIdent(ident,fInstanceID);
    except
      on e:exception do
      begin
        senddata('StatusVarExists',e.Message);
        result:=-1;
        //exit;
      end;
    end;
    //Objectid is varable id
    //result:=GetStatusVariableID(ident);
 end;

end.

