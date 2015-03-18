unit UIPSDataTypes;

interface

uses Windows, UIPSTypes, UIPSModuleTypes;

//Defines Interfaces that are implemented
//------------------------------------------------------------------------------
type
 IIPSSendString = interface(IInvokable)
  ['{79827379-F36E-4ADA-8A95-5F8D1DC92FA9}']
  procedure SendText(Text: String); stdcall;
 end;

 IIPSReceiveString = interface(IInvokable)
  ['{018EF6B5-AB94-40C6-AA53-46943E824ACF}']
  procedure ReceiveText(Text: String); stdcall;
 end;

 IIPSReadPage = interface(IInvokable)
  ['{D4C1D08F-CD3B-494B-BE18-B36EF73B8F43}']
  function RetrievePage(URL: String): String; stdcall;
  function RetrievePageEx(URL: String; Timeout: Integer): String; stdcall;
  function SubmitPage(URL, Data: String): String; stdcall;
  function SubmitPageEx(URL, Data: String; Timeout: Integer): String; stdcall;
 end;

 IIPSSendHID = interface(IInvokable)
  ['{4A550680-80C5-4465-971E-BBF83205A02B}']
  procedure SendEvent(ReportID: Byte; Data: String); stdcall;
 end;

 IIPSReceiveHID = interface(IInvokable)
  ['{FD7FF32C-331E-4F6B-8BA8-F73982EF5AA7}']
  procedure ReceiveEvent(ReportID: Byte; Data: String); stdcall;
 end;
 
 IIPSSendDMX = interface(IInvokable)
  ['{F241DA6A-A8BD-484B-A4EA-CC2FA8D83031}']
  procedure SendDMXChannelValue(Channel, Value: Integer; FadingSeconds, DelayedSeconds: Double); stdcall;
 end;

 IIPSReceiveDMX = interface(IInvokable)
  ['{311686E9-E1C5-4247-931B-EB8FF396638F}']
  procedure ReceiveDMXChannelValue(Channel, Value: Integer); stdcall;
 end;

 IIPSSendFHZ = interface(IInvokable)
  ['{122F60FB-BE1B-4CAB-A427-2613E4C82CBA}']
  procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
 end;

 IIPSReceiveFHZ = interface(IInvokable)
  ['{DF4F0170-1C5F-4250-840C-FB5B67262530}']
  procedure ReceiveFHZData(Data: TFHZDataRX); stdcall;
 end;

 IIPSSendHM = interface(IInvokable)
  ['{75B6B237-A7B0-46B9-BBCE-8DF0CFE6FA52}']
  procedure SendHMData(Protocol: THMProtocol; MethodName: String; Data: THMValues); stdcall;
  function ReadHMData(Protocol: THMProtocol; MethodName: String; Data: THMValues): THMValue; stdcall;
  procedure SendHMDataEx(Protocol: THMProtocol; MethodName: String; Data: THMValues; WaitTime: Integer); stdcall;
  function ReadHMDataEx(Protocol: THMProtocol; MethodName: String; Data: THMValues; WaitTime: Integer): THMValue; stdcall;
 end;

 IIPSReceiveHM = interface(IInvokable)
  ['{98FEC99D-6AD9-4598-8F50-2976DA0A32C8}']
  procedure ReceiveHMEvent(Data: THMArray); stdcall;
 end;

 IIPSTMEXServer = interface(IInvokable)
  ['{7DF59F47-5AE7-4709-B269-807C3016B5EE}']
  function RequestSlot(InstanceID: TInstanceID; Timeout: Integer): Integer; stdcall; //Returns SlotID, Is Blocking!
  procedure ReleaseSlot(SlotID: Integer); stdcall;
 end;

 IIPSTMEXClient = interface(IInvokable)
  ['{532BB4B0-E217-4A86-BBBF-72E7951305A0}']
 end;

 IIPSReceiveLCN = interface(IInvokable)
  ['{0BD35CD6-01E1-497E-A656-4A9E629123A0}']
  procedure ReceiveLCNData(_Type: TLCNMessage; Segment, Target: Byte; _Function, Data: String); stdcall;
 end;

 IIPSSendLCN = interface(IInvokable)
  ['{C5755489-1880-4968-9894-F8028FE1020A}']
  procedure SendLCNData(Address: TLCNAddress; Segment, Target: Byte; _Function, Data: String); stdcall;
 end;

 IIPSReceiveInternalLCN = interface(IInvokable)
  ['{00E11183-CDAF-4AFB-9B13-D41A8B6D05ED}']
  procedure ReceiveLCNData(_Type: TLCNMessage; _Function, Data: String); stdcall;
 end;

 IIPSSendInternalLCN = interface(IInvokable)
  ['{40C6F645-4A0C-40D7-9100-38EABB73B1EB}']
  procedure SendLCNData(_Function, Data: String); stdcall;
 end;

 IIPSReceivexComfort = interface(IInvokable)
  ['{BF8A4773-5DA8-47F6-9E7F-809886A15859}']
  procedure ReceivexComfortData(Data: String); stdcall;
 end;

 IIPSSendxComfort = interface(IInvokable)
  ['{06ECB637-A51A-45CE-BAC8-9D5F922166CE}']
  procedure SendxComfortData(Data: String); stdcall;
 end;

 IIPSModBusPLCServer = interface(IInvokable)
  ['{77B31ABB-18FA-4B91-BB63-E5B2AB5588F4}']
  function ReadCoil(Address: Integer; ReadOnly: Boolean): Boolean; stdcall;
  function ReadRegisterByte(Address: Integer; ReadOnly: Boolean): Byte; stdcall;
  function ReadRegisterWord(Address: Integer; ReadOnly: Boolean): Word; stdcall;
  function ReadRegisterDWord(Address: Integer; ReadOnly: Boolean): DWord; stdcall;
  function ReadRegisterShortInt(Address: Integer; ReadOnly: Boolean): ShortInt; stdcall;
  function ReadRegisterSmallInt(Address: Integer; ReadOnly: Boolean): SmallInt; stdcall;
  function ReadRegisterInteger(Address: Integer; ReadOnly: Boolean): Integer; stdcall;
  function ReadRegisterReal(Address: Integer; ReadOnly: Boolean): Double; stdcall;
  procedure WriteCoil(Address: Integer; Value: Boolean); stdcall;
  procedure WriteRegisterByte(Address: Integer; Value: Byte); stdcall;
  procedure WriteRegisterWord(Address: Integer; Value: Word); stdcall;
  procedure WriteRegisterDWord(Address: Integer; Value: DWord); stdcall;
  procedure WriteRegisterShortInt(Address: Integer; Value: ShortInt); stdcall;
  procedure WriteRegisterSmallInt(Address: Integer; Value: SmallInt); stdcall;
  procedure WriteRegisterInteger(Address: Integer; Value: Integer); stdcall;
  procedure WriteRegisterReal(Address: Integer; Value: Double); stdcall;
 end;

 IIPSModBusPLCClient = interface(IInvokable)
  ['{E310B701-4AE7-458E-B618-EC13A1A6F6A8}']
 end;

 IIPSSiemensPLCServer = interface(IInvokable)
  ['{EC09E155-355C-4DC2-95C7-5C336B1C9D48}']
  function ReadBit(Area: TNoDaveArea; AreaAddress, Address, Bit: Integer): Boolean; stdcall;
  function ReadByte(Area: TNoDaveArea; AreaAddress, Address: Integer): Byte; stdcall;
  function ReadWord(Area: TNoDaveArea; AreaAddress, Address: Integer): Word; stdcall;
  function ReadDWord(Area: TNoDaveArea; AreaAddress, Address: Integer): DWord; stdcall;
  function ReadShortInt(Area: TNoDaveArea; AreaAddress, Address: Integer): ShortInt; stdcall;
  function ReadSmallInt(Area: TNoDaveArea; AreaAddress, Address: Integer): SmallInt; stdcall;
  function ReadInteger(Area: TNoDaveArea; AreaAddress, Address: Integer): Integer; stdcall;
  function ReadReal(Area: TNoDaveArea; AreaAddress, Address: Integer): Double; stdcall;
  procedure WriteBit(Area: TNoDaveArea; AreaAddress, Address, Bit: Integer; Value: Boolean); stdcall;
  procedure WriteByte(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: Byte); stdcall;
  procedure WriteWord(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: Word); stdcall;
  procedure WriteDWord(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: DWord); stdcall;
  procedure WriteShortInt(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: ShortInt); stdcall;
  procedure WriteSmallInt(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: SmallInt); stdcall;
  procedure WriteInteger(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: Integer); stdcall;
  procedure WriteReal(Area: TNoDaveArea; AreaAddress, Address: Integer; Value: Double); stdcall;
 end;

 IIPSSiemensPLCClient = interface(IInvokable)
  ['{042EF3A2-ECF4-404B-9FA2-42BA032F4A56}']
 end; 

 IIPSSendEnOcean = interface(IInvokable)
  ['{70E3075F-A35D-4DEB-AC20-C929A156FE48}']
  procedure SendEnOceanData(Data: TEnOceanDataTX); stdcall;
 end;

 IIPSReceiveEnOcean = interface(IInvokable)
  ['{DE2DA2C0-7A28-4D23-A9AA-6D1C7609C7EC}']
  procedure ReceiveEnOceanData(Data: TEnOceanDataRX); stdcall;
 end;

 IIPSSendXBee = interface(IInvokable)
  ['{91DF0325-934F-4E76-A3D2-BF7BD4DA635C}']
  procedure SendXBeeData(DestinationDevice: Integer; Data: String); stdcall;
 end;

 IIPSReceiveXBee = interface(IInvokable)
  ['{3431D06E-3992-4656-9F2E-129B839735A5}']
  procedure ReceiveXBeeData(SourceDevice: Integer; Data: String); stdcall;
 end;

 IIPSReceiveFS10 = interface(IInvokable)
  ['{78AC3D2F-D2FA-416A-BA19-ED4E557839EB}']
  procedure ReceiveFS10Data(Data: String); stdcall;
 end;

 IIPSSendFS10 = interface(IInvokable)
  ['{F8ABF3AB-AF9F-4588-BCA9-273EF7EF1732}']
  procedure SendFS10Data(Data: String); stdcall;
 end;

 IIPSReceiveEIB = interface(IInvokable)
  ['{8A4D3B17-F8D7-4905-877F-9E69CEC3D579}']
  procedure ReceiveEIBData(Data: String); stdcall;
 end;

 IIPSSendEIB = interface(IInvokable)
  ['{42DFD4E4-5831-4A27-91B9-6FF1B2960260}']
  procedure SendEIBData(Header, Data: String); stdcall;
 end;

 IIPSReceiveZWave = interface(IInvokable)
  ['{F403B0C2-AA74-4070-98C3-BC0815D941CD}']
  procedure ReceiveZWaveData(Data: String); stdcall;
 end;

 IIPSSendZWave = interface(IInvokable)
  ['{0F6E6A9E-8121-473D-9E1C-161A09829771}']
  procedure SendZWaveData(Data: String); stdcall;
  procedure SendZWaveNodeData(NodeID: Integer; Data: String); stdcall;
 end;

 IIPSReceiveWMRS200 = interface(IInvokable)
  ['{93727164-A8C8-40D5-8038-A32B12247FAB}']
  procedure ReceiveWMRS200Data(Data: String); stdcall;
 end;

 IIPSSendWMRS200 = interface(IInvokable)
  ['{ED60928C-B2BE-4F64-9EB0-49911AB66A5C}']
  procedure SendWMRS200Data(Data: String); stdcall;
 end;

 IIPSReceiveProJet = interface(IInvokable)
  ['{7C307DE6-093B-4E83-AF0B-116B50569EF4}']
  procedure ReceiveProJetData(Data: String); stdcall;
 end;

 IIPSSendProJet = interface(IInvokable)
  ['{9DD17B0B-030F-4849-8BFF-88EB4BB414BA}']
  function SendProJetData(Data: String): String; stdcall;
 end;

 IIPSReceiveMBus = interface(IInvokable)
  ['{672C59A3-52CF-4704-848A-552598AFEF34}']
  procedure ReceiveMBusData(Data: String); stdcall;
 end;

 IIPSSendMBus = interface(IInvokable)
  ['{2C30BDAD-B9D7-4309-AE35-EE5AC073A663}']
  function SendMBusShortFrame(C, A: Byte; ExpectedFrame: TMBusFrame): String; stdcall;
 end;

 IIPSSendWuT = interface(IInvokable)
  ['{92B71588-7F58-45F5-9028-21598C54B264}']
  function SendWuTData(Command, Data: String): String; stdcall;
 end;

 IIPSReceiveWuT = interface(IInvokable)
  ['{7D516779-3959-49A6-878A-7F037799C190}']
  procedure ReceiveWuTData(Command, Data: String); stdcall;
 end;

 IIPSReceiveIRTrans = interface(IInvokable)
  ['{B35083D2-AD72-4984-BF59-E2D5E793B421}']
  procedure ReceiveIRTransData(DeviceID: Integer; Remote, Button: String); stdcall;
 end;

 IIPSSendIRTrans = interface(IInvokable)
  ['{E7FC23F6-C086-422D-9D66-50337C805F6C}']
  function SendIRTransData(DeviceID: Integer; Remote, Button: String): String; stdcall;
 end;

 IIPSReceivedS = interface(IInvokable)
  ['{1602EDEB-367D-4B87-82DD-1222BCB95448}']
  procedure ReceivedSData(Event: String); stdcall;
 end;

 IIPSSenddS = interface(IInvokable)
  ['{EB906053-D9FD-4E1B-A2CD-7E5C1B3C7706}']
  function SenddSData(Request, Data: String): String; stdcall;
 end;

 IIPSReceiveOZW = interface(IInvokable)
  ['{75A04B59-9545-4163-9914-1239CBBCD5AE}']
  procedure ReceiveOZWData(); stdcall;
 end;

 IIPSSendOZW = interface(IInvokable)
  ['{DB344659-ECCF-4780-969D-872A1ADC139A}']
  function SendOZWData(API, Data: String): String; stdcall;
 end;

 IIPSReceiveOZWDevice = interface(IInvokable)
  ['{B8E69181-4F63-422C-8238-B2248751169F}']
  procedure ReceiveOZWDeviceData(); stdcall;
 end;

 IIPSSendOZWDevice = interface(IInvokable)
  ['{B9339593-D996-410D-96A4-56DDDDF3C3D6}']
  function SendOZWDeviceData(API, Data: String): String; stdcall;
 end;

implementation

end.
