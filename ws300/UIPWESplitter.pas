unit UIPWESplitter;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2013
interface
uses
     Classes, StrUtils, SysUtils,ScktComp,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes,UWS300interface,RegExpr;

type
 TSettings = record
  Interval: Integer;
  Url:String;
  log:String;
   wswin:String;
  username:string;
  password:string;
  rainpercount:integer;
 end;

 TIPSIPWESplitter = class(TIPSModuleObject,
                          IIPSModule,
                          IIPSIPWESplitter,
                          IIPSSendWS300,
                          IIPSReceiveString)

  private


   //--- Custom Objects
       ipwe_data:Tws300dev_data;
//          errortxt:string;
//          errorflag:boolean;
          const MAXSENSORS=9;

   //--- Private Procedures/Functions
   private
   function CreateDevice(Device:integer):IInterface;
   function parse(Text:string):boolean;
   procedure log;
   procedure syncParent;
  protected
    procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;
    procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   //--- IIPSModule implementation
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   procedure ApplyChanges(); override;
   //--- IIPSIPWESplitter implementation
    //Public Get-Set
   {
   procedure SetInterval(Interval: integer); stdcall;
   function GetInterval: integer; stdcall;
   function GetUrl:string;stdcall;
   procedure SetURL(url:string); stdcall;
   function GetAuth:string;stdcall;
   procedure SetAuth(auth:string); stdcall;
   procedure SetRainPerCount(I: integer); stdcall;
   function GetRainPerCount: integer; stdcall;
   procedure SetLogFile(fname: string); stdcall;
   function GetLogFile: string; stdcall;
   procedure SetWSWINFile(fname: string); stdcall;
   function GetWSWINFile: string; stdcall;
   }
   //Actions
   function update:boolean; stdcall;

   { Data Points }
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
class function TIPSIPWESplitter.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSIPWESplitter); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetModuleName(): String;
begin
 Result := 'IPWE1';
end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetParentRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReadPage);

end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveWS300);

end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 3);
 Result[0] := GUIDToString(IIPSSendWS300);
 Result[1] := GUIDToString(IIPSSendString);
 Result[2] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSIPWESplitter.GetAliases(): TStringArray;
begin

 SetLength(Result, 1);
 Result[0] := 'IPWE1';

end;
//--Typ implementation
//------------------------------------------------------------------------------
constructor TIPSIPWESplitter.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 RegisterProperty('Interval', 300);
 RegisterProperty('URL', 'http://ipwe1/ipwe1.cgi');
 RegisterProperty('LogFile', '');
 RegisterProperty('WSWinFile', '');
 RegisterProperty('Username', '');
 RegisterProperty('Password', '');
 RegisterProperty('UseBasicAuth',false);
 RegisterProperty('RainPerCount', 295);
 RegisterProperty('AutoCreate', true);
 //Check Parent
 RequireParent(IIPSWWWReader, false);



end;

//------------------------------------------------------------------------------
destructor  TIPSIPWESplitter.Destroy;
begin

 //Save Settings
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.LoadSettings();
begin
 inherited;

end;



//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SaveSettings();
begin
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.ResetChanges();
var parent:IIPSModule;
    pUrl:String;
begin
 parent:=getParent;
  if Supports(parent, IIPSWWWReader) then
  begin
      purl:=parent.GetProperty('URL');
      SetProperty('URL',purl) ;
  end;
 inherited;  //savesettings is following...
end;

//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.ApplyChanges();
begin

 inherited;

end;
//--------------------------------------------------------
procedure TIPSIPWESplitter.ProcessKernelRunlevelChange(Runlevel: Integer);
begin
 inherited;
 case Runlevel of
  KR_READY:begin
            syncparent;
            if GetProperty('RainPerCount')=0 then   SetProperty('RainPerCount',295);
            if GetProperty('URL')='' then SetProperty('URL','http://ipwe1/ipwe.cgi');
            if GetProperty('Interval')=0 then setProperty('Interval',300);
          end;
  end; //case
