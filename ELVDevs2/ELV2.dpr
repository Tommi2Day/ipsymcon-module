library ELV2;
//Thomas Dreﬂler (www.tdressler.net) 2009-2013

uses
  simplesharemem,
  Windows,
  StrUtils,
  Classes,
  SysUtils,
  UIPSTypes,
  UIPSModuleTypes,
  UELV2interface in 'UELV2interface.pas',
  UM232Device in 'UM232Device.pas',
  UULA200Device in 'UULA200Device.pas',
  UUAD8Device in 'UUAD8Device.pas',
  UUIO88Device in 'UUIO88Device.pas',
  USI1Device in 'USI1Device.pas',
  FS20PCS_Splitter in 'FS20PCS_Splitter.pas',
  UFHZtypes in 'UFHZtypes.pas',
  FS20PCE_Splitter in 'FS20PCE_Splitter.pas';

{$R *.res}


//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID    : '{C3627332-4F96-4DA4-AA4D-B7915B345A6D}';
                                 //--------------------------
                                 mAuthor      : 'Thomas Dreﬂler';
                                 mURL         : 'www.tdressler.net';
                                 mName        : 'ELV2';
                                 mVersion     : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV =2.50}
                                 mBuild       : {CompileBuild}83{/CompileBuild};
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
 vKernel.LogMessage(KL_MESSAGE, 0, LibInfo.mName, 'Register Build '+inttostr(LibInfo.mBuild));

 //Register Classes
 ModuleRegistry.RegisterModule(TIPSUIO88, TypeInfo(IIPSUIO88), 'UIO88');
 ModuleRegistry.RegisterModule(TIPSULA200, TypeInfo(IIPSULA200), 'ULA200');
 ModuleRegistry.RegisterModule(TIPSUAD8, TypeInfo(IIPSUAD8), 'UAD8');
 ModuleRegistry.RegisterModule(TIPSM232, TypeInfo(IIPSM232), 'M232');
 ModuleRegistry.RegisterModule(TIPSSI1, TypeInfo(IIPSSI1), 'SI1');
 ModuleRegistry.RegisterModule(TIPSFS20PCS, TypeInfo(IIPSFS20PCS), 'FS20PCS');
 ModuleRegistry.RegisterModule(TIPSFS20PCE, TypeInfo(IIPSFS20PCE), 'FS20PCE');
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

