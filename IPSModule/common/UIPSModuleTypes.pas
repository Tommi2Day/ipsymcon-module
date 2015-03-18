unit UIPSModuleTypes;

interface

uses Windows, SysUtils, UIPSTypes, InvokeRegistry;

const
 IPS_MODULEBASE = 20000;

//Defines Interfaces that are implemented
//------------------------------------------------------------------------------
type
 TIDHeader = class(TSOAPHeader)
  private
   FID: Integer;
  published
   property ID: Integer read FID write FID;
 end;

 IIPSMain = interface(IInvokable)
  ['{C2C382AE-DFF2-47B8-95C3-8BF7CEFA2DF7}']
 end;

 IIPSDMXOutput = interface(IInvokable)
  ['{E19C2E41-7347-4A3B-B7D9-A9A88E0D133E}']
  procedure SetValue(Channel, Value: Integer); stdcall;
  procedure Fade(Channel, Value: Integer; FadingSeconds: Double); stdcall;
  procedure FadeDelayed(Channel, Value: Integer; FadingSeconds, DelayedSeconds: Double); stdcall;
 end;

 TDMXGatewayMode = (gmDMX4ALL, gmArtNet);

 IIPSDMXSplitter = interface(IInvokable)
  ['{B1E43BF6-770A-4FD7-B4FE-6D265F93746B}']
  procedure SetBlackOut(BlackoutOn: Boolean); stdcall;
  procedure ResetInterface(); stdcall;
  procedure RequestInfo(); stdcall;
 end;

 IIPSClientSocket = interface(IInvokable)
  ['{3CFF0FD9-E306-41DB-9B5A-9D06D38576C3}']
  procedure SendText(Text: String); stdcall;
 end;

 IIPSUDPSocket = interface(IInvokable)
  ['{82347F20-F541-41E1-AC5B-A636FD3AE2D8}']
  procedure SendText(Text: String); stdcall;
 end;
 
 IIPSServerSocket = interface(IInvokable)
  ['{8062CF2B-600E-41D6-AD4B-1BA66C32D6ED}']
  procedure SendText(Text: String); stdcall;
 end; 

 //If you implement this one, you are required to have the following properties
 //-BaudRate, StopBits, DataBits, Parity
 IIPSSerialControl = interface(IInvokable)
  ['{62351C4A-1947-4AEA-A3F3-8FA85D22C960}']
 end;

 IIPSSerialControlEx = interface(IIPSSerialControl)
  ['{2A35E181-2562-433F-9F61-2C169EF6CA80}']
  procedure SetDTR(OnOff: Boolean); stdcall;
  procedure SetRTS(OnOff: Boolean); stdcall;
  procedure SetDTRFlowControl(Mode: Integer); stdcall;
  procedure SetRTSFlowControl(Mode: Integer); stdcall;
  procedure SetBreak(OnOff: Boolean); stdcall;
 end;

 IIPSSerialPort = interface(IIPSSerialControlEx)
  ['{6DC3D946-0D31-450F-A8C6-C42DB8D7D4F1}']
  procedure SendText(Text: String); stdcall;
 end;

 IIPSMediaControl = interface(IInvokable)
 ['{B66913CF-9917-434C-B9A2-38095C977705}']
  procedure Play(); stdcall;
  procedure Stop(); stdcall;
  procedure Pause(); stdcall;
  procedure Prev(); stdcall;
  procedure Next(); stdcall;
  procedure SetPosition(Seconds: Integer); stdcall;  
  procedure SetVolume(Volume: Integer); stdcall;
  procedure SetShuffle(DoShuffle: Boolean); stdcall;
  procedure SetRepeat(DoRepeat: Boolean); stdcall;
 end;

 IIPSPlaylistControl = interface(IIPSMediaControl)
 ['{30F06CBE-CD9D-4479-A340-7DC91A2F1D81}']
  procedure AddFile(Filename: String); stdcall;
  procedure ClearPlaylist(); stdcall;
  function GetPlaylistLength(): Integer; stdcall;
  function GetPlaylistPosition(): Integer; stdcall;
  procedure SetPlaylistPosition(Position: Integer); stdcall;
  function GetPlaylistFile(Position: Integer): String; stdcall;
  function GetPlaylistTitle(Position: Integer): String; stdcall;
 end;

 IIPSWinampControl = interface(IIPSPlaylistControl)
  ['{2999EBBB-5D36-407E-A52B-E9142A45F19C}']
  procedure SetLocation(WinampPath: String); stdcall;
  function GetLocation: String; stdcall;
  //Actions
  procedure PlayFile(Filename: String); stdcall;
 end;

 IIPSMediaPlayer = interface(IIPSPlaylistControl)
  ['{2999EBBB-5D36-407E-A52B-E9142A45F19C}']
  procedure SetDeviceID(DeviceID: Integer); stdcall;
  function GetDeviceID(): Integer; stdcall;
  function GetDevices(): TStringArray; stdcall;
  procedure SetUpdateInterval(Seconds: Integer); stdcall;
  function GetUpdateInterval: Integer; stdcall;
  //Actions
  procedure PlayFile(Filename: String); stdcall;
 end;

 IIPSEZControlT10 = interface(IInvokable)
  ['{9B177C28-BD4D-478C-922E-7743A6E6BBDB}']
  function SendCommand(System, HC1, HC2, Addr, Value, Param, RepeatNum: Integer): Boolean; stdcall;
  function SendPreset(SwitchNum, Value: Integer): Boolean; stdcall;
 end;

 IIPSWWWReader = interface(IInvokable)
  ['{4CB91589-CE01-4700-906F-26320EFCF6C4}']
  procedure UpdatePage(); stdcall;
 end;

 IIPSWebInterface = interface(IInvokable)
  ['{D83E9CCF-9869-420F-8306-2B043E9BA180}']
 end;

 IIPSWinLIRC = interface(IInvokable)
  ['{19E51FC2-064B-4A51-8995-11FEFF7F129A}']
  //Actions
  procedure SendOnce(Remote, Button: String); stdcall;
 end;

 IIPSIRTransGateway = interface(IInvokable)
  ['{0F0F74EF-2304-4C23-840F-EC1C5B9A9A82}']
  function ListRemotes: TStringArray; stdcall;
  function ListButtons(Remote: String): TStringArray; stdcall;
 end;

 IIPSIRTransDevice = interface(IInvokable)
  ['{899DBC68-0147-4528-B95D-D43C568D4E56}']
  procedure SendOnce(Remote, Button: String); stdcall;
 end;

 THIDDevice = class(TIPSRemotable)
  private
   FDeviceSerial : String;
   FProductID    : Integer;
   FVendorID     : Integer;
   FDeviceName   : String;
   FDeviceVendor : String;
  published
   property DeviceSerial : String read FDeviceSerial write FDeviceSerial;
   property ProductID    : Integer read FProductID write FProductID;
   property VendorID     : Integer read FVendorID write FVendorID;
   property DeviceName   : String read FDeviceName write FDeviceName;
   property DeviceVendor : String read FDeviceVendor write FDeviceVendor;
 end;
 THIDDevices = Array of THIDDevice;

 IIPSHID = interface(IInvokable)
  ['{E6D7692A-7F4C-441D-827B-64062CFE1C02}']
  procedure SetOpen(Open: Boolean); stdcall;
  procedure SetDeviceSerial(Serial: String); stdcall;
  procedure SetDeviceVendorID(VID: Integer); stdcall;
  procedure SetDeviceProductID(PID: Integer); stdcall;
  function GetOpen: Boolean; stdcall;
  function GetDeviceSerial(): String; stdcall;
  function GetDeviceVendorID(): Integer; stdcall;
  function GetDeviceProductID(): Integer; stdcall;
  //Actions
  function GetDevices: THIDDevices; stdcall;
  procedure SendEvent(ReportID: Byte; Text: String); stdcall;
 end;

 TFTDIDevice = class(TIPSRemotable)
  private
   FSerialNumber : String;
   FDescription  : String;
   FInUse        : Boolean;
  published
   property SerialNumber : String read FSerialNumber write FSerialNumber;
   property Description  : String read FDescription write FDescription;
   property InUse        : Boolean read FInUse write FInUse;
 end;
 TFTDIDevices = Array of TFTDIDevice;

 IIPSFTDI = interface(IIPSSerialControlEx)
  ['{C1D478E9-2A3E-4344-BCC4-37C892F58751}']
  procedure SendText(Text: String); stdcall;
 end;

 IIPSUSBXp = interface(IIPSSerialControl)
  ['{BFC698E9-1F43-45CD-BD79-47EA79CE21AD}']
  procedure SendText(Text: String); stdcall;
 end;

 TFHZProtocol = (fhzpFS20, fhzpFHT, fhzpHMS, fhzpKS300, fhzpFHTResponse, fhzpDateTime);

 //Transmit Record
 TFHZDataTX = class(TIPSRemotable)
  private
   FProtocol  : TFHZProtocol;
   FDestByte1 : Byte;
   FDestByte2 : Byte;
   FDestByte3 : Byte;
   FDataByte1 : Byte;
   FDataByte2 : Byte;
   FDataByte3 : Byte;
  published
   property Protocol : TFHZProtocol read FProtocol write FProtocol;
   property DestByte1 : Byte read FDestByte1 write FDestByte1;
   property DestByte2 : Byte read FDestByte2 write FDestByte2;
   property DestByte3 : Byte read FDestByte3 write FDestByte3;
   property DataByte1 : Byte read FDataByte1 write FDataByte1;
   property DataByte2 : Byte read FDataByte2 write FDataByte2;
   property DataByte3 : Byte read FDataByte3 write FDataByte3;
 end;

 TFHZDevice=(fhzdFS20, fhzdFHT, fhzdHMSTF, fhzdHMST, fhzdHMSW, fhzdHMS100RM,
             fhzdHMS100TFK, fhzdSwitchIN, fhzdGasSensor1, fhzdGasSensor2, fhzdCOSensor, fhzdKS300, fhzdFIT, fhzdALW);

 //Receive Record
 TFHZDataRX = class(TIPSRemotable)
  private
   FProtocol   : TFHZProtocol;
   FDevice     : TFHZDevice;
   FDeviceByte : Byte;
   FSrcsByte1  : Byte;
   FSrcsByte2  : Byte;
   FSrcsByte3  : Byte;
   FSrcsByte4  : Byte;
   FDataByte1  : Byte;
   FDataByte2  : Byte;
   FDataByte3  : Byte;
   FDataByte4  : Byte;
  published
   property Protocol   : TFHZProtocol read FProtocol write FProtocol;
   property Device     : TFHZDevice read FDevice write FDevice;
   property DeviceByte : Byte read FDeviceByte write FDeviceByte;
   property SrcsByte1  : Byte read FSrcsByte1 write FSrcsByte1;
   property SrcsByte2  : Byte read FSrcsByte2 write FSrcsByte2;
   property SrcsByte3  : Byte read FSrcsByte3 write FSrcsByte3;
   property SrcsByte4  : Byte read FSrcsByte4 write FSrcsByte4;
   property DataByte1  : Byte read FDataByte1 write FDataByte1;
   property DataByte2  : Byte read FDataByte2 write FDataByte2;
   property DataByte3  : Byte read FDataByte3 write FDataByte3;
   property DataByte4  : Byte read FDataByte4 write FDataByte4;
 end;

 //Queueing Types
 TFHZQueueStatus = (
                    qsQueued,  //Item is queued and Waiting
                    qsWaiting, //Items was send to FHZ, Awaiting response
                    qsOk,      //Command was successfully send
                    qsTimeout  //Command response timed out
                    );

 TFHZQueueItem = class(TIPSRemotable)
  private
//   FInstanceID : TInstanceID;
   FQueueTime  : TDateTime;
   FExecTime   : TDateTime;
   FStatus     : TFHZQueueStatus;
   FData       : TFHZDataTX;
   FByteCount  : Integer;
  public
   property Data: TFHZDataTX read FData write FData;
   property ByteCount: Integer read FByteCount write FByteCount;   
  published
