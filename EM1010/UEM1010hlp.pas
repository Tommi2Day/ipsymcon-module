unit UEM1010hlp;
//Thomas Dreßler (www.tdressler.net) 2009-2012
{
 Parts of this code is based on em1010.pl, found in fhem distribution
 (http://www.koeniglich.de/fhem/fhem.html)
 all rights are accepted
 }
interface
//common functions
 uses  sysutils,dateutils,classes,portinc,windows;

type

  em1010_stat= record
      device:integer;
      pulses:integer;
      pulses_max:integer;
      ec:integer;
      readings:integer;
      devs:integer;
      startblk:integer;
      cur_power:double;
      cur_power_max:double;
      sum_h_energy:double;
      sum_d_energy:double;
      sum_w_energy:double;
      total_energy:double;
      price_cf:double;
      alarm_pa:integer;
      iec:integer;
      cur_energy:double;
      pulses_total:integer;
end;
    TEM1010_data=record
        date:TDateTime;
        records:array[1..12] of EM1010_stat;
end;

  Tem1010_rec=record
      date:TDateTime;
      value:double;
  end;


 const maxfields=18;
const em1010rec_fields:array[0..maxfields] of string=
  ('Date','Device','pulses','pulses_max',
  'EnergyConst','Readings','devs','FirstPage',
  'Cur_Power',
  'Cur_Power_Max',
  'Sum_H_Energy','Sum_D_Energy','Sum_W_Energy',
  'Total_Energy',
  'Price_cf','alarm_pa','iec','Cur_Energy','pulses_total');
  const em1010rec_format='%d;%d;%d;%d;%d;%d;%d;%0.3f;%0.3f;%0.3f;%0.3f;%0.3f;%0.3f;%0.3f;%d;%d;%0.3f;%d;';

  function b(t :string;p: integer):byte;
  function w(t :string;p: integer):word;
  function dw(t :string;p: integer):integer;
  function docrc(inval,newval:word):word;
  function checkcrc(inval:string;len:integer):boolean;
  function makemsg(data:string):string;
  function maketime(timeval:TDateTime):string;
  function esc(inval:byte):string;
  function hexdump(data:string):string;
  function bin2hex( s : string):string;
  function hex2bin(s : string):string;
  procedure outlog(data:string);
  function openport(port:integer):boolean;
  function getdata:string;
  function getbyte:integer;
  function writedata(data:string):boolean;
  procedure closeport;
  function statusstring(status:em1010_stat):string;
  procedure EnumerateDosDevices( List: TStringlist );

 var
 frecord:integer;

 em1010_data  :Tem1010_data;
 em1010_records:array of Tem1010_rec;
 em1010rec_value:array[0..maxfields] of double;



 implementation
   // Beispiel: StrToHexString('Daten') => '446174656E'
function bin2hex(s : string):string;
begin
  if s = '' then
    Result := ''
  else
  begin
    SetLength(Result, Length(s)*2);
    BinToHex(PChar(s), PChar(Result), Length(s));
  end;
end;

// Beispiel: HexStringToStr('446174656E') => 'Daten'
function Hex2bin(s : string):string;
begin
  if s = '' then
    Result := ''
  else
  begin
    if Odd(length(s)) then
      s := '0'+s;
    SetLength(Result, Length(s) div 2);
    HexToBin(Pchar(s), PChar(Result), Length(Result));
  end;
end;

  //#########################
function b(t:string;p:integer):byte;
var c:char;
begin
  c:=t[p+1];
  Result:=ord(c);
end;
//#########################

function w(t :string;p: integer):word;
begin
  w:= b(t,p+1)*256 + b(t,p);
end;

//#########################
function dw(t :string;p: integer):integer;
begin
  dw:= w(t,p+2)*65536 + w(t,p);
end;

//#########################
function docrc(inval,newval:word):word;
var crc,bits,k,v:integer;
begin

  crc:=0;
  bits:=8;
  k := ((inval shr 8) xor newval) shl 8;
  while(bits > 0) do
  begin
    v:=(crc xor k) and $8000;
    if v=0 then
      crc:=crc shl 1
    else
      crc := (crc shl 1) xor $8005;

    k :=k shl 1;
    Dec(bits);
  end;
  v:=((inval shl 8) xor crc) and $ffff;
  Result:= v;
end;

//#########################
function checkcrc(inval:string;len:integer):boolean;
var crc,crccheck:word;
  l:integer;
  bt:byte;
  r:boolean;
begin
  crc := $8c27;
  len:=len+4;
  for l:=2 to len-1 do
  begin
    bt := b(inval,l);
    if ((bt =$02) or (bt=$03) or (bt=$10)) then crc := docrc(crc, $10);
    crc := docrc(crc, bt);
  end;
  crccheck:=w(inval, len);
  r:=(crc = crccheck);
  Result:= r;
end;

//#########################
function esc(inval:byte):string;
var outval:string;
    bt:byte;
begin
  outval := '';
  bt:=inval;
  if (bt = $02) or (bt = $03) or (bt=$10) then  outval :=outval+ chr($10);
  outval :=outval+ chr(bt);
  Result:=outval;
end;

//#########################
function makemsg(data:string):string;
var len,l:integer;
  outval:string;
  crc:word;
  bt:byte;
begin
  len := length(data);
  data := chr(len and $ff) + chr((len div 256) and $FF) + data;

  outval := #2#0;
  crc := $8c27;
  for l := 0 to  len+1 do
  begin
    bt := b(data,l);
    if ((bt =$02) or (bt=$03) or (bt=$10)) then crc := docrc(crc, $10);
    crc := docrc(crc, bt);
    outval :=outval+ esc(bt);
  end;
  outval :=outval+ esc(crc and $ff);
  outval :=outval+ esc(crc div 256);
  outval :=outval+ chr($03);
  Result:=outval;
end;

//#########################
function maketime(timeval:TDateTime) :string;
var
  myDate : TDateTime;
  myYear, myMonth, myDay : Word;
  myHour, myMin, mySec, myMilli : Word;

 begin
 myDate:=timeval;
 DecodeDateTime(myDate, myYear, myMonth, myDay,
                 myHour, myMin, mySec, myMilli);

 Result:=Format('%4.4d-%2.2d-%2.2d %2.2d:%2.2d:00',[
                myYear,myMonth,myDay,myHour,myMin]);
end;
//#########################
function hexdump(data:string):string;
var i,l:integer;
  outval:string;
  //h:string;
begin
outval:='';
l:=length(data) ;
  for i := 1 to  l do
  begin
    outval := outval+format('%2.2x',[ord(data[i])]);
    if (l mod 16)=0 then
        outval:=outval+#13+#10;
    if (l mod 4)=0 then
        outval:=outval+' ';
  end;
  outval:=outval+#13+#10;
  Result:=outval;
end;

//------------------------------------------------------------------------------
procedure outlog(data:string);
var f:textfile;
  logfile:string;
begin
 logfile:='em1010pl.log';
 if fileexists(logfile) then
 begin
 assignfile(f,logfile);
  append(f);
  writeln(f,data);
  flush(f);
  close(f);
 end;
end;
//------------------------------------------------------------------------------
function statusstring(status:em1010_stat):string;
var data:string;
begin
  DecimalSeparator:='.';
  with status do begin
  data:=Format(em1010rec_format,[
    device,pulses, pulses_max,ec, readings,devs,startblk,
     cur_power, cur_power_max,
    sum_h_energy,sum_d_energy,sum_w_energy,
    total_energy,price_cf,alarm_pa,iec,cur_energy,pulses_total]);
  end;
Result:=data;
end;
//------------------------------------------------------------------------------
function openport(Port:integer):boolean;
var p:integer;
s:pchar;
begin
     Result:=false;
     if (port<1) or (port>99) then exit;
      s:=Pchar('COM'+inttostr(port)+': baud=38400 data=8 parity=N stop=1');
      if port>9 then
         s:=Pchar('\\.\COM'+inttostr(port)+': baud=38400 data=8 parity=N stop=1');
         try
      p:=portinc.OPENCOM(s);
         except
            on exception do p:=-1;
         end;
      Result:=(p<>0);
end;
procedure closeport;
begin
      portinc.CLOSECOM;
end;

//------------------------------------------------------------------------------

function writedata(data:string):boolean;
var l,i:integer;
    b:byte;
begin
  l:=length(data);
  for i:= 1 to l do
  begin
    b:=ord(data[i]);
    portinc.SENDBYTE(b);
  end;
   Result:=true;
end;
//------------------------------------------------------------------------------
function getbyte:integer;
begin
  result:=portinc.READBYTE;
end;

//------------------------------------------------------------------------------
function getdata:string;
var
buffer:string;
b:integer;
begin
  buffer:='';
  while true do
  begin
    b:=getbyte;
    if b<0 then break;
    buffer:=buffer+chr(b);
  end;
   Result:=buffer;
end;
//------------------------------------------------------------------------------
//http://www.delphigroups.info/2/fd/417256.html
procedure EnumerateDosDevices( List: TStringlist );
var
  Buffer: pChar;
  BufLen: Cardinal;
  len: Cardinal;
  p: PChar;
  sl: TStringlist;
begin
  Assert( Assigned( List ));
  BufLen := High(Word);
  Buffer := AllocMem(BufLen);
  try
    repeat
      len:= QueryDosDevice(nil, Buffer, Buflen - 1);
      if len = ERROR_INSUFFICIENT_BUFFER then begin
        BufLen := Buflen * 2;
        ReAllocMem(Buffer, BufLen);
      end;
    until len <> ERROR_INSUFFICIENT_BUFFER;
    Buffer[Len] := #0;
    sl:= TStringlist.Create;
    try
      p:= Buffer;
      while p < @Buffer[Len] do begin
        sl.Add(p);
        p:= StrEnd(p)+1;
      end;
      sl.Sorted := true;
      List.Assign(sl);
    finally
      sl.Free;
    end; { finally }
  finally
    FreeMem(Buffer);
  end; { finally }
end;

end.
