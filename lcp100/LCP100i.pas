unit LCP100i;

interface

uses
  Windows,
  SysUtils, Classes, CPDrv, Graphics;

type
TProgress=procedure (position:integer) of object;stdcall;
type
  TLCP100ips = class
  private
    { Private-Deklarationen }
    FComPort:TCommPortDriver;
    FPageImages:array[0..63] of TBitmap;
    FBacklightOn: boolean;
    FPageUploading: integer;
    FPageDownloading: integer;
    FPageShowing: integer;
    FPageCurrent:Integer;
    FOnTranferFinished: TNotifyEvent;
    FProgress:TProgress;
    function GetCommPortNo: TPortNumber;
    function GetConnected: boolean;
    function GetPageImage: TBitmap;
    procedure SetBacklightOn(const Value: boolean);
    procedure SetCommPortNo(const Value: TPortNumber);
    procedure SetConnected(const Value: boolean);
    procedure SetPageImage(const Value: TBitmap);
    function GetFirmwareVersion: string;
    procedure SetFirmwareVersion(const Value: string);
    procedure SetPageShowing(const Value: integer);
    procedure SetPageUploading(const Value: integer);
    procedure SetPageDownloading(const Value: integer);
  protected
    { Protected-Deklarationen }

  public
    procedure Find_LCP100_ComPort(List:TStrings);
    procedure setComPortByName(const portname:string);
    { Public-Deklarationen }
    constructor Create; 
    destructor Destroy; override;
    function Connect:boolean;
    function Disconnect:boolean;

    function ClearDisplay:boolean;
    function ShowTestImage:boolean;
    function UploadImage(Bmp:TBitmap; Page:integer):boolean;
    function DownloadImage(var Bmp:TBitmap; Page:integer):boolean;
    function ShowPageNo(PageNo:integer):boolean;
  published
    { Published-Deklarationen }
    property CommPortNo:TPortNumber read GetCommPortNo write SetCommPortNo;
    property Connected:boolean read GetConnected write SetConnected stored false;
    property FirmwareVersion:string read GetFirmwareVersion write SetFirmwareVersion stored false;
    property BacklightOn:boolean read FBacklightOn write SetBacklightOn stored false;
    property PageShowing:integer read FPageShowing write SetPageShowing stored false;
    property PageUploading:integer read FPageUploading write SetPageUploading stored false;
     property PageDownloading:integer read FPageDownloading write SetPageDownloading stored false;
    property PageImage:TBitmap read GetPageImage write SetPageImage stored false;
    property OnTranferFinished:TNotifyEvent read FOnTranferFinished write FOnTranferFinished;
    property Progress:TProgress read FProgress write FProgress;
  end;



implementation
uses registry,LCP100_Cmd;

{ TLCP100ips }

function TLCP100ips.ClearDisplay: boolean;
begin
  result := LCP100_ClearDisplay(FComPort);
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

function TLCP100ips.Connect: boolean;
begin
  result := FComPort.Connect;
  if Result then
  begin
    ClearDisplay;
    BacklightOn := true;
  end;
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

constructor TLCP100ips.Create;
var i:integer;
  row: Integer;
  col: Integer;
  color:TColor;
begin
  inherited;
  FComPort := TCommPortDriver.Create(nil);
  FComPort.BaudRate := br38400;
  FComPort.DataBits := db8BITS;
  FComPort.StopBits := sb1BITS;
  FComPort.Parity := ptEVEN;

  FBacklightOn := true;
  FPageUploading := 0;
  FPageShowing := 0;
  FPageDownloading := 0;
  for i := 0 to LCP100_NumberOfPages - 1 do
  begin
    FPageImages[i] := TBitmap.Create;
    FPageImages[i].width := 128;
    FPageImages[i].height := 128;
    FPageImages[i].pixelformat := pf24bit;
  end;
  i:=  LCP100_NumberOfPages - 1;
  color:=$FFFFFF;
  for row := 0 to 127 do
  begin
    for col := 0 to 127 do
    begin
       FPageImages[i].Canvas.Pixels[row,col]:=color;
    end;
  end;
  FPageCurrent:=i;
end;

destructor TLCP100ips.Destroy;
//var i:integer;
begin
  {
  for i := 0 to LCP100_NumberOfPages - 1 do
  begin
    if assigned(FPageImages[i]) then FPageImages[i].Free;
  end;
  }
  FComPort.Disconnect;
  FComPort.Free;
  inherited;
end;

function TLCP100ips.Disconnect: boolean;
begin
  FComPort.Disconnect;
  result := not FComPort.Connected;
