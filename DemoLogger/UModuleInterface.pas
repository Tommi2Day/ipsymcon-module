unit UModuleInterface;
// Demo-Interface Unit f�r IPS-Module
// Thomas Dre�ler 2009 - 2012
// frei f�r private Nutzung

interface
uses UIPSTypes, UIPSModuleTypes;

//Defines a custom Interface that is implemented
//alle Funktionen m�ssen StdCall verwenden
//Jedes Interface braucht seine eigene GUID
//------------------------------------------------------------------------------
type
IIPSDevice = interface(IInvokable)
 ['{2097D725-4B79-49CF-887A-1E84C38BEB92}'] //F�r jedes Interface mit STRG-SHIFT-G neu erstellen !!
//Diese Funktionen werden jetzt unter PHP sichtbar
 //setzt Filenamen f�r Logfile (relativ zu ips.exe)
 procedure setLogFile(FileName:string); stdcall;
 //Gibt einen String an das Modul und gibt die Anzahl der Zeichen zur�ck
  function setLine(Text:string):integer; stdcall;
  //gibt den letzten Eintrag zur�ck
  function getLine:string; stdcall;
  //erlaubt echo
  procedure EnableEcho(bEcho:boolean);stdcall;
  procedure Testfunction;stdcall;
 end;

implementation


end.

