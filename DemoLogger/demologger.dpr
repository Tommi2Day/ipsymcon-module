library demologger;
// Demo-Library f�r IPS-Module
// Thomas Dre�ler 2009-2012
// frei f�r private Nutzung

uses
  simplesharemem,
  Windows,
  StrUtils,
  Classes,
  SysUtils,
  UIPSTypes,
  UIPSModuleTypes,
  UModuleInterface in 'UModuleInterface.pas',
  UDevice in 'UDevice.pas';

{$R *.res}

//Standard-Texte, mussen bei jeder Library existieren
//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID    : '{30dec678-a21a-41f8-840b-cfd52a4a9436}'; //F�r jedes Modul mit STRG-SHIFT-G neu erstellen !!
                                 //-------------------------- //n�chste 3 Zeilen anpassen, Build muss leider Manuell hizugef�gt werden
                                 mAuthor      : 'Thomas Dre�ler';
                                 mURL         : 'www.ipsymcon.de';
                                 mName        : 'Demo Modul "Logger"';
                                 mVersion     : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild       : {CompileBuild}39{/CompileBuild};
                                 mDate        : {CompileTime}0{/CompileTime};
                                 //-------------------------- //nicht �ndern!
                                 mKernelVersion : KERNEL_VERSION;
                                 //--------------------------
                                 fRegister    : IPSModuleRegister;
                                 fUnregister  : IPSModuleUnregister;
                               );

//------------------------------------------------------------------------------
var vKernel: IIPSKernel;

//------------------------------------------------------------------------------
procedure IPSLibraryInfo(var LibraryInfo: PIPSLibraryInfo); stdcall;
begin

 LibraryInfo := @LibInfo;

end;

//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall;
{Modul registerfunktion
f�r jedes Modul(Device, Splitter muss ein Eintag existieren. Die Interface und Typinfo
sollten �ber units bekannt gemacht sein
}

begin

 vKernel := Kernel;
 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Register Build '+inttostr(LibInfo.mBuild));

 //Register Classes
 {ein Eintrag pro Modul. Es k�nnen auch mehrere Module in einer Library registriert werden
 alle Module landen dann in der gleichen DLL. Type und Interface m�ssen anschliessend
 im Modul definiert werden: Type=ObjektType in UDevice, Interface in ModulInterface
 Eine gute Praxis ist es, f�r jedes Device/Splitter eine eigene Unit anzulegen,
 so das innerhalb einer Unit nur mit einem Objekt gearbeitet werden muss
 Die PHP-Funktionen werden den als NamensPrefix den letzter Parameter haben}
 ModuleRegistry.RegisterModule(TIPSDevice, TypeInfo(IIPSDevice), 'MyDevice');

end;

//------------------------------------------------------------------------------
procedure IPSModuleUnregister(); stdcall;
begin

 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Unregister');
 vKernel := NIL;

end;

//==============================================================================
exports IPSLibraryInfo;

begin
 //
end.

