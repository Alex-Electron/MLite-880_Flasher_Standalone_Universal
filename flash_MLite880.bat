@echo off
setlocal EnableDelayedExpansion EnableExtensions
title Flashing Malachite DSP (MLite-880)

:: ===================================================
::  Malachite DSP Firmware Flasher v2.4.2
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
echo             Malachite DSP Flasher v2.4.2
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
:: --- DFU device selection ---
:: dfu-util -l prints one "Found DFU: [VID:PID] ... serial=..." line per alt setting.
:: Collect the STM32 serials (deduped). If more than one STM32 is in DFU mode at once
:: (rare), let the user pick which to flash and target it with -S <serial>. The serial is
:: the last field on each line, so we take everything after "serial=" and strip the quotes.
set "DFU_SELECT="
set "devcount=0"
:: Write the matching "Found DFU" lines to a temp file with a PLAIN command (pipe +
:: redirect), then read the file with for /f. Putting the dfu-util ^| findstr pipe
:: directly inside for /f needs fragile escaping and failed on Windows, so we avoid it.
set "DFU_LIST=%TEMP%\mlite_dfu_%RANDOM%.txt"
"%DFU_EXE%" -l 2>nul | findstr /C:"Found DFU: [%STM_VID%:%STM_PID%]" > "%DFU_LIST%"
for /f "usebackq tokens=* delims=" %%L in ("%DFU_LIST%") do (
    set "line=%%L"
    set "ser=!line:*serial=!"
    set "ser=!ser:"=!"
    set "pth=!line:*path=!"
    for /f "tokens=1 delims=," %%p in ("!pth!") do set "pth=%%p"
    set "pth=!pth:"=!"
    if not defined seen_!ser! (
        set "seen_!ser!=1"
        set /a devcount+=1
        set "devserial[!devcount!]=!ser!"
        set "devpath[!devcount!]=!pth!"
    )
)
del "%DFU_LIST%" 2>nul

:: Friendly USB product name (best-effort). Run PowerShell as a PLAIN command into a temp
:: file - the | and & inside the quoted -Command are safe there (no for /f escaping needed).
:: Falls back to a generic name if PowerShell / Get-PnpDevice is missing or returns nothing.
set "DEVNAME=STM32 BOOTLOADER"
set "DN_FILE=%TEMP%\mlite_dn_%RANDOM%.txt"
powershell -NoProfile -Command "(Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -like '*VID_%STM_VID%&PID_%STM_PID%*' } | Select-Object -First 1 -ExpandProperty FriendlyName)" > "%DN_FILE%" 2>nul
set /p DEVNAME=<"%DN_FILE%"
del "%DN_FILE%" 2>nul
:: strip shell metacharacters from the name so it cannot break the echo lines below
set "DEVNAME=%DEVNAME:&= %"
set "DEVNAME=%DEVNAME:|= %"
set "DEVNAME=%DEVNAME:<= %"
set "DEVNAME=%DEVNAME:>= %"

if %devcount% GTR 1 goto pick_multi
if %devcount% EQU 1 goto pick_single
goto fw_select

:pick_single
call set "chosen_serial=%%devserial[1]%%"
echo [OK] Target: %DEVNAME%   serial %chosen_serial%
echo      Sanity check: the serial's last 4 digits also show on the receiver's screen -
echo      as the 4th group of its ID, in the middle, not at the end.
echo.
goto fw_select

:pick_multi
echo More than one STM32 DFU device is connected:
echo ---------------------------------------------------
for /L %%i in (1,1,%devcount%) do call echo   [%%i] %DEVNAME%   serial=%%devserial[%%i]%%   USB port %%devpath[%%i]%%
echo ---------------------------------------------------
echo A serial's last 4 digits show up as the 4th group of that receiver's on-screen ID -
echo in the middle, not at the end. You can also unplug one or check Device Manager.
echo.
set /p "dchoice=Select the device to flash (1-%devcount%): "
if "%dchoice%"=="" goto invalid
if %dchoice% LSS 1 goto invalid
if %dchoice% GTR %devcount% goto invalid
call set "chosen_serial=%%devserial[%dchoice%]%%"
set "DFU_SELECT=-S %chosen_serial%"
echo.
echo Target: %DEVNAME%   serial %chosen_serial%
echo.
goto fw_select

:fw_select
set "count=0"
:: Sort newest-first by the YYYYMMDD date embedded at the end of each filename
:: (the last 8 chars before .bin), so the newest stays option [1] even when the
:: version width changes (v1.100, v10.xx). We tag each file with its date, sort
:: descending, then read the filenames back. (dir /o-n would sort by name and
:: mis-rank e.g. v10 below v2.)
set "FWLIST=%TEMP%\mlite_fw_%RANDOM%.txt"
type nul > "%FWLIST%"
for /f "delims=" %%f in ('dir /b /a-d "%SCRIPT_DIR%*.bin" 2^>nul') do (
    set "nm=%%~nf"
    >> "%FWLIST%" echo !nm:~-8! %%f
)
for /f "tokens=1,* delims= " %%a in ('sort /r "%FWLIST%" 2^>nul') do (
    set /a count+=1
    set "file[!count!]=%%b"
    set "path[!count!]=%SCRIPT_DIR%%%b"
)
del "%FWLIST%" 2>nul

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

set /p "choice=Select firmware (1-%count%) [Enter = 1, newest]: "
if "%choice%"=="" set "choice=1"
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

:: -d <vid:pid>,<vid:pid> targets only our STM32 (already in DFU mode). Without it dfu-util
:: aborts with "More than one DFU capable device" when another DFU-capable device (e.g. a
:: webcam) shares the USB bus. BOTH pairs are required: a single pair filters only run-time
:: devices, not ones already in DFU mode. The value is quoted so cmd.exe does not treat the
:: comma as an argument separator.
::
:: Run dfu-util directly (no pipe or redirect) so the user sees its live progress bar.
"%DFU_EXE%" -d "%STM_VID%:%STM_PID%,%STM_VID%:%STM_PID%" %DFU_SELECT% -a 0 -s 0x08000000:force:leave -D "%FIRMWARE_PATH%"
set "DFU_EXIT=%ERRORLEVEL%"

:: Judge success by the exit code. After a good flash dfu-util sends `:leave`, the device
:: immediately resets and detaches, and dfu-util returns 74 ("Error during download
:: get_status") - that is SUCCESS, not a failure. A clean exit (0) counts as success too.
:: Any other code is a real failure. We deliberately do NOT probe the USB bus afterwards:
:: on a VM the device can still appear for a moment, which produced false failure reports.
set "RESULT=1"
if "%DFU_EXIT%"=="74" set "RESULT=0"
if "%DFU_EXIT%"=="0" set "RESULT=0"

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
