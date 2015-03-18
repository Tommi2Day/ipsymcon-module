unit RTTIUnit;

{ Don't forget to check out Danny Thorpe's
  book for much more info on RTTI:

  Delphi Component Design, Addison-Wesley, 1996 }

{$ifdef Ver80} { Delphi 1.0x }
  {$define DelphiLessThan3}
{$endif}
{$ifdef Ver90} { Delphi 2.0x }
  {$define DelphiLessThan3}
{$endif}
{$ifdef Ver93} { C++ Builder 1.0x }
  {$define DelphiLessThan3}
{$endif}

interface

uses
  SysUtils;

procedure SetDefaults(Obj: TObject);

procedure CopyObject(ObjFrom, ObjTo: TObject);

procedure ReadProp(Obj: TObject; const PropName: String);
procedure ReadProps(Obj: TObject; const PropNames: array of String);

procedure WriteProp(Obj: TObject; const PropName: String);
procedure WriteProps(Obj: TObject; const PropNames: array of String);

function GetImplementingObject(const I: IInterface): TObject; 

type
  EPropertyError = class(Exception);

implementation

uses
{$ifdef Windows}
  IniFiles,
{$else}
  Registry,
{$endif}
  TypInfo, Forms;

const
  NoDefault = -MaxLongint-1;
  tkPropsWithDefault = [tkInteger, tkChar, tkSet, tkEnumeration];

function GetImplementingObject(const I: IInterface): TObject; 
const   
  AddByte = $04244483;  
  AddLong = $04244481;  
type   
  PAdjustSelfThunk = ^TAdjustSelfThunk;   
  TAdjustSelfThunk = packed record
    case AddInstruction: longint of       
      AddByte : (AdjustmentByte: shortint);       
      AddLong : (AdjustmentLong: longint);   
    end;   
  PInterfaceMT = ^TInterfaceMT;   
  TInterfaceMT = packed record     
    QueryInterfaceThunk: PAdjustSelfThunk;   
  end;   
  TInterfaceRef = ^PInterfaceMT; 
var   
  QueryInterfaceThunk: PAdjustSelfThunk; 
begin   
  Result := Pointer(I);   
  if Assigned(Result) then     
    try       
      QueryInterfaceThunk := TInterfaceRef(I)^.QueryInterfaceThunk;       
      case QueryInterfaceThunk.AddInstruction of         
        AddByte: Inc(PChar(Result), QueryInterfaceThunk.AdjustmentByte);         
        AddLong: Inc(PChar(Result), QueryInterfaceThunk.AdjustmentLong);         
      else     
        Result := nil;       
      end;     
    except       
      Result := nil;     
    end; 
end;  

procedure SetDefaults(Obj: TObject);
var
  PropInfos: PPropList;
  Count, Loop: Integer;
