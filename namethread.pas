unit namethread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TGNOutputFormat = (ofXML, ofHTML, ofSQL, ofCSV);
  type
    TGNConfig = record
      OutputFileName: String;
      TotalNames: Integer;
      OutputType: TGNOutputFormat;
      IncludeAge: Boolean;
      IncludeEmail: Boolean;
    end;

  TUpdateCountEvent = procedure(c: Integer) of Object;
  TRunComplete = procedure(Runtime: String) of Object;
  TGNThread = class(TThread)
    private
      FCurrentIndex: Integer;
      FTotal: Integer;
      FRunTime: String;
      FOnUpdateCount: TUpdateCountEvent;
      FOnRunComplete: TRunComplete;
      procedure Generate;
      procedure UpdateCount;
      procedure GenerationComplete;
    protected
      procedure Execute; override;
    public
      stop: Boolean;
      Options: TGNConfig;
      constructor Create(CreateSuspended: boolean);
      property OnUpdateCount: TUpdateCountEvent read FOnUpdateCount write FOnUpdateCount;
      property OnRunComplete: TRunComplete read FOnRunComplete write FOnRunComplete;
      property Total: Integer read FTotal write FTotal;
  end;

function GenerateRandomEmail(f: String; s: String): String;

implementation

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

{ TGNThread }

constructor TGNThread.Create(CreateSuspended: Boolean);
begin
  FCurrentIndex := 0;
  FTotal := 10;
  stop := false;
  inherited Create(CreateSuspended);
end;

procedure TGNThread.Generate;
var
  fo: TextFile;
  age: Byte;
  firstname, surname, email: String;
  firstnames: TStrings;
  surnames: TStrings;
  i,rf,rs: Integer;
  starttime, endtime: TDateTime;
  s: String;
begin
  firstnames := TStringList.Create;
  {$I firstnames.inc }
  surnames := TStringList.Create;
  {$I surnames.inc }
  AssignFile(fo,Options.OutputFileName);
  Rewrite(fo);
  if Options.OutputType = ofXML then
  begin
    Writeln(fo,'<?xml version="1.0" encoding="UTF-8" ?>');
    Writeln(fo,'<people>');
  end;
  if Options.OutputType = ofCSV then
  begin
    s := 'first_name,surname';
    if Options.IncludeAge then s := s + ',age';
    if Options.IncludeEmail then s := s + ',email';
    writeln(fo,s);
  end;
  if Options.OutputType = ofHTML then
  begin
    writeln(fo,'<html>');
    writeln(fo,'<head>');
    writeln(fo,'  <title>List of ',FTotal,' names</title>');
    writeln(fo,'</head>');
    writeln(fo,'<body>');
    writeln(fo,'  <table>');
    writeln(fo,'    <tr>');
    writeln(fo,'      <th>First name</th>');
    writeln(fo,'      <th>Surname</th>');
    if Options.IncludeAge then writeln(fo,'      <th>Age</th>');
    if Options.IncludeEmail then writeln(fo,'      <th>E-mail</th>');
    writeln(fo,'    </tr>');
  end;
  if Options.OutputType = ofSQL then
  begin
    s := 'CREATE TABLE `people` (`id` INT(11), `firstname` VARCHAR(25), ';
    s := s + '`surname` VARCHAR(25)';
    if Options.IncludeAge then s := s + ', `age` INT(3)';
    if Options.IncludeEmail then s := s + ', `email` VARCHAR(50)';
    s := s + ');';
    writeln(fo,s);
    writeln(fo,'');
  end;
  i := 0;
  starttime := Now;
  repeat
    if stop then break;
    rf := Random(firstnames.Count);
    rs := Random(surnames.Count);
    firstname := firstnames[rf];
    surname := surnames[rs];
    if Options.IncludeAge then age := Random(100);
    if Options.IncludeEmail then email := GenerateRandomEmail(firstname, surname);
    if Options.OutputType = ofXML then
    begin
      Writeln(fo,'  <person>');
      Writeln(fo,'    <firstname>', firstname, '</firstname>');
      Writeln(fo,'    <surname>', surname, '</surname>');
      if Options.IncludeAge then Writeln(fo,'    <age>', age, '</age>');
      if Options.IncludeEmail then Writeln(fo,'    <email>', email, '</email>');
      Writeln(fo,'  </person>');
    end;
    if Options.OutputType = ofCSV then
    begin
      s := firstname + ',' + surname;
      if Options.IncludeAge then s := s + ',' + IntToStr(age);
      if Options.IncludeEmail then s := s + ',' + email;
      Writeln(fo,s);
    end;
    if Options.OutputType = ofHTML then
    begin
      writeln(fo,'    <tr>');
      writeln(fo,'      <td>',firstname,'</td>');
      writeln(fo,'      <td>',surname,'</td>');
      if Options.IncludeAge then writeln(fo,'      <td>',age,'</td>');
      if Options.IncludeEmail then writeln(fo,'      <td>',email,'</td>');
      writeln(fo,'    </tr>');
    end;
    if Options.OutputType = ofSQL then
    begin
      s := 'INSERT INTO `people` (`id`,`firstname`,`surname`';
      if Options.IncludeAge then s := s + ',`age`';
      if Options.IncludeEmail then s := s + ',`email`';
      s := s + ') VALUES (';
      s := s + IntToStr(i+1) + ',';
      s := s + '''' + firstname + ''',';
      s := s + '''' + surname + '''';
      if Options.IncludeAge then s := s + ',' + IntToStr(age);
      if Options.IncludeEmail then s := s + ',''' + email + '''';
      s := s + ');';
      writeln(fo,s);
    end;
    inc(i);
  until i = FTotal;
  if Options.OutputType = ofXML then
  begin
    Writeln(fo,'</people>');
  end;
  if Options.OutputType = ofHTML then
  begin
    writeln(fo,'  </table>');
    writeln(fo,'</body>');
    writeln(fo,'</html>');
  end;
  endtime := Now;
  CloseFile(fo);
  DateTimeToString(FRunTime,'HH:nn:ss.zzz',(endtime-starttime));
  firstnames.Free;
  surnames.Free;
end;

procedure TGNThread.UpdateCount;
begin
  if Assigned(FOnUpdateCount) then
  begin
    FOnUpdateCount(FCurrentIndex);
  end;
end;

procedure TGNThread.GenerationComplete;
begin
  if Assigned(FOnRunComplete) then
  begin
    FOnRunComplete(FRunTime);
  end;
end;

procedure TGNThread.Execute;
begin
  Generate;
end;

end.

