unit UELV2interface;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2013
interface
uses Windows, UIPSTypes, UIPSModuleTypes;



//------------------------------------------------------------------------------

//Defines a custom Interface that is implemented
//------------------------------------------------------------------------------
type
 IIPSM232 = interface(IIPSModule)
  ['{19B29FA3-AB27-4097-9B74-250B1D9A0AEE}']
  function GetIOByte():integer; stdcall;
  function SetIOByte(States:integer): integer;stdcall;
  function GetIOBit(Bit:integer): integer;stdcall;
  function SetIOBit(Bit:integer; state: boolean): integer;stdcall;
  function SetCounterState(state: boolean): integer; stdcall;
  function GetCounterValue():integer; stdcall;
  function StartAnalog(command: integer): integer;stdcall;
  function GetAnalogValue(channel:integer):integer;stdcall;

 end;

//------------------------------------------------------------------------------

//Defines a custom Interface that is implemented
//------------------------------------------------------------------------------
type
 IIPSUAD8 = interface(IIPSModule)
['{71817358-2D66-47D6-88BD-11DE58834D8B}']
  function ActivateChannel(channel:integer;status:boolean):boolean; stdcall;
  function GetData(channel:integer):double; stdcall;
  //function SendConfig:boolean; stdcall;
  function RunTest: boolean; stdcall;
  //function getChannel(channel:integer):boolean;stdcall;
   //procedure setChannel(channel:integer;status:boolean);stdcall;
 end;
//------------------------------------------------------------------------------
type
 IIPSULA200 = interface(IIPSModule)
  ['{0EF64B85-90B8-4EEB-9B36-094DAB9F88E2}']
  function LCDBacklight(fStatus :boolean): boolean; stdcall;
  function LCDCLS:boolean; stdcall;
  function LCDText(Text:string):boolean; stdcall;
  function LCDGoTo(xPos:integer; yPos: Integer): boolean; stdcall;
 end;
//------------------------------------------------------------------------------
 type
 IIPSUIO88 = interface(IIPSModule)
 ['{4CFAB1FE-0C09-480C-867E-9385D30404A6}']
 function GetInput():integer; stdcall;
  function SetOutput(States:integer): integer; stdcall;
  function GetOutput(): integer; stdcall;
  function SetOutputBit(Bit:integer; state: boolean): integer;stdcall;
 end;

 //------------------------------------------------------------------------------
 type
 IIPSSI1 = interface(IIPSModule)
 ['{375C1547-ED8A-4E44-B6C3-3D7ABD739F2D}']
 function SwitchMode(state:boolean):boolean; stdcall;
 function SwitchDuration(state:boolean;time:integer):boolean; stdcall;
 function GetDevStatus:integer;stdcall;
 end;

 //------------------------------------------------------------------------------

 type
 IIPSFS20PCE = interface(IIPSModule)
 ['{FFF72149-C696-427D-B178-0BAA8196F2A3}']
 function GetVersion:String;stdcall;
 end;
 //------------------------------------------------------------------------------
 type
 IIPSFS20PCS = interface(IIPSModule)
 ['{2359E195-AA51-4804-A80E-326A2A8E02BE}']
 //IIPSSend/Receive FHZ defined in IIPSSendFHZ
  //procedure SendFHZData(Data: TFHZDataTX; NumBytes: Byte); stdcall;
  //own procedures
 function GetVersion:String;stdcall;
 end;
 //------------------------------------------------------------------------------

//defines  protocoll characters
const STX =$02;
const ETX =$03;
const ENQ =$05;
const ACK =$06;
const NAK =$15;
const DC2 =$12;
const DC3 =$13;
const STH =1;
const CR  =13;


//defines usbstatus

const USB_DATA=3;
const USB_NAK=2;
const USB_ACK=1;
const USB_PENDING=0;
const USB_ERROR_UNBEKANNT =-1;
const USB_ERROR_RAHMEN  =-2;
const USB_ERROR_QUER    =-3;
const USB_ERROR_OVER    =-4;
const USB_ERROR_PARITY  =-5;
const USB_ERROR_FRAME   =-6;
const USB_ERROR_TIMEOUT =-7;
const USB_ERROR_ANTWORT =-8;
const USB_ERROR_N_OFFEN =-9;
const USB_ERROR_ANZAHL  =-10;
const ERROR_VERIFY      =-11;
const USB_ERROR_CHANNEL=-12;




implementation

end.

