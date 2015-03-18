unit UEM1010;
//Thomas Dreßler (www.tdressler.net) 2009 - 2013
 {
 huge part of this code is based on em1010.pl, found in fhem distribution
 (http://www.koeniglich.de/fhem/fhem.html)
 all rights are accepted
 }
interface

uses SysUtils, classes,
     strutils,UUtils, dateutils,
     UIPSTypes, UIPSModuleTypes, UIPSDataTypes, superobject,
     UEM1010Interface,uEM1010hlp;


type
 TIPSEM1010 = class(TIPSModuleObject,
                     IIPSModule,
                     //IIPSReceiveString,
                     //IIPSSendString,
                     IIPSSendEM1010,
                     IIPSEM1010
                     )

  private

   //--- Basic Structures
   timeout:extended;
   fTimeout,faction, fquery:boolean;

   fcomplete,fstart,fende,fesc  :boolean;
   errortxt:string;
   allstats:array[1..12] of em1010_stat;


   //--- Custom Objects
   //--- Private Procedures/Functions
   private
   function CreateDevice(Device:integer):IInterface;
   function FindChild(id:integer):IInterface;
   function GetEC(Device:integer):integer;
   //procedure distribute;

   procedure TimeOutEvent;
   procedure UpdateEvent;
  //function getData(data:string):string;
   //function FindChild(id:integer):IInterface;
  function em_read:string;
  procedure log;



  protected
   //procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);override;
   //procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
  public

   //--- IIPSModule implementation
   constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;
   procedure ApplyChanges(); override;
   function GetConfigurationForm(): String; override;

   //--- IIPSSendEM1010 implementation
   procedure SendEM1010Data(DestDevice: Integer; Data: String); stdcall;
   function query(querydata:string):string;stdcall;
   function getDevStatus(DestDevice:integer):boolean; stdcall;
  //function getDevBlk(DestDevice:integer;archivfile:string;Blk:integer=0):integer;stdcall;
  function setPrice(DestDevice:integer;euro:double):boolean;stdcall;
  //function setAlarm(DestDevice,value:integer):boolean;stdcall;
  function setRPerKW(DestDevice,value:integer):boolean;stdcall;


//--- IIPSEM1010 implementation
  function getVersion():String; stdcall;
  function getTime():String; stdcall;
  procedure update; stdcall;

  function get62():string;stdcall;
  function setTime(z:string):boolean; stdcall;
  procedure reset();stdcall;
  //function getDevPage(page:word;len:word=264):string;stdcall;
   { Data Points }
 //   procedure SendText(Text: String); stdcall;
   //procedure ReceiveText(Text: String); stdcall;
   { Class Functions }
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   //class function GetParentRequirements(): TStrGUIDs; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetChildRequirements(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

 end;
implementation
  const MAXSENSORS=12;

//------------------------------------------------------------------------------
class function TIPSEM1010.GetModuleID(): TStrGUID;
begin
 Result := GUIDToString(IIPSEM1010); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSEM1010.GetModuleType(): TIPSModuleType;
begin
 Result := mtSplitter;
end;

//------------------------------------------------------------------------------
class function TIPSEM1010.GetModuleName(): String;
begin
 Result := 'EM1010PC';
end;

//------------------------------------------------------------------------------
//class function TIPSEM1010.GetParentRequirements(): TStrGUIDs;
//begin

// SetLength(Result, 1);
// Result[0] := GUIDToString(IIPSSendString);

//end;
//------------------------------------------------------------------------------
class function TIPSEM1010.GetChildRequirements(): TStrGUIDs;
begin

 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveEM1010);

end;
//------------------------------------------------------------------------------
class function TIPSEM1010.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendEM1010);
 //Result[1] := GUIDToString(IIPSEM1010);
 //Result[2] := GUIDToString(IIPSReceiveString);
end;
//------------------------------------------------------------------------------
class function TIPSEM1010.GetVendor(): String;
begin
 Result := 'ELV';
end;

//------------------------------------------------------------------------------
class function TIPSEM1010.GetAliases(): TStringArray;
begin

 SetLength(Result, 2);
 Result[0] := 'EM1010PC USB';
 Result[1] := 'Conrad Energy Control 3000 USB';

end;

//------------------------------------------------------------------------------
constructor TIPSEM1010.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);
begin

 inherited;

 //Register Variables

 timeout := 2.0;
 RegisterTimer('EM1010PC_Update', 0, UpdateEvent);
 RegisterTimer('EM1010PC_Timeout', 0, TimeoutEvent);

 // register status
 RegisterProperty('Port', 'COM3');
 RegisterProperty('Interval', 300);
 RegisterProperty('LogFile', '');
 RegisterProperty('AutoCreate', true);

//Check Parent
 //RequireParent(IIPSSendString, true);

 faction:=true;//enable all
end;

//------------------------------------------------------------------------------
destructor  TIPSEM1010.Destroy;
begin

 //Save Settings
 faction:=false;
 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSEM1010.ApplyChanges();
 begin

    inherited;
    //syncParent;
    SetTimerInterval('EM1010PC_Update', GetProperty('Interval'));
