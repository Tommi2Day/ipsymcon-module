library demologger;
// Demo-Library für IPS-Module
// Thomas Dreßler 2009-2012
// frei für private Nutzung

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
                                 mUniqueID    : '{30dec678-a21a-41f8-840b-cfd52a4a9436}'; //Für jedes Modul mit STRG-SHIFT-G neu erstellen !!
                                 //-------------------------- //nächste 3 Zeilen anpassen, Build muss leider Manuell hizugefügt werden
                                 mAuthor      : 'Thomas Dreßler';
                                 mURL         : 'www.ipsymcon.de';
                                 mName        : 'Demo Modul "Logger"';
                                 mVersion     : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild       : {CompileBuild}39{/CompileBuild};
                                 mDate        : {CompileTime}0{/CompileTime};
                                 //-------------------------- //nicht ändern!
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
für jedes Modul(Device, Splitter muss ein Eintag existieren. Die Interface und Typinfo
sollten über units bekannt gemacht sein
}

begin

 vKernel := Kernel;
 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Register Build '+inttostr(LibInfo.mBuild));

 //Register Classes
 {ein Eintrag pro Modul. Es können auch mehrere Module in einer Library registriert werden
 alle Module landen dann in der gleichen DLL. Type und Interface müssen anschliessend
 im Modul definiert werden: Type=ObjektType in UDevice, Interface in ModulInterface
 Eine gute Praxis ist es, für jedes Device/Splitter eine eigene Unit anzulegen,
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

