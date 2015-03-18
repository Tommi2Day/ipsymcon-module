unit UDevice;
// Demo-Device Unit f�r IPS-Module
// Thomas Dre�ler 2009 - 2012
// requires IPS V2.6+ (Property functions)
// frei f�r private Nutzung

interface

uses  Windows, SysUtils, Forms, StrUtils,  //standard units f�r eigene Implementierung
     UIPSTypes, UIPSModuleTypes,UIPSDataTypes, //IPS SDK
     UModuleInterface; //eigenes Interface

type


//Hauptobjekt des Moduls, implementiert die folgenden Interfaces
TIPSDevice = class(TIPSModuleObject, //standard
                        IIPSModule, //standard
                        IIPSReceiveString, //TextEmpfang aus anderen Modulen erm�glichen
                        IIPSDevice) //eigenes Interface

  private
   //--- Custom Objects
   lastLine:string;

   //--- seperate get/set- property Funktionen  sind obsolete

   //--- Private Procedures/Functions
   procedure logme(Text:string);
   procedure DoEcho(Text:string);
   procedure handleData(from,Text:String);

  protected
  {Alle Funktionen, die auch in abgeleiteten Objekten genutzt werden sollen,
  aber nicht �ffentlich sind, werden als Protected gekennzeichnet
  Funktionen, die nicht implementiert werden, m�ssen auskommentiert werden

   Beispiel:
   IPS-funktionen zur optionalen Auswertung von Status-Informationen
   //Wenn eine Instance den Status �ndert, kann hiermit drauf reagiert werden
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); override;

   //Wenn der Kernel den Status �ndern m�chte, kann ebenfalls noch reagiert werden
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); override;
   }
  public
  {
  Alle nach Aussen sichtbare Funktionen und Werte m�ssen Public sein

  1. Objekterstellung , muss immer implementiert werden und public sein
  Dabei wird das Standardverhalten �berschrieben (override)
  mit inherited kann die Standardfunktionalit�t trotzdem noch genutzt werden
  }
  constructor Create(IKernel: IIPSKernel; InstanceID: TInstanceID); override;
   destructor  Destroy; override;

   //2. Class Functions
   class function GetModuleID(): TStrGUID; override;
   class function GetModuleType(): TIPSModuleType; override;
   class function GetModuleName(): String; override;
   class function GetImplemented(): TStrGUIDs; override;
   class function GetVendor(): String; override;
   class function GetAliases(): TStringArray; override;

   //3.optionale Funktionen
   class function GetParentRequirements(): TStrGUIDs; override;
   //class function GetClientRequirements(): TStrGUIDs; override;

   //4. Interface Funktionen
   //--- IIPSModule implementation
   procedure LoadSettings(); override;
   procedure SaveSettings(); override;
   procedure ResetChanges(); override;
   procedure ApplyChanges(); override;


   //--- IIPSReceiveString implemenatation(Datapoint)
   //alle Interface-Funktionen m�ssen stdcall benutzen!
   procedure ReceiveText(Text:string); stdcall;

  //--- IIPSDevice implementation =diese Funktionen sind unter PHP sichtbar
  {alle im Interface genannten Funktionen m�ssen Textgleich noch einmal
  hier aufgef�hrt werden
  alle PHP-Funktionen m�ssen stdcall benutzen!
  }
  procedure setLogFile(FileName:string); stdcall;
  function setLine(Text:string):integer; stdcall;
  function getLine:string; stdcall;
  procedure EnableEcho(bEcho:boolean);stdcall;
  procedure Testfunction;stdcall;

 end;

implementation


//------------------------------------------------------------------------------
class function TIPSDevice.GetModuleType(): TIPSModuleType;
{
definiert den Modultyp.
Devices k�nnen keine Childs, nur Parents haben, Splitter dagegen beides.
Nur Devices werden bei der Modulauswahl angezeigt, wenn man nicht "AlleModuleAnzeigen"
ausgew�hlt hat.
Regel:Wenn es ein Endger�t ist, dann immer als Device, Wenn es dagegen Daten an andere
Module senden soll, als Splitter definieren
}
begin
 Result := mtDevice; //Typ ist i.d.R. mtDevice oder mtSplitter (siehe UIPSTypes)
end;
//------------------------------------------------------------------------------
class function TIPSDevice.GetModuleID(): TStrGUID;
//gibt die GUID des Moduls f�r die Modulverwaltung zur�ck
begin
 Result := GUIDToString(IIPSDevice); //Will return Interface GUID
