# MALAHIT STM32 DFU USB Setup 1.0.0

Один EXE для Windows 10/11: скачайте, запустите, подключите нужный приёмник в DFU по его руководству, подтвердите выбор и нажмите **Установить WinUSB**. Разрешите установку в запросе Windows. Затем вернитесь в веб-прошивальщик и подключитесь снова. Распаковывать архивы и запускать скрипты не требуется.

Подходит для приёмников MALAHITEAM, которые в DFU используют **0483:DF11**, включая MLite и DSP. Способ входа в DFU зависит от модели. Для MLite-880: удерживайте `1` при включении 3 секунды. Другие STM32 DFU на время установки отключите: USB ID определяет загрузчик, а не производителя приёмника. Аудио/COM/накопитель в обычном режиме не являются целью установки.

One EXE for Windows 10/11: download, run, connect the intended receiver in DFU according to its manual, confirm the target, click **Install WinUSB**, and approve Windows elevation. Return to the web flasher and reconnect. No manual extraction or scripts. The installer supports any MALAHITEAM receiver exposing STM32 DFU **0483:DF11**; this ID alone cannot identify a radio model. Disconnect other STM32 DFU devices first.

The helper refuses zero or multiple present DFU devices, rechecks the exact instance after elevation and immediately before installation, and targets only VID 0483/PID DF11. It never invokes firmware flashing. A successful native installer exit is followed by checking the bound Windows service and device status; if binding is not confirmed, reconnect in DFU and use **Check USB**. Browser permissions and another program holding USB are separate issues this installer cannot fix.

Original Zadig is included as a manual fallback with WinUSB selected by default and hubs hidden. Its list is not restricted to STM32: always verify **0483 DF11** before installing. Upstream Zadig presets create a driver package; they do not filter the live device list, so the helper does not pretend a preset provides that protection.

Temporary files and installation log are kept in the per-run `%TEMP%\Malahit-DFU-<random>` folder shown by the application. No global policy, driver-signature enforcement or browser settings are changed. Windows may warn because our wrapper EXE has no Authenticode signature; it is not signed by MALAHITEAM or Microsoft. .NET Framework 4.x is required (included with Windows 10/11). ARM64 is not validated.

## Components and licenses

Our C# wrapper: GPL-3.0-or-later, source in this folder. Build on Windows using `powershell -File tools/dfu-driver/build.ps1`; GitHub Actions also builds and runs `--self-test` without installing drivers. `COPYING` and `COPYING-LGPL` are embedded and extracted with the original tools.

- [QMK driver installer v1.01](https://github.com/qmk/qmk_driver_installer/releases/tag/v1.01), based on libwdi; original EXE unchanged, SHA-256 `ccd78a40e3db74a189f42e3eab93463ef6c214c4f928b586992d70863b094431`. [Corresponding source](https://github.com/qmk/qmk_driver_installer/tree/v1.01).
- [Zadig 2.9 / libwdi v1.5.1](https://github.com/pbatard/libwdi/releases/tag/v1.5.1); original EXE unchanged, SHA-256 `4ecaa95df3da3621486a043aef8b3050b8bafe7c901402871e816229ef82039b`. [Corresponding source](https://github.com/pbatard/libwdi/tree/v1.5.1), [Zadig settings](https://github.com/pbatard/libwdi/wiki/Zadig).

Both EXEs were compared byte-for-byte with their upstream release downloads. Source/build/self-test evidence does not prove successful installation on a physical receiver; that requires Windows hardware acceptance.
