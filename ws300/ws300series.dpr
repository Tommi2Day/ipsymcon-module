library ws300series;
//Thomas Dreﬂler (www.tdressler.net) 2009 - 2013
uses
  simplesharemem,
  sysutils,
  UIPSTypes,
  UIPSModuleTypes,
  UWS300Device in 'UWS300Device.pas',
  UIPWESplitter in 'UIPWESplitter.pas',
  UWS300interface in 'UWS300interface.pas',
  RegExpr in 'RegExpr.pas',
  UIPSWDE1Splitter in 'UIPSWDE1Splitter.pas',
  UWS300Splitter in 'UWS300Splitter.pas',
  UIPSFS20WUESplitter in 'UIPSFS20WUESplitter.pas',
  UFHZtypes in 'UFHZtypes.pas',
  UThreadStringList in 'UThreadStringList.pas';

{$R *.res}

//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID      : '{6BC4A6DC-6AA1-4495-A6BC-6DB2EBA77B3F}';
                                 mAuthor        : 'Thomas Dreﬂler';
                                 mURL           : 'www.tdressler.net';
                                 mName          : 'WS300series';
                                 mVersion       : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV }
                                 mBuild         : {CompileBuild}103{/CompileBuild};
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
 ModuleRegistry.RegisterModule(TIPSIPWESplitter, TypeInfo(IIPSIPWESplitter), 'IPWE1');
 ModuleRegistry.RegisterModule(TIPSWS300Device, TypeInfo(IIPSWS300Device), 'WS300SENSOR');
 ModuleRegistry.RegisterModule(TIPSWS300Splitter, TypeInfo(IIPSWS300Splitter), 'WS300PC');
 ModuleRegistry.RegisterModule(TIPSWDE1Splitter, TypeInfo(IIPSWDE1Splitter), 'WDE1');
 ModuleRegistry.RegisterModule(TIPSFS20WUESplitter, TypeInfo(IIPSFS20WUESplitter), 'FS20WUE');

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

