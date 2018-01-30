unit main;

{$mode delphi}{$H+}

interface

uses
  {$IFDEF WINDOWS}Windows,{$ENDIF}SysUtils, Classes, fpg_base, process,
  fpg_main,  fpg_form, fpg_button, fpg_radiobutton, fpg_edit, fpg_dialogs, 
  fpg_label, fpg_checkbox, fpg_combobox, fpg_gauge;

type
  TDialogType = (dtOpen, dtSave);
  TfrmMain = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: frmMain}
    listOutput: TfpgComboBox;
    Label1: TfpgLabel;
    textTotal: TfpgEditInteger;
    textOutputFilename: TfpgEdit;
    checkAge: TfpgCheckBox;
    checkEmail: TfpgCheckBox;
    Label2: TfpgLabel;
    Label3: TfpgLabel;
    btnGo: TfpgButton;
    btnAbout: TfpgButton;
    btnPickFile: TfpgButton;
    Gauge1: TfpgGauge;
    {@VFD_HEAD_END: frmMain}
    procedure btnChooseOutputFileClick(Sender: TObject);    
    procedure btnGoClick(Sender: TObject);    
  public
    procedure AfterCreate; override;
  end;
  
const
  TAB = #9;  

{@VFD_NEWFORM_DECL}

implementation

{@VFD_NEWFORM_IMPL}

{$IFDEF WINDOWS}

function GetWinVer: String;
var
  VerInfo: TOSVersioninfo;
  nt: String;
begin
  nt := '';
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  if VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then nt := 'NT ';
  Result := 'Windows '+nt+IntToStr(VerInfo.dwMajorVersion) + '.' + IntToStr(VerInfo.dwMinorVersion);
end;

{ http://forum.lazarus.freepascal.org/index.php?topic=34998.0 }

function GetOpenFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll' name 'GetOpenFileNameA';     // AnsiVersion
function GetSaveFileName(var OpenFile: TOpenFilename): Bool; stdcall; external 'comdlg32.dll' name 'GetSaveFileNameA';

function  AFF_OFSize(const CurSize: integer): integer;
const
  WIN_2000 = 5;
  OLDWIN_OFSSIZE  = 76;
var 
  OSVersion: TOSVersionInfo;
begin
  result := CurSize;
  OSVersion.dwOSVersionInfoSize := SizeOf(OSVersion);
  if GetVersionEx(OSVersion) then
    if (OSVersion.dwPlatformId<VER_PLATFORM_WIN32_NT) or (OSVersion.dwMajorVersion<WIN_2000) then
      result := OLDWIN_OFSSIZE;
end;

function AskForFile(const WinHandle: THandle; const FileFilters: string; const FileFlags: DWORD; DialogType: TDialogType; var FileName: string): Boolean;
var
  FileToProcess: TOpenFileName;
  CFileName: array [0..Pred(MAX_PATH+10)] of Char;
  CFileNameOnly: array [0..Pred(MAX_PATH+10)] of Char;
begin
  FillChar(FileToProcess, SizeOf(FileToProcess), 0);
  FillChar(CFileName, SizeOf(CFileName), 0);
  FillChar(CFileNameOnly, SizeOf(CFileNameOnly), 0);
  //
  FileToProcess.lStructSize := AFF_OFSize(SizeOf(FileToProcess));
  FileToProcess.hWndOwner := WinHandle;
  FileToProcess.hInstance := HInstance;
  FileToProcess.lpstrFilter := PChar(FileFilters);
  FileToProcess.nFilterIndex := 1;            // First filter is current filter by default
  FileToProcess.lpstrFile := CFileName;
  FileToProcess.nMaxFile := Pred(Length(CFileName));
  FileToProcess.lpstrFileTitle := CFileNameOnly;
  FileToProcess.nMaxFileTitle := Pred(Length(CFileNameOnly));
  FileToProcess.lpstrInitialDir := '.\';      // Current directory by default
  FileToProcess.Flags := FileFlags;
  //
  FileName := '';
  if DialogType = dtOpen then result := GetOpenFileName(FileToProcess)
  else Result := GetSaveFileName(FileToProcess);
  if result then
    FileName := string(CFileName);
end;
{$ELSE}
function AskForFile(const FileFilters: string; DialogType: TDialogType; var FileName: string): Boolean;
var
  dlg: TfpgFileDialog;
begin
  dlg := TfpgFileDialog.Create(nil);
  Result := false;
  dlg.Filter := FileFilters;
  if DialogType = dtOpen then
  begin
    if dlg.RunOpenFile then
    begin
       Result := true;
       FileName := dlg.FileName;
    end;
  end
  else
  begin
    if dlg.RunSaveFile then
    begin
       Result := true;
       FileName := dlg.FileName;
    end;
  end;
    dlg.Free;
end;

function GetPreferredFont: String;
const
  BUF_SIZE = 2048;
var
  AProcess: TProcess;
  OutputStream: TStream;
  BytesRead: longint;
  Buffer: array[1..BUF_SIZE] of byte;
  fonts: TStrings;
  i: Integer;
begin
  Result := '';
  AProcess := TProcess.Create(nil);
  AProcess.Executable := 'fc-list';
  AProcess.Options := [poUsePipes];
  AProcess.Execute;
  OutputStream := TMemoryStream.Create;
  repeat
    BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);
    OutputStream.Write(Buffer, BytesRead)
  until BytesRead = 0;
  AProcess.Free;
  fonts := TStringList.Create;
  OutputStream.Position := 0;
  fonts.LoadFromStream(OutputStream);
  for i := 0 to fonts.Count -1 do
  begin
    if AnsiPos('Oxygen',fonts[i]) > 1 then
    begin
      Result := 'Oxygen';
      break;
    end;
    if (AnsiPos('DejaVu Sans',fonts[i]) > 1) and (Length(Result) < 1) then
    begin
      Result := 'DejaVu Sans';
    end;
  end;
  if Length(Result) < 1 then Result := 'Helvetica';
  fonts.Free;
  OutputStream.Free;