end;



//------------------------------------------------------------------------------
function TIPSEM1010.GetConfigurationForm(): String;
var Form, Port: ISuperObject;
    Devices: TStringList;
    i: Integer;
begin


 Form := SO(inherited GetConfigurationForm());


 Devices := TStringlist.Create;
 try
  EnumerateDosDevices(Devices);
  for i := 0 to Devices.Count - 1 do
   if SameText(LeftStr(Devices[i], 3), 'COM') and (Devices[i][4] in ['0'..'9']) then
    begin
     Port := SO();
     Port.S['label'] := Devices[i];
     Port.S['value'] := Devices[i];
     Form.O['elements'].AsArray[1].O['options'].AsArray.Add(Port);
    end;


 finally
  Devices.Free;
 end;

 Result := Form.AsJSon();

end;
//---Actions
 //------------------------------------------------------------------------------
procedure TIPSEM1010.update; stdcall;

var i:integer;
begin

  SendData('Update','entered');
  if not faction then begin
    SendData('Update','Wait for history');
    exit;
  end;

  for i := 1 to maxsensors do
  begin
    sendData('Update','Device '+inttostr(i));
    getDevstatus(i);
    em1010_data.records[i]:=allstats[i];
  end;
  em1010_data.date:=now;
  log;
end;
//------------------------------------------------------------------------------
procedure TIPSEM1010.log;
var o:Textfile;
    i:integer;
    z:string;
    dt:TDateTime;
    fname:string;

begin
  fname:= GetProperty('LogFile');
  if fname='' then exit;
  if em1010_data.date=0 then
    dt:=now
    else
    dt:=em1010_data.date;
  assignfile(o,fname);
  if fileexists(fname) then
    append(o)
  else
  begin
      rewrite(o);
      for i := 0 to maxfields do write(o,em1010rec_fields[i],';');
      writeln(o);
  end;

  //DateSeperator:='-';
  DateTimetostring(z,'yyyy-mm-dd hh:nn:ss',dt);
  for i := 1 to 9 do
  begin

      if (em1010_data.records[i].readings>0) then
      begin
         writeln(o,z,';',statusstring(em1010_data.records[i]));
      end;
  end;
  closefile(o);
end;
 {
////------------------------------------------------------------------------------
//procedure TIPSEM1010.SendText(Text: String); stdcall;
//var parent:IIPSModule;
//begin
//if hasactiveparent then
//begin
//  SendData('ToEM1010',Text);
//  (GetParent() as IIPSSendString).SendText(Text);
//
//end else    SendData('ToFTDI','No Parent');
//
//end;
//
//------------------------------------------------------------------------------
//procedure TIPSEM1010.ReceiveText(Text: String); stdcall;
//
//var i,l,z:integer;
//    c:char;
//
//begin
//
//
// senddata('RECEIVED',text);
// l := length(text);
// for i:=1 to l do
// begin
//    c:=text[i];
//    if not fstart then
//    begin
//      if c=#2 then
//      begin
//        fstart:=true;
//        line:=c;
//        continue;
//      end;
//      continue;
//    end;
//
//    if not fende then
//    begin
//      if fesc then
//      begin
//         line:=line+c;
//         fesc:=false;
//         continue;
//      end;
//      if c=#10 then
//      begin
//        fesc:=true;
//        continue;
//      end;
//
//      line:=line+c;
//      if c=#3 then
//      begin
//        fende:=true;
//        if( l < 8) then exit;
//        z:=b(line,1);
//        if z <> 0 then exit;
//        z:=w(line,2);
//        if(z <> l-7) then exit;
//        fcomplete:=true;
//        exit;
//      end;
//    end;
//
//
// end;//for
////
//end;
 //  #########################
//function TIPSEM1010.getDevPage(page:word;len:word=264):string;
//var d:string;
//
//begin
//  SendData('GetDevPage','entered, Page:'+inttostr(page));
//  d:='';
//  if not faction then begin
//    SendData('GetDevPage','Wait for history');
//    exit;
//  end;
//  if (len<1) or (len>264) then len := 264;
//  d:=chr($52)+chr(page mod 256)+chr( page div 256)+chr(0)+chr(0)+chr(len mod 256)+chr(len div 256);
//  d:=query(d);
//
////  d := getData(format('52%02x%02x0000%02x%02x',
////                [page mod 256, int(page div 256), len mod 256, len div 256]));
//
//   if d='' then
//   begin
//    SendData('getDevPage','no data');
//    exit;
//   end;
//    SendData('getDevPage','Success:'+hexdump(d));
//  Result:=d;
//end;
//------------------------------------------------------------------------------
}
function  TIPSEM1010.FindChild(id:integer):IInterface;
var Intfs: TInterfaceList;
    Intf: IInterface;
    foundinst:IInterface;
begin

foundinst:=NIL;
  Intfs := GetChildren();
  try
  for Intf in Intfs do
   if Supports(Intf, IIPSReceiveEM1010) then
   begin
     if (Intf as IIPSModule).GetProperty('DeviceID') =id then
      begin
        foundinst:=Intf;
        break;
      end;
   end;
 finally
  Intfs.Free;
 end;
 Result:=foundinst;
