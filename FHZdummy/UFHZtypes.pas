unit UFHZtypes;
 //Thomas Dreﬂler (www.tdressler.net) 2010-13
interface
uses uthreadstringlist,classes,sysutils,math;
const
FHZProtocol:Array[0..5] of String[15]=('pFS20', 'pFHT', 'pHMS', 'pKS300',
                                          'pFHTResponse', 'pDateTime');
FHZDevice:Array[0..13] of String[15]=('FS20', 'FHT', 'HMSTempFeucht', 'HMSTemp', 'HMSWasser',
                                      'HMS100RM','HMS100TFK', 'SwitchIN',
                                      'GasSensor1', 'GasSensor2', 'COSensor',
                                      'KS300', 'FIT', 'ALW');
FHZQueueStatus:Array[0..3] of String[15]=(
                    'Queued',  //Item is queued and Waiting
                    'Waiting', //Items was send to FHZ, Awaiting response
                    'Ok',      //Command was successfully send
                    'Timeout'  //Command response timed out
                    );
//------------------------------------------------------------------------------
//string handling
function data2hex(s : string):string; //mit leerzeichen nach jedem Byte
function string2hex(s : string):string; //ohne leerzeichen
function btohex(b : byte):string;  //byte als hex
function bin2four(v:string):string;  //bytes als ELV four code
function four2bin(v:string):string;  //ELV Four Code als bytes
function  bcd2string(s : string):string; //bcd as string
//initialization
procedure codes_initialize; stdcall;
procedure ExitProc; stdcall;
//------------------------------------------------------------------------------
var
     fs20_codes,
      FHT_codes
      {
      fht_warnings,
      fht_priority,
      fht_tfk_codes,
      fht_c2m}
      :TThreadStringList;
      fs20_times: array[0..255] of string;


//----------###############
implementation

procedure codes_initialize;stdcall;
var
  I,j: integer;
  t,f: double;
  b: byte;
  text: string;
begin
fs20_codes:=TThreadStringList.Create;
with fs20_codes do
begin
          values['00']:='Dim Level 0 0% (off)';
  				values['01']:='Dim Level 1 6%';
  				values['02']:='Dim Level 2 12%';
  				values['03']:='Dim Level 3 18%';
  				values['04']:='Dim Level 4 25%';
  				values['05']:='Dim Level 5 31%';
  				values['06']:='Dim Level 6 37%';
  				values['07']:='Dim Level 7 43%';
  				values['08']:='Dim Level 8 50%';
  				values['09']:='Dim Level 9 56%';
  				values['0A']:='Dim Level 10 62%';
  				values['0B']:='Dim Level 11 68%';
  				values['0C']:='Dim Level 12 75%';
  				values['0D']:='Dim Level 13 81%';
  				values['0E']:='Dim Level 14 87%';
  				values['0F']:='Dim Level 15 93%';
          values['10']:='Dim Level 16 100% (On)';
  				values['11']:='On to last Dim Level';
  				values['12']:='toggle';
  				values['13']:='dimup';
  				values['14']:='dimdown';
  				values['15']:='dimupdown';
  				values['16']:='timer';
  				values['17']:='sendstate';
  				values['18']:='off-for-timer';
  				values['19']:='on-for-timer';
  				values['1A']:='on-old-for-timer';
  				values['1B']:='reset';
  				values['1C']:='ramp-on-time';
  				values['1D']:='ramp-off-time';
  				values['1E']:='on-old-for-timer-prev';
  				values['1F']:='on-100-for-timer-prev';
          values['20']:='Timer to Dim Level 0 0% (off)';
  				values['21']:='Timer to Dim Level 1 6%';
  				values['22']:='Timer to Dim Level 2 12%';
  				values['23']:='Timer to Dim Level 3 18%';
  				values['24']:='Timer to Dim Level 4 25%';
  				values['25']:='Timer to Dim Level 5 31%';
  				values['26']:='Timer to Dim Level 6 37%';
  				values['27']:='Timer to Dim Level 7 43%';
  				values['28']:='Timer to Dim Level 8 50%';
  				values['29']:='Timer to Dim Level 9 56%';
  				values['2A']:='Timer to Dim Level 10 62%';
  				values['2B']:='Timer to Dim Level 11 68%';
  				values['2C']:='Timer to Dim Level 12 75%';
  				values['2D']:='Timer to Dim Level 13 81%';
  				values['2E']:='Timer to Dim Level 14 87%';
  				values['2F']:='Timer to Dim Level 15 93%';
          values['30']:='Timer to Dim Level 16 100% (On)';
          values['31']:='Timer to last Dim Level';
          values['32']:='On to last Level, then Timer to off';
          values['33']:='Dimup, then Timer to off';
          values['34']:='Dimdown, then Timer to off';
          values['35']:='DimUpdown, then Timer to off';
          values['36']:='Set Timer';
          values['37']:='illegal';
          values['38']:='Out for Timer, then On to last';
          values['39']:='On(100%) for Timer, then Off';
          values['3A']:='On(last) for Timer, then Off';
          values['3B']:='illegal';
          values['3C']:='Set Ramp Up time';
          values['3D']:='Set Ramp Down time';
          values['3E']:='On(100%) for Timer, then before';
          values['3F']:='On(last) for Timer, then before';

  end;

  //fs20_times
  for I := 0 to 15 do
  begin
    f:=(power(2,i)*0.25);
    for j := 0 to 15 do
    begin
      b:=i*16+j;
      if j=0 then
        text:='immediate/permanent'
      else
      begin
      if i<13 then
      begin
        t:=f*j;
        text:=format('%0.2f s',[t]);
      end
      else
      begin
      // 0Dx-0Fx==0Cx
        text:=fs20_times[($C0+j)];
      end;
      end;
      fs20_times[b]:=text;
    end;
  end;


  fht_codes:=TThreadStringList.Create;
  with FHT_codes do begin

  				values['00']:='actuator';
  				values['01']:='actuator1';
  				values['02']:='actuator2';
  				values['03']:='actuator3';
  				values['04']:='actuator4';
  				values['05']:='actuator5';
  				values['06']:='actuator6';
  				values['07']:='actuator7';
  				values['08']:='actuator8';

  				values['14']:='mon-from1';
  				values['15']:='mon-to1';
  				values['16']:='mon-from2';
  				values['17']:='mon-to2';
  				values['18']:='tue-from1';
  				values['19']:='tue-to1';
  				values['1A']:='tue-from2';
  				values['1B']:='tue-to2';
  				values['1C']:='wed-from1';
  				values['1D']:='wed-to1';
  				values['1E']:='wed-from2';
  				values['1F']:='wed-to2';
  				values['20']:='thu-from1';
  				values['21']:='thu-to1';
  				values['22']:='thu-from2';
  				values['23']:='thu-to2';
  				values['24']:='fri-from1';
  				values['25']:='fri-to1';
  				values['26']:='fri-from2';
  				values['27']:='fri-to2';
  				values['28']:='sat-from1';
  				values['29']:='sat-to1';
  				values['2A']:='sat-from2';
  				values['2B']:='sat-to2';
  				values['2C']:='sun-from1';
  				values['2D']:='sun-to1';
  				values['2E']:='sun-from2';
  				values['2F']:='sun-to2';

			  	values['3E']:='mode';
  				values['3F']:='holiday1';
  				values['40']:='holiday2';
  				values['41']:='desired-temp';
  				values['XX']:='measured-temp';
  				values['42']:='measured-low';
  				values['43']:='measured-high';
  				values['44']:='warnings';
  				values['45']:='manu-temp';

  				values['4B']:='ack';
  				values['53']:='can-xmit';
  				values['54']:='can-rcv';

  				values['60']:='year';
  				values['61']:='month';
  				values['62']:='day';
  				values['63']:='hour';
  				values['64']:='minute';
  				values['65']:='report1';
  				values['66']:='report2';
  				values['69']:='ack2';

  				values['7D']:='start-xmit';
  				values['7E']:='end-xmit';

  				values['82']:='day-temp';
  				values['84']:='night-temp';
  				values['85']:='lowtemp-offset';
  				values['8A']:='windowopen-temp';

  				values['B9']:='TFK';



  end;
