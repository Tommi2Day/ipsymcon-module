unit UModuleInterface;
// Demo-Interface Unit für IPS-Module
// Thomas Dreßler 2009 - 2012
// frei für private Nutzung

interface
uses UIPSTypes, UIPSModuleTypes;

//Defines a custom Interface that is implemented
//alle Funktionen müssen StdCall verwenden
//Jedes Interface braucht seine eigene GUID
//------------------------------------------------------------------------------
type
IIPSDevice = interface(IInvokable)
 ['{2097D725-4B79-49CF-887A-1E84C38BEB92}'] //Für jedes Interface mit STRG-SHIFT-G neu erstellen !!
//Diese Funktionen werden jetzt unter PHP sichtbar
 //setzt Filenamen für Logfile (relativ zu ips.exe)
 procedure setLogFile(FileName:string); stdcall;
 //Gibt einen String an das Modul und gibt die Anzahl der Zeichen zurück
  function setLine(Text:string):integer; stdcall;
  //gibt den letzten Eintrag zurück
  function getLine:string; stdcall;
  //erlaubt echo
  procedure EnableEcho(bEcho:boolean);stdcall;
  procedure Testfunction;stdcall;
 end;

implementation


end.

