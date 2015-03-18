unit LCP100_CRC;

interface
uses
	Windows, SysUtils, Classes;

function crc16_init(init:word):word;
function crc16_byte(crc:word; data:byte):word;
function crc16(init:word; Data:tstream):word;

implementation

function crc16_byte(crc:word; data:byte):word;
var r:dword;
    b:byte;
    i:integer;
begin
	//result:= (crc shl 8) xor crc16_table[ ((crc shr 8) xor data) and $ff ];
  r := crc;
  for i := 0 to 7 do
  begin
    r := r shl 1;
    b := (data and $80) shr 7;
    r := r or b;
    data := data shl 1;
    if (r and $010000) =$010000 then r := r xor $8005;
  end;
  result := r and $FFFF;
end;

function crc16_init(init:word):word;
var crc:word;
begin
	crc := crc16_byte( $0000,init shr 8);
	result:= crc16_byte(crc, init and $ff);
end;

function crc16(init:word; Data:tstream):word;
var crc:word;
    i:word;
    t:byte;
begin
	crc := crc16_init( init );
  data.Position := 0;
  for i := 0 to data.Size - 1 do
  begin
    data.Read(t,1);
    crc := crc16_byte(crc, t);
  end;
	result:= crc;
end;


end.
