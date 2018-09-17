unit main;

{$mode delphi}{$H+}

interface

uses
  {$IFDEF WINDOWS}Windows, shlobj,{$ENDIF} Classes, SysUtils, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Spin, EditBtn, ComCtrls, Buttons, LCLIntf,
  namethread;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnGo: TButton;
    checkAge: TCheckBox;
    checkEmail: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
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
    procedure Label7Click(Sender: TObject);
  private
    WorkThread: TGNThread;
    procedure SetControlsEnabled(b: Boolean);
    procedure NameCountUpdate(c: Integer);
    procedure NamesGenerateComplete(Runtime: String);
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
{$IFDEF WINDOWS}
var
  AppDataPath: Array[0..MaxPathLen] of Char;
{$ENDIF}
begin
  Randomize;
{$IFDEF WINDOWS}
  AppDataPath:='';
  SHGetSpecialFolderPath(0,AppDataPath,CSIDL_DESKTOPDIRECTORY,false);
  textOutputFilename.InitialDir := AppDataPath;
{$ENDIF}
  textOutputFilename.Text := '';
  frmMain.Caption := 'Random Name List Generator';
  Application.Title := frmMain.Caption;
end;

procedure TfrmMain.Label5Click(Sender: TObject);
begin
  OpenURL(Label5.Caption);
end;

procedure TfrmMain.Label7Click(Sender: TObject);
begin
  OpenURL('https://homepage.net/name_generator/');
end;

procedure TfrmMain.btnGoClick(Sender: TObject);
var
  Options: TGNConfig;
begin
  if FileExists(textOutputFilename.Text) then
  begin
    if messagedlg('Output file already exists, overwrite?',mtConfirmation, mbOKCancel, 0)  = mrCancel then
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
    if ExtractFileExt(textOutputFilename.Text) <> '.sql' then
      textOutputFilename.Text := textOutputFilename.Text + '.sql';
  end;
  // Begin
  Options.IncludeAge := checkAge.Checked;
  Options.IncludeEmail := checkEmail.Checked;
  Options.OutputFileName := textOutputFilename.Text;
  Options.TotalNames := textCount.Value;
  case listOutput.ItemIndex of
    0: Options.OutputType := ofXML;
    1: Options.OutputType := ofCSV;
    2: Options.OutputType := ofHTML;
    3: Options.OutputType := ofSQL;
  end;
  WorkThread := TGNThread.Create(true);
  WorkThread.Options := Options;
  WorkThread.FreeOnTerminate := true;
  WorkThread.OnRunComplete := NamesGenerateComplete;
  SetControlsEnabled(false);
  StatusBar1.SimpleText := 'Please wait..';
  WorkThread.Start;
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

procedure TfrmMain.NameCountUpdate(c: Integer);
begin
  StatusBar1.SimpleText := IntToStr(c) + ' names generated';
end;

procedure TfrmMain.NamesGenerateComplete(Runtime: String);
begin
  StatusBar1.SimpleText := IntToStr(textCount.Value) + ' names generated in ' + Runtime;
  showmessage('Done');
  SetControlsEnabled(true);
end;

end.

