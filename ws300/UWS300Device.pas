unit UWS300Device;
  //Thomas Dreßler (www.tdressler.net) 2009 - 2013
interface
uses
     SysUtils,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,UWS300interface;


type


 TIPSWS300Device = class(TIPSModuleObject,
                        IIPSModule,
                        IIPSWS300Device,
                        IIPSReceiveWS300)
  private

   //--- Custom Objects
   //--- Private Procedures/Functions
  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   //--- IIPSModule implementation
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   procedure ApplyChanges(); override;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
   //--- IIPSWS300Device implementation
   //--Get/Set
 //  procedure SetDeviceID(DeviceID: Integer); stdcall;
  // function GetDeviceID: Integer; stdcall;

   //Actions
   function update:boolean; stdcall;

   { Data Points }
   procedure ReceiveWS300Data(DestDevice: Integer; Data: String); stdcall;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetParentRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

   private
   procedure parse(Data:string);
   procedure SetStatusVariables;
 end;
implementation

//---Module Standard
//------------------------------------------------------------------------------
class function TIPSWS300Device.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSWS300Device); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetModuleType(): TIPSModuleType;
begin
 Result := mtDevice;
end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetModuleName(): String;
begin
 Result := 'WS300 Series Sensor';
end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendWS300);

end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveWS300);
end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSWS300Device.GetAliases(): TStringArray;
begin

 SetLength(Result, 6);
 Result[0] := 'WS300 Series Device';
 Result[1] := 'S300TH Sensor';
 Result[2] := 'AS2200H Sensor';
 Result[3] := 'PS50 PoolSensor';
 Result[4] := 'KS300 KombiSensor';
 Result[5] := 'WS300PC internal Sensor';

end;
 // Type implementation
//------------------------------------------------------------------------------
constructor TIPSWS300Device.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
var //i:integer;
    Associations : TIPSValueAssociations;
   {
   const willi :array [0..3] of array [0..1] of string=
      (('Sunny','Sun'),
      ('some Clouds','Cloud'),
      ('Cloudy','Cloud'),
      ('Rainy','Drops'));


    $forecast=array(0=>array('Heavy Snow','Snowflake'),
                1=>array('Little Snow','Snowflake'),
                2=>array('Heavy Rain','Rainfall'),
                3=>array('Little Rain','Drops'),
                4=>array('Cloudy','Cloud'),
                5=>array('some Clouds','Cloud'),
                6=>array('Sunny','Sun'));
}
begin


 inherited;

 //willi profile
 if not fKernel.ProfilePool.VariableProfileExists('WS300_Willi') then
 begin
      SetLength(Associations, 4);
      Associations[0] := ValueAssociation(0, 'Sunny','Sun', -1);
      Associations[1] := ValueAssociation(1, 'some Clouds','Cloud', -1);
      Associations[2] := ValueAssociation(2, 'Cloudy','Cloud', -1);
      Associations[3] := ValueAssociation(3, 'Rainy','Drops', -1);
      RegisterProfile(TIPSVarProfile.CreateIntegerProfileex('WS300_Willi', '','', '',Associations));
 end;




// register property
 RegisterProperty('DeviceID', -1);

 //register status variables
 RegisterVariable('TempVariable', 'Temperatur', vtFloat, 'Temperature');
 RegisterVariable('HumVariable', 'Humidity', vtInteger, 'Humidity');

 //only if ws300pc connected
 RegisterVariable('BatteryVariable', 'Battery', vtBoolean, 'Battery.Reversed');
 RegisterVariable('LostVariable', 'LostRecords', vtInteger);


//only for id8=KS300
 RegisterVariable('RainVariable', 'Rain', vtFloat, 'Rainfall');
 RegisterVariable('WindVariable', 'Wind Speed', vtFloat, 'WindSpeed.kmh');
 RegisterVariable('RainNowVariable', 'Raining', vtBoolean, 'Raining');
 RegisterVariable('RainCounterVariable', 'Rain Counter', vtInteger);


 //only for id9=ws300pc
 RegisterVariable('PressVariable', 'Pressure', vtInteger, 'AirPressure');
 RegisterVariable('WilliVariable', 'Willi', vtInteger,'WS300_Willi');




 //Check Parent
 RequireParent(IIPSSendWS300, true);


