unit ULCP100interface;
//Thomas Dreﬂler (www.tdressler.net) 2010-13
interface
uses Windows, UIPSTypes, UIPSModuleTypes;



//------------------------------------------------------------------------------

//Defines a custom Interface that is implemented
//------------------------------------------------------------------------------

 type
 IIPSLCP100 = interface(IIPSModule)
 ['{F5DC33B7-80E5-4B65-83A4-D6E8431D023D}']
 function Backlight(OnOff :boolean): boolean; stdcall;
  function CLS:boolean; stdcall;
  function Test:boolean; stdcall;
  function PushBitmap(page:integer;datei:string):boolean; stdcall;
 function GetBitmap(page:integer;datei:string):boolean; stdcall;
 function ShowPage(page:integer):boolean; stdcall;
 function GetVersion:string;stdcall;
 function GetPortList:string;stdcall;
  //function GetComPort:string;stdcall;
  //procedure SetComPort(Device:string);stdcall;
 end;
 //------------------------------------------------------------------------------



implementation

end.

