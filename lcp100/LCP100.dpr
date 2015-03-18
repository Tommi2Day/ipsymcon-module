library LCP100;
//Thomas Dreﬂler (www.tdressler.net) 2010 - 2013
//Based on Code found on http://www.ip-symcon.de/forum/f30/lcd-colour-panel-lcp-100-a-8468/#post97947

uses
  simplesharemem,
  Windows,
  StrUtils,
  Classes,
  SysUtils,
  UIPSTypes,
  UIPSModuleTypes,
  CPDrv in 'CPDrv.pas',
  ULCP100interface in 'ULCP100interface.pas',
  LCP100_Cmd in 'LCP100_Cmd.pas',
  LCP100_CRC in 'LCP100_CRC.pas',
  LCP100_Frame in 'LCP100_Frame.pas',
  ULCP100Device in 'ULCP100Device.pas',
  LCP100i in 'LCP100i.pas';

{$R *.res}


//------------------------------------------------------------------------------
procedure IPSModuleRegister(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall; forward;
procedure IPSModuleUnregister(); stdcall; forward;

//------------------------------------------------------------------------------
const LibInfo: TIPSLibraryInfo = (
                                 mUniqueID    : '{90D38532-A108-4D36-AFD0-F9AEF5317DAD}';
                                 //--------------------------
                                 mAuthor      : 'Thomas Dreﬂler';
                                 mURL         : 'www.tdressler.net';
                                 mName        : 'LCP100';
                                 mVersion     : {CompileVersion}$030A{/CompileVersion}; { Hi - MajorV, Lo - MinorV =2.50}
                                 mBuild       : {CompileBuild}25{/CompileBuild};
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
 ModuleRegistry.RegisterModule(TIPSLCP100, TypeInfo(IIPSLCP100), 'LCP100');

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