end;

//------------------------------------------------------------------------------
destructor  TIPSWS300Device.Destroy;
begin

 inherited;

end;
//------------------------------------------------------------------------------
procedure TIPSWS300Device.LoadSettings();

begin
inherited;  //first load propertys
 LogMessage(KL_DEBUG,'Load Settings');
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Device.SaveSettings();
begin
 inherited;
 LogMessage(KL_DEBUG,'SAVE Settings');
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Device.ResetChanges();
begin
 inherited;
 LogMessage(KL_DEBUG,'Reset Settings');
end;

//------------------------------------------------------------------------------
procedure TIPSWS300Device.ApplyChanges();
begin
 inherited;
 LogMessage(KL_DEBUG,'Apply Settings');
 if fKernelRunlevel = KR_READY then  SetStatusVariables; //Update Variables
end;
//------------------------------------------------------------------------------
procedure TIPSWS300Device.ProcessKernelRunlevelChange(Runlevel: Integer);
begin
 inherited;
 case Runlevel of
  KR_READY:setstatusVariables;
  end;
end;
{
//--Get/Set
//------------------------------------------------------------------------------
procedure TIPSWS300Device.SetDeviceID(DeviceID: Integer); stdcall;
var id:integer;
begin
 id:=DeviceID+1;
 if fChangedSettings.DeviceID = ID then
  exit;
 fChangedSettings.DeviceID := ID;

 SettingsChanged;
 LogMessage(KL_DEBUG,'Set Device ID:'+inttostr(id));

end;

//------------------------------------------------------------------------------
function TIPSWS300Device.GetDeviceID: Integer; stdcall;
var id:integer;
begin
 id:=fchangedSettings.DeviceID-1;
 Result := id;
end;
 }
//action
//------------------------------------------------------------------------------
function TIPSWS300Device.update:boolean; stdcall;
begin
//forward request to parent
 Result:=(GetParent() as IIPSSendWS300).update;
end;

//DataPoint
//------------------------------------------------------------------------------
procedure TIPSWS300Device.ReceiveWS300Data(DestDevice: Integer; Data: String); stdcall;
var device :integer;
begin

senddata('RECEIVED',data);
device:=GetProperty('DeviceID');
 if DestDevice <> device then
  begin
   SendData('Wrong DeviceID', inttostr(device)+'-->'+inttostr(DestDevice));
   exit;
  end;
 SendData('DeviceID', 'OK:'+inttostr(device));
 parse(data);
end;

//------------------------------------------------------------------------------
//---Status Variables
procedure TIPSWS300Device.SetStatusVariables;
var id:integer;
  ws300pc:boolean;
  parent:IIPSModule;
begin

  id:=GetProperty('DeviceID');
  parent:=NIL;

  if id<0 then exit;
  SendData('SetVars','Device '+inttostr(id));
  if fKernel.DataHandlerex.GetInstanceParentID(fInstanceID) > 0 then    parent:=getParent();
  if parent=NIL then ws300pc:=false else  ws300pc:=supports(parent,IIPSWS300splitter);
  LogMessage(KL_DEBUG,'SetVars Device '+inttostr(id));

  try

  //only for id9=ws300pc
 MaintainVariable((id=9),'PressVariable', 'Pressure', vtInteger, 'AirPressure');
 MaintainVariable((id=9),'WilliVariable', 'Willi Indicator', vtInteger,'WS300_Willi' );

//only for id8=KS300
 MaintainVariable((id=8),'RainVariable', 'Rain', vtFloat,'Rainfall');
 MainTainVariable((id=8),'WindVariable', 'Wind Speed', vtFloat, 'WindSpeed.kmh');
 MaintainVariable((id=8),'RainNowVariable', 'Raining', vtBoolean, 'Raining');
 MaintainVariable((id=8),'RainCounterVariable', 'Rain Counter', vtInteger, '');
 //only ws300pc
 MaintainVariable((ws300pc and (id<9)),'BatteryVariable', 'Battery', vtBoolean, 'Battery.Reversed');
 MaintainVariable((ws300pc and (id<9)),'LostVariable', 'LostRecords', vtInteger);
  except
  on e:exception do
  LogMessage(KL_DEBUG,'SetVars Exception: '+e.Message);

  end;