end;
//--------------------------------------------------------
procedure TIPSIPWESplitter.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

  inherited;

end;
//parent settings
//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SyncParent();
var parent:IIPSModule;
    //Module: IIPSModule;
    pUrl,url:String;
    pInterval:integer;
    Interval:integer;
begin

  parent:=getParent;
  if Supports(parent, IIPSWWWReader) then
  begin
      //url
      purl:=parent.GetProperty('URL');
      if (purl='') or (ansicontainstext(purl,'google')) then
      begin
          url:='http://ipwe1/ipwe.cgi';
          SetProperty('URL',url);
          parent.SetProperty('URL',url);
       end;
       //authorization
       if (GetProperty('UseBasicAuth')=true) then
       begin
        parent.SetProperty('AuthUser',GetProperty('Username'));
        parent.SetProperty('AuthPass',GetProperty('Password'));
        parent.SetProperty('UseBasicAuth',true);
        end else begin
        parent.SetProperty('UseBasicAuth',false);
       end;
       //intervall
       pinterval:=parent.GetProperty('Interval');
       interval:=GetProperty('Interval');
       if Interval <> pInterval then
       begin
          parent.SetProperty('Interval',Interval);
       end;
       parent.ApplyChanges;
       savesettings;

  end;
end;

{
 //----Getter/Setter
 //------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SetAuth(auth:string);stdcall;
var p,l:integer;
    user,password:string;
begin
  user:='';
  password:='';
  l:=length(auth);
  p:=pos(':',auth);
  if p>1 then
  begin
    user:=copy(auth,1,p-1);
    if l>p then  password:=copy(auth,p+1,l-p);
  end;
  if fchangedsettings.username+':'+fchangedsettings.password<>auth then  settingschanged;
  if fchangedsettings.username<>user then fchangedsettings.username:=user;
  if fchangedsettings.password<>password then fchangedsettings.password:=password;
end;

//------------------------------------------------------------------------------
function TIPSIPWESplitter.GetAuth:string;stdcall;
var user,password:string;
    parent:IIPSWWWreader;

begin
   user:='';
   password:='';
   if hasactiveparent then
    begin
      parent:=(getParent() as IIPSWWWReader);
      user:=parent.GetAuthUsername;
      password:=parent.GetAuthPassword;
      setAuth(Result);
    end else begin
      user:=fchangedsettings.username;
      password:=fchangedsettings.password;
    end;
    if (user>'') and (password>'') then
        Result:=user+':'+password;


end;
 //------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SetUrl(url:string);stdcall;
begin
  if fchangedsettings.url=url then exit;
    fchangedsettings.url:=url;
    settingschanged;
end;

//------------------------------------------------------------------------------
function TIPSIPWESplitter.GetUrl:string;stdcall;
var url:string;

begin
   if hasactiveparent then
    url:=(GetParent() as IIPSWWWreader).GetPage
    else
    url:=fchangedsettings.Url;
  Result:=url;
end;
//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SetInterval(Interval:integer);stdcall;

begin
  if fchangedsettings.Interval=Interval then exit;
 fchangedsettings.Interval:=Interval;
 settingschanged;
end;



//------------------------------------------------------------------------------
function TIPSIPWESplitter.GetInterval:integer;stdcall;
var i:integer;
begin

    i:=fcurrentsettings.Interval;
  Result:=i;
end;
//--------------------------------------------------------
procedure TIPSIPWESplitter.SetLogFile(fname:string);
begin
    if fchangedsettings.log=fname then exit;
 fchangedsettings.log:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSIPWESplitter.GetLogFile:string;
begin
  Result:=fchangedsettings.log;
end;

//--------------------------------------------------------
procedure TIPSIPWESplitter.SetWswinFile(fname:string);
begin
    if fchangedsettings.wswin=fname then exit;
 fchangedsettings.wswin:=fname;
 settingschanged;
end;
//--------------------------------------------------------
function TIPSIPWESplitter.GetWswinFile:string;
begin
  Result:=fchangedsettings.wswin;
end;
//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SetRainPerCount(I:integer);stdcall;
begin
 if fChangedSettings.rainPerCount = I then
  exit;
 fChangedSettings.RainPerCount := I;
 SettingsChanged;

end;
//------------------------------------------------------------------------------
function TIPSIPWESplitter.GetRainPerCount:integer;stdcall;
begin

   Result:=fchangedsettings.RainPerCount;
end;
}
//---Actions
 //------------------------------------------------------------------------------
