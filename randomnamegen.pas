program randomnamegen;
{$mode objfpc}{$H+}

uses SysUtils, Classes, fpg_base, fpg_main, fpg_stylemanager, main;

procedure main;
var
  frm: TfrmMain;
  sfimg: TfpgImage;
  progicon: TfpgImage;
begin
  Randomize;
  fpgApplication.Initialize;
  if fpgStyleManager.SetStyle('carbon') then fpgStyle := fpgStyleManager.Style;
  frm := TfrmMain.Create(nil);
  try
    frm.Show;
    fpgApplication.Run;
  finally
    frm.Free;
  end;
end;

begin
  main;
end.
