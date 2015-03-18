unit UIPSTypes;

interface

uses Windows,
     Messages,
     SysUtils,
     Classes,
     TypInfo,
     IniFiles,                                                     
     RTTIUnit,
     ActiveX,
     Math,
     Variants,
     InvokeRegistry,
     gnugettext,
     Contnrs,
     StrUtils,
     superobject,
     SOAPConst;


threadvar
 //This Value specifies if the created object should be DataContext aware
 DataContextDisabled: Boolean;

const
 // --- KERNEL VERSION FOR SDK
 KERNEL_VERSION   = $030A;
 KERNEL_VERSION_COMPATIBLE = $030A; //requires 3.1 SDK

 // --- Important GUIDs
 IID_WildCard            : TGUID = '{FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF}';
 IID_Blank               : TGUID = '{00000000-0000-0000-0000-000000000000}';

 // --- Message Constants
 // --- BASE MESSAGE
 IPS_BASE = 10000;                             //Base Message

 IPS_KERNELSHUTDOWN = IPS_BASE + 1;            //Pre Shutdown Message, Runlevel UNINIT Follows
 IPS_KERNELSTARTED = IPS_BASE + 2;             //Post Ready Message

 // --- KERNEL
 IPS_KERNELMESSAGE = IPS_BASE + 100;           //Kernel Message
 KR_CREATE = IPS_KERNELMESSAGE + 1;            //Kernel is beeing created
 KR_INIT = IPS_KERNELMESSAGE + 2;              //Kernel Components are beeing initialised, Modules loaded, Settings read
 KR_READY = IPS_KERNELMESSAGE + 3;             //Kernel is ready and running
 KR_UNINIT = IPS_KERNELMESSAGE + 4;            //Got Shutdown Message, unloading all stuff
 KR_SHUTDOWN = IPS_KERNELMESSAGE + 5;          //Uninit Complete, Destroying Kernel Inteface

 IPS_LOGMESSAGE = IPS_BASE + 200;              //Logmessage Message
 KL_MESSAGE = IPS_LOGMESSAGE + 1;              //Normal Message                      | FG: Black | BG: White  | STLYE : NONE
 KL_SUCCESS = IPS_LOGMESSAGE + 2;              //Success Message                     | FG: Black | BG: Green  | STYLE : NONE
 KL_NOTIFY = IPS_LOGMESSAGE + 3;               //Notiy about Changes                 | FG: Black | BG: Blue   | STLYE : NONE
 KL_WARNING = IPS_LOGMESSAGE + 4;              //Warnings                            | FG: Black | BG: Yellow | STLYE : NONE
 KL_ERROR = IPS_LOGMESSAGE + 5;                //Error Message                       | FG: Black | BG: Red    | STLYE : BOLD
 KL_DEBUG = IPS_LOGMESSAGE + 6;                //Debug Informations + Script Results | FG: Grey  | BG: White  | STLYE : NONE
 KL_CUSTOM = IPS_LOGMESSAGE + 7;               //User Message                        | FG: Black | BG: White  | STLYE : NONE

 // --- MODULE LOADER
 IPS_MODULEMESSAGE = IPS_BASE + 300;           //ModuleLoader Message
 ML_LOAD = IPS_MODULEMESSAGE + 1;              //Module loaded
 ML_UNLOAD = IPS_MODULEMESSAGE + 2;            //Module unloaded

 // --- OBJECT MANAGER
 IPS_OBJECTMESSAGE = IPS_BASE + 400;
 OM_REGISTER = IPS_OBJECTMESSAGE + 1;          //Object was registered
 OM_UNREGISTER = IPS_OBJECTMESSAGE + 2;        //Object was unregistered
 OM_CHANGEPARENT = IPS_OBJECTMESSAGE + 3;      //Parent was Changed
 OM_CHANGENAME = IPS_OBJECTMESSAGE + 4;        //Name was Changed
 OM_CHANGEINFO = IPS_OBJECTMESSAGE + 5;        //Info was Changed
 OM_CHANGETYPE = IPS_OBJECTMESSAGE + 6;        //Type was Changed
 OM_CHANGESUMMARY = IPS_OBJECTMESSAGE + 7;     //Summary was Changed
 OM_CHANGEPOSITION = IPS_OBJECTMESSAGE + 8;    //Position was Changed
 OM_CHANGEREADONLY = IPS_OBJECTMESSAGE + 9;    //ReadOnly was Changed
 OM_CHANGEHIDDEN = IPS_OBJECTMESSAGE + 10;     //Hidden was Changed
 OM_CHANGEICON = IPS_OBJECTMESSAGE + 11;       //Icon was Changed
 OM_CHILDADDED = IPS_OBJECTMESSAGE + 12;       //Child for Object was added
 OM_CHILDREMOVED = IPS_OBJECTMESSAGE + 13;     //Child for Object was removed
 OM_CHANGEIDENT = IPS_OBJECTMESSAGE + 14;      //Ident was Changed

 // --- INSTANCE MANAGER
 IPS_INSTANCEMESSAGE = IPS_BASE + 500;         //Instance Manager Message
 IM_CREATE = IPS_INSTANCEMESSAGE + 1;          //Instance created
 IM_DELETE = IPS_INSTANCEMESSAGE + 2;          //Instance deleted
 IM_CONNECT = IPS_INSTANCEMESSAGE + 3;         //Instance connectged
 IM_DISCONNECT = IPS_INSTANCEMESSAGE + 4;      //Instance disconncted
 IM_CHANGESTATUS = IPS_INSTANCEMESSAGE + 5;    //Status was Changed
 IM_CHANGESETTINGS = IPS_INSTANCEMESSAGE + 6;  //Settings were Changed
 IM_CHANGESEARCH = IPS_INSTANCEMESSAGE + 7;    //Searching was started/stopped
 IM_SEARCHUPDATE = IPS_INSTANCEMESSAGE + 8;    //Searching found new results
 IM_SEARCHPROGRESS = IPS_INSTANCEMESSAGE + 9;  //Searching progress in %
 IM_SEARCHCOMPLETE = IPS_INSTANCEMESSAGE + 10; //Searching is complete

 // --- VARIABLE MANAGER
 IPS_VARIABLEMESSAGE = IPS_BASE + 600;              //Variable Manager Message
 VM_CREATE = IPS_VARIABLEMESSAGE + 1;               //Variable Created
 VM_DELETE = IPS_VARIABLEMESSAGE + 2;               //Variable Deleted
 VM_UPDATE = IPS_VARIABLEMESSAGE + 3;               //On Variable Update
 VM_CHANGEPROFILENAME = IPS_VARIABLEMESSAGE + 4;    //On Profile Name Change
 VM_CHANGEPROFILEACTION = IPS_VARIABLEMESSAGE + 5;  //On Profile Action Change

 // --- SCRIPT MANAGER
 IPS_SCRIPTMESSAGE = IPS_BASE + 700;           //Script Manager Message
 SM_CREATE = IPS_SCRIPTMESSAGE + 1;            //On Script Create
 SM_DELETE = IPS_SCRIPTMESSAGE + 2;            //On Script Delete
 SM_CHANGEFILE = IPS_SCRIPTMESSAGE + 3;        //On Script File changed
 SM_BROKEN = IPS_SCRIPTMESSAGE + 4;            //Script Broken Status changed

 // --- EVENT MANAGER
 IPS_EVENTMESSAGE = IPS_BASE + 800;             //Event Scripter Message
 EM_CREATE = IPS_EVENTMESSAGE + 1;             //On Event Create
 EM_DELETE = IPS_EVENTMESSAGE + 2;             //On Event Delete
 EM_UPDATE = IPS_EVENTMESSAGE + 3;
 EM_CHANGEACTIVE = IPS_EVENTMESSAGE + 4;
 EM_CHANGELIMIT = IPS_EVENTMESSAGE + 5;
 EM_CHANGESCRIPT = IPS_EVENTMESSAGE + 6;
 EM_CHANGETRIGGER = IPS_EVENTMESSAGE + 7;
 EM_CHANGETRIGGERVALUE = IPS_EVENTMESSAGE + 8;
 EM_CHANGETRIGGEREXECUTION = IPS_EVENTMESSAGE + 9;
 EM_CHANGECYCLIC = IPS_EVENTMESSAGE + 10;
 EM_CHANGECYCLICDATEFROM = IPS_EVENTMESSAGE + 11;
 EM_CHANGECYCLICDATETO = IPS_EVENTMESSAGE + 12;
 EM_CHANGECYCLICTIMEFROM = IPS_EVENTMESSAGE + 13;
 EM_CHANGECYCLICTIMETO = IPS_EVENTMESSAGE + 14;

 // --- MEDIA MANAGER
 IPS_MEDIAMESSAGE = IPS_BASE + 900;           //Media Manager Message
 MM_CREATE = IPS_MEDIAMESSAGE + 1;             //On Media Create
 MM_DELETE = IPS_MEDIAMESSAGE + 2;             //On Media Delete
 MM_CHANGEFILE = IPS_MEDIAMESSAGE + 3;         //On Media File changed
 MM_AVAILABLE = IPS_MEDIAMESSAGE + 4;          //Media Available Status changed
 MM_UPDATE = IPS_MEDIAMESSAGE + 5;

 // --- LINK MANAGER
 IPS_LINKMESSAGE = IPS_BASE + 1000;           //Link Manager Message
 LM_CREATE = IPS_LINKMESSAGE + 1;             //On Link Create
 LM_DELETE = IPS_LINKMESSAGE + 2;             //On Link Delete
 LM_CHANGETARGET = IPS_LINKMESSAGE + 3;       //On Link TargetID change
  
 // --- DATA HANDLER
 IPS_DATAMESSAGE = IPS_BASE + 1100;             //Data Handler Message
 DM_CONNECT = IPS_DATAMESSAGE + 1;             //On Instance Connect
 DM_DISCONNECT = IPS_DATAMESSAGE + 2;          //On Instance Disconnect

 // --- SCRIPT ENGINE
 IPS_ENGINEMESSAGE = IPS_BASE + 1200;           //Script Engine Message
 SE_UPDATE = IPS_ENGINEMESSAGE + 1;             //On Library Refresh
 SE_EXECUTE = IPS_ENGINEMESSAGE + 2;            //On Script Finished execution
 SE_RUNNING = IPS_ENGINEMESSAGE + 3;            //On Script Started execution

 // --- PROFILE POOL
 IPS_PROFILEMESSAGE = IPS_BASE + 1300;
 PM_CREATE = IPS_PROFILEMESSAGE + 1;
 PM_DELETE = IPS_PROFILEMESSAGE + 2;
 PM_CHANGETEXT = IPS_PROFILEMESSAGE + 3;
 PM_CHANGEVALUES = IPS_PROFILEMESSAGE + 4;
 PM_CHANGEDIGITS = IPS_PROFILEMESSAGE + 5;
 PM_CHANGEICON = IPS_PROFILEMESSAGE + 6;
 PM_ASSOCIATIONADDED = IPS_PROFILEMESSAGE + 7;
 PM_ASSOCIATIONREMOVED = IPS_PROFILEMESSAGE + 8;
 PM_ASSOCIATIONCHANGED = IPS_PROFILEMESSAGE + 9;

 // --- TIMER POOL
 IPS_TIMERMESSAGE = IPS_BASE + 1400;            //Timer Pool Message
 //TM_REGISTER = IPS_TIMERMESSAGE + 1;
 //TM_UNREGISTER = IPS_TIMERMESSAGE + 2;
 //TM_SETINTERVAL = IPS_TIMERMESSAGE + 3;
 //TM_UPDATE = IPS_TIMERMESSAGE + 4;
 //TM_RUNNING = IPS_TIMERMESSAGE + 5;
 
 // --- TInstanceStatus Constants

 // --- STATUS CODES
 IS_SBASE        = 100;
 IS_CREATING     = IS_SBASE + 1; //module is being created
 IS_ACTIVE       = IS_SBASE + 2; //module created and running
 IS_DELETING     = IS_SBASE + 3; //module us being deleted
 IS_INACTIVE     = IS_SBASE + 4; //module is not beeing used

 // --- ERROR CODES
 IS_EBASE        = 200;          //default errorcode
 IS_NOTCREATED   = IS_EBASE + 1; //instance could not be created

 // --- Search Handling
 FOUND_UNKNOWN = 0;     //Undefined value
 FOUND_NEW = 1;         //Device is new and not configured yet
 FOUND_OLD = 2;         //Device is already configues (InstanceID should be set)
 FOUND_CURRENT = 3;     //Device is already configues (InstanceID is from the current/searching Instance)
 FOUND_UNSUPPORTED = 4; //Device is not supported by Module

 type