function TIPSIPWESplitter.update:boolean; stdcall;
begin
//forward update request to parent
if hasactiveparent then
(GetParent() as IIPSWWWreader).UpdatePage;
Result:=true;

end;

//DataPoint
//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.ReceiveText(Text: String); stdcall;
var i:integer;
  data:string;
  datum:string;

begin
 //data entry for data from parent ,frequenz is adjusted on parent
 senddata('RECEIVE',text);
 if parse(Text) then
 begin
  //parsing was OK, start distribute
  senddata('DISTRIBUTE','PREPARE');
  //log results
  log;
  //distribute
  DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',ipwe_data.date);
  for i := 0 to MAXSENSORS do
  begin
    with ipwe_data.records[i] do
    begin
     data:=Format('%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum]);
     if i=8 then
     data:=Format('%s;%s;%s;%s;%s;%s;;;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,ipwe_data.wind,ipwe_data.rain,ipwe_data.israining,ipwe_data.rainc]);
      //only sensors with typ field set
      if typ>'' then
      begin
          //DATA:Timestamp;Typ;ID;Sensor;temp;hum;wind;rain
          SendData('DISTRIBUTE','Sensor:'+id+' '+data);
          SendWS300Data(strtoint(id),data);
      end;

    end; //with
  end;//for
  end  //if parse
  else
  begin
  SendData('PARSE','ERROR');
  end;
end;

//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.SendWS300Data(DestDevice: Integer;Data: String); stdcall;

var Intfs: TInterfaceList;
    Intf: IInterface;
    found:boolean;
    id:Integer;
    freeinst:IIPSModule;
begin
//send data to childs
 found:=false;
 Intfs := GetChildren();
 try
  for Intf in Intfs do
   if Supports(Intf, IIPSReceiveWS300) then
   begin
   id:=(Intf as IIPSModule).GetProperty('DeviceID');
    if id=-1 then
            //id not sett, assume can use that one
            freeinst:=(intf as IIPSModule);
     //check if target and source id match
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
//--------------------------------------------------------
function TIPSIPWESplitter.CreateDevice(Device:integer):IInterface;
var  InstanceID: TInstanceID;
    ModuleID:TGUID;
    Instance: TIPSInstance;
    Intf:IInterface;
begin
     Result:=NIL;
     ModuleID:=IIPSWS300Device;
     if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then exit;
     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
     if device=8  then
      fKernel.ObjectManager.SetName(InstanceID, 'IPWE KombiSensor')
     else
      fKernel.ObjectManager.SetName(InstanceID, 'IPWE Sensor '+inttostr(Device));

     fKernel.DataHandler.ConnectInstance(InstanceID,fInstanceID);  //Parents are we!
     Instance := fKernel.InstanceManager.GetInstance(InstanceID);
      try
        intf := Instance.InstanceInterface;
        (intf as IIPSModule).SetProperty('DeviceID',Device);
        (intf as IIPSModule).SaveSettings;
        (intf as IIPSModule).ApplyChanges;
      finally
        //nothing
      end;
     Result := intf;
     if Result = nil then
        sendData('NEWInstance','Instance Interface is not assigned!')
        else
        sendData('NEWINSTANCE','ID:'+inttostr(InstanceID));
end;


//--internal Implementation
//------------------------------------------------------------------------------
function TIPSIPWESplitter.parse(Text:string):boolean;
var
  regex_tab,regex_row,regex_col,regex_m,regex_d,regex_blank,regex_sensor:TRegExpr;
  table,row,col:string;
  c,r,p,rc:integer;
  m:real;

const
//preg_match_table='<tbody>(?:(?!<tbody>).)*</tbody>';
preg_match_table='<tbody>(.*?)</tbody>';
    preg_match_st='Sensortyp';
    preg_match_row='<tr.*?>(.*?)</tr>';
    preg_match_col='<td.*?>(.*?)(<br>)*</td>';
    preg_match_empty='^\s*$';
   preg_match_digit='([-+#]?\s*\b[0-9]+(\.*[0-9]*))';
    preg_blank='&nbsp;';
    preg_sensor='<input[^>]*?name="des.".*?value="([^"]+?)">';


begin
   //initialization
   for r:=0 to maxsensors do //clear current values
   begin
      with ipwe_data.records[r] do
      begin
        typ:='';
        id:='';
        sensor:='';
        temp:='';
        hum:='';
      end;
   end;
   ipwe_data.wind:='';
   ipwe_data.rain:='';
   ipwe_data.israining:='';

  //data check
  Result:=false;
  ipwe_data.date:=now();
  if (length(text)=0 ) then
  begin
    SendData('PARSE','No Data from '+GetProperty('URL'));
    exit;
  end;


  try
    //create regular expression objects
    regex_tab:=TRegExpr.Create;
    regex_row:=TRegExpr.Create;
    regex_col:=TRegExpr.Create;
    regex_m:=TRegExpr.Create;
    regex_d:=TRegExpr.Create;
    regex_blank:=TRegExpr.Create;
    regex_sensor:=TRegexpr.Create;


    regex_blank.Expression:=preg_blank;
    regex_blank.Compile;
    Text:=regex_blank.Replace(Text,' ',true);

    regex_tab.Expression:=preg_match_table;
    //regex_tab.ModifierStr:='isg';//[preCaseLess,preSingleLine,preUngreedy	];
    regex_tab.Compile;
    regex_d.Expression:=preg_match_digit;
    regex_col.Expression:=preg_match_col;
    regex_sensor.Expression:=preg_sensor;
     regex_row.Expression:=preg_match_row;


    ipwe_data.date:=now();
    r:=0;
    rc:=GetProperty('RainPerCount');

    //start parsing with looking for <table> tags
    if regex_tab.Exec(text) then
    begin
    repeat

      table:=regex_tab.match[0];
      regex_m.Expression:=preg_match_st;

      //writeln(table);
      regex_m.ModifierStr:='is';//[preCaseLess,preSingleLine];

        //check matched input for right table, should have "Sensortyp" into
        if regex_m.Exec(table) then
        begin

          regex_row.ModifierStr:='is';//[preCaseLess,preSingleLine];
            //ok, we are in the right table, now match row content
            if regex_row.Exec(table) then
            repeat
            with ipwe_data.records[r] do begin
                row:=regex_row.Match[0];
                if regex_m.Exec(row) then continue;

                c:=0;

                regex_col.ModifierStr:='is';//[preCaseLess,preSingleLine];
                //vhech for Columns within Row tags
                if regex_col.Exec(row) then
                repeat
                    //found columns
                    inc(c);
                    //l:=regex_col.SubExprMatchCount;
                    col:=regex_col.Match[1];
                    regex_m.Expression:=preg_match_empty;
                    //go next if column empty
                    if (c=1) and regex_m.Exec(col) then break;
                    senddata('PARSE','R'+inttostr(r)+'C'+inttostr(c)+':'+col);

                    //now, assign the column value to the right record field
                    case c of
                      //Sensor typ
                      1:begin
                          typ:=col;
                      end;
                      //id
                      2:begin
                        if regex_d.Exec(col) then
                          id:=regex_d.Match[0];
                      end;
                      //sensor name
                      3:begin
                        //depending of page, sensors.cgi has input tags, ipwe.cgi not
                        if pos('<input',col)>0 then
                        begin
                             if regex_sensor.Exec(col) then
                                       col:=regex_sensor.Match[1]
                             else
                                       col:='';
                        end;
                        sensor:=col;
                        senddata('PARSE','Name:'+col);
                      end;
                      //temperature
                      4:begin
                        if regex_d.Exec(col) then begin
                          temp:=regex_d.Match[0];
                        end;
                      end;
                      //Humidity
                      5:begin
                        if regex_d.Exec(col) then begin
                          hum:=regex_d.Match[0];
                        end;
                      end;
                      //wind
                      6:begin

                        if regex_d.Exec(col) then begin
                          ipwe_data.wind:=regex_d.Match[0];
                        end;
                      end;
                      //regenmenge
                      7:begin
                        if regex_d.Exec(col) then begin
                          col:=regex_d.Match[0];
                          if typ='Kombi' then id:='8';
                          //rain
                          p:=pos('#',col); //is rainig prefix
                          if p>0 then
                          begin
                            delete(col,1,p);
                            ipwe_data.israining:='YES'
                          end else begin
                            ipwe_data.israining:='NO'
                          end;
                          ipwe_data.rain:=col;
                          ipwe_data.rainc:='';
                          if ipwe_data.rain>'' then begin
                            try
                              col:='';
                              DecimalSeparator:='.';
                              m:=strtofloat(ipwe_data.rain);
                              if rc<>0 then
                              begin
                                m:=m*1000/rc;
                                col:=format('%.0f',[m]);
                              end;
                            finally
                              col:=col;
                            end;
                            ipwe_data.rainc:=col;
                          end;
                        end;
                      end;
                    end;//case

                until not regex_col.ExecNext;
                end; //with
                inc(r);
            until not regex_row.ExecNext;

      end;

    until not regex_tab.ExecNext;
    end;
    senddata('PARSE','FINISH');
    except
      on e:Exception do
      begin

        senddata('PARSE','EXCEPTION:'+e.Message);
        exit;
      end;

    end;//try
  Result:=true;
end;

//------------------------------------------------------------------------------
procedure TIPSIPWESplitter.log;

var o:Textfile;
    i:integer;
    datum:string;
    dt:TDateTime;
    fname:string;
    data:string;

    function wv(v:string):string;
  begin
  if v='' then v:='0';
  wv:=v;
  end;

begin

  if ipwe_data.date=0 then
    dt:=now
  else
    dt:=ipwe_data.date;
  fname:=getProperty('LogFile');
  if fname>'' then
  begin
    assignfile(o,fname);
    try
    if fileexists(fname) then
      append(o)
    else
    begin
      rewrite(o);
      if (fname>'') then
            writeln(o,'Time',';','Typ',';','id',';','Name',';','Temp',';','Hum',';Bat;Lost;','Wind',';','Rain',';','isRaining',';','RainCounter',';');
    end;

  //DateSeperator:='-';
    DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',dt);
    for i := 0 to MAXSENSORS do
    begin
      with ipwe_data.records[i] do
      begin

        data:=Format('%s;%s;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum]);
        if i=8 then
          data:=Format('%s;%s;%s;%s;%s;%s;;;%s;%s;%s;%s;',[datum,typ,id,sensor,temp,hum,ipwe_data.wind,ipwe_data.rain,ipwe_data.israining,ipwe_data.rainc]);
        if (temp>'') then
          writeln(o,data);
      end; //with
    end; //for
    finally
     closefile(o);
    end;  //try

  end; //if

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
      if (fname>'') then
            writeln(o,',,2,18,3,19,4,20,5,21,6,22,7,23,8,24,9,25,10,26,1,17,33,134,35');
    end;

    //DateSeperator:='.';
    DateTimetostring(datum,'dd.mm.yyyy,hh:nn',dt);
    write(o,datum);
    for i := 0 to MAXSENSORS do
    begin
      write(o,',',wv(ipwe_data.records[i].temp),',',wv(ipwe_data.records[i].hum));
    end;
    writeln(o,',',wv(ipwe_data.press),',',wv(ipwe_data.rain),',',wv(ipwe_data.wind));
  finally
    closefile(o);
  end; //try
  end; //if

end; //proc


end.