end;
{$ENDIF}

function GenerateRandomEmail(f: String; s: String): String;
var
  i: Integer;
  front, domain: String;
  domains: TStrings;
begin
  domains := TStringList.Create;
  domains.Add('outlook.com');
  domains.Add('gmail.com');
  domains.Add('yahoo.com');
  domains.Add('hotmail.com');
  i := Random(1000);
  if i <= 333 then
  begin
    front := f[1] + s;
  end;
  if (i > 333) and (i <= 666) then
  begin
    front := f + '.' + s;
  end;
  if i > 666 then
  begin
    front := f + s[1];
  end;
  i := Random(domains.Count);
  domain := domains[i];
  Result := front + '@' + domain;
  domains.Free;
end;

procedure TfrmMain.AfterCreate;
var
  f: String;
begin
  {$IFDEF WINDOWS}
  f := 'Segoe UI-9:antialias=true';
  {$ELSE}
  f := GetPreferredFont+'-10:antialias=true';
  {$ENDIF}
  {%region 'Auto-generated GUI code' -fold}
  {@VFD_BODY_BEGIN: frmMain}
  Name := 'frmMain';
  SetPosition(649, 397, 311, 191);
  WindowTitle := 'frmMain';
  Hint := '';
  IconName := '';

  listOutput := TfpgComboBox.Create(self);
  with listOutput do
  begin
    Name := 'listOutput';
    SetPosition(24, 32, 120, 24);
    ExtraHint := '';
    FontDesc := f;
    Hint := '';
    Items.Add('XML');
    Items.Add('CSV');
    Items.Add('HTML table');
    //Items.Add('JSON');
    FocusItem := 0;
    TabOrder := 1;
  end;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(28, 12, 80, 14);
    FontDesc := f;
    Hint := '';
    Text := 'Output format';
  end;

  textTotal := TfpgEditInteger.Create(self);
  with textTotal do
  begin
    Name := 'textTotal';
    SetPosition(164, 32, 120, 24);
    FontDesc := f;
    Hint := '';
    MaxValue := 99999999;
    MinValue := 0;
    TabOrder := 3;
    Value := 10;
  end;

  textOutputFilename := TfpgEdit.Create(self);
  with textOutputFilename do
  begin
    Name := 'textOutputFilename';
    SetPosition(24, 120, 236, 24);
    FontDesc := f;
    ExtraHint := '';
    TabOrder := 4;
  end;
  
  btnPickFile := TfpgButton.Create(self);
  with btnPickFile do
  begin
    Name := 'btnPickFile';
    SetPosition(262, 120, 24, 24);
    Text := '...';
    FontDesc := f;
    Hint := '';
    ImageName := '';
    TabOrder := 10;
    OnClick := btnChooseOutputFileClick;
  end;
  
  checkAge := TfpgCheckBox.Create(self);
  with checkAge do
  begin
    Name := 'checkAge';
    SetPosition(24, 68, 120, 18);
    FontDesc := f;
    Hint := '';
    TabOrder := 5;
    Text := 'Include age field';
  end;

  checkEmail := TfpgCheckBox.Create(self);
  with checkEmail do
  begin
    Name := 'checkEmail';
    SetPosition(164, 68, 120, 18);
    FontDesc := f;
    Hint := '';
    TabOrder := 6;
    Text := 'Include email field';
  end;

  Label2 := TfpgLabel.Create(self);
  with Label2 do
  begin
    Name := 'Label2';
    SetPosition(28, 96, 80, 14);
    FontDesc := f;
    Hint := '';
    Text := 'Output file';
  end;

  Label3 := TfpgLabel.Create(self);
  with Label3 do
  begin
    Name := 'Label3';
    SetPosition(164, 12, 140, 14);
    FontDesc := f;
    Hint := '';
    Text := 'Number of names';
  end;

  btnGo := TfpgButton.Create(self);
  with btnGo do
  begin
    Name := 'btnGo';
    SetPosition(220, 156, 80, 22);
    Text := 'Generate';
    FontDesc := f;
    Hint := '';
    ImageName := '';
    TabOrder := 9;
    OnClick := btnGoClick;
  end;

  btnAbout := TfpgButton.Create(self);
  with btnAbout do
  begin
    Name := 'btnAbout';
    SetPosition(24, 156, 22, 22);
    Text := '';
    FontDesc := f;
    Hint := '';
    ImageName := '';
    TabOrder := 10;
  end;

  Gauge1 := TfpgGauge.Create(self);
  with Gauge1 do
  begin
    Name := 'Gauge1';
    SetPosition(112, 156, 100, 21);
    Hint := '';
    Progress := 0;
    Visible := false;
  end;

  {@VFD_BODY_END: frmMain}
  {%endregion}