end;

//------------------------------------------------------------------------------
class function TIPSDevice.GetModuleName(): String;
{
gibt den Namen des Moduls f�r die Modulverwaltung zur�ck
unter diesem Prefix z.B.die Eintr�ge im Log vorgenommen und
auch das Json File f�r die Properties ben�tigt exact diesen Namen
}
begin
 Result := 'MyDemo';
end;

//------------------------------------------------------------------------------
class function TIPSDevice.GetParentRequirements(): TStrGUIDs;
{
abfrage, ob der Parent ein kompatibles Interface hat
Hier wollen wir nur Parents mit TextInterface Senden
Parents, die diese Vorraussetzung nicht haben, k�nnen nicht verbunden werden
}
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSSendString);

end;
//------------------------------------------------------------------------------
class function TIPSDevice.GetImplemented(): TStrGUIDs;
{
hier erf�hrt der Parent mittels GetParentRequirement
(bzw der Child �ber getChildRequirements),
ob er kompatibel mit diesem modul ist, sprich das gew�nschte Interface implementiert ist
Hier sagen wir, das wir �ber das TextInterface daten bekommen k�nnen
}
begin
 SetLength(Result, 1);
 Result[0] := GUIDToString(IIPSReceiveString);
end;

//------------------------------------------------------------------------------
class function TIPSDevice.GetVendor(): String;
//Das Modul erscheint unter diesem Herstellernamen in der Auswahl
begin
 Result := 'MySelf';
end;

//------------------------------------------------------------------------------
class function TIPSDevice.GetAliases(): TStringArray;
//Das Modul erscheint unter allen diesen Bamen in der Auswahl
begin

 SetLength(Result, 2); //Anzahl der Namen entsprechend anpassen
 Result[0] := 'MyDevice';
 Result[1] := 'MyLogger'; //optional

end;

//Ab hier gehts in eingemachte
//Implementation des Hauptobktes und der Interface
//------------------------------------------------------------------------------
constructor TIPSDevice.Create(IKernel: IIPSKernel; InstanceID: TInstanceID);

begin

 {StandardRoutinen zur Objekterzeugung eines IPS-Modules ausf�hren
 }
 inherited;

 //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Create Object ...');
 {Properties definieren
 Diese Properties werden �ber IPS_SetProperty und IPS_SetProperty-Funktionen
 gesetzt bzw. Ausgelesen werden. Der Name ist egal, wird aber in den Funktionen
 ben�tigt,der 2. Parameter ist ein default Wert

 Die Namen der Properties k�nnen in einem json File im /forms Ordner
 referenziert und damit die Instanz konfiguriert werden

 }
 RegisterProperty( 'LogFile','');
 RegisterProperty( 'Echo',false);


 {Status-Variablen definieren (optional)
 Diese StatusVariablen werden dann in der Konsole und Frontend automatisch angezeigt
 Die StatusVariablen sollten auch ein profil bekommen, wenn sie in der Anzeige
 formatiert dargestellt werden sollen. Details bitte dem SDK (UIPSTypes ab
 Zeile 1925 f�r SDK 2.04) entnehmen. Im WebFrontend sind in 2.0.4 aber nur die
 DefaultProfile implementiert, so das man bei eigenen Profile diese dort
 selber nachbilden muss.
 In 2.10 gibt man den Namen eines existierenden Defaultprofiles oder eines eigenen Profiles mit,
 welches man vorher mit CreateXXXXProfile angelegt hat. Bei eigenen Profilen kann man auch ein eigenes Icon
 angeben oder man w�hlt ein existierendes aus, wie hier.
 ab SDK2.5 werden hier nur statische Variablen eingetragen
 }
 TIPSVarProfile.CreateStringProfile('DemoTextProfile', 'Information','', '-->logged');
 RegisterVariable('LastLineVariable','LastText',vtString,'DemoTextProfile');
 RegisterVariable('TestVariable','Test',vtString,'DemoTextProfile');
 //Beispiel f�r einen Schalter mit default Profile
 //RegisterVariable('StatusVariable','Status',vtBoolean,GetDefaultProfile(dpSwitch));

 //Initialisation lokaler variablen
 lastLine:='';

 //Hier werden auch Timer usw. initialisiert
 //...

 //Check Parent
 {hier wird automatisch die Verbindung zu einem passenden Parent hergestellt.
 steht der Parameter auf True, wird der Parent immer neu angelegt
 Die automatische Auswahl bei noch nicht registriertem Parent greift leider
 manchmal daneben, weil immer das erste passende Modul zugewiesen wird.
 auch wenn es schon woanders zugewiesen wurde.
 }
 RequireParent(IIPSSendString,false);