end;

//------------------------------------------------------------------------------
//- Implementation
procedure TIPSWS300Device.parse(Data:string);
var p,f:integer;
  line,s:string;
  iv:integer;
  fv:double;
  DestDevice:Integer;

begin
  Line:=data;
  senddata('PARSE',line);
  DestDevice:=GetProperty('DeviceID');

   //parse record
  DecimalSeparator:='.';
  try
 p:=pos(';',Line);
 f:=0;
    while p>0 do
      begin

        s:=copy(line,1,p-1);
        delete(line,1,p);
        SendData('PARSE','Field:'+inttostr(f)+'->'+s);
        if s>'' then
        begin
          case f of
          0: //Date
            sendData('PARSE','Date:'+s);
          1://typ
            sendData('PARSE','Typ:'+s);
          2://id
            sendData('PARSE','ID:'+s);
          3://sensorname
            sendData('PARSE','Name:'+s);
          4://temp
            begin
              fv:=strtofloat(s);
              fKernel.VariableManager.WriteVariableFloat(GetStatusVariableID('TempVariable'), fv);
              sendData('PARSE','Temperature:'+s);
            end;
          5://hum
            begin
              iv:=strtoint(s);
              fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('HumVariable'), iv);
              sendData('PARSE','Hum:'+s);
            end;
          6://battery
           if DestDevice<9 then
            begin
                p:=pos('LOW',s); //Battery
                if p>0 then
                begin

                  fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('BatteryVariable'),false);
                  sendData('PARSE','BatteryLow');
                end
                else
                begin
                  fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('BatteryVariable'), true);
                  sendData('PARSE','BatteryOK');
                end;
            end;

          7://lost
            if DestDevice<9 then
            begin
                  iv:=strtoint(s);
                  fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('LostVariable'), iv);
                  sendData('PARSE','SensorLost:'+s);


            end;
          8://wind
            if (DestDevice=8) then
            begin
              fv:=strtofloat(s);
              fKernel.VariableManager.WriteVariableFloat(GetStatusVariableID('WindVariable'), fv);
              sendData('PARSE','WindSpeed:'+s);
            end;
          9://rain
            if (DestDevice=8) then
            begin
              fv:=strtofloat(s);
              fKernel.VariableManager.WriteVariableFloat(GetStatusVariableID('RainVariable'), fv);
              sendData('PARSE','Rain:'+s);
            end;
          10://israining
            if (DestDevice=8) then
            begin
              p:=pos('YES',s); //is raining
              if p>0 then
              begin
                  //delete(s,1,p);
                  fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('RainNowVariable'), true);
                  sendData('PARSE','Its Raining');
              end
              else
              begin
                  fKernel.VariableManager.WriteVariableBoolean(GetStatusVariableID('RainNowVariable'), false);
                  sendData('PARSE','No Rain');
              end;
            end;
          11://raincounter
            if (DestDevice=8)  then begin
              iv:=strtoint(s);
              fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('RainCounterVariable'), iv);
              sendData('PARSE','RainCounter:'+s);
            end;
          12://pressure
            if (DestDevice=9) then
            begin
              iv:=strtoint(s);
              fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('PressVariable'), iv);
              sendData('PARSE','Pressure:'+s);
            end;
          13://willi
            if (DestDevice=9) then
            begin
              iv:=strtoint(s);
              fKernel.VariableManager.WriteVariableInteger(GetStatusVariableID('WilliVariable'), iv);
              sendData('PARSE','Willi:'+s);
            end;
          end; //case
       end;

      p:=pos(';',line);
      inc(f);
      end;
 except
    on e:Exception do
      begin
      SendData('PARSE','Error:'+e.message);
      exit;
      end;
 end;

end;



end.
