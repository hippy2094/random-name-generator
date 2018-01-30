@echo off
fpc -iTP > tmpvar
set /p myplatform= < tmpvar
fpc -iTO > tmpvar
set /p myos= < tmpvar
del tmpvar

if exist .\lib\%myplatform%-%myos%\nul.x goto end

mkdir .\lib\%myplatform%-%myos%
goto end

:end

fpc @extrafpc-win.cfg randomnamegen.pas
