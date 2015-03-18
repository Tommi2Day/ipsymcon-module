library EM1010;
//Thomas Dreﬂler (www.tdressler.net) 2009-2013

uses
  simplesharemem,
  Windows,
  StrUtils,
  Classes,
  SysUtils,
  UIPSTypes,
  UIPSModuleTypes,
  portinc in 'portinc.pas',
  UEM1010 in 'UEM1010.pas',
  UEM1010interface in 'UEM1010interface.pas',
  UEM1010Device in 'UEM1010Device.pas',
  UEM1010hlp in 'UEM1010hlp.pas';

{$R *.res}


//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID    : '{8F8F5427-6942-4450-B58A-29EBA35171D8}';
                                 //--------------------------
                                 mAuthor      : 'Thomas Dreﬂler';
                                 mURL         : 'www.tdressler.net';
                                 mName        : 'EM1010';
                                 mVersion     : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild       : {CompileBuild}151{/CompileBuild};
                                 mDate        : {CompileTime}0{/CompileTime};
                                 //--------------------------
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
begin

 vKernel := Kernel;
 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Register Build '+inttostr(libinfo.mBuild));

 //Register Classes
 ModuleRegistry.RegisterModule(TIPSEM1010, TypeInfo(IIPSEM1010), 'EM1010PC');
 ModuleRegistry.RegisterModule(TIPSEM1010Device, TypeInfo(IIPSEM1010Device), 'EM1010Dev');

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