// --- Basic Structures
 TUnixTime = Integer;

 { ID Types }
 TIPSID = Word;
 TIPSIDs = Array of TIPSID;

 { Localization }
 TCategoryID = TIPSID;
 TCategoryIDs = Array of TCategoryID;
 TInstanceID = TIPSID;
 TInstanceIDs = Array of TInstanceID;
 TVariableID = TIPSID;
 TVariableIDs = Array of TVariableID;
 TScriptID = TIPSID;
 TScriptIDs = Array of TScriptID;
 TEventID = TIPSID;
 TEventIDs = Array of TEventID;
 TFormID = TIPSID;
 TFormIDs = Array of TFormID;
 TMediaID = TIPSID;
 TMediaIDs = Array of TMediaID;
 TLinkID = TIPSID;
 TLinkIDs = Array of TLinkID;
 TThreadID = Integer;
 TThreadIDs = Array of TThreadID;

 //TimerID's are not handled as IP-Symcon Objects
 TTimerID = Word;
 TTimerIDs = Array of TTimerID;

 TTimerEvent = procedure of object;

 { Array of Variant's }
 TVariantArray = Array of Variant;

 { Array of String }
 TStringArray = Array of String;

 { String GUIDs }
 TStrGUID = String;
 TStrGUIDs = TStringArray;

 { Possible Object Types }
 TIPSObjectType = (otCategory, otInstance, otVariable, otScript, otEvent, otMedia, otLink);

 { Possible Module Types }
 TIPSModuleType = (mtCore, mtIO, mtSplitter, mtDevice, mtConfigurator);
 TModuleTypes = set of TIPSModuleType;

 //Forward declarations
 IIPSKernel = interface;
 IIPSModuleRegistry = interface;
 {$METHODINFO ON}
 IIPSModule = interface;
 IIPSSimpleKernel = interface;
 IIPSLicensePool = interface;
 IIPSModuleLoader = interface;
 IIPSObjectManager = interface;
 IIPSCategoryManager = interface;
 IIPSVariableManager = interface;
 IIPSInstanceManager = interface;
 IIPSScriptManager = interface;
 IIPSEventManager = interface;
 IIPSMediaManager = interface;
 IIPSLinkManager = interface;
 IIPSScriptEngine = interface;
 IIPSTimerPool = interface;
 IIPSDiscoveryServer = interface;
 IIPSProfilePool = interface;
 IIPSDataHandler = interface;
 IIPSSOAPServer = interface;
 IIPSDebugServer = interface;
 IIPSSettings = interface;
 {$METHODINFO OFF}
 IIPSModuleLoaderEx = interface;
 IIPSObjectManagerEx = interface;
 IIPSCategoryManagerEx = interface;
 IIPSVariableManagerEx = interface;
 IIPSInstanceManagerEx = interface;
 IIPSScriptManagerEx = interface;
 IIPSEventManagerEx = interface;
 IIPSMediaManagerEx = interface;
 IIPSLinkManagerEx = interface;
 IIPSScriptEngineEx = interface;
 IIPSTimerPoolEx = interface;
 IIPSDiscoveryServerEx = interface;
 IIPSProfilePoolEx = interface;
 IIPSDataHandlerEx = interface;
 IIPSDebugServerEx = interface;
 IIPSSettingsEx = interface;
 IIPSLicensePoolEx = interface;

 TIPSModuleObject = class;
 TIPSModuleClass = class of TIPSModuleObject;

 TIPSCallableObject = class;
 TIPSCallableClass = class of TIPSCallableObject;

//------------------------------------------------------------------------------
// Basic Types
//------------------------------------------------------------------------------
 TIPSRemotable = class(TRemotable)
  public
   constructor Create; override;
 end;

//------------------------------------------------------------------------------
// Message Handling
//------------------------------------------------------------------------------
 { Message Record }
 TIPSMessage = class(TIPSRemotable)
  private
   FTimeStamp : Integer;
   FSenderID  : TIPSID;
   FMessage   : Integer;
   FData      : Variant;
  public
   constructor Create(SenderID: TIPSID; Message: Integer; Data: Array of Const); reintroduce; overload;
   constructor Create(Msg: TIPSMessage); reintroduce; overload;
  published
   property TimeStamp : Integer read FTimeStamp write FTimeStamp;
   property SenderID  : TIPSID read FSenderID;
   property Message   : Integer read FMessage;
   property Data      : Variant read FData write FData;
 end;
 TIPSMessages = Array of TIPSMessage;

//------------------------------------------------------------------------------
// Module DLL Exports
//------------------------------------------------------------------------------
 { Module Register Call }
 TFModuleRegister    = procedure(Kernel: IIPSKernel; ModuleRegistry: IIPSModuleRegistry); stdcall;
 { Module Unregister Call }
 TFModuleUnregister  = procedure(); stdcall;

//------------------------------------------------------------------------------
// Module Handling
//------------------------------------------------------------------------------
 PIPSLibraryInfo = ^TIPSLibraryInfo;
 TIPSLibraryInfo = record
  mUniqueID      : TStrGUID;
  mAuthor        : String;
  mURL           : String;
  mName          : String;
  mVersion       : Word;                                                        { HiByte - MajorV, LoByte - MinorV }
  mBuild         : Word;                                                        { 0 - 65535 }
  mDate          : TUnixTime;                                                   { Build Date }
  //--------------------------------
  { Defines the Kernel Version the Module was compiled for }
  mKernelVersion : Integer;
  //--------------------------------
  fRegister      : TFModuleRegister;
  fUnregister    : TFModuleUnregister;
 end;

 { Must be EXPORTED by a Module }
 TFLibraryInfo = procedure(var LibraryInfo: PIPSLibraryInfo); stdcall;

 TIPSLibraryInformation = class(TIPSRemotable)
  private
   FLibraryID : TStrGUID;
   FAuthor   : String;
   FURL      : String;
   FName     : String;
   FVersion  : Word;
   FBuild    : Word;
   FDate     : TUnixTime;
  published
   property LibraryID : TStrGUID read FLibraryID write FLibraryID;
   property Author    : String read FAuthor write FAuthor;
   property URL       : String read FURL write FURL;
   property Name      : String read FName write FName;
   property Version   : Word read FVersion write FVersion;
   property Build     : Word read FBuild write FBuild;
   property Date      : TUnixTime read FDate write FDate;
 end;
 TIPSLibraryInformations = Array of TIPSLibraryInformation;

 TIPSBasicModuleInformation = class(TIPSRemotable)
  private
  { Used to requery/ident parent }
   FModuleID    : TStrGUID;
  { Used to show some userinfo while module isn't loaded but involved }
   FModuleName  : ShortString;
  { Possible Module Types }
   FModuleType  : TIPSModuleType;
  published
   property ModuleID   : TStrGUID read FModuleID write FModuleID;
   property ModuleName : ShortString read FModuleName write FModuleName;
   property ModuleType : TIPSModuleType read FModuleType write FModuleType;
 end;
 TIPSBasicModuleInformations = Array of TIPSBasicModuleInformation;


 TIPSModuleInformation = class(TIPSBasicModuleInformation)
  private
  { Used to requery/ident parent }
   FModuleID    : TStrGUID;
  { Used to show some userinfo while module isn't loaded but involved }
   FModuleName  : ShortString;
  { Possible Module Types }
   FModuleType  : TIPSModuleType;
  { More Information }
   FParentRequirements : TStrGUIDs;
   FChildRequirements  : TStrGUIDs;
   FImplemented : TStrGUIDs;
   FVendor      : String;
   FAliases     : TStringArray;
   { Linked Library }
   FLibraryID   : TStrGUID;
  published
   property ModuleID   : TStrGUID read FModuleID write FModuleID;
   property ModuleName : ShortString read FModuleName write FModuleName;
   property ModuleType : TIPSModuleType read FModuleType write FModuleType;
   property ParentRequirements : TStrGUIDs read FParentRequirements write FParentRequirements;
   property ChildRequirements : TStrGUIDs read FChildRequirements write FChildRequirements;
   property Implemented : TStrGUIDs read FImplemented write FImplemented;
   property Vendor : String read FVendor write FVendor;
   property Aliases : TStringArray read FAliases write FAliases;
   property LibraryID : TStrGUID read FLibraryID write FLibraryID;
 end;
 TIPSModuleInformations = Array of TIPSModuleInformation;

//------------------------------------------------------------------------------
// Object Handling
//------------------------------------------------------------------------------
 TIPSObject = class(TIPSRemotable)
  private
   FParentID       : TIPSID;
   FObjectID       : TIPSID;
   FObjectType     : TIPSObjectType;
   FObjectIdent    : String;
   FObjectName     : String;
   FObjectInfo     : String;
   FObjectIcon     : String;
   FObjectSummary  : String; //Will not be saved!
   FObjectPosition : Integer;

   FObjectIsReadOnly : Boolean;
   FObjectIsHidden   : Boolean;

   //Special Fields for faster SOAP Access
   FHasChildren    : Boolean;
   FChildrenIDs    : TIPSIDs;
  published
   property ParentID         : TIPSID read FParentID write FParentID;
   property ObjectID         : TIPSID read FObjectID write FObjectID;
   property ObjectType       : TIPSObjectType read FObjectType write FObjectType;
   property ObjectIdent      : String read FObjectIdent write FObjectIdent;
   property ObjectName       : String read FObjectName write FObjectName;
   property ObjectInfo       : String read FObjectInfo write FObjectInfo;
   property ObjectIcon       : String read FObjectIcon write FObjectIcon;
   property ObjectSummary    : String read FObjectSummary write FObjectSummary;
   property ObjectPosition   : Integer read FObjectPosition write FObjectPosition;
   property ObjectIsReadOnly : Boolean read FObjectIsReadOnly write FObjectIsReadOnly;
   property ObjectIsHidden   : Boolean read FObjectIsHidden write FObjectIsHidden;
   //Special Properties for faster SOAP Access
   property HasChildren      : Boolean read FHasChildren write FHasChildren;
   property ChildrenIDs      : TIPSIDs read FChildrenIDs write FChildrenIDs;
 end;
 TIPSObjects = Array of TIPSObject;

//------------------------------------------------------------------------------
// Category Handling
//------------------------------------------------------------------------------
 TIPSCategory = class(TIPSRemotable)
  private
   FCategoryID         : TIPSID;
   FCategoryBackground : TMediaID;
  published
   property CategoryID         : TIPSID read FCategoryID write FCategoryID;
   property CategoryBackground : TMediaID read FCategoryBackground write FCategoryBackground;
 end;
 TIPSCategorys = Array of TIPSCategory;

//------------------------------------------------------------------------------
// Instance Handling
//------------------------------------------------------------------------------
 TIPSInterfaceStatus = Integer;

 TIPSInstance = class(TIPSRemotable)
  private
   { Identify the Instance }
   FInstanceID        : TInstanceID;
   { Data Connection to a Splitter/IO Interface }
   FConnectionID      : TInstanceID;
   { Interface instance of a Module }
   FInstanceStatus    : TIPSInterfaceStatus;
   { Instance Changed }
   FLastChange        : TUnixTime;
   { Copy of Persistent needed Informations }
   FModuleInfo        : TIPSBasicModuleInformation;
   { Not avaiable via SOAP/PHP }
   FInstanceInterface : IIPSModule;
  public
   constructor Create; override;
   destructor Destroy; override;
   property InstanceInterface : IIPSModule read FInstanceInterface write FInstanceInterface;
  published
   property InstanceID        : TInstanceID read FInstanceID write FInstanceID;
   property ConnectionID      : TInstanceID read FConnectionID write FConnectionID;
   property InstanceStatus    : TIPSInterfaceStatus read FInstanceStatus write FInstanceStatus;
   property LastChange        : TUnixTime read FLastChange write FLastChange;
   property ModuleInfo        : TIPSBasicModuleInformation read FModuleInfo write FModuleInfo;
 end;
 TIPSInstances = Array of TIPSInstance;

//------------------------------------------------------------------------------
// Variable Handling
//------------------------------------------------------------------------------
 TIPSVarType = (vtBoolean, vtInteger, vtFloat, vtString, vtVariant, vtArray);
 TIPSVarTypes = set of TIPSVarType;

 TIPSVarIndexType = (itInt, itStr);

 TIPSVarIndex = class(TIPSRemotable)
  private
   FIndexType : TIPSVarIndexType;
   FIndexInt  : Integer;
   FIndexStr  : String;
  published
   property IndexType : TIPSVarIndexType read FIndexType write FIndexType;
   property IndexInt  : Integer read FIndexInt write FIndexInt;
   property IndexStr  : String read FIndexStr write FIndexStr;
 end;
 
 TIPSVarValue = class;
 TIPSVarValues = Array of TIPSVarValue;
 TIPSVarValue = class(TIPSRemotable)
  private
   FValueIndex   : TIPSVarIndex;
   FValueType    : TIPSVarType;
   FValueBoolean : Boolean;
   FValueInteger : Integer;
   FValueFloat   : Double;
   FValueString  : String;
   FValueVariant : Variant;
   FValueArray   : TIPSVarValues;  { Array Support }
   function PrepareAndCheckArrayEx(IndexType: TIPSVarIndexType; Name: String; Index: Integer): Integer;
   function PrepareAndCheckArrayStr(Name: String = ''): Integer;
   function PrepareAndCheckArrayInt(Index: Integer = -1): Integer;
  public
   constructor Create; override;
   destructor Destroy; override;

   procedure AddIndexedBool(Value: Boolean; Index: Integer = -1);
   procedure AddIndexedInt(Value: Integer; Index: Integer = -1);
   procedure AddIndexedFloat(Value: Double; Index: Integer = -1);
   procedure AddIndexedStr(Value: String; Index: Integer = -1);
   procedure AddIndexedVariant(Value: Variant; Index: Integer = -1);
   function  AddIndexedArray(Index: Integer = -1): TIPSVarValue;
   procedure AddNamedBool(Name: String; Value: Boolean);
   procedure AddNamedInt(Name: String; Value: Integer);
   procedure AddNamedFloat(Name: String; Value: Double);
   procedure AddNamedStr(Name: String; Value: String);
   procedure AddNamedVariant(Name: String; Value: Variant);
   function  AddNamedArray(Name: String): TIPSVarValue;
  published
   property ValueIndex   : TIPSVarIndex read FValueIndex write FValueIndex;
   property ValueType    : TIPSVarType read FValueType write FValueType;
   property ValueBoolean : Boolean read FValueBoolean write FValueBoolean;
   property ValueInteger : Integer read FValueInteger write FValueInteger;
   property ValueFloat   : Double read FValueFloat write FValueFloat;
   property ValueString  : String read FValueString write FValueString;
   property ValueVariant : Variant read FValueVariant write FValueVariant;
   property ValueArray   : TIPSVarValues read FValueArray write FValueArray;
 end;

 TIPSValueAssociation = class(TIPSRemotable)
  private
   FValue : Double;
   FName  : String;
   FIcon  : String;
   FColor : Integer; //>= 0 -> RGB | < 0 -> No Color
  published
   property Value : Double read FValue write FValue;
   property Name  : String read FName write FName;
   property Icon  : String read FIcon write FIcon;
   property Color : Integer read FColor write FColor;
 end;
 TIPSValueAssociations = Array of TIPSValueAssociation;

 TIPSVarProfile = class(TIPSRemotable)
  private
   FProfileName  : String;
   FProfileType  : TIPSVarType;
   FPrefix       : String;
   FSuffix       : String;
   { Int/Float Only }
   FMinValue     : Double;
   FMaxValue     : Double;
   FStepSize     : Double;
   { Float only }
   FDigits       : Integer;
   { Bool/Int only [0=False,1=True] }
   FAssociations : TIPSValueAssociations;
   { Icon }
   FIcon         : String;
   { Flags }
   FReadOnly     : Boolean;
  public
   { Default destructor }
   destructor Destroy; override;
   { Special constructors }
   constructor CreateBooleanProfile(Name, Icon, TrueName, TrueIcon:String; TrueColor: Integer; FalseName, FalseIcon: String; FalseColor: Integer); reintroduce;
   constructor CreateIntegerProfile(Name, Icon, Prefix, Suffix: String; MinValue, MaxValue, StepSize: Integer); reintroduce;
   constructor CreateIntegerProfileEx(Name, Icon, Prefix, Suffix: String; Associations: TIPSValueAssociations); reintroduce;
   constructor CreateFloatProfile(Name, Icon, Prefix, Suffix: String; MinValue, MaxValue, StepSize: Double; Digits: Integer); reintroduce;
   constructor CreateFloatProfileEx(Name, Icon, Prefix, Suffix: String; Digits: Integer; Associations: TIPSValueAssociations); reintroduce;
   constructor CreateStringProfile(Name, Icon, Prefix, Suffix: String); reintroduce;
  published
   property ProfileName  : String read FProfileName write FProfileName;
   property ProfileType  : TIPSVarType read FProfileType write FProfileType;
   property Icon         : String read FIcon write FIcon;
   property Prefix       : String read FPrefix write FPrefix;
   property Suffix       : String read FSuffix write FSuffix;
   property MinValue     : Double read FMinValue write FMinValue;
   property MaxValue     : Double read FMaxValue write FMaxValue;
   property StepSize     : Double read FStepSize write FStepSize;
   property Digits       : Integer read FDigits write FDigits;
   property Associations : TIPSValueAssociations read FAssociations write FAssociations;
   property IsReadOnly   : Boolean read FReadOnly write FReadOnly;
 end;
 TIPSVarProfiles = Array of TIPSVarProfile;

 TIPSVariable = class(TIPSRemotable)
  private
   { Identify the Variable }
   FVariableID               : TVariableID;
   { Variable Configuration }
   FVariableProfile          : String;			  //System
   FVariableAction           : TInstanceID;		//System
   FVariableCustomProfile    : String;
   FVariableCustomAction     : TScriptID;
   FVariableUpdated          : TUnixTime;
   FVariableChanged          : TUnixTime;
   { Variable Value + Type }
   FVariableValue            : TIPSVarValue;
   { Variable Flag }
   FVariableIsBinary         : Boolean;
   { Variable Notify Settings }
   FVariableLocked           : Boolean;
  public
   constructor Create; override;
   destructor Destroy; override;
  published
   { Identify the Variable }
   property VariableID               : TVariableID read FVariableID write FVariableID;
   { Variable Configuration }
   property VariableProfile          : String read FVariableProfile write FVariableProfile;
   property VariableAction           : TInstanceID read FVariableAction write FVariableAction;
   property VariableCustomProfile    : String read FVariableCustomProfile write FVariableCustomProfile;
   property VariableCustomAction     : TScriptID read FVariableCustomAction write FVariableCustomAction;
   { Variable Timestamps }
   property VariableUpdated          : TUnixTime read FVariableUpdated write FVariableUpdated;
   property VariableChanged          : TUnixTime read FVariableChanged write FVariableChanged;
   { Variable Value + Type }
   property VariableValue            : TIPSVarValue read FVariableValue write FVariableValue;
   { Variable Flag }
   property VariableIsBinary         : Boolean read FVariableIsBinary write FVariableIsBinary;
   { Licensing }
   property VariableIsLocked         : Boolean read FVariableLocked write FVariableLocked;
 end;
 TIPSVariables = Array of TIPSVariable;

//------------------------------------------------------------------------------
// Event Handling
//------------------------------------------------------------------------------
 TIPSEventType = (etTrigger, etCyclic);

 TIPSTriggerType = (evtOnUpdate, evtOnChange, evtOnLimitExceed, evtOnLimitDrop, evtOnValue);
 TIPSCyclicDateType = (cdtNone, cdtOnce, cdtDay, cdtWeek, cdtMonth, cdtYear);
 TIPSCyclicTimeType = (cttOnce, cttSecond, cttMinute, cttHour, cttSpecial);

 TIPSEventDate = class(TIPSRemotable)
  private
   FDay: Integer;
   FMonth: Integer;
   FYear: Integer;
  published
   property Day: Integer read FDay write FDay;
   property Month: Integer read FMonth write FMonth;
   property Year: Integer read FYear write FYear;
 end;

 TIPSEventTime = class(TIPSRemotable)
  private
   FHour: Integer;
   FMinute: Integer;
   FSecond: Integer;
  published
   property Hour: Integer read FHour write FHour;
   property Minute: Integer read FMinute write FMinute;
   property Second: Integer read FSecond write FSecond;
 end; 

 TIPSEvent=class(TIPSRemotable)
  private
   FEventID: TIPSID;
   FEventType: TIPSEventType;
   FEventActive: Boolean;                 //Active/Inactive
   FEventLimit: Integer;                  //0 = Unlimited, >0 Times left
   //---
   FTriggerType: TIPSTriggerType;
   FTriggerVariableID: TVariableID;
   FTriggerValue: Variant;
   FTriggerSubsequentExecution: Boolean;
   //---
   FCyclicDateType: TIPSCyclicDateType;
   FCyclicDateFrom: TIPSEventDate;        //Timer Valid from, 00/00/0000 = NOW
   FCyclicDateTo: TIPSEventDate;          //Timer Valid to, 00/00/0000 = ENDLESS
   FCyclicDateValue: Integer;             //Each x {Day, Week, Month, Year}
   FCyclicDateDay: Integer;               //Each Mon(2^0), Tue(2^1), Wed(2^2)...
   FCyclicDateDayValue: Integer;          //Each x "DateDay" Day
   //---
   FCyclicTimeType: TIPSCyclicTimeType;
   FCyclicTimeFrom: TIPSEventTime;        //Timer Valid from, 00:00:00 = NOW
   FCyclicTimeTo: TIPSEventTime;          //Timer Valid to, 00:00:00 = ENDLESS
   FCyclicTimeValue: Integer;             //Each x {Second,Minute...}
   //---
   FEventScript: String;
   FLastRun: TUnixTime;                   //0 = NEVER
   FNextRun: TUnixTime;
  public
   constructor Create; override;
   destructor Destroy; override;
  published
   //Properties
   property EventID       : TIPSID read FEventID write FEventID;
   property EventType     : TIPSEventType read FEventType write FEventType;
   property EventActive   : Boolean read FEventActive write FEventActive;
   property EventLimit    : Integer read FEventLimit write FEventLimit;

   property TriggerType : TIPSTriggerType read FTriggerType write FTriggerType;
   property TriggerVariableID : TVariableID read FTriggerVariableID write FTriggerVariableID;
   property TriggerValue    : Variant read FTriggerValue write FTriggerValue;
   property TriggerSubsequentExecution: Boolean read FTriggerSubsequentExecution write FTriggerSubsequentExecution;

   property CyclicDateType  : TIPSCyclicDateType read FCyclicDateType write FCyclicDateType;
   property CyclicDateFrom  : TIPSEventDate read FCyclicDateFrom write FCyclicDateFrom;
   property CyclicDateTo    : TIPSEventDate read FCyclicDateTo write FCyclicDateTo;
   property CyclicDateValue : Integer read FCyclicDateValue write FCyclicDateValue;
   property CyclicDateDay      : Integer read FCyclicDateDay write FCyclicDateDay;
   property CyclicDateDayValue : Integer read FCyclicDateDayValue write FCyclicDateDayValue;

   property CyclicTimeType  : TIPSCyclicTimeType read FCyclicTimeType write FCyclicTimeType;
   property CyclicTimeFrom  : TIPSEventTime read FCyclicTimeFrom write FCyclicTimeFrom;
   property CyclicTimeTo    : TIPSEventTime read FCyclicTimeTo write FCyclicTimeTo;
   property CyclicTimeValue : Integer read FCyclicTimeValue write FCyclicTimeValue;

   property EventScript     : String read FEventScript write FEventScript;
   property LastRun : TUnixTime read FLastRun write FLastRun;
   property NextRun : TUnixTime read FNextRun write FNextRun;
 end;
 TIPSEvents = Array of TIPSEvent;

//------------------------------------------------------------------------------
// Script Handling
//------------------------------------------------------------------------------
 TIPSScriptType = (stPHPScript, stMacroScript, stBrickScript);

 TIPSScript = class(TIPSRemotable)
  private
   { Identify the Script }
   FScriptID    : TScriptID;
   { Script Configuration }
   FScriptType  : TIPSScriptType;
   FScriptFile  : String;
   FIsBroken    : Boolean;    //Will be set to TRUE if an Error occours and FALSE by the next successful run
   FLastExecute : TUnixTime;
  published
   { Identify the Script }
   property ScriptID    : TScriptID read FScriptID write FScriptID;
   { Script Configuration }
   property ScriptType  : TIPSScriptType read FScriptType write FScriptType;
   property ScriptFile  : String read FScriptFile write FScriptFile;
   property IsBroken    : Boolean read FIsBroken write FIsBroken;              //Will be set to TRUE if an Error occours and FALSE by the next successful run
   property LastExecute : TUnixTime read FLastExecute write FLastExecute;
 end;
 TIPSScripts = Array of TIPSScript;

//------------------------------------------------------------------------------
// Script Function/Data Handling
//------------------------------------------------------------------------------
 TIPSPHPVariableType = (pvtIPS, pvtSERVER, pvtGET, pvtPOST, pvtCOOKIE);

 TIPSPHPVariable = class(TIPSRemotable)
  private
   FVariableName : String;
   FVariableType : TIPSPHPVariableType;
   FVariableValue: TIPSVarValue;
  public
   constructor Create; override;
   constructor CreateNamed(Name: String); reintroduce;
   constructor CreateBool(Name: String; Value: Boolean); reintroduce;
   constructor CreateInt(Name: String; Value: Integer); reintroduce;
   constructor CreateFloat(Name: String; Value: Double); reintroduce;
   constructor CreateStr(Name: String; Value: String); reintroduce;  
   destructor Destroy; override;   
  published
   property VariableName : String read FVariableName write FVariableName;
   property VariableType : TIPSPHPVariableType read FVariableType write FVariableType;
   property VariableValue: TIPSVarValue read FVariableValue write FVariableValue;
 end;
 TIPSPHPVariables = Array of TIPSPHPVariable; 

 TIPSPHPParameter = TIPSVarValue;
 TIPSPHPParameters = TIPSVarValues;

 TIPSPHPExecute = procedure(FunctionName    : String;
                            Parameters      : TIPSPHPParameters;
                            var ReturnValue : TIPSPHPParameter) of Object;

 TIPSPHPResultType = TIPSVarType;
 TIPSPHPParameterInfo = class(TIPSRemotable)
  private
   FDescription : String;
   FType        : TIPSPHPResultType;
   FEnumeration : TStringArray;
  published
   property Description : String read FDescription write FDescription;
   property Type_ : TIPSPHPResultType read FType write FType;
   property Enumeration : TStringArray read FEnumeration write FEnumeration;
 end;
 TIPSPHPParameterInfos = Array of TIPSPHPParameterInfo;

 TIPSPHPInstance = class(TIPSRemotable)
  private
   FInstanceID      : TInstanceID;
   FSingleton       : Boolean;
   FFunctionHandler : TIPSPHPExecute;
  public 
   property FunctionHandler : TIPSPHPExecute read FFunctionHandler write FFunctionHandler;
  published
   property InstanceID : TInstanceID read FInstanceID write FInstanceID;
   property Singleton  : Boolean read FSingleton write FSingleton;
 end;
 TIPSPHPInstances = Array of TIPSPHPInstance;

 TIPSPHPFunction = class(TIPSRemotable)
  protected
   FFunctionName : String;
   FParameters   : TIPSPHPParameterInfos;
   FResult       : TIPSPHPParameterInfo;
   FPHPInstances : TIPSPHPInstances;
   function GetParameters : TIPSPHPParameterInfos; virtual;
   procedure SetParameters(Value: TIPSPHPParameterInfos); virtual;
   function GetInstances: TIPSPHPInstances; virtual;
   procedure SetInstances(Value: TIPSPHPInstances); virtual;
  public
   constructor Create; override;
   destructor Destroy; override;
   property Instances    : TIPSPHPInstances read GetInstances write SetInstances;
  published
   property FunctionName : String read FFunctionName write FFunctionName;
   property Parameters   : TIPSPHPParameterInfos read GetParameters write SetParameters;
   property Result       : TIPSPHPParameterInfo read FResult write FResult;
 end;
 TIPSPHPFunctions = Array of TIPSPHPFunction;
 
//------------------------------------------------------------------------------
// Script Result Handling
//------------------------------------------------------------------------------
 TIPSExecuteInfo = class;
 
 TReqMethod = (rmGET, rmPOST);
 TOnNewContent = procedure(Content: String; Data: TIPSExecuteInfo) of object; 

 TIPSExecuteInfo = class(TIPSRemotable)
  private
   //Input
   FRequestMethod   : TReqMethod;
   FQueryString     : String;
   FServerVariables : TIPSPHPVariables;
   FCookies         : String;
   //Post
   FPostData        : TMemoryStream;
   FContentType     : String;
   FContentLength   : Integer;
   //Output
   FScriptResult    : String;
   FScriptHeaders   : TStringArray;
   //Event
   FOnNewContent    : TOnNewContent;
   //Data
   FData            : Pointer;
  public
   constructor Create; override;
   destructor Destroy; override;
  public
   property OnNewContent    : TOnNewContent read FOnNewContent write FOnNewContent;
   property Data            : Pointer read FData write FData;
   //Input
   property RequestMethod   : TReqMethod read FRequestMethod write FRequestMethod;
   property QueryString     : String read FQueryString write FQueryString;
   property Cookies         : String read FCookies write FCookies;
   //Post
   property PostData        : TMemoryStream read FPostData write FPostData;
   property ContentType     : String read FContentType write FContentType;
   property ContentLength   : Integer read FContentLength write FContentLength;
  published
   //Input
   property ServerVariables : TIPSPHPVariables read FServerVariables write FServerVariables;
   //Output
   property ScriptResult    : String read FScriptResult write FScriptResult;
   property ScriptHeaders   : TStringArray read FScriptHeaders write FScriptHeaders;
 end;

//------------------------------------------------------------------------------
// Media Handling
//------------------------------------------------------------------------------
 TIPSMediaType = (mtForm, mtImage, mtSound, mtStream, mtChart);

 TIPSMedia = class(TIPSRemotable)
  private
   { Identify the Media }
   FMediaID     : TMediaID;
   { Media Con figuration }
   FMediaType   : TIPSMediaType;
   FMediaFile   : String;
   FMediaCRC    : String;
   FMediaSize   : Integer;
   FIsAvailable : Boolean;    //Will be set to FALSE if Media is unavailable
   FLastUpdate  : TUnixTime;
  published
   { Identify the Media }
   property MediaID     : TMediaID read FMediaID write FMediaID;
   { Media Configuration }
   property MediaType   : TIPSMediaType read FMediaType write FMediaType;
   property MediaFile   : String read FMediaFile write FMediaFile;
   property MediaCRC    : String read FMediaCRC write FMediaCRC;
   property MediaSize   : Integer read FMediaSize write FMediaSize;
   property IsAvailable : Boolean read FIsAvailable write FIsAvailable;
   property LastUpdate  : TUnixTime read FLastUpdate write FLastUpdate;
 end;
 TIPSMedias = Array of TIPSMedia;

//------------------------------------------------------------------------------
// Link Handling
//------------------------------------------------------------------------------
 TIPSLink = class(TIPSRemotable)
  private
   { Identify the Link }
   FLinkID      : TLinkID;
   { Link Configuration }
   FTargetID : TIPSID;
  published
   { Identify the Link }
   property LinkID      : TLinkID read FLinkID write FLinkID;
   { Media Configuration }
   property TargetID : TIPSID read FTargetID write FTargetID;
   property LinkChildID : TIPSID read FTargetID write FTargetID; //Delete post 3.x
 end;
 TIPSLinks = Array of TIPSLink;

//------------------------------------------------------------------------------
// Timer Handling
//------------------------------------------------------------------------------
 TIPSTimer = class(TIPSRemotable)
  private
   FTimerID: TTimerID;
   FInstanceID: TInstanceID;
   FName: String;
   FInterval: Integer;
   { Internal Data }
   FEvent: TTimerEvent;
   { Dynamic Data }
   FRunning: Boolean;
   function GetLastRun: TUnixTime;
   function GetNextRun: TUnixTime;
  protected
   FLastRun: Int64;
   FNextRun: Int64;   
  public
   property Event      : TTimerEvent read FEvent write FEvent;
  published
   { Identify the Timer }
   property TimerID    : TTimerID read FTimerID write FTimerID;
   property InstanceID : TInstanceID read FInstanceID write FInstanceID;
   property Name       : String read FName write FName;
   { Timer Configuration }
   property Interval   : Integer read FInterval write FInterval;
   property LastRun    : TUnixTime read GetLastRun;
   property NextRun    : TUnixTime read GetNextRun;
   property Running    : Boolean read FRunning write FRunning;
 end;
 TIPSTimers = Array of TIPSTimer;

 TIPSTimerEx = class(TIPSTimer)
  published
   property LastRunEx : Int64 read FLastRun write FLastRun;
   property NextRunEx : Int64 read FNextRun write FNextRun;
 end;

//------------------------------------------------------------------------------
// Thread Handling
//------------------------------------------------------------------------------
 TIPSScriptThreadInfo = class(TIPSRemotable)
  private
   FThreadID     : THandle;
   FExecuteCount : Cardinal;
   FStartTime    : TDateTime;
   FSender       : String;
   FFilePath     : String;
   FScriptID     : TScriptID;
  published
   property ThreadID     : THandle read FThreadID write FThreadID;
   property ExecuteCount : Cardinal read FExecuteCount write FExecuteCount;
   property StartTime    : TDateTime read FStartTime write FStartTime;
   property Sender       : String read FSender write FSender;
   property FilePath     : String read FFilePath write FFilePath;
   property ScriptID     : TScriptID read FScriptID write FScriptID;
 end;
 TIPSScriptThreadInfos = Array of TIPSScriptThreadInfo;

//------------------------------------------------------------------------------
// SoapServer Handling
//------------------------------------------------------------------------------
 TIPSFilterType = (ftIncludeFilter, ftExcludeFilter);

 TIPSMessageFilter = class(TIPSRemotable)
  private
   FSenderID: Integer;
   FMessage: Integer;
  public
   constructor Create(SenderID, Message: Integer); reintroduce;
  published
   property SenderID: Integer read FSenderID write FSenderID;
   property Message: Integer read FMessage write FMessage;
 end;
 TIPSMessageFilters = Array of TIPSMessageFilter;
 
//------------------------------------------------------------------------------
// Interfaces
//------------------------------------------------------------------------------
// --- ModuleRegister Interface
 IIPSModuleRegistry=interface(IInterface)
  ['{66BFF782-3CCA-4FD9-9B12-906C12852618}']
   { Register a Module Class }
   procedure RegisterModule(ModuleClass: TIPSModuleClass; InterfaceInfo: PTypeInfo; Prefix: String = ''; Singleton: Boolean = False); stdcall;
  end;

 IIPSInterface = interface(IInterface)
  ['{C7CA6A65-CE8E-46FD-9976-D1FF9C9C0F91}']
  { Reference Counting }
  function ReferenceCount(): Integer;
 end;

// --- MessageSink Interface
 IIPSMessageSink=interface(IIPSInterface)
   ['{4AB6071E-F8D1-4968-A432-17751D071BF8}']
   procedure MessageSink(var Msg: TIPSMessage);
  end;

// --- Persistence Interface
 IIPSPersistence=interface(IIPSInterface)
   ['{7661A416-C37E-4A76-A589-ECB07749D398}']
   procedure LoadFromData(ID: TIPSID; Data: ISuperObject);
  end;
  
// --- Module Interface
 IIPSModule = interface(IIPSMessageSink)
  ['{551860D7-8E44-430B-8C44-CBB5AA708470}']
  procedure RequestAction(VariableIdent: String; Value: Variant); stdcall;
  { Searching }
  function SupportsSearching: Boolean; stdcall;
  function IsSearching: Boolean; stdcall;
  procedure StartSearch; stdcall;
  procedure StopSearch; stdcall;
  { Configuration }
  procedure SetProperty(PropertyName: String; PropertyValue: Variant); stdcall;
  function GetProperty(PropertyName: String): Variant; stdcall;
  procedure SetConfiguration(Configuration: String); stdcall;
  function GetConfiguration(): String; stdcall;
  { Configuration Form }
  function GetConfigurationForm(): String; stdcall;
  { Will load Settings }
  procedure LoadSettings(); stdcall;
  { Will save Settings }
  procedure SaveSettings(); stdcall;
  { Will reset/Apply current Settings }
  function HasChanges: Boolean; stdcall;
  procedure ResetChanges(); stdcall;
  procedure ApplyChanges(); stdcall;
  { InstanceID }
  function GetInstanceID(): TInstanceID; stdcall;
  { Data Handling }
  procedure ReceiveData(Data: String); stdcall;
  procedure ForwardData(Data: String); stdcall;
 end;

// --- Kernel Interface
 IIPSKernel=interface(IIPSMessageSink)
  ['{BCB79E07-1AA9-42B1-B154-EDC5AFB50D37}']
  (*
    Info: Will load all needed Interfaces
    Messages: IPS_KERNELMESSAGE => KR_INIT(Const) | IPS_KERNELMESSAGE => KR_READY(Const)
    RunningTime: -
  *)
  procedure InitKernel; stdcall;

  (*
    Info: Will unload all Interfaces
    Messages: IPS_KERNELMESSAGE => KR_UNINIT(Const), IPS_KERNELMESSAGE => KR_SHUTDOWN(Const)
    RunningTime: -
  *)
  procedure UninitKernel; stdcall;

  (*
    Info: Returns the current Kernel Version
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelVersion: Word; stdcall;

  (*
    Info: Displays some Message to KernelLog
    Type: HiByte - MajorV, LoByte - MinorV
    Messages: IPS_LOGMESSAGE => Type(Int), Sender(Str), Message(Str)
    RunningTime: O(1)
  *)
  procedure LogMessage(LType: Integer; LSenderID: TIPSID; LSender: String; LMessage: String); stdcall;

  (*
    Info: Send Message to the internal Message Queue
    Messages: -
    RunningTime: O(1)
  *)
  procedure PostMessage(SenderID: TIPSID; Message: Integer; Data: Array of Const); stdcall;
  
  (*
    Info: Returns the current KernelDir
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelDir: String; stdcall;

  (*
    Info: Returns the current Kernel Runlevel
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelRunlevel: Integer; stdcall;

  (*
    Info: Returns the last Kernel Ticktime (updated every Seconds from the Main Thread)
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelTicktime: TDateTime; stdcall;

  (*
    Info: Returns Kernel SubModules
    Messages: -
    RunningTime: O(1)
  *)
  function GetModuleLoaderEx: IIPSModuleLoaderEx; stdcall;
  function GetObjectManagerEx: IIPSObjectManagerEx; stdcall;
  function GetCategoryManagerEx: IIPSCategoryManagerEx; stdcall;
  function GetInstanceManagerEx: IIPSInstanceManagerEx; stdcall;
  function GetVariableManagerEx: IIPSVariableManagerEx; stdcall;
  function GetScriptManagerEx: IIPSScriptManagerEx; stdcall;
  function GetEventManagerEx: IIPSEventManagerEx; stdcall;
  function GetMediaManagerEx: IIPSMediaManagerEx; stdcall;
  function GetLinkManagerEx: IIPSLinkManagerEx; stdcall;
  function GetScriptEngineEx: IIPSScriptEngineEx; stdcall;
  function GetDataHandlerEx: IIPSDataHandlerEx; stdcall;
  function GetTimerPoolEx: IIPSTimerPoolEx; stdcall;
  function GetDiscoveryServerEx: IIPSDiscoveryServerEx; stdcall;
  function GetProfilePoolEx: IIPSProfilePoolEx; stdcall;
  function GetSettingsEx: IIPSSettingsEx; stdcall;
  function GetDebugServerEx: IIPSDebugServerEx; stdcall;
  function GetLicensePoolEx: IIPSLicensePoolEx; stdcall;
  (*
    Info: Property declarations for Get* Functions
    Messages: -
    RunningTime: Same as Get* Functions
  *)
  property ModuleLoaderEx: IIPSModuleLoaderEx read GetModuleLoaderEx;
  property ObjectManagerEx: IIPSObjectManagerEx read GetObjectManagerEx;
  property CategoryManagerEx: IIPSCategoryManagerEx read GetCategoryManagerEx;
  property InstanceManagerEx: IIPSInstanceManagerEx read GetInstanceManagerEx;
  property VariableManagerEx: IIPSVariableManagerEx read GetVariableManagerEx;
  property ScriptManagerEx: IIPSScriptManagerEx read GetScriptManagerEx;
  property EventManagerEx: IIPSEventManagerEx read GetEventManagerEx;
  property MediaManagerEx: IIPSMediaManagerEx read GetMediaManagerEx;
  property LinkManagerEx: IIPSLinkManagerEx read GetLinkManagerEx;
  property ScriptEngineEx: IIPSScriptEngineEx read GetScriptEngineEx;
  property DataHandlerEx: IIPSDataHandlerEx read GetDataHandlerEx;
  property TimerPoolEx: IIPSTimerPoolEx read GetTimerPoolEx;
  property DiscoveryServerEx: IIPSDiscoveryServerEx read GetDiscoveryServerEx;
  property ProfilePoolEx: IIPSProfilePoolEx read GetProfilePoolEx;
  property SettingsEx: IIPSSettingsEx read GetSettingsEx;
  property DebugServerEx: IIPSDebugServerEx read GetDebugServerEx;
  property LicensePoolEx: IIPSLicensePoolEx read GetLicensePoolEx;

  (*
    Info: Returns Kernel SubModules
    Messages: -
    RunningTime: O(1)
  *)
  function GetSimpleKernel: IIPSSimpleKernel; stdcall;
  function GetModuleLoader: IIPSModuleLoader; stdcall;
  function GetObjectManager: IIPSObjectManager; stdcall;
  function GetCategoryManager: IIPSCategoryManager; stdcall;
  function GetInstanceManager: IIPSInstanceManager; stdcall;
  function GetVariableManager: IIPSVariableManager; stdcall;
  function GetScriptManager: IIPSScriptManager; stdcall;
  function GetEventManager: IIPSEventManager; stdcall;
  function GetMediaManager: IIPSMediaManager; stdcall;
  function GetLinkManager: IIPSLinkManager; stdcall;
  function GetScriptEngine: IIPSScriptEngine; stdcall;
  function GetDataHandler: IIPSDataHandler; stdcall;
  function GetTimerPool: IIPSTimerPool; stdcall;
  function GetDiscoveryServer: IIPSDiscoveryServer; stdcall;
  function GetProfilePool: IIPSProfilePool; stdcall;
  function GetSettings: IIPSSettings; stdcall;
  function GetDebugServer: IIPSDebugServer; stdcall;
  function GetSOAPServer: IIPSSOAPServer; stdcall;
  function GetLicensePool: IIPSLicensePool; stdcall;

  (*
    Info: Property declarations for Get* Functions
    Messages: -
    RunningTime: Same as Get* Functions
  *)
  property SimpleKernel: IIPSSimpleKernel read GetSimpleKernel;
  property ModuleLoader: IIPSModuleLoader read GetModuleLoader;
  property ObjectManager: IIPSObjectManager read GetObjectManager;
  property CategoryManager: IIPSCategoryManager read GetCategoryManager;
  property InstanceManager: IIPSInstanceManager read GetInstanceManager;
  property VariableManager: IIPSVariableManager read GetVariableManager;
  property ScriptManager: IIPSScriptManager read GetScriptManager;
  property EventManager: IIPSEventManager read GetEventManager;
  property MediaManager: IIPSMediaManager read GetMediaManager;
  property LinkManager: IIPSLinkManager read GetLinkManager;
  property ScriptEngine: IIPSScriptEngine read GetScriptEngine;
  property TimerPool: IIPSTimerPool read GetTimerPool;
  property DiscoveryServer: IIPSDiscoveryServer read GetDiscoveryServer;
  property ProfilePool: IIPSProfilePool read GetProfilePool;
  property DataHandler: IIPSDataHandler read GetDataHandler;
  property Settings: IIPSSettings read GetSettings;
  property DebugServer: IIPSDebugServer read GetDebugServer;
  property SOAPServer: IIPSSOAPServer read GetSOAPServer;
  property LicensePool: IIPSLicensePool read GetLicensePool;

  (*
  *)
  function IsRemoteCall(): Boolean;
 end;

// --- SimpleKernel Interface
 IIPSSimpleKernel=interface(IIPSMessageSink)
  ['{CE014520-8DBA-4225-9C34-1F94100D1D00}']
  (*
    Info: Returns the current Kernel Version
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelVersion: Word; stdcall;

  (*
    Info: Displays some Message to KernelLog
    Type: HiByte - MajorV, LoByte - MinorV
    Messages: IPS_LOGMESSAGE => Type(Int), Sender(Str), Message(Str)
    RunningTime: O(1)
  *)
  procedure LogMessage(LType: Integer; LSenderID: TIPSID; LSender: String; LMessage: String); stdcall;

  (*
    Info: Returns the current KernelDir
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelDir: String; stdcall;

  (*
    Info: Returns the current Kernel Runlevel
    Messages: -
    RunningTime: O(1)
  *)
  function GetKernelRunlevel: Integer; stdcall;

  (*
    Info: Returns the last Kernel Ticktime (updated every Seconds from the Main Thread)
    Messages: -
    RunningTime: O(1)
  *)  
  function GetKernelTicktime: TDateTime; stdcall;
 end;

// --- LicensePool Interfaces
 IIPSLicensePool=interface(IIPSMessageSink)
  ['{1674C142-C6C0-485B-897B-BC1423C87E8D}']
  function GetLicensee: String; stdcall;
  function GetLiveUpdateVersion: String; stdcall;
  function GetLiveConsoleCRC: String; stdcall;
  function GetLiveConsoleFile: String; stdcall;
  function GetLimitDemo: Integer; stdcall;
  function GetDemoExpiration: TDateTime; stdcall;
  function GetLimitWebFront: Integer; stdcall;
  function GetLimitVariables: Integer; stdcall;
 end;

 IIPSLicensePoolEx = interface(IIPSLicensePool)
  ['{F49BA3B4-A234-4257-8369-4F0F84BCAA24}']
  function GetPassword: String; stdcall;
  function GetAuthenticationKeys: TStringArray; stdcall;
 end;

// --- ModuleLoader Interfaces
 IIPSModuleLoader=interface(IIPSMessageSink)
  ['{9A0F6FD4-1719-451D-900D-C13250995753}']
  (*
    Info: Loads not yet loaded Libraries
    Messages: -
    RunningTime: O(n*m) | n = DLL's in ModuleFolder, m = LoadLibrary() RunningTime
  *)
  procedure LoadLibraries; stdcall;

  (*
    Info: Unloads all loaded Libraries
    Messages: -
    RunningTime: O(n*m) | n = DLL's in ModuleFolder, m = LoadLibrary() RunningTime
  *)
  procedure UnloadLibraries; stdcall;

  (*
    Info: Return if Library for LibraryID exits
    Messages: -
    RunningTime: O(1)
  *)
  
  (*
  	Function: IPS_LibraryExists
  	
  		The command checks if the library with ID *LibraryID* exists.
  		
  	Parameters:
  	
  		LibraryID - ID of the library to be tested
  		
  	Returns:
  	
  		If the LibraryID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_LibraryExists("{7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}"))
  		echo "ELV Library exists!";
  		
  		
  *)		
  function LibraryExists(LibraryID: TStrGUID): Boolean; stdcall;

  (*
    Info: Return Pointer to Library for LibraryID | Do not Modify Record!
    Messages: -
    RunningTime: O(1)
  *)
  
  (*
  	Function: IPS_GetLibrary
  	
  		The command returns an array containing information about the library with ID * LibraryID*.
  		
  	Parameters:
  	
  		LibraryID - LibraryID, which is to show
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		Author		|	string		|	Name of author
  		Build		|	integer		|	Build number 
  		Date		|	integer		|	Unix Timestamp
  		LibraryID	|	string		|	LibraryID
  		Name		|	string		|	Name of library
  		URL			|	string		|	Internet address of the library author
  		Version		|	integer		|	HighByte: Major version, LowByte: Minor Version
  		
  	Example:
  	
  		print_r(IPS_GetLibrary("{7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}"));
		/* returns e.g.:
		Array
		(
  		[Author] => IP-Symcon - CSS
  		[Build] => 0
  		[Date] => 2085798496
  		[LibraryID] => {7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}
  		[Name] => ELV Device Library
  		[URL] => www.ip-symcon.de
  		[Version] => 512
		)
		*/


  *)
  function GetLibrary(LibraryID: TStrGUID): TIPSLibraryInformation; stdcall;

  (*
    Info: Return GUIDs to all Libraries
    Messages: -
    RunningTime: O(n) | n = CurrentLibraryCount
  *)
  function GetLibraries(LibraryIDs: TStrGUIDs): TIPSLibraryInformations; stdcall;

  (*
    Info: Return GUIDs to all Libraries
    Messages: -
    RunningTime: O(n) | n = CurrentLibraryCount
  *)
  
  (*
  	Function: IPS_GetLibraryList
  	
  		The command determines the IDs of all available libraries in IP-Symcon. The IDs are listed in an array. HighByte: Major version, LowByte: Minor Version
  		
  	Returns:
  	
  		An array of string values ​​of all the GUIDs of the libraries in IP-Symcon.
  		
  	Example:
  	
  		print_r(IPS_GetLibraryList());
		/* returns e.g.:
		Array
		(
  		[0] => {FF95B199-B3BD-424C-9AEF-3F004BC672B6}
  		[1] => {6EC74E99-C6FD-4E03-9195-E7BD90E6C07E}
  		[2] => {2CE84600-0A3C-438C-AC22-86439A1E5DF0}
  		ect. ...
		)
 		*/
 		
 		
  *)		
  function GetLibraryList(): TStrGUIDs; stdcall;

  (*
    Info: Return GUIDs to all Modules from Library
    Messages: -
    RunningTime: O(n+m) | n = CurrentLibraryCount, m = CurrentModuleCount
  *)
  
  (*
  	Function: IPS_GetLibraryModules
  	
  		The command determines the IDs of all modules in a specified library. The IDs are listed in an array.
  		
  	Parameters:
  	
  		LibraryID - ID of the library to be returned
  		
  	Returns:
  	
  		An array of string values ​​of all the GUIDs of the libraries in IP-Symcon.
  		
  	Example:
  	
  		print_r(IPS_GetLibraryModule("{7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}"));
		/* returns e.g.:
		Array
		(
  		[0] => {57040540-4432-4220-8D2D-4676B57E223D}
  		[1] => {48FCFDC1-11A5-4309-BB0B-A0DB8042A969}
  		[2] => {56800073-A809-4513-9618-1C593EE1240C}
  		[3] => {2FD7576A-D2AD-47EE-9779-A502F23CABB3}
  		ect. ...
		)
 		*/
 		
 		
  *)		
  function GetLibraryModules(LibraryID: TStrGUID): TStrGUIDs; stdcall;

  (*
    Info: Return if Module for ModuleID exits
    Messages: -
    RunningTime: O(1)
  *)
  
  (*
  	Function: IPS_ModuleExists
  	
  		The command checks whether the module with the ID *ModuleID* exists.
  		
  	Parameters:
  	
  		ModuleID - ID of the modul to be tested
  		
  	Returns:
  	
  		If the ModuleID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_ModuleExists("{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}"))
  		echo "FS20 Modul exists!";
  		
  		
  *)		
  function ModuleExists(ModuleID: TStrGUID): Boolean; stdcall;

  (*
   Info: Collect all Module Information

  *)
  
  (*
  	Function: IPS_GetModule
  	
  		The command returns an array containing information about the module with the ID *ModuleID*.
  		
  	Parameters:
  	
  		ModuleID - ID of the modul to be returned
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		Aliases				|	array	|	Array of alternative names (string) for the module
  		ChildRequirements	|	array	|	Array of GUIDs (string), which are expected by child objects
  		ParentRequirements	|	array	|	Array of GUIDs (string), which are expected by parent objects
  		Implemented			|	array	|	Array of GUIDs (string) offered by the module
  		LibraryID			|	string	|	LibraryID in which the module is included
  		ModuleID			|	string	|	ModuleID
  		ModuleName			|	string	|	Name of module
		ModuleType			|	integer	|	Type of module (0: core, 1: I / O, 2: Splitter, 3: Device)
		
	Example:
	
		print_r(IPS_GetModule("{7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}"));
		/* returns e.g.:
		Array
		(
  		[Aliases] => Array
      	(
         [0] => FS20 receiver
         [1] => FS20 transmitter
      	)

  		[ChildRequirements] => Array
      	(
      	)

  		[Implemented] => Array
      	(
         [0] => {DF4F0170-1C5F-4250-840C-FB5B67262530}
      	)

  		[LibraryID] => {7DC57F9A-C095-4CDE-A6F0-2CB35A29A8FE}
  		[ModuleID] => {48FCFDC1-11A5-4309-BB0B-A0DB8042A969}
  		[ModuleName] => FS20
  		[ModuleType] => 3
  		[ParentRequirements] => Array
      	(
         [0] => {122F60FB-BE1B-4CAB-A427-2613E4C82CBA}
      	)

  		[Vendor] => ELV
		)
		*/
		
		
  *)		
  function GetBasicModule(ModuleID: TStrGUID): TIPSBasicModuleInformation; stdcall; (* THIS IS A HACK TO GET SOAP WSDL WORKING *) 
  function GetModule(ModuleID: TStrGUID): TIPSModuleInformation; stdcall;
  
  (*
    Info: Return GUIDs to all Modules
    Messages: -
    RunningTime: O(n) | n = CurrentModuleCount
  *)
  function GetModules(ModuleIDs: TStrGUIDs): TIPSModuleInformations; stdcall;

  (*
    Info: Return GUIDs to all Modules
    Messages: -
    RunningTime: O(n) | n = CurrentModuleCount
  *)
  
  (*
  	Function: IPS_GetModuleList
  	
  		The command determines the IDs of all available modules in IP-Symcon. The IDs are listed in an array.
  		
  	Returns:
  	
  		An array of string values ​​of all the GUIDs of the modules in IP-Symcon.
  		
  	Example:
  	
  		print_r(IPS_GetModuleList());
		/* returns e.g.:
		Array
		(
	  	[0] => {2D8B0172-166C-45B0-B979-61A787809E22}
 		[1] => {CCC52C33-D77A-4AE9-A6CF-462F152532A0}
 	 	[2] => {11842D31-3CA4-4F1B-BBA9-E4A0FE1873AF}
  		[3] => {4CB91589-CE01-4700-906F-26320EFCF6C4}
  		ect. ...
		)
		*/
 		
 		//Output of all module names with GUID

		foreach(IPS_GetModuleList() as $guid)
 		{
  		$module = IPS_GetModule($guid);
  		$pair[$module['ModuleName']] = $guid;
 		}
 		ksort($pair);
 		foreach($pair as $key=>$guid)
 		{
  		echo $key." = ".$guid."\n";
 		}

 		/*
 		ALL3690 = {BBD04875-8CC5-412A-B848-B2AB6F08C425}
 		ALL4000 = {2D8B0172-166C-45B0-B979-61A787809E22}
 		AllUniversal = {D805EC4C-7D17-4E84-98D3-A441AA71ACA3}
 		Archive Control = {43192F0B-135B-4CE7-A0A7-1475603F3060}
 		Client Socket = {3CFF0FD9-E306-41DB-9B5A-9D06D38576C3}
		Codatex RFReader1 = {4C4EAE41-96D8-45AA-A506-67609B06E400}
 		Cutter = {AC6C6E74-C797-40B3-BA82-F135D941D1A2}
 		DMX4ALL = {B1E43BF6-770A-4FD7-B4FE-6D265F93746B}
 		DMXOUT = {E19C2E41-7347-4A3B-B7D9-A9A88E0D133E}
 		Dummy Module = {485D0419-BE97-4548-AA9C-C083EB82E61E}
 		EIB Gateway = {1C902193-B044-43B8-9433-419F09C641B8}
 		EIB Group = {D62B95D3-0C5E-406E-B1D9-8D102E50F64B}
 		EM24-DIN = {2AA27F83-E4DA-48D5-86CF-613C09F1B4B5}
 		EZControl T-10 = {9B177C28-BD4D-478C-922E-7743A6E6BBDB}
 		EnOcean EltakoFSS12 = {7124C1BC-B260-4C5E-BF00-B38D3C7B5CB7}
 		EnOcean Gateway = {A52FEFE9-7858-4B8E-A96E-26E15CB944F7}
 		EnOcean Hoppe = {1C8D7E80-3ED1-4117-BB53-9C5F61B1BEF3}
 		EnOcean Opus = {9B1F32CD-CD74-409A-9820-E5FFF064449A}
 		EnOcean PTM200 = {40C99CC9-EC04-49C8-BB9B-73E21B6FA265}
 		EnOcean PTM200RX = {63484585-F8AD-4780-BAFD-3C0353641046}
 		EnOcean RCM100 = {8492CEAF-ED62-4634-8A2F-B09A7CEDDE5B}
 		EnOcean STM100 = {FA1479DE-C0C1-433D-98BC-EA7C298D1AA5}
 		EnOcean STM250 = {B01DE819-EA69-4FC1-91AB-4D9FF8D55370}
 		EnOcean Thermokon = {B4249BC6-5BA8-45E3-B506-86680935D4EE}
 		Event Control = {ED573B53-8991-4866-B28C-CBE44C59A2DA}
 		FHT = {A89F8DFA-A439-4BF1-B7CB-43D047208DDD}
 		FHZ1X00PC = {57040540-4432-4220-8D2D-4676B57E223D}
 		FS10 = {6D508C91-F197-44A9-A1AB-A27F97A18A5F}
 		FS10 Receiver = {753E7267-7558-49D3-ACFB-86755C28318D}
 		FS20 = {48FCFDC1-11A5-4309-BB0B-A0DB8042A969}
 		FS20EX = {56800073-A809-4513-9618-1C593EE1240C}
 		FTDI = {C1D478E9-2A3E-4344-BCC4-37C892F58751}
 		HID = {E6D7692A-7F4C-441D-827B-64062CFE1C02}
 		HMS = {2FD7576A-D2AD-47EE-9779-A502F23CABB3}
 		Heating Control = {3F52FA69-77F5-4DE6-8B2A-347452AC5F8F}
 		HomeMatic Configurator = {5214C3C6-91BC-4FE1-A2D9-A3920261DA74}
 		HomeMatic Device = {EE4A81C6-5C90-4DB7-AD2F-F6BBD521412E}
 		HomeMatic Socket = {A151ECE9-D733-4FB9-AA15-7F7DD10C58AF}
 		IMAP = {CABFCCA1-FBFF-4AB7-B11B-9879E67E152F}
 		IPSDog = {B5F1C151-16DA-4EEA-962A-92D620FB47E6}
 		IRTrans Device = {899DBC68-0147-4528-B95D-D43C568D4E56}
 		IRTrans Gateway = {0F0F74EF-2304-4C23-840F-EC1C5B9A9A82}
 		ISDN Module = {D738E8CC-F524-454A-BB69-93E5BE416E87}
 		Image Grabber = {5A5D5DBD-53AB-4826-8B09-71E9E4E981E5}
 		KNX/EIB Configurator = {33765ABB-CFA5-40AA-89C0-A7CEA89CFE7A}
 		KS300 = {9D21F700-6F67-4FBB-ACC2-AA42420A0486}
 		LCN Configurator = {0F64973F-4669-4272-BDB3-6338D0350269}
 		LCN Data = {A26E7E5A-A7C5-4063-8BE0-ED8BB26F8411}
 		LCN Module = {0E31FED6-E465-4621-95D4-AAF2683C41EC}
 		LCN Splitter = {9BDFC391-DEFF-4B71-A76B-604DBA80F207}
 		LCN Unit = {2D871359-14D8-493F-9B01-26432E3A710F}
 		LCN Value = {0102BDC9-3B85-4A11-968D-7D314DA07C06}
 		LevelJet = {D64B904C-5312-443C-A2F3-03201ED9811C}
 		M-Bus Device = {B53BE2E5-892D-4537-94AC-EAC68A469188}
 		M-Bus Gateway = {301AB802-23CD-4DE2-91D1-6E3BC9BF03FC}
 		MF420IRCTF = {1599A33E-1A39-4DB3-904C-C88DAADB33EF}
 		Media Player = {2999EBBB-5D36-407E-A52B-E9142A45F19C}
 		ModBus Address = {CB197E50-273D-4535-8C91-BB35273E3CA5}
 		ModBus RTU/TCP = {A5F663AB-C400-4FE5-B207-4D67CC030564}
 		OneWire = {9317CC5B-4E1D-4440-AF3A-5CC7FB42CCAA}
 		POP3 = {69CA7DBF-5FCE-4FDF-9F36-C05E0136ECFD}
 		ProJet Counter = {134A1CFF-3CAA-4D2E-8517-F9BFDE7544C9}
 		ProJet Display = {9542B617-C603-4E8A-BFDE-DD69663F0226}
 		ProJet Display Input = {FBF6F86C-4901-4957-8D08-2B2CBC1DF71A}
 		ProJet Display Output = {C8CF38E9-BEAA-4149-A9ED-C8AAE04E8A6D}
 		ProJet Gateway = {995946C3-7995-48A5-86E1-6FB16C3A0F8A}
 		ProJet Input = {5509B26C-F2F7-428F-973B-FD5D07C80111}
 		ProJet Stripe = {7AF52E55-4994-44AE-9DB8-752895F1EB76}
 		ProJet Stripe Input = {26B22717-924E-4D58-B091-C98E49812238}
 		ProJet Tracker = {50460BD9-FA93-4DE0-976A-55208C90DF15}
 		RRDTool = {D8F1786A-EA45-4B86-B2F6-2986F77C193A}
 		Register Variable = {F3855B3C-7CD6-47CA-97AB-E66D346C037F}
 		SI USBXpress = {BFC698E9-1F43-45CD-BD79-47EA79CE21AD}
 		SMS = {96102E00-FD8C-4DD3-A3C2-376A44895AB1}
 		SMTP = {375EAF21-35EF-4BC4-83B3-C780FD8BD88A}
 		Serial Port = {6DC3D946-0D31-450F-A8C6-C42DB8D7D4F1}
 		Server Socket = {8062CF2B-600E-41D6-AD4B-1BA66C32D6ED}
 		Shutter Control = {542CC907-CA63-4E7A-A8C7-92F74639FA4C}
 		Siemens Address = {932076B1-B18E-4AB6-AB6D-275ED30B62DB}
 		Siemens S7 = {1B0A36F7-343F-42F3-8181-0748819FB324}
 		TMEX = {CED1D815-2477-4B05-8F65-0E4475913063}
 		Text Parser = {4B00C7F7-1A6D-4795-A2D2-08151854D259}
 		Text To Speech = {684CC410-6777-46DD-A33F-C18AC615BB94}
 		ThermoJet = {C3380B6E-2351-4A19-9668-A17960F97E51}
 		UDP Socket = {82347F20-F541-41E1-AC5B-A636FD3AE2D8}
 		UVR1611 = {0A8F9D69-E78B-4EAB-8E26-C8A4ACF7FA25}
 		Utils Control = {B69010EA-96D5-46DF-B885-24821B8C8DBD}
 		Velleman USB = {8CE70CD0-6674-4907-B3CE-F6E5235C9938}
 		Virtual I/O = {6179ED6A-FC31-413C-BB8E-1204150CF376}
 		WMRS200 = {DD2A4676-82C6-4154-9AAD-DE30668D53B0}
 		WMRS200 Receiver = {E4FDC411-95D5-453C-B731-0CEB0483E663}
 		WWW Reader = {4CB91589-CE01-4700-906F-26320EFCF6C4}
		WebFront Configurator = {3565B1F2-8F7B-4311-A4B6-1BF1D868F39E}
 		WebServer = {D83E9CCF-9869-420F-8306-2B043E9BA180}
 		WinLIRC = {19E51FC2-064B-4A51-8995-11FEFF7F129A}
 		WuT Counter = {5F1C5261-07A2-4A7E-9AC4-88AF9ED29420}
 		WuT Gateway = {01CA6888-C833-484E-A3F3-806535421CB7}
 		WuT Input = {C3D0F82C-CD07-4AA8-AE5C-7AD983FE91F3}
 		WuT Output = {E85C40B3-C1E9-4A60-85C7-6CDDA3D8D7BF}
 		WuT ThermoHygro = {2EF634A4-D96D-4018-BD90-94E487A89D49}
 		XBee Device = {E4027862-E456-4634-A48C-7A8E0C720756}
 		XBee Gateway = {7FA47C08-E31B-44A6-9E50-20C4DDD3E081}
 		XBee Splitter = {9D5DCE79-1A97-4531-9D10-68839F4BEAAC}
 		Z-Wave Configurator = {2D7CA355-2C51-4430-8F67-4E397EAAEA19}
 		Z-Wave Gateway = {4EF72D56-BF9F-4347-8F0A-2035D241116F}
 		Z-Wave Module = {101352E1-88C7-4F16-998B-E20D50779AF6}
 		xComfort Binary Input = {3040A77D-3E9C-42D4-A1B6-329EFE8086DB}
 		xComfort Configurator = {5DD921D4-4712-443F-B89F-03434A4DBF94}
 		xComfort Dimmer = {8050FEEC-C875-4BDD-9143-D15134B89D35}
 		xComfort Energy = {814067F0-EACB-43C3-99BD-5CB9B2F8FB9E}
 		xComfort Gateway = {D2DCE381-19A7-4D14-B819-49C0539BC350}
 		xComfort Humidity = {3EBA1AB7-72CA-48D2-8F89-813E085D41BB}
 		xComfort Impulse = {A374DCF0-CEDE-4EB7-B6A8-E92787E19B25}
 		xComfort Remote = {DCBD8143-83AB-4068-8FC0-0C92A93AA8A8}
 		xComfort Room Control = {1A1C4C67-C99D-4D3E-8A34-23581CE8CCAA}
 		xComfort Shutter = {1B7B5B7D-CAA9-4AB5-B9D8-EC805EC955AD}
 		xComfort Switch = {27DD9788-802E-45B7-BA54-FB97141398F7}
 		xComfort Temperature = {591B4A05-E5BF-4EEA-BC34-36E6F1CC9D56}
 		xComfort Value RX = {DA2FCC12-2DE1-404A-8A5E-1C6AF05F96A2}
 		xComfort Value TX = {ED6A1E00-81C7-416F-9F97-1F2CC8F45B15}
 		*/
 		
 			
  *)		
  function GetModuleList(): TStrGUIDs; stdcall;

  (*
   Info: Checks if both Modules can be connected
   Messages: -
   RunningTime: O(1)
  *)
  
  (*
  	Function: IPS_IsModuleCompatible
  	
  		The command determines whether two modules are compatible with each other.
  		
  	Parameters:
  	
  		ModuleID		- first ModuleID
  		ParentModuleID	- second ModuleID
  		
  	Returns:
  	
  		*TRUE* if the modules are compatible, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_IsModuleCompatible("{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}",
                           "{57040540-4432-4220-8D2D-4676B57E223D}"))

  		echo "FS20 module is compatible to the  FHZ module!";
  		
  *)		
  function IsModuleCompatible(ModuleID, ParentModuleID: TStrGUID): Boolean; stdcall;

  (*
   Info: Searches all compatible Modules can be connected with Module
   Messages: -
   RunningTime: O(1)
  *)
  
  (*
  	Function: IPS_GetCompatibleModules
  	
  		The command determines the IDs of all available modules that are compatible to *ModulID* in IP-Symcon. The IDs are listed in an array.
  		
  	Parameters:
  	
  		ModuleID - ID of the module to be tested
  		
  	Returns:
  	
  		Array of string values ​​of all compatible ModulIDs to *ModulID*.
  		
  	Example:
  	
  		print_r(IPS_GetCompatibleModules("{57040540-4432-4220-8D2D-4676B57E223D}"));
		/* returns e.g.:
		Array
		(
  		[0] => {4CB91589-CE01-4700-906F-26320EFCF6C4}
  		[1] => {6DC3D946-0D31-450F-A8C6-C42DB8D7D4F1}
  		[2] => {3CFF0FD9-E306-41DB-9B5A-9D06D38576C3}
  		[3] => {8062CF2B-600E-41D6-AD4B-1BA66C32D6ED}
  		ect...
		)
 		*/
 		
 	
  *)	
  function GetCompatibleModules(ModuleID: TStrGUID): TStrGUIDs; stdcall;
  
 end;

 IIPSModuleLoaderEx = interface(IIPSMessageSink)
  ['{18D0B53E-865F-48EA-A227-39327457C318}']
  (*
    Info: Returns ModuleClass. Do not create Instaces of it. Use InstanceControl.CreateInstance
    Messages: -
    RunningTime: O(1)
  *)
  function GetModuleClass(ModuleID: TStrGUID): TIPSModuleClass; stdcall;
  (*
    Info: Returns ModulePrefix.
    Messages: -
    RunningTime: O(1)
  *)
  function GetModulePrefix(ModuleID: TStrGUID): String; stdcall;
  (*
    Info: Returns if Module is singleton.
    Messages: -
    RunningTime: O(1)
  *)
  function GetModuleSingleton(ModuleID: TStrGUID): Boolean; stdcall;
  (*
    Info: Returns InterfaceInfo.
    Messages: -
    RunningTime: O(n)
  *)
  function GetInterfaceInfo(InterfaceID: TGUID): PTypeInfo; stdcall;  
 end;
 
// --- DataHandler Interface
 IIPSDataHandler=interface(IIPSMessageSink)
  ['{3FF06499-9CF9-42AE-A2F0-E9C9C3ED60DA}']
  { Connects the Instance with some Parent Instance, 0 = Connect to None }
  
  (*
  	Function: IPS_ConnectInstance
  	
  		The command connects the instance *InstanceID* with the instance *ParentID*, seen by the hardware (physical) view, that the data can be exchanged. An example would a FS20 device that is connected to a FTA splitter.
  		§Each instance can have only one parent instance.§
  		
  	Parameters:
  	
  		InstanceID - ID of the instance
  		ParentID   - ID of the new instance to be connected
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_ConnectInstance(12345, 23456);
  		
  *)		
  procedure ConnectInstance(InstanceID, ParentID: TInstanceID); stdcall;
  { Disconnects the Instance from all other ones }
  
  (*
  	Function: IPS_DisconnectInstance
  	
  		The command disconnects a connected instance *InstanceID* from the parent instance. The specification of the parent instance is not necessary because there is always only one instance to be disconnected.
  		
  	Parameters:
  	
  		InstanceID - ID of the instance
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_DisconnectInstance(12345);
  		
  *)		
  procedure DisconnectInstance(InstanceID: TInstanceID); stdcall;
 end;

 IIPSDataHandlerEx=interface(IIPSPersistence)
  ['{9D100F18-2835-4005-849F-EE9D0AEFABA9}']
  { Has Parent? }
  
  (*
  	Function: IPS_HasInstanceParent
  	
  		The command indicates whether a particular instance *InstanceID*, seen by the hardware (physical) view, has a parent instance e.g. a splitter or I / O module.
  		§This command is only useful for devices and splitter instances.§
  		
  	Parameters:
  	
  		InstanceID - ID of the instance to be checked
  		
  	Returns:
  	
  		The return value is *TRUE* if the instance has a parent instance, otherwise, *FALSE*.
  		
  	Example:
  	
  		if(IPS_HasInstanceParent(12345))
		{
 		echo "Has a parent instance";	
		}
		
  *) 
  function HasInstanceParent(InstanceID: TInstanceID): Boolean; stdcall;
  { Return ParentID for InstanceID }
  
  (*
  	Function: IPS_GetInstanceParentID
  	
  		The command returns the ID of the parent instance for the instance *InstanceID*. (Seen by the hardware (physical) view)
  		§This command is only useful for devices and splitter instances.§
  		
  	Parameters:
  	
  		InstanceID - ID of the instance to be checked
  		
  	Returns:
  	
  		ID of the parent instance
  		
  	Example:
  	
  		echo IPS_GetInstanceParentID(12345);
  		
  *)
  function GetInstanceParentID(InstanceID: TInstanceID): TInstanceID; stdcall;
  { Return all ParentIDs for InstanceID }
  function GetInstanceParentIDs(InstanceID: TInstanceID): TInstanceIDs; stdcall;
  { Has Children? }
  
  (*
  	Function: IPS_HasInstanceChildren
  	
  		The command indicates whether a particular instance of *InstanceID*, seen by the hardware (physical) view, has a child instance e.g. a splitter or device module.
  		§This command is only useful for I / O and splitter instances.§
  	
  	Parameters:
  	
  		InstanceID - ID of the instance to be checked
  		
  	Returns:
  	
  		The return value is *TRUE* if the instance has a child instance, otherwise, *FALSE*.
  		
  	Example:
  	
  		if(IPS_HasInstanceChild(12345))
		{
 		echo "Has a child instance";
		}
		
  *)
  function HasInstanceChildren(InstanceID: TInstanceID): Boolean; stdcall;
  { Only applicable for Splitters and Devices }
  
  (*
  	Function: IPS_GetInstanceChildrenIDs
  	
  		The command returns all IDs of the child instances for the specific instance *InstanceID*. (Seen by the hardware (physical) view)
  		§This command is only useful for I / O and splitter instances.§
  	
  	Parameters:
  	
  		InstanceID - ID of the instance to be checked
  		
  	Retruns:
  	
  		An array of InstanceIDs from the children instances.
  		
  	Example:
  	
  		print_r(IPS_GetInstanceChildrenIDs(12345));
  *)		
  
  function GetInstanceChildrenIDs(InstanceID: TInstanceID): TInstanceIDs; stdcall;

  //Sending Data
  procedure SendDataToParent(InstanceID: TInstanceID; Data: String);
  procedure SendDataToChildren(InstanceID: TInstanceID; Data: String);
 end;

// --- ObjectManager Interface
 IIPSObjectManager=interface(IIPSMessageSink)
  ['{085EA06E-0143-4EFB-B8C5-794542F58D04}']
  { Registers Object }
  function RegisterObject(ObjectType: TIPSObjectType): TIPSID; stdcall;
  { Unregisters the given Object and updates all Children with a valid ParentID }
  procedure UnregisterObject(ID: TIPSID); stdcall;
  { Set the Objects Name/Parent }

  (*
  	Function: IPS_SetParent
  	
  		The command moves the object with ID *ObjectID* in the IP Symcon logical tree under the object with ID *ParentID*. The object is visually subordinated to the parent object. The new assignment is in the logical tree view visible. In this way, the logical view can be adjusted so that it best reflects the unity of and / or function of various components.
  		#The assignment of an object to a new parent object does not change the existing physical connections. It only serves to better representation.#
  
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		ParentID - ID of the new parent object in the logical tree
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  	
  	Example:
  	
  		IPS_SetParent(47381, 15361);
  		
  *)		
  procedure SetParent(ID: TIPSID; ParentID: TIPSID); stdcall;

  (*
  	Function: IPS_SetIdent
  	
  		The command modifies the object with ID *ObjectID* and changes its unique identifier. If an object with the same identifier is already in this category an error is thrown and this function will terminate. 
  
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Identifier - A unique identifiert in this category
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  	
  	Example:
  	
  		IPS_SetIdent(47381, "STATUS");
  		
  *)  
  procedure SetIdent(ID: TIPSID; Ident: String); stdcall;
  
  (*
  	Function: IPS_SetName
  	
  		The command assigns the object with ID *ObjectID* a name *Name*. The name appears in the tree structure instead of the object ID and can contribute to readability. The command can be applied to all objects that have an ID for identification.
  	
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Name     - New name for the object
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		print_r(IPS_GetObjectList());  

		/* returns e.g.:
		Array
		(
  		[0] => 0
  		[1] => 10573
  		[2] => 11363
  		[3] => 11650
  		[4] => 14114
  		ect. ...

		)
		*/ 
		
  *)
  procedure SetName(ID: TIPSID; Name: String); stdcall;
  
  (*
  	Function: IPS_SetInfo
  	
  		The command assigns the object with ID *ObjectID* extended information. These can be used e.g. to define specific configurations or specific information on each object.
  	
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Info	 - New info text for the object
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetInfo (47381, "USB sound card - Port A, basement - Green cable");
  		
  *)
  procedure SetInfo(ID: TIPSID; Info: String); stdcall;
  
  (*
  	Function: IPS_SetIcon
  	
  		The command assigns the object with ID *ObjectID* an icon. The name of the icon is the filename without the extension or path.
  		
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Icon     - Filename of the icon without path / extension
  		
  	Retruns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetIcon(47381, "weather");
  		
  *)
  procedure SetIcon(ID: TIPSID; Icon: String); stdcall;
  procedure SetSummary(ID: TIPSID; Summary: String); stdcall;
  
  (*
  	Function: IPS_SetPosition
  	
  		The command assigns the object with ID *ObjectID* a position. The position will be used in the visualization to display the objects in the desired order. The default value is zero. The position value may not be unique. If two positions are equal, the name will be used as an additional criterion of sorting.
  		
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Position - Position value of the object
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetIcon(47381, "weather");
  		
  *)
  procedure SetPosition(ID: TIPSID; Position: Integer); stdcall;
  procedure SetReadOnly(ID: TIPSID; ReadOnly: Boolean); stdcall;
  
  (*
  	Function: IPS_SetHidden
  	
  		The command sets the visibility of the object with the ID *ObjectID*. Invisible objects with their child objects are excluded from the visualization. In the configuration the are displayed in gray.
  		
  	Parameters:
  	
  		ObjektID - ID of the object to be changed
  		Hidden   - TRUE if hidden
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetHidden(47381, true); //hidden object
  		
  *)
  procedure SetHidden(ID: TIPSID; Hidden: Boolean); stdcall;
  { Getter Functions }
  
  (*
  	Function: IPS_ObjectExists
  	
  		The command checks whether an object exists with the ID *ObjectID*
  		
  	Parameters:
  	
  		ObjektID - The ObjectID to be tested
  		
  	Returns: 
  	
  		If the Object ID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  	
  	Example:
  	
  		if (IPS_ObjectExists(34881))
  		echo "An object with that ID exists!";
  		
  *)
  function ObjectExists(ID: TIPSID): Boolean; stdcall;
  procedure CheckObject(ID: TIPSID); stdcall;
  
  (*
  	Function: IPS_GetObject
  	
  		The command returns an array containing information about the object with the ID *ObjectID*. If the object is not available, an alert is generated.
  		
  	Parameters:
  	
  		ObjektID - The ObjectID to be returned
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		ChildrenIDs          |		array		|		Child ObjectID. See: <IPS_GetChildrenIDs>
  		HasChildren          |		boolean		|		TRUE if the object has child objects. See: <IPS_HasChild>		
  		ObjectID			 |		integer		|		ObjectID
  		ObjectType			 |		integer		|		Object-type (0: category 1: instance 2: Variable, 3: script, 4: Event 5: Media, 6: Link)
  		ObjectName			 |		string		|		Name of the object. See: <IPS_SetName>
  		ObjectInfo			 |		string		|		The user can specify extended information. See: <IPS_SetInfo>
  		ObjectIcon			 |		string		|		File name without extension of the icon. See: <IPS_SetIcon>
  		ObjectSummery   	 |		string		|		Short description of an object, which is generated by the module if needed
  		ObjectPosition		 |		integer		|		Position of the object in the visualization. This value may not be unique. See: <IPS_SetPosition>
  		ObjectIsHidden		 |		boolean		|		TRUE if the object is hidden in the visualization. See <IPS_SetHidden>
  		ObjectIsReadOnly	 |		boolean		|		TRUE if the object is read-only. (Currently used only for state variables)
  		ParentID			 |		integer		|		Parent object. 0 = No parent object. See: <IPS_SetParent>
  		
  	Example:
  	
  		print_r(IPS_GetObject(19668));

		/* returns e.g.:
		Array
		(
  		[Children] => Array
     	(
        [0] => 38434
      	)

  		[HasChildren] => 1
  		[ObjectID] => 19668
  		[ObjectInfo] => Nutzt USB Soundkarte
  		[ObjectName] => Text To Speech
  		[ObjectType] => 1
  		[ParentID] => 0
		)

		*/
		
	*)
  		
  function GetObject(ID: TIPSID): TIPSObject; stdcall;
  function GetObjects(IDs: TIPSIDs): TIPSObjects; stdcall;
  
  (*
	Function: IPS_GetObjectList
	
		The command determines the IDs of all obejects registered in IP Symcon. The IDs are listed in an array.
	
	Returns:
	
		An array of integer values ​​of all IDs in IP Symcon
  
  	Example:
  	
  		print_r( IPS_GetObjectList() );

		/* returns e.g.:
		Array
		(
  		[0] => 0
  		[1] => 10573
  		[2] => 11363
  		[3] => 11650
  		[4] => 14114
 		ect. ...

		)
		*/  
  
  *)
  function GetObjectList(): TIPSIDs; stdcall;
  
  (*
  	Function: IPS_GetObjectIDByName
  		
  		The command is trying to determine the ID of the object with the name *ObjectName*, whose parent owns the ID *ParentID*. It will use the ID of the first found object whose name matches with *ObjectName*. If such an object was found, its ID is returned, otherwise FALSE.
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		ObjektName - ObjectName to be searched
  		ParentID   - Object to be searched in its child objects
  	
  	Returns:
  	
  		ID of the found object, otherwise *FALSE*.
  		
  	Example:
  	
  		$ObjektID = @IPS_GetObjectIDByName("Rain sensing", $ParentID);
		if ($ObjektID === false)
  		echo "Object is not found!";
		else
  		echo "The object ID is: ". $ObjektID;
  		
  *)
  function GetObjectIDByName(Name: String; ParentID: TIPSID): TIPSID; stdcall;
  function GetObjectIDByNameEx(Name: String; ParentID: TIPSID; ObjectType: TIPSObjectType): TIPSID; stdcall;
  function GetObjectIDByIdent(Ident: String; ParentID: TIPSID): TIPSID; stdcall;
  
  (*
  	Function: IPS_HasChildren
  	
  		The command checks whether an object with ID *ObjectID* has child objects.
  		
  	Parameters:
  	
  		ObjectID - ID of the object to be tested
  		
  	Returns:
  	
  		*TRUE* if the object has child objects, otherwise *FALSE*
  		
  	Example:
  	
  		if (IPS_IsHasChildren(0))
  		echo "The root object has child objects!";
  		
  *)
  function HasChildren(ID: TIPSID): Boolean; stdcall;
  
  (*
  	Function: IPS_IsChild
  	
  		The command checks whether an object with ID *ObjectID* is a child of the object *ParentID*. If the *Recursive* parameter is activated, all child objects are checked for any child levels. Otherwise, only the immediate child objects are checked. 
  		
  	Parameters:
  	
  		ObjectID  - ID of the object to be tested
  		ParentID  - ID of the parent object
  		Recursive - FALSE, if only one level should be checked, otherwise TRUE
  		
  	Returns:
  	
  		*TRUE* if ObjectID is the child of ParentID, otherwise *FALSE*
  		
  	Example:
  	
  		if (IPS_IsChild(0, 12345, true))
  		echo "The object 12345 is subordinate to the root object!";
  		
  *)		
  function IsChild(ID: TIPSID; Parent: TIPSID; Recursive: Boolean = True): Boolean; stdcall;
  
  (*
  	Function: IPS_GetChildrenIDs
  	
  		The command determines the IDs of all child objects of object *ObjectID*. The IDs are listed in an array.
  		
  	Returns:
  	
  		An array of integer values ​​of all IDs of the child objects of object ObjectID
  		
  	Example:
  	
  		print_r(IPS_GetChildrenIDs(32102));


		/* returns e.g.:
		Array
		(
 		[0] => 11650
 		[1] => 25578
  		[2] => 30202
 		ect. ...
	
		)
		*/
		
  *)	
  function GetChildrenIDs(ID: TIPSID): TIPSIDs; stdcall;  
  (*
  
  	Function: IPS_GetName
  	
  		This command returns the name of an object
  		
  	Parameters:
  	
  		ObjectID - ID for which the name should be returned
  		
  	Returns:
  	
  		Name of the object in the logical tree 
  		
  		
  	Example:
  	
  		echo IPS_GetName(47359);
 		//returns e.g.: My table lamp
 		
  *)
  function GetName(ID: TIPSID): String; stdcall;
  
  (*
  	Function: IPS_GetParent
  	
  		This command returns the ParentID of an object
  		
  	Parameters:
  	
  		ObjektID - ID for which to return the ParentID
  		
  	Returns:
  	
  		ParentID of the object in the logical tree of objects
  		
  	Example:
  	
  		 echo IPS_GetParent(47359);
 		//returns e.g.: 0 for the main category
 		
  *)	
  function GetParent(ID: TIPSID): TIPSID; stdcall;
  
  (*
  	Function: IPS_GetLocation
  	
  		This command is used to receive the complete path including the name of an object.
  		
  	Parameters:
  	
  		ObjektID - ID for which the path / name to be created
  		
  	Returns:
  	
  		Path / name of the object in the logical tree of objects
  		
  	Example:
  	
  		echo IPS_GetLocation(47359);
 		//returns e.g.: FHT8b\LowBattery
 	
  *)	
  function GetLocation(ID: TIPSID): String; stdcall;
 end;

 IIPSObjectManagerEx=interface(IIPSPersistence)
  ['{938A55CF-C10B-469F-BE99-31C1320ADA2C}']
 end;

//-- CategoryManager Interface
 IIPSCategoryManager=interface(IIPSMessageSink)
  ['{EF1146D4-0DFC-4293-928D-C55EEEF7AD00}']
  
  (*
  	Function: IPS_CreateCategory
  		
  		The command creates a new category. It requires no parameters. After the command execution appears in the category tree of IP-Symcon a new object, designated as e.g. "Unnamed Object (ID: 48 490)." With the help of the command <IPS_SetName> the object (in this category) will be given a meaningful name. The name is irrelevant to the identification. For this purpose, the ID is always responsible.
		The function returns an ID that can clearly identify the generated class.
	
	Returns:
	
		ID of the newly created object
		
	Example:
	
		// Creating a new category called "Rain sensing"
		$CatID = IPS_CreateCategory();       // Creating a Category
		IPS_SetName($CatID, "Rain sensing"); // Category name

  *)
  function CreateCategory(): TCategoryID; stdcall;
  
  (*
  	Function: IPS_DeleteCategory
  	
  		The command deletes the existing category with the ID *CategoryID*. All the category child objects are moved to the root category.
		
	Parameters:
	
		CategoryID - ID of the category to be deleted
		
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
		
	Example:
	
		// Delete the category 47788
		IPS_DeleteCategory(47788);
		
  *)	
  procedure DeleteCategory(ID: TCategoryID); stdcall;
  { Set the Objects Name/Parent }
//FIXME: Determine if needed  procedure SetCategoryBackground(ID: TCategoryID; MediaID: TMediaID); stdcall;
  { Getter Functions }
  
  (*
  	Function: IPS_CategoryExists
  	
  		The command will check if the category with the ID *CategoryID* exists.
  		
  	Parameters:
  	
  		CategoryID - ID of the category to be tested
  		
  	Returns:
  	
  		If the CategoryID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_CategoryExists(45724))
  		echo "Category already exists!";
  		
  *)	
  function CategoryExists(ID: TCategoryID): Boolean; stdcall;
  procedure CheckCategory(ID: TCategoryID); stdcall;
  
  (*
  	Function: IPS_GetCategoryList
  	
  		The command determines the IDs of categories in IP-Symcon. The IDs are listed in an array. If no category exists, the array is empty.
  		
  	Returns:
  	
  		An array of integer values ​​of all IDs of the categories in IP-Symcon
  		
  	Example:
  	
  		$allCategories = IPS_GetCategoryList();
		print_r($allCategories);   /* delivers e.g.:
                        Array
                        (
                            [0] => 0
                            [1] => 37659
                            [2] => 18326
                            ect. ...
                        )
                      */
                      
  *)      
  function GetCategoryList(): TCategoryIDs; stdcall;
  
  (*
  	Function: IPS_GetCategoryIDByName
  	
  		The command is trying to determine the ID of the category called *CategoryName*, whose parent owns the ID *ParentID*. It will use the ID of the first found object whose name matches with *CategoryName*. If such an object was found, its ID is returned, otherwise FALSE.
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		CategoryName - CategoryName to be searched
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found category, otherwise *FALSE*
  		
  	Example:
  	
  		$CatID = @IPS_GetCategoryIDByName("Rain sensing", $ParentID);
		if ($CatID === false)
 		echo "Category not found!";
		else
  		echo "The category ID is: ". $CatID;
  		
  *)		
  function GetCategoryIDByName(Name: String; ParentID: TIPSID): TCategoryID; stdcall;
 end;

 IIPSCategoryManagerEx=interface(IIPSPersistence)
  ['{600A7ABD-0CED-4976-A037-81E6B6A3818B}']
 end;

//-- InstanceManager Interface
 IIPSInstanceManager=interface(IIPSMessageSink)
  ['{0D8CEA36-DFA4-4576-ACC8-5675042D7599}']
  { Create an Module Instance upon the Module IID }
  
  (*
  	Function: IPS_CreateInstance
  	
  		The command creates an unconfigured instance of the ID *ModulID*. Allowable values ​​for *ModulID* can be determined via the function <IPS_GetModuleList>. The ModulID is a 32Bit GUID in the format {00000000-0000-0000-0000-000000000000}. 
  		The function returns an ID which helps to identify the created instance. After the application is the created object still unconfigured and must be configured with the appropriate device-specific functions. The configuration must be taken with the command <IPS_ApplySettings>. 
  		
  	Parameters:
  	
  		ModulID - ModulID of object to create
  		
  	Returns:
  	
  		ID of the newly created instance
  		
  	Example:
  	
  		//FS20 Create Instance
		echo IPS_CreateInstance("{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}");
		
  *)	
  function CreateInstance(ModuleID: TStrGUID): TInstanceID; stdcall;

  { Delete the Instance }

  (*
  	Function: IPS_DeleteInstance
  	
  		The command deletes an existing instance with the ID *InstanceID*.
		All the child objects of the instance are moved to the root category. Associated status variables will be deleted.
		
	Parameters:
	
		InstanceID - ID of the instance to delete
		
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		// Delete the Instance 47788
		IPS_DeleteInstance(47788);
		
  *)	
  procedure DeleteInstance(InstanceID: TInstanceID); stdcall;
  { Recreates the Interfaces for a specified IID after a Module Reload/Load and assigns it in the private Array }
  procedure ConnectModuleInstances(ModuleID: TStrGUID); stdcall;
  { Frees the Interfaces for a specified IID before a Module Unload }
  procedure DisconnectModuleInstances(ModuleID: TStrGUID); stdcall;
  { Some useful Functions }
  
  (*
   	Function: IPS_InstanceExists
   	
   		The command checks whether the instance exists with the ID *InstanceID*.
   		
   	Parameters:
   	
   		InstanceID - ID of the Instance to be tested
   		
   	Returns:
   	
   		If the InstanceID exists in the system, *TRUE* is returned, otherwise *FALSE*.
   		
   	Example:
   	
   		if (IPS_InstanceExists(45724))
  		echo "Instance already exists!";
  		
  *)
  function InstanceExists(InstanceID: TInstanceID): Boolean; stdcall;
  procedure CheckInstance(InstanceID: TInstanceID); stdcall;
  
  (*
  	Function: IPS_GetInstance
  	
  		The command returns an array containing information about the instance with the ID *InstanceID*. If the instance does not exist, an alert is generated.
  		
  	Parameters:
  	
  		InstanceID - InstanceID to be returned
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		ChildrenIDs		|		array		|		Child InstanceIDs. See: <IPS_GetInstanceChildrenIDs>
  		InstanceID		|		integer		|		InstanceID
  		InstanceStatus	|		integer		|		Status of the Instance
  													101   - Instance is created
													102	  - Instance is active
													103	  - Instance is deleted
													104   - Instance is inactive
													>=200 - Instance is marked as faulty
		LastChange		|		float		|		reserved
		ModuleInfo		|		array		|		Modulinformationen
													ModuleID   - ModulID for instance
													ModuleName - ModuleName of the instance
													ModuleType - ModulType of the Instance
		NeedParent		|		boolean		|		True if this module requires a parent instance
		ParentID		|		integer		|		Parent instance. 0 = No parent instance.
													See: <IPS_GetInstanceParentID>
		
		Example:
		
			/* returns e.g.:
			Array
			(
  			[ChildrenIDs] => Array
     		(
     		)

  			[InstanceID] => 18235
  			[InstanceStatus] => 102
  			[LastChange] => 0
  			[ModuleInfo] => Array
      		(
         	[ModuleID] => {48FCFDC1-11A5-4309-BB0B-A0DB8042A969}
         	[ModuleName] => FS20
         	[ModuleType] => 3
      		)

  			[NeedParent] => 1
  			[ParentID] => 29416
			)

			*/
			
  *)
  function GetInstance(InstanceID: TInstanceID): TIPSInstance; stdcall;
  function GetInstances(InstanceIDs: TInstanceIDs): TIPSInstances; stdcall;
  
  (*
  	Function: IPS_GetInstanceList
  	
  		The command determines the IDs of all registered IPS instances in IP Symcon. The IDs are listed in an array. If no instance exists, the array is empty.
  		
  	Returns:
  		
  		An array of integer values ​​of all IDs of the instances in IP-Symcon
  		
  	Example:
  	
  		$allInstances = IPS_GetInstanceList();
		print_r($allInstances);      /* returns e.g.:
                        Array
                        (
                            [0] => 37659
                            [1] => 18326
                      ect. ...
                      */ 
                      
  *)
  function GetInstanceList(): TInstanceIDs; stdcall;
  
  (*
  
  	Function: IPS_GetInstanceListByModuleType
  	
  		The command determines the IDs of all instances of a particular *Instance type*. The IDs are listed in an array. If there is no instance of the requested type, the array is empty.
  		It lists only objects of the type *Instance type*. If all instances to be listed, this command can be used IPS_GetInstanceList.
  		
  	Parameters:
  	
  		Value	|		Description
  		0		|		core instances
  		1		|		I/O Instances
  		2		|		splitter instances
  		3		|		device instances
  		4		|		configurator instances
  		
  	Returns:
  	
  		$allInstances = IPS_GetInstanceListByModuleType(1); // list olny I/O Instances
		print_r($allInstances);          /* returns e.g.:
                              Array
                              (
                                  [0] => 37659
                                  [1] => 18326
                            ect. ...
                            */
                            
  *)
  function GetInstanceListByModuleType(ModuleType: TIPSModuleType): TInstanceIDs; stdcall;
  
  (*
  	Function: IPS_GetInstanceListByModuleID
  	
  		The command returns all instances that match the specified *ModulID* in an array.
  		
  	Parameters:	
  	
  		ModulID - ModulID of the instances to be returned
  		
  	Returns:
  	
  		An array of integer values ​​of all matching IDs
  		
  	Example:
  	
  		//FS20 Transmitter
		$guid = "{48FCFDC1-11A5-4309-BB0B-A0DB8042A969}";

		//List
		print_r(IPS_GetInstanceListByModuleID($guid));
		
  *)
  function GetInstanceListByModuleID(ModuleID: TStrGUID): TInstanceIDs; stdcall;
  
  (*
  	Function:	IPS_GetInstanceIDByName
  	
  		The command is trying to determine the ID of the Instance called *InstanzName*, whose parent owns the ID *ParentID*. It will use the ID of the first found object whose name matches with *InstanzName*. If such an object was found, its ID is returned, otherwise FALSE.
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		InstanzName - Instance Name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found instance, otherwise *FALSE*
  		
  	Example:
  	
  		$InstanceID = @IPS_GetInstanceIDByName("Rainfall", $ParentID);
		if ($InstanceID === false)
  		echo "Instance not found!";
		else
  		echo "The Instance-ID is: ". $InstanceID;
  		
  *)		
  function GetInstanceIDByName(Name: String; ParentID: TIPSID): TInstanceID; stdcall;
  { Checks compatibility }
  
  (*
  	Function: IPS_IsInstanceCompatible
  	
  		The command determines whether two instances are compatible.
  		
  	Parameters:
  	
  		InstanceID - first ID
  		ParentID   - second ID
  		
  	Returns:
  	
  		*TRUE* if the instance is compatible, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_IsInstanceCompatible(12345, 23456))
  	echo "Instance is compatible to another instance";
  	 
  	 
  *)
  function IsInstanceCompatible(InstanceID, ParentInstanceID: TInstanceID): Boolean; stdcall;
  
  (*
  	Function: IPS_GetCompatibleInstances

  		The command determines the IDs of all available instances in IP Symcon that are compatible to *InstanzID*. The IDs are listed in an array.

  	Parameters:

  		InstanceID - ID of the instance to be tested

  	Returns:

  		Array of integer values ​​of all compatible Instance IDs to *InstanceID*

  	Example:

  		print_r(IPS_GetCompatibleInstances(12345));
		/* returns e.g.:
		Array
		(
 		[0] => 22222
  		[1] => 33333
  		[2] => 44444
  		[3] => 55555
  		ect. ...
		)
 		*/

  *)
  function GetCompatibleInstances(InstanceID: TInstanceID): TInstanceIDs; stdcall;
 end;

 IIPSInstanceManagerEx=interface(IIPSPersistence)
  ['{E359382A-74B9-4BD7-A708-7D16964311FF}']
  { Instance Status }
  function GetInstanceStatus(InstanceID: TInstanceID): Integer; stdcall;
  procedure SetInstanceStatus(InstanceID: TInstanceID; InstanceStatus: Integer); stdcall;
  { Messages }
  procedure ForwardMessage(Message: TIPSMessage); stdcall;
  procedure ForwardMessageToType(Message: TIPSMessage; ModuleType: TIPSModuleType); stdcall;
 end;

// --- VariableManager Interface
 IIPSVariableManager=interface(IIPSMessageSink)
  ['{5528E859-0D7D-41CE-9E82-D7CF50228A5B}']
  { Created a Variable }

  (*
  	Function: IPS_CreateVariable

  		The command creates a new IPS variable of the type *VariablesType*. The function returns an ID with which the created variable can be uniquely identified.

  	Parameters:

  		VariablesType - 		Value		| Description
  								0			| creates a variable of type boolean
  								1			| creates a variable of type integer
  								2			| creates a variable of type float
  								3			| creates a variable of type string

  	Returns:

  		ID of the newly created variable

  	Example:

  		// Create a float variable
		$VarID_room temperature = IPS_CreateVariable(2);

  *)
  function CreateVariable(VarType: TIPSVarType): TVariableID; stdcall;

  { Deleted a Variable }
  (*
  	Function: IPS_DeleteVariable

  		The command deletes an existing variable with the ID *VariableID*. All of the variable child objects are moved to the root category.

  	Parameters:

  		VariableID - ID of the variable to be deleted

  	Retruns:

  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.

  	Example:

  		// Delete the variable 47788
		IPS_DeleteVariable(47788);
		
  *)		
  procedure DeleteVariable(VariableID: TVariableID); stdcall;
  { Reads/Writes the Variable Value }
  function ReadVariableBoolean(VariableID: TVariableID): Boolean; stdcall;
  procedure WriteVariableBoolean(VariableID: TVariableID; VarValue: Boolean); stdcall;
  function ReadVariableInteger(VariableID: TVariableID): Integer; stdcall;
  procedure WriteVariableInteger(VariableID: TVariableID; VarValue: Integer); stdcall;
  function ReadVariableFloat(VariableID: TVariableID): Double; stdcall;
  procedure WriteVariableFloat(VariableID: TVariableID; VarValue: Double); stdcall;
  function ReadVariableString(VariableID: TVariableID): String; stdcall;
  procedure WriteVariableString(VariableID: TVariableID; VarValue: String); stdcall;

  { Get a single Variable }
  
  (*
  	Function: IPS_VariableExists
  	
  		The command checks whether the variable with the ID *VariableID* exists.
  		
  	Parameters:
  	
  		VariableID - ID of the variable to be tested
  		
  	Returns:

  		If the VariableID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_VariableExists(44788))
  		echo "Variable already exists!";
  		
  *)		
  function VariableExists(VariableID: TVariableID): Boolean; stdcall;
  procedure CheckVariable(VariableID: TVariableID); stdcall;
  
  (*
  	Function: IPS_GetVariable
  	
  		The command returns an array containing information about the variable with the ID *VariableID*.
  		
  	Parameters:
  	
  		VariableID - VariableID to be returned

  	Returns:
  	
  		The following information are available as key => value pairs:
  		VariableChanged			|	float	|	Unix timestamp when the variable was last changed
  		VariableUpdated			|	float	|	Unix timestamp when the variable was last updated
  		VariableValue			|	array	|	Value type		Variable type (0: Boolean, 1: integer 2: Float, 3: String)
  												ValueBoolean,	Value of the variable depending on the ValueType
												ValueInteger,
												ValueFloat,
												ValueString
  		VariableID				|	integer	|	VariableID
  		VariableIsBinary		|	boolean	|	Specifies whether the string variable is encoded using SOAP Base64
  		VariableIsLocked		|	boolean	|	Indicates whether this variable is above the variable limit and therefore can not be described (Available in Version 2.3)
  		VariableProfile			|	string	|	Name given by the system profile. Empty if no profile specified
  		VariableCustomProfile	|	string	|	Name given by the user profile. Empty if not specify a profile
  		VariableCustomAction	|	integer	|	ID of the script that should be started at a desired change in the variable on the visualization
  		
  	Example:
  	
  		print_r(IPS_GetVariable(40770));

 

		/* returns e.g.:
		Array
		(
  		[VariableChanged] => 1246039629.471
  		[VariableCustomAction] => 0
  		[VariableCustomProfile] => BoolProfile
  		[VariableID] => 40770
  		[VariableIsBinary] => 
  		[VariableIsLocked] =>
  		[VariableProfile] => ~Switch
  		[VariableUpdated] => 1246039629.471
  		[VariableValue] => Array
    	(
        [ValueArray] => Array
        (
        )

        [ValueBoolean] => 1
        [ValueFloat] => 0
        [ValueIndex] => Array
        (
        [IndexInt] => 0
        [IndexStr] => 
        [IndexType] => 0
        )

        [ValueInteger] => 0
        [ValueString] => 
        [ValueType] => 0
      	)

		)
		*/
		
  *)	 		
  function GetVariable(VariableID: TVariableID): TIPSVariable; stdcall;
  function GetVariables(VariableIDs: TVariableIDs): TIPSVariables; stdcall;
  
  (*
  	Function: IPS_GetVariableList
  	
  		The command determines the IDs of all registered IPS variables in IP-Symcon. The IDs are listed in an array. If no variable exists, the array is empty.
  		
  	Returns:
  		
  		An array of integer values ​​of all IDs of the variables in IP-Symcon.

  	Example:
  	
  		$allVariables = IPS_GetVariableList();
		print_r($allVariables);      /* returns e.g.:
                        Array
                        (
                            [0] => 37659
                            [1] => 18326
                      ect. ...
                      */
                      
  *)
  function GetVariableList(): TVariableIDs; stdcall;
  
  (*
  	Function: IPS_GetVariableIDByName
  	
  		The command is trying to determine the ID of the variable called *VariableName*, whose parent owns the ID *ParentID*. It will use the ID of the first found variable whose name matches with *VariableName*. If such a variable was found, its ID is returned, otherwise FALSE. Unlike <IPS_GetVariableID> is an additional criterion (ParentID) used in the search. Here, the probability to find the right ID considerably larger. Remember:
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		VariableName - Variable Name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found variable, otherwise *FALSE*	

  	Example:
  	
  		$VarID = @IPS_GetVariableIDByName("Rainfall", $ParentID);
		if ($VarID === false)
 		echo "Variable not found!";
		else
  		echo "The Variable ID is: ". $VarID;
  		
  *)		
  function GetVariableIDByName(Name: String; ParentID: TIPSID): TVariableID; stdcall;
  { Assign Profile }
  
  (*
  	Function: IPS_SetVariableCustomProfile

  		The command assigns the variable *VariableID* the custom profile *ProfileName*.
  		#Standard profiles can not be changed, if they are starting with a tilde (~).#
  		
  	Parameters:

  		VariableID  - ID of the variable to which the profile should be assigned
  		ProfileName - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
					  If an empty string is passed, then the user profile is disabled.
					 
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:

  		IPS_SetVariableCustomProfile(12345, "~Switch");
  	
  *)	
  procedure SetVariableCustomProfile(VariableID: TVariableID; VarProfileName: String); stdcall;

  (*
  	Function: IPS_SetVariableCustomAction
  	
  		The command assigns the variable *VariableID* a custom action that is used in the visualization, to forward a change in the variable to the proper function of the module. An example of an action script can be found here: <Variable profiles>

  	Parameters:
  	
  		VariableID - ID of the variable to which the profile should be assigned
  		SkriptID   - ID of the script to be listed as an action

  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  	
  *)		
  procedure SetVariableCustomAction(VariableID: TVariableID; ScriptID: TScriptID); stdcall;
 end;

 IIPSVariableManagerEx=interface(IIPSPersistence)
  ['{E731790D-F4DB-4F20-BAF8-B8A9C5F95546}']
  { Set Default Profile }
  procedure SetVariableAction(VariableID: TVariableID; InstanceID: TInstanceID); stdcall;
  procedure SetVariableProfile(VariableID: TVariableID; VarProfileName: String); stdcall;
 end;

// --- ScriptManager Interface
 IIPSScriptManager=interface(IIPSMessageSink)
  ['{ED275B5F-4944-4B37-920F-498C1AFFB14F}']
  { Register / Unregister a Script by providing a Filename which can be found in %KERNELDIR%\scripts }
  
  (*
  	Function: IPS_CreateScript
  	
  		The command creates a script from the type *ScriptType*. The function returns an ID that can help to uniquely identify the generated script. When storing in the directory "scripts" a text file named *SkriptID*.ips.php is created, e.g. "43954.ips.php". The storage process is triggered either by clicking the "Save" button or by running the script with the "Execute" button.
  		
  	Parameters:
  	
  		ScriptType - Value	|	Desription
  					 0		|	generates a normal PHP script
  					 1		|	generates a IPS Macro
  					 2		|	generates a IPS Brick
  					 
  	Returns:
  	
  		ID of the newly created script
  		
  	Example:
  	
  		$ScriptID = IPS_CreateScript(0);
		echo"The Script-ID is: ". $ScriptID;
		
  *)		
  function CreateScript(ScriptType: TIPSScriptType): TScriptID; stdcall;
  
  (*
  	Function: IPS_DeleteScript
  	
  		The command removes the script using the ID *ScriptID* from the internal list of scripts. The script will no longer appear in the tree structure and can not be edited. Deleted scripts are moved to "/ scripts / deleted /" folder. All the child objects of the script are moved to the root category.
  
  	Parameters:
  		
  		ScriptID     - ID of the script to delete
  		DeleteScript - TRUE if the file should be deleted.
					   FALSE if the file should be moved to the 'deleted' folder.
					   
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		IPS_DeleteScript($ScriptID, true); // Deleting a script including file
		
  *)
  procedure DeleteScript(ScriptID: TScriptID; DeleteFile: Boolean = False); stdcall;
  { Configure }
  
  (*
  	Function: IPS_SetScriptFile
  	
  		The command links the file name *FileName* to the script with the ID *SkriptID*. Normally, the filename of the script consists only of the ID with the extension ". Ips.php". With this command it is possible to use a different file name.
  		The file name has nothing to do with the script name, which can be seen in the Location Tree. Script name and file name can be completely different. The SkriptID remains even after the assignment. Neither the name nor the script file name can be used directly to identify the script. IP-Symcon used for this purpose, only the numerical SkriptID.
  
  	Parameters:
  	
  		ScriptID - ID of the script, the file name to be assigned
  		FileName - Filename of the PHP script (relative to the "/ scripts" folder)
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		$ScriptPath = "Example.ips.php"; //script file
		$ScriptID = IPS_CreateScript(0);                  

		//link
		IPS_SetScriptFile($ScriptID, $ScriptPath);
		
		
  *)
  procedure SetScriptFile(ScriptID: TScriptID; ScriptFile: String); stdcall;

  { Get Script Inforamtions }
  
  (*
  	Function: IPS_ScriptExists
  	
  		The command checks whether the script with the ID *SkriptID* exists.
  		
  	Parameters:
  	
  		ScriptID - ID of the script to be tested
  		
  	Returns:
  	
  		If the SkriptID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_ScriptExists(34881))
  		echo "A Script with this ID exists!";
  		
  *)	
  function ScriptExists(ScriptID: TScriptID): Boolean; stdcall;
  procedure CheckScript(ScriptID: TScriptID); stdcall;
  
  (*
  	Function: IPS_GetScript
  	
  		The command returns an array containing information about the script with the ID *SkriptID*.
  		
  	Parameters:
  	
  		ScriptID - SkriptID, which is to show
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		IsBroken	|	boolean		|	TRUE if you have an error call in the last script, otherwise FALSE
  		LastExecute |	float		|	Unix timestamp of the last call
  		ScriptFile  |	string		|	Filename of the script
  		VariableID  |	integer		|	ScriptID
  		ScriptType  |	integer		|	Script type (0: PHP Script, 1: Macro or 2 IPS: IPS Brick)
  		
  	Example:
  	
  		$ScriptID = 46413;
		$ScriptInfo = IPS_GetScript($SkriptID);
		print_r($ScriptInfo);     /* returns e.g.:
                      Array
                      (
                        [IsBroken] => false
                        [LastExecute] => 1204933792
                        [ScriptFile] => 46413.ips.php
                        [ScriptID] => 46413
                        [ScriptType] => 0
                      )
                    */
                    
  *) 
  function GetScript(ScriptID: TScriptID): TIPSScript; stdcall;
  function GetScripts(ScriptIDs: TScriptIDs): TIPSScripts; stdcall;
  
  (*
  	Function: IPS_GetScriptList
  	
  		The command determines the IDs of all registered scripts in IP-Symcon. The IDs are listed in an array. If no script exists, the array is empty.
  		
  	Returns:
  	
  		An array of integer values ​​of all IDs of the scripts in IP-Symcon
  		
  	Example:
  	
  		$alleSkripte = IPS_GetScriptList();
		print_r($allScripts);      /* returns e.g.:
                        Array
                        (
                            [0] => 37659
                            [1] => 18326
                      ect. ...
                      */
                      
  *)                   
  function GetScriptList(): TScriptIDs; stdcall;
  
  (*
  	Function: IPS_GetScriptIDByName
  	
  		The command is trying to determine the ID of the script called *ScriptName*, whose parent owns the ID *ParentID*. It will use the ID of the first found script whose name matches with *ScriptName*. If such a script was found, its ID is returned, otherwise FALSE. Unlike <IPS_GetScriptID> is an additional criterion (ParentID) used in the search. Here, the probability to find the right ID is considerably larger. Remember:
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		ScriptName   - Script Name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found script, otherwise *FALSE*	
  		
  	Example:
  	
  		$ScriptID = @IPS_GetScriptIDByName("Rain sensing", $ParentID);
		if ($ScriptID === false)
  		echo "Script not found!";
		else
  		echo "the Script ID is: ". $ScriptID;
  		
  *)
  function GetScriptIDByName(Name: String; ParentID: TIPSID): TScriptID; stdcall;
  function GetScriptIDByFile(Filepath: String): TScriptID; stdcall;
  function GetScriptFile(ScriptID: TScriptID): String; stdcall;

  (*

  *)
  function GetScriptContent(ScriptID: TScriptID): String; stdcall;
  procedure SetScriptContent(ScriptID: TScriptID; Content: String); stdcall; 
 end;

 IIPSScriptManagerEx=interface(IIPSPersistence)
  ['{9C75C9DC-D667-4F06-98C5-C34649941AAF}']
 end;

//-- EventManager Interface
 IIPSEventManager = interface(IIPSMessageSink)
  ['{FC71B118-4077-4113-882B-66017F889C26}']
  { Create / Delete Events }
  
  (*
  	Function: IPS_CreateEvent
  	
  		The command creates an event object of type *EventType*. The function returns an ID that can help to uniquely identify the created event object. After the application the created object is still unconfigured and must be configured with the functions <IPS_SetEventActive>, <IPS_SetEventScript> and <IPS_SetEventCyclic>, <IPS_SetEventTrigger>.
  		
  	Parameters:
  	
  		EventType - Value	|	Description
  					0		|	creates a "triggered" event
  					1		|	creates a "cyclical" event
  					
  	Returns:
  	
  		ID of the newly created event.
  		
  	Example:
  	
  		$eid = IPS_CreateEvent(0);        //triggered event
		IPS_SetEventTrigger($eid, 1, 15754); //On change of variable with ID 15 754
		IPS_SetParent($eid, $_IPS['SELF']); //Assigning the event
		IPS_SetEventActive($eid, true);    //Activate the event
		
		$eid = IPS_CreateEvent(1);            //triggered event
		IPS_SetEventCyclic($eid, 2, 1, 0, 3, 6);   //Every day, every 6 hours
		IPS_SetEventCyclicDateBounds($eid,
   		mktime(0, 0, 0, 12, 1, date("Y")),
   		mktime(0, 0, 0, 12, 31, date("Y"))); //1.12 - 31.12 of every year 

		IPS_SetEventCyclicTimeBounds($eid,
  		mktime(15, 0, 0),
  		mktime(23, 30, 0));               //15:00 till 23:30

		IPS_SetParent($eid, $_IPS['SELF']);   //Assigning the event
		IPS_SetEventActive($eid, true);        //Activate the event
		
		
  *)
  function CreateEvent(EventType: TIPSEventType): TEventID; stdcall;
  
  (*
  	Function: IPS_DeleteEvent
  	
  		The command deletes an existing variable with the ID *EventID*. All the child objects of the media object are moved to the root category.
  		
  	Parameters:
  	
  		EventID - ID of the event to be deleted 
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_DeleteEvent($EreignisID);
  		
  		
  *)		
  procedure DeleteEvent(EventID: TEventID); stdcall;

  { Configure Events }
  
  (*
  	Function: IPS_SetEventActive
  	
  		After the activation / deactivation the new status can be read in <IPS_GetEvent>.  In active / cyclic events, it is possible to determine the next execution date. In a deactivated event the *NextRun* value is zero.
  		
  	Parameters:
  	
  		EventID - ID of the event to be changed
  		Active  - Indicates whether the event should be activated (TRUE) /  deactivated (FALSE)
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventActive($EreignisID, true);  // Activates the event
  		
  		
  *)		
  procedure SetEventActive(EventID: TEventID; Active: Boolean); stdcall;
  
  (*
  	Function: IPS_SetEventLimit
  	
  		The limitation on number effects that the event will only run as often as specified in the limitation. Then the number is zero and the event is deactivated. Setting the number = 0 removes the limitation.
  		
  	Parameters:
  	
  		EventID - ID of the event to be changed
  		Count   - The number of executions before the event is deactivated. 0 = No Limit
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventLimit($EreignisID, 0);  //No limitation
  		
  		
  *)		
  procedure SetEventLimit(EventID: TEventID; Count: Integer); stdcall;

  (*
  	Function: IPS_SetEventScript
  	
  		Every event that is not subordinate to a script but to an instance / variable can execute an operation on the parent object (as the instance / variable). The operation can be programmed in PHP. With this command the operation can be defined as PHP code that is executed when the event occurs. The PHP will be given directly without the PHP tags (<? ...?>). The list of system variables shows what specific variables are available.
  		
  	Parameters:
  	
  		EventID 	- ID of the event to be changed
  		EventScript - PHP script without PHP tags (<? ... ?>)
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventScript($EreignisID, "echo linked object: $IPS['TARGET']");  
  		//Assign the script content to the event
  		
  		
  *)		
  procedure SetEventScript(EventID: TEventID; EventScript: String); stdcall;
  
  (*
  	Function: IPS_SetEventTrigger
  	
  		To configure a triggering event, it must be set at what type of trigger the event should react and which variable the event should observe.
  		
  	Parameters:
  	
  		EventID 	- ID of the event to be changed
  		TriggerType - Value    	|	Description
  				      0	    	|	For variable update
  				      1	    	|	For variable change
  				      2	    	|	For crossing border
  				      3	    	|	When falling short
  				      4	    	|	In certain value. Value is determined by <IPS_SetEventTriggerValue>
  				      
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventTrigger($eid, 0, 12345);   //OnUpdate for variable 12345
  		
  		
  *)		
  procedure SetEventTrigger(EventID: TEventID; TriggerType: TIPSTriggerType; TriggerVariableID: TVariableID); stdcall;
  
  (*
  	Function: IPS_SetEventTriggerValue
  	
  		Indicates the value at which the event should be run. The trigger type of the event must also be set "On value". The limit must be specified with a correct type. Otherwise the comparison may fail or be triggered unexpectedly.
  		
  	Paramerters:
  	
  		EventID      - ID of the event to be changed
  		TriggerValue - Value / type, depending on TriggerVariableID
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventTriggerValue($EventID, true); //Trigger only for​​ TRUE values 
  		
  		
  *)		
  procedure SetEventTriggerValue(EventID: TEventID; TriggerValue: Variant); stdcall;
  
  (*
  	Function: IPS_SetEventTriggerSubsequentExecution
  	
  		Indicates whether the event should be run again if triggered for the second time on a limit exceeded / felt below event. Otherwise, an event is executed only if the variable value was within the limit range and is again exceeded.
  		
  	Parameters:
  	
  		EventID      		      - ID of the event to be changed
  		AllowSubsequentExecutions - TRUE if permitted, otherwise FALSE
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetEventTriggerSubsequentExecution($EventID, true); //allow
  		
  			
  *)	
  procedure SetEventTriggerSubsequentExecution(EventID: TEventID; AllowSubsequentExecutions: Boolean); stdcall;
  
  (*
  	Function: IPS_SetEventCyclic
  	
  		To configure a cyclical event, it must determine in which intervals it should run. This will include a date interval that specifies the interval in a given day, week, month or year rhythm and a time interval that defines every day a second, minute or hour-based intervals. 
  		If the *DateInterval* "week" is selected, it is possible to determine the days of the week on which the event should be started. At an annual or monthly *DateInterval*, the day of the month / year can be specified in the parameter *DateValue*. For all other types the parameter with the placeholder 0 can be used.
  		§Remarks: - (Monthly) In the version "On the X. day all Y months", X> = 31, that the last day of the month is chosen.
  				  - (Monthly) In the variant "On the X. weekday all months" X must contain only the values ​​1-4. Although in some months e.g. the 5th Friday exists, so is this special case not supported.	  
  				  - (Annually) In the variant "The X. months", a timer is executed only if X is a valid day in the month, otherwise the timer is not running. The special case of the 29th February is not supported.§
  				  
  	Parameters:
  	
  		EventID      		  - ID of the event to be changed
  		DateType     		  - Value    	|	Description
  				       			0	    	|	No date type. Daily execution.
  				       			1	    	|	Once. IPS_SetEventCyclicDateBounds for target date 
  				       			2	    	|	Daily
  				       			3	    	|	Weekly
  				       			4	    	|	Monthly
  				       			5	    	|	Annually
  		DateInterval 		  - Date type	|	Description
  					   			0			|	0 (No Evaluation)
  					   			1			|	0 (No Evaluation)
  					   			2			|	Every X day
  					   			3			|	Every X week
  					   			4			|	Every X month
  					   			5			|	1 = January ... 12 = December
  		DateDay  	  		  - Date type	|	Description
  					   			0			|	0 (No Evaluation)
  					   			1			|	0 (No Evaluation)
  					   			2			|	0 (No Evaluation)
  					   			3			|	Add favorite daily values:
  					   							Monday		|	+1
  					   							Tuesday 	|	+2
  					   							Wednesday 	|	+4
  					   							Thursday 	|	+8
  					   							Friday 		|	+16
  					   							Saturday	|	+32
												Sunday		|	+64 
  					   			4			|	Monday		|	1
  					   							Tuesday 	|	2
  					   							Wednesday 	|	4
  					   							Thursday 	|	8
  					   							Friday 		|	16
  					   							Saturday	|	32
												Sunday		|	64 
  					   			5			|	0 (No Evaluation)
  		DateDayinterval 	  - Date type	|	Description
  					   			0			|	0 (No Evaluation)
  					   			1			|	0 (No Evaluation)
  					   			2			|	0 (No Evaluation)
  					   			3			|	0 (No Evaluation)
  					   			4			|	Every X day in the month
  					   			5			|	Every X day in the year
  		TimeType			  - Date type	|	Description
  					   			0			|	Once. <IPS_SetEventCyclicTimeBounds> for target time
  					   			1			|	every second
					   			2			|	every minute
  					   			3			|	hourly	
  		TimeInterval		  - Date type	|	Description
  					   			0			|	0 (No Evaluation)
  					   			1			|	Every X second
					   			2			|	Every X minute
  					   			3			|	Every X	hour
  					   			
  		Returns:
  		
  			If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  			
  		Example:

  			IPS_SetEventCyclic($eid, 2, 1, 0, 0, 3, 6);   //Every day all 6 hours


			IPS_SetEventCyclic($eid, 0, 0, 0, 2, 2 ,2); //Every 2 minutes

			IPS_SetEventCyclic($eid, 3, 2, 5, 0, 0, 0);   //Every 2 weeks at Monday+Wednesday
			IPS_SetEventCyclicTimeBounds($eid,
   			mktime(15, 0, 0), 0);            //always at 3 pm


  *)
  procedure SetEventCyclic(EventID: TEventID; DateType: TIPSCyclicDateType; DateValue, DateDay, DateDayValue: Integer; TimeType: TIPSCyclicTimeType; TimeValue: Integer); stdcall;

  procedure SetEventCyclicDateFrom(EventID: TEventID; Day, Month, Year: Integer); stdcall;
  procedure SetEventCyclicDateTo(EventID: TEventID; Day, Month, Year: Integer); stdcall;
  procedure SetEventCyclicTimeFrom(EventID: TEventID; Hour, Minute, Second: Integer); stdcall;
  procedure SetEventCyclicTimeTo(EventID: TEventID; Hour, Minute, Second: Integer); stdcall;
  
  { Retrieve Events }
  
  (*
  	Function: IPS_EventExists
  	
  		The command checks whether the event ID *EventID* exists.
  		
  	Parameters:
  	
  		EventID - ID of the event to be tested
  		
  	Returns:
  	
  		If the EventID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_EreignisExists(34881))
  		echo "A event with this ID exists!";
  		
  		
  *)

  function EventExists(EventID: TEventID): Boolean; stdcall;
  procedure CheckEvent(EventID: TEventID); stdcall;
  
  (*
  	Function:
  	
  		The command returns an array containing information about the event with ID *EventID*.
  		
  	Parameters:
  	
  		EventID - EventID, which is to show
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		CyclicDateType				|	integer		|	Date type. See: <IPS_SetEventCyclic>
  		CyclicDateValue				|	integer		|	Date interval. See: <IPS_SetEventCyclic>
  		CyclicDateDay				|	integer		|	Day of date. See: <IPS_SetEventCyclic>
  		CyclicDateDayValue			|	integer		|	Day of date, interval. See: <IPS_SetEventCyclic>
  		CyclicDateFrom				|	float		|	Unix Timestamp of the start day of the event, 0 = Always. See: <IPS_SetEventCyclicDateBounds>
  		CyclicDateTo				|	float		|	Unix Timestamp of final day of the event, 0 = Never. See: <IPS_SetEventCyclicDateBounds>
  		CyclicTimeType				|	integer		|	Time type. See: <IPS_SetEventCyclic>
  		CyclicTimeValue				|	integer		|	Time interval. See: <IPS_SetEventCyclic>
  		CyclicTimeFrom				|	float		|	Unix Timestamp of the start time for the event, 0 = Midnight. See: <IPS_SetEventCyclicTimeBounds>
  		CyclicTimeTo				|	float		|	Unix timestamp of the end time for the event, 0 = Midnight. See: <IPS_SetEventCyclicTimeBounds>
  		EventID						|	integer		|	EventID
  		EventLimit					|	integer		|	Remaining number of executions. 0 = No Limit
  		EventScript					|	string		|	PHP code of the operation to be performed
  		EventActive					|	boolean		|	TRUE if the event is active
  		EventType					|	integer		|	Event Type: (0: trigger 1: cyclic)
  		LastRun						|	float		|	Unix timestamp of the last run, 0 = Never
  		NextRun						|	float		|	Unix timestamp of the next run, 0 = Never
  		TriggerSubsequentExecution	|	boolean		|	Allow to run again in triggering without value change
  		TriggerType					|	integer		|	Value for the trigger type: See: <IPS_SetEventTrigger>
  		TriggerUseDefaultValue		|	boolean		|	TRUE if the value above / below of the variable should be used
  		TriggerVariableID			|	integer		|	VariablenID to be used as a trigger
  		
  	Example:
  	
  		$EventID = 46413;
		$EventInfo = IPS_GetEvent($EreignisID);
		print_r($EventInfo);      

		/* returns e.g.:
		Array
		(
  		[CyclicDateData] => 0
  		[CyclicDateFrom] => 1228082400
  		[CyclicDateTo] => 1230674400
  		[CyclicDateValue] => 2
  		[CyclicDateDay] => 0
  		[CyclicDateDayValue] => 1
  		[CyclicTimeFrom] => 1223816400
  		[CyclicTimeTo] => 1223847000
  		[CyclicTimeType] => 3
  		[CyclicTimeValue] => 6
  		[EventID] => 35365
  		[EventLimit] => -1
  		[EventScript] => 
  		[EventActive] => 1
  		[EventType] => 1
  		[LastRun] => 0
  		[NextRun] => 1228136400
  		[TriggerSubsequentExecution] => 1
  		[TriggerType] => 0
  		[TriggerUseDefaultValue] => 1
  		[TriggerVariableID] => 0
		)
		*/
  		
  		
  *)		
  function GetEvent(EventID: TEventID): TIPSEvent; stdcall;
  function GetEvents(EventIDs: TEventIDs): TIPSEvents; stdcall;
  
  (*
  	Function: IPS_GetEventList
  	
  		The command determines the IDs of all registered events in IP-Symcon. The IDs are listed in an array. If no event exists, the array is empty.
  		
  	Parameters:
  	
  		An array of integer values ​​of all IDs of the events in IP-Symcon
  		
  	Example:
  	
  		$allEvents = IPS_GetEventList();
		print_r($allEvents); /* returns e.g.:
                        Array
                        (
                            [0] => 37659
                            [1] => 18326
                      ect. ...
                     */
                     
                     
  *) 
  function GetEventList(): TEventIDs; stdcall;
  
  (*
  	Function: IPS_GetEventListByType
  	
  		The command determines the IDs of all events of a specific *EventType*. The IDs are listed in an array. If no event with the specific type exists, the array is empty. It lists only objects of the event type *EventType*. If all events shuold be listed, this command can be used <IPS_GetEventList>.
  		
  	Parameters:
  	
  		EventType - Value	|	Description
  					0		|	triggered event
  					1		|	cyclical event
  					
  	Returns:
  	
  		An array of integer values ​​of all IDs of the event with the type *EventType* in IP-Symcon.
  		
  	Example:
  	
  		$allEvents = IPS_GetEventListByType(1); // list only cyclical events 
		print_r($alleEreignisse);         /* returns e.g.:
                              Array
                              (
                                  [0] => 37659
                                  [1] => 18326
                            ect. ...
                            */
                            
                            
  *)
  function GetEventListByType(EventType: TIPSEventType): TEventIDs; stdcall;
  
  (*
  	Function: IPS_GetEventIDByName
  	
  		The command is trying to determine the ID of the event called *EventName*, whose parent owns the ID *ParentID*. It will use the ID of the first found event whose name matches with *EventName*. If such an event was found, its ID is returned, otherwise FALSE. 
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		EventName    - Script Name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found event, otherwise *FALSE*.
  		
  	Example:
  	
  		$EventID = @IPS_GetEventIDByName("TimerABC", $ParentID);
		if ($EventID === false)
  		echo "Event not found!";
		else
  		echo "The Event ID is: ". $EreignisID;
  		
  		
  *)	
  function GetEventIDByName(Name: String; ParentID: TIPSID): TEventID; stdcall;

  { Retrieve Events for Scripts/Variables }
  
  (*
  	Function: IPS_GetVariableEventList
  	
  		The command returns an array whose elements are the respective IDs of the events in which the variable *VariableID* is used. The events can be further processed by the command <IPS_GetEvent>.
  		
  	Parameters:
  	
  		VariableID - Related events of the VariableID are to be searched 
  		
  	Returns:
  	
  		An array of integer values ​​of all EventIDs associated with the variable VariableID.
  	
  	Example:
  	
  		$events = IPS_GetVariableEventList(12345);
		print_r($events);  // determines all events of the current script 
		
  *)
  function GetVariableEventList(VariableID: TVariableID): TEventIDs; stdcall;
  
  (*
  	Function: IPS_GetScriptEventList
  	
  		The command returns an array whose elements are the respective IDs of the events in which the script *ScriptID* is used. The events can be further processed by the command <IPS_GetEvent>.
  		
  	Parameters:
  	
  		SkriptID - Related events of the ScriptID are to be searched 
  		
  	Returns:
  	
  		An array of integer values ​​of all EventIDs associated with the script SkriptID.
  		
  	Example:
  	
  		$events = IPS_GetScriptEventList($_IPS['SELF']);
		print_r($events);  // determines all events of the current script
		
		
  *)		
  function GetScriptEventList(ScriptID: TScriptID): TEventIDs; stdcall;
 end;

 IIPSEventManagerEx=interface(IIPSPersistence)
  ['{D884D3FA-14C5-4C2A-A99E-F0702C5BFBE9}']
 end;
 
 // --- MediaManager Interface
 IIPSMediaManager=interface(IIPSMessageSink)
  ['{53392D3E-3AA1-4A1C-B3A3-F39F851D2D63}']
  { Register / Unregister a Media by providing a Filename which can be found in %KERNELDIR%\Medias }
  
  (*
  	Function: IPS_CreateMedia
  	
  		The command creates an empty media object of the type *MediaType*. The function returns an ID that can help to uniquely identified the created media object. After the application the created object is still empty and needs to be connected with the function <IPS_SetMediaFile> with a real media file.
  		
  	Parameters:
  	
  		MediaType - Value	|	Description
  					0		|	creates a designer form
  					1		|	creates an image object
  					2		|	creates a sound object
  				
  	Returns:
  	
  		ID of the newly created media object
  		
  	Example:
  	
  		$ImageFile = "C:\\Pictures\\Alarm symbol.png";  // Image file
		$MediaID = IPS_CreateMedia(1);           // create the image in the media pool
		IPS_SetMediaFile($MediaID, $ImageFile);    // link the image in the media pool with image file
		
		
  *)	
  function CreateMedia(MediaType: TIPSMediaType): TMediaID; stdcall;
  
  (*
  	Function: IPS_DeleteMedia
  	
  		The command removes the media object with ID MediaID from the media pool. All the child objects of the media object are moved to the root category.
  
  	Parameters:
  	
  		MediaID		- ID of the media object to be deleted
  		DeleteFile	- TRUE if the file should be deleted.
					  FALSE if the file should be moved to the 'deleted' folder.
					  
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		IPS_DeleteMedia($MediaID, true);
		
  *)		
  procedure DeleteMedia(MediaID: TMediaID; DeleteFile: Boolean = False); stdcall;
  { Configure }
  
  (*
  	Function: IPS_SetMediaFile
  	
  		The command links the file name *FileName* to the media object with ID *MedienID*. The parameter *FileMustExist* indicates whether to check if the file exists. The allocated media file must match the media type of the media object.
  	
  	Parameters:
  	
  		MediaID       - ID of the object media to be changed
  		FileName      - Filename of the media file. The following extensions are allowed:
  				        Type of media object   | appropriate media files
  				        0 (Designer form)	   | bin
  				        1 (Image object)	   | bmp
					  					       | jpg, jpeg
          			  					   	   | gif
      				  					   	   | png
					  					   	   | ico
  				        2 (Sound object)	   | wav
					  					   	   | mp3
		FileMustExist - TRUE, if existence is to be checked, otherwise FALSE								
										
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		$ImageFile = "C:\\Bilder\\Alarmsymbol.png";  // Image file
		$MediaID = IPS_CreateMedia(1);           // create the image in the media pool
		IPS_SetMediaFile($MediaID, $ImageFile);    // link the image in the media pool with image file
		
		
  *)		
  procedure SetMediaFile(MediaID: TMediaID; MediaFile: String; FileMustExist: Boolean = True); stdcall;

  { Get Media Informations }
  
  (*
  	Function: IPS_MediaExists
  	
  		The command checks whether the media object with the ID *MediaID* exists.
  		
  	Parameters:
  	
  		MediaID - ID of the media object to be tested
  		
  	Returns:
  	
  		If the MediaID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_MediaExists(34881))
  		echo "A media object with this ID exists!";
  		
  *)		
  function MediaExists(MediaID: TMediaID): Boolean; stdcall;
  procedure CheckMedia(MediaID: TMediaID); stdcall;
  
  (*
  	Function: IPS_GetMedia
  	
  		The command returns an array with information about media with the ID *MediaID*.
  		
  	Parameters:
  	
  		MediaID - MediaID, which is to show
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		IsAvailable	|	boolean 	|	TRUE if media file is available
  		IsLinked	|	boolean 	|	TRUE if the file is located outside the Media folder
  		LastUpdate	|	float		|	Unix timestamp of last update
  		MediaCRC	|	string		|	CRC32 of the file
  		MediaFile	|	string		|	Path to the file
  		MediaID		|	integer		|	MediaID	
  		MediaSize	|	integer		|	Size in bytes
  		MediaType	|	integer		|	Media Type (0: Form 1: Image 2: sound)
  		
  	Example:
  	
  		print_r(IPS_GetMedia(45699))
		/* returns e.g.:
		Array
		(
  		[IsAvailable] => 1
  		[IsLinked] => 
  		[LastUpdate] => 1214421546.474
  		[MediaCRC] => E2D2C1D1
  		[MediaFile] => media\45699.bin
  		[MediaID] => 45699
  		[MediaSize] => 8192
  		[MediaType] => 0
		)
		*/
		

  *)		
  function GetMedia(MediaID: TMediaID): TIPSMedia; stdcall;
  function GetMedias(MediaIDs: TMediaIDs): TIPSMedias; stdcall;
  
  (*
  	Function: IPS_GetMediaList
  	
  		The command determines the IDs of all registered media objects in the media pool. The IDs are listed in an array. If no media object exists, the array is empty.
  		
  	Returns:
  	
  		An array of integer values ​​of all IDs of the media objects in IP-Symcon
  		
  	Example:
  	
  		$allMediaObjects = IPS_GetMediaList();
		print_r($allMediaObjects);  /* returns e.g.:
                        Array
                        (
                            [0] => 37659
                            [1] => 18326
                      ect. ...
                      */
                      
  *)		
  function GetMediaList(): TMediaIDs; stdcall;
  
  (*
  	Function: IPS_GetMediaListByType
  	
  	The command determines the IDs of all registered media objects in the media pool. The IDs are listed in an array. If no media object exists, the array is empty. It lists only objects of the media type *MediaType*. If all media objects should be listed, this command can be used <IPS_GetMediaList>.
  		
  	Parameters:
  	
  		MediaType - Value	|	Description
  					0		|	creates a designer form
  					1		|	creates an image object
  					2		|	creates a sound object
  					
  	Returns:
  	
  		An array of integer values ​​of all IDs of the media objects with the type *MediaType* in IP-Symcon.
  		
  	Example:
  	
  		$allImageObjects = IPS_GetMediaListByType(1); // list only Image objects
		print_r($allImageObjects);         /* returns e.g.:
                              Array
                              (
                                  [0] => 37659
                                  [1] => 18326
                            ect. ...
                            */
                            
                 
  *)               
  function GetMediaListByType(MediaType: TIPSMediaType): TMediaIDs; stdcall;
  
  (*
  	Function: IPS_GetMediaIDByName
  	
  		The command is trying to determine the ID of the media called *MediaName*, whose parent owns the ID *ParentID*. It will use the ID of the first found media whose name matches with *MediaName*. If such a media was found, its ID is returned, otherwise FALSE. Unlike <IPS_GetMediaID> is an additional criterion (ParentID) used in the search. Here, the probability to find the right ID is considerably larger. Remember:
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		MediaName    - Media name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found media object, otherwise *FALSE*	
  		
  	Example:
  	
  		$MediaID = @IPS_GetMediaIDByName("MyPicture", $ParentID);
		if ($MediaID === false)
  		echo "Picture not found!";
		else
  		echo "The Media ID is: ". $MediaID;
  		
  		
  *)		
  function GetMediaIDByName(Name: String; ParentID: TIPSID): TMediaID; stdcall;
  
  (*
  	Function: IPS_GetMediaIDByFile
  	
  		The command tries to find the ID of the media with the path *MediaPath*. If the *MediaPath* does not exist in IP-Symcon, a warning is generated. The warning can be caught with the @ operator.
  		
  	Parameters:
  	
  		MediaPath - Relative media path as seen from main programm path
  		
  	Returns:
  	
  		ID of the found media object, otherwise 0 and Warning
  		
  	Example:
  	
  		$MediaID = @IPS_GetMediaIDByFile("media\\help.png");
		if ($MediaID == 0)
  		echo "Picture not found!";
		else
  		echo "The Media ID is: ". $MediaID;
  		
  	
  *)	
  function GetMediaIDByFile(Filepath: String): TMediaID; stdcall;
  { Actions }
  
  (*
  	Function: IPS_SendMediaEvent
  	
  		The command sends a message that the media object with ID *MediaID* has changed. This message is used for example from the dashboard to update an image / form. For media files in the 'media' folder, this command is not necessary because all changes are monitored from the internal system of IP-Symcon. Any changes will be sent automatically.
  		
  	Parameters:
  	
  		MediaID - ID of the media object to be tested
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SendMediaEvent(12345);
  		
  	
  *)	
  procedure SendMediaEvent(MediaID: TMediaID); stdcall;

  function GetMediaContent(MediaID: TMediaID): String; stdcall;
  procedure SetMediaContent(MediaID: TMediaID; Content: String); stdcall; 
 end;

 IIPSMediaManagerEx=interface(IIPSPersistence)
  ['{CE4EBF3F-B34D-47A3-B9C9-58FA7964A3DB}']
 end;
 
 // --- LinkManager Interface
 IIPSLinkManager=interface(IIPSMessageSink)
  ['{275A6FAF-EA8B-4641-97CB-31ED5673F2F4}']
  
  (*
  	Function: IPS_CreateLink
  	
  		The command creates a new link. It requires no parameters. After the command a new object named as "Unnamed Object (ID: 48 490)" appears in the category tree of IP Symcon. With the help of the command <IPS_SetName> the object (here the link) can be given a meaningful name. The name is irrelevant to the identification. For this purpose, the ID is always responsible.Furthermore, the link should be linked to another object. This can be done via the function <IPS_SetTargetID>.
		The function returns an ID that can help to clearly identify the generated link.
		
	Returns:
	
		ID of the newly created link
		
	Example:
	
		//Creating a new category called "rain sensing"
		$LinkID = IPS_CreateLink();       //Create link
		IPS_SetName($LinkID, "Regenerfassung"); //name the link
		IPS_SetTargetID($LinkID, 12345);     //Combine the link
	
	
  *)	
  function CreateLink(): TLinkID; stdcall;
  
  (*
  	Function: IPS_DeleteLink
  	
  		The command deletes the existing category with the ID *LinkID*. All the child objects of the link are moved to the root category.
  		
  	Parameters:
  	
  		LinkID - ID of the link to be deleted
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		//Delete the Link 47788
		IPS_DeleteLink(47788);
		
		
  *)		
  procedure DeleteLink(LinkID: TLinkID); stdcall;
  { Set the Objects Name/Parent }
  
  (*
  	Function: IPS_SetTargetID
  	
  		The command links a specific object *LinkedObject* with the link LinkID together so that the link points to this object.
  		
  	Parameters:
  	
  		LinkID 		 - ID of the Link to be changed 
  		LinkedObject - ID of the object to be linked
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		IPS_SetTargetID($LinkID, 12345); //Refer to object 12 345
  		
  	
  *)	
  procedure SetLinkTargetID(LinkID: TLinkID; TargetID: TIPSID); stdcall;

  { Getter Functions }
  
  (*
  	Function: IPS_LinkExists
  	
  		The command checks whether a link exists with the ID *LinkID*.
  		
  	Parameters:
  	
  		LinkID - ID of the link to be tested
  		
  	Retruns:
  	
  		If the LinkID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:
  	
  		if (IPS_LinkExists(45724))
  		echo "Link already exists!";
  
  
  *)
  function LinkExists(LinkID: TLinkID): Boolean; stdcall;
  procedure CheckLink(LinkID: TLinkID); stdcall;
  
  (*
  	Function: IPS_GetLink
  	
  		The command returns an array containing information about the link with the ID *LinkID*. If the link does not exist, a warning is generated.
  		
  	Parameters:
  	
  		LinkID - LinkID, which is to show
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		LinkID			| integer	| ObjectID	
  		TargetID		| integer	| ID of the object with which this link is connected. See <IPS_SetTargetID>
  		LinkChildID	| integer	| Deprecated field.

  	Example:
  	
  		print_r(IPS_GetLink(19668));

		/* returns e.g.:
		Array
		(
  		[LinkID] => 19668
  		[LinkTargetID] => 14444
		)
		*/
		
  *)		
  function GetLink(LinkID: TLinkID): TIPSLink; stdcall;
  function GetLinks(LinkIDs: TLinkIDs): TIPSLinks; stdcall;
  
  (*
  	Function: IPS_GetLinkList
  	
  		The command determines the IDs of all available links IP-Symcon. The IDs are listed in an array. If no link exists, the array is empty.
  		
  	Returns:
  	
  		An array of integer values ​​of all IDs of links in IP-Symcon.
  		
  	Example:
  	
  		$allLinks = IPS_GetLinkList();
		print_r($allLinks);    /* returns e.g.:
                        Array
                        (
                            [0] => 0
                            [1] => 37659
                            [2] => 18326
                            ect. ...
                        )
                      */
                      
                      
  *)                    
  function GetLinkList(): TLinkIDs; stdcall;
  
  (*
  	Function: IPS_GetLinkIDByName
  	
  		The command is trying to determine the ID of the link called *LinkName*, whose parent owns the ID *ParentID*. It will use the ID of the first found link whose name matches with *LinkName*. If such a link was found, its ID is returned, otherwise FALSE.
  		§Names in IP-Symcon can be chosen freely, so they are not unique. For this reason, the command can return a false ID.§
  		#This function generates a warning if the name was not found. Use the @ operator, if you want to suppress this message. The exact function of this operator you can look up in the PHP manual.#
  	
  	Parameters:
  	
  		LinkName     - Link name to be returned
  		ParentID     - Object to be searched in its child objects
  		
  	Returns:
  	
  		ID of the found link$LinkID = @IPS_GetLinkIDByName("Verlinkte Regenerfassung", $ParentID);

	Example:
	
		if ($LinkID === false)
			echo "Link not found!";
		else
			echo "The Link ID is: ". $LinkID;, otherwise *FALSE*	
  		
  		
  *)		
  function GetLinkIDByName(Name: String; ParentID: TIPSID): TLinkID; stdcall;
 end;

 IIPSLinkManagerEx=interface(IIPSPersistence)
  ['{51D8796B-7D51-4EB6-A40F-DA8D7D72101F}']
 end;
 