end;

//------------------------------------------------------------------------------
destructor  TIPSDevice.Destroy;
begin
 //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Destroy Object ...');
 inherited;

end;

//--Implementation Klassenfunktionen
//------------------------------------------------------------------------------
procedure TIPSDevice.LoadSettings();
begin
{holt aus den gespeicherten Settings Properties und Variablen-Namen/Werte
Wurde diese vorher nicht mit Register... definiert, gibt es Fehler im Logfile
}

//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Load Settings ...');

 inherited;

 {hier kann man noch zus�tzliche Einstellungen  dazu laden.
 oder z.B. die wieder hergestellten gespeicherten Werte noch einmal
 bearbeiten, Status zur�cksetzen.
 Die Ausf�hrung von Aktionen ist noch nicht m�glich
 }
 end;

//------------------------------------------------------------------------------
procedure TIPSDevice.SaveSettings();
begin
 {Speichert Properties und StrausVariablen in die Settings.xml}

//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Save Settings ...');
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSDevice.ResetChanges();
{macht die im speicher vorhandenen �nderungen wieder R�ckg�nig.
Dabei wird lediglich der Settings Record umkopiert. i.D.R arbeitet man jedoch
mit dem aktuellen (ungespeicherten) changedsettings record}
begin
 //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Reset Settings ...');
 inherited;
end;

//------------------------------------------------------------------------------
procedure TIPSDevice.ApplyChanges();
{hier werden die dynamische StatusVariablen zugewiesen und am Ende ein
SaveSettings ausgef�hrt
im Beispiel soll die Variable Beispiel der Batterie nur auftauchen,
wenn das Device wirklich eine Batterie hat
}
//MaintainVariable(haveBattery,'BatteryVariable', 'Battery', vtBoolean, 'Battery.Reversed');
begin

//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Apply Changes ...');

 inherited;
 {
 hier k�nnten jetzt noch Zusatzfunktionen zur Einstellung des Parents stehen
 ...

 Die Initialisierung des Moduls ist nun abgeschlossen.
 }
end;


//Datapoint
{Implementation Dateninterface IIPSReceiveString
IIPSReceiveString erfordert die Implementierung einer Funktion ReceiveText
mit einem String als Parameter
}
//------------------------------------------------------------------------------
procedure TIPSDevice.ReceiveText(Text:string); stdcall;
begin

//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'External Data received');

  //sendData erzeugt Eintrag im DebugFenster
  SendData('Received', ' Msg:'+Text);
  //Ausf�hrung der Datenbearbeitung
  handleData('Interface',Text);
end;

//---Implementation IIPSDevice Modulfunctionen (Actions)
{Alle im DeviceInterface definierten Funktionen und Proceduren m�ssen auch
implementiert werden.
}
//------------------------------------------------------------------------------
//PHP-DemoFunktion zum setzen des Logfilenamens
procedure TIPSDevice.setLogFile(FileName:string);stdcall;
   begin
   //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Set Logfile entered');

   //sendData erzeugt Eintrag im DebugFenster
   SendData('SetLogfile', ' SetLogFile to '+FileName);
   //hier wird einfach nur die SetMethode aufgerufen
    SetProperty('LogFile',FileName); //ablegen

    {setzt ein Flag zum Speichern und
    erzeugt eine SettingsChanged-Message}
    settingschanged;
   end;
 //------------------------------------------------------------------------------
 //PHP-DemoFunktion zur R�ckgabe eines Wertes
 function TIPSDevice.getLine:string;stdcall;
 begin
 //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'GetLine entered...');
 //sendData erzeugt Eintrag im DebugFenster
 SendData('getLine','entered');
 //Als Ergenis wird der zuletzt gespeicherte Text zur�ckgegeben
 result:=lastLine;
 SendData('getLine','Finshed, Result:'+result);
end;

//------------------------------------------------------------------------------
//PHP-DemoFun zum ausf�hren einer Aktion und R�ckgabe eines Wertes
function TIPSDevice.setLine(Text:string):integer;stdcall;
begin
//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'SetLine entered...');
   //sendData erzeugt Eintrag im DebugFenster
   senddata('setLine','entered');
   //Ausf�hrung einer Logik-Funktion
   handleData('PHP',Text);
   //R�ckgabe eines Wertes
   Result:=length(Text);
