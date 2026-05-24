@echo off
setlocal EnableDelayedExpansion
title Flashing Malachite DSP (MLite-880)

:: ===================================================
::  Malachite DSP Firmware Flasher v1.1.3
::  Created by: Alexander Lavrinovich
::  GitHub: https://github.com/Alex-Electron
::  Email: EU1L@mail.ru
:: ===================================================

set "DFU_EXE=dfu-util.exe"
set "DFU_UTIL=%~dp0%DFU_EXE%"

echo ===================================================
echo             Malachite DSP Flasher v1.2.1
echo.
echo   Developed by: Alexander Lavrinovich
echo   GitHub:       https://github.com/Alex-Electron
echo   Email:        EU1L@mail.ru
echo ===================================================
echo.

if not exist "%DFU_UTIL%" (
    echo [ERROR] %DFU_EXE% not found!
    pause
    exit /b
)

set "count=0"
for %%f in ("%~dp0*.bin") do (
    set /a count+=1
    set "file[!count!]=%%~nxf"
    set "path[!count!]=%%f"
)

if %count%==0 (
    echo [ERROR] No .bin files found!
    pause
    exit /b
)

echo Available firmware files:
echo ---------------------------------------------------
for /L %%i in (1, 1, %count%) do (
    echo   [%%i] !file[%%i]!
)
echo ---------------------------------------------------
echo.

set /p "choice=Select firmware (1-%count%): "
if "%choice%"=="" goto invalid
if %choice% LSS 1 goto invalid
if %choice% GTR %count% goto invalid

set "FIRMWARE_FILE=!file[%choice%]!"
set "FIRMWARE_PATH=!path[%choice%]!"

echo.
echo Selected: %FIRMWARE_FILE%
echo 1. Connect USB.
echo 2. Put receiver into DFU mode (Hold '1', turn on, wait 3s).
echo.
pause

echo.
echo ===================================================
echo FLASHING... (Please wait 5-15 seconds)
echo DO NOT DISCONNECT!
echo ===================================================
echo.

:: REPAIRING COMMAND:
:: Removed :verify (invalid) and :mass-erase (sometimes fails).
:: Using :force:leave for reliable sector-by-sector flashing and auto-reboot.
"%DFU_UTIL%" -a 0 -s 0x08000000:force:leave -D "%FIRMWARE_PATH%"

echo.
echo ===================================================
echo  [DONE] The process has finished.
echo.
echo  * If you see "File downloaded successfully",
echo    your firmware is updated and radio rebooted.
echo ===================================================
echo.
pause
exit /b

:invalid
echo [ERROR] Invalid selection!
pause
exit /b