end;

procedure TfrmMain.btnChooseOutputFileClick(Sender: TObject);
var
  FileName: string;
const
  FILE_FILTERS: string = 'All Files (*.*)' + #00 + '*.*' + #00 + #00;
begin
  {$IFDEF WINDOWS}
  if AskForFile(0, FILE_FILTERS, OFN_PATHMUSTEXIST or OFN_HIDEREADONLY, dtSave, FileName) then textOutputFilename.Text := FileName;
  {$ELSE}
  if AskForFile('All files (*.*)|*.*', dtSave, FileName) then textOutputFilename.Text := FileName;
  {$ENDIF}
end;

procedure TfrmMain.btnGoClick(Sender: TObject);
var
  fo: TextFile;
  age: Byte;
  firstname, surname, email: String;
  firstnames: TStrings;
  surnames: TStrings;
  i,rf,rs: Integer;
  starttime, endtime: TDateTime;
  runtime: String;
  TotalCount: Integer;
  s: String;
begin
  TotalCount := textTotal.Value;
  firstnames := TStringList.Create;
  // Check inputs exist
  if not FileExists('firstnames.txt') then
  begin
    //writeln('FATAL: Cannot find firstnames.txt!');
    exit;
  end;
  firstnames.LoadFromFile('firstnames.txt');
  if firstnames.Count = 0 then
  begin
    //writeln('FATAL: No first names found!');
    exit;
  end;
  surnames := TStringList.Create;
  if not FileExists('surnames.txt') then
  begin
    //writeln('FATAL: Cannot find surnames.txt!');
    exit;
  end;
  surnames.LoadFromFile('surnames.txt');
  if surnames.Count = 0 then
  begin
    //writeln('FATAL: No surnames found!');
    exit;
  end;
  // Parse output filename
  if listOutput.FocusItem = 0 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.xml' then 
      textOutputFilename.Text := textOutputFilename.Text + '.xml';
  end;
  if listOutput.FocusItem = 1 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.csv' then 
      textOutputFilename.Text := textOutputFilename.Text + '.csv';  
  end;
  if listOutput.FocusItem = 2 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.html' then 
      textOutputFilename.Text := textOutputFilename.Text + '.html';  
  end;
  if listOutput.FocusItem = 3 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.json' then 
      textOutputFilename.Text := textOutputFilename.Text + '.json';  
  end;
  // Begin
  AssignFile(fo,textOutputFilename.Text);
  Rewrite(fo);
  if listOutput.FocusItem = 0 then
  begin
    Writeln(fo,'<?xml version="1.0" encoding="UTF-8" ?>');
    Writeln(fo,'<people>');  
  end;
  if listOutput.FocusItem = 1 then
  begin
    s := 'first_name,surname';
    if checkAge.Checked then s := s + ',age';
    if checkEmail.Checked then s := s + ',email';
    writeln(fo,s);
  end;
  if listOutput.FocusItem = 2 then
  begin
    writeln(fo,'<html>');
    writeln(fo,'<head>');
    writeln(fo,'  <title>List of ',TotalCount,' names</title>');
    writeln(fo,'</head>');    
    writeln(fo,'<body>');
    writeln(fo,'  <table>');
    writeln(fo,'    <tr>');
    writeln(fo,'      <th>First name</th>');
    writeln(fo,'      <th>Surname</th>');
    if checkAge.Checked then writeln(fo,'      <th>Age</th>');
    if checkEmail.Checked then writeln(fo,'      <th>E-mail</th>');
    writeln(fo,'    </tr>');
  end;
  i := 0;
  starttime := Now;
  repeat
    rf := Random(firstnames.Count);
    rs := Random(surnames.Count);
    firstname := firstnames[rf];
    surname := surnames[rs];
    if checkAge.Checked then age := Random(100);
    if checkEmail.Checked then email := GenerateRandomEmail(firstname, surname);
    if listOutput.FocusItem = 0 then
    begin
      Writeln(fo,'  <person>');
      Writeln(fo,'    <firstname>', firstname, '</firstname>');
      Writeln(fo,'    <surname>', surname, '</surname>');
      if checkAge.Checked then Writeln(fo,'    <age>', age, '</age>');
      if checkEmail.Checked then Writeln(fo,'    <email>', email, '</email>');
      Writeln(fo,'  </person>');    
    end;
    if listOutput.FocusItem = 1 then
    begin
      s := firstname + ',' + surname;
      if checkAge.Checked then s := s + ',' + IntToStr(age);
      if checkEmail.Checked then s := s + ',' + email;
      Writeln(fo,s);
    end;
    if listOutput.FocusItem = 2 then
    begin
      writeln(fo,'    <tr>');
      writeln(fo,'      <td>',firstname,'</td>');
      writeln(fo,'      <td>',surname,'</td>');
      if checkAge.Checked then writeln(fo,'      <td>',age,'</td>');
      if checkEmail.Checked then writeln(fo,'      <td>',email,'</td>');
      writeln(fo,'    </tr>');      
    end;
    inc(i);
  until i = TotalCount;
  if listOutput.FocusItem = 0 then
  begin
    Writeln(fo,'</people>');
  end;
  if listOutput.FocusItem = 2 then
  begin
    writeln(fo,'  </table>');  
    writeln(fo,'</body>');    
    writeln(fo,'</html>');        
  end;
  endtime := Now;
  CloseFile(fo);
  firstnames.Free;
  DateTimeToString(runtime,'HH:nn:ss.zzz',(endtime-starttime));
  //writeln(i, ' names generated in ', runtime);
  surnames.Free;  
end;

end.
