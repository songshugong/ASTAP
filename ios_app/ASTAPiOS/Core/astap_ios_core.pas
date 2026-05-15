library astap_ios_core;
{C ABI bridge for the iOS prototype. It reuses the ASTAP command-line solver
 units in-process so the UIKit app does not try to execute a bundled CLI.}

{$mode objfpc}{$H+}

uses
  ctypes, SysUtils, Classes, Math,
  unit_command_line_general,
  unit_command_line_solving;

function JsonEscape(const s: string): string;
var
  i: integer;
  ch: char;
begin
  result := '';
  for i := 1 to Length(s) do
  begin
    ch := s[i];
    case ch of
      '"': result := result + '\"';
      '\': result := result + '\\';
      #8: result := result + '\b';
      #9: result := result + '\t';
      #10: result := result + '\n';
      #12: result := result + '\f';
      #13: result := result + '\r';
      #0..#7, #11, #14..#31:
        result := result + '\u' + IntToHex(Ord(ch), 4);
    else
      result := result + ch;
    end;
  end;
end;

function JsonString(const key, value: string): string;
begin
  result := '"' + key + '":"' + JsonEscape(value) + '"';
end;

function JsonNumber(const key, value: string): string;
begin
  result := '"' + key + '":' + value;
end;

function JsonFloatNumber(const key: string; value: double; decimals: integer): string;
var
  fs: TFormatSettings;
begin
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := '.';
  result := JsonNumber(key, FloatToStrF(value, ffFixed, 18, decimals, fs));
end;

function JsonBool(const key: string; value: boolean): string;
begin
  if value then
    result := '"' + key + '":true'
  else
    result := '"' + key + '":false';
end;

function JsonArrayFromStrings(const key: string; list: TStrings): string;
var
  i: integer;
begin
  result := '"' + key + '":[';
  if list <> nil then
    for i := 0 to list.Count - 1 do
    begin
      if i > 0 then result := result + ',';
      result := result + '"' + JsonEscape(list[i]) + '"';
    end;
  result := result + ']';
end;

function ReturnCString(const s: string): PChar;
begin
  result := StrAlloc(Length(s) + 1);
  StrPCopy(result, s);
end;

function SafeString(p: PChar): string;
begin
  if p = nil then result := '' else result := StrPas(p);
end;

function IncludeSlash(const path: string): string;
begin
  if path = '' then
    result := ''
  else
    result := IncludeTrailingPathDelimiter(path);
end;

function ExtractJsonString(const json, key, defaultValue: string): string;
var
  needle: string;
  startPos, endPos: integer;
