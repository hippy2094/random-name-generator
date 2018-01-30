unit main;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  EditBtn, ComCtrls, Buttons;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnGo: TButton;
    checkAge: TCheckBox;
    checkEmail: TCheckBox;
    listOutput: TComboBox;
    textOutputFilename: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    textCount: TSpinEdit;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

// https://www.experts-exchange.com/questions/26904175/How-do-I-get-System-Path-Desktop-with-Delphi2010.html
function GetSystemPath(Folder: Integer): string;
var
  PIDL: PItemIDList;
  Path: LPSTR;
  AMalloc: IMalloc;
begin
  Path := StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(Application.Handle, Folder, PIDL);

  if SHGetPathFromIDList(PIDL, Path) then Result := Path;

  SHGetMalloc(AMalloc);
  AMalloc.Free(PIDL);
  StrDispose(Path);
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  textOutputFilename.InitialDir := GetSystemPath(CSIDL_DESKTOPDIRECTORY);
end;

end.

