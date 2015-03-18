unit LCP100_Frame;

interface
uses
	Windows, Messages, SysUtils, Classes, CPDrv;

function  Frame_Receive(Comm:TCommPortDriver; ReceiveFrame:TStream):boolean;
function  Frame_Send(Comm:TCommPortDriver;DataFrame:TStream):boolean;
procedure SplitWord(w:word;var hi,lo:byte);
function CombineWord(hi,lo:byte):word;

implementation
uses LCP100_CRC;

procedure SplitWord(w:word;var hi,lo:byte);
var whi,wlo:word;
begin
  whi := (w and $FF00) shr 8;
  wlo := (w and $00FF);
  hi := whi;
  lo := wlo;
end;

function CombineWord(hi,lo:byte):word;
var whi,wlo:word;
begin
  whi := hi shl 8;
  wlo := lo;
  result := whi + wlo;
end;

function receive_byte(Comm:TCommPortDriver; var crc:word; var dest:byte ):cardinal;
var t:array[0..0] of byte;
begin
  dest := 0;
  result := 0;
	if comm.ReadData( @t, 1) = 0 then exit;
  result := result + 1;

	if ( t[0] = $10 ) then
  begin
		comm.readdata( @t, 1 );
		t[0] := t[0] and $7f;
	end;

	if ( crc <> 0 ) then
  begin
		crc := crc16_byte(crc, t[0]);
  end;

	dest := t[0];
 end;

function receive_word(Comm:TCommPortDriver; var crc:word; var dest:word ):cardinal;
var
  hi,lo:byte;
  //whi,wlo:word;
begin
  dest := 0;
  result := 0;

	if receive_byte(Comm, crc, hi)<>1 then exit;
  result := result + 1;
	if receive_byte(Comm, crc, lo)<>1 then exit;
  result := result + 1;

  dest := CombineWord(hi,lo);
 end;

function send_byte(var crc:word; src:byte; sendbuffer:tstream ):boolean;
var t:byte;
begin
  //result := false;
	t := src;

	if ( t = $02) or (t = $10 ) then
  begin
		t := $10;
		sendbuffer.Write(t,1);
		t := src or $80;
  end;

	sendbuffer.Write(t,1);

	if ( crc <> 0 ) then
  begin
		crc := crc16_byte(crc, src );
  end;
  result := true;
end;

function send_word(var crc:word; src:word; sendbuffer:tstream ):boolean;
var hi,lo:byte;
    //whi,wlo:word;
begin
  SplitWord(src,hi,lo);

	result := send_byte(crc, hi ,sendbuffer);
  result := result and send_byte(crc, lo,sendbuffer );
end;

function Frame_Receive(Comm:TCommPortDriver; Receiveframe:TStream):boolean;
var
  t:byte;
  framesize:word;
  computed_crc:word;
  crc,w:word;
  i:integer;
begin
  result := false;
	t := 0;
	crc := 0;
	//i := 0;
  ReceiveFrame.Position := 0;
  ReceiveFrame.Size := 0;

	if (comm.readdata(@t, 1) <> 1) or
     (t <> $02 ) then exit;

	computed_crc := crc16_init( $ffff );

	receive_word(Comm, computed_crc, framesize);

	for i := 0 to framesize - 1 do
  begin
		if receive_byte(Comm, computed_crc, t) = 0 then break;
    ReceiveFrame.Write(t,1);
  end;

  w := 0;
	receive_word(Comm, w,crc);

	if computed_crc = crc
    then result := true;
end;

function Frame_Send(Comm:TCommPortDriver; DataFrame:TStream):boolean;
var t:byte;
    crc,w, length:word;
    i:integer;
    sendframe:tmemorystream;
begin
  ///result := false;
  DataFrame.Position := 0;
  sendframe := TMemoryStream.Create;
  try
    (* send 0x02 (STX) directly (no DLE-encoding wanted) *)
    t := $02;
    sendframe.Write(t,1);

    crc := crc16_init( $ffff );

    length := DataFrame.Size;
    send_word(crc, length, sendframe);

    for i := 0 to length - 1 do
    begin
      DataFrame.Read(t,1);
      send_byte(crc, t,sendframe);
    end;

    crc := crc16_byte(crc,0);
    crc := crc16_byte(crc,0);

    w := 0;
    send_word( w, crc,sendframe);

    sendframe.Position := 0;
    result := comm.SendData(sendframe.Memory,sendframe.Size) = sendframe.Size;
  finally
    sendframe.Free;
  end;
end;

end.