//-- ScriptEngine Interface
 IIPSScriptEngine=interface(IIPSMessageSink)
  ['{CEB34938-A40C-4A5E-94B3-9013772CFB62}']
  { Scripting Functions }
  function FunctionExists(FunctionName: String): Boolean; stdcall;
  function GetFunction(FunctionName: String): TIPSPHPFunction; stdcall;
  function GetFunctions(FunctionNames: TStringArray): TIPSPHPFunctions; stdcall;
  function GetFunctionList(Filter: TIPSID = 0): TStringArray; stdcall;
  { ScriptThread Status }
  function ScriptThreadExists(ThreadID: TThreadID): Boolean; stdcall;
  procedure CheckScriptThread(ThreadID: TThreadID); stdcall;
  function GetScriptThread(ThreadID: TThreadID): TIPSScriptThreadInfo; stdcall;
  function GetScriptThreads(ThreadIDs: TThreadIDs): TIPSScriptThreadInfos; stdcall;
  function GetScriptThreadList(): TThreadIDs; stdcall;
  { Execution }
  function ExecuteScript(ScriptID: TScriptID; DoWait: Boolean): String; stdcall;
  function ExecuteFile(ScriptFile: String; DoWait: Boolean): String; stdcall;
  function ExecuteText(ScriptText: String; DoWait: Boolean): String; stdcall;
  { Extended Execution }
  procedure ExecuteScriptEx(ScriptID: TScriptID; Sender: String; DoWait: Boolean; var ExecuteInfo: TIPSExecuteInfo); stdcall;
  procedure ExecuteFileEx(ScriptFile: String; Sender: String; DoWait: Boolean; var ExecuteInfo: TIPSExecuteInfo); stdcall;
  procedure ExecuteTextEx(ScriptText: String; Sender: String; DoWait: Boolean; var ExecuteInfo: TIPSExecuteInfo); stdcall;
 end;

 IIPSScriptEngineEx=interface(IIPSMessageSink)
  ['{028ECD1E-544B-4DC2-969A-4858F1584EEE}']
  { Register PHP Functions }
  procedure RegisterFunction(FunctionName: String; Parameters: TIPSPHPParameterInfos; Result: TIPSPHPParameterInfo; FunctionHandler: TIPSPHPExecute; InstanceID: TInstanceID = 0; Singleton: Boolean = True); stdcall;
  procedure UnregisterFunction(FunctionName: String; InstanceID: TInstanceID = 0); stdcall;
  { Register Instance Functions }
  procedure RegisterFunctions(Info: PTypeInfo; Prefix: String; FunctionHandler: TIPSPHPExecute; InstanceID: TInstanceID = 0; Singleton: Boolean = True); stdcall;
  procedure UnregisterFunctions(InstanceID: TInstanceID); stdcall;
  { Required for JSON-RPC API }
  function ExecuteFunction(FunctionName: String; Parameters: ISuperObject): ISuperObject;
 end;

