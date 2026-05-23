@echo off
setlocal EnableDelayedExpansion
title Flashing Malachite DSP (MLite-880)

:: ===================================================
::  Malachite DSP Firmware Flasher
::  Created by: Alexander Lavrinovich
::  GitHub: https://github.com/Alex-Electron
::  Email: EU1L@mail.ru
:: ===================================================

:: --- CONFIGURATION ---
set "DFU_EXE=dfu-util.exe"
:: ---------------------

set "DFU_UTIL=%~dp0%DFU_EXE%"

echo ===================================================
echo             Malachite DSP Flasher
echo.
echo   Developed by: Alexander Lavrinovich
echo   GitHub:       https://github.com/Alex-Electron
echo   Email:        EU1L@mail.ru
echo ===================================================
echo.

:: Check for dfu-util
if not exist "%DFU_UTIL%" (
    echo [ERROR] %DFU_EXE% not found at:
    echo "%DFU_UTIL%"
    echo.
    pause
    exit /b
)

:: Find all .bin files in the script directory
set "count=0"
for %%f in ("%~dp0*.bin") do (
    set /a count+=1
    set "file[!count!]=%%~nxf"
    set "path[!count!]=%%~f"
)

:: If no files found
if %count%==0 (
    echo [ERROR] No .bin firmware files found in this folder!
    echo Please place your .bin files here:
    echo "%~dp0"
    echo.
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

set /p "choice=Select a firmware to flash (1-%count%): "

:: Validate input
if "%choice%"=="" goto invalid
if %choice% LSS 1 goto invalid
if %choice% GTR %count% goto invalid

set "FIRMWARE_FILE=!file[%choice%]!"
set "FIRMWARE_PATH=!path[%choice%]!"

echo.
echo ===================================================
echo Selected firmware: %FIRMWARE_FILE%
echo ===================================================
echo.
echo 1. Connect the receiver via USB.
echo 2. Put the receiver into DFU mode.
echo.
pause

echo.
echo ===================================================
echo Starting flash process (Mass Erase -> Download)...
echo Please DO NOT disconnect the cable!
echo ===================================================
echo.

:: Run dfu-util directly so user can see the progress bar
"%DFU_UTIL%" -a 0 -s 0x08000000:mass-erase:force:leave -D "%FIRMWARE_PATH%"

echo.
echo ===================================================
echo  [DONE] The flashing process has finished.
echo.
echo  * Note: If you see "Error during download get_status" 
echo    above, it is completely NORMAL and means SUCCESS.
echo    It just means the receiver rebooted successfully.
echo ===================================================
echo.
pause
exit /b

:invalid
echo.
echo [ERROR] Invalid selection! Please enter a number from 1 to %count%.
echo.
pause
exit /b
