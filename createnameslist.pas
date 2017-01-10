program createnameslist;
{$mode objfpc}{$H+}
uses Classes, SysUtils, StrUtils, DateUtils;

(* Names file created using names from http://homepage.net/name_generator/ *)

procedure main;
const
  TAB = #9;
  TOTALCOUNT = 100000;
var
  fo: TextFile;
  age: Byte;
  firstname, surname: String;
  firstnames: TStrings;
  surnames: TStrings;
  i,rf,rs: Integer;
  starttime, endtime: TDateTime;
  runtime: String;
begin
  firstnames := TStringList.Create;
  firstnames.LoadFromFile('firstnames.txt');
  surnames := TStringList.Create;
  surnames.LoadFromFile('surnames.txt');
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
  until i = TOTALCOUNT;
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