//-- TimerPool Interface
 IIPSTimerPool = interface(IIPSMessageSink)
 ['{BB4A97E0-D803-4D5E-9A6A-1D5DCC49EF47}']
  { Get Timers }
  function TimerExists(TimerID: TTimerID): Boolean; stdcall;
  procedure CheckTimer(TimerID: TTimerID); stdcall;
  function GetTimer(TimerID: TTimerID): TIPSTimer; stdcall;
  function GetTimers(TimerIDs: TTimerIDs): TIPSTimers; stdcall;
  function GetTimerList(): TTimerIDs; stdcall;
 end;

 IIPSTimerPoolEx = interface(IIPSMessageSink)
  ['{6EBEA65A-62D7-4DE8-8FA2-E268E35D5DAA}']
  { Register Timer }
  function RegisterTimer(Name: String; InstanceID: TInstanceID; OnEvent: TTimerEvent; Seconds: Integer = 0): TTimerID; stdcall;
  function RegisterTimerEx(Name: String; InstanceID: TInstanceID; OnEvent: TTimerEvent; Milliseconds: Integer = 0): TTimerID; stdcall;
  procedure UnregisterTimer(TimerID: TTimerID); stdcall;
  { Configure Timer }
  procedure SetInterval(TimerID: TTimerID; Seconds: Integer); stdcall;
  procedure SetIntervalEx(TimerID: TTimerID; Milliseconds: Integer); stdcall;
  procedure ResetTimer(TimerID: TTimerID); stdcall;
 end;

