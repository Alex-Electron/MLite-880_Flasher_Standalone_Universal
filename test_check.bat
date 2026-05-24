@echo off
"C:\Repos\MLite-880_Flasher_Standalone_Universal\dfu-util.exe" -l 2>nul | findstr /C:"Found DFU" >nul
if not errorlevel 1 ( echo OK ) else ( echo FAIL )