//   property InstanceID : TInstanceID read FInstanceID write FInstanceID;
   property QueueTime : TDateTime read FQueueTime write FQueueTime;
   property ExecTime: TDateTime read FExecTime write FExecTime;
   property Status: TFHZQueueStatus read FStatus write FStatus;
 end;
 TFHZQueueItems = Array of TFHZQueueItem;

 TFS20DeviceAddress = class(TIPSRemotable)
  private
   FAddress   : String;
   FSubAddress: String;
  published
   property Address    : String read FAddress write FAddress;
   property SubAddress : String read FSubAddress write FSubAddress;
 end;
 TFS20DeviceAddresses = Array of TFS20DeviceAddress;

 TFS20Device = class(TIPSRemotable)
  private
   FHomeCode  : String;
   FAddress   : String;
   FSubAddress: String;
   FMapping   : TFS20DeviceAddresses;
  public
   destructor Destroy; override;
  published
   property HomeCode   : String read FHomeCode write FHomeCode;
   property Address    : String read FAddress write FAddress;
   property SubAddress : String read FSubAddress write FSubAddress;
   property Mapping    : TFS20DeviceAddresses read FMapping write FMapping;
 end;

 TFS20Devices = Array of TFS20Device;

 IIPSFHZ = interface(IInvokable)
  ['{57040540-4432-4220-8D2D-4676B57E223D}']
  //function GetFHTQueue(): TFHZQueueItems; stdcall;
  function GetFreeBuffer(): Integer; stdcall;
 end;

 IIPSFS20 = interface(IInvokable)
  ['{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}']
  procedure SetDeviceAddress(HomeCode, Address, SubAddress: String); stdcall;
  procedure AddDeviceMapping(Address, SubAddress: String); stdcall;
  procedure RemoveDeviceMapping(Address, SubAddress: String); stdcall;
  procedure SetEnableReceive(Enable: Boolean); stdcall;
  procedure SetEnableTimer(Enable: Boolean); stdcall;
  function GetDeviceAddress(): TFS20Device; stdcall;
  function GetEnableReceive: Boolean; stdcall;
  function GetEnableTimer: Boolean; stdcall;
  //Helper
  function GetInstanceIDforAddress(HomeCode, Address, SubAddress: String): TInstanceID; stdcall;
  //Action
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure SwitchDuration(DeviceOn: Boolean; Duration: Integer); stdcall;
  procedure SetIntensity(Intensity: Integer; Duration: Integer); stdcall;
  procedure DimUp(); stdcall;
  procedure DimDown(); stdcall;
 end;

 IIPSFS20EX = interface(IInvokable)
  ['{56800073-A809-4513-9618-1C593EE1240C}']
  procedure SetHomeCode(HomeCode: String); stdcall;
  function GetHomeCode(): String; stdcall;
  function GetDevices: TFS20Devices; stdcall;
  procedure AddDevice(Address, SubAddress: String); stdcall;
  procedure DeleteDevice(Index: Integer); stdcall;
 end;

 IIPSFHT = interface(IInvokable)
  ['{A89F8DFA-A439-4BF1-B7CB-43D047208DDD}']
  procedure SetAddress(Address: String); stdcall;
  function GetAddress: String; stdcall;
  procedure SetEmulateStatus(Value: Boolean); stdcall;
  function GetEmulateStatus(): Boolean; stdcall;
  //Action
  procedure SetTemperature(Temperature: Double); stdcall;
  procedure SetMode(Mode: Integer); stdcall;
  procedure SetYear(Value: Integer); stdcall;
  procedure SetMonth(Value: Integer); stdcall;
  procedure SetDay(Value: Integer); stdcall;
  procedure SetHour(Value: Integer); stdcall;
  procedure SetMinute(Value: Integer); stdcall;
  procedure RequestData(); stdcall;
 end;

 TIPSHMSDeviceType =(dtUnknown,
                     dtHMST,
                     dtHMSTF,
                     dtHMSWD,
                     dtHMSTFK,
                     dtHMSRM,
                     dtHMSInput,
                     dtHMSGas1,
                     dtHMSGas2,
                     dtHMSCONotify,
                     dtHMSFIT);

 IIPSHMS = interface(IInvokable)
  ['{2FD7576A-D2AD-47EE-9779-A502F23CABB3}']
  procedure ReleaseFI(Delay: Integer); stdcall;
 end;

 IIPSKS300 = interface(IInvokable)
  ['{9D21F700-6F67-4FBB-ACC2-AA42420A0486}']
 end;

 TIPSHMSocketMode = (smCCU, smLAN);

 TIPSHMServiceMessage = class(TIPSRemotable)
  private
   FAddress : String;
   FMessage : String;
   FValue   : Variant;
  published
   property Address : String read FAddress write FAddress;
   property Message  : String read FMessage write FMessage;
   property Value    : Variant read FValue write FValue;
 end;
 TIPSHMServiceMessages = Array of TIPSHMServiceMessage;

 IIPSHMSocket = interface(IInvokable)
  ['{A151ECE9-D733-4FB9-AA15-7F7DD10C58AF}']
  function ReadServiceMessages(): TIPSHMServiceMessages; stdcall;
 end;

 THMProtocol = (hmpRadio, hmpWired);

 IIPSHMDevice = interface(IInvokable)
  ['{EE4A81C6-5C90-4DB7-AD2F-F6BBD521412E}']
  procedure WriteValueBoolean(Parameter: String; Value: Boolean); stdcall;
  procedure WriteValueInteger(Parameter: String; Value: Integer); stdcall;
  procedure WriteValueFloat(Parameter: String; Value: Double); stdcall;
  procedure WriteValueString(Parameter: String; Value: String); stdcall;
  procedure RequestStatus(Parameter: String); stdcall;
 end;

 THMDevice = class(TIPSRemotable)
  private
   FAddress: String;
   FProtocol: THMProtocol;
   FType: String;
   FDeviceName: String;
   FInstanceID: TInstanceID; //Search Status
  published
   property Address: String read FAddress write FAddress;
   property Protocol: THMProtocol read FProtocol write FProtocol;
   property Type_: String read FType write FType;
   property DeviceName: String read FDeviceName write FDeviceName;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 THMDevices = Array of THMDevice;

 IIPSHMConfigurator = interface(IInvokable)
 ['{5214C3C6-91BC-4FE1-A2D9-A3920261DA74}']
  procedure LoadDevices(Protocol: THMProtocol); stdcall;
  function GetKnownDevices(): THMDevices; stdcall;
 end;
 
 THMType = (hmtBoolean, hmtInteger, hmtDouble, hmtString, hmtArray, hmtStruct);

const
 HMTypeValues: Array[THMType] of Word = ($01, $02, $03, $04, $100, $101);