//-- DiscoveryServer Interface
 IIPSDiscoveryServer = interface(IIPSMessageSink)
  ['{440DD282-CD53-44F3-B739-75B0B1485F9A}']
 end;

 IIPSDiscoveryServerEx = interface(IIPSMessageSink)
  ['{5BAE6D93-3D0B-48E0-B2B1-CB176E76E3AB}']
  function GetUUID: String;
  function GetSerialNumber: String;
 end;

// --- VariableManager Interface
 IIPSProfilePool=interface(IIPSMessageSink)
  ['{39D2A7B2-C402-4F73-B91B-78A446BC6744}']
  (*
  	Function: IPS_CreateVariableProfile
  	
  		The command creates a new variable profiles for the type *VariableType*. The function returns an ID that can be uniquely identified with the help of the created variable.
  		
  	Parameters:
  	
  		ProfileName   - Name of the profile. Allowed are A-Z, period, comma, underscore
  		VariablenTyp - Value 	|	Desription
  					   0		|	specifies a variable profile of the type boolean
  					   1		|	specifies a variable profile of the type integer
  					   2		|	specifies a variable profile of the type float
  					   3		|	specifies a variable profile of the type string

  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		//Create a profile for Boolean variables
 		IPS_CreateVariableProfile("Schalter", 0);
		//... here the further configuration of the profile

  *)		
  procedure CreateVariableProfile(VarProfileName: String; VarProfileType: TIPSVarType); stdcall;
  
  (*
  	Function: IPS_DeleteVariableProfile
  	
  		The command deletes an existing variable profile named *ProfileName*.
  		
  	Parameters:

  		ProfileName - Name of profile to be deleted
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
  		
  	Example:
  	
  		//Deleting the profile switch
		IPS_DeleteVariableProfile("Switch");
		
  *)	
  procedure DeleteVariableProfile(VarProfileName: String); stdcall;
  { Modify Profile }

  (*
  	Function: PS_SetVariableProfileText
  	
  		The command sets the prefix and suffix of a variable profile with the name *ProfileName*.

  	Parameters:
  	
  		ProfileName - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
  		Prefix      - Prefix for the value
  		Suffix      - Suffix for the value
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.

  	Example:
  	
  		IPS_SetVariableProfileText("Switch", "", "%");
  		
  *)
  procedure SetVariableProfileText(VarProfileName: String; Prefix, Suffix: String); stdcall;
  
  (*
  	Function: IPS_SetVariableProfileValues

  		The command sets the minimum value, maximum value and the step size of a variable profile  with the name *ProfileName*.
  		
  	Parameters:
  	
  		ProfileName   - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
  		MinValue      - The minimum value used for the visualization. This soft-limitation does not affect the variable value.
  		MaxValue      - The maximum value used for the visualization. This soft-limitation does not affect the variable value.
  		StepSize      - The step size used for the visualization to create the setpoint change bar.
						A step size of 0 enables the association list.

	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		IPS_SetVariableProfileValues("Temperature", -10, 40, 0.5);
		
  *)		
  procedure SetVariableProfileValues(VarProfileName: String; MinValue, MaxValue, StepSize: Double); stdcall;
  
  (*
  	Function: IPS_SetVariableProfileDigits
  	
  		The command sets the number of decimal places of a variable profile named *ProfileName*.
  		
  	Parameters:
  	
  		ProfileName    - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
  		Decimal places - Number of decimal places displayed in the visualization
  		
  	Returns:
  	
  		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.

  	Example:
  	
  		IPS_SetVariableProfileDigits("Temperature", 1);
  		
  *)
  procedure SetVariableProfileDigits(VarProfileName: String; Digits: Integer); stdcall;

  (*
  	Function: IPS_SetVariableProfileIcon
  	
  		The command sets the default used icon of a variable profile named *ProfileName*.
  		§The order of the icons is as follows:
		# AssoziationsIcon -> ProfileIcon -> LinkIcon -> ObjectIcon§
		#Standard profiles can not be changed, if they are starting with a tilde (~).#
		
	Parameters:
	
		ProfileName - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
		Icon		- Icon to the specified value
		#If name and icon are empty, the association to the specified value is cleared.#
		
	Returns:

 		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
 		
 	Example:
 	
 		IPS_SetVariableProfileIcon("Temperature",  "Temperature");
		
  *)
  procedure SetVariableProfileIcon(VarProfileName: String; Icon: String); stdcall;

  (*
  	Function: PS_SetVariableProfileAssociation

  		The command sets the name, the icon and the color profile for a value of a variable profile named *ProfileName*.
  		#Standard profiles can not be changed, if they are starting with a tilde (~).#
  		
  	Parameters:

  		ProfileName - Name of the profile. Available profiles can be queried via <IPS_GetVariableProfileList>.
  		Value		- The value that should be linked to the name and icon
  		Name		- Name to the specified value
  		Icon		- Icon to the specified value
  		Color		- Color value in the HTML color code (e.g. 0x0000FF blue).
					  Special case: -1 for transparent
		#If name and icon are empty, the association to the specified value is cleared.#
		
 	Returns:

 		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
 		
 	Example:
 	
 		//Creating the value 1 in the white color
		IPS_SetVariableProfileAssociation("Temperature", 1, "Value 1", "Speaker", 0xFFFFFF);

		//Delete value 1
		IPS_SetVariableProfileAssociation("Temperature", 1, "", "", -1);

  *)
  procedure SetVariableProfileAssociation(VarProfileName: String; AssociationValue: Double; AssociationName, AssociationIcon: String; AssociationColor: Integer); stdcall;
    
  { Enumeration }

  (*
  	Function: IPS_VariableProfileExists
  	
  		The command checks whether the variable profile with named *ProfileName* exists.

  	Parameters:
  	
  		ProfileName - Name of the sought variable profile
  		
  	Returns:
  	
  		If the VariablenID exists in the system, *TRUE* is returned, otherwise *FALSE*.
  		
  	Example:

  		if (IPS_VariableProfileExists("Temperature"))
  		echo "Profile already exists!";
  		
  *)		
  function VariableProfileExists(VarProfileName: String): Boolean; stdcall;
  procedure CheckVariableProfile(VarProfileName: String); stdcall;
  
  (*
  	Function: IPS_GetVariableProfile

  		The command returns an array containing information about the variable profile named *ProfileName*.
  		
  	Parameters:
  	
  		ProfileName - Name of the profile.
  		
  	Returns:
  	
  		The following information are available as key => value pairs:
  		Associations |	array		|	Array with value, name, icon pairs
  		Icon		 |	string 		|	Icon to the specified value
  		IsReadOnly	 |	boolean		|	TRUE if there is a system created profile, which can not be changed
  		MinValue     |  float		|	The minimum value used for the visualization. 
  		MaxValue     |  float		|	The maximum value used for the visualization. 
  		StepSize     |  float		|	Step size for the visualization,0 when the association table is used
  		Digits		 |	integer		|	Number of decimal places
  		Prefix       | 	array		|	Prefix for the value
  		Suffix       | 	integer		|	Suffix for the value
  		ProfileName	 |	string		|	Name of the profile. (~ = System profile)
  		ProfileType  |	integer		|	Type of profile (See: variable type)
  		
  	Example:
  	
  		print_r( IPS_GetVariableProfile("~WindDirection") );

		/* returns e.g.:
		Array
		(
 	 	[Associations] => Array
      	(
      	)

  		[Digits] => 1
  		[Icon] => WindDirection
  		[IsReadOnly] => 1
  		[MaxValue] => 360
  		[MinValue] => 0
  		[Prefix] => 
  		[ProfileName] => ~WindDirection
  		[ProfileType] => 2
  		[StepSize] => 60
  		[Suffix] => °
		)
		*/

  *)		
  function GetVariableProfile(VarProfileName: String): TIPSVarProfile; stdcall;
  function GetVariableProfiles(VarProfileNames: TStringArray): TIPSVarProfiles; stdcall;
  
  (*
  	Function: IPS_GetVariableProfileList
  	
  		The command identifies existing variable profiles in IP-Symcon. The names are listed in an array.
  		
  	Returns:
  		
  		An array of string values ​​for all names of the variables profiles 
  		
  	Example:

  		$Profile = IPS_GetVariableProfileList();
		print_r($Profile);
		/* returns e.g.:
		Array
		(
  		[0] => ~Temperature
  		[1] => ~Humidity
  		[2] => ~AirPressure
    	ect. ...
		*/
	
  *)	
  function GetVariableProfileList(): TStringArray; stdcall;
  
  (*
  	Function: IPS_GetVariableProfileListByType
  	
  		The command identifies existing variable profiles of the type *VariableType* in IP-Symcon. The names are listed in an array.
  	
  	Parameters:
  	
  		VariablenTyp - Value 	|	Desription
  					   	0		|	specifies a variable profile of the type boolean
  					   	1		|	specifies a variable profile of the type integer
  					   	2		|	specifies a variable profile of the type float
  					  	3		|	specifies a variable profile of the type string
  					  	 		
  	Returns:
  	
  		An array of string values ​​for all names of the variables profiles
  		
  	Example:
  	
  		$Profile = IPS_GetVariableProfileListByType(0);
		print_r($Profile);
		/* returns e.g.:
		Array
		(
  		[0] => ~Switch
  		[1] => ~Alert
  		[2] => ~Alert.Reversed
    	ect. ...
		*/ 
		
  *)
  function GetVariableProfileListByType(VarProfileType: TIPSVarType): TStringArray; stdcall;
 end;

 IIPSProfilePoolEx=interface(IIPSPersistence)
  ['{34E9460F-53E1-46C2-8EB9-330DA39F1952}']
  { Variable Profile Pool }
  procedure CreateVariableProfileEx(VarProfile: TIPSVarProfile); stdcall;
 end;