end;
//------------------------------------------------------------------------------
procedure ExitProc; stdcall;
begin
fs20_codes.Free;
fht_codes.Free;
//fs20_codes.Destroy;
//fht_codes.Destroy;

end;
//------------------------------------------------------------------------------
  function  data2hex(s : string):string;
  var l,i:integer;
  r:string;
begin
  r:='';
  l:=Length(s);
  if l >0 then
  begin

    for i:=1 to l do
    begin
        r:=r+btohex(ord(s[i]))+' ';
    end;
  end; //if
  result:=r;
end; //function
//------------------------------------------------------------------------------
function btohex(b:byte):string;
begin
  result:=inttohex(b,2);
end;
//------------------------------------------------------------------------------
function bin2four(v:string):string;
var r:string;
  l,i:integer;
  a,b:integer;
begin
  r := '';
  l:=length(v);
  for i:=1  to l do
  begin
    a:=ord(v[i]);
    b:=a and $f;
    a:=a shr 4;
    r :=r+format(' %d%d', [(a div 4)+1, (a mod 4)+1]);
    r :=r+format('%d%d', [(b div 4)+1, (b mod 4)+1]);
  end;
  Result:=r;
end;
//------------------------------------------------------------------------------

function four2bin(v:string):string;
var l,i,a,p:integer;
  r:integer;
  res:string;
begin
res:='';
Result:='';
l:=length(v);
if (l mod 4)>0 then exit;
p:=1;
while p<l do
begin
  r:=0;
  for i:=1  to 4 do
  begin
    a:=ord(v[p])-$30;
    r:=(r *4)+(a-1);
  inc(p);
  end;
  res:=res+chr(r);
end;
  Result:=res;
end; //function
//------------------------------------------------------------------------------
function  string2hex(s : string):string;
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
function  bcd2string(s : string):string;
var l,i: integer;
    a,b:byte;
    r:string;
begin
  r:='';
  l:=length(s);
  if l>0 then
  begin
    for i := 1 to l do
      begin
       a:=ord(s[i]);
       b:=a and $f;
        a:=a shr 4;
        r:=r+chr($30+a)+chr($30+b);
      end;
  end; //if
  result:=r;
end; //function

//----------###################
initialization
 codes_initialize;
//----------###################
finalization
  ExitProc
end.