begin
  result := defaultValue;
  needle := '"' + key + '"';
  startPos := Pos(needle, json);
  if startPos = 0 then exit;
  startPos := Pos(':', Copy(json, startPos + Length(needle), MaxInt));
  if startPos = 0 then exit;
  startPos := Pos(needle, json) + Length(needle) + startPos;
  while (startPos <= Length(json)) and (json[startPos] in [' ', #9, #10, #13]) do Inc(startPos);
  if (startPos > Length(json)) or (json[startPos] <> '"') then exit;
  Inc(startPos);
  endPos := startPos;
  while endPos <= Length(json) do
  begin
    if (json[endPos] = '"') and ((endPos = startPos) or (json[endPos - 1] <> '\')) then break;
    Inc(endPos);
  end;
  if endPos <= Length(json) then
    result := Copy(json, startPos, endPos - startPos);
end;

function ExtractJsonNumber(const json, key, defaultValue: string): string;
var
  needle: string;
  startPos, endPos: integer;
begin
  result := defaultValue;
  needle := '"' + key + '"';
  startPos := Pos(needle, json);
  if startPos = 0 then exit;
  startPos := Pos(':', Copy(json, startPos + Length(needle), MaxInt));
  if startPos = 0 then exit;
  startPos := Pos(needle, json) + Length(needle) + startPos;
  while (startPos <= Length(json)) and (json[startPos] in [' ', #9, #10, #13]) do Inc(startPos);
  endPos := startPos;
  while (endPos <= Length(json)) and (json[endPos] in ['0'..'9', '.', '-', '+']) do Inc(endPos);
  if endPos > startPos then result := Copy(json, startPos, endPos - startPos);
end;

procedure EnsureLists;
begin
  if memo1 = nil then memo1 := TStringList.Create;
  if memo2 = nil then memo2 := TStringList.Create;
end;

procedure ResetCoreState(const inputPath, databaseDir: string);
begin
  EnsureLists;
  memo1.Clear;
  memo2.Clear;

  astap_version := '2026.04.21';
  filename2 := inputPath;
  database_path := IncludeSlash(databaseDir);
  star_database1 := 'auto';
  search_fov1 := '0';
  radius_search1 := '180';
  max_stars := 500;
  quad_tolerance1 := '0.007';
  min_star_size1 := '1.5';
  downsample_for_solving1 := 0;
  force_oversize1 := false;
  check_pattern_filter1 := false;
  add_sip1 := false;
  commandline_log := false;
  solve_show_log := true;
  errorlevel := 0;
  warning_str := '';
  fov_specified := false;
  esc_pressed := false;
end;

function WidthOfLoadedImage: integer;
begin
  if (Length(img_loaded) > 0) and (Length(img_loaded[0]) > 0) then
    result := Length(img_loaded[0, 0])
  else
    result := 0;
end;

function HeightOfLoadedImage: integer;
begin
  if (Length(img_loaded) > 0) then
    result := Length(img_loaded[0])
  else
    result := 0;
end;

function BuildJson(ok, solved: boolean; errorCode: integer; const message: string): string;
begin
  result := '{' +
    JsonBool('ok', ok) + ',' +
    JsonNumber('errorCode', IntToStr(errorCode)) + ',' +
    JsonString('message', message) + ',' +
    JsonArrayFromStrings('headerLines', memo1) + ',' +
    JsonNumber('imageWidth', IntToStr(WidthOfLoadedImage)) + ',' +
    JsonNumber('imageHeight', IntToStr(HeightOfLoadedImage)) + ',' +
    JsonBool('solved', solved) + ',' +
    JsonFloatNumber('raDeg', ra0 * 180 / Pi, 8) + ',' +
    JsonFloatNumber('decDeg', dec0 * 180 / Pi, 8) + ',' +
    JsonFloatNumber('scaleArcsecPerPixel', Abs(cdelt2) * 3600, 4) + ',' +
    JsonFloatNumber('rotationDeg', crota2, 4) + ',' +
    JsonArrayFromStrings('logLines', memo2) +
    '}';
end;

procedure ApplySolveOptions(const optionsJson: string);
var
  s: string;
begin
  star_database1 := ExtractJsonString(optionsJson, 'database', 'auto');
  radius_search1 := ExtractJsonNumber(optionsJson, 'radiusDeg', radius_search1);
  quad_tolerance1 := ExtractJsonNumber(optionsJson, 'tolerance', quad_tolerance1);
  min_star_size1 := ExtractJsonNumber(optionsJson, 'minStarArcsec', min_star_size1);

  s := ExtractJsonNumber(optionsJson, 'fovDeg', '0');
  if s <> '0' then
  begin
    search_fov1 := s;
    fov_specified := true;
  end;

  s := ExtractJsonNumber(optionsJson, 'raHours', '');
  if s <> '' then ra0 := strtofloat2(s) * Pi / 12;

  s := ExtractJsonNumber(optionsJson, 'spdDeg', '');
  if s <> '' then dec0 := (strtofloat2(s) - 90) * Pi / 180;

  s := ExtractJsonNumber(optionsJson, 'maxStars', '');
  if s <> '' then max_stars := StrToIntDef(s, max_stars);

  s := ExtractJsonNumber(optionsJson, 'downsample', '');
  if s <> '' then downsample_for_solving1 := StrToIntDef(s, downsample_for_solving1);

  force_oversize1 := Pos('"speed":"slow"', optionsJson) > 0;
  check_pattern_filter1 := Pos('"checkPattern":true', optionsJson) > 0;
  add_sip1 := Pos('"sip":true', optionsJson) > 0;
end;

function astap_parse_file_json(inputPath, databaseDir: PChar): PChar; cdecl;
var
  loaded: boolean;
begin
  try
    ResetCoreState(SafeString(inputPath), SafeString(databaseDir));
    if not FileExists(filename2) then
    begin
      errorlevel := 16;
      exit(ReturnCString(BuildJson(false, false, errorlevel, 'Input file not found.')));
    end;

    loaded := load_image;
    if loaded then
      result := ReturnCString(BuildJson(true, false, 0, 'Parsed.'))
    else
    begin
      errorlevel := 16;
      result := ReturnCString(BuildJson(false, false, errorlevel, 'Error reading image file.'));
    end;
  except
    on E: Exception do
      result := ReturnCString(BuildJson(false, false, 99, E.Message));
  end;
end;

function astap_solve_file_json(inputPath, databaseDir, optionsJson: PChar): PChar; cdecl;
var
  loaded, solved: boolean;
begin
  try
    ResetCoreState(SafeString(inputPath), SafeString(databaseDir));
    if not FileExists(filename2) then
    begin
      errorlevel := 16;
      exit(ReturnCString(BuildJson(false, false, errorlevel, 'Input file not found.')));
    end;

    loaded := load_image;
    if not loaded then
    begin
      errorlevel := 16;
      exit(ReturnCString(BuildJson(false, false, errorlevel, 'Error reading image file.')));
    end;

    ApplySolveOptions(SafeString(optionsJson));
    solved := solve_image(img_loaded);
    if solved then
      result := ReturnCString(BuildJson(true, true, 0, 'Solved.'))
    else
    begin
      if errorlevel = 0 then errorlevel := 1;
      result := ReturnCString(BuildJson(false, false, errorlevel, 'No solution found.'));
    end;
  except
    on E: Exception do
      result := ReturnCString(BuildJson(false, false, 99, E.Message));
  end;
end;

procedure astap_free_string(ptr: PChar); cdecl;
begin
  if ptr <> nil then StrDispose(ptr);
end;

exports
  astap_parse_file_json,
  astap_solve_file_json,
  astap_free_string;

begin
  memo1 := TStringList.Create;
  memo2 := TStringList.Create;
end.
