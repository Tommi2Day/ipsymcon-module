unit UWS300interface;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2012
interface

type Tws300dev_rec=record
  typ:string;
  id:string;
  sensor:string;
  temp:string;
  hum:string;
   battery:string;
  lost:string;
end;
type Tws300dev_data=record
        date:TDateTime;
        willi:string;
        wind:string;
        rain:string;//in mm
        rainc:string; //counter
        israining:string; //value
        press:string;
        records:array[0..9] of Tws300dev_rec;
end;


//Defines Interfaces that are implemented
//------------------------------------------------------------------------------
type
  IIPSSendWS300 = interface(IInvokable)
  ['{F7B329D4-6E4E-4D0C-B059-E1894B23D8CE}']
  procedure SendWS300Data(DestDevice: Integer; Data: String); stdcall;
  function update:boolean;stdcall;
 end;

 IIPSReceiveWS300 = interface(IInvokable)
  ['{CD3D1E2D-83ED-4595-90CD-3444A22AAA66}']
  procedure ReceiveWS300Data(DestDevice: Integer; Data: String); stdcall;
  //function GetDeviceID: Integer; stdcall;
 end;


 //Sensor
 IIPSWS300Device = interface(IInvokable)
  ['{4228137D-EDE3-41BF-9B0A-CA0DB1AC6353}']
   //procedure SetDeviceID(DeviceID: Integer); stdcall;
   //function GetDeviceID:integer; stdcall;
   function update:boolean;stdcall;
 end;

 //ws300pc
 IIPSWS300Splitter = interface(IInvokable)
  ['{C790A7F2-2572-421F-901B-7F45C05BB062}']
  //procedure SetReadInterval(I: integer); stdcall;
   //function GetReadInterval: integer; stdcall;
   //function GetDeviceID: string; stdcall;
    //procedure SetLogFile(fname: string); stdcall;
    //procedure SetAltitude(I: integer); stdcall;
    //procedure SetRainPerCount(I: integer); stdcall;
    //procedure Setws300pcinterval(I: integer); stdcall;
    procedure setConfig;stdcall;
    function GetConfig:boolean;stdcall;
   //function GetLogFile: string; stdcall;
   function getNextRecord(logfile:string):boolean; stdcall;
   function getCurrentRecord:boolean; stdcall;
   //function GetAltitude: integer; stdcall;
   //function GetRainPerCount: integer; stdcall;
   //function GetWS300PCinterval: integer; stdcall;
   function GetVersion:string;stdcall;
   function GetHistoryCount: integer; stdcall;
   function update:boolean; stdcall;
   //procedure SetWSWINFile(fname: string); stdcall;
   //function GetWSWINFile: string; stdcall;
 end;
 //IPWE
 IIPSIPWEsplitter = interface(IInvokable)
  ['{F2C12056-727F-4F40-9350-DB10001F65B2}']
  //--- IIPSIPWESplitter implementation
 //function GetUrl:string;stdcall;
 //procedure SetInterval(Intervall: integer); stdcall;
 //function GetInterval: integer; stdcall;
 //procedure SetLogFile(fname: string); stdcall;
   //function GetLogFile: string; stdcall;
   //function GetAuth:string;stdcall;
   //procedure SetAuth(auth:string); stdcall;
   //procedure SetRainPerCount(I: integer); stdcall;
   //function GetRainPerCount: integer; stdcall;
   function update:boolean; stdcall;
   //procedure SetWSWINFile(fname: string); stdcall;
   //function GetWSWINFile: string; stdcall;
 end;
 //WDE1
 IIPSWDE1Splitter = interface(IInvokable)
  ['{EE7F90DD-7668-459C-A233-8241C46864A5}']
   //function GetComPort: string; stdcall;
   //procedure SetLogFile(fname: string); stdcall;
   //function GetLogFile: string; stdcall;
   //function GetRainPerCount: integer; stdcall;
   //procedure SetRainPerCount(I: integer); stdcall;
   //procedure SetWSWINFile(fname: string); stdcall;
   //function GetWSWINFile: string; stdcall;
 end;

 //FS20WUE
 IIPSFS20WUESplitter = interface(IInvokable)
  ['{AA2544FC-0BF8-43C1-B84C-096B844AEACC}']
   //function GetComPort: string; stdcall;
   //procedure SetLogFile(fname: string); stdcall;
   //function GetLogFile: string; stdcall;
   //function GetRainPerCount: integer; stdcall;
   //procedure SetRainPerCount(I: integer); stdcall;
 end;
implementation

end.