end;

//------------------------------------------------------------------------------
//---PHP Stub zum setzen einer Property
procedure TIPSDevice.EnableEcho(bEcho:boolean);stdcall;
begin
//Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Enable Echo entered...');
   //sendData erzeugt Eintrag im DebugFenster
   senddata('Enable Echo','entered');

   SetProperty('Echo',bEcho); //ablegen

    {setzt ein Flag zum Speichern und
    erzeugt eine SettingsChanged-Message}
    settingschanged;
end;

{ab hier kommt erst die Logik in ausgelagerten Funktionen
alternativ k�nnen auch aus anderen Programmen bereits vorhandene Funktionen in
eigenen Units verwendet werden (refactoring)
}
//---Implementation privater Modulfunctionen (Logik)
//------------------------------------------------------------------------------
procedure TIPSDevice.logMe(Text:string);
//implementiert Logger-Funktion->schreibt in eine Textdatei alle Aufrufe
var log:TextFile;
  fname:string;
begin
  //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'LogMe entered...');

 //sendData erzeugt Eintrag im DebugFenster
 senddata('LogMe','entered');
 //property Logfile abfragen
 fname:=GetProperty('LogFile');
 //kein Name=nichts loggen
 if fname>'' then
 begin
  //file�ffenen( Anh�ngen oder neu)
  assignfile(log,fname);
  if fileexists(fname) then append(log) else rewrite(log);
  //schreiben�, dabei exceptions abfangen
  try
    writeln(log,Text);
  finally
  //file schliessen
  closefile(log);
  end;
 end;
 senddata('LogMe','finished');
end;
//------------------------------------------------------------------------------
procedure TIPSDevice.HandleData(From,Text:string);
//Verarbeitet die  ankommenden Daten in einer gemeinasmen Methode f�r alle Quellen
var s:string;
begin
   //Nur zur Demo!! Eintrag im Kernellog zum Nachvollzienen der Aufrufe
 LogMessage(KL_DEBUG,'Handle Data entered');
  //sendData erzeugt Eintrag im DebugFenster
   senddata('HandleData','entered');

   //Demo-Funktion=Text zusammensetzen
   s:=from+' -->'+Text;
   lastline:=s;
   //Text loggen
   logme(s);
   //Echo zur�ckgeben, wenn gefordert
   DoEcho(Text);
   //Statusvariable setzen
   fKernel.VariableManager.WriteVariableString(GetStatusVariableID('LastLineVariable'), s);
   senddata('HandleData','finished');
end;
//------------------------------------------------------------------------------
procedure TIPSDevice.DoEcho(Text:string);
{
implementiert PseudoEcho-Funktion  gem�� Wunsch in
http://www.ip-symcon.de/forum/f13/beispielprojekt-doku-source-veroeffentlicht-7605/index2.html#post66603
->sendet den hereinkommenden Text an den angeschlossenen Parent zur�ck, soweit dieser das unterst�tzt.
}
var s:string;
  parent:IIPSModule;
  ifsend:IIPSSendString;
begin
  s:=Text;
  senddata('DoEcho','entered');
  //test, ob echo property gesetzt ist
  if GetProperty('Echo')=true then
  begin
      senddata('DoEcho','Echo requested');
      //Parent Instance holen
      parent:=getParent();
      //Test ob Instance existiert
      if parent=NIL then
      begin
      //nein->Melden
        senddata('DoEcho','Kein Parent verbunden, skip');
      end else begin
      //test ob IIPSSendString-Interface existiert
        if supports(parent,IIPSSendString,IfSend) then
        begin
        //existiert, kann senden
          senddata('DoEcho','Alles Ok');
          ifsend.SendText(s);
        end else begin
        //Problem mitteilen
          senddata('DoEcho','Send String not supported');
        end;
      end;
   end else begin
   //kein Echo, weil nicht aktiviert, mache Debug-Eintrag
     senddata('DoEcho','Echo not requested');
   end;
   senddata('DoEcho','finished');
end;
procedure TIPSDevice.TestFunction; stdcall;
var
  i:integer;
  msg:string;
begin
  for I := 0 to 99 do
  begin
     senddata('TestFunction', 'Prepare String, Idx='+IntToStr(i));
     msg := msg + '1234567890';
     senddata('TestFunction', 'Write Variable, Idx='+IntToStr(i));
     fKernel.VariableManager.WriteVariableString(
        GetStatusVariableID('TestVariable'), msg);
  end;
end;
end.