// --- Settings Interface
 IIPSSettings=interface(IIPSMessageSink)
  ['{2058C7E1-D444-4EB1-B67A-FD48DBA7D06F}']
  function GetSnapshot(): String; stdcall;
  function GetSnapshotChanges(LastTimeStamp: Integer): TIPSMessages; stdcall;

  procedure SetOption(Option: String; Value: Integer); stdcall;
  function GetOption(Option: String): Integer; stdcall;

  (*

    Legacy functions. Remove somewhere in 3.x

  *)

  { Returns an Array of Items in Section }
  function GetInstanceItems(InstanceID: TInstanceID; Section: Array of String; var Values: TStringArray; var Count: Integer): HRESULT; 
  { Read/Write Instance Data, like Instance specific Settings }
  function WriteInstanceBoolean(InstanceID: TInstanceID; Section: Array of String; Name: String; Value: Boolean): HRESULT; 
  function WriteInstanceInteger(InstanceID: TInstanceID; Section: Array of String; Name: String; Value: Integer): HRESULT;
  function WriteInstanceFloat(InstanceID: TInstanceID; Section: Array of String; Name: String; Value: Double): HRESULT; 
  function WriteInstanceString(InstanceID: TInstanceID; Section: Array of String; Name: String; Value: String): HRESULT; 
  function ReadInstanceBoolean(InstanceID: TInstanceID; Section: Array of String; Name: String; var Value: Boolean): HRESULT;
  function ReadInstanceInteger(InstanceID: TInstanceID; Section: Array of String; Name: String; var Value: Integer): HRESULT; 
  function ReadInstanceFloat(InstanceID: TInstanceID; Section: Array of String; Name: String; var Value: Double): HRESULT; 
  function ReadInstanceString(InstanceID: TInstanceID; Section: Array of String; Name: String; var Value: String): HRESULT; 
  { Delete Instance Item }
  function DeleteInstanceItem(InstanceID: TInstanceID; Section: Array of String): HRESULT; 
 end;

 IIPSSettingsEx = interface(IIPSPersistence)
  ['{BBC6FF8F-7C80-46A8-8A6E-60B76434AB2B}']
  function GetSnapshotEx(): ISuperObject; stdcall;

  function CreateOption(Option: String; DefaultValue: Integer): Integer; stdcall;
  
  procedure LoadSettings(); stdcall;
  procedure SaveSettings(); stdcall;
 end;

// --- DebugServer Interface
 IIPSDebugServer = interface(IIPSMessageSink)
 ['{CA3F512F-B1FB-4D2E-94D8-47C4139555B7}']
  procedure EnableDebug(ID: TIPSID; Duration: Integer); stdcall;
  procedure DisableDebug(ID: TIPSID); stdcall;
 end;

 IIPSDebugServerEx = interface(IIPSMessageSink)
 ['{C1111BBF-A5D3-4A5B-B9DB-4E447C508766}']
  procedure SendData(SenderID: TIPSID; Message, Data: String);
 end;

// --- SOAPServer Interface
 IIPSSOAPServer = interface(IIPSMessageSink)
 ['{2FA0A102-A67D-4F7C-BA16-4E5ACC7EF71C}']
  { Get new SessionID to use }
  function IsSessionValid(SessionID: String): Boolean; stdcall;
  function StartSession(FilterType: TIPSFilterType): String; stdcall;
  {$IFDEF DEBUG}
  function EndSession(SessionID: String): String; stdcall;
  {$ENDIF DEBUG}
  procedure AddSessionFilter(SessionID: String; SenderID, Message: Integer); stdcall;
  procedure RemoveSessionFilter(SessionID: String; SenderID, Message: Integer); stdcall;
  procedure ClearSessionFilter(SessionID: String); stdcall;
  function GetSessionFilter(SessionID: String): TIPSMessageFilters; stdcall;
  function GetSessionMessages(SessionID: String): TIPSMessages; stdcall;
 end;

//------------------------------------------------------------------------------
// Basic Implementations
//------------------------------------------------------------------------------
// --- Helper Class
 TStrListHelper = class helper for TStrings
 public
  procedure FreeObjects;
  function toArray: TStringArray;
 end;

// --- Helper Class
 TThreadListHelper = class helper for TThreadList
 public
  procedure FreeObjects;
 end;

// --- MessageSink Class
 TIPSMessageObject=class(TInterfacedObject, IIPSMessageSink)
  protected
   fKernel: IIPSKernel;
   fKernelRunlevel: Integer;
   procedure ProcessKernelRunlevelChange(Runlevel: Integer); virtual;
   //Helper
   procedure LogModuleMessage(Str: String; KMsg: Integer = KL_MESSAGE; KID: TIPSID = 0);
   function GetLocation(ID: TIPSID): String;
   function GetName(ID: TIPSID): String;
  public
   constructor Create(Kernel: IIPSKernel); virtual;
   procedure MessageSink(var Msg: TIPSMessage); virtual;
   { Should return 1. Only the Kernel should hold a reference }
   function ReferenceCount(): Integer;
 end;

 TIPSCallableObject=class(TIPSMessageObject)
  public
   class function FilterFunctions(): TStringArray; virtual;
 end;

// --- Module Class
 TBoolSetter = procedure(Value: Boolean) of Object; stdcall;
 TBoolGetter = function: Boolean of Object; stdcall;

 TIntSetter = procedure(Value: Integer) of Object; stdcall;
 TIntGetter = function: Integer of Object; stdcall;

 TFloatSetter = procedure(Value: Double) of Object; stdcall;
 TFloatGetter = function: Double of Object; stdcall;

 TStrSetter = procedure(Value: String) of Object; stdcall;
 TStrGetter = function: String of Object; stdcall;

 TPropertyHolder = class
  public
   PropertyType: TIPSVarType;
   Getter: TMethod;
   Setter: TMethod;
 end;

 TIPSActionRequestHandler = procedure(VariableIdent: String; Value: Variant) of object;
  
 //Exception
 EIPSModuleObject = class(Exception);

 //Class
 TIPSModuleObject = class(TIPSCallableObject, IIPSModule, IIPSPersistence)
  private
   { Properties }
   fProperties        : TStringList;  //Kill this for 3.0, DEPRECATED
   fConfiguration     : ISuperObject; //Holds the current configuration that modules use
   fConfigurationFlux : ISuperObject; //Maintaines intermediate changes before final ApplyChanges is called
   fVariableActions   : THashedStringList;
   { Timers }
   fTimers            : THashedStringList;
   { Settings }
   fHasChanges        : Boolean;
   fIsSearching       : Boolean;
   fSupportsSearching : Boolean;
   procedure SendSettingsChangedMessage;
   procedure RegisterPropertyDeprecated(PropertyName: String; PType: TIPSVarType; Getter: TMethod; Setter: TMethod);
  protected
   fKernel          : IIPSKernel;
   fInstanceID      : TInstanceID;
   fLock            : TMultiReadExclusiveWriteSynchronizer;
   { Is Remote Call }
   function IsRemoteCall: Boolean;
   { Easy LogMessages }
   procedure LogMessage(LType: Integer; LMessage: String);
   procedure SendData(Message, Data: String);
   procedure SetStatus(Status: Integer);
   procedure SetSummary(Summary: String);
   { PHP Function Handling }
   procedure RegisterFunctions();
   { Configuration Handling }
   // *** DEPRECATED
   procedure RegisterBoolProperty(PropertyName: String; Getter: TBoolGetter; Setter: TBoolSetter);
   procedure RegisterIntProperty(PropertyName: String; Getter: TIntGetter; Setter: TIntSetter);
   procedure RegisterFloatProperty(PropertyName: String; Getter: TFloatGetter; Setter: TFloatSetter);
   procedure RegisterStrProperty(PropertyName: String; Getter: TStrGetter; Setter: TStrSetter);
   { *** ADDED Version 2.6 }
   procedure RegisterProperty(PropertyName: String; PropertyDefaultValue: Variant);
   { Status Variable Handling }
   procedure RegisterVariable(VarIdent: String; VarName: String; VarType: TIPSVarType; VarProfile: String = ''; VarAction: TIPSActionRequestHandler = nil; VarPosition: Integer = 0);
   procedure UnregisterVariable(VarIdent: String);
   procedure MaintainVariable(Keep: Boolean; VarIdent: String; VarName: String; VarType: TIPSVarType; VarProfile: String = ''; VarAction: TIPSActionRequestHandler = nil; VarPosition: Integer = 0);
   function GetStatusVariableID(VariableIdent: String): TVariableID; stdcall;
   { Timers }
   procedure RegisterTimer(Name: String; Interval: Double; OnEvent: TTimerEvent);
   procedure SetTimerInterval(Name: String; Interval: Double);
   procedure ResetTimer(Name: String);
   { Status Variable Profiles }
   procedure RegisterProfile(VarProfile: TIPSVarProfile);
   { Searching Support }
   procedure EnableSearchSupport;
   procedure DisableSearchSupport;
   procedure SendSearchUpdate(DeviceText: String; PropertiesAndValues: Array of Const);
   procedure SendSearchProgress(Status: String);
   procedure SendSearchComplete;
   function MatchSearchProperties(PropertiesAndValues: Array of Const): TInstanceID; virtual;
   { Device Data Handling }
   function RequireParent(ModuleID: TGUID; ForceCreate: Boolean = False): Boolean;
   function ForceParent(ModuleID: TGUID): Boolean;
   function ForceParentConfiguration(IID: TGUID; Configuration: Array of Const): Boolean;
   function GetParent(): IIPSModule;
   function GetChildren(): TInterfaceList;
   function HasActiveParent(): Boolean;
   { PHP Event Handling }
   procedure HandlePHPEvent(FunctionName    : String;
                            Parameters      : TIPSPHPParameters;
                            var ReturnValue : TIPSPHPParameter); virtual;
   { Settings Handling }
   procedure SettingsChanged;

   { MessageSink Forwardings }
   procedure ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer); virtual;

   { Properties }
   //property Configuration : ISuperObject read fConfiguration;
   //property ConfigurationFlux : ISuperObject read fConfigurationFlux;
  public
   constructor Create(Kernel: IIPSKernel; InstanceID: TInstanceID); reintroduce; virtual;
   destructor Destroy; override;
   { Message Sink }
   procedure MessageSink(var Msg: TIPSMessage); override;
   { Status Variables }
   procedure RequestAction(VariableIdent: String; Value: Variant); virtual; stdcall;
   { Searching }
   function SupportsSearching: Boolean; stdcall;
   function IsSearching: Boolean; stdcall;
   procedure StartSearch; virtual; stdcall;
   procedure StopSearch; virtual; stdcall;
   { Configuration }
   procedure SetProperty(PropertyName: String; PropertyValue: Variant); virtual; stdcall;
   function GetProperty(PropertyName: String): Variant; virtual; stdcall;
   procedure SetConfiguration(Configuration: String); stdcall;
   function GetConfiguration(): String; stdcall;
   { Configuration Form }
   function GetConfigurationForm(): String; virtual; stdcall;
   { Persistence }
   procedure LoadFromData(ID: TIPSID; Data: ISuperObject);
   { Save/Load Settings }
   procedure LoadSettings(); virtual; stdcall;
   procedure SaveSettings(); virtual; stdcall;
   { Process changes }
   
   (*
   	Function: IPS_HasChanges
   	
   		The command checks whether any changes were made ​​to the configuration, that must be adopted as the current actual configuration.
   			
   	Parameters:
   	
   		InstanceID - ID of the instance to be tested
   		
   	Returns:
   	
   		*TRUE* if there are changes, otherwise *FALSE*.
   		
   	Example:
   	
   		if(IPS_HasChanges(12345))
		{
			IPS_ApplyChanges(12345);
		}


   *)
   function HasChanges(): Boolean; stdcall;
  
   (*
   	Function: IPS_ResetChanges
   	
   		The command overwrites the new target configuration by the current actual configuration.
   		
   	Parameters:
   	
		InstanceID - ID of the instance to be tested
		
	Returns:
	
		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
		
	Example:
	
		if(IPS_HasChanges(12345))
		{
			IPS_ResetChanges(12345);
		}
		
   *)
   procedure ResetChanges(); virtual; stdcall;
   
   (*
   	Function: IPS_ApplyChanges
   	
   		The command takes on the new target configuration as as the current actual configuration and reinitialize if necessary appropriate module components. (e.g. a socket module, the network connection is dropped and rebuilt)
   		
   	Parameters:
   	
   		InstanceID - ID of the instance
   		
   	Returns:
   	
   		If the command succeeds, it returns *TRUE*, otherwise *FALSE*.
   		
   	Example:
   	
   		if(IPS_HasChanges(12345))
		{
			IPS_ApplyChanges(12345);
		}
		
   *)	
   procedure ApplyChanges(); virtual; stdcall;
   { InstanceID }
   function GetInstanceID(): TInstanceID; stdcall;
   { Data Handling }
   procedure ReceiveData(Data: String); virtual; stdcall;
   procedure ForwardData(Data: String); virtual; stdcall;

   // --- IIPSCallable Implementation
   class function FilterFunctions(): TStringArray; override;

   { Class Functions }
   class function GetModuleID(): TStrGUID; virtual; abstract;
   class function GetModuleType(): TIPSModuleType; virtual; abstract;
   class function GetModuleName(): String; virtual; abstract;
   class function GetParentRequirements(): TStrGUIDs; virtual;
   class function GetChildRequirements(): TStrGUIDs; virtual;
   class function GetImplemented(): TStrGUIDs; virtual;
   class function GetVendor(): String; virtual;
   class function GetAliases(): TStringArray; virtual;
 end;

//------------------------------------------------------------------------------
// Helper Functions
//------------------------------------------------------------------------------
 procedure DisableContext;
 procedure EnableContext;

 function VarRecToVariant(varRec: TVarRec): Variant;
 
 function StringToVarType(VarType: String): TIPSVarType;
 function VarTypeToString(VarType: TIPSVarType): String;
 function StringToEventType(EventType: String): TIPSEventType;
 function EventTypeToString(EventType: TIPSEventType): String;
 function StringToTriggerType(TriggerType: String): TIPSTriggerType;
 function TriggerTypeToString(TriggerType: TIPSTriggerType): String; 
 function StringToCyclicDateType(CyclicDateType: String): TIPSCyclicDateType;
 function CyclicDateTypeToString(CyclicDateType: TIPSCyclicDateType): String;
 function StringToCyclicTimeType(CyclicTimeType: String): TIPSCyclicTimeType;
 function CyclicTimeTypeToString(CyclicTimeType: TIPSCyclicTimeType): String;
 function StringToObjectType(ObjectType: String): TIPSObjectType;
 function ObjectTypeToString(ObjectType: TIPSObjectType): String;
 function StringToMediaType(MediaType: String): TIPSMediaType;
 function MediaTypeToString(MediaType: TIPSMediaType): String;
 function NamedVarType(VName: String; VType: TIPSVarType): TIPSPHPParameterInfo;
 function NamedVarTypes(VInfos: Array of TIPSPHPParameterInfo): TIPSPHPParameterInfos;
 function ValueAssociation(Value: Double; Name, Icon: String; Color: Integer): TIPSValueAssociation;
 function ValueAssociations(VInfos: Array of TIPSValueAssociation): TIPSValueAssociations;
 function MakeColor(R, G, B: Byte): Integer;
 function KernelConstToString(Message: Integer): String;
 
 type
  TDefaultProfiles = (dpTemperature, dpHumidity, dpAirPressure, dpIlluminance,
                      dpSwitch, dpIntensity1, dpIntensity100, dpIntensity255,
                      dpAlarm, dpAlarmReversed, dpWindow, dpWindowReversed, dpBattery, dpBatteryReversed,
                      dpBattery100, dpWindSpeedKmh, dpWindSpeedMs, dpWindDirection, dpUVIndex,
                      dpRainfall, dpRaining, dpValve, dpShutter, dpVolt230, dpAmpere16, dpWatt3680,
                      dpElectricity, dpWater, dpGas
);

implementation

//------------------------------------------------------------------------------
procedure DisableContext;
begin
 DataContextDisabled := True;
end;

//------------------------------------------------------------------------------
procedure EnableContext;
begin
 DataContextDisabled := False;
end;

//------------------------------------------------------------------------------
function NamedVarType(VName: String; VType: TIPSVarType): TIPSPHPParameterInfo;
begin

 DisableContext;
 try
  Result := TIPSPHPParameterInfo.Create;
 finally
  EnableContext;
 end;
 Result.Description := VName;
 Result.Type_ := VType;

end;

//------------------------------------------------------------------------------
function NamedVarTypes(VInfos: Array of TIPSPHPParameterInfo): TIPSPHPParameterInfos;
var i: Integer;
begin

 SetLength(Result, High(VInfos)+1);
 for i := Low(VInfos) to High(VInfos) do
  Result[i] := VInfos[i];

end;

//------------------------------------------------------------------------------
function ValueAssociation(Value: Double; Name, Icon: String; Color: Integer): TIPSValueAssociation;
begin

 DisableContext;
 try
  Result := TIPSValueAssociation.Create;
 finally
  EnableContext;
 end;
 Result.Value := Value;
 Result.Name := Name;
 Result.Icon := Icon;
 Result.Color := Color;

end;

//------------------------------------------------------------------------------
function ValueAssociations(VInfos: Array of TIPSValueAssociation): TIPSValueAssociations;
var i: Integer;
begin

 SetLength(Result, High(VInfos)+1);
 for i := Low(VInfos) to High(VInfos) do
  Result[i] := VInfos[i];
  
end;

//------------------------------------------------------------------------------
function MakeColor(R, G, B: Byte): Integer;
begin

 Result := B + (G shl 8) + (R shl 16);

end;

//Implements HelperClass
//------------------------------------------------------------------------------
procedure TStrListHelper.FreeObjects;
var i: Integer;
begin

 if Self.Count > 0 then
  for i:=0 to Self.Count-1 do
   Self.Objects[i].Free;

end;

//------------------------------------------------------------------------------
function TStrListHelper.toArray: TStringArray;
var i: Integer;
begin

  SetLength(Result, Count);
  if Count > 0 then
   for i:=0 to Count-1 do
    Result[i] := Self[i];

end;

//------------------------------------------------------------------------------
procedure TThreadListHelper.FreeObjects;
var i: Integer;
    L: TList;
begin

 L := Self.LockList;
 try
  if L.Count > 0 then
   for i:=0 to L.Count-1 do
    TObject(L[i]).Free;

 finally
  Self.UnlockList;
 end;

end;

//------------------------------------------------------------------------------
constructor TIPSRemotable.Create;
begin
 if not DataContextDisabled then
  inherited;
end;

//------------------------------------------------------------------------------
constructor TIPSMessage.Create(SenderID: TIPSID; Message: Integer; Data: Array of Const);
var i: Integer;
begin

 FTimeStamp := 0;
 FSenderID := SenderID;
 FMessage := Message;
 FData := VarArrayCreate([0, High(Data)], varVariant);

 for i := Low(Data) to High(Data) do
  FData[i] := VarRecToVariant(Data[i]);

 inherited Create();

end;

//------------------------------------------------------------------------------
constructor TIPSMessage.Create(Msg: TIPSMessage);
begin

 FTimeStamp := Msg.TimeStamp;
 FSenderID := Msg.SenderID;
 FMessage := Msg.FMessage;
 FData := Msg.FData;

 inherited Create();

end;

//------------------------------------------------------------------------------
constructor TIPSMessageFilter.Create(SenderID, Message: Integer);
begin

 FSenderID := SenderID;
 FMessage := Message;

 inherited Create();

end;

//Implements IPSInstance
//------------------------------------------------------------------------------
constructor TIPSInstance.Create;
begin
 FModuleInfo := TIPSBasicModuleInformation.Create;
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSInstance.Destroy;
begin
 if Self.DataContext = nil then
  FreeAndNil(FModuleInfo);
 inherited;
end;

//------------------------------------------------------------------------------
function TIPSTimer.GetLastRun: TUnixTime;
begin
 Result := FLastRun div 1000;
end;

//------------------------------------------------------------------------------
function TIPSTimer.GetNextRun: TUnixTime;
begin
 Result := FNextRun div 1000;
end;

//Implements IPSVarValue
//------------------------------------------------------------------------------
constructor TIPSVarValue.Create;
begin
 FValueIndex := TIPSVarIndex.Create;
 SetLength(FValueArray, 0);
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSVarValue.Destroy;
var i: Integer;
begin
 if Self.DataContext = nil then
  begin
   FValueIndex.Free;
   for i:=Low(FValueArray) to High(FValueArray) do
    FValueArray[i].Free;
  end;
 inherited;
