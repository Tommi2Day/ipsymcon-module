
{*******************************************************}
{                                                       }
{       Utils Class for SkyLIX                          }
{                                                       }
{       Copyright (c) 2003 Paresy & Pikachu             }
{                                                       }
{       v. 0.1.0.0 @ 27.05.03                           }
{                                                       }
{*******************************************************}

{$IOCHECKS ON}
                           
unit UUtils;

interface uses Windows, StrUtils, SysUtils, Classes;

type
 TStrArray = Array of String;

 // wonderful cut function by me :)
 function CutText(var inStr: String; sStr: String; before: Boolean): Boolean;
 function GetText(var inStr: String; sStr: String; var sOutput: String): Boolean;
 function TextBetween(var inStr: String; argA, argB: String; var sOutput: String): Boolean;
 function MatchStrings(Source, pattern: string): Boolean; 
 function PassFilter(filename, filter: String; var DoAllow: Boolean): Boolean;
 function PassFilters(filename: String; rules: TStrings; var reason: String): Boolean;
 function ExplodeText(inStr: String; sStr: String; var items: TStrArray): Integer;
 function GetChunk(var inStr: String; sLen: Integer; var sChunk: String): Boolean;
 function StripHTML(S: string): string;
implementation

function StripHTML(S: string): string;
var
  TagBegin, TagEnd, TagLength: integer;
begin
  TagBegin := Pos( '<', S);      // search position of first < 

  while (TagBegin > 0) do begin  // while there is a < in S
    TagEnd := Pos('>', S);              // find the matching >
    if TagEnd = 0 then
     break; 
    TagLength := TagEnd - TagBegin + 1;
    Delete(S, TagBegin, TagLength);     // delete the tag 
    TagBegin:= Pos( '<', S);            // search for next <
  end;
  
  Result := S;                   // give the result
end;

function CutText(var inStr: String; sStr: String; before: Boolean): Boolean;
var fPos: Integer;
begin

 fPos := pos(sStr, inStr);

 if fPos > 0 then
  begin
   if before then
    delete(inStr, 1, fPos+length(sStr)-1)
   else
    delete(inStr, fPos, length(inStr));

   Result := True;
  end
 else
  Result := False;

end;

function GetText(var inStr: String; sStr: String; var sOutput: String): Boolean;
var fPos: Integer;
begin

 fPos := pos(sStr, inStr);

 if fPos > 0 then
  begin
   sOutput := LeftStr(inStr, fPos-1);
   Delete(inStr, 1, fPos+length(sStr)-1);

   Result := True;
  end
 else
  begin
   sOutput := '';
   Result := False;
  end;

end;

function TextBetween(var inStr: String; argA, argB: String; var sOutput: String): Boolean;
var savebuffer: String;
begin

Result := False;

savebuffer := inStr;

if CutText(saveBuffer, argA, True) then
 if GetText(saveBuffer, argB, sOutput) then
  begin
   inStr := saveBuffer;
   Result := True;
  end;

end;

function MatchStrings(Source, pattern: string): Boolean;
var
  pSource: array [0..255] of Char;
  pPattern: array [0..255] of Char;

  function MatchPattern(element, pattern: PChar): Boolean;

    function IsPatternWild(pattern: PChar): Boolean;
    begin
      Result := StrScan(pattern, '*') <> nil;
      if not Result then Result := StrScan(pattern, '?') <> nil; 
    end;
  begin
    if 0 = StrComp(pattern, '*') then
      Result := True
    else if (element^ = Chr(0)) and (pattern^ <> Chr(0)) then
      Result := False
    else if element^ = Chr(0) then
      Result := True
    else
    begin
      case pattern^ of
        '*': if MatchPattern(element, @pattern[1]) then
            Result := True
          else
            Result := MatchPattern(@element[1], pattern);
          '?': Result := MatchPattern(@element[1], @pattern[1]);
        else
          if element^ = pattern^ then
            Result := MatchPattern(@element[1], @pattern[1])
          else
            Result := False;
      end; 
    end;
  end;
begin
  StrPCopy(pSource, Source);
  StrPCopy(pPattern, pattern);
  Result := MatchPattern(pSource, pPattern);
end;

function PassFilter(filename, filter: String; var DoAllow: Boolean): Boolean;
var fPattern, fSize, fSizeType, fType: String;
    fFSize: LongInt;
    fFile: file of Byte;
begin

 Result := False;

 // filter = '*;>0;A';

 GetText(filter, ';', fPattern);
 GetText(filter, ';', fSize);
 fType := filter;

 //kill case sensitive
 fPattern := LowerCase(fPattern);

 if fPattern = '' then
  fPattern := '*';

 fSizeType := LeftStr(fSize, 1);
 Delete(fSize, 1, 1);

 if fType = 'A' then
  DoAllow := True
 else
  DoAllow := False;

{I-}
 try
  AssignFile(fFile, filename);
  Reset(fFile);
  fFSize := FileSize(fFile);
 finally
  CloseFile(fFile);
 end;
{I+} 

 //paths
 filename := LowerCase(ExtractFileName(filename));

 if not Matchstrings(filename, fPattern) then
  exit;

 if fSizeType = '>' then
  begin
   if fFSize <= StrToInt(fSize) then
    exit;
  end
 else if fSizeType = '<' then
  begin
   if fFSize >= StrToInt(fSize) then
    exit;
  end
 else
  exit;

 Result := True;

end;

function PassFilters(filename: String; rules: TStrings; var reason: String): Boolean;
var rback: Boolean;
    i: Integer;
begin

  Result := False;

  if not FileExists(filename) then
   begin
    reason := 'FILE NOT FOUND!';
    exit;
   end;

  if rules.Count > 0 then
   for i:=0 to rules.Count-1 do
    if Trim(rules[i]) <> '' then
     if PassFilter(filename, Trim(rules[i]), rback) then
      begin
       Result := rback;
       if rback then
        reason := 'ACCEPTED at Rule #'+IntToStr(i+1) + ' ( ' + Trim(rules[i]) + ' )'
       else
        reason := 'DENIED at Rule #'+IntToStr(i+1) + ' ( ' + Trim(rules[i]) + ' )';

       exit;
      end;

   reason := 'DENIED as NO RULE applied';

end;

function ExplodeText(inStr: String; sStr: String; var items: TStrArray): Integer;
begin

 Result := 0;
 SetLength(items, Result+1);

 while GetText(inStr, sStr, items[Result]) do
  begin
   Inc(Result);
   SetLength(items, Result+1);
  end;
 items[Result] := inStr;
 Inc(Result);

end;

function GetChunk(var inStr: String; sLen: Integer; var sChunk: String): Boolean;
begin

 Result := False;
 if Length(inStr) <= 0 then
  exit;

 sChunk := LeftStr(inStr, sLen);
 Delete(inStr, 1, sLen);
 Result := True;
 
end;


end.
 