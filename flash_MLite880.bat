@echo off
setlocal EnableDelayedExpansion EnableExtensions
title Flashing Malachite DSP (MLite-880)

:: ===================================================
::  Malachite DSP Firmware Flasher v2.4.1
::  Created by: Alexander Lavrinovich
::  GitHub: https://github.com/Alex-Electron
::  Email: EU1L@mail.ru
:: ===================================================

set "SCRIPT_DIR=%~dp0"
set "DFU_EXE=%SCRIPT_DIR%dfu-util.exe"
set "WDI_EXE=%SCRIPT_DIR%qmk_driver_installer.exe"
set "ZADIG_EXE=%SCRIPT_DIR%tools\zadig-2.9.exe"
set "STM_VID=0483"
set "STM_PID=df11"

echo ===================================================
echo             Malachite DSP Flasher v2.4.1
echo.
echo   Developed by: Alexander Lavrinovich
echo   GitHub:       https://github.com/Alex-Electron
echo   Email:        EU1L@mail.ru
echo ===================================================
echo.

if not exist "%DFU_EXE%" (
    echo [ERROR] dfu-util.exe not found in script directory.
    pause
    exit /b 1
)

echo Before we start, please prepare the receiver:
echo   1. Connect it to this computer via USB.
echo   2. Put it into DFU mode:
echo        Hold the '1' button, turn the radio on, wait 3 seconds, then release '1'.
echo.
pause
echo.

:: ----- Device / driver diagnostics -----
:: Step 1: ask dfu-util whether the device is usable.
:: Step 2: if not, ask Windows (pnputil) whether the device is physically present.
::         If it is present but dfu-util cannot use it, the WinUSB driver is missing.

set "INSTALL_TRIES=0"

:check_device
set "DFU_OK=0"
set "DEVICE_PRESENT=0"

"%DFU_EXE%" -l 2>nul | findstr /C:"Found DFU" >nul
if not errorlevel 1 set "DFU_OK=1"

if "%DFU_OK%"=="1" (
    echo [OK] DFU device detected and ready.
    echo.
    goto select_firmware
)

:: dfu-util cannot use the device - check whether Windows can see it on USB.
pnputil /enum-devices 2>nul | findstr /I /R /C:"VID_%STM_VID%.PID_%STM_PID%" /C:"STM32 BOOTLOADER" >nul
if not errorlevel 1 set "DEVICE_PRESENT=1"

if "%DEVICE_PRESENT%"=="0" (
    echo [WARN] STM32 DFU device ^(VID:PID %STM_VID%:%STM_PID%^) was not detected.
    echo        Checklist:
    echo          - USB cable is connected
    echo          - Receiver is powered on
    echo          - Receiver is in DFU mode ^(Hold '1', turn on, wait 3s, release^)
    echo.
    echo Press any key to retry detection, or close this window to abort...
    pause >nul
    goto check_device
)

:: Device is on the bus but dfu-util cannot open it - WinUSB driver is missing.
set /a INSTALL_TRIES+=1
if %INSTALL_TRIES% GTR 2 (
    echo.
    echo [WARN] Tried to install/bind the driver twice and dfu-util still cannot see the device.
    echo        This usually clears up if you physically reconnect the receiver.
    echo.
    echo        Please:
    echo          1. Disconnect the receiver from USB.
    echo          2. Reconnect it and re-enter DFU mode
    echo             ^(Hold '1', turn on, wait 3s, release^).
    echo          3. Press any key to retry.
    echo.
    pause
    set "INSTALL_TRIES=0"
    goto check_device
)
echo [WARN] STM32 BOOTLOADER device is present, but the WinUSB driver is missing.
echo        The driver must be installed before flashing. ^(attempt %INSTALL_TRIES%/2^)
echo.

:: Require administrator for driver install. Self-elevate if needed.
net session >nul 2>&1
if errorlevel 1 (
    echo [INFO] Driver installation requires Administrator rights.
    echo        Re-launching this script with elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b 0
)

if not exist "%WDI_EXE%" (
    echo [ERROR] qmk_driver_installer.exe not found - cannot install driver automatically.
    echo         Falling back to manual mode: please run zadig-2.9.exe and install WinUSB
    echo         for "STM32 BOOTLOADER" manually, then re-run this script.
    pause
    exit /b 1
)

:: Unblock the installer if it was downloaded from the internet (removes Mark of the Web
:: so SmartScreen does not block silent execution). Safe no-op if no zone info is present.
powershell -NoProfile -Command "Unblock-File -LiteralPath '%WDI_EXE%' -ErrorAction SilentlyContinue" >nul 2>&1

:: qmk_driver_installer.exe takes a CSV file listing devices to install drivers for.
:: Format (from QMK Toolbox drivers.txt): driver,desc,vid,pid,guid
::   driver: winusb | libusbk | libusb-win32 | usbser  (lower-case)
::   vid/pid: hex without 0x prefix
::   guid:   DeviceInterfaceGUID for the driver (any well-formed GUID)
:: The example below uses the same GUID QMK Toolbox ships for STM32 Bootloader.
set "DRIVERS_LIST=%TEMP%\mlite880_drivers_%RANDOM%.txt"
>"%DRIVERS_LIST%" (
    echo winusb,STM32 Bootloader,%STM_VID%,%STM_PID%,6d98a87f-4ecf-464d-89ed-8c684d857a75
)

echo [INFO] Installing WinUSB driver silently via qmk_driver_installer.exe...
echo        ^(Vendor: %STM_VID%, Product: %STM_PID%, target: WinUSB^)
echo        This may take 10-30 seconds. No clicks required.
echo.

set "WDI_LOG=%SCRIPT_DIR%flash_MLite880_last_driver.log"
"%WDI_EXE%" --force --all "%DRIVERS_LIST%" >"%WDI_LOG%" 2>&1
set "WDI_RESULT=%ERRORLEVEL%"
echo --- qmk_driver_installer output (exit=%WDI_RESULT%) ---
type "%WDI_LOG%"
echo --- end of output (saved to %WDI_LOG%) ---
del "%DRIVERS_LIST%" 2>nul

if not "%WDI_RESULT%"=="0" (
    echo.
    echo [WARN] Silent driver install returned exit code %WDI_RESULT%.
    echo        See log above for the actual reason.
    echo        Log file kept at: %WDI_LOG%
    echo.
    pause
    if exist "!ZADIG_EXE!" (
        echo        Falling back to interactive Zadig as a last resort...
        start "" /WAIT "!ZADIG_EXE!"
    ) else (
        echo [ERROR] zadig-2.9.exe fallback not found either. Cannot proceed.
        pause
        exit /b 1
    )
)

echo.
echo [INFO] Driver install finished. Forcing PnP to bind the new driver...
echo        ^(qmk_driver_installer stages the driver in the Driver Store, but Windows
echo         needs a rescan / device restart to attach it to the already-connected unit^)

:: 1) Force Windows to re-enumerate all devices and bind new drivers.
pnputil /scan-devices >nul 2>&1

:: 2) Restart the specific STM32 BOOTLOADER device instance (programmatic unplug+plug).
::    Find any matching instance id and restart it.
for /f "tokens=*" %%I in ('pnputil /enum-devices 2^>nul ^| findstr /I /R /C:"USB.VID_%STM_VID%.PID_%STM_PID%"') do (
    for /f "tokens=2 delims=:" %%J in ("%%I") do (
        set "DEV_ID=%%J"
        setlocal EnableDelayedExpansion
        set "DEV_ID=!DEV_ID: =!"
        pnputil /restart-device "!DEV_ID!" >nul 2>&1
        endlocal
    )
)

echo [INFO] Waiting for driver binding to settle...
timeout /T 5 /NOBREAK >nul
goto check_device

:: ----- Firmware selection -----
:select_firmware
set "count=0"
for %%f in ("%SCRIPT_DIR%*.bin") do (
    set /a count+=1
    set "file[!count!]=%%~nxf"
    set "path[!count!]=%%f"
)

if %count%==0 (
    echo [ERROR] No .bin files found in script directory.
    pause
    exit /b 1
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
echo Reminder: receiver should still be in DFU mode.
echo.
pause

echo.
echo ===================================================
echo FLASHING... (this can take several minutes for 2 MB)
echo DO NOT DISCONNECT the receiver until you see SUCCESS!
echo ===================================================
echo.

:: Run dfu-util directly so the user sees its native output. 
:: We DO NOT pipe or tee this output, because PowerShell/cmd pipes strip the 
:: carriage return (\r) characters that dfu-util uses to draw its live progress bar,
:: causing it to spam hundreds of new lines instead of updating a single line.
:: -d <vid:pid>,<vid:pid> targets only our STM32 (already in DFU mode). Without it dfu-util
:: aborts with "More than one DFU capable device" when another DFU-capable device (e.g. a
:: webcam) shares the USB bus. BOTH pairs are required: a single pair filters only run-time
:: devices, not ones already in DFU mode. The value is quoted so cmd.exe does not treat the
:: comma as an argument separator.
"%DFU_EXE%" -d "%STM_VID%:%STM_PID%,%STM_VID%:%STM_PID%" -a 0 -s 0x08000000:force:leave -D "%FIRMWARE_PATH%"
set "DFU_EXIT=%ERRORLEVEL%"

:: dfu-util's exit code is unreliable: after `:leave` the device resets and detaches
:: from USB, and dfu-util returns 74 ("Error during download get_status") even though
:: the firmware was written successfully.
:: 
:: Reliable success condition: dfu-util exited with 74 AND the device is no longer
:: in DFU mode (because it rebooted).
:: If it exits with any other code, or if the device is STILL in DFU mode, it failed.

set "RESULT=1"
if "%DFU_EXIT%"=="74" (
    :: Exit code is 74. Check if the device is actually gone.
    "%DFU_EXE%" -l 2>nul | findstr /C:"Found DFU" >nul
    if errorlevel 1 (
        :: Device is gone -> Successful flash & reboot.
        set "RESULT=0"
    )
) else if "%DFU_EXIT%"=="0" (
    :: Some versions of dfu-util might actually exit 0 if leave is clean.
    set "RESULT=0"
)

echo.
echo ===================================================
if "%RESULT%"=="0" (
    echo  [SUCCESS] Firmware flashed successfully.
    echo  The receiver should reboot automatically.
) else (
    echo  [ERROR] Flashing failed!
    echo  Please check the output above. If the device is stuck,
    echo  re-enter DFU mode manually and try again.
)
echo ===================================================
echo.
echo Press any key to close this window...
pause >nul
exit /b %RESULT%

:invalid
echo [ERROR] Invalid selection.
pause
exit /b 1