end;
procedure TLCP100ips.Find_LCP100_ComPort(List:TStrings);
var reg:tregistry;
    sl:tstringlist;
    i:integer;
    portname:string;
    res:TStringList;
begin

  reg := TRegistry.Create;
  sl := TStringList.Create;
  res:=TStringlist.Create;
  try
    reg.Access := KEY_READ;
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.OpenKey('Hardware\DeviceMap\SERIALCOMM',false) then
    begin
      reg.GetValueNames(sl);
      sl.text := LowerCase(sl.Text);
      for i := 0 to sl.Count - 1 do
      begin
        if pos('\device\silabser',sl[i]) = 1 then
        begin
          portname := reg.ReadString(sl[i]);
          res.Add(trim(portname));
        end;
      end;
    end;
  List.Assign(res);
  finally
    reg.Free;
    sl.Free;
  end;
end;

function TLCP100ips.GetCommPortNo: TPortNumber;
begin
  result := FComPort.Port;
end;

function TLCP100ips.GetConnected: boolean;
begin
  result := FComPort.Connected;
end;

function TLCP100ips.GetFirmwareVersion: string;
begin
  result := LCP100_GetFirmwareVersion(FComPort);
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

function TLCP100ips.GetPageImage: TBitmap;
begin
  result := FPageImages[FPageCurrent];
end;

procedure TLCP100ips.SetBacklightOn(const Value: boolean);
begin
  if value then
  begin
    if LCP100_BacklightOn(FComPort) then FBacklightOn := true;
  end else begin
    if LCP100_BacklightOff(FComPort) then FBacklightOn := false;
  end;
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

procedure TLCP100ips.SetCommPortNo(const Value: TPortNumber);
begin
  if FComPort.Connected then abort;
  FComPort.Port := Value;
end;
procedure TLCP100ips.setComportbyname(const portname:string);
var port:TPortNumber;
begin
  if length(portname)<4 then abort;
  if pos('COM',portname)<>1 then abort;
  port := TPortNumber(strtointdef(copy(portname,4,2),integer(fcomport.Port)));
  SetCommPortNo(port);
end;


procedure TLCP100ips.SetConnected(const Value: boolean);
begin
  if value
    then Connect
    else Disconnect;
end;

procedure TLCP100ips.SetFirmwareVersion(const Value: string);
begin
  //read only
end;

procedure TLCP100ips.SetPageImage(const Value: TBitmap);
begin
  UploadImage(value,FPageUploading);
end;

procedure TLCP100ips.SetPageShowing(const Value: integer);
begin
  if (value < 0) or (value > LCP100_NumberOfPages - 1) then exit;

  if LCP100_ShowPage(FComPort, Value,Progress)
    then FPageShowing := Value;
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

procedure TLCP100ips.SetPageUploading(const Value: integer);
begin
if (value < 0) or (value > LCP100_NumberOfPages - 1) then exit;
  FPageUploading := Value;
  FPageCurrent:=Value;
end;

procedure TLCP100ips.SetPageDownloading(const Value: integer);
begin
if (value < 0) or (value > LCP100_NumberOfPages - 1) then exit;
  FPageDownloading := Value;
  FPageCurrent:=Value;
end;
function TLCP100ips.ShowPageNo(PageNo: integer): boolean;
begin
  SetPageShowing(PageNo);
  Result := PageNo = FPageShowing;
  FPageCurrent:=FPageShowing;
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

function TLCP100ips.ShowTestImage: boolean;
begin
  Result := LCP100_TestImage(FComPort);
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

function TLCP100ips.UploadImage(Bmp: TBitmap; Page: integer): boolean;
begin
  if (Page < 0) or (Page > LCP100_NumberOfPages - 2) then abort;
  {clear
  pageUploading:=LCP100_NumberOfPages - 1;
  LCP100_UploadImage(fcomport,PageUploading,FPageImages[LCP100_NumberOfPages - 1]);
  }
  pageUploading:=page;
  FPageImages[Page].Canvas.StretchDraw(FPageImages[Page].Canvas.ClipRect,Bmp);
  Result := LCP100_UploadImage(fcomport,PageUploading,FPageImages[Page],Progress);
  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;

function TLCP100ips.DownloadImage(var Bmp: TBitmap;Page: integer ): boolean;
begin
  if (Page < 0) or (Page > LCP100_NumberOfPages - 1) then abort;
  pageDownloading:=page;
  Result := LCP100_DownloadImage(fcomport,PageDownloading,bmp,progress);
  FPageImages[Page]:=Bmp;

  if Assigned(FOnTranferFinished) then FOnTranferFinished(Self);
end;
end.
