library fhzdummy;
//Thomas Dreﬂler (www.tdressler.net) 2011-2013
uses
  simplesharemem,
  sysutils,
  UIPSTypes,
  UIPSModuleTypes,
  UFHZDummyinterface in 'UFHZDummyinterface.pas',
  UFHZDummySplitter in 'UFHZDummySplitter.pas',
  UFHZtypes in 'UFHZtypes.pas',
  UThreadStringList in 'UThreadStringList.pas';

{$R *.res}

//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID      : 'ECB21704-CC7B-4C3A-97A7-97E6506B1BEC';
                                 mAuthor        : 'Thomas Dreﬂler';
                                 mURL           : 'www.tdressler.net';
                                 mName          : 'FHZDummy';
                                 mVersion       : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild         : {CompileBuild}78{/CompileBuild};
                                 mDate          : {CompileTime}0{/CompileTime};
                                 //--------------------------
                                 mKernelVersion : KERNEL_VERSION;
                                 //--------------------------
                                 fRegister      : IPSModuleRegister;
                                 fUnregister    : IPSModuleUnregister;
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
 vKernel.LogMessage(0,KL_MESSAGE, LibInfo.mName, 'Register Build '+inttostr(libinfo.mBuild));

 //Register Classes
 ModuleRegistry.RegisterModule(TIPSFHZDummy, TypeInfo(IIPSFHZDummy), 'FHZdummy');

end;

//------------------------------------------------------------------------------
procedure IPSModuleUnregister(); stdcall;
begin

 vKernel.LogMessage(0,KL_MESSAGE, LibInfo.mName, ('Unregister'));
 vKernel := NIL;

end;

//==============================================================================
exports IPSLibraryInfo;

begin
 //
end.