end;

//------------------------------------------------------------------------------
function TIPSVarValue.PrepareAndCheckArrayEx(IndexType: TIPSVarIndexType; Name: String; Index: Integer): Integer;

 function GetNextIndex(): Integer;
 var i: Integer;
 begin

  Result := 0;
  if Length(FValueArray) = 1 then
   exit;

  for i:=0 to Length(FValueArray)-1 do //Do not check last item
   Result := Max(Result, FValueArray[i].ValueIndex.IndexInt);
  Inc(Result);

 end;

begin

 if FValueType <> vtArray then
  raise Exception.Create(_('Variable is not from Array Type'));

 //Create Array if not already there
 if High(FValueArray) <> -1 then
  begin
   //Check Arraytype
   if FValueArray[0].ValueIndex.IndexType <> IndexType then
    raise Exception.Create(_('Cannot add Named Value in Indexed Array'));
  end;

 //Add Slot
 Result := Length(FValueArray);
 SetLength( FValueArray, Result+1 );
 FValueArray[Result] := TIPSVarValue.Create;
 FValueArray[Result].ValueIndex.IndexType := IndexType;

 case IndexType of
   itInt: if Index = -1 then
           FValueArray[Result].ValueIndex.IndexInt := GetNextIndex()
          else
           FValueArray[Result].ValueIndex.IndexInt := Index;
   itStr: FValueArray[Result].ValueIndex.IndexStr := Name;
 end;

end;

//------------------------------------------------------------------------------
function TIPSVarValue.PrepareAndCheckArrayStr(Name: String = ''): Integer;
begin
 Result := PrepareAndCheckArrayEx(itStr, Name, 0);
end;

//------------------------------------------------------------------------------
function TIPSVarValue.PrepareAndCheckArrayInt(Index: Integer = -1): Integer;
begin
 Result := PrepareAndCheckArrayEx(itInt, '', Index);
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddIndexedBool(Value: Boolean; Index: Integer = -1);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt( Index);
 //Add Value
 FValueArray[Pos].ValueType := vtBoolean;
 FValueArray[Pos].ValueBoolean := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddIndexedInt(Value: Integer; Index: Integer = -1);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt( Index);
 //Add Value
 FValueArray[Pos].ValueType := vtInteger;
 FValueArray[Pos].ValueInteger := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddIndexedFloat(Value: Double; Index: Integer = -1);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt(Index);
 //Add Value
 FValueArray[Pos].ValueType := vtFloat;
 FValueArray[Pos].ValueFloat := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddIndexedStr(Value: String; Index: Integer = -1);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt( Index);
 //Add Value
 FValueArray[Pos].ValueType := vtString;
 FValueArray[Pos].ValueString := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddIndexedVariant(Value: Variant; Index: Integer = -1);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt( Index);
 //Add Value
 FValueArray[Pos].ValueType := vtVariant;
 FValueArray[Pos].ValueVariant := Value;
end;

//------------------------------------------------------------------------------
function TIPSVarValue.AddIndexedArray(Index: Integer = -1): TIPSVarValue;
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayInt(Index);
 //Add Value
 FValueArray[Pos].ValueType := vtArray;
 FValueArray[Pos].ValueArray := NIL;
 Result := FValueArray[Pos];
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddNamedBool(Name: String; Value: Boolean);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtBoolean;
 FValueArray[Pos].ValueBoolean := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddNamedInt(Name: String; Value: Integer);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtInteger;
 FValueArray[Pos].ValueInteger := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddNamedFloat(Name: String; Value: Double);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtFloat;
 FValueArray[Pos].ValueFloat := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddNamedStr(Name: String; Value: String);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtString;
 FValueArray[Pos].ValueString := Value;
end;

//------------------------------------------------------------------------------
procedure TIPSVarValue.AddNamedVariant(Name: String; Value: Variant);
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtVariant;
 FValueArray[Pos].ValueVariant := Value;
end;

//------------------------------------------------------------------------------
function TIPSVarValue.AddNamedArray(Name: String): TIPSVarValue;
var Pos: Integer;
begin
 Pos := PrepareAndCheckArrayStr(Name);
 //Add Value
 FValueArray[Pos].ValueType := vtArray;
 FValueArray[Pos].ValueArray := NIL;
 Result := FValueArray[Pos];
end;

//Implements TIPSVarProfile
//------------------------------------------------------------------------------
destructor TIPSVarProfile.Destroy;
var i: Integer;
begin

 if Self.DataContext = nil then
  begin
   for i := 0 to High(FAssociations) do
    FAssociations[i].Free;
  end;

 inherited; 

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateStringProfile(Name, Icon, Prefix, Suffix: String);
begin

 FProfileType := vtString;
 FIcon := Icon;
 FProfileName := Name;
 FPrefix := Prefix;
 FSuffix := Suffix;

 inherited Create;

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateBooleanProfile(Name, Icon, TrueName, TrueIcon:String; TrueColor: Integer; FalseName, FalseIcon: String; FalseColor: Integer);
begin

 FMinValue := 0;
 FMaxValue := 1;

 CreateStringProfile(Name, Icon, '', '');

 SetLength(FAssociations, 2);
 FAssociations[0] := ValueAssociation(0, FalseName, FalseIcon, FalseColor);
 FAssociations[1] := ValueAssociation(1, TrueName, TrueIcon, TrueColor);

 FProfileType := vtBoolean;

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateIntegerProfile(Name, Icon, Prefix, Suffix: String; MinValue, MaxValue, StepSize: Integer);
begin

 FMinValue := MinValue;
 FMaxValue := MaxValue;
 FStepSize := StepSize;

 CreateStringProfile(Name, Icon, Prefix, Suffix);

 FProfileType := vtInteger;

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateIntegerProfileEx(Name, Icon, Prefix, Suffix: String; Associations: TIPSValueAssociations);
begin

 FDigits := 0;
 FAssociations := Associations;

 CreateIntegerProfile(Name, Icon, Prefix, Suffix, Round(Associations[0].Value), Round(Associations[High(Associations)].Value), 0);

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateFloatProfile(Name, Icon, Prefix, Suffix: String; MinValue, MaxValue, StepSize: Double; Digits: Integer);
begin

 FDigits := Digits;
 FMinValue := MinValue;
 FMaxValue := MaxValue;
 FStepSize := StepSize;

 CreateStringProfile(Name, Icon, Prefix, Suffix);

 FProfileType := vtFloat;

end;

//------------------------------------------------------------------------------
constructor TIPSVarProfile.CreateFloatProfileEx(Name, Icon, Prefix, Suffix: String; Digits: Integer; Associations: TIPSValueAssociations);
begin

 FAssociations := Associations;

 CreateFloatProfile(Name, Icon, Prefix, Suffix, Associations[0].Value, Associations[High(Associations)].Value, 0, Digits);

end;

//Implements TIPSVariable
//------------------------------------------------------------------------------
constructor TIPSVariable.Create;
begin
 FVariableValue := TIPSVarValue.Create;
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSVariable.Destroy;
begin
 if Self.DataContext = nil then
  begin
   FVariableValue.Free;
  end;
 inherited;
end;

//Implements TIPSEvent
//------------------------------------------------------------------------------
constructor TIPSEvent.Create;
begin
 FCyclicDateFrom := TIPSEventDate.Create;
 FCyclicDateTo := TIPSEventDate.Create;
 FCyclicTimeFrom := TIPSEventTime.Create;
 FCyclicTimeTo := TIPSEventTime.Create;
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSEvent.Destroy;
begin
 if Self.DataContext = nil then
  begin
   FCyclicDateFrom.Free;
   FCyclicDateTo.Free;
   FCyclicTimeFrom.Free;
   FCyclicTimeTo.Free;
  end;
 inherited;
end;

//Implements TIPSPHPFunction
//------------------------------------------------------------------------------
constructor TIPSPHPFunction.Create;
begin
 FResult := TIPSPHPParameterInfo.Create;
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSPHPFunction.Destroy;
var i: Integer;
begin
 if Self.DataContext = nil then
  begin
   FResult.Free;
   for i:=Low(FParameters) to High(FParameters) do
    FParameters[i].Free;
   for i:=Low(FPHPInstances) to High(FPHPInstances) do
    FPHPInstances[i].Free;
  end;
 inherited;
end;

//------------------------------------------------------------------------------
function TIPSPHPFunction.GetParameters : TIPSPHPParameterInfos;
begin
 Result := FParameters;
end;

//------------------------------------------------------------------------------
procedure TIPSPHPFunction.SetParameters(Value: TIPSPHPParameterInfos);
begin
 FParameters := Value;
end;

//------------------------------------------------------------------------------
function TIPSPHPFunction.GetInstances: TIPSPHPInstances;
begin
 Result := FPHPInstances;
end;

//------------------------------------------------------------------------------
procedure TIPSPHPFunction.SetInstances(Value: TIPSPHPInstances);
begin
 FPHPInstances := Value;
end;

//Implements TIPSPHPVariable
//------------------------------------------------------------------------------
constructor TIPSPHPVariable.Create;
begin
 FVariableType := pvtIPS;
 FVariableValue := TIPSVarValue.Create;
 inherited;
end;

//------------------------------------------------------------------------------
constructor TIPSPHPVariable.CreateNamed(Name: String);
begin
 FVariableName := Name;
 Create;
end;

//------------------------------------------------------------------------------
constructor TIPSPHPVariable.CreateBool(Name: String; Value: Boolean);
begin
 CreateNamed(Name);
 FVariableValue.ValueType := vtBoolean;
 FVariableValue.ValueBoolean := Value;
end;

//------------------------------------------------------------------------------
constructor TIPSPHPVariable.CreateInt(Name: String; Value: Integer);
begin
 CreateNamed(Name);
 FVariableValue.ValueType := vtInteger;
 FVariableValue.ValueInteger := Value;
end;

//------------------------------------------------------------------------------
constructor TIPSPHPVariable.CreateFloat(Name: String; Value: Double);
begin
 CreateNamed(Name);
 FVariableValue.ValueType := vtFloat;
 FVariableValue.ValueFloat := Value;
end;

//------------------------------------------------------------------------------
constructor TIPSPHPVariable.CreateStr(Name: String; Value: String);
begin
 CreateNamed(Name);
 FVariableValue.ValueType := vtString;
 FVariableValue.ValueString:= Value;
end;


//------------------------------------------------------------------------------
destructor TIPSPHPVariable.Destroy;
begin
 if Self.DataContext = nil then
  FVariableValue.Free;
 inherited;
end;

//Implements TIPSExecuteInfo
//------------------------------------------------------------------------------
constructor TIPSExecuteInfo.Create;
begin
 FRequestMethod := rmGET;
 FQueryString := '';
 SetLength(FServerVariables, 0);
 FCookies := '';
 FScriptResult := '';
 SetLength(FScriptHeaders, 0);
 FOnNewContent := nil;
 FData := nil;
 FPostData := TMemoryStream.Create;
 FContentType := '';
 FContentLength := 0;
 inherited;
end;

//------------------------------------------------------------------------------
destructor TIPSExecuteInfo.Destroy;
var i: Integer;
begin
 if Self.DataContext = nil then
  begin
   for i:=Low(FServerVariables) to High(FServerVariables) do
    FServerVariables[i].Free;
   SetLength(FServerVariables, 0);
   SetLength(FScriptHeaders, 0);
   FPostData.Free;
  end;
 inherited;
end;

//Implements MessageObject
//------------------------------------------------------------------------------
constructor TIPSMessageObject.Create(Kernel: IIPSKernel); 
begin

 fKernel := Kernel;
 fKernelRunlevel := Kernel.GetKernelRunlevel;

end;

//------------------------------------------------------------------------------
procedure TIPSMessageObject.MessageSink(var Msg: TIPSMessage);
begin

 case Msg.Message of
  IPS_KERNELMESSAGE:
   begin
    fKernelRunlevel := Msg.Data[0];
    ProcessKernelRunlevelChange(fKernelRunlevel);
   end;
 end;

end;

//------------------------------------------------------------------------------
function TIPSMessageObject.ReferenceCount(): Integer;
begin
 Result := FRefCount;
end;

//------------------------------------------------------------------------------
procedure TIPSMessageObject.LogModuleMessage(Str: String; KMsg: Integer = KL_MESSAGE; KID: TIPSID = 0);
begin

 fKernel.LogMessage(KMsg, KID, MidStr(ClassName, 5, Length(ClassName)), Str);

end;

//------------------------------------------------------------------------------
function TIPSMessageObject.GetLocation(ID: TIPSID): String;
begin
 Result := fKernel.ObjectManager.GetLocation(ID);
end;

//------------------------------------------------------------------------------
function TIPSMessageObject.GetName(ID: TIPSID): String;
begin
 Result := fKernel.ObjectManager.GetName(ID);
end;

//------------------------------------------------------------------------------
procedure TIPSMessageObject.ProcessKernelRunlevelChange(Runlevel: Integer);
begin
 //Nothing to do
end;

//Implements CallableObject
//------------------------------------------------------------------------------
class function TIPSCallableObject.FilterFunctions(): TStringArray;
begin
 SetLength(Result, 0);
end;

//Implements ModuleObject
//------------------------------------------------------------------------------
class function TIPSModuleObject.FilterFunctions(): TStringArray;
begin

 SetLength(Result, 3);
 Result[0] := 'LoadSettings';
 Result[1] := 'SaveSettings';
 Result[2] := 'GetInstanceID';

end;

//------------------------------------------------------------------------------
constructor TIPSModuleObject.Create(Kernel: IIPSKernel; InstanceID: TInstanceID);
begin

 fKernel := Kernel;
 fInstanceID := InstanceID;
 fLock := TMultiReadExclusiveWriteSynchronizer.Create;
 fSupportsSearching := False;
 
 inherited Create(Kernel);

 LogMessage(KL_MESSAGE, _('Creating...'));

 fConfiguration := SO();
 fConfigurationFlux := SO();
 fProperties      := TStringList.Create;
 fVariableActions := THashedStringList.Create;
 fTimers          := THashedStringList.Create; 

 RegisterFunctions();

 if GetModuleType = mtIO then 
  SetStatus(IS_INACTIVE);

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.IsRemoteCall: Boolean;
begin

 Result := (not DataContextDisabled) and fKernel.IsRemoteCall();

end;

//------------------------------------------------------------------------------
destructor TIPSModuleObject.Destroy;
var i: Integer;
begin

 fKernel.ScriptEngineEx.UnregisterFunctions(fInstanceID);

 //Free ActionList
 fVariableActions.Free;

 //Free Properties
 fProperties.FreeObjects;
 fProperties.Free;

 //Free Configurations
 fConfiguration := nil;
 fConfigurationFlux := nil;

 //Free Timers
 for i := 0 to fTimers.Count -1 do
  fKernel.TimerPoolEx.UnregisterTimer(Integer(fTimers.Objects[i]));  
 fTimers.Free;

 //Free Locks
 fLock.Free;

 LogMessage(KL_MESSAGE, _('Deleting...'));

 //Cleanup Interface links
 fKernel := NIL;

 inherited;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.MessageSink(var Msg: TIPSMessage);
begin

 inherited;

 case Msg.Message of
  IM_CHANGESTATUS:
   ProcessInstanceStatusChange(Msg.SenderID, Msg.Data[0]);
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.LogMessage(LType: Integer; LMessage: String);
begin

 fKernel.LogMessage(LType,
                    fInstanceID,
                    Self.GetModuleName(),
                    LMessage);
                    
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SendData(Message, Data: String);
begin

 fKernel.DebugServerEx.SendData(fInstanceID, Message, Data);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SetStatus(Status: Integer);
begin

 fKernel.InstanceManagerEx.SetInstanceStatus(fInstanceID, Status);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SetSummary(Summary: String);
begin

 fKernel.ObjectManager.SetSummary(fInstanceID, Summary);

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetStatusVariableID(VariableIdent: String): TVariableID;
begin

 Result := fKernel.ObjectManager.GetObjectIDByIdent(VariableIdent, fInstanceID);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RequestAction(VariableIdent: String; Value: Variant);
var VarIndex: Integer;
    F: TIPSActionRequestHandler;
begin

 fLock.BeginRead;
 try
  VarIndex := fVariableActions.IndexOf(VariableIdent);

  if VarIndex = -1 then
   raise EIPSModuleObject.Create(Format(_('No action for Ident "%s" definied'), [VariableIdent]));

  TMethod(F).Data := Self;
  TMethod(F).Code := Pointer(fVariableActions.Objects[VarIndex]);
  F(VariableIdent, Value);
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.EnableSearchSupport;
begin

 fLock.BeginWrite;
 try
  fSupportsSearching := True;
 finally
  fLock.EndWrite;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.DisableSearchSupport;
begin

 fLock.BeginWrite;
 try
  fSupportsSearching := False;
 finally
  fLock.EndWrite;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SendSearchUpdate(DeviceText: String; PropertiesAndValues: Array of Const);
type TConstArray = array of TVarRec;
var i: Integer;
    SearchUpdate: TConstArray;
begin

 SetLength(SearchUpdate, Length(PropertiesAndValues)+ 2);

 SearchUpdate[0].VType := System.vtAnsiString;
 SearchUpdate[0].VAnsiString := nil;
 AnsiString(SearchUpdate[0].VAnsiString) := AnsiString(DeviceText);

 SearchUpdate[1].VType := System.vtInteger;
 SearchUpdate[1].VInteger := MatchSearchProperties(PropertiesAndValues);

 for i := Low(PropertiesAndValues) to High(PropertiesAndValues) do
   SearchUpdate[i+2] := PropertiesAndValues[i];

 fKernel.PostMessage(fInstanceID, IM_SEARCHUPDATE, SearchUpdate);

 //free memory
 AnsiString(SearchUpdate[0].VAnsiString) := '';

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SendSearchProgress(Status: String);
begin

 fKernel.PostMessage(fInstanceID, IM_SEARCHPROGRESS, [Status]);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SendSearchComplete;
begin

 fKernel.PostMessage(fInstanceID, IM_SEARCHCOMPLETE, []);

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.MatchSearchProperties(PropertiesAndValues: Array of Const): TInstanceID;
var InstanceIDs: TInstanceIDs;
    Instance: TIPSInstance;
    Matched: Boolean;
    i, j: Integer;
begin

 Result := 0;
 InstanceIDs := fKernel.InstanceManager.GetInstanceListByModuleID(GetModuleID());
 for i := 0 to Length(InstanceIDs) -1 do
  begin
   Instance := fKernel.InstanceManager.GetInstance(InstanceIDs[i]);
   Matched := True;
   try
    try
     for j := 0 to (Length(PropertiesAndValues) div 2) - 1 do
      begin
       Matched := Instance.InstanceInterface.GetProperty(VarRecToVariant(PropertiesAndValues[j*2])) = VarRecToVariant(PropertiesAndValues[j*2+1]);
       if not Matched then
        break;
      end;
    except
     Matched := False;
    end;
    if Matched then
     begin
      Result := Instance.InstanceID;
      exit;
     end;
   finally
    Instance.Free;
   end;
  end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.SupportsSearching: Boolean;
begin

 fLock.BeginRead;
 try
  Result := fSupportsSearching;
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.StartSearch();
begin

 fLock.BeginWrite;
 try
  fIsSearching := True;
 finally
  fLock.EndWrite;
 end;
 
 fKernel.PostMessage(fInstanceID, IM_CHANGESEARCH, [True]);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.StopSearch();
begin

 fLock.BeginWrite;
 try
  fIsSearching := False;
 finally
  fLock.EndWrite;
 end;
 
 fKernel.PostMessage(fInstanceID, IM_CHANGESEARCH, [False]);

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.IsSearching: Boolean;
begin

 fLock.BeginRead;
 try
  Result := fIsSearching;
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.HandlePHPEvent(FunctionName    : String;
                                          Parameters      : TIPSPHPParameters;
                                          var ReturnValue : TIPSPHPParameter);
begin

 raise EIPSModuleObject.Create(Format(_('PHP function was not handled: %s'), [FunctionName]));

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SetProperty(PropertyName: String; PropertyValue: Variant); stdcall;
var PropertyArray: TSuperArray;
    i: Integer;
begin

 fLock.BeginWrite;
 try
  if not Assigned(fConfigurationFlux.AsObject.O[PropertyName]) then
   raise EIPSModuleObject.Create(Format( _('Property %s could not be found!'), [PropertyName] ));

  case fConfigurationFlux.AsObject.O[PropertyName].DataType of
   stBoolean:
    begin
     if fConfigurationFlux.AsObject.B[PropertyName] = PropertyValue then
      exit;
     fConfigurationFlux.AsObject.B[PropertyName] := PropertyValue;
    end;
   stInt:
    begin
     if fConfigurationFlux.AsObject.I[PropertyName] = PropertyValue then
      exit;
     fConfigurationFlux.AsObject.I[PropertyName] := PropertyValue;
    end;
   stCurrency,
   stDouble:
    begin
     if fConfigurationFlux.AsObject.D[PropertyName] = PropertyValue then
      exit;
     fConfigurationFlux.AsObject.D[PropertyName] := PropertyValue;
    end;
   stString:
    begin
     if fConfigurationFlux.AsObject.S[PropertyName] = PropertyValue then
      exit;
     if VarIsNull(PropertyValue) then
      fConfigurationFlux.AsObject.S[PropertyName] := ''
     else 
      fConfigurationFlux.AsObject.S[PropertyName] := PropertyValue;
    end;
   stArray:
    begin
     PropertyArray := fConfigurationFlux.AsObject[PropertyName].AsArray;
     PropertyArray.Clear();
     for i := 0 to VarArrayHighBound(PropertyValue, 1)do
      PropertyArray.Add(SO(PropertyValue[i]));
    end
  else
   raise EIPSModuleObject.Create('Unsupported property datatype');
  end;

  //only do this, of we didn't leave with an exit or exception
  fHasChanges := True;
 finally
  fLock.EndWrite;
 end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetProperty(PropertyName: String): Variant; stdcall;
var PropertyArray: TSuperArray;
    i: Integer;
begin

 fLock.BeginRead;
 try
  if not Assigned(fConfiguration.AsObject.O[PropertyName]) then
   raise EIPSModuleObject.Create(Format( _('Property %s could not be found!'), [PropertyName] ));

  case fConfiguration.AsObject.O[PropertyName].DataType of
   stBoolean:
    Result := fConfiguration.AsObject.B[PropertyName];
   stInt:
    Result := fConfiguration.AsObject.I[PropertyName];
   stDouble:
    Result := fConfiguration.AsObject.D[PropertyName];
   stString:
    Result := fConfiguration.AsObject.S[PropertyName];
   stArray:
    begin
     PropertyArray := fConfiguration.AsObject[PropertyName].AsArray;
     if PropertyArray.Length = 0 then
      Result := VarArrayOf([])
     else
      begin
       Result := VarArrayCreate([0, PropertyArray.Length-1], varVariant);
       for i := 0 to PropertyArray.Length - 1 do
        case PropertyArray[i].DataType of
         stBoolean:
          Result[i] := PropertyArray[i].AsBoolean;
         stInt:
          Result[i] := PropertyArray[i].AsInteger;
         stCurrency,
         stDouble:
          Result[i] := PropertyArray[i].AsDouble;
         stString:
          Result[i] := PropertyArray[i].AsString;
        end;
      end;
    end
  else
   raise EIPSModuleObject.Create(Format('Unsupported property %s datatype %d', [PropertyName, Ord(fConfiguration.AsObject.O[PropertyName].DataType)]));
  end;
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SetConfiguration(Configuration: String); stdcall;
var ConfigurationNew, Properties: ISuperObject;
    i: Integer;
begin

 fLock.BeginWrite;
 try
  ConfigurationNew := SO(Configuration);
  Properties := fConfigurationFlux.AsObject.GetNames;

  //check for type mismatch errors
  for i := 0 to Properties.AsArray.Length - 1 do
   if Assigned(ConfigurationNew.AsObject[Properties.AsArray[i].AsString]) then
    if fConfigurationFlux.AsObject.O[Properties.AsArray[i].AsString].DataType <> ConfigurationNew.AsObject.O[Properties.AsArray[i].AsString].DataType then
     raise EIPSModuleObject.Create(Format('DataType missmatch for property %s', [Properties.AsArray[i].AsString]));

  //copy new configuration
  for i := 0 to Properties.AsArray.Length - 1 do
   if Assigned(ConfigurationNew.AsObject[Properties.AsArray[i].AsString]) then
    fConfigurationFlux.AsObject.O[Properties.AsArray[i].AsString] := ConfigurationNew.AsObject.O[Properties.AsArray[i].AsString].Clone;

  //show we have some changes
  fHasChanges := True;    
 finally
  fLock.EndWrite;
 end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetConfiguration(): String; stdcall;
begin

 fLock.BeginRead;
 try
  Result := fConfiguration.AsJSon();
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetConfigurationForm(): String; stdcall;
var KernelDir: String;
    Instance: TIPSInstance;
    StrList: TStringList;
begin

 Result := '{}';
 KernelDir := fKernel.GetKernelDir();
 Instance := fKernel.InstanceManager.GetInstance(fInstanceID);
 try
  if FileExists(KernelDir + 'forms/' + Instance.ModuleInfo.ModuleName + '.json') then
   begin
    StrList := TStringList.Create;
    try
     StrList.LoadFromFile(KernelDir + 'forms/' + Instance.ModuleInfo.ModuleName + '.json');
     Result := StrList.Text;
    finally
     StrList.Free;
    end;
   end;
 finally
  Instance.Free;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.LoadFromData(ID: TIPSID; Data: ISuperObject);
var i: Integer;
    Properties: ISuperObject;
begin

 Properties := fConfigurationFlux.AsObject.GetNames; 
 for i := 0 to Properties.AsArray.Length - 1 do
  if Assigned(Data.AsObject[Properties.AsArray[i].AsString]) then
   fConfigurationFlux.AsObject.O[Properties.AsArray[i].AsString] := Data.AsObject.O[Properties.AsArray[i].AsString].Clone;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.LoadSettings();
var i: Integer;
    ValBool: Boolean;
    ValInt: Integer;
    ValStr: String;
    ValFloat: Double;
    Properties: ISuperObject;
begin

 DisableContext;
 try
  //Load Module Settings
  if fProperties.Count > 0 then
   for i:=0 to fProperties.Count-1 do
    begin
     case TPropertyHolder(fProperties.Objects[i]).PropertyType of
      vtBoolean: if not FAILED(fKernel.Settings.ReadInstanceBoolean(fInstanceID, ['Settings'], fProperties[i], ValBool)) then
                  TBoolSetter(TPropertyHolder(fProperties.Objects[i]).Setter)(ValBool);
      vtInteger: if not FAILED(fKernel.Settings.ReadInstanceInteger(fInstanceID, ['Settings'], fProperties[i], ValInt)) then
                  TIntSetter(TPropertyHolder(fProperties.Objects[i]).Setter)(ValInt);
      vtFloat:   if not FAILED(fKernel.Settings.ReadInstanceFloat(fInstanceID, ['Settings'], fProperties[i], ValFloat)) then
                  TFloatSetter(TPropertyHolder(fProperties.Objects[i]).Setter)(ValFloat);
      vtString:  if not FAILED(fKernel.Settings.ReadInstanceString(fInstanceID, ['Settings'], fProperties[i], ValStr)) then
                  TStrSetter(TPropertyHolder(fProperties.Objects[i]).Setter)(ValStr);
     else
      raise EIPSModuleObject.Create(Format(_('Cannot load unsupported Property: %s'), [fProperties[i]]));
     end;
    end;

   //Import old legacy settings
   Properties := fConfigurationFlux.AsObject.GetNames;
   for i := 0 to Properties.AsArray.Length - 1 do
    case fConfigurationFlux.AsObject.O[Properties.AsArray[i].AsString].DataType of
     stBoolean:
      if not FAILED(fKernel.Settings.ReadInstanceBoolean(fInstanceID, ['Settings'], Properties.AsArray[i].AsString, ValBool)) then
       begin
        fConfigurationFlux.AsObject.B[Properties.AsArray[i].AsString] := ValBool;
        fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', Properties.AsArray[i].AsString]);
       end;
     stInt:
      if not FAILED(fKernel.Settings.ReadInstanceInteger(fInstanceID, ['Settings'], Properties.AsArray[i].AsString, ValInt)) then
       begin
        fConfigurationFlux.AsObject.I[Properties.AsArray[i].AsString] := ValInt;
        fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', Properties.AsArray[i].AsString]);
       end;
     stDouble:
      if not FAILED(fKernel.Settings.ReadInstanceFloat(fInstanceID, ['Settings'], Properties.AsArray[i].AsString, ValFloat)) then
       begin
        fConfigurationFlux.AsObject.D[Properties.AsArray[i].AsString] := ValFloat;
        fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', Properties.AsArray[i].AsString]);
       end;
     stString:
      if not FAILED(fKernel.Settings.ReadInstanceString(fInstanceID, ['Settings'], Properties.AsArray[i].AsString, ValStr)) then
       begin
        fConfigurationFlux.AsObject.S[Properties.AsArray[i].AsString] := ValStr;
        fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', Properties.AsArray[i].AsString]);
       end;
    end;
    
 finally
  EnableContext;
 end;
   
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SaveSettings();
var i: Integer;
begin

 DisableContext;
 try
  //Save Module Settings
  if fProperties.Count > 0 then
   for i:=0 to fProperties.Count-1 do
    begin
     case TPropertyHolder(fProperties.Objects[i]).PropertyType of
      vtBoolean: fKernel.Settings.WriteInstanceBoolean(fInstanceID, ['Settings'], fProperties[i], TBoolGetter(TPropertyHolder(fProperties.Objects[i]).Getter));
      vtInteger: fKernel.Settings.WriteInstanceInteger(fInstanceID, ['Settings'], fProperties[i], TIntGetter(TPropertyHolder(fProperties.Objects[i]).Getter));
      vtFloat:   fKernel.Settings.WriteInstanceFloat(fInstanceID, ['Settings'], fProperties[i], TFloatGetter(TPropertyHolder(fProperties.Objects[i]).Getter));
      vtString:  fKernel.Settings.WriteInstanceString(fInstanceID, ['Settings'], fProperties[i], TStrGetter(TPropertyHolder(fProperties.Objects[i]).Getter));
     else
      raise EIPSModuleObject.Create(Format(_('Cannot load unsupported Property: %s'), [fProperties[i]]));
     end;
    end;

 finally
  EnableContext;
 end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.HasChanges: Boolean;
begin

 fLock.BeginRead;
 try
  Result := fHasChanges;
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ResetChanges(); 
begin

 fLock.BeginWrite;
 try
  //Reset configuration
  fConfigurationFlux := fConfiguration.Clone;
  fHasChanges := False;
 finally
  fLock.EndWrite;
 end;
 
 SendSettingsChangedMessage;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ApplyChanges();
begin

 fLock.BeginWrite;
 try
  //Apply configuration
  fConfiguration := fConfigurationFlux.Clone;

  //Force Save to XML
  SaveSettings;

  //Send Message to update Clients and JSON files
  fHasChanges := False;
 finally
  fLock.EndWrite;
 end;

 //Will send new JSON based settings
 SendSettingsChangedMessage;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetInstanceID(): TInstanceID; stdcall;
begin

 Result := fInstanceID;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SettingsChanged;
begin

 fLock.BeginWrite;
 try
  fHasChanges := True;
 finally
  fLock.EndWrite;
 end;
 
 SendSettingsChangedMessage;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SendSettingsChangedMessage;
