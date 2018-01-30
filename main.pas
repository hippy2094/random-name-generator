unit main;

{$mode delphi}{$H+}

interface

uses
  Windows, shlobj, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Spin, EditBtn, ComCtrls, Buttons, LCLIntf;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnGo: TButton;
    checkAge: TCheckBox;
    checkEmail: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    listOutput: TComboBox;
    textOutputFilename: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    textCount: TSpinEdit;
    StatusBar1: TStatusBar;
    procedure btnGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label5Click(Sender: TObject);
  private
    procedure SetControlsEnabled(b: Boolean);
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

function GenerateRandomEmail(f: String; s: String): String;
var
  i,j: Integer;
  front, domain: String;
  domains: TStrings;
  suf: TStrings;
begin
  domains := TStringList.Create;
  domains.Add('outlook.com');
  domains.Add('gmail.com');
  domains.Add('yahoo.com');
  domains.Add('hotmail.com');
  domains.Add('aol.com');
  suf := TStringList.Create;
  suf.Add('.com');
  suf.Add('.net');
  suf.Add('.org');
  suf.Add('.co.uk');
  suf.Add('.de');
  suf.Add('.fr');
  suf.Add('.ca');
  suf.Add('.io');
  i := Random(1500);
  if i <= 333 then
  begin
    front := f[1] + s;
  end;
  if (i > 333) and (i <= 666) then
  begin
    front := f + '.' + s;
  end;
  if (i > 666) and (i < 1000) then
  begin
    front := f + s[1];
  end;
  if i >= 1000 then
  begin
    front := f;
    j := Random(600);
    if j < 200 then domain := f + s;
    if (j >= 200) and (j < 400) then domain := f + '-' + s;
    if j >= 400 then domain := s;
    j := Random(suf.Count);
    domain := domain + suf[j];
  end;
  if i < 1000 then
  begin
    i := Random(domains.Count);
    domain := domains[i];
  end;
  Result := Lowercase(front) + '@' + Lowercase(domain);
  domains.Free;
  suf.Free;
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  AppDataPath: Array[0..MaxPathLen] of Char;
begin
  AppDataPath:='';
  SHGetSpecialFolderPath(0,AppDataPath,CSIDL_DESKTOPDIRECTORY,false);
  textOutputFilename.InitialDir := AppDataPath;
  textOutputFilename.Text := '';
end;

procedure TfrmMain.Label5Click(Sender: TObject);
begin
  OpenURL(Label5.Caption);
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
  if textOutputFilename.FileName = '' then
  begin
    messagedlg('No output file specified!',mtError, [mbOK], 0);
    exit;
  end;
  TotalCount := textCount.Value;
  firstnames := TStringList.Create;
  // Check inputs exist
  if not FileExists('firstnames.txt') then
  begin
    messagedlg('Cannot find firstnames.txt!',mtError, [mbOK], 0);
    exit;
  end;
  firstnames.LoadFromFile('firstnames.txt');
  if firstnames.Count = 0 then
  begin
    messagedlg('No first names found!',mtError, [mbOK], 0);
    exit;
  end;
  surnames := TStringList.Create;
  if not FileExists('surnames.txt') then
  begin
    messagedlg('Cannot find surnames.txt!',mtError, [mbOK], 0);
    exit;
  end;
  surnames.LoadFromFile('surnames.txt');
  if surnames.Count = 0 then
  begin
    messagedlg('No surnames found!',mtError, [mbOK], 0);
    exit;
  end;
  // Parse output filename
  if listOutput.ItemIndex = 0 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.xml' then
      textOutputFilename.Text := textOutputFilename.Text + '.xml';
  end;
  if listOutput.ItemIndex = 1 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.csv' then
      textOutputFilename.Text := textOutputFilename.Text + '.csv';
  end;
  if listOutput.ItemIndex = 2 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.html' then
      textOutputFilename.Text := textOutputFilename.Text + '.html';
  end;
  if listOutput.ItemIndex = 3 then
  begin
    if ExtractFileExt(textOutputFilename.Text) <> '.json' then
      textOutputFilename.Text := textOutputFilename.Text + '.json';
  end;
  // Begin
  SetControlsEnabled(false);
  StatusBar1.SimpleText := 'Please wait..';
  AssignFile(fo,textOutputFilename.Text);
  Rewrite(fo);
  if listOutput.ItemIndex = 0 then
  begin
    Writeln(fo,'<?xml version="1.0" encoding="UTF-8" ?>');
    Writeln(fo,'<people>');
  end;
  if listOutput.ItemIndex = 1 then
  begin
    s := 'first_name,surname';
    if checkAge.Checked then s := s + ',age';
    if checkEmail.Checked then s := s + ',email';
    writeln(fo,s);
  end;
  if listOutput.ItemIndex = 2 then
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
    Application.ProcessMessages;
    rf := Random(firstnames.Count);
    rs := Random(surnames.Count);
    firstname := firstnames[rf];
    surname := surnames[rs];
    if checkAge.Checked then age := Random(100);
    if checkEmail.Checked then email := GenerateRandomEmail(firstname, surname);
    if listOutput.ItemIndex = 0 then
    begin
      Writeln(fo,'  <person>');
      Writeln(fo,'    <firstname>', firstname, '</firstname>');
      Writeln(fo,'    <surname>', surname, '</surname>');
      if checkAge.Checked then Writeln(fo,'    <age>', age, '</age>');
      if checkEmail.Checked then Writeln(fo,'    <email>', email, '</email>');
      Writeln(fo,'  </person>');
    end;
    if listOutput.ItemIndex = 1 then
    begin
      s := firstname + ',' + surname;
      if checkAge.Checked then s := s + ',' + IntToStr(age);
      if checkEmail.Checked then s := s + ',' + email;
      Writeln(fo,s);
    end;
    if listOutput.ItemIndex = 2 then
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
  if listOutput.ItemIndex = 0 then
  begin
    Writeln(fo,'</people>');
  end;
  if listOutput.ItemIndex = 2 then
  begin
    writeln(fo,'  </table>');
    writeln(fo,'</body>');
    writeln(fo,'</html>');
  end;
  endtime := Now;
  CloseFile(fo);
  firstnames.Free;
  DateTimeToString(runtime,'HH:nn:ss.zzz',(endtime-starttime));
  StatusBar1.SimpleText := IntToStr(i) + ' names generated in ' + runtime;
  showmessage('Done');
  SetControlsEnabled(true);
  surnames.Free;
end;

procedure TfrmMain.SetControlsEnabled(b: Boolean);
begin
  listOutput.Enabled := b;
  textCount.Enabled := b;
  textOutputFilename.Enabled := b;
  checkAge.Enabled := b;
  checkEmail.Enabled := b;
  Label1.Enabled := b;
  Label2.Enabled := b;
  Label3.Enabled := b;
  btnGo.Enabled := b;
end;

end.

