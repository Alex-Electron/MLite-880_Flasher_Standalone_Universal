@echo off
setlocal EnableDelayedExpansion EnableExtensions
title USB Driver Cleanup Utility

:: ===================================================
::  Universal USB Driver Cleanup
::  Removes all third-party (oem*.inf) drivers that match a given VID/PID.
::
::  Usage:
::    cleanup_drivers.bat              -> defaults to STM32 BOOTLOADER (0483:DF11)
::    cleanup_drivers.bat 16C0 05DF    -> any VID:PID pair (hex, no 0x)
::    cleanup_drivers.bat --help       -> show this help
::
::  What it does:
::    1. Scans %WINDIR%\INF\oem*.inf for files referencing VID_xxxx&PID_yyyy.
::    2. Self-elevates to Administrator (one UAC prompt).
::    3. Calls `pnputil /delete-driver <inf> /uninstall /force` for each match.
::    4. Reports what was removed.
::
::  Created by: Alexander Lavrinovich  -  https://github.com/Alex-Electron
:: ===================================================

if "%~1"=="--help" goto :show_help
if "%~1"=="-h"     goto :show_help
if "%~1"=="/?"     goto :show_help

set "VID=%~1"
set "PID=%~2"
if "%VID%"=="" set "VID=0483"
if "%PID%"=="" set "PID=DF11"

echo ===================================================
echo  USB Driver Cleanup
echo  Target VID:PID = %VID%:%PID%
echo ===================================================
echo.

:: ----- Self-elevate if not running as admin -----
net session >nul 2>&1
if errorlevel 1 (
    echo [INFO] Administrator rights are required to remove drivers.
    echo        Re-launching with elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%VID% %PID%' -Verb RunAs"
    exit /b 0
)

:: ----- Scan oem*.inf files for matching VID/PID -----
echo Scanning %WINDIR%\INF for matching drivers...
echo.

set "FOUND_COUNT=0"
set "REMOVED_COUNT=0"
set "FAILED_COUNT=0"

for /f "delims=" %%F in ('powershell -NoProfile -Command "Get-ChildItem -Path '%WINDIR%\INF\oem*.inf' | Select-String -Pattern 'VID_%VID%.*PID_%PID%' -List | Select-Object -ExpandProperty Path" 2^>nul') do (
    set /a FOUND_COUNT+=1
    echo Found match: %%~nxF
    pnputil /delete-driver "%%~nxF" /uninstall /force
    if not errorlevel 1 (
        set /a REMOVED_COUNT+=1
    ) else (
        set /a FAILED_COUNT+=1
    )
    echo.
)

echo ===================================================
if "!FOUND_COUNT!"=="0" (
    echo  No drivers found for VID:PID %VID%:%PID%.
    echo  Nothing to clean up.
) else (
    echo  Scanned:  !FOUND_COUNT! matching driver package^(s^)
    echo  Removed:  !REMOVED_COUNT!
    if not "!FAILED_COUNT!"=="0" (
        echo  Failed:   !FAILED_COUNT!  ^(check messages above^)
    )
)
echo ===================================================
echo.

:: Flush any buffered keypresses, then wait.
powershell -NoProfile -Command "while ($Host.UI.RawUI.KeyAvailable) { [void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') }" 2>nul
echo Press any key to close this window...
pause >nul
exit /b 0

:show_help
echo ===================================================
echo  USB Driver Cleanup - Universal utility
echo ===================================================
echo.
echo Removes all third-party drivers ^(oem*.inf^) that reference a
echo given USB VID:PID pair.
echo.
echo Usage:
echo   cleanup_drivers.bat                  Defaults to STM32 BOOTLOADER ^(0483:DF11^)
echo   cleanup_drivers.bat ^<VID^> ^<PID^>      Any VID and PID in hex without 0x
echo   cleanup_drivers.bat --help           Show this message
echo.
echo Examples:
echo   cleanup_drivers.bat                  -> 0483:DF11  ^(STM32 Bootloader^)
echo   cleanup_drivers.bat 16C0 05DF        -> 16C0:05DF  ^(Atmel HID Bootloader^)
echo   cleanup_drivers.bat 03EB 2FF4        -> 03EB:2FF4  ^(ATmega32U4 DFU^)
echo.
echo The script self-elevates to Administrator ^(one UAC prompt^) and
echo calls `pnputil /delete-driver` for each matching INF.
echo.
pause >nul
exit /b 0