var Configuration: String;
begin

 if (fKernelRunlevel <> KR_READY) then
  exit;

 fLock.BeginRead;
 try
  if fHasChanges then
   begin
    Configuration := fConfigurationFlux.AsJSon(); //cannot send function result in array of const
    fKernel.PostMessage(fInstanceID, IM_CHANGESETTINGS, [fHasChanges, Configuration])
   end
  else
   begin
    Configuration := fConfiguration.AsJSon(); //cannot send function result in array of const
    fKernel.PostMessage(fInstanceID, IM_CHANGESETTINGS, [fHasChanges, Configuration]);
   end;
 finally
  fLock.EndRead;
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ProcessInstanceStatusChange(InstanceID: TInstanceID; Status: Integer);
begin

 //

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterPropertyDeprecated(PropertyName: String; PType: TIPSVarType; Getter: TMethod; Setter: TMethod);
var PropHolder: TPropertyHolder;
begin

 if fProperties.IndexOf(PropertyName) <> -1 then
  EIPSModuleObject.Create(Format(_('Property "%s" already exists'), [PropertyName]));

 PropHolder := TPropertyHolder.Create;
 PropHolder.PropertyType := PType;
 PropHolder.Getter := Getter;
 PropHolder.Setter := Setter;

 fProperties.AddObject(PropertyName, PropHolder);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterFunctions();
var Prefix: String;
    Singleton: Boolean;
    i: Integer;
    Info: PTypeInfo;
    Table: PInterfaceTable;
begin

 Prefix := fKernel.ModuleLoaderEx.GetModulePrefix(GetModuleID());
 Singleton := fKernel.ModuleLoaderEx.GetModuleSingleton(GetModuleID());
 Table := Self.GetInterfaceTable;

 if Assigned(Table) then
  for i:=0 to Table.EntryCount-1 do
   begin
    Info := fKernel.ModuleLoaderEx.GetInterfaceInfo(Table.Entries[i].IID);
    if Assigned(Info) then
     begin
      if Info^.Name = 'IIPSModule' then
       fKernel.ScriptEngineEx.RegisterFunctions(Info, 'IPS', HandlePHPEvent, fInstanceID, False)
      else
       fKernel.ScriptEngineEx.RegisterFunctions(Info, Prefix, HandlePHPEvent, fInstanceID, Singleton);
     end;
   end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterBoolProperty(PropertyName: String; Getter: TBoolGetter; Setter: TBoolSetter);
begin
 RegisterPropertyDeprecated(PropertyName, vtBoolean, TMethod(Getter), TMethod(Setter));
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterIntProperty(PropertyName: String; Getter: TIntGetter; Setter: TIntSetter);
begin
 RegisterPropertyDeprecated(PropertyName, vtInteger, TMethod(Getter), TMethod(Setter));
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterFloatProperty(PropertyName: String; Getter: TFloatGetter; Setter: TFloatSetter);
begin
 RegisterPropertyDeprecated(PropertyName, vtFloat, TMethod(Getter), TMethod(Setter));
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterStrProperty(PropertyName: String; Getter: TStrGetter; Setter: TStrSetter);
begin
 RegisterPropertyDeprecated(PropertyName, vtString, TMethod(Getter), TMethod(Setter));
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterTimer(Name: String; Interval: Double; OnEvent: TTimerEvent);
var TimerID: TTimerID;
begin

 if fTimers.IndexOf(Name) <> -1 then
  raise EIPSModuleObject.Create(Format('Timer with name %s already registered', [Name]));

 TimerID := fKernel.TimerPoolEx.RegisterTimerEx(Name, fInstanceID, OnEvent, Round(Interval*1000));
 fTimers.AddObject(Name, TObject(TimerID));

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.SetTimerInterval(Name: String; Interval: Double);
var TimerIndex: Integer;
    TimerID: TTimerID;
begin

 TimerIndex := fTimers.IndexOf(Name);
 if TimerIndex = -1 then
  raise EIPSModuleObject.Create(Format('Timer with name %s was not found', [Name]));

 TimerID := Integer(fTimers.Objects[TimerIndex]);
 fKernel.TimerPoolEx.SetIntervalEx(TimerID, Round(Interval*1000));

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ResetTimer(Name: String);
var TimerIndex: Integer;
    TimerID: TTimerID;
begin

 TimerIndex := fTimers.IndexOf(Name);
 if TimerIndex = -1 then
  raise EIPSModuleObject.Create(Format('Timer with name %s was not found', [Name]));

 TimerID := Integer(fTimers.Objects[TimerIndex]);
 fKernel.TimerPoolEx.ResetTimer(TimerID);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterProfile(VarProfile: TIPSVarProfile);
begin

 //system profiles are read-only
 VarProfile.IsReadOnly := True;

 //system profile have a prefix
 if Length(VarProfile.ProfileName) > 0 then
  if VarProfile.ProfileName[1] <> '~' then
   VarProfile.ProfileName := '~' + VarProfile.ProfileName;

 //Register Profile
 fKernel.ProfilePoolEx.CreateVariableProfileEx(VarProfile);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterProperty(PropertyName: String; PropertyDefaultValue: Variant);
var PropertyArray: TSuperArray;
    i: Integer;
begin

 case TVarData(PropertyDefaultValue).VType of
  varBoolean:
   fConfigurationFlux.AsObject.B[PropertyName] := TVarData(PropertyDefaultValue).VBoolean;
  varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64:
   fConfigurationFlux.AsObject.I[PropertyName] := PropertyDefaultValue;
  varSingle, varDouble, varCurrency:
   fConfigurationFlux.AsObject.D[PropertyName] := PropertyDefaultValue;
  varOleStr, varString:
   if Assigned ( TVarData(PropertyDefaultValue).VString ) then
    fConfigurationFlux.AsObject.S[PropertyName] := PropertyDefaultValue
   else
    fConfigurationFlux.AsObject.S[PropertyName] := '';
 else
  begin
   if VarIsArray(PropertyDefaultValue) then
    begin
     fConfigurationFlux.AsObject[PropertyName] := SA([]);
     PropertyArray := fConfigurationFlux.AsObject[PropertyName].AsArray;
     PropertyArray.Clear();
     for i := 0 to VarArrayHighBound(PropertyDefaultValue, 1)do
      PropertyArray.Add(SO(PropertyDefaultValue[i]));
    end
  end;
  //varDate, varError, varDispatch, varVariant, varUnknown
 end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.RegisterVariable(VarIdent: String; VarName: String; VarType: TIPSVarType; VarProfile: String = ''; VarAction: TIPSActionRequestHandler = nil; VarPosition: Integer = 0);
var ID: TIPSID;
    VariableID: Integer;
    UseAction: Boolean;
    Variable: TIPSVariable;
    VarIndex: Integer;
    VarActionID: TIPSID;
begin

 //prefer system profiles
 if Length(VarProfile) > 0 then
  if VarProfile[1] <> '~' then
   if fKernel.ProfilePool.VariableProfileExists('~' + VarProfile) then
    VarProfile := '~' + VarProfile;

 if not fKernel.ProfilePool.VariableProfileExists(VarProfile) then
  VarProfile := ''; //do not assign profile that do not exist
    
 try
  ID := fKernel.ObjectManager.GetObjectIDByIdent(VarIdent, fInstanceID);
 except
  ID := 0;
 end;

 if ID = 0 then
  begin
   //try importing from 2.4 settings
   if not FAILED(fKernel.Settings.ReadInstanceInteger(fInstanceID, ['Settings', 'StatusVariables'], VarIdent, VariableID)) then
    begin
     if fKernel.VariableManager.VariableExists(VariableID) then //Filter invalid references
      if (fKernel.ObjectManager.GetParent(VariableID) = fInstanceID) then //Filter Version 1.0 double-mappings
       begin
        ID := VariableID;
        fKernel.ObjectManager.SetIdent(ID, VarIdent);
        fkernel.ObjectManager.SetReadOnly(ID, True);
        if Assigned(VarAction) then
         fKernel.VariableManagerEx.SetVariableAction(ID, fInstanceID);
       end;
     fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', 'StatusVariables', VarIdent]);
    end;

   if ID > 0 then   
    if not FAILED(fKernel.Settings.ReadInstanceBoolean(fInstanceID, ['Settings', 'StatusVariablesActions'], VarIdent, UseAction)) then
     begin
      if not UseAction then
       fKernel.VariableManager.SetVariableCustomAction(ID, 1);
      fKernel.Settings.DeleteInstanceItem(fInstanceID, ['Settings', 'StatusVariablesActions', VarIdent]);
     end;
  end;

 //check if for type matching
 if ID > 0 then
  begin
   Variable := fKernel.VariableManager.GetVariable(ID);
   try
    if Variable.VariableValue.ValueType <> VarType then
     begin
      fKernel.VariableManager.DeleteVariable(ID);
      ID := 0;
     end;
   finally
    Variable.Free;
   end;
  end;

 //create new one
 if ID = 0 then
  begin
   ID := fKernel.VariableManager.CreateVariable(VarType);
   fKernel.ObjectManager.SetParent(ID, fInstanceID);
   fKernel.ObjectManager.SetIdent(ID, VarIdent);
   fKernel.ObjectManager.SetName(ID, VarName);
   fKernel.ObjectManager.SetPosition(ID, VarPosition);
   fKernel.ObjectManager.SetReadOnly(ID, True);
   if Assigned(VarAction) then   
    fKernel.VariableManagerEx.SetVariableAction(ID, fInstanceID);
   if SameText(VarIdent, '') then
    fKernel.ObjectManager.SetHidden(ID, True);
  end;

 //update profile
 Variable := fKernel.VariableManager.GetVariable(ID);
 try
  if Variable.VariableProfile <> VarProfile then
   fKernel.VariableManagerEx.SetVariableProfile(ID, VarProfile);
 finally
  Variable.Free;
 end;

 if Assigned(VarAction) then
  VarActionID := fInstanceID
 else
  VarActionID := 0;

 //update action
 Variable := fKernel.VariableManager.GetVariable(ID);
 try
  if Variable.VariableAction <> VarActionID then
   begin
    //if the action was disabled before, let it disabled. user can enable it manually
    if Variable.VariableAction = 0 then
     fKernel.VariableManager.SetVariableCustomAction(ID, 1);

    fKernel.VariableManagerEx.SetVariableAction(ID, VarActionID);
   end;
 finally
  Variable.Free;
 end;

 //add action to list
 (*
   this is potentially bad, as we need to make sure that RegisterVariabe is called at lease once after a startup
   to get a valid pointer for the action handler. 
 *)
 if Assigned(VarAction) then
  if fVariableActions.IndexOf(VarIdent) = -1 then
   fVariableActions.AddObject(VarIdent, TObject(TMethod(VarAction).Code));

 if not Assigned(VarAction) then
   begin
    VarIndex := fVariableActions.IndexOf(VarIdent);
    if VarIndex > 0 then
     fVariableActions.Delete(VarIndex);
   end;

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.UnregisterVariable(VarIdent: String);
var ID: TIPSID;
begin

 try
  ID := fKernel.ObjectManager.GetObjectIDByIdent(VarIdent, fInstanceID);
 except
  ID := 0;
 end;

 if ID > 0 then
  fKernel.VariableManager.DeleteVariable(ID);

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.MaintainVariable(Keep: Boolean; VarIdent: String; VarName: String; VarType: TIPSVarType; VarProfile: String = ''; VarAction: TIPSActionRequestHandler = nil; VarPosition: Integer = 0);
begin

 if not Keep then
  UnregisterVariable(VarIdent)
 else
  RegisterVariable(VarIdent, VarName, VarType, VarProfile, VarAction, VarPosition); 

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.RequireParent(ModuleID: TGUID; ForceCreate: Boolean = False): Boolean;
var Compatibles: TInstanceIDs;
    InstanceID: TInstanceID;
    Module: TIPSModuleClass;
begin

 Result := False;
 if fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID) = 0 then
  begin
   if not ForceCreate then
    Compatibles := fKernel.InstanceManager.GetCompatibleInstances(fInstanceID);

   if ForceCreate or (High(Compatibles) = -1) then
    begin
     if not fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
      exit;
     Module := fKernel.ModuleLoaderEx.GetModuleClass(GUIDToString(ModuleID));
     InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
     fKernel.ObjectManager.SetName(InstanceID, Module.GetModuleName());
     fKernel.DataHandler.ConnectInstance(fInstanceID, InstanceID);
     Result := True;
    end
   else
    fKernel.DataHandler.ConnectInstance(fInstanceID, Compatibles[0]);
  end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.ForceParent(ModuleID: TGUID): Boolean;
var ParentID: TInstanceID;
    InstanceID: TInstanceID;
    Instance: TIPSInstance;
    InstanceModuleID: TStrGUID;
    Module: TIPSModuleClass;
begin

 Result := False;

 ParentID := fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID);
 if ParentID <> 0 then
  begin
   Instance := fKernel.InstanceManager.GetInstance(ParentID);
   try
    InstanceModuleID := Instance.ModuleInfo.ModuleID;
   finally
    Instance.Free;
   end;
   if not (InstanceModuleID = GUIDToString(ModuleID)) then
    if fKernel.ModuleLoader.ModuleExists(GUIDToString(ModuleID)) then
     begin
      Module := fKernel.ModuleLoaderEx.GetModuleClass(GUIDToString(ModuleID));
      InstanceID := fKernel.InstanceManager.CreateInstance(GUIDToString(ModuleID));
      fKernel.ObjectManager.SetName(InstanceID, Module.GetModuleName());
      fKernel.DataHandler.ConnectInstance(fInstanceID, InstanceID);

      //Delete old Parent?
      if not fKernel.DataHandlerEx.HasInstanceChildren(ParentID) then
       fKernel.InstanceManager.DeleteInstance(ParentID);

      Result := True;
     end;
  end;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.ForceParentConfiguration(IID: TGUID; Configuration: Array of Const): Boolean;
var i: Integer;
    Valid: Boolean;
begin

 Result := False;
 Valid := False;
 if Supports(GetParent(), IID) then
  for i := 0 to (Length(Configuration) div 3) -1 do
   begin
    //Rest validation to false at the beginning and on property name change
    if (i = 0) or (VarRecToVariant(Configuration[i*3+0]) <> VarRecToVariant(Configuration[(i-1)*3+0])) then
     Valid := False;

    //Check a few comparison options 
    if VarRecToVariant(Configuration[i*3+1]) = '=' then
     Valid := Valid or ((GetParent().GetProperty(VarRecToVariant(Configuration[i*3+0])) = VarRecToVariant(Configuration[i*3+2])))
    else if VarRecToVariant(Configuration[i*3+1]) = '>=' then
     Valid := Valid or ((GetParent().GetProperty(VarRecToVariant(Configuration[i*3+0])) >= VarRecToVariant(Configuration[i*3+2])));

    //Only do validity check if we are at the end or the next property name differs
    if (i = ((Length(Configuration) div 3))-1) or (VarRecToVariant(Configuration[i*3+0]) <> VarRecToVariant(Configuration[(i+1)*3+0])) then
     if not Valid then
      begin
       GetParent().SetProperty(VarRecToVariant(Configuration[i*3+0]), VarRecToVariant(Configuration[i*3+2]));
       Result := True;
      end;
   end;

 if Result then
  GetParent().ApplyChanges;

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetParent(): IIPSModule;
var ObjID: TInstanceID;
    Instance: TIPSInstance;
begin

 ObjID := fKernel.DataHandlerEx.GetInstanceParentID(fInstanceID);
 if ObjID = 0 then
  raise EIPSModuleObject.Create(_('Instance has no Parent Instance connected!'));

 Instance := fKernel.InstanceManager.GetInstance(ObjID);
 try
  Result := Instance.InstanceInterface;
 finally
  Instance.Free;
 end;

 if Result = nil then
  raise EIPSModuleObject.Create(_('Instance Interface is not assigned!'));

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.HasActiveParent(): Boolean;

 function HasActiveParentByID(InstanceID: TInstanceID): Boolean;
 var ObjID: TInstanceID;
     Instance: TIPSInstance;
 begin

  Result := False;
  ObjID := fKernel.DataHandlerEx.GetInstanceParentID(InstanceID);
  if (ObjID > 0) and (fKernel.InstanceManager.InstanceExists(ObjID)) then
   begin
    Instance := fKernel.InstanceManager.GetInstance(ObjID);
    try
     if Instance.ModuleInfo.ModuleType <> mtIO then
      Result := HasActiveParentByID(Instance.InstanceID)
     else
      Result := Instance.InstanceStatus = IS_ACTIVE;
    finally
     Instance.Free;
    end;
   end;
   
 end;

begin
 Result := HasActiveParentByID(fInstanceID);
end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ReceiveData(Data: String); stdcall;
begin

 //placeholder. functions has to be overriden

end;

//------------------------------------------------------------------------------
procedure TIPSModuleObject.ForwardData(Data: String); stdcall;
begin

 //placeholder. functions has to be overriden

end;

//------------------------------------------------------------------------------
function TIPSModuleObject.GetChildren(): TInterfaceList;
var ObjIDs: TInstanceIDs;
    i: Integer;
    Instance: TIPSInstance;
begin

 ObjIDs := fKernel.DataHandlerEx.GetInstanceChildrenIDs(fInstanceID);

 Result := TInterfaceList.Create;
 for i:= Low(ObjIDs) to High(ObjIDs) do
  if fKernel.InstanceManager.InstanceExists(ObjIDs[i]) then
   begin
    Instance := fKernel.InstanceManager.GetInstance(ObjIDs[i]);
    try
     if Assigned(Instance.InstanceInterface) then
      Result.Add(Instance.InstanceInterface);
    finally
     Instance.Free;
    end;
   end;

end;

//------------------------------------------------------------------------------
class function TIPSModuleObject.GetParentRequirements(): TStrGUIDs;
begin
 if GetModuleType = mtIO then
  raise EIPSModuleObject.Create(_('I/O Modules have no Parents'));
 SetLength(Result, 0);
end;

//------------------------------------------------------------------------------
class function TIPSModuleObject.GetChildRequirements(): TStrGUIDs;
begin
 if GetModuleType in [mtConfigurator, mtCore, mtDevice] then
  raise EIPSModuleObject.Create(_('Device/Core/Configurator Modules have no Children'));
 SetLength(Result, 0);
end;

//------------------------------------------------------------------------------
class function TIPSModuleObject.GetImplemented(): TStrGUIDs;
begin
 SetLength(Result, 0);
end;

//------------------------------------------------------------------------------
class function TIPSModuleObject.GetVendor(): String;
begin
 Result := '';
end;

//------------------------------------------------------------------------------
class function TIPSModuleObject.GetAliases(): TStringArray;
begin
 SetLength(Result, 0);
end;

//------------------------------------------------------------------------------
function VarRecToVariant(varRec: TVarRec): Variant;
begin
 case varRec.VType of
  System.vtInteger    : result := varRec.VInteger;
  System.vtInt64      : result := varRec.VInt64^;
  System.vtBoolean    : result := varRec.VBoolean;
  System.vtChar       : result := varRec.VChar;
  System.vtWideChar   : result := varRec.VWideChar;
  System.vtExtended   : result := varRec.VExtended^;
  System.vtCurrency   : result := varRec.VCurrency^;
  System.vtString     : result := varRec.VString^;
  System.vtPChar      : result := varRec.VPChar^;
  System.vtAnsiString : result := AnsiString(varRec.VAnsiString);
  System.vtWideString : result := WideString(varRec.VWideString);
  System.vtObject     : result := varRec.VObject.ClassName;
  System.vtClass      : result := varRec.VClass.ClassName;
  System.vtVariant    : result := varRec.VVariant^;
 else
  raise Exception.Create('Cannot copy message from VarRec To Variant'); 
 end;
end;
 
//Implements some global used functions/procedures
//------------------------------------------------------------------------------
function StringToVarType(VarType: String): TIPSVarType;
begin
 Result := TIPSVarType(GetEnumValue(TypeInfo(TIPSVarType),'vt'+VarType));
end;

//------------------------------------------------------------------------------
function VarTypeToString(VarType: TIPSVarType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSVarType), Integer(VarType));
 Delete(Result, 1, 2); //Cut off first two chars
end;

//------------------------------------------------------------------------------
function StringToEventType(EventType: String): TIPSEventType;
begin
 Result := TIPSEventType(GetEnumValue(TypeInfo(TIPSEventType),'et'+EventType));
end;

//------------------------------------------------------------------------------
function EventTypeToString(EventType: TIPSEventType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSEventType), Integer(EventType));
 Delete(Result, 1, 2); //Cut off first two chars
end;

//------------------------------------------------------------------------------
function StringToTriggerType(TriggerType: String): TIPSTriggerType;
begin
 Result := TIPSTriggerType(GetEnumValue(TypeInfo(TIPSTriggerType),'evt'+TriggerType));
end;

//------------------------------------------------------------------------------
function TriggerTypeToString(TriggerType: TIPSTriggerType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSTriggerType), Integer(TriggerType));
 Delete(Result, 1, 3); //Cut off first three chars
end;

//------------------------------------------------------------------------------
function StringToCyclicDateType(CyclicDateType: String): TIPSCyclicDateType;
begin
 Result := TIPSCyclicDateType(GetEnumValue(TypeInfo(TIPSCyclicDateType),'cdt'+CyclicDateType));
end;

//------------------------------------------------------------------------------
function CyclicDateTypeToString(CyclicDateType: TIPSCyclicDateType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSCyclicDateType), Integer(CyclicDateType));
 Delete(Result, 1, 3); //Cut off first three chars
end;

//------------------------------------------------------------------------------
function StringToCyclicTimeType(CyclicTimeType: String): TIPSCyclicTimeType;
begin
 Result := TIPSCyclicTimeType(GetEnumValue(TypeInfo(TIPSCyclicTimeType),'cdt'+CyclicTimeType));
end;

//------------------------------------------------------------------------------
function CyclicTimeTypeToString(CyclicTimeType: TIPSCyclicTimeType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSCyclicTimeType), Integer(CyclicTimeType));
 Delete(Result, 1, 3); //Cut off first three chars
end;

//------------------------------------------------------------------------------
function StringToObjectType(ObjectType: String): TIPSObjectType;
begin
 Result := TIPSObjectType(GetEnumValue(TypeInfo(TIPSObjectType),'ot'+ObjectType));
end;

//------------------------------------------------------------------------------
function ObjectTypeToString(ObjectType: TIPSObjectType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSObjectType), Integer(ObjectType));
 Delete(Result, 1, 2); //Cut off first two chars
end;

//------------------------------------------------------------------------------
function StringToMediaType(MediaType: String): TIPSMediaType;
begin
 Result := TIPSMediaType(GetEnumValue(TypeInfo(TIPSMediaType),'mt'+MediaType));
end;

//------------------------------------------------------------------------------
function MediaTypeToString(MediaType: TIPSMediaType): String;
begin
 Result := GetEnumName(TypeInfo(TIPSMediaType), Integer(MediaType));
 Delete(Result, 1, 2); //Cut off first two chars
end;

//------------------------------------------------------------------------------
function KernelConstToString(Message: Integer): String;
begin

 case Message of
  IPS_BASE            : Result := 'IPS_BASE';
  IPS_KERNELSHUTDOWN  : Result := 'IPS_KERNELSHUTDOWN';
  IPS_KERNELSTARTED   : Result := 'IPS_KERNELSTARTED';
  IPS_KERNELMESSAGE   : Result := 'IPS_KERNELMESSAGE';
 // --- KERNEL
  KR_CREATE           : Result := 'KR_CREATE';
  KR_INIT             : Result := 'KR_INIT';
  KR_READY            : Result := 'KR_READY';
  KR_UNINIT           : Result := 'KR_UNINIT';
  KR_SHUTDOWN         : Result := 'KR_SHUTDOWN';
  IPS_LOGMESSAGE      : Result := 'IPS_LOGMESSAGE';
  KL_MESSAGE          : Result := 'KL_MESSAGE';
  KL_SUCCESS          : Result := 'KL_SUCCESS';
  KL_NOTIFY           : Result := 'KL_NOTIFY';
  KL_WARNING          : Result := 'KL_WARNING';
  KL_ERROR            : Result := 'KL_ERROR';
  KL_DEBUG            : Result := 'KL_DEBUG';
  KL_CUSTOM           : Result := 'KL_CUSTOM';
  // --- MODULE LOADER
  IPS_MODULEMESSAGE      : Result := 'IPS_MODULEMESSAGE';
  ML_LOAD                : Result := 'ML_LOAD';
  ML_UNLOAD              : Result := 'ML_UNLOAD';
  // --- OBJECT MANAGER
  IPS_OBJECTMESSAGE      : Result := 'IPS_OBJECTMESSAGE';
  OM_REGISTER            : Result := 'OM_REGISTER';
  OM_UNREGISTER          : Result := 'OM_UNREGISTER';
  OM_CHANGEPARENT        : Result := 'OM_CHANGEPARENT';
  OM_CHANGENAME          : Result := 'OM_CHANGENAME';
  OM_CHANGEINFO          : Result := 'OM_CHANGEINFO';
  OM_CHANGETYPE          : Result := 'OM_CHANGETYPE';
  OM_CHANGESUMMARY       : Result := 'OM_CHANGESUMMARY';
  OM_CHANGEPOSITION      : Result := 'OM_CHANGEPOSITION';
  OM_CHANGEREADONLY      : Result := 'OM_CHANGEREADONLY';
  OM_CHANGEHIDDEN        : Result := 'OM_CHANGEHIDDEN';
  OM_CHILDADDED          : Result := 'OM_CHILDADDED';
  OM_CHILDREMOVED        : Result := 'OM_CHILDREMOVED';
  OM_CHANGEIDENT         : Result := 'OM_CHANGEIDENT';
  // --- INSTANCE MANAGER
  IPS_INSTANCEMESSAGE    : Result := 'IPS_INSTANCEMESSAGE';
  IM_CREATE              : Result := 'IM_CREATE';
  IM_DELETE              : Result := 'IM_DELETE';
  IM_CONNECT             : Result := 'IM_CONNECT';
  IM_DISCONNECT          : Result := 'IM_DISCONNECT';
  IM_CHANGESTATUS        : Result := 'IM_CHANGESTATUS';
  IM_CHANGESETTINGS      : Result := 'IM_CHANGESETTINGS';
  IM_CHANGESEARCH        : Result := 'IM_CHANGESEARCH';
  IM_SEARCHUPDATE        : Result := 'IM_SEARCHUPDATE';
  IM_SEARCHPROGRESS      : Result := 'IM_SEARCHPROGRESS';
  IM_SEARCHCOMPLETE      : Result := 'IM_SEARCHCOMPLETE';
  // --- VARIABLE MANAGER
  IPS_VARIABLEMESSAGE    : Result := 'IPS_VARIABLEMESSAGE';
  VM_CREATE              : Result := 'VM_CREATE';
  VM_DELETE              : Result := 'VM_DELETE';
  VM_UPDATE              : Result := 'VM_UPDATE';
  VM_CHANGEPROFILENAME   : Result := 'VM_CHANGEPROFILENAME';
  VM_CHANGEPROFILEACTION : Result := 'VM_CHANGEPROFILEACTION';
  // --- SCRIPT MANAGER
  IPS_SCRIPTMESSAGE      : Result := 'IPS_SCRIPTMESSAGE';
  SM_CREATE              : Result := 'SM_CREATE';
  SM_DELETE              : Result := 'SM_DELETE';
  SM_CHANGEFILE          : Result := 'SM_CHANGEFILE';
  SM_BROKEN              : Result := 'SM_BROKEN';
  // --- EVENT MANAGER
  IPS_EVENTMESSAGE          : Result := 'IPS_EVENTMESSAGE';
  EM_CREATE                 : Result := 'EM_CREATE';
  EM_DELETE                 : Result := 'EM_DELETE';
  EM_UPDATE                 : Result := 'EM_UPDATE';
  EM_CHANGEACTIVE           : Result := 'EM_CHANGEACTIVE';
  EM_CHANGELIMIT            : Result := 'EM_CHANGELIMIT';
  EM_CHANGESCRIPT           : Result := 'EM_CHANGESCRIPT';
  EM_CHANGETRIGGER          : Result := 'EM_CHANGETRIGGER';
  EM_CHANGETRIGGERVALUE     : Result := 'EM_CHANGETRIGGERVALUE';
  EM_CHANGETRIGGEREXECUTION : Result := 'EM_CHANGETRIGGEREXECUTION';
  EM_CHANGECYCLIC           : Result := 'EM_CHANGECYCLIC';
  EM_CHANGECYCLICDATEFROM  : Result := 'EM_CHANGECYCLICDATEFROM';
  EM_CHANGECYCLICDATETO    : Result := 'EM_CHANGECYCLICDATETO';
  EM_CHANGECYCLICTIMEFROM  : Result := 'EM_CHANGECYCLICTIMEFROM';
  EM_CHANGECYCLICTIMETO    : Result := 'EM_CHANGECYCLICTIMETO';
  // --- MEDIA MANAGER
  IPS_MEDIAMESSAGE       : Result := 'IPS_MEDIAMESSAGE';
  MM_CREATE              : Result := 'MM_CREATE';
  MM_DELETE              : Result := 'MM_DELETE';
  MM_CHANGEFILE          : Result := 'MM_CHANGEFILE';
  MM_AVAILABLE           : Result := 'MM_AVAILABLE';
  MM_UPDATE              : Result := 'MM_UPDATE';
  // --- LINK MANAGER
  IPS_LINKMESSAGE        : Result := 'IPS_LINKMESSAGE';
  LM_CREATE              : Result := 'LM_CREATE';
  LM_DELETE              : Result := 'LM_DELETE';
  LM_CHANGETARGET        : Result := 'LM_CHANGETARGET';
  // --- DATA HANDLER
  IPS_DATAMESSAGE        : Result := 'IPS_DATAMESSAGE';
  DM_CONNECT             : Result := 'DM_CONNECT';
  DM_DISCONNECT          : Result := 'DM_DISCONNECT';  
  // --- SCRIPT ENGINE
  IPS_ENGINEMESSAGE      : Result := 'IPS_ENGINEMESSAGE';
  SE_UPDATE              : Result := 'SE_UPDATE';
  SE_EXECUTE             : Result := 'SE_EXECUTE';
  SE_RUNNING             : Result := 'SE_RUNNING';
  // --- PROFILE POOL
  IPS_PROFILEMESSAGE     : Result := 'IPS_PROFILEMESSAGE';
  PM_CREATE              : Result := 'PM_CREATE';
  PM_DELETE              : Result := 'PM_DELETE';
  PM_CHANGETEXT          : Result := 'PM_CHANGETEXT';
  PM_CHANGEVALUES        : Result := 'PM_CHANGEVALUES';
  PM_CHANGEDIGITS        : Result := 'PM_CHANGEDIGITS';
  PM_CHANGEICON          : Result := 'PM_CHANGEICON';
  PM_ASSOCIATIONADDED    : Result := 'PM_ASSOCIATIONADDED';
  PM_ASSOCIATIONREMOVED  : Result := 'PM_ASSOCIATIONREMOVED';
  PM_ASSOCIATIONCHANGED  : Result := 'PM_ASSOCIATIONREMOVED';
  // --- TIMER POOL
  IPS_TIMERMESSAGE       : Result := 'IPS_TIMERMESSAGE';
  //TM_REGISTER            : Result := 'TM_REGISTER';
  //TM_UNREGISTER          : Result := 'TM_UNREGISTER';
  //TM_SETINTERVAL         : Result := 'TM_SETINTERVAL';
  //TM_UPDATE              : Result := 'TM_UPDATE';
  //TM_RUNNING             : Result := 'TM_RUNNING';
 else
  Result := 'unknown. id = ' + IntToStr(Message); 
 end;

end;


initialization
 RemClassRegistry.RegisterXSInfo(TypeInfo(TIPSID), 'urn:UIPSTypes', 'TIPSID');
 RemClassRegistry.RegisterXSInfo(TypeInfo(TInstanceID), 'urn:UIPSTypes', 'TInstanceID');

end.




