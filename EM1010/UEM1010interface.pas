unit UEM1010interface;
//Thomas Dreﬂler (www.tdressler.net) 2009-2012
interface
uses UIPSTypes, UIPSModuleTypes;



//Defines Interfaces that are implemented
//------------------------------------------------------------------------------
type
  IIPSSendEM1010 = interface(IInvokable)
  ['{AC69FB80-B17F-4134-BD23-E7E3D86B2F9F}']
  procedure SendEM1010Data(DestDevice: Integer; Data: String); stdcall;
  function query(queryData:string):string;stdcall;
  function getDevStatus(DestDevice:integer):boolean; stdcall;
  //function getDevBlk(DestDevice:integer;archivfile:string;Blk:integer=0):integer;stdcall;
  function setPrice(DestDevice:integer;euro:double):boolean;stdcall;
  //function setAlarm(DestDevice,value:integer):boolean;stdcall;
  function setRPerKW(DestDevice,value:integer):boolean;stdcall;
 end;

 IIPSReceiveEM1010 = interface(IInvokable)
  ['{67625154-753E-4C8E-B1BA-0D842307807A}']
  procedure ReceiveEM1010Data(DestDevice: Integer; Data: String); stdcall;
  function GetEC: Integer; stdcall;
//  procedure SetLastRecord(reads: Integer); stdcall;
//   function GetLastRecord: Integer; stdcall;
//   procedure SetLastDate(datum: String); stdcall;
//   function GetLastDate: string; stdcall;
//   procedure SetRecords(reads: Integer); stdcall;
//   function GetRecords: Integer; stdcall;
 end;

 IIPSEM1010 = interface(IInvokable)
['{45530748-849E-4FE0-8877-2F335B456F15}']
  //Actions
   function getVersion():String; stdcall;
  function getTime():String; stdcall;
   function setTime(z:string):boolean; stdcall;
  procedure reset();stdcall;
  procedure update; stdcall;

 end;

 IIPSEM1010Device = interface(IInvokable)
 ['{1BC1661B-3731-4DAE-A39E-58349F38A3F4}']
   procedure update; stdcall;
   function getDevStatus:boolean; stdcall;
  function setPrice(euro:double):boolean; stdcall;
  function setRperKW(value:integer):boolean; stdcall;
  function GetLastRecord: string; stdcall;
  //not used
    //function setAlarm(value:integer):boolean; stdcall;
  //function getDevBlk(archivfile:string;Blk:integer=0):integer;stdcall;
  //function GetLastDate: string; stdcall;
  //function GetRecords: Integer; stdcall;
  //function GetLastRecordnum: Integer; stdcall;

 end;
 implementation
end.

