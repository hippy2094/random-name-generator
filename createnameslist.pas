program createnameslist;
{$mode objfpc}{$H+}
uses Classes, SysUtils, StrUtils, DateUtils;

(* Names file created using names from http://homepage.net/name_generator/ *)

procedure main;
const
  TAB = #9;
  DEFAULTCOUNT = 10;
  APPVER = '0.1.1';
var
  fo: TextFile;
  age: Byte;
  firstname, surname: String;
  firstnames: TStrings;
  surnames: TStrings;
  i,rf,rs: Integer;
  starttime, endtime: TDateTime;
  runtime: String;
  TotalCount: Integer;
begin  
  writeln('Random name generator ',APPVER);
  writeln('(c) 2017 Matthew Hipkin <http://www.matthewhipkin.co.uk>');
  writeln;
  if ParamCount = 0 then
  begin
    writeln('USAGE: createnameslist <number_of_names>');
    writeln('Defaulting to 10 names');
    writeln;
  end;
  TotalCount := StrToIntDef(ParamStr(1),DEFAULTCOUNT);    
  firstnames := TStringList.Create;
  if not FileExists('firstnames.txt') then
  begin
    writeln('FATAL: Cannot find firstnames.txt!');
    exit;
  end;
  firstnames.LoadFromFile('firstnames.txt');
  if firstnames.Count = 0 then
  begin
    writeln('FATAL: No first names found!');
    exit;
  end;
  surnames := TStringList.Create;
  if not FileExists('surnames.txt') then
  begin
    writeln('FATAL: Cannot find surnames.txt!');
    exit;
  end;
  surnames.LoadFromFile('surnames.txt');
  if surnames.Count = 0 then
  begin
    writeln('FATAL: No surnames found!');
    exit;
  end;
  AssignFile(fo,'namelist.xml');
  Rewrite(fo);
  Writeln(fo,'<?xml version="1.0" encoding="UTF-8" ?>');
  Writeln(fo,'<people>');
  i := 0;
  starttime := Now;
  repeat
    rf := Random(firstnames.Count);
    rs := Random(surnames.Count);
    firstname := firstnames[rf];
    surname := surnames[rs];
    age := Random(100);
    Writeln(fo,'  <person>');
    Writeln(fo,'    <firstname>', firstname, '</firstname>');
    Writeln(fo,'    <surname>', surname, '</surname>');
    Writeln(fo,'    <age>', age, '</age>');
    Writeln(fo,'  </person>');
    inc(i);
  until i = TotalCount;
  Writeln(fo,'</people>');
  endtime := Now;
  CloseFile(fo);
  firstnames.Free;
  DateTimeToString(runtime,'HH:nn:ss.zzz',(endtime-starttime));
  writeln(i, ' names generated in ', runtime);
  surnames.Free;
end;

begin
  Randomize;
  main;
end.