begin
  { Find out how many properties we'll be considering }
  Count := GetPropList(Obj.ClassInfo, tkPropsWithDefault, nil);
  { Allocate memory to hold their RTTI data }
  GetMem(PropInfos, Count * SizeOf(PPropInfo));
  try
    { Get hold of the property list in our new buffer }
    GetPropList(Obj.ClassInfo, tkPropsWithDefault, PropInfos);
    { Loop through all the selected properties }
    for Loop := 0 to Count - 1 do
      with PropInfos^[Loop]^ do
        { If there is supposed to be a default value... }
        if Default <> NoDefault then
          { ...then jolly well set it }
          SetOrdProp(Obj, PropInfos^[Loop], Default)
  finally
    FreeMem(PropInfos, Count * SizeOf(PPropInfo));
  end;
end;

procedure CopyObject(ObjFrom, ObjTo: TObject);
var
  PropInfos: PPropList;
  PropInfo: PPropInfo;
  Count, Loop: Integer;
  OrdVal: Longint;
  StrVal: String;
  FloatVal: Extended;
  MethodVal: TMethod;
begin
  if ObjFrom = nil then
   exit;
  { Iterate thru all published fields and properties of source }
  { copying them to target }

  { Find out how many properties we'll be considering }
  Count := GetPropList(ObjFrom.ClassInfo, tkAny, nil);
  { Allocate memory to hold their RTTI data }
  GetMem(PropInfos, Count * SizeOf(PPropInfo));
  try
    { Get hold of the property list in our new buffer }
    GetPropList(ObjFrom.ClassInfo, tkAny, PropInfos);
    { Loop through all the selected properties }
    for Loop := 0 to Count - 1 do
    begin
      PropInfo := GetPropInfo(ObjTo.ClassInfo, PropInfos^[Loop]^.Name);
      { Check the general type of the property }
      { and read/write it in an appropriate way }
      case PropInfos^[Loop]^.PropType^.Kind of
        tkClass:
        begin
         CopyObject(TObject(GetOrdProp(ObjFrom, PropInfos^[Loop])), TObject(GetOrdProp(ObjTo, PropInfo)));
        end;
        tkInteger, tkChar, tkEnumeration,
        tkSet{$ifdef Win32}, tkWChar{$endif}:
        begin
          OrdVal := GetOrdProp(ObjFrom, PropInfos^[Loop]);
          if Assigned(PropInfo) then
            SetOrdProp(ObjTo, PropInfo, OrdVal);
        end;
        tkFloat:
        begin
          FloatVal := GetFloatProp(ObjFrom, PropInfos^[Loop]);
          if Assigned(PropInfo) then
            SetFloatProp(ObjTo, PropInfo, FloatVal);
        end;
        {$ifndef DelphiLessThan3}
        tkWString,
        {$endif}
        {$ifdef Win32}
        tkLString,
        {$endif}
        tkString:
        begin
          (*
          { Avoid copying 'Name' - components must have unique names }
          if UpperCase(PropInfos^[Loop]^.Name) = 'NAME' then
            Continue;
          *)
          StrVal := GetStrProp(ObjFrom, PropInfos^[Loop]);
          if Assigned(PropInfo) then
            SetStrProp(ObjTo, PropInfo, StrVal);
        end;
        tkMethod:
        begin
          MethodVal := GetMethodProp(ObjFrom, PropInfos^[Loop]);
          if Assigned(PropInfo) then
            SetMethodProp(ObjTo, PropInfo, MethodVal);
        end;
        tkDynArray:
        begin
         //raise Exception.Create('Could not clone DynArray');  
        end; 
      end
    end
  finally
    FreeMem(PropInfos, Count * SizeOf(PPropInfo));
  end;
end;

var
  Ini: {$ifdef Windows}TIniFile{$else}TRegIniFile{$endif};

const
  Section = 'Property Values';

procedure ReadProp(Obj: TObject; const PropName: String);
var
  Prop: PPropInfo;
begin
  Prop := GetPropInfo(Obj.ClassInfo, PropName);
  if not Assigned(Prop) then
    raise EPropertyError.CreateFmt(
      'Property %s not found in %s class', [PropName, Obj.ClassName]);
  with Prop^ do
    { For each case, read a value from the registry, using }
    { the current value as the default, then use that read }
    { value to set the property }
    case PropType^.Kind of
      {$ifndef DelphiLessThan3}
      tkWString,
      {$endif}
      {$ifdef Win32}
      tkLString,
      {$endif}
      tkString:
        SetStrProp(Obj, Prop,
          Ini.ReadString(Section, PropName, GetStrProp(Obj, Prop)));
      tkInteger, tkChar, tkSet{$ifdef Win32}, tkWChar{$endif}:
        SetOrdProp(Obj, Prop,
          Ini.ReadInteger(Section, PropName, GetOrdProp(Obj, Prop)));
      tkFloat:
        SetFloatProp(Obj, Prop, StrToFloat(
          Ini.ReadString(Section, PropName,
            FloatToStr(GetFloatProp(Obj, Prop)))));
      { Enums are written out as strings }
      tkEnumeration:
        SetOrdProp(Obj, Prop,
          GetEnumValue(
            Prop^.PropType{$ifndef Windows}^{$endif},
            Ini.ReadString(Section, PropName,
              GetEnumName(Prop^.PropType{$ifndef Windows}^{$endif},
                GetOrdProp(Obj, Prop)){$ifdef Windows}^{$endif})));
    end
end;

procedure ReadProps(Obj: TObject; const PropNames: array of String);
var
  Loop: Integer;
begin
  for Loop := Low(PropNames) to High(PropNames) do
    ReadProp(Obj, PropNames[Loop])
end;

procedure WriteProp(Obj: TObject; const PropName: String);
var
  Prop: PPropInfo;
begin
  Prop := GetPropInfo(Obj.ClassInfo, PropName);
  if not Assigned(Prop) then
    raise EPropertyError.CreateFmt(
      'Property %s not found in %s class', [PropName, Obj.ClassName]);
  //For each case, write the property value to the registry
  with Prop^ do
    case PropType^.Kind of
      {$ifndef DelphiLessThan3}
      tkWString,
      {$endif}
      {$ifdef Win32}
      tkLString,
      {$endif}
      tkString:
        Ini.WriteString(Section, PropName, GetStrProp(Obj, Prop));
      tkInteger, tkChar, tkSet{$ifdef Win32}, tkWChar{$endif}:
        Ini.WriteInteger(Section, PropName, GetOrdProp(Obj, Prop));
      tkFloat:
        Ini.WriteString(Section, PropName,
          FloatToStr(GetFloatProp(Obj, Prop)));
      tkEnumeration:
        Ini.WriteString(Section, PropName,
          GetEnumName(Prop^.PropType{$ifndef Windows}^{$endif},
            GetOrdProp(Obj, Prop)){$ifdef Windows}^{$endif});
    end
end;

procedure WriteProps(Obj: TObject; const PropNames: array of String);
var
  Loop: Integer;
begin
  for Loop := Low(PropNames) to High(PropNames) do
    WriteProp(Obj, PropNames[Loop])
end;

procedure ExitProc; far;
begin
  Ini.Free;
end;

initialization
  { Delphi 1 does not support the finalization section }
  { so we use an exit procedure instead }
  { However Delphi 3 packages are not compatible with }
  { exit routines so we make sure to use }
  { finalization sections in 32-bit }
{$ifdef Windows}
  AddExitProc(ExitProc);
  Ini := TIniFile.Create(
    Copy(Application.ExeName, 1,
      Length(Application.ExeName) - 3) + 'INI');
{$else}
  Ini := TRegIniFile.Create('Software\Oblong\Property Saver');
finalization
  ExitProc
{$endif}
end.
