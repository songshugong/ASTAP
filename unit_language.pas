unit unit_language;

{ Runtime language support for ASTAP.

  English LFM text is the source of truth. Translations are loaded from the
  Lazarus-style PO file languages/zh_CN/astap.po and applied to open forms.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, ComCtrls, ExtCtrls, Forms, Menus, StdCtrls, TypInfo;

type
  TAppLanguage = (alEnglish, alChineseSimplified);

function LanguageCode(ALanguage: TAppLanguage): string;
function LanguageName(ALanguage: TAppLanguage): string;
function LanguageFromCode(const ACode: string): TAppLanguage;
procedure SetAppLanguage(ALanguage: TAppLanguage);
procedure SetAppLanguageCode(const ACode: string);
function GetAppLanguage: TAppLanguage;
function TranslateText(const AText: string): string;
procedure ApplyLanguageToForm(AForm: TCustomForm);
procedure ApplyLanguageToOpenForms;

implementation

uses
  SysUtils, StrUtils, LCLTranslator, LResources;

var
  CurrentLanguage: TAppLanguage = alChineseSimplified;
  BaseKeys: TStringList = nil;
  BaseValues: TStringList = nil;
  POKeys: TStringList = nil;
  POValues: TStringList = nil;
  POLoaded: Boolean = False;

function LanguageCode(ALanguage: TAppLanguage): string;
begin
  case ALanguage of
    alChineseSimplified: Result := 'zh_CN';
  else
    Result := 'en';
  end;
end;

function LanguageName(ALanguage: TAppLanguage): string;
begin
  case ALanguage of
    alChineseSimplified: Result := 'Chinese (Simplified)';
  else
    Result := 'English';
  end;
end;

function LanguageFromCode(const ACode: string): TAppLanguage;
var
  Code: string;
begin
  Code := LowerCase(StringReplace(ACode, '-', '_', [rfReplaceAll]));
  if (Code = 'zh') or (Code = 'zh_cn') or (Code = 'chinese') or
     (Code = 'chinese_simplified') then
    Result := alChineseSimplified
  else
    Result := alEnglish;
end;

procedure EnsureBaseStore;
begin
  if BaseKeys = nil then
  begin
    BaseKeys := TStringList.Create;
    BaseValues := TStringList.Create;
  end;
end;

function NormalizeCaption(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] = '&' then
    begin
      if (I < Length(S)) and (S[I + 1] = '&') then
      begin
        Result := Result + '&';
        Inc(I, 2);
      end
      else if (I > 1) and (I < Length(S)) and
              (S[I - 1] = ' ') and (S[I + 1] = ' ') then
      begin
        Result := Result + '&';
        Inc(I);
      end
      else
        Inc(I);
    end
    else
    begin
      Result := Result + S[I];
      Inc(I);
    end;
  end;
end;

function NormalizeTranslationKey(const S: string): string;
var
  Text: string;
begin
  Text := StringReplace(S, #13#10, #10, [rfReplaceAll]);
  Text := StringReplace(Text, #13, #10, [rfReplaceAll]);
  Result := LowerCase(TrimRight(NormalizeCaption(Text)));
end;

function DecodePOString(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if S[I] = '\' then
    begin
      Inc(I);
      if I > Length(S) then Break;
      case S[I] of
        'n': Result := Result + LineEnding;
        'r': ;
        't': Result := Result + #9;
        '\': Result := Result + '\';
        '"': Result := Result + '"';
      else
        Result := Result + S[I];
      end;
    end
    else
      Result := Result + S[I];
    Inc(I);
  end;
end;

function ReadPOQuoted(const LineText: string): string;
var
  FirstQuote, LastQuote: Integer;
begin
  Result := '';
  FirstQuote := Pos('"', LineText);
  LastQuote := RPos('"', LineText);
  if (FirstQuote <= 0) or (LastQuote <= FirstQuote) then Exit;
  Result := DecodePOString(Copy(LineText, FirstQuote + 1,
                                LastQuote - FirstQuote - 1));
end;

procedure AddTranslation(const AKey, AValue: string);
var
  KeyText, ValueText: string;
begin
  if (AKey = '') or (AValue = '') then Exit;

  ValueText := StringReplace(AValue, #10, LineEnding, [rfReplaceAll]);

  KeyText := NormalizeTranslationKey(AKey);
  if POKeys.IndexOf(KeyText) < 0 then
  begin
    POKeys.Add(KeyText);
    POValues.Add(ValueText);
  end;
end;

function LanguagesDirectory: string;
var
  ExeDir: string;
begin
  ExeDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  Result := ExpandFileName(ExeDir + '..' + DirectorySeparator + 'Resources' +
                            DirectorySeparator + 'languages' + DirectorySeparator);
  if DirectoryExists(Result) then Exit;

  Result := ExpandFileName(ExeDir + 'languages' + DirectorySeparator);
  if DirectoryExists(Result) then Exit;

  Result := ExpandFileName(ExeDir + '..' + DirectorySeparator + 'languages' +
                            DirectorySeparator);
  if DirectoryExists(Result) then Exit;

  Result := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(Application.Location)) +
                            'languages' + DirectorySeparator);
end;

function POFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(LanguagesDirectory) +
            'zh_CN' + DirectorySeparator + 'astap.po';
end;

procedure CommitPOEntry(const AMsgID, AMsgStr: string);
begin
  if AMsgID <> '' then
    AddTranslation(AMsgID, AMsgStr);
end;

procedure EnsurePOTranslations;
var
  Lines: TStringList;
  I, State: Integer;
  LineText, TrimmedText, MsgID, MsgStr, FileName: string;
begin
  if POLoaded then Exit;
  POLoaded := True;

  FreeAndNil(POKeys);
  FreeAndNil(POValues);
  POKeys := TStringList.Create;
  POValues := TStringList.Create;

  FileName := POFileName;
  if not FileExists(FileName) then Exit;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    State := 0;
    MsgID := '';
    MsgStr := '';

    for I := 0 to Lines.Count - 1 do
    begin
      LineText := Lines[I];
      TrimmedText := Trim(LineText);
      if TrimmedText = '' then Continue;
      if TrimmedText[1] = '#' then Continue;

      if StartsStr('msgid ', TrimmedText) then
      begin
        CommitPOEntry(MsgID, MsgStr);
        MsgID := ReadPOQuoted(TrimmedText);
        MsgStr := '';
        State := 1;
      end
      else if StartsStr('msgstr ', TrimmedText) then
      begin
        MsgStr := ReadPOQuoted(TrimmedText);
        State := 2;
      end
      else if TrimmedText[1] = '"' then
      begin
        case State of
          1: MsgID := MsgID + ReadPOQuoted(TrimmedText);
          2: MsgStr := MsgStr + ReadPOQuoted(TrimmedText);
        end;
      end;
    end;

    CommitPOEntry(MsgID, MsgStr);
  finally
    Lines.Free;
  end;
end;

procedure RefreshLazarusTranslator(ALanguage: TAppLanguage);
begin
  if Assigned(LRSTranslator) then
    FreeAndNil(LRSTranslator);

  if ALanguage = alChineseSimplified then
  begin
    { Let Lazarus load resource strings from the same PO family, but keep UI
      string-property replacement under our control so English can be restored
      reliably from the captured base text. }
    SetDefaultLang(LanguageCode(ALanguage), LanguagesDirectory, 'astap', False);
    if Assigned(LRSTranslator) then
      FreeAndNil(LRSTranslator);
  end;
end;

procedure SetAppLanguage(ALanguage: TAppLanguage);
begin
  CurrentLanguage := ALanguage;
  if CurrentLanguage = alChineseSimplified then
    EnsurePOTranslations;
  RefreshLazarusTranslator(CurrentLanguage);
end;

procedure SetAppLanguageCode(const ACode: string);
begin
  SetAppLanguage(LanguageFromCode(ACode));
end;

function GetAppLanguage: TAppLanguage;
begin
  Result := CurrentLanguage;
end;

function LookupPOTranslation(const AKey: string; out ATranslation: string): Boolean;
var
  Index: Integer;
begin
  EnsurePOTranslations;
  Index := POKeys.IndexOf(NormalizeTranslationKey(AKey));

  Result := Index >= 0;
  if Result then
    ATranslation := POValues[Index]
  else
    ATranslation := AKey;
end;

function SplitTrailingSuffix(const AKey: string; out ABase, ASuffix: string): Boolean;
var
  P: Integer;
begin
  Result := False;
  ABase := '';
  ASuffix := '';
  P := RPos('(', AKey);
  if P <= 1 then Exit;
  if AKey[Length(AKey)] <> ')' then Exit;

  ABase := TrimRight(Copy(AKey, 1, P - 1));
  ASuffix := TrimLeft(Copy(AKey, P, MaxInt));
  Result := (ABase <> '') and (ASuffix <> '');
end;

function FindChineseTranslation(const AText: string; out ATranslation: string): Boolean;
var
  Key, BaseText, SuffixText: string;
begin
  Key := TrimRight(NormalizeCaption(AText));
  if LookupPOTranslation(Key, ATranslation) then
    Exit(True);

  if SplitTrailingSuffix(Key, BaseText, SuffixText) and
     LookupPOTranslation(BaseText, ATranslation) then
  begin
    ATranslation := ATranslation + ' ' + SuffixText;
    Exit(True);
  end;

  ATranslation := AText;
  Result := False;
end;

function TranslateText(const AText: string): string;
begin
  case CurrentLanguage of
    alChineseSimplified:
      if not FindChineseTranslation(AText, Result) then
        Result := AText;
  else
    Result := AText;
  end;
end;

procedure RememberBaseText(const Key, Value: string);
begin
  EnsureBaseStore;
  if BaseKeys.IndexOf(Key) < 0 then
  begin
    BaseKeys.Add(Key);
    BaseValues.Add(Value);
  end;
end;

function GetBaseText(const Key, Fallback: string): string;
var
  Index: Integer;
begin
  EnsureBaseStore;
  Index := BaseKeys.IndexOf(Key);
  if Index >= 0 then
    Result := BaseValues[Index]
  else
    Result := Fallback;
end;

function IsStringProperty(AObject: TObject; const AProperty: string): Boolean;
var
  PropInfo: PPropInfo;
begin
  if AObject.ClassInfo = nil then Exit(False);
  PropInfo := GetPropInfo(AObject.ClassInfo, AProperty);
  Result := Assigned(PropInfo) and
            (PropInfo^.PropType^.Kind in [tkSString, tkLString, tkAString,
                                           tkWString, tkUString]);
end;

procedure ApplyStringPropertyByKey(const Key: string; AObject: TObject;
  const AProperty: string);
var
  Original: string;
begin
  if AObject = nil then Exit;
  if not IsStringProperty(AObject, AProperty) then Exit;

  RememberBaseText(Key, GetStrProp(AObject, AProperty));
  Original := GetBaseText(Key, GetStrProp(AObject, AProperty));

  if (AObject is TComponent) and
     ((AProperty = 'Caption') or (AProperty = 'Text')) and
     (Original = TComponent(AObject).Name) then
    Exit;

  if CurrentLanguage = alChineseSimplified then
    SetStrProp(AObject, AProperty, TranslateText(Original))
  else
    SetStrProp(AObject, AProperty, Original);
end;

procedure ApplyStringProperty(AForm: TCustomForm; AComponent: TComponent;
  const AProperty: string);
begin
  if (AComponent = nil) or (AComponent.Name = '') then Exit;
  ApplyStringPropertyByKey(AForm.Name + '.' + AComponent.Name + '.' + AProperty,
                           AComponent, AProperty);
end;

procedure ApplyFormCaption(AForm: TCustomForm);
var
  Key, Original: string;
begin
  if (AForm = nil) or (AForm.Name = '') then Exit;
  Key := AForm.Name + '.Caption';
  RememberBaseText(Key, AForm.Caption);
  Original := GetBaseText(Key, AForm.Caption);
  if CurrentLanguage = alChineseSimplified then
    AForm.Caption := TranslateText(Original)
  else
    AForm.Caption := Original;
end;

procedure ApplyStrings(const AKeyPrefix: string; AStrings: TStrings);
var
  I: Integer;
  Key, Original: string;
begin
  if AStrings = nil then Exit;
  AStrings.BeginUpdate;
  try
    for I := 0 to AStrings.Count - 1 do
    begin
      Key := AKeyPrefix + '.Item' + IntToStr(I);
      RememberBaseText(Key, AStrings[I]);
      Original := GetBaseText(Key, AStrings[I]);
      if CurrentLanguage = alChineseSimplified then
        AStrings[I] := TranslateText(Original)
      else
        AStrings[I] := Original;
    end;
  finally
    AStrings.EndUpdate;
  end;
end;

procedure ApplyListViewColumns(AForm: TCustomForm; AComponent: TComponent);
var
  I: Integer;
  Key: string;
  ListView: TListView;
begin
  if not (AComponent is TListView) then Exit;

  ListView := TListView(AComponent);
  for I := 0 to ListView.Columns.Count - 1 do
  begin
    Key := AForm.Name + '.' + AComponent.Name + '.Column' + IntToStr(I);
    ApplyStringPropertyByKey(Key, ListView.Columns[I], 'Caption');
  end;
end;

procedure ApplyComponentItems(AForm: TCustomForm; AComponent: TComponent);
var
  ComboIndex: Integer;
begin
  if (AForm = nil) or (AComponent = nil) or (AComponent.Name = '') then Exit;

  if AComponent is TComboBox then
  begin
    if TComboBox(AComponent).Sorted then Exit;
    ComboIndex := TComboBox(AComponent).ItemIndex;
    ApplyStrings(AForm.Name + '.' + AComponent.Name + '.Items',
                 TComboBox(AComponent).Items);
    if (ComboIndex >= 0) and (ComboIndex < TComboBox(AComponent).Items.Count) then
      TComboBox(AComponent).ItemIndex := ComboIndex;
  end
  else if AComponent is TListBox then
  begin
    if TListBox(AComponent).Sorted then Exit;
    ApplyStrings(AForm.Name + '.' + AComponent.Name + '.Items',
                 TListBox(AComponent).Items);
  end
  else if AComponent is TRadioGroup then
    ApplyStrings(AForm.Name + '.' + AComponent.Name + '.Items',
                 TRadioGroup(AComponent).Items);
end;

procedure ApplyMenuItemLanguage(AForm: TCustomForm; AItem: TMenuItem;
  const APath: string);
var
  I: Integer;
  ItemPath: string;
begin
  if AItem = nil then Exit;

  ItemPath := APath;
  if AItem.Name <> '' then
    ItemPath := AForm.Name + '.' + AItem.Name;

  ApplyStringPropertyByKey(ItemPath + '.Caption', AItem, 'Caption');
  ApplyStringPropertyByKey(ItemPath + '.Hint', AItem, 'Hint');

  for I := 0 to AItem.Count - 1 do
    ApplyMenuItemLanguage(AForm, AItem.Items[I], ItemPath + '.Item' + IntToStr(I));
end;

procedure ApplyMenuLanguage(AForm: TCustomForm; AComponent: TComponent);
begin
  if not (AComponent is TMenu) then Exit;
  ApplyMenuItemLanguage(AForm, TMenu(AComponent).Items,
                        AForm.Name + '.' + AComponent.Name + '.Items');
end;

procedure ApplyComponentLanguage(AForm: TCustomForm; AComponent: TComponent);
begin
  if AComponent is TMenuItem then Exit;
  ApplyStringProperty(AForm, AComponent, 'Caption');
  ApplyStringProperty(AForm, AComponent, 'Hint');
  ApplyStringProperty(AForm, AComponent, 'Text');
  ApplyComponentItems(AForm, AComponent);
  ApplyListViewColumns(AForm, AComponent);
  ApplyMenuLanguage(AForm, AComponent);
end;

procedure ApplyLanguageToForm(AForm: TCustomForm);
var
  I: Integer;
begin
  if AForm = nil then Exit;
  ApplyFormCaption(AForm);
  for I := 0 to AForm.ComponentCount - 1 do
    ApplyComponentLanguage(AForm, AForm.Components[I]);
end;

procedure ApplyLanguageToOpenForms;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
    ApplyLanguageToForm(Screen.Forms[I]);
end;

initialization

finalization
  if Assigned(LRSTranslator) then
    FreeAndNil(LRSTranslator);
  FreeAndNil(BaseKeys);
  FreeAndNil(BaseValues);
  FreeAndNil(POKeys);
  FreeAndNil(POValues);

end.