end;

//------------------------------------------------------------------------------
procedure TIPSEM1010.SendEM1010Data(DestDevice: Integer;Data:string); stdcall;
var
    myinst:IInterface;
begin

  sendData('SENDDATA','Entered');
  myinst:=FindChild(DestDevice);
  if assigned(myinst) then
  begin
        sendData('SENDDATA','Use existing ID:'+inttostr(DestDevice));
  end
  else
  begin
    myinst:= FindChild(-1); //empty Instance?
    if assigned(myinst) then
       begin
        sendData('SENDDATA','USE FREE Instance');
         (myinst as IIPSModule).SetProperty('DeviceID', DestDevice);
         (myinst as IIPSModule).ApplyChanges;
       end
    else
    begin
        if (GetProperty('AutoCreate')= true) then
        begin
          //new instance needed
          sendData('SENDDATA','CREATE NEW Device');
          myinst:=createDevice(DestDevice);
        end
        else
        begin
          sendData('SENDDATA','Creating Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
          LogMessage(KL_MESSAGE,'Creating Device ID '+inttostr(DestDevice)+ ' disabled by Property AutoCreate');
        end;
    end;
  end;
  if assigned(myinst) then
  begin
    sendData('SENDDATA','Distribute');
     (myinst as IIPSReceiveEM1010).ReceiveEM1010Data(DestDevice,Data);
  end;

end;

//------------------------------------------------------------------------------


function TIPSEM1010.CreateDevice(Device:integer):IInterface;
var //Compatibles: TInstanceIDs;
    InstanceID: TInstanceID;
    //Module: TIPSModuleClass;
    ModuleID:TGUID;
    Instance: TIPSInstance;
    Intf:IInterface;
begin
  Result:=NIL;
  sendData('NewDevice','entered');
       ModuleID:=IIPSEM1010Device;
       if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
      exit;
     //Module := fKernel.ModuleLoaderEx.GetModuleClass(GUIDToString(ModuleID));
     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
     fKernel.ObjectManager.SetName(InstanceID, 'Energy Sensor '+inttostr(Device));
     fKernel.DataHandler.ConnectInstance(InstanceID,fInstanceID);  //Parents are we!
     Instance := fKernel.InstanceManager.GetInstance(InstanceID);
      try
        intf := Instance.InstanceInterface;
        (intf as IIPSModule).SetProperty('DeviceID', Device);
        (intf as IIPSModule).ApplyChanges;
          sendData('NewDevice','created');
      except
        sendData('NewDevice','failed creating Device for Sensor '+inttostr(Device));

      end;
     Result := intf;
     if Result = nil then
        sendData('NEWDevice','Instance Interface is not assigned!')
        else
        sendData('NEWDevice','ID:'+inttostr(InstanceID));
end;

 //--------------------------------------------------------
function TIPSEM1010.getDevStatus(DestDevice:integer):boolean; stdcall;
var d,r,line:string;
  id:integer;

begin
  id:=DestDevice;
  SendData('GetStatus','entered,ID:'+inttostr(id));
  Result:= false;
  if (id <1) or (id > 12) then
  begin
    errortxt:='wrong devicenumber (1-12):'+inttostr(id) ;
    SendData('DevStatus',errortxt);
    exit;
  end;
  {
  Sending: 02001002007a00aae103
  }
  d := query(chr($7A)+chr(id-1));
  if d='' then exit;
  SendData('getDevStatus',hexdump(d));
  r:=dupestring(#0,45) + dupestring(chr($FF),  6);
  if d =r  then
  begin
    errortxt:=Format('     No device no. %2d present',[id]);
    SendData('getDEvStatus',errortxt);
    exit;
  end;
  if dw(d,2)=0  then
  begin
    errortxt:=Format('     No data fo Device( %2d ) present',[id]);
    SendData('getDEvStatus',errortxt);
    exit;
  end;

  with allstats[id] do
  begin
    device:=id;
    cur_energy:=0;
    cur_power:=0;
    cur_power_max:=0;
    sum_h_energy:=0;
    sum_d_energy:=0;
    sum_w_energy:=0;
    total_energy:=0;
    pulses_total:=0;
    iec:=0;

   {01020304050607080910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758
    0200330000000000000000000000000000000000000000832400000000000000000000000000000000000000000000000000000000000089E003
    000000000000000000000000000000000000008324000000000000000000000000000000000000000000000000000000000000
    8A0052050000024549000020731200140080121229062932240000102916258012A7000000880F0000454900000000DC050000
    5D015305000002534900002E731100130080121329072933240000102916258012A7000000880F0000534900000000DC050000
    21005D05000002E1490000BC731100130080121D2911293D240000192916258012AB0000008A0F0000E14900000000DC050000

ID:5->18;20;0;1362;2;31;0.00;0.18;0.20;0.00;3.00;18.00;18.00;0.15;0;1000
ID:5->17;19;0;1363;2;31;0.00;0.17;0.19;0.00;3.00;18.00;18.00;0.15;0;1000
}
    {2,0,33,0,d4,1,3c,10,3,0,0,1,4a,10,10,0,0,84,4,5,0,72,10,2,80,be,bc,ca,b0,ca,9c,c
6,0,0,b0,ca,a4,ca,a4,ca,36,0,0,0,c,7,0,0,4a,10,10,0,0,0,0,dc,5,dc,5,5a,b8,3,
RAW    0200 3300 d401 3c03 0000 014a 1000 0084
RAW    0405 0072 0280 bebc cab0 ca9c c600 00b0
RAW    caa4 caa4 ca36 0000 000c 0700 004a 1000
RAW    0000 00dc 05dc 055a b803
     Readings       (off  2): 828
     Nr devs        (off  6): 1
     puls/5min      (off 13): 5
     puls.max/5min  (off 15): 626
     cur.energy(off   ): 0.033 kWh
     cur.power      (      ): 0.400 kW
     cur.power max  (      ): 0.000 kW
     energy h       (off 33): 0.360 kWh (h)
     energy d       (off 37): 12.027 kWh (d)
     energy w       (off 41): 27.800 kWh (w)
     total energy   (off  7): 27.800 kWh (total)
     Alarm PA       (off 45): 0 W
     Price CF       (off 47): 0.15 EUR/kWh
     R/kW  EC       (off 49): 150
RAW    d401 3c03 0000 014a 1000 0084 0405 0072
RAW    0280 bebc cab0 ca9c c600 00b0 caa4 caa4
RAW    ca36 0000 000c 0700 004a 1000 0000 00dc
RAW    05dc 05}

readings:=w(d,2);
    devs:=b(d,6);
    startblk:=b(d,18)+13;
    pulses:=w(d,13);
    pulses_max:=w(d,15);
    pulses_total:=dw(d, 7);
    ec:=w(d,49) div 10;
senddata('Parse','Readings:'+inttostr( w(d,2)));
senddata('Parse','devs:'+inttostr( b(d,6)));
senddata('Parse','Startblk:'+inttostr( b(d,18)));
senddata('Parse','Puls5min:'+inttostr( w(d,13)));
senddata('Parse','Puls_max:'+inttostr( w(d,15)));
senddata('Parse','EC_read:'+inttostr( w(d,49)));
senddata('Parse','Pulse-H:'+inttostr( dw(d,33)));
  senddata('Parse','Pulse-D:'+inttostr( dw(d,37)));
  senddata('Parse','Pulse-W:'+inttostr( dw(d,41)));
  senddata('Parse','Pulse-T:'+inttostr( dw(d,7)));

outlog         ('----------------------------------------');
outlog(Format  ('     Date                 : %s',   [line]));
outlog(Format  ('     Device                 : %d',   [id]));
  outlog(Format('     Readings       (off  2): %d',   [readings]));
  outlog(Format('     Nr devs        (off  6): %d',   [devs]));
  outlog(Format('     puls/5min      (off 13): %d',   [pulses]));
  outlog(Format('     puls.max/5min  (off 15): %d',   [pulses_max]));
  outlog(Format('     Startblk  (off 18): %d',   [startblk]));

//  lauf:=19;
//  while lauf<45 do
//  begin
//    outlog(Format('     t wert    (off %d): %d',   [lauf,w(d,lauf)]));
//    lauf:=lauf+2;
//  end;

  // The data must interpreted depending on the sensor type.


  case id of
  1..4: begin
  // Sensor 1..4 WZ
      if ec=0 then ec:=getEC(id);
      if ec=0 then ec:=75; // ec = U/kWh
    end;
  5..8: begin
  // Sensor 5..8 EM
      if ec=0 then ec:=getEC(id);
      if ec=0  then ec := 1000;  // ec = puls/kWh
    end;
  9..12: begin
  // Sensor 9..12 Gas
      if ec=0 then ec:=getEC(id);
      if ec=0  then ec := 100;   // ec = puls/m³
    end;
  end;
  iec := ec;
    //senddata('Parse','Pulses:'+hexdump(copy(d,38,4))+':'+hexdump(copy(d,42,4))+hexdump(copy(d,8,4)));
  sum_h_energy:=  dw(d,33)/ iec; // 33= pulses this hour
  sum_d_energy:= dw(d,37) / iec; // 37= pulses today
  sum_w_energy:= dw(d,41) / iec; // 41= pulses this week
  alarm_pa:=w(d,45); //45 Alarm
  price_cf:=w(d,47)/10000;

  total_energy:= pulses_total / iec; //  7= pulses total
  cur_energy := pulses / ec;   //kwh 5min
  cur_power  := pulses / ec *12; //kwh scaled to 1h
  cur_power_max  := pulses_max / ec*12;  //max kwh scaled to 1h

  outlog(Format('     cur.energy     (      ): %0.3f kW(m³)/5min', [cur_energy]));
  outlog(Format('     cur.power      (      ): %0.3f kW(m³)/h', [cur_power]));
  outlog(Format('     cur.power max  (      ): %0.3f kW(m³)/5min', [cur_power_max]));
  outlog(Format('     energy h       (off 33): %0.3f kWh(m³) (h)', [sum_h_energy]));
  outlog(Format('     energy d       (off 37): %0.3f kWh(m³) (d)', [sum_d_energy]));
  outlog(Format('     energy w       (off 41): %0.3f kWh(m³) (w)', [sum_w_energy]));
  outlog(Format('     total energy   (off  7): %0.3f kWh(m³) (total)', [total_energy]));
  outlog(Format('     Alarm PA       (off 45): %d W', [alarm_pa]));
  outlog(Format('     Price CF       (off 47): %0.2f EUR/kWh',   [price_cf]));
  outlog(Format('     R/kW  EC       (off 49): %d',   [ec]));

  end; //with
  DateTimetostring(line,'yyyy-mm-dd hh:nn:ss',now());
  line:=line+';'+statusstring(allstats[id]);
  SendData('getDEvStatus','ID:'+inttostr(id)+'->'+line);
  SendEM1010data(id,line);
  SendData('getDEvStatus','leaved');
  result:=true;
end;

{*
//#########################
function TIPSEM1010.getDevBlk(DestDevice:integer;archivfile:string;blk:integer=0):integer;stdcall;

var
  //smooth:boolean;
  id,step:integer;
   divread,backlog:integer;
  off,f1,f2,f3:integer;
  v:double;
  d,datum:string;
page,max:word;
   tm:TDateTime;
  res,flog:boolean;
  af:Textfile;
  child:IIPSReceiveEM1010;
  status:em1010_stat;
  startblk,pages,reads,nrreadings:integer;


begin
  SendData('GetDevData','entered,Blk:'+inttostr(blk));
  id:=DestDevice;

  //smooth := false; // Set this to 0 to get the "real" values
  //Result:= -2;
  flog:=false;
  if (id <1) or (id > 12) then
  begin
    errortxt:='wrong devicenumber (1-12):'+inttostr(id) ;
    SendData('DevData',errortxt);
    Result:= -3;
    exit;
  end;
  status:=allstats[id];
  if (status.readings = 0) or (blk=0 )then
  begin
    res:=getDevStatus(id);
    if not res then
    begin
      SendData('getDevData','prelimary GetDevStatus failed');
      Result:= -4;
      exit;
    end;
    status:=allstats[id];
  end;
  if(status.readings = 0) then
    begin
      SendData('GetDevData','No data to read (yet?)');
      Result:= -5;
      exit;
    end;
    //DateSeperator:='-';

  faction:=false;
  nrreadings := status.readings;
  pages:=(nrreadings-1)div 64;
  step := status.devs;
  startblk :=  status.startblk;
  if blk=0  then    blk:=startblk;
  if blk>65535 then
  begin
      SendData('GetDevData','Block to high:'+inttostr(blk));
      Result:= -6;
      exit;
    end;


  try
      if archivfile>'' then
      begin
          flog:=true;
          DecimalSeparator:='.';
          assignfile(af,archivfile);
          if fileexists(archivfile) then
            append(af)
          else
          begin
            rewrite(af);
            writeln(af,'Device',';','Date',';','Value',';');
          end;
      end;
   except
      on exception do
      begin
        flog:=false;
      end;
   end;

   reads:=0;
   page:=0;
   child:=(FindChild(id) as IIPSReceiveEM1010);
    if not (child=NIL) then
    begin
       reads:=child.GetRecords;
       page:=child.GetLastRecord;
    end;


    //endread := startread + ((nrreadings-1)div 64)*step;
  divread := status.ec;
  if (divread = 0) then divread := 1;

  backlog := 0;
  outlog('--GetData ID:'+inttostr(id)+'------------------------');
  outlog(Format('Total %4d,Start %4d - End %4d ,Step: %4d,Div:%4d',[nrreadings,page,pages,step,divread]));
  SendData('GetDevData',Format('Total %4d,Start %4d - End %4d ,Step: %4d,Div:%4d',[nrreadings,page,pages,step,divread]));
  tm := IncSecond(now(),-((nrreadings-1)*300));
 //  for(my $p = $start; $p <= $end; $p += $step)

  //while p<= endread do

  SendData('GetDevData',Format('Get Blk %d (%d)',[blk,page]));
    //writeln(Format('Get page %d',[p]));
    //$d = getData(sprintf("52%02x%02x00000801", $p%256, int($p/256)));
    d:=chr($52)+chr(blk mod 256)+chr(blk div 256)+#0#0#8#1;
    d:=query(d);
    //d := getData(Format('52%02x%02x00000801', [p mod 256, p div 256]));

  if d>'' then
  begin //idata
    if page = pages then  max := ((nrreadings mod 64)*4)+4 else  max:=260;
    SendData('GetPage',hexdump(d));
    SendData('GetPage','Head:'+hexdump(copy(d,1,8))+',Max:'+inttostr(Max));

    step := b(d, 6); //adjust step
    off:=8;
    while off<= max do
    //for(my $off = 8; $off <= $max; $off += 4)
    begin  //w2
     backlog:=backlog+1;
     senddata('GetPage','O:'+inttostr(off)+',Bl:'+inttostr(backlog)+' Data:'+hexdump(copy(d,off,4)));
      if (w(d,off+2) = $ffff) then
       // "smoothing"
        continue
      else
      begin  //i1b
        try
        inc(reads);
        DateTimetostring(datum,'yyyy-mm-dd hh:nn:ss',tm);
	      v := w(d,off)*12; //5minvalue
        v :=v / divread;
        v :=v / backlog;
	      f1 := b(d,off+2);
	      f2 := b(d,off+3);
	      f3 := w(d,off+2);
        while(backlog>0) do
        begin  //w3
          backlog:=backlog-1;
          if backlog >0 then
          begin  //i2
            f1:=-1;
            f2:=-1;
            f3:=-1;
          end;  //i2
         tm :=incsecond(tm,300);
         outlog(Format('%s %6.3f kWh (%d %d %d) Read %d / %d', [datum, v,
		          f1, f2, f3,reads,nrreadings]));
         senddata('GetPage',Format('Datum:%s Value:%6.3f kWh (%d %d %d) Read %d / %d', [datum, v,
		          f1, f2, f3,reads,nrreadings]));
         if flog then
           writeln(af,Format('%d;%s;%6.3f;',[id,datum,v]));
        end; //w3
        except
          on e:exception do
            SendData('GetPage','Error:'+e.Message);
        end;
      off := off+4;
	    backlog := 0;
      end; //i1b
    end; //w2

    if flog then closefile(af);


      inc(page);
      if not (child=NIL) then
      begin
        child.SetLastRecord(page);
        child.SetLastDate(datum);
        child.SetRecords(reads);
      end;

      if (page=pages) then
      begin
        Result:=0;
        SendData('GetDevData','finished sucessfully');
      end else begin
        Result:=blk+step; //more data
        SendData('GetDevData','more data waiting');
      end;

    end else
    begin  //idata
      SendData('getPage','no data');
      Result:= -7;
    end;  //idata
    faction:=true;
end;
*}
//####################
function TIPSEM1010.setPrice(DestDevice:integer;euro:double):boolean; stdcall;
var d:string;
  id,value:integer;
begin
  id:=DestDevice;
  Result:=false;
  SendData('SetPrice',Format('ID: %d = %0.3f Euro',[id,euro]));
  if not faction then begin
    SendData('SetPrice','Wait for history');
    exit;
  end;
  //euro in 0.01 eurocent
  value:=round(euro*10000);
  if (id <1) or (id > 12) then
  begin
    errortxt:='wrong devicenumber (1-12):'+inttostr(id) ;
    SendData('SetPrice',errortxt);
    exit;
  end;
  d:=chr($79)+chr(id-1)+chr($2f)+chr(2)+chr(value mod 256)+chr(value div 256);
  d:=query(d);
  //d := getData(Format('79%02x2f02%02x%02x', [id-1, value mod 256, value div 256]));
  if(b(d,0) = 6) then
  begin
      Result:=true;
      sendData('SetPrice','OK');
  end
  else
  begin
      sendData('SetPrice','Error');
      //outlog(hexdump(d));
  end;
end;

//####################
{*
function TIPSEM1010.setAlarm(Destdevice,value:integer):boolean; stdcall;
//id Geräteid
//value in kwh
var d:string;
  id:integer;
begin
  id:=DestDevice;
  SendData('SetAlarm','ID:'+inttostr(id)+' Value:'+inttostr(value)+' entered');
  Result:=false;
  if not faction then begin
    SendData('SetAlarm','Wait for history');
    exit;
  end;

  if (id <1) or (id > 12) then
  begin
    errortxt:='wrong devicenumber (1-12):'+inttostr(id) ;
    SendData('SetAlarm',errortxt);
    exit;
  end;
  d:=chr($79)+chr(id-1)+chr($2d)+chr(2)+chr(value mod 256)+chr(value div 256);
  d:=query(d);
  //d := getData(Format('79%02x2d02%02x%02x', [id-1, value mod 256, value div 256]));
  if(b(d,0) = 6) then
  begin
      Result:=true;
      SendData('SetAlarm','OK');
  end
  else
  begin

      SendData('SetAlarm','Error');
      //outlog(hexdump(d));
  end;
end;
 *}
//#######################
 function TIPSEM1010.setRperKW(DestDevice,value:integer):boolean; stdcall;
//id Geräteid
//value rotation per kw
var d:string;
  id:integer;
  v:integer;
begin
   Result:=false;
   id:=Destdevice;
   SendData('SetRPerKW','ID:'+inttostr(id)+' Value:'+inttostr(value)+' entered');
   if not faction then begin
    SendData('SetRperKW','Wait for history');
    exit;
  end;

   if (id <1) or (id >4) then
  begin
    errortxt:='wrong devicenumber (1..4):'+inttostr(id) ;
    SendData('SetRPerKW',errortxt);
    exit;
  end;
  v:=value*10;  //adjust display and parameter
  d:=chr($79)+chr(id-1)+chr($31)+chr(2)+chr(v mod 256)+chr(v div 256);
  d:=query(d);
  //d := getData(Format('79%02x3102%02x%02x', [id-1, value mod 256, value div 256]));
  if(b(d,0) = 6) then
  begin
      Result:=true;
      SendData('SetRperKW','OK');
  end
  else
  begin

      SendData('Set RperKW','Error');
      outlog(hexdump(d));
  end;
end;

//#########################
function TIPSEM1010.query(querydata:string):string;
var outdata,data,portname:string;
    i,l,z,port:integer;
begin

  SendData('Query','entered');
  Result:='';
  outdata := makemsg(querydata);
//  parent:=getParent;
//  if parent=nil then
//  begin
//    SendData('Query','No parent to send');
//    exit;
//  end;
  if fquery then
  begin
        SendData('Query','Query already active');
    exit;
  end;
  //openport(parent, true);
  try

  errortxt:='';
  port:=0;
  portname:=GetProperty('Port');

  //check port
  if length(portname)<4 then
  begin
    errortxt:='Portname "'+portname+'" to short';
    senddata('Query',errortxt);
    exit;
  end
  else
  begin
    if leftstr(portname,3)='COM' then
    begin
      try
        port:=strtoint(midstr(portname,4,2));
      except
        on E: exception do
          port:=0;
        end; //try
    end;
    if port=0 then
    begin
        errortxt:='Portname "'+portname+'" wrong';
        senddata('Query',errortxt);
        exit;
    end;
  end;

  if not (openport(port))then
  begin
   sleep(500);
   errortxt:='Cannot open port '+inttostr(port);
   senddata('Query',errortxt);
   exit;
  end;

  //fKernel.TimerPoolEx.SetInterval(fTimerUpdate, 0);

  fquery:=true;
  data:='';
  fcomplete:=false;
  fstart:=false;
  fende:=false;
  fesc:=false;
  ftimeout:=false;
  sendData( 'Send', hexdump(outdata));
  writedata(outdata);
  SetTimerInterval('EM1010PC_Timeout', timeout);

  z:=0;

    while z<20 do
    begin //w1
      if ftimeout then break;
      sleep(10);
      inc(z);
      SendData('Query',Format( 'Read (try nr %d)',[z]));
      data:=data+em_read;
      if fcomplete then break;
    end; //w2 while z

  //end;
  finally
 // fKernel.TimerPoolEx.SetInterval(fTimerUpdate, fcurrentsettings.Interval);
  SetTimerInterval('EM1010PC_Timeout', 0);
  fquery:=false;
   closeport;
  end;

  if not fcomplete then exit;
  l:=length(data);
  if( l < 8) then
  begin //2
          errortxt:=errortxt+' '+'Msg too short';
  end; //2
  i:=b(data,1);
  if i <> 0 then
  begin //2
          errortxt:=errortxt+' '+'Bad second byte';

  end; //2
  i:=w(data,2);
  if(i <> l-7) then
  begin //2
            errortxt:=errortxt+' '+'Length mismatch';

  end; //2
  if(not checkcrc(data,l-7)) then
  begin //2
    errortxt:=errortxt+' '+'Bad CRC';

  end;  //2

  l:=length(data);
  SendData('Query',Format( 'Got %d bytes',[l]));

    if errortxt='' then
  begin
        SendData('Query','Record OK');
        Result:=copy(data, 5, l-7);
  end else begin
    SendData('Query',errortxt);
  end;

end;

//#########################
function TIPSEM1010.getVersion():String;stdcall;
var d,r:string;
begin
{          0

Sending: 0200010076d35903
         0200010076D35903
2,0,10,2,0,1,5,b1,7b,3,
02 0002 00 0105 b17b 03
1.5
}
Result:='';
SendData('GetVersion','entered');
if not faction then begin
    SendData('GetVersion','Wait for history');
    exit;
  end;
  d := query(chr($76));

  if d='' then
  begin

    SendData('GetVersion','NoData');
    exit;
  end;
  SendData('getVersion',hexdump(d));
  r:=Format('%d.%d',[ b(d,0), b(d,1)]);
  Result:=r;
  sendData('GetVersion',Result);
end;

//#########################
function TIPSEM1010.getTime():String;stdcall;
var d,r:string;
begin
{Sending: 0200010074dcd903
2,0,6,0,15,c,1d,d,5,10,3,de,ca,3,
RAW    0200 0600 150c 1d0d 0503 deca 03
2009-05-13 21:12:29
}
Result:='';
SendData('GetTime','entered');
  if not faction then begin
    SendData('GetTime','Wait for history');
    exit;
  end;
  d := query(chr($74));
  if d='' then
  begin

    SendData('GetTime','NoData');
    exit;
  end;
  {02000600151B161E050387DD03}

  SendData('getTime',hexdump(d));
  r:=Format('%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d',
          [b(d,5)+2006, b(d,4), b(d,3),
          b(d,0), b(d,1), b(d,2)]);
  Result:=r;
  sendData('GetTime',Result);
end;
//function inttohex(i:integer):string;
//var d:string;
//begin
//  d:=format('%x',[i]);
//  if odd(length(d)) then d:='0'+d;
//  Result:=d;
//end;
//#########################


//###################
procedure TIPSEM1010.reset(); stdcall;
var d:string;
begin

  sendData('Reset','entered');
  if not faction then begin
    SendData('Reset','Wait for history');
    exit;
  end;

  d := query(chr($45)+chr($45));
  //outlog (hexdump(d));
  sendData('Reset',hexdump(d));
end;

//##################
function TIPSEM1010.get62():string;
var d:string;
begin

SendData('Get62','entered');
if not faction then begin
    SendData('Get62','Wait for history');
    exit;
  end;

  d := query(chr($62));
  Result:=hexdump(d);
  SendData('Get62',Result);
end;

//#######################
function TIPSEM1010.setTime(z:string):boolean;
var d,s:string;
    dt:TDateTime;
    dtformat:TFormatSettings;
    tag,monat,jahr,stunde,minute,sekunde,msec:word;

begin
Result:=false;
  SendData('SetTime','entered');
  if not faction then begin
    SendData('SetTime','Wait for history');
    exit;
  end;

  getlocaleformatsettings(49,dtformat);
  if length(z)>0 then
  begin

    try
    dt:=strtodatetime(z,dtformat);
    except
      on EConvertError do begin
        SendData('SetTime','Convert Error, take now');
        dt:=now();
      end;
    end;
  end
  else
  begin
    SendData('SetTime','No Input, take now');
    dt:=now();
  end;
    DecodeDateTime(dt,jahr,monat,tag,stunde,minute,sekunde,msec);
    s:=chr($73)+chr(tag)+chr(monat)+chr(jahr-2000+$d0)+chr(0)+chr(stunde)+chr(minute)+chr(sekunde);
//    s := Format('73%02x%02x%02x00%02x%02x%02x',
//        [tag,monat,jahr-2000+$d0,
//        stunde,minute,sekunde]);
    sendData('setTime',hexdump(s));

    d := query(s);
    if d='' then exit;
    if(b(d,0) = 6) then
    begin
      Result:=true;
      sendData('SetTime','OK');
    end
    else
    begin
      Result:=true;
      SendData('SetTime','Error');
      //outlog(hexdump(d));
    end;

end;

//#######################
procedure TIPSEM1010.UpdateEvent;
begin
  SendData('UpdateEvent','happends');
  update;
  //distribute;
end;

//#######################
procedure TIPSEM1010.TimeOutEvent;
begin
  errortxt:='Timeout reading the answer';
  fTimeout:=true;
  SetTimerInterval('EM1010PC_Timeout',0);
  //fKernel.TimerPoolEx.SetIntervalex(fTimerUpdate, 0);
  sendData('TimeOut',errortxt);
end;

//#######################

 function TIPSEM1010.em_read:string;
var

  bt:integer;
  f_esc,f_started:boolean;
  I: Integer;
  line:string;
begin
    SendData('READ','entered');
      f_esc := false;
    f_started := false;
    fcomplete := false;
    line:='';

      while not (fcomplete or ftimeout) do
      begin

        for I := 0 to 3 do
        begin
          bt:=getbyte();
          if bt>-1 then break;
        end;
        if bt=-1 then
        begin

            line:='';
            break;
        end;

        //outlog(Format('Byte %2d',[bt]));
        if((not f_started) and (bt <> $02)) then continue;
        f_started := true;
        if(f_esc) then
        begin //1
         line :=line+ chr(bt);
         f_esc := false;
         continue;
        end; //1
        if(bt = $10) then
        begin //1
          f_esc := true;
          continue;
        end; //1
        line :=line+chr(bt);
        if( bt = $03) then
        begin //1
          fcomplete := true;
          break;
        end; //1
      end;
      //writeln(dl,'ReadBuffer:'+hexdump(data));
      Senddata('READ','Complete:'+hexdump(line));
      Result:=line;

end;
//------------------------------------------------------------------------------
function  TIPSEM1010.getEC(Device:integer):integer;
var
    myinst:IInterface;
begin
  result:=0;
  myinst:=FindChild(Device);
  if assigned(myinst) then
  begin
       result:=(myinst as IIPSReceiveEM1010).GetEC();
  end;
  Senddata('getEC','Result:'+inttostr(result));
end;
 {
//#######################
procedure TIPSEM1010.em_write(data:string);
var bt:byte;
  l,len:integer;
begin

      len:=length(data);
      sendData('Write ',hexdump(data));
//      for l:= 1 to  len do
//      begin
//        bt:=ord(data[l]);
//       sendbyte(bt);
//       //sleep(10);
//      end;
    writedata(data);

end;
}


   //#########################
//procedure TIPSEM1010.openport(parent:IIPSModule;open:boolean);
//var ftdi:IIPSFTDI;
//    serial:IIPSSerialport;
//begin
////  if supports(parent,IIPSFTDI,ftdi) then
////    begin
////    if ftdi.GetOpen then ftdi.SetOpen(false);
////    if open then ftdi.SetOpen(true);
////    end;
////  if supports(parent,IIPSSerialPort,serial) then
////    begin
////    if serial.GetOpen then serial.SetOpen(false);
////    if open then serial.SetOpen(true);
////    end;
////    parent.ApplyChanges;
//
//end;

end.

