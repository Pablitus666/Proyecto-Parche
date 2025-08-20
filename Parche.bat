@echo off
title Adobe Patcher
setlocal

:: Check for admin rights using openfiles
openfiles >nul 2>&1
if %errorlevel% equ 0 (
    goto :mainScript
) else (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:mainScript
    cd /d "%~dp0"
    pwsh -ExecutionPolicy Bypass -NoProfile -File ".\src\AdobePatcher.ps1"