type
  THMValue = class
   private
    FValueType: THMType;
   public
    constructor Create(ValueType: THMType);
    property ValueType: THMType read FValueType; 
  end;
  THMValues = Array of THMValue;

  THMBoolean = class(THMValue)
   private
    FValue: Boolean;
   public
    constructor Create(Value: Boolean);
    property Value: Boolean read FValue;
  end;

  THMInteger = class(THMValue)
   private
    FValue: Integer;
   public
    constructor Create(Value: Integer);
    property Value: Integer read FValue;
  end;

  THMDouble = class(THMValue)
   private
    FValue: Double;
   public
    constructor Create(Value: Double);
    property Value: Double read FValue;
  end;

  THMString = class(THMValue)
   private
    FValue: String;
   public
    constructor Create(Value: String);
    property Value: String read FValue;
  end;

  THMStruct = class(THMValue)
   private
    FName: String;
    FValue: THMValue;
   public
    constructor Create(Name: String; Value: THMValue);
    destructor Destroy; override;
    property Name: String read FName;
    property Value: THMValue read FValue;
  end;

  THMArray = class(THMValue)
   private
    FValues: THMValues;
    function GetCount: Integer;
    function GetValue(Index: Integer): THMValue;
   public
    constructor Create(Values: THMValues);
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Value[Index: Integer]: THMValue read GetValue;
  end;

 TIPSFS10DeviceType = (fdtUnknown,
                       fdtFunkfernbedienung,
                       fdtAussensensorT,
                       fdtAussensensorTF,
                       fdtRegensensor,
                       fdtWindsensor,
                       fdtInnensensor,
                       fdtHelligkeitssensor,
                       fdtPyranometer);

 TFS10Device = record
  DeviceType : TIPSFS10DeviceType;
  DeviceID   : Integer;
 end;

 IIPSFS10 = interface(IInvokable)
  ['{6D508C91-F197-44A9-A1AB-A27F97A18A5F}']
 end;

 IIPSFS10Splitter = interface(IInvokable)
  ['{753E7267-7558-49D3-ACFB-86755C28318D}']
 end;

 TOneWireDevice = class(TIPSRemotable)
  private
   FDeviceID: String;
   FDeviceFamily: Integer;
   FInstanceID: TInstanceID; //Search Status
  published
   property DeviceID: String read FDeviceID write FDeviceID;
   property DeviceFamily: Integer read FDeviceFamily write FDeviceFamily;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TOneWireDevices = Array of TOneWireDevice;

 IIPSOneWireConfigurator = interface(IInvokable)
 ['{F462BFF3-6772-4720-8450-49E6E2820643}']
  function GetKnownDevices(): TOneWireDevices; stdcall;
 end;

 IIPSOneWire = interface(IInvokable)
  ['{9317CC5B-4E1D-4440-AF3A-5CC7FB42CCAA}']
  procedure SetDevice(DeviceID: String); stdcall;
  function GetDevice(): String; stdcall;
  procedure SetInterval(Seconds: Integer); stdcall;
  function GetInterval: Integer; stdcall;
  procedure SetF05Invert(Invert: Boolean); stdcall;
  function GetF05Invert: Boolean; stdcall;
  procedure SetF05PinType(IsInput: Boolean); stdcall;
  function GetF05PinType(): Boolean; stdcall;
  procedure SetF12Invert(Pin: Integer; Invert: Boolean); stdcall;
  function GetF12Invert(Pin: Integer): Boolean; stdcall;
  procedure SetF12PinType(Pin: Integer; IsInput: Boolean); stdcall;
  function GetF12PinType(Pin: Integer): Boolean; stdcall;
  procedure SetF20PortType(Port: Integer; IsAnalogInput: Boolean); stdcall;
  function GetF20PortType(Port: Integer): Boolean; stdcall;
  procedure SetF20Resolution(Port: Integer; Value: Integer); stdcall;
  function GetF20Resolution(Port: Integer): Integer; stdcall;
  procedure SetF20Voltage(Port: Integer; Is510Volt: Boolean); stdcall;
  function GetF20Voltage(Port: Integer): Boolean; stdcall;
  procedure SetF2CUseCPC(UseCPC: Boolean); stdcall;
  function GetF2CUseCPC: Boolean; stdcall;
  procedure SetF28Precision(Precision: Integer); stdcall;
  function GetF28Precision: Integer; stdcall;
  procedure SetF29Invert(Pin: Integer; Invert: Boolean); stdcall;
  function GetF29Invert(Pin: Integer): Boolean; stdcall;
  procedure SetF29PinType(Pin: Integer; IsInput: Boolean); stdcall;
  function GetF29PinType(Pin: Integer): Boolean; stdcall;
  procedure SetF3AInvert(Pin: Integer; Invert: Boolean); stdcall;
  function GetF3AInvert(Pin: Integer): Boolean; stdcall;
  procedure SetF3APinType(Pin: Integer; IsInput: Boolean); stdcall;
  function GetF3APinType(Pin: Integer): Boolean; stdcall;
  //Action
  procedure RequestRead; stdcall;
  procedure F05_TogglePin(); stdcall;
  procedure F05_SetPin(Status: Boolean); stdcall;
  procedure F12_SetPin(Pin: Integer; Status: Boolean); stdcall;
  procedure F20_SetPin(Pin: Integer; Status: Boolean); stdcall;
  procedure F29_SetPin(Pin: Integer; Status: Boolean); stdcall;
  procedure F29_SetPort(Bitmask: Integer); stdcall;
  procedure F29_SetStrobe(Status: Boolean); stdcall;
  procedure F29_WriteBytes(Data: String); stdcall;
  procedure F29_WriteBytesMasked(Data: String; Mask: Integer); stdcall;
  procedure F2C_SetPosition(Value: Integer); stdcall;
  procedure F3A_SetPin(Pin: Integer; Status: Boolean); stdcall;
 end;

 TOWQueueStatus = (
                   owqsWaiting, //Item is queued and Waiting
                   owqsRunning  //Items request Accepted, waiting for Ready Flag
                  );

 TOWQueueItem = class(TIPSRemotable)
  private
   FInstanceID : TInstanceID;
   FQueueTime  : TDateTime;
   FExecTime   : TDateTime;
   FStatus     : TOWQueueStatus;
   FSlotID     : Integer;
  public
   property SlotID: Integer read FSlotID write FSlotID;
  published
   property InstanceID : TInstanceID read FInstanceID write FInstanceID;
   property QueueTime  : TDateTime read FQueueTime write FQueueTime;
   property ExecTime   : TDateTime read FExecTime write FExecTime;
   property Status     : TOWQueueStatus read FStatus write FStatus;
 end;
 TOWQueueItems = Array of TOWQueueItem;

 TOWAdapter = class(TIPSRemotable)
  private
   FPortNum: Integer;
   FPortType: Integer;
   FPortSpeed: Integer;
   FPortLevel: Integer;
  published
   property PortNum: Integer read FPortNum write FPortNum;
   property PortType: Integer read FPortType write FPortType;
   property PortSpeed: Integer read FPortSpeed write FPortSpeed;
   property PortLevel: Integer read FPortLevel write FPortLevel;
 end;

 IIPSTMEX = interface(IInvokable)
  ['{CED1D815-2477-4B05-8F65-0E4475913063}']
  function GetQueue(): TOWQueueItems; stdcall;
  function EnumerateDevices: TStringArray; stdcall;
 end;

 TALL4000DeviceType = (aldUnknown, aldTemperature, aldPressure, aldHumidity, aldSwitch, aldAnalog, aldCounter, aldIO, aldIllumination);

 IIPSALL4000 = interface(IInvokable)
  ['{2D8B0172-166C-45B0-B979-61A787809E22}']
  procedure ReadConfiguration(); stdcall;
  procedure UpdateValues(); stdcall;
 end;

 TALLDeviceType = (al3000RF, al3100, al3096, al3075, al3270, al4000Relais, al4000RF, al4000I2C, al4000RF433, al3418, al3421, al4500, al5000, al3075V2, al3073, al4076, al4075);

 IIPSALLUniversal = interface(IInvokable)
  ['{D805EC4C-7D17-4E84-98D3-A441AA71ACA3}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure UpdateValues(); stdcall;
 end;

 IIPSALL3690 = interface(IInvokable)
  ['{BBD04875-8CC5-412A-B848-B2AB6F08C425}']
  procedure UpdateValues(); stdcall;
 end;

 IIPSALL3691 = interface(IInvokable)
  ['{07CAE61E-01FA-4086-A2D1-55C442D8C8BF}']
  procedure UpdateValues(); stdcall;
 end;

 TLCNMessage = (lmIO, lmValue, lmData, lmCommand, lmAcknowledgement);
 TLCNAddress = (laModule, laGroup);

const
 LCN_Loggedin = IS_ACTIVE;
 LCN_Connected = IS_EBASE + 1;
 LCN_Disconnected = IS_EBASE + 2;
 LCN_AuthError = IS_EBASE + 3;
 LCN_LicenseError = IS_EBASE + 4;
 LCN_UnknownError = IS_EBASE + 5;

type
 TLCNDevice = class(TIPSRemotable)
  private
   FSegment: Byte;
   FTarget: Byte;
   FDeviceName: String;
   FInstanceID: TInstanceID; //Search Status
   //Temporary
   FName1: String;
   FName2: String;
   procedure SetName1(Value: String);
   procedure SetName2(Value: String);
  public
   property Name1: String read FName1 write SetName1;
   property Name2: String read FName2 write SetName2;
  published
   property Segment: Byte read FSegment write FSegment;
   property Target: Byte read FTarget write FTarget;
   property DeviceName: String read FDeviceName write FDeviceName;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TLCNDevices = Array of TLCNDevice;

 IIPSLCNSplitter = interface(IInvokable)
  ['{9BDFC391-DEFF-4B71-A76B-604DBA80F207}']
 end;

 IIPSLCNConfigurator = interface(IInvokable)
 ['{0F64973F-4669-4272-BDB3-6338D0350269}']
  procedure SearchDevices(Segment: Integer); stdcall;
  function GetKnownDevices(): TLCNDevices; stdcall;
 end;

 IIPSLCNModule = interface(IInvokable)
 ['{0E31FED6-E465-4621-95D4-AAF2683C41EC}']
  procedure SetRelay(Value: String); stdcall;
  procedure SetLamp(Lamp: Integer; Action: String); stdcall;
  procedure Beep(SpecialTone: Boolean; Count: Byte); stdcall;
  procedure AddGroup(Group: Integer); stdcall;
  procedure RemoveGroup(Group: Integer); stdcall;
  procedure RequestStatus(); stdcall;
  //Special Command
  procedure SendCommand(_Function, Data: String); stdcall;
 end;

 TLCNUnit = (luOutput, luBinInput, luRelay, luSum);

 IIPSLCNUnit = interface(IInvokable)
 ['{2D871359-14D8-493F-9B01-26432E3A710F}']
  procedure SwitchMode(Ramp: Byte); stdcall;
  procedure SwitchMemory(Ramp: Byte); stdcall;
  procedure SwitchDurationSec(Seconds: Byte; Fadeout: String; Retentive: Boolean); stdcall;
  procedure SwitchDurationMin(Minutes: Byte; Fadeout: String; Retentive: Boolean); stdcall;
  procedure SetIntensity(Intensity: Byte; Ramp: Byte); stdcall;
  procedure AddIntensity(Intensity: Byte); stdcall;
  procedure DeductIntensity(Intensity: Byte); stdcall;
  procedure FadeOut(Intensity, Ramp: Byte); stdcall;
  procedure StartFlicker(Depth, Speed: String; Count: Byte); stdcall;
  procedure StopFlicker(); stdcall;
  procedure RampStop(); stdcall;
  procedure LimitOutput(Value: Integer; Time: Integer; TimeType: String);
  procedure SelectSceneRegister(_Register: Integer); stdcall;
  procedure SaveScene(Scene: Integer); stdcall;
  procedure LoadScene(Scene: Integer); stdcall;
  //Actions Relay
  procedure SwitchRelay(SwitchOn: Boolean); stdcall;
  procedure FlipRelay(); stdcall;
 end;

 TLCNValue = ((* Old Modules *) lvTValue, lvR1Value, lvR1Target, lvR2Value, lvR2Target, lvTargetShift,
              (* New Modules *) lvA1Value, lvA2Value, lvA3Value, lvA4Value, lvA5Value, lvA6Value, lvA7Value, lvA8Value, lvA9Value, lvA10Value, lvA11Value, lvA12Value, lvS1Target, lvS2Target);
 TLCNTarget = (ltR1, ltR2, ltS1, ltS2);
 TLCNValueType = (ttTemperature, ttLux, ttCounter, ttLux2);
 TLCNValues = Array of TLCNValue;

 IIPSLCNValue = interface(IInvokable)
  ['{0102BDC9-3B85-4A11-968D-7D314DA07C06}']
  procedure SetTargetValue(Target: TLCNTarget; Value: Double); stdcall;
  procedure ShiftTargetValue(Target: TLCNTarget; RelativeValue: Double); stdcall;
  procedure LockTargetValue(Target: TLCNTarget); stdcall;
  procedure ReleaseTargetValue(Target: TLCNTarget); stdcall;
 end;

 IIPSLCNShutter = interface(IInvokable)
  ['{C81E019F-6341-4748-8644-1C29D99B813E}']
  procedure ShutterMoveDown(); stdcall;
  procedure ShutterMoveUp(); stdcall;
  procedure ShutterStop(); stdcall;
 end; 

 TLCNData = (ldThresholds, ldLights, ldTransponder, ldRemote, ldCommand);

 IIPSLCNData = interface(IInvokable)
  ['{A26E7E5A-A7C5-4063-8BE0-ED8BB26F8411}']
  procedure RequestThresholds; stdcall;
  procedure RequestLights; stdcall;
 end;

 TxComfortValueType = (dtBoolean, dtInteger, dtFloat);

 TxComfortDevice = class(TIPSRemotable)
  private
   FDataPoint: Integer;
   FDataPointName: String;
   FDeviceSerial: String;
   FDeviceType: Integer;
   FDeviceDP: Integer;
   FDeviceMode: Integer;
   FDeviceClass: Integer;
   FInstanceID: TInstanceID; //Search Status
  published
   property DataPoint: Integer read FDataPoint write FDataPoint;
   property DataPointName: String read FDataPointName write FDataPointName;
   property DeviceSerial: String read FDeviceSerial write FDeviceSerial;
   property DeviceType: Integer read FDeviceType write FDeviceType;
   property DeviceDP: Integer read FDeviceDP write FDeviceDP;
   property DeviceMode: Integer read FDeviceMode write FDeviceMode;
   property DeviceClass: Integer read FDeviceClass write FDeviceClass;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TxComfortDevices = Array of TxComfortDevice;

 IIPSxComfortConfigurator = interface(IInvokable)
 ['{5DD921D4-4712-443F-B89F-03434A4DBF94}']
  procedure SearchDevices(); stdcall;
  function GetKnownDevices(): TxComfortDevices; stdcall;
  procedure UploadDataPointFile(Content: String); stdcall;
 end;

 IIPSxComfortGateway = interface(IInvokable)
  ['{D2DCE381-19A7-4D14-B819-49C0539BC350}']
  procedure RequestInfo(); stdcall;
 end;

 IIPSxComfortModule = interface(IInvokable)
  ['{6BF7FB13-95FC-4F93-A993-40E4900213FF}']
  procedure RequestStatus(); stdcall;
 end;

 IIPSxSensorModule = interface(IIPSxComfortModule)
  //function AssignSensor(DoAssign: Boolean; OnAssign: TOnBasicModeEvent): HRESULT; stdcall; //BasicMode
  //function RemoveSensor(OnRemove: TOnBasicModeEvent): HRESULT; stdcall; //BasicMode
 end;

 IIPSxActuatorModule = interface(IIPSxComfortModule)
  //function AssignActuator(): HRESULT; stdcall; //BasicMode
  //function RemoveActuator(): HRESULT; stdcall; //BasicMode
 end;

 IIPSxComfortSwitch = interface(IIPSxActuatorModule)
  ['{27DD9788-802E-45B7-BA54-FB97141398F7}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
 end;

 IIPSxComfortDimmer = interface(IIPSxActuatorModule)
  ['{8050FEEC-C875-4BDD-9143-D15134B89D35}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure DimSet(Intensity: Integer); stdcall;
  procedure DimBrighter(); stdcall;
  procedure DimDarker(); stdcall;
  procedure DimStop(); stdcall;
 end;

 IIPSxComfortShutter = interface(IIPSxActuatorModule)
  ['{1B7B5B7D-CAA9-4AB5-B9D8-EC805EC955AD}']
  procedure ShutterMoveDown(); stdcall;
  procedure ShutterMoveUp(); stdcall;
  procedure ShutterStepDown(); stdcall;
  procedure ShutterStepUp(); stdcall;
  procedure ShutterStop(); stdcall;
 end;

 IIPSxComfortValueTX = interface(IIPSxActuatorModule)
  ['{ED6A1E00-81C7-416F-9F97-1F2CC8F45B15}']
  procedure SendBoolean(Value: Boolean); stdcall;
  procedure SendInteger(Value: Integer); stdcall;
  procedure SendFloat(Value: Double); stdcall;
 end; 

 IIPSxComfortBinary = interface(IIPSxSensorModule)
  ['{3040A77D-3E9C-42D4-A1B6-329EFE8086DB}']
 end;

 IIPSxComfortRemote = interface(IIPSxSensorModule)
  ['{DCBD8143-83AB-4068-8FC0-0C92A93AA8A8}']
 end;

 IIPSxComfortRoomControl = interface(IIPSxSensorModule)
  ['{1A1C4C67-C99D-4D3E-8A34-23581CE8CCAA}']
 end;

 IIPSxComfortTemperature = interface(IIPSxSensorModule)
  ['{591B4A05-E5BF-4EEA-BC34-36E6F1CC9D56}']
 end;

 TxComfortEnergyType = (etEnergy, etPower, etCurrent, etVoltage);

 IIPSxComfortEnergy = interface(IIPSxSensorModule)
  ['{814067F0-EACB-43C3-99BD-5CB9B2F8FB9E}']
 end;

 IIPSxComfortImpulse = interface(IIPSxSensorModule)
  ['{A374DCF0-CEDE-4EB7-B6A8-E92787E19B25}']
 end;

 IIPSxComfortHRV = interface(IIPSxSensorModule)
  ['{E4693C3F-95F1-48B6-9443-4A6B3EE0FACA}']
  procedure SetTemperature(Temperature: Double); stdcall;
 end;

 IIPSxComfortHumidity = interface(IIPSxSensorModule)
  ['{3EBA1AB7-72CA-48D2-8F89-813E085D41BB}']
 end;

 IIPSxComfortValueRX = interface(IIPSxSensorModule)
  ['{DA2FCC12-2DE1-404A-8A5E-1C6AF05F96A2}']
 end;

 IIPSTTS = interface(IInvokable)
  ['{684CC410-6777-46DD-A33F-C18AC615BB94}']
  procedure Speak(Text: String; Wait: Boolean); stdcall;
  procedure GenerateFile(Text, Filename: String; Format: Integer); stdcall;
 end;

 TRegVarAction  = (daRead, daWrite);
 TRegVarTarget  = (ddVariable, ddScript);
 TRegVarTrigger = (dtOnUpdate, dtOnChange);

 IIPSRegVar = interface(IInvokable)
  ['{F3855B3C-7CD6-47CA-97AB-E66D346C037F}']
  procedure SendText(Text: String); stdcall;
  function GetBuffer(): String; stdcall;
  procedure SetBuffer(Text: String); stdcall;
 end;

 TCParsingType=(ptCutting, ptFixedInput);

 IIPSCutter = interface(IInvokable)
  ['{AC6C6E74-C797-40B3-BA82-F135D941D1A2}']
  procedure ClearBuffer(); stdcall;
 end;

 TTParserType = (ptUnknown, ptCutBefore, ptCutAfter, ptGetText, ptGetBetween);  

 TTPRule = class(TIPSRemotable)
  private
   FParseType: TTParserType;
   FTagOne: String;
   FTagTwo: String;
   FVariable: TVariableID;
  published
   property ParseType: TTParserType read FParseType write FParseType;
   property TagOne: String read FTagOne write FTagOne;
   property TagTwo: String read FTagTwo write FTagTwo;
   property Variable: TVariableID read FVariable write FVariable;
 end;
 TTPRules = Array of TTPRule;

 IIPSTextParser = interface(IInvokable)
  ['{4B00C7F7-1A6D-4795-A2D2-08151854D259}']
  function GetRules: TTPRules; stdcall;
  procedure AddRule(ParseType: TTParserType; TagOne, TagTwo: String; Variable: TVariableID); stdcall;
  procedure EditRule(Index: Integer; ParseType: TTParserType; TagOne, TagTwo: String; Variable: TVariableID); stdcall;
  procedure DeleteRule(Index: Integer); stdcall;
 end;

 TISDNRejectCause = (rjeNormalCallClear,rjeIgnoreCall);
 TISDNConnections = Array of Integer;
 TISDNConnectionInfo = class(TIPSRemotable)
  private
   FState: Integer;
   FCallingNumber: String;
   FCalledNumber: String;
   FCIPValue: Integer;
  published
   property State: Integer read FState write FState;
   property CallingNumber: String read FCallingNumber write FCallingNumber;
   property CalledNumber: String read FCalledNumber write FCalledNumber;
   property CIPValue: Integer read FCIPValue write FCIPValue;
 end;

 IIPSISDN = interface(IInvokable)
  ['{D738E8CC-F524-454A-BB69-93E5BE416E87}']
  function Connect(Number: String): Integer; stdcall;
  procedure Disconnect(ConnectionID: Integer); stdcall;
  procedure AcceptCall(ConnectionID: Integer); stdcall;
  //procedure RejectCall(ConnectionID: Integer; RejectCause: TISDNRejectCause); stdcall;
  function PlayWave(ConnectionID: Integer; Filename: String): Integer; stdcall;
  procedure StopPlay(ConnectionID: Integer); stdcall;
  procedure RecordWave(ConnectionID: Integer; Filename: String); stdcall;
  procedure StopRecord(ConnectionID: Integer); stdcall;
  function GetActiveConnections: TISDNConnections; stdcall;
  function GetConnectionInfo(ConnectionID: Integer): TISDNConnectionInfo; stdcall;
 end;

 IIPSRFReader1 = interface(IInvokable)
  ['{4C4EAE41-96D8-45AA-A506-67609B06E400}']
 end;

 TCSTAMenuType = (mtSimple, mtNumEdit, mtNumEditEcho, mtStrEdit);

 TCSTAMenu = class(TIPSRemotable)
  private
   FType: TCSTAMenuType;
   FText: String;
   FShortKey: Integer;
   FOnSelect: TScriptID;
  published
   property _Type: TCSTAMenuType read FType write FType;
   property Text: String read FText write FText;
   property ShortKey: Integer read FShortKey write FShortKey;
   property OnSelect: TScriptID read FOnSelect write FOnSelect;
 end;
 TCSTAMenus = Array of TCSTAMenu;

 TCSTAKey = class(TIPSRemotable)
  private
   FKey: Integer;
   FOnPress: TScriptID;
  published
   property Key: Integer read FKey write FKey;
   property OnPress: TScriptID read FOnPress write FOnPress;
 end;
 TCSTAKeys = Array of TCSTAKey;

 IIPSCSTA = interface(IInvokable)
  ['{11842D31-3CA4-4F1B-BBA9-E4A0FE1873AF}']
  procedure SetIPAddress(IPAddress: String); stdcall;
  function GetIPAddress: String; stdcall;
  procedure SetPassword(Password: String); stdcall;
  function GetPassword: String; stdcall; stdcall;
  procedure SetNumber(Number: String); stdcall;
  function GetNumber: String; stdcall; stdcall;
  procedure SetMenuTitle(MenuTitle: String); stdcall;
  function GetMenuTitle: String; stdcall; stdcall;
  function GetMenus(): TCSTAMenus; stdcall;
  procedure AddMenu(MenuType: TCSTAMenuType; Text: String; ShortKey: Integer; OnSelect: TScriptID); stdcall;
  procedure RemoveMenu(Index: Integer); stdcall;
  function GetKeys(): TCSTAKeys; stdcall;
  procedure AddKey(Key: Integer; OnPress: TScriptID); stdcall;
  procedure RemoveKey(Index: Integer); stdcall;
  //Actions
  function GetLoginStatus: Boolean; stdcall;
  procedure UpdateMenuText(Index: Integer; Text: String); stdcall;
 end;

 TModBusGatewayMode = (gmTCP, gmRTU, gmRTUoverTCP);

 IIPSModBusPLC = interface(IInvokable)
  ['{A5F663AB-C400-4FE5-B207-4D67CC030564}']
 end;

 TModBusDataType = (vBit, vByte, vWord, vDWord, vShortInt, vSmallInt, vInteger, vReal); 

 IIPSModBusAddress = interface(IInvokable)
  ['{CB197E50-273D-4535-8C91-BB35273E3CA5}']
  procedure RequestRead; stdcall;
  procedure WriteCoil(Value: Boolean); stdcall;
  procedure WriteRegisterByte(Value: Byte); stdcall;
  procedure WriteRegisterWord(Value: Word); stdcall;
  procedure WriteRegisterDWord(Value: DWord); stdcall;
  procedure WriteRegisterShortInt(Value: ShortInt); stdcall;
  procedure WriteRegisterSmallInt(Value: SmallInt); stdcall;
  procedure WriteRegisterInteger(Value: Integer); stdcall;
  procedure WriteRegisterReal(Value: Double); stdcall;
 end;

 //Extracted from nodavecomponent.pas (part of the LibNoDave library)
  TNoDaveProtocol = (                                           //The type of the communication-protocol for the TNoDave-Component.
                      daveProtoMPI,                             //MPI-Protocol
                      daveProtoMPI2,                            //MPI-Protocol (Andrew's version without STX)
                      daveProtoMPI3,                            //MPI-Protocol (Step 7 Version version)
                      daveProtoMPI4,                            //MPI-Protocol (Andrew's version with STX)
                      daveProtoPPI,                             //PPI-Protocol
                      daveProtoISOTCP,                          //ISO over TCP
                      daveProtoISOTCP243,                       //ISO over TCP (for CP243)
                      daveProtoIBH,                             //IBH-Link TCP/MPI-Adapter
                      daveProtoIBH_PPI,                         //IBH-Link TCP/MPI-Adapter with PPI-Protocol
                      daveProtoS7Online,                        //use S7Onlinx.dll for transport via Siemens CP
                      daveProtoAS511,                           //S5 via programmer-port
                      daveProtoNLPro                            //Deltalogic NetLink-PRO TCP/MPI-Adapter
  );

  TNoDaveSpeed = (                                              //The speed of the MPI-protocol for the TNoDave-Component.
                   daveSpeed9k,
                   daveSpeed19k,
                   daveSpeed187k,
                   daveSpeed500k,
                   daveSpeed1500k,
                   daveSpeed45k,
                   daveSpeed93k
  );

 IIPSSiemensPLC = interface(IInvokable)
  ['{1B0A36F7-343F-42F3-8181-0748819FB324}']
 end;

  TNoDaveArea = (                                               //The area of the PLC-Data for the TNoDave-Component.
                  daveSysInfo,                                  //System information of 200 family
                  daveSysFlags,                                 //System flag area of 200 family
                  daveAnaIn,                                    //Analog input words of 200 family
                  daveAnaOut,                                   //Analog output words of 200 family
                  daveInputs,                                   //Input memory image
                  daveOutputs,                                  //Output memory image
                  daveFlags,                                    //Flags/Markers
                  daveDB,                                       //Data Blocks (global data)
                  daveDI,                                       //Data Blocks (instance data) ?
                  daveLocal,                                    //Data Blocks (local data) ?
                  daveV,                                        //unknown Area
                  daveCounter,                                  //Counter
                  daveTimer,                                    //Timer
                  daveP                                         //Peripherie Input/Output
  );

 TSiemensDataType = (sBit, sByte, sWord, sDWord, sShortInt, sSmallInt, sInteger, sReal); 

 IIPSSiemensAddress = interface(IInvokable)
  ['{932076B1-B18E-4AB6-AB6D-275ED30B62DB}']
  procedure RequestRead; stdcall;
  procedure WriteBit(Value: Boolean); stdcall;
  procedure WriteByte(Value: Byte); stdcall;
  procedure WriteWord(Value: Word); stdcall;
  procedure WriteDWord(Value: DWord); stdcall;
  procedure WriteShortInt(Value: ShortInt); stdcall;
  procedure WriteSmallInt(Value: SmallInt); stdcall;
  procedure WriteInteger(Value: Integer); stdcall;
  procedure WriteReal(Value: Double); stdcall;
 end;

 TEnOceanDataTX = class(TIPSRemotable)
  private
   FDevice     : Byte;
   FStatus     : Byte;
   FDeviceID   : Cardinal; //4 Bytes - Only Lower 7 Bits are relevant
   FDataByte3  : Byte;
   FDataByte2  : Byte;
   FDataByte1  : Byte;
   FDataByte0  : Byte;
  published
   property Device     : Byte read FDevice write FDevice;
   property Status     : Byte read FStatus write FStatus;
   property DeviceID   : Cardinal read FDeviceID write FDeviceID;
   property DataByte3  : Byte read FDataByte3 write FDataByte3;
   property DataByte2  : Byte read FDataByte2 write FDataByte2;
   property DataByte1  : Byte read FDataByte1 write FDataByte1;
   property DataByte0  : Byte read FDataByte0 write FDataByte0;
 end;

 TEnOceanDataRX = class(TIPSRemotable)
  private
   FDevice     : Byte;
   FStatus     : Byte;
   FDeviceID   : Cardinal; //4 Bytes
   FDataByte3  : Byte;
   FDataByte2  : Byte;
   FDataByte1  : Byte;
   FDataByte0  : Byte;
  published
   property Device     : Byte read FDevice write FDevice;
   property Status     : Byte read FStatus write FStatus;
   property DeviceID   : Cardinal read FDeviceID write FDeviceID;
   property DataByte3  : Byte read FDataByte3 write FDataByte3;
   property DataByte2  : Byte read FDataByte2 write FDataByte2;
   property DataByte1  : Byte read FDataByte1 write FDataByte1;
   property DataByte0  : Byte read FDataByte0 write FDataByte0;
 end;

 TEnoGatewayMode = (egmESP2_Binary, egmESP2_ASCII, egmESP3_Binary);
 
 IIPSEnOceanGateway = interface(IInvokable)
  ['{A52FEFE9-7858-4B8E-A96E-26E15CB944F7}']
 end;

 IIPSEnOceanModule = interface(IInvokable)
  ['{6B721E6D-9254-40FA-A97C-20B91F62D448}']
 end;

 IIPSEnOceanHoppe = interface(IIPSEnOceanModule)
  ['{1C8D7E80-3ED1-4117-BB53-9C5F61B1BEF3}']
 end;

 IIPSEnOceanPTM200 = interface(IIPSEnOceanModule)
  ['{40C99CC9-EC04-49C8-BB9B-73E21B6FA265}']
 end;

 IIPSEnOceanSTM100 = interface(IIPSEnOceanModule)
  ['{FA1479DE-C0C1-433D-98BC-EA7C298D1AA5}']
 end;

 IIPSEnOceanSTM250 = interface(IIPSEnOceanModule)
  ['{B01DE819-EA69-4FC1-91AB-4D9FF8D55370}']
 end;

 TEnoButtonMode = (btnmLeft, btnmRight);

 IIPSEnOceanPTM200RX = interface(IIPSEnOceanModule)
  ['{63484585-F8AD-4780-BAFD-3C0353641046}']
 end;

 IIPSEnOceanThanos = interface(IIPSEnOceanModule)
  ['{54E114A3-F9B6-4747-A07E-D2A064629627}']
  procedure SendLearn; stdcall;
  procedure SetTemperature1(Temperature: Double); stdcall;
  procedure SetActiveMessage(Message: Integer); stdcall;
  procedure SetRoomOccupancy(Occupied: Boolean); stdcall;
  procedure SetLockRoomOccupancy(Locked: Boolean); stdcall;
  procedure SetLockFanStage(Locked: Boolean); stdcall;
 end;
 
 IIPSXBeeGateway = interface(IInvokable)
  ['{7FA47C08-E31B-44A6-9E50-20C4DDD3E081}']
  procedure SendBuffer(DestinationDevice: Integer; Buffer: String); stdcall;
  procedure SendCommand(Command: String); stdcall;
 end;

 IIPSXBeeSplitter = interface(IInvokable)
  ['{9D5DCE79-1A97-4531-9D10-68839F4BEAAC}']
 end;

 TEnoSendMode =(smNMessage, smUMessage, smBoth);
                                                                                 
 IIPSEnOceanRCM100 = interface(IIPSEnOceanModule)
  ['{8492CEAF-ED62-4634-8A2F-B09A7CEDDE5B}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure SwitchModeEx(DeviceOn: Boolean; SendMode: TEnoSendMode); stdcall;
 end;

 IIPSEnOceanEltakoSwitch = interface(IIPSEnOceanModule)
  ['{FD46DA33-724B-489E-A931-C00BFD0166C9}']
  procedure SendLearn; stdcall;
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
//  procedure SwitchModeEx(DeviceOn: Boolean; SendMode: TEnoSendMode); stdcall;
 end;

 IIPSEnOceanEltakoDimmer = interface(IIPSEnOceanEltakoSwitch)
  ['{48909406-A2B9-4990-934F-28B9A80CD079}']
  procedure DimSet(Intensity: Integer); stdcall;
 end;

 IIPSEnOceanOpus = interface(IIPSEnOceanRCM100)
  ['{9B1F32CD-CD74-409A-9820-E5FFF064449A}']
  procedure SetIntensity(DeviceOn: Boolean; Intensity: Integer); stdcall;
 end;

 IIPSEnOceanThermokon = interface(IIPSEnOceanModule)
  ['{B4249BC6-5BA8-45E3-B506-86680935D4EE}']
 end;
 
 IIPSEnOceanEltakoFSS12 = interface(IIPSEnOceanModule)
  ['{7124C1BC-B260-4C5E-BF00-B38D3C7B5CB7}']
 end; 

 IIPSEnOceanEltakoFAH60 = interface(IIPSEnOceanModule)
  ['{AF827EB8-08A3-434D-9690-424AFF06C698}']
 end; 

 IIPSEnOceanEltakoFAFT60 = interface(IIPSEnOceanModule)
  ['{0BE195DC-6002-4D99-A566-3B9B0B57FAD6}']
 end;

 IIPSVelleUSB = interface(IInvokable)
  ['{8CE70CD0-6674-4907-B3CE-F6E5235C9938}']
  function ReadAnalogChannel(Channel: Integer): Integer; stdcall;
  procedure WriteAnalogChannel(Channel: Integer; Value: Integer); stdcall;
  //--------------
  function ReadDigital(): Integer; stdcall;
  procedure WriteDigital(Value: Integer); stdcall;
  function ReadDigitalChannel(Channel: Integer): Boolean; stdcall;
  procedure WriteDigitalChannel(Channel: Integer; Value: Boolean); stdcall;
  //--------------
  function ReadCounter(Counter: Integer): Integer; stdcall;
  procedure ResetCounter(Counter: Integer); stdcall;
  procedure SetCounterDebounceTime(Counter, Time: Integer); stdcall;
 end;

 IIPSMF420IRCTF = interface(IInvokable)
  ['{1599A33E-1A39-4DB3-904C-C88DAADB33EF}']
  procedure UpdateValues(); stdcall;
 end;

 IIPSLevelJet = interface(IInvokable)
  ['{D64B904C-5312-443C-A2F3-03201ED9811C}']
 end;

 IIPSThermoJet = interface(IInvokable)
  ['{C3380B6E-2351-4A19-9668-A17960F97E51}']
 end;

 IIPSUVR1611 = interface(IInvokable)
  ['{0A8F9D69-E78B-4EAB-8E26-C8A4ACF7FA25}']
  procedure UpdateValues(); stdcall;
 end;

 IIPSDog = interface(IInvokable)
  ['{B5F1C151-16DA-4EEA-962A-92D620FB47E6}']
  procedure SendCommand(Data: String); stdcall;
  procedure SetMenu(Position: Integer; Line1, Line2: String; Comma, Min, Max, StepSize: Integer; _Unit: String); stdcall;
  procedure SetMenuText(Position: Integer; Line: String); stdcall;
  procedure SetInfoText(Position: Integer; Line1, Line2: String); stdcall;
  procedure SetInfoTextPosition(ShowPosition: Integer); stdcall;
  procedure SetInfoTextRotation(Speed: Integer); stdcall;
  procedure SetBacklight(BacklightOn: Boolean); stdcall;
  procedure ReadTemperature; stdcall;
 end;

 TShutterType = (stShutter, stMarquee);
 TDrivePosition = (dpOpen, dpHalf, dpDown, dpClose);
 TDriveDirection = (ddStop, ddUp, ddDown);
 TDriveValues = Array[0..3] of Double;

 TDriveDownTimings = class(TIPSRemotable)
  private
   FHalf  : Double;
   FDown  : Double;
   FClose : Double;
  published
   property Half  : Double read FHalf write FHalf;
   property Down  : Double read FDown write FDown;
   property Close : Double read FClose write FClose;
 end;

 TDriveUpTimings = class(TIPSRemotable)
  private
   FDown  : Double;
   FHalf  : Double;
   FOpen  : Double;
  published
   property Open  : Double read FOpen write FOpen;
   property Down  : Double read FDown write FDown;
   property Half  : Double read FHalf write FHalf;
 end;

 IIPSShutterControl = interface(IInvokable)
  ['{542CC907-CA63-4E7A-A8C7-92F74639FA4C}']
  procedure SetTransmitDevice(DeviceID: Integer); stdcall;
  procedure SetTransmitDevice2(DeviceID: Integer); stdcall;
  procedure SetShutterType(_Type: TShutterType); stdcall;
  procedure SetDriveDownTimings(Half, Down, Close: Double); stdcall;
  procedure SetDriveUpTimings(Down, Half, Open: Double); stdcall;
  procedure SetMotorDelay(Milliseconds: Integer); stdcall;
  procedure SetHandlerScript(ScriptID: Integer); stdcall;
  function GetTransmitDevice: Integer; stdcall;
  function GetTransmitDevice2: Integer; stdcall;
  function GetShutterType: TShutterType; stdcall;
  function GetDriveDownTimings: TDriveDownTimings; stdcall;
  function GetDriveUpTimings: TDriveUpTimings; stdcall;
  function GetMotorDelay: Integer; stdcall;
  function GetHandlerScript: Integer; stdcall;
  //Actions
  procedure Move(Position: Integer); stdcall;
  procedure MoveDown(Duration: Integer); stdcall;
  procedure MoveUp(Duration: Integer); stdcall;
  procedure Stop(); stdcall;
 end;

 TIPSStatusEvent = class(TIPSRemotable)
  private
   FDeviceID: TInstanceID;
   FScriptID: TScriptID;
  published
   property DeviceID: TInstanceID read FDeviceID write FDeviceID;
   property ScriptID : TScriptID read FScriptID write FScriptID;
 end;
 TIPSStatusEvents = Array of TIPSStatusEvent;

 IIPSEventControl = interface(IInvokable)
  ['{ED573B53-8991-4866-B28C-CBE44C59A2DA}']
  procedure SetStartupScript(Script: Integer); stdcall;
  function GetStartupScript: Integer; stdcall;
  procedure SetShutdownScript(Script: Integer); stdcall;
  function GetShutdownScript: Integer; stdcall;
  procedure SetWatchdogScript(Script: Integer); stdcall;
  function GetWatchdogScript: Integer; stdcall;
  //Events
  procedure AddStatusEvent(DeviceID: TInstanceID; ScriptID: TScriptID); stdcall;
  procedure DeleteStatusEvent(DeviceID: TInstanceID); stdcall;
  function GetStatusEvent: TIPSStatusEvents; stdcall;
 end;

 TEIBGatewayMode = (gmFT12, gmIP, gmFT12overTCP);

 IIPSEIBGateway = interface(IInvokable)
  ['{1C902193-B044-43B8-9433-419F09C641B8}']
  procedure RequestInfo; stdcall;
 end;

 TEIBGroupAddress = class(TIPSRemotable)
  private
   FGA1: Integer;
   FGA2: Integer;
   FGA3: Integer;
  published
   property GA1 : Integer read FGA1 write FGA1;
   property GA2 : Integer read FGA2 write FGA2;
   property GA3 : Integer read FGA3 write FGA3;
 end;
 TEIBGroupAddresses = Array of TEIBGroupAddress;

 TEIBGroupCapability = (egcReceive, egcRead, egcTransmit, egcWrite);
 TEIBGroupCapabilities = Array of TEIBGroupCapability;

 IIPSEIBGroup = interface(IInvokable)
  ['{D62B95D3-0C5E-406E-B1D9-8D102E50F64B}']
  procedure SetGroupAddress(GA1, GA2, GA3: Integer); stdcall;
  procedure SetGroupFunction(Function_: String); stdcall;
  procedure SetGroupInterpretation(Interpretation: String); stdcall;
  procedure SetGroupCapabilities(Capabilities: TEIBGroupCapabilities); stdcall;
  function GetGroupAddress: TEIBGroupAddress; stdcall;
  function GetGroupFunction: String; stdcall;
  function GetGroupInterpretation: String; stdcall;
  function GetGroupCapabilities: TEIBGroupCapabilities; stdcall;
  procedure AddGroupMapping(GA1, GA2, GA3: Integer); stdcall;
  procedure RemoveGroupMapping(GA1, GA2, GA3: Integer); stdcall;
  function GetGroupMapping: TEIBGroupAddresses; stdcall;
  //Actions
  procedure Switch(Value: Boolean); stdcall;
  procedure DimControl(Value: Integer); stdcall;
  procedure DimValue(Value: Integer); stdcall;
  procedure Value(Value: Double); stdcall;
  procedure Scale(Value: Integer); stdcall;
  procedure DriveMove(Value: Boolean); stdcall;
  procedure DriveStep(Value: Boolean); stdcall;
  procedure DriveShutterValue(Value: Integer); stdcall;
  procedure DriveBladeValue(Value: Integer); stdcall;
  procedure PriorityPosition(Value: Boolean); stdcall;
  procedure PriorityControl(Value: Integer); stdcall;
  procedure FloatValue(Value: Double); stdcall;
  procedure Counter8bit(Value: Integer); stdcall;
  procedure Counter16bit(Value: Integer); stdcall;
  procedure Counter32bit(Value: Integer); stdcall;
  procedure Time(Value: String); stdcall;
  procedure Date(Value: String); stdcall;
  procedure Char(Value: String); stdcall;
  procedure Str(Value: String); stdcall;
  procedure RequestStatus; stdcall;
 end;

 TEIBMoveCommand = (emcOpen, emcStepOpen, emcStop, emcStepClose, emcClose);

 IIPSEIBShutter = interface(IInvokable)
  ['{24A9D68D-7B98-4D74-9BAE-3645D435A9EF}']
  procedure SetGroupAddressMove(GA1, GA2, GA3: Integer); stdcall;
  procedure SetGroupAddressStep(GA1, GA2, GA3: Integer); stdcall;
  procedure SetGroupAddressStop(GA1, GA2, GA3: Integer); stdcall;
  procedure SetGroupAddressPositionWrite(GA1, GA2, GA3: Integer); stdcall;
  procedure SetGroupAddressPositionRead(GA1, GA2, GA3: Integer); stdcall;
  function GetGroupAddressMove: TEIBGroupAddress; stdcall;
  function GetGroupAddressStep: TEIBGroupAddress; stdcall;
  function GetGroupAddressStop: TEIBGroupAddress; stdcall;
  function GetGroupAddressPositionWrite: TEIBGroupAddress; stdcall;
  function GetGroupAddressPositionRead: TEIBGroupAddress; stdcall;
  //Actions
  procedure Move(Command: TEIBMoveCommand); stdcall;
  procedure Position(Position: Integer); stdcall;
  procedure RequestStatus; stdcall;
 end;

 TEIBGroup = class(TIPSRemotable)
  private
   FGroupAddress: TEIBGroupAddress;
   FMainGroupName: String;
   FMiddleGroupName: String;
   FGroupName: String;
   FGroupFunction: String;
   FGroupInterpretation: String;
   FExtraAddresses: TEIBGroupAddresses;
   FInstanceID: TInstanceID; //Search Status
   FInstanceFunction: String;
   FInstanceInterpretation: String;
  public
   destructor Destroy; override; 
  published
   property GroupAddress: TEIBGroupAddress read FGroupAddress write FGroupAddress;
   property MainGroupName: String read FMainGroupName write FMainGroupName;
   property MiddleGroupName: String read FMiddleGroupName write FMiddleGroupName;
   property GroupName: String read FGroupName write FGroupName;
   property GroupFunction: String read FGroupFunction write FGroupFunction;
   property GroupInterpretation: String read FGroupInterpretation write FGroupInterpretation;
   property ExtraAddresses: TEIBGroupAddresses read FExtraAddresses write FExtraAddresses;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
   property InstanceFunction: String read FInstanceFunction write FInstanceFunction;
   property InstanceInterpretation: String read FInstanceInterpretation write FInstanceInterpretation;
 end;
 TEIBGroups = Array of TEIBGroup;

 IIPSEIBConfigurator = interface(IInvokable)
 ['{33765ABB-CFA5-40AA-89C0-A7CEA89CFE7A}']
  procedure SearchDevices(); stdcall;
  function GetKnownDevices(): TEIBGroups; stdcall;
  procedure UploadDataPointFile(Content: String); stdcall;
 end;

 IIPSdSSplitter = interface(IInvokable)
 ['{8D7872F4-CAC3-409D-926B-CCF1BA9E937B}']
  procedure RequestToken(Username: String; Password: String); stdcall;
 end;

 TdSDevice = class(TIPSRemotable)
  private
   FID: String;
   FName: String;
   FMeterName: String;
   FRoomName: String;
   FFunctionID: Integer;
   FInstanceID: TInstanceID; //Search Status
  published
   property ID: String read FID write FID;
   property Name: String read FName write FName;
   property MeterName: String read FMeterName write FMeterName;
   property RoomName: String read FRoomName write FRoomName;
   property FunctionID: Integer read FFunctionID write FFunctionID;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TdSDevices = Array of TdSDevice;

 IIPSdSConfigurator = interface(IInvokable)
 ['{7CADC358-60B0-4D91-9825-27E9029B62C4}']
  function GetKnownDevices(): TdSDevices; stdcall;
 end;
 
 IIPSdSDevice = interface(IInvokable)
  ['{47C3099F-D072-4B6D-B9A9-85EBF873EC9D}']
 end;

 IIPSdSLight = interface(IIPSdSDevice)
  ['{DB54D0DB-64C3-4930-9B53-2337183C9C1D}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure DimSet(Intensity: Integer); stdcall;
 end;

 IIPSdSShutter = interface(IIPSdSDevice)
  ['{3DDA1E2B-B807-4680-AB6D-E7E8FBD6093A}']
  procedure ShutterMove(Position: Integer); stdcall;
  procedure ShutterMoveDown(); stdcall;
  procedure ShutterMoveUp(); stdcall;
  procedure ShutterStop(); stdcall;
 end;

 TOZWDevice = class(TIPSRemotable)
  private
   FName: String;
   FType: String;
   FAddress: String;
   FSerialNumber: String;
   FInstanceID: TInstanceID; //Search Status
  published
   property Name: String read FName write FName;
   property Type_: String read FType write FType;
   property Address: String read FAddress write FAddress;
   property SerialNumber: String read FSerialNumber write FSerialNumber;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TOZWDevices = Array of TOZWDevice;

 IIPSOZWSplitter = interface(IInvokable)
  ['{1D60A51E-FF04-4D82-9E0D-04B3A11EF13F}']
 end;

 IIPSOZWConfigurator = interface(IInvokable)
  ['{62BDA2F6-6206-4DC3-9431-4328B5890836}']
  function GetKnownDevices(): TOZWDevices; stdcall;
 end;

 TOZWItemType = (itMenu, itDataPoint);

 TOZWItem = class(TIPSRemotable)
  private
   FID: Integer;
   FName: String;
   FWriteAccess: Boolean;
   FType: TOZWItemType;
   FInstanceID: TInstanceID; //Search Status
  published
   property ID: Integer read FID write FID;
   property Name: String read FName write FName;
   property WriteAccess: Boolean read FWriteAccess write FWriteAccess;
   property Type_: TOZWItemType read FType write FType;
   property InstanceID: TInstanceID read FInstanceID write FInstanceID;
 end;
 TOZWItems = Array of TOZWItem;
 
 IIPSOZWDevice = interface(IInvokable)
  ['{CE54AFB0-625A-4F37-B5C1-EAF1FD2A1DA6}']
  function GetKnownItems(RootID: Integer): TOZWItems; stdcall;
 end;

 IIPSOZWDataPoint = interface(IInvokable)
  ['{422A36CD-5565-4CDC-9FC4-242D3C810901}']
  procedure WriteDataPoint(Value: Variant); stdcall;
  procedure RequestStatus; stdcall;
 end;

const
 ZWAVE_BASE = IPS_MODULEBASE + 1000;

 ZWAVE_UPDATE_NOTIFY = ZWAVE_BASE;

 ZWAVE_ADDNOTIFY_READY = ZWAVE_BASE + 1;
 ZWAVE_ADDNOTIFY_ERROR = ZWAVE_BASE + 2;
 ZWAVE_ADDNOTIFY_DONE = ZWAVE_BASE + 3;
 ZWAVE_ADDNOTIFY_PROTOCOL_DONE = ZWAVE_BASE + 4;

 ZWAVE_REMOVENOTIFY_READY = ZWAVE_BASE + 5;
 ZWAVE_REMOVENOTIFY_ERROR = ZWAVE_BASE + 6;
 ZWAVE_REMOVENOTIFY_DONE = ZWAVE_BASE + 7;

type
 TZWCapability = (zcPrimaryController, zcSecondaryController, zcIsSUC, zcHasSIS);
 TZWCapabilities = Array of TZWCapability;

 TZWType = (ztStaticController, ztBrigdeController, ztPortableController,
            ztSlaveEnhanced, ztSlaveRouting, ztSlave, ztInstaller);

 TZWDevice = class(TIPSRemotable)
  private
   FNodeID: Integer;
   FBasicClass: Integer;
   FGenericClass: Integer;
   FSpecificClass: Integer;
  published
   property NodeID : Integer read FNodeID write FNodeID;
   property BasicClass : Integer read FBasicClass write FBasicClass;
   property GenericClass : Integer read FGenericClass write FGenericClass;
   property SpecificClass : Integer read FSpecificClass write FSpecificClass;
 end;
 TZWDevices = Array of TZWDevice;

 TZWDeviceEx = class(TIPSRemotable)
  private
   FNodeID: Integer;
   FBasicClass: Integer;
   FGenericClass: Integer;
   FSpecificClass: Integer;
   FInstanceID: TInstanceID;
  published
   property NodeID : Integer read FNodeID write FNodeID;
   property BasicClass : Integer read FBasicClass write FBasicClass;
   property GenericClass : Integer read FGenericClass write FGenericClass;
   property SpecificClass : Integer read FSpecificClass write FSpecificClass;
   property InstanceID : TInstanceID read FInstanceID write FInstanceID;
 end;
 TZWDevicesEx = Array of TZWDeviceEx;

 TIntegerArray = Array of Integer;

 IIPSZWaveGateway = interface(IInvokable)
  ['{4EF72D56-BF9F-4347-8F0A-2035D241116F}']
  //Actions
  function GetHomeID: String; stdcall;
  function GetNodeID: Integer; stdcall;
  function GetSUCID: Integer; stdcall;
  function GetVersion: String; stdcall;
  function GetCapabilities: TZWCapabilities; stdcall;
  function GetType: TZWType; stdcall;
  function GetDevices: TZWDevices; stdcall;
  //Actions
  procedure RequestInfo(); stdcall;
  procedure ResetToDefault(); stdcall;
  function RoutingGetNodes(NodeID: Integer): TIntegerArray; stdcall;
  function RoutingTestNode(NodeID: Integer): Boolean; stdcall;
  procedure RoutingOptimizeNode(NodeID: Integer); stdcall;
  procedure RoutingOptimize(); stdcall;
  procedure RoutingAssignReturnRoute(NodeID: Integer); stdcall;
  procedure CheckCapability(Cap: TZWCapability); stdcall;
 end;

 TDeviceClasses = Array of Integer;

 TZWBasicResponse = class(TIPSRemotable)
  private
   FEnabled: Boolean;
   FData: Integer;
  published
   property Enabled : Boolean read FEnabled write FEnabled;
   property Data : Integer read FData write FData;
 end;

 TZWDeviceVersion = class(TIPSRemotable)
  private
   FLibraryType: TZWType;
   FProtocolVersion: String;
   FApplicationVersion: String;
  published
   property LibraryType : TZWType read FLibraryType write FLibraryType;
   property ProtocolVersion : String read FProtocolVersion write FProtocolVersion;
   property ApplicationVersion : String read FApplicationVersion write FApplicationVersion;
 end; 

 TZWProtection = (pOff, pLimited, pOn);

 TZWThermostatMode = (tmOff, tmHeat, tmCool, tmAuto, tmAuxiliary, tmResume, tmFanOnly, tmFurnace, tmDryAir, tmMoistAir, tmAutoChangeover);
 TZWThermostatSetPoint = (tspInvalid, tspHeating, tspCooling, tspFurnace, tspDryAir, tspMoistAir, tspAutoChangeover);
 TZWThermostatFanMode = (tfmAutoLow, tfmOnLow, tfmAutoHigh, tfmOnHigh);

 //Proprietary
 TZWPulseThermostatMode = (ptmHeat, ptmCool, ptmAutoChangeover);
 TZWPulseThermostatSetPoint = (ptspNormalHeat, ptspNormalCool, ptspNormalAuto, ptspEconomyHeat, ptspEconomyCool, ptspEconomyAutoHeat, ptspEconomyAutoCool);
 TZWPulseThermostatFanMode = (ptfmAuto, ptfmLow, ptfmMedium, ptfmHigh, ptfmOff);
 TZWPulseThermostatPowerMode = (ptpmOff, ptpmNormal, ptpmEconomy);

 IIPSZWaveModule = interface(IInvokable)
  ['{101352E1-88C7-4F16-998B-E20D50779AF6}']
  procedure SetNodeID(Value: Integer); stdcall;
  function GetNodeID(): Integer; stdcall;
  procedure SetEnforceBasicClass(Enabled: Boolean); stdcall;
  function GetEnforceBasicClass: Boolean; stdcall;
  procedure SetEnableSceneActivationClass(Enabled: Boolean); stdcall;
  function GetEnableSceneActivationClass: Boolean; stdcall;
  procedure SetMultiInstanceID(ID: Integer); stdcall;
  function GetMultiInstanceID(): Integer; stdcall;
  //Read only information
  function GetNodeClasses(): TDeviceClasses; stdcall;
  function GetMultiInstanceCount(): Integer; stdcall;
  function GetMultiInstanceClasses(): TDeviceClasses; stdcall;
  //Associations
  procedure RequestAssociations; stdcall;
  function AssociationGetGroupCount: Integer; stdcall;
  function AssociationGetGroupMaxNodes(Group: Integer): Integer; stdcall;
  function AssociationGetGroupNodes(Group: Integer): TIntegerArray; stdcall;
  procedure AssociationAddToGroup(Group, Node: Integer); stdcall;
  procedure AssociationRemoveFromGroup(Group, Node: Integer); stdcall;
  //Configuration
  function ConfigurationGetValue(Parameter: Integer): Integer; stdcall;
  procedure ConfigurationSetValue(Parameter: Integer; Value: Integer); stdcall;
  procedure ConfigurationResetValue(Parameter: Integer); stdcall;
  //WakeUp
  procedure RequestWakeUpInterval; stdcall;
  function WakeUpGetInterval(): Integer; stdcall;
  procedure WakeUpSetInterval(Seconds: Integer); stdcall;
  //Version
  function RequestVersion(): TZWDeviceVersion; stdcall;
  //Status
  procedure RequestStatus(); stdcall;
  procedure RequestInfo(); stdcall;
  //Actions
  procedure Basic(Value: Integer); stdcall;
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure DimSet(Intensity: Integer); stdcall;
  procedure DimStop(); stdcall;
  procedure ShutterMoveDown(); stdcall;
  procedure ShutterMoveUp(); stdcall;
  procedure ShutterStop(); stdcall;
  procedure ProtectionSet(Mode: TZWProtection); stdcall;
  procedure MeterReset(); stdcall;
  procedure ThermostatModeSet(Mode: TZWThermostatMode); stdcall;
  procedure ThermostatSetPointSet(SetPoint: TZWThermostatSetPoint; Value: Double); stdcall;
  procedure ThermostatFanModeSet(FanMode: TZWThermostatFanMode); stdcall;
  //Actions for Proprietary Devices
  procedure PulseThermostatModeSet(Mode: TZWPulseThermostatMode); stdcall;
  procedure PulseThermostatSetPointSet(SetPoint: TZWPulseThermostatSetPoint; Value: Double); stdcall;
  procedure PulseThermostatFanModeSet(FanMode: TZWPulseThermostatFanMode); stdcall;
  procedure PulseThermostatPowerModeSet(PowerMode: TZWPulseThermostatPowerMode); stdcall;
 end;

 IIPSZWaveConfigurator = interface(IInvokable)
 ['{2D7CA355-2C51-4430-8F67-4E397EAAEA19}']
  procedure SearchDevices(); stdcall;
  function GetKnownDevices(): TZWDevicesEx; stdcall;
  //Actions
  procedure StartAddDevice(); stdcall;
  procedure StopAddDevice(); stdcall;
  procedure StartRemoveDevice(); stdcall;
  procedure StopRemoveDevice(); stdcall;
  procedure StartAddNewPrimaryController(); stdcall;
  procedure StopAddNewPrimaryController(); stdcall;
 end;

 TIPSWMRS200DeviceType = (wmrdtUnknown,
                          wmrdtWind,
                          wmrdtRain,
                          wmrdtBarometer,
                          wmrdtTH,
                          wmrdtUV);

 TWMRS200Device = record
  DeviceType : TIPSWMRS200DeviceType;
  DeviceID   : Integer;
 end;
                          
 IIPSWMRS200 = interface(IInvokable)
  ['{DD2A4676-82C6-4154-9AAD-DE30668D53B0}']
 end;

 IIPSWMRS200Receiver = interface(IInvokable)
  ['{E4FDC411-95D5-453C-B731-0CEB0483E663}']
 end;

{
 TStartEndTime = record
  StartTime: Integer;
  EndTime  : Integer;
 end;
}
 TStartEndTime = class(TIPSRemotable)
  private
   FStartTime: Integer;
   FEndTime  : Integer;
  published
   property StartTime : Integer read FStartTime write FStartTime;
   property EndTime : Integer read FEndTime write FEndTime;
 end;

 TStartEndTimes = Array of TStartEndTime;

 TIPSAggregationSpan = (agHour, agDay, agWeek, agMonth, agYear, ag5Minutes, ag1Minute);
 TIPSAggregationType = (asGauge, asCounter);

 TIPSAggregationValue = class(TIPSRemotable)
  private
   FTimeStamp: Integer;
   FLastTime: Integer;
   FDuration: Integer;
   FMin: Double;
   FMinTime: Integer;
   FAvg: Double;
   FMax: Double;
   FMaxTime: Integer;
  published
   property TimeStamp: Integer read FTimeStamp write FTimeStamp;
   property LastTime: Integer read FLastTime write FLastTime;
   property Duration: Integer read FDuration write FDuration;
   property Min: Double read FMin write FMin;
   property MinTime: Integer read FMinTime write FMinTime;
   property Avg: Double read FAvg write FAvg;
   property Max: Double read FMax write FMax;
   property MaxTime: Integer read FMaxTime write FMaxTime;
 end;
 TIPSAggregationValues = Array of TIPSAggregationValue;

 TIPSLoggedValue = class(TIPSRemotable)
  private
   FTimeStamp: Integer;
   FLastTime: Integer;
   FDuration: Integer;
   FValue: Variant;
  published
   property TimeStamp: Integer read FTimeStamp write FTimeStamp;
   property LastTime: Integer read FLastTime write FLastTime;
   property Duration: Integer read FDuration write FDuration;
   property Value: Variant read FValue write FValue;
 end;
 TIPSLoggedValues = Array of TIPSLoggedValue;

 TIPSAggregationVariable = class(TIPSRemotable)
  private
   FVariableID: TVariableID;
   FAggregationType: TIPSAggregationType;
   FAggregationActive: Boolean;
   FFirstTime: Integer;
   FLastTime: Integer;
   FRecordCount: Integer;
  published
   property VariableID: TVariableID read FVariableID write FVariableID;
   property AggregationType: TIPSAggregationType read FAggregationType write FAggregationType;
   property AggregationActive: Boolean read FAggregationActive write FAggregationActive;
   property FirstTime: Integer read FFirstTime write FFirstTime;
   property LastTime: Integer read FLastTime write FLastTime;
   property RecordCount: Integer read FRecordCount write FRecordCount;
 end;
 TIPSAggregationVariables = Array of TIPSAggregationVariable;

 IIPSArchiveControl = interface(IInvokable)
  ['{43192F0B-135B-4CE7-A0A7-1475603F3060}']
  procedure SetLoggingStatus(VariableID: TVariableID; Active: Boolean); stdcall;
  function GetLoggingStatus(VariableID: TVariableID): Boolean; stdcall;
  procedure SetGraphStatus(VariableID: TVariableID; Active: Boolean); stdcall;
  function GetGraphStatus(VariableID: TVariableID): Boolean; stdcall;
  procedure SetAggregationType(VariableID: TVariableID; AggregationType: TIPSAggregationType); stdcall;
  function GetAggregationType(VariableID: TVariableID): TIPSAggregationType; stdcall;

  procedure ReAggregateVariable(VariableID: TVariableID); stdcall;
  procedure ChangeVariableID(OldVariableID, NewVariableID: TVariableID); stdcall;
  procedure DeleteVariableData(VariableID: TVariableID; StartTime, EndTime: Integer); stdcall;

  function GetLoggedValues(VariableID: TVariableID; StartTime, EndTime: Integer; Limit: Integer): TIPSLoggedValues; stdcall;
  function GetAggregatedValues(VariableID: TVariableID; AggregationType: TIPSAggregationSpan; StartTime, EndTime: Integer; Limit: Integer): TIPSAggregationValues; stdcall;

  function GetAggregationVariables(QueryDatabase: Boolean): TIPSAggregationVariables; stdcall;

  {$IFDEF DEBUG}
  procedure LogVariable(VariableID: TVariableID; Value: Variant; TimeStamp: Integer; DoLog: Boolean = true; DoAggregate: Boolean = true; AggregationStatus: Byte = 0); stdcall;
  {$ENDIF}
  
  function GetHours(TS, TS_Target: Integer): TStartEndTimes; stdcall;
  function GetDays(TS, TS_Target: Integer): TStartEndTimes; stdcall;
  function GetWeeks(TS, TS_Target: Integer): TStartEndTimes; stdcall;
  function GetMonths(TS, TS_Target: Integer): TStartEndTimes; stdcall;
  function GetYears(TS, TS_Target: Integer): TStartEndTimes; stdcall;

 end;

 IIPSCGEM24 = interface(IInvokable)
  ['{2AA27F83-E4DA-48D5-86CF-613C09F1B4B5}']
  procedure RequestRead; stdcall;
 end;                                                                       

 IIPSVirtualIO = interface(IInvokable)
  ['{6179ED6A-FC31-413C-BB8E-1204150CF376}']
  //Actions
  procedure SendText(Text: String); stdcall;
  procedure PushText(Text: String); stdcall;
  procedure PushTextHEX(Text: String); stdcall;
 end;

 IIPSDummy = interface(IInvokable)
  ['{485D0419-BE97-4548-AA9C-C083EB82E61E}']
 end;

 TIPSSearchResult = class(TIPSRemotable)
  private
   FScriptID: TScriptID;
   FLineNumber: Integer;
   FLineContent: String;
   FLinePosition: Integer;
  published
   property ScriptID: TScriptID read FScriptID write FScriptID;
   property LineNumber: Integer read FLineNumber write FLineNumber;
   property LineContent: String read FLineContent write FLineContent;
   property LinePosition: Integer read FLinePosition write FLinePosition;
 end;
 TIPSSearchResults = Array of TIPSSearchResult;

 IIPSUtilsControl = interface(IInvokable)
  ['{B69010EA-96D5-46DF-B885-24821B8C8DBD}']
  procedure RenameScript(ScriptID: TScriptID; Filename: String); stdcall;
  function FindInFiles(Files: TScriptIDs; SearchStr: String): TIPSSearchResults; stdcall;
  function ReplaceInFiles(Files: TScriptIDs; SearchStr, ReplaceStr: String): TIPSSearchResults; stdcall;
 end;

 //Message
const
 WFC_BASE = IPS_MODULEBASE + 100;
 WFC_POPUP = WFC_BASE + 1;
 WFC_TEXT_NOTIFICATION = WFC_BASE + 2;
 WFC_AUDIO_NOTIFICATION = WFC_BASE + 3;
 WFC_SWITCHPAGE = WFC_BASE + 4;
 WFC_RELOAD = WFC_BASE + 5;

type
 TIPSWebFrontItem = class(TIPSRemotable)
  private
   FID: String;
   FClassName: String;
   FConfiguration: String;
   FPosition: Integer;
   FParentID: String;
   FVisible: Boolean;
  published
   property ID: String read FID write FID;
   property ClassName: String read FClassName write FClassName;
   property Configuration: String read FConfiguration write FConfiguration;
   property Position: Integer read FPosition write FPosition;
   property ParentID: String read FParentID write FParentID;
   property Visible: Boolean read FVisible write FVisible;
 end;
 TIPSWebFrontItems = Array of TIPSWebFrontItem;

 IIPSWebFrontConfigurator = interface(IInvokable)
  ['{3565B1F2-8F7B-4311-A4B6-1BF1D868F39E}']
  procedure AddItem(ID, ClassName, Configuration, ParentID: String); stdcall;
  procedure DeleteItem(ID: String); stdcall;
  procedure UpdateConfiguration(ID: String; Configuration: String); stdcall;
  procedure UpdatePosition(ID: String; Position: Integer); stdcall;
  procedure UpdateParentID(ID: String; ParentID: String); stdcall;
  procedure UpdateVisibility(ID: String; Visible: Boolean); stdcall;
  function GetItems(): TIPSWebFrontItems; stdcall;
  procedure SetItems(JSONItems: String); stdcall;
  //Actions
  procedure SendPopup(Title, Text: String); stdcall;
  procedure SendNotification(Title, Text, Icon: String; Timeout: Integer); stdcall;
  procedure PushNotification(Title, Text, Icon: String; TargetID: TIPSID); stdcall;
  procedure AudioNotification(Title: String; MediaID: TIPSID); stdcall;
  procedure SwitchPage(PageName: String); stdcall;
  procedure Reload(); stdcall;
  //RPC
  function GetSnapshot(): String; stdcall;
  function GetSnapshotEx(CategoryID: TCategoryID): String; stdcall;
  function GetSnapshotChanges(LastTimeStamp: Integer): TIPSMessages; stdcall;
  function GetSnapshotChangesEx(CategoryID: TCategoryID; LastTimeStamp: Integer): TIPSMessages; stdcall;
  function Execute(ActionID: TIPSID; TargetID: TIPSID; Value: Variant): String; stdcall;
  function GetAggregatedValues(VariableID: TVariableID; AggregationSpan: TIPSAggregationSpan; StartTime, EndTime: Integer; Limit: Integer): TIPSAggregationValues; stdcall;
 end;

 IIPSWebFrontConfiguratorEx = interface(IIPSWebFrontConfigurator)
  ['{3F61C474-1F55-40DD-9583-9069111EF810}']
  function GetMobileID(): Integer; stdcall;
 end;

 IIPSEnergyControl = interface(IInvokable)
  ['{5D316E10-DF36-4042-8338-FA26C5193DC7}']
 end;

 IIPSTestModule = interface(IInvokable)
  ['{08C4AD92-426C-462A-B6FE-AC88E2313D57}']
 end;

 IIPSProJetGateway = interface(IInvokable)
  ['{995946C3-7995-48A5-86E1-6FB16C3A0F8A}']
 end;

 IIPSProJetCounter = interface(IInvokable)
  ['{134A1CFF-3CAA-4D2E-8517-F9BFDE7544C9}']
  procedure RequestStatus(); stdcall;
 end;

 IIPSProJetDisplay = interface(IInvokable)
  ['{9542B617-C603-4E8A-BFDE-DD69663F0226}']
  procedure LCDText(Line: Integer; Text: String); stdcall;
  procedure SwitchLED(LED: Integer; Status: Boolean); stdcall;
  procedure Backlight(Status: Boolean); stdcall;
  procedure Beep(TenthOfASecond: Integer); stdcall;
 end;

 IIPSProJetDisplayOutput = interface(IInvokable)
  ['{C8CF38E9-BEAA-4149-A9ED-C8AAE04E8A6D}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
 end;

 IIPSProJetDisplayInput = interface(IInvokable)
  ['{FBF6F86C-4901-4957-8D08-2B2CBC1DF71A}']
 end;

 IIPSProJetTracker = interface(IInvokable)
  ['{50460BD9-FA93-4DE0-976A-55208C90DF15}']
 end;

 IIPSProJetInput = interface(IInvokable)
  ['{5509B26C-F2F7-428F-973B-FD5D07C80111}']
 end;

 IIPSProJetStripe = interface(IInvokable)
  ['{7AF52E55-4994-44AE-9DB8-752895F1EB76}']
  procedure SetRGBW(R, G, B, W: Integer); stdcall;
  procedure DimRGBW(R, RTime, G, GTime, B, BTime, W, WTime: Integer); stdcall;
  procedure RunProgram(Type_: Integer); stdcall;
 end;

 IIPSProJetStripeInput = interface(IInvokable)
  ['{26B22717-924E-4D58-B091-C98E49812238}']
 end;

 IIPSProJetWatchDogTimer = interface(IInvokable)
  ['{9F88A462-BFDA-47C5-990C-B9E20D2F861E}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
  procedure SwitchDuration(DeviceOn: Boolean; Duration: Integer); stdcall;
 end;

 IIPSProJetAccelerometer = interface(IInvokable)
  ['{304B6E9A-A518-43C6-80E8-D066879E7FD1}']
 end;

 IIPSProJetLevel = interface(IInvokable)
  ['{C7A069AB-E2BE-4AD2-BB51-A7B52D6FAC4E}']
  procedure RequestStatus(); stdcall;
 end;

 IIPSProJetThermo = interface(IInvokable)
  ['{95D715AA-AB5A-4423-AD7B-5081EB542971}']
  procedure RequestStatus(); stdcall;
 end;

 TIPSHeatingSetBackVariable = class(TIPSRemotable)
  private
   FVariableID: TVariableID;
   FInvert: Boolean;
  published
   property VariableID : TVariableID read FVariableID write FVariableID;
   property Invert : Boolean read FInvert write FInvert;
 end;
 TIPSHeatingSetBackVariables = Array of TIPSHeatingSetBackVariable;

 TIPSHeatingOverrideVariable = class(TIPSRemotable)
  private
   FVariableID: TVariableID;
   FInvert: Boolean;
  published
   property VariableID : TVariableID read FVariableID write FVariableID;
   property Invert : Boolean read FInvert write FInvert;
 end;
 TIPSHeatingOverrideVariables = Array of TIPSHeatingOverrideVariable;

 TIPSHeatingTransmitDevice = class(TIPSRemotable)
  private
   FDeviceID: TInstanceID;
   FInvert: Boolean;
  published
   property DeviceID: TInstanceID read FDeviceID write FDeviceID;
   property Invert : Boolean read FInvert write FInvert;
 end;
 TIPSHeatingTransmitDevices = Array of TIPSHeatingTransmitDevice;

 IIPSHeatingControl = interface(IInvokable)
  ['{3F52FA69-77F5-4DE6-8B2A-347452AC5F8F}']
  procedure SetHandlerScript(ScriptID: Integer); stdcall;
  function GetHandlerScript: Integer; stdcall;
  procedure SetHysteresis(Hysteresis: Double); stdcall;
  function GetHysteresis: Double; stdcall;
  procedure SetSetBack(SetBack: Double); stdcall;
  function GetSetBack: Double; stdcall;
  procedure SetSourceVariable(VariableID: Integer); stdcall;
  function GetSourceVariable: Integer; stdcall;
  procedure SetResendInterval(Minutes: Integer); stdcall;
  function GetResendInterval: Integer; stdcall;

  procedure AddSetBackVariable(VariableID: TVariableID; Invert: Boolean); stdcall;
  procedure DeleteSetBackVariable(VariableID: TVariableID); stdcall;
  function GetSetBackVariables: TIPSHeatingSetBackVariables; stdcall;

  procedure AddOverrideVariable(VariableID: TVariableID; Invert: Boolean); stdcall;
  procedure DeleteOverrideVariable(VariableID: TVariableID); stdcall;
  function GetOverrideVariables: TIPSHeatingOverrideVariables; stdcall;

  procedure AddTransmitDevice(DeviceID: TInstanceID; Invert: Boolean); stdcall;
  procedure DeleteTransmitDevice(DeviceID: TInstanceID); stdcall;
  function GetTransmitDevices: TIPSHeatingTransmitDevices; stdcall;

  //Action
  procedure TargetValue(Value: Double); stdcall;
 end;

 IIPSSMTP = interface(IInvokable)
  ['{375EAF21-35EF-4BC4-83B3-C780FD8BD88A}']
  procedure SendMail(Subject, Text: String); stdcall;
  procedure SendMailEx(Address, Subject, Text: String); stdcall;
  procedure SendMailAttachment(Subject, Text, Filename: String); stdcall;
  procedure SendMailAttachmentEx(Address, Subject, Text, Filename: String); stdcall;
 end;

 TIPSMail = class(TIPSRemotable)
  private
   FSenderName: String;
   FSenderAddress: String;
   FRecipient: String;
   FSubject: String;
   FDate: TDateTime;
   FUID: String;
   FFlags: String;
  published
   property SenderName : String read FSenderName write FSenderName;
   property SenderAddress : String read FSenderAddress write FSenderAddress;
   property Recipient : String read FRecipient write FRecipient;
   property Subject : String read FSubject write FSubject;
   property Date : TDateTime read FDate write FDate;
   property UID : String read FUID write FUID;
   property Flags : String read FFlags write FFlags;
 end;
 TIPSMails = Array of TIPSMail;

 TIPSMailEx = class(TIPSMail)
  private
   FContentType: String;
   FCharSet: String;
   FText: String;
  published
   property ContentType : String read FContentType write FContentType;
   property CharSet : String read FCharSet write FCharSet;
   property Text : String read FText write FText;
 end;

 IIPSPOP3 = interface(IInvokable)
  ['{69CA7DBF-5FCE-4FDF-9F36-C05E0136ECFD}']
  procedure UpdateCache; stdcall;
  function GetCachedMails(): TIPSMails; stdcall;
  function GetMailEx(UID: String): TIPSMailEx; stdcall;
 end;

 IIPSIMAP = interface(IInvokable)
  ['{CABFCCA1-FBFF-4AB7-B11B-9879E67E152F}']
  procedure UpdateCache; stdcall;
  function GetCachedMails(): TIPSMails; stdcall;
  function GetMailEx(UID: String): TIPSMailEx; stdcall;
 end;

 TImageGrabberImageType = (igctAutomatic, igctJPG, igctGIF, igctBMP, igctPNG);

 IIPSImageGrabber = interface(IInvokable)
  ['{5A5D5DBD-53AB-4826-8B09-71E9E4E981E5}']
  procedure UpdateImage(); stdcall;
 end;

 IIPSSMS = interface(IInvokable)
  ['{96102E00-FD8C-4DD3-A3C2-376A44895AB1}']
  function Send(Number, Text: String): String; stdcall;
  function RequestBalance(): Double; stdcall;
  function RequestStatus(MsgID: String): String; stdcall;
 end;

 TMBusFrame = (mbfSingle, mbfShortFrame, mbfControlFrame, mbfLongFrame);

 TIPSMBusDeviceInfo = class(TIPSRemotable)
  private
   FIdentNr: String;
   FManufacturer: String;
   FVersion: Integer;
   FMedium: Integer;
   FAccessNr: Integer;
   FStatus: Integer;
  published
   property IdentNr : String read FIdentNr write FIdentNr;
   property Manufacturer : String read FManufacturer write FManufacturer;
   property Version : Integer read FVersion write FVersion;
   property Medium : Integer read FMedium write FMedium;
   property AccessNr : Integer read FAccessNr write FAccessNr;
   property Status : Integer read FStatus write FStatus;
 end;

 IIPSMBusGateway = interface(IInvokable)
  ['{301AB802-23CD-4DE2-91D1-6E3BC9BF03FC}']
 end;

 IIPSMBusDevice = interface(IInvokable)
  ['{B53BE2E5-892D-4537-94AC-EAC68A469188}']
  procedure UpdateValues(); stdcall;
  {$IFDEF DEBUG}
  procedure ProcessPacket(Buffer: String); stdcall;
  {$ENDIF}
 end;

 IIPSWuTGateway = interface(IInvokable)
  ['{01CA6888-C833-484E-A3F3-806535421CB7}']
  procedure UpdateValue(); stdcall;
 end;

 IIPSWuTInput = interface(IInvokable)
  ['{C3D0F82C-CD07-4AA8-AE5C-7AD983FE91F3}']
 end;

 IIPSWuTOutput = interface(IInvokable)
  ['{E85C40B3-C1E9-4A60-85C7-6CDDA3D8D7BF}']
  procedure SwitchMode(DeviceOn: Boolean); stdcall;
 end;

 IIPSWuTCounter = interface(IInvokable)
  ['{5F1C5261-07A2-4A7E-9AC4-88AF9ED29420}']
 end;

 IIPSWuTThermoHygro = interface(IInvokable)
  ['{2EF634A4-D96D-4018-BD90-94E487A89D49}']
  procedure UpdateValues(); stdcall;
 end;

 TPNSProvider = (pAPNS, pGCM);

 TIPSPNSDevice = class(TIPSRemotable)
  private
   FID: Integer;
   FName: String;
   FModified: TDateTime;
   FConfigurators: TIntegerArray;
  published
   property ID : Integer read FID write FID;
   property Name : String read FName write FName;
   property Modified : TDateTime read FModified write FModified;
   property Configurators : TIntegerArray read FConfigurators write FConfigurators;
 end;
 TIPSPNSDevices = Array of TIPSPNSDevice;

 IIPSNotificationControl = interface(IInvokable)
  ['{D4B231D6-8141-4B9E-9B32-82DA3AEEAB78}']
  procedure ActivateServer(); stdcall;
  //PNS Actions
  function AddDevice(Device: String; Provider: TPNSProvider; Name: String; Configurators: String): Integer; stdcall;
  procedure RemoveDevice(DeviceID: Integer); stdcall;
  procedure TestDevice(DeviceID: Integer); stdcall;
  procedure SetDeviceName(DeviceID: Integer; Name: String); stdcall;
  procedure SetDeviceConfigurator(DeviceID: Integer; WebFrontConfiguratorID: TInstanceID; Enabled: Boolean); stdcall;
  function GetDevices(): TIPSPNSDevices; stdcall;
  procedure SendNotification(WebFrontConfiguratorID: TInstanceID; Text: String); stdcall;
 end;
 
implementation

constructor THMValue.Create(ValueType: THMType);
begin
 FValueType := ValueType;
end;

constructor THMBoolean.Create(Value: Boolean);
begin
 inherited Create(hmtBoolean);                         
 FValue := Value;
end;

constructor THMInteger.Create(Value: Integer);
begin
 inherited Create(hmtInteger);
 FValue := Value;
end;

constructor THMDouble.Create(Value: Double);
begin
 inherited Create(hmtDouble);
 FValue := Value;
end;

constructor THMString.Create(Value: String);
begin
 inherited Create(hmtString);
 FValue := Value;
end;

constructor THMStruct.Create(Name: String; Value: THMValue);
begin
 inherited Create(hmtStruct);
 FName := Name;
 FValue := Value;
end;

destructor THMStruct.Destroy;
begin
 FValue.Free;
end;

constructor THMArray.Create(Values: THMValues);
begin
 inherited Create(hmtArray);
 FValues := Values;
end;

destructor THMArray.Destroy;
var i: Integer;
begin
 for i:=0 to GetCount-1 do
  FValues[i].Free;
end;

function THMArray.GetCount: Integer;
begin
 Result := Length(FValues);
end;

function THMArray.GetValue(Index: Integer): THMValue;
begin
 Result := FValues[Index];
end;

procedure TLCNDevice.SetName1(Value: String);
begin
 FName1 := Value;
 FDeviceName := FName1 + FName2;
end;

procedure TLCNDevice.SetName2(Value: String);
begin
 FName2 := Value;
 FDeviceName := FName1 + FName2;
end;

destructor TFS20Device.Destroy;
var i: Integer;
begin
 if Self.DataContext = nil then
  for i:=0 to Length(FMapping)-1 do
   FMapping[i].Free;
end;

destructor TEIBGroup.Destroy;
var i: Integer;
begin
 if Self.DataContext = nil then
  begin
   FGroupAddress.Free;
   for i:=0 to Length(FExtraAddresses)-1 do
    FExtraAddresses[i].Free;
  end;
end;

end.
