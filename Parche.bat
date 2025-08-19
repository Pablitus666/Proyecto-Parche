@echo off
title Adobe Patcher

:: Asks for Administrator Permissions
net session >nul 2>&1
if %errorlevel% neq 0 goto elevate
cd /d "%~dp0"
goto mainScript

:elevate
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd","/c %~s0 ::","","runas",1)(window.close) >nul 2>&1
exit

:mainScript
pwsh -ExecutionPolicy Bypass -NoProfile -File ".\src\AdobePatcher.ps1"
