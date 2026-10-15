// SPDX-License-Identifier: GPL-3.0-or-later
// MALAHIT STM32 DFU Setup. No firmware is read, erased or written.
using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Management;
using System.Reflection;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Forms;

[assembly: AssemblyTitle("MALAHIT STM32 DFU USB Setup")]
[assembly: AssemblyDescription("WinUSB setup for STM32 DFU 0483:DF11; no firmware flashing")]
[assembly: AssemblyCompany("Alex-Electron")]
[assembly: AssemblyProduct("MALAHIT STM32 DFU Setup")]
[assembly: AssemblyVersion("1.0.0.0")]

internal sealed class DfuDevice
{
    internal string Id, Name, Service;
    internal int Problem;
}

internal static class Setup
{
    internal const string QmkHash = "ccd78a40e3db74a189f42e3eab93463ef6c214c4f928b586992d70863b094431";
    internal const string ZadigHash = "4ecaa95df3da3621486a043aef8b3050b8bafe7c901402871e816229ef82039b";
    internal const string Csv = "winusb,STM32 Bootloader,0483,df11,6d98a87f-4ecf-464d-89ed-8c684d857a75\r\n";
    internal const string Ini = "[general]\r\nadvanced_mode=false\r\nexit_on_success=true\r\nlog_level=1\r\n[device]\r\nlist_all=true\r\ninclude_hubs=false\r\n[driver]\r\ndefault_driver=0\r\nextract_only=false\r\n";
    internal const string Project = "https://github.com/Alex-Electron/MLite-880_Flasher_Standalone_Universal";
    internal static readonly bool Russian = System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ru";
    internal static string T(string ru, string en) { return Russian ? ru : en; }

    internal static bool IsDfu(string id)
    {
        // Match the physical DFU device, never audio/serial or composite children.
        return id != null && Regex.IsMatch(id, @"^USB\\VID_0483&PID_DF11\\[A-Z0-9&_\-]+$", RegexOptions.IgnoreCase);
    }

    internal static DfuDevice[] FindDevices()
    {
        using (var query = new ManagementObjectSearcher("SELECT Name, PNPDeviceID, Service, ConfigManagerErrorCode FROM Win32_PnPEntity WHERE Present = TRUE"))
        using (var devices = query.Get())
        {
            return devices.Cast<ManagementObject>().Where(d => IsDfu(d["PNPDeviceID"] as string))
                .Select(d => new DfuDevice { Id = (string)d["PNPDeviceID"], Name = d["Name"] as string ?? "STM32 DFU",
                    Service = d["Service"] as string ?? "(none)", Problem = Convert.ToInt32(d["ConfigManagerErrorCode"]) }).ToArray();
        }
    }

    internal static DfuDevice OnlyDevice(string expected = null)
    {
        var devices = FindDevices();
        if (devices.Length != 1) throw new InvalidOperationException(devices.Length == 0
            ? T("STM32 DFU 0483:DF11 не найден. Подключите приёмник в режиме DFU по его руководству и нажмите «Проверить USB».",
                "STM32 DFU 0483:DF11 was not found. Connect the receiver in DFU mode according to its manual, then click Check USB.")
            : T("Найдено несколько STM32 DFU. Оставьте подключённым только нужный приёмник.",
                "Multiple STM32 DFU devices found. Leave only the intended receiver connected."));
        if (expected != null && !String.Equals(expected, devices[0].Id, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException(T("Устройство изменилось. Запустите установщик заново.", "The device changed. Start setup again."));
        return devices[0];
    }

    internal static byte[] Resource(string name)
    {
        using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(name))
        using (var buffer = new MemoryStream()) { if (stream == null) throw new IOException("Missing resource: " + name); stream.CopyTo(buffer); return buffer.ToArray(); }
    }

    internal static string Hash(byte[] bytes)
    {
        using (var sha = SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
    }

    internal static string Extract()
    {
        var qmk = Resource("qmk.exe"); var zadig = Resource("zadig.exe");
        if (Hash(qmk) != QmkHash || Hash(zadig) != ZadigHash) throw new IOException("Embedded executable checksum mismatch.");
        string folder = Path.Combine(Path.GetTempPath(), "Malahit-DFU-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(folder);
        File.WriteAllBytes(Path.Combine(folder, "qmk.exe"), qmk);
        File.WriteAllBytes(Path.Combine(folder, "zadig.exe"), zadig);
        File.WriteAllText(Path.Combine(folder, "drivers.txt"), Csv, Encoding.ASCII);
        File.WriteAllText(Path.Combine(folder, "zadig.ini"), Ini, Encoding.ASCII);
        File.WriteAllBytes(Path.Combine(folder, "COPYING"), Resource("COPYING"));
        File.WriteAllBytes(Path.Combine(folder, "COPYING-LGPL"), Resource("COPYING-LGPL"));
        return folder;
    }

    internal static string Quote(string argument)
    {
        return "\"" + Regex.Replace(Regex.Replace(argument, @"(\\*)""", "$1$1\\\""), @"(\\+)$", "$1$1") + "\"";
    }

    internal static bool IsAdmin()
    {
        using (var identity = WindowsIdentity.GetCurrent()) return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
    }

    internal static void SelfTest()
    {
        if (!IsDfu(@"USB\VID_0483&PID_DF11\123ABC") || !IsDfu(@"usb\vid_0483&pid_df11\5&123&0&1")) throw new Exception("DFU matching failed");
        foreach (string id in new[] { "", @"USB\VID_0483&PID_DF12\ABC", @"USB\VID_0483&PID_DF11&MI_00\ABC", @"XUSB\VID_0483&PID_DF11\ABC", @"USB\VID_0483&PID_DF11\ABC" + "\"" })
            if (IsDfu(id)) throw new Exception("Unsafe device accepted: " + id);
        if (Hash(Resource("qmk.exe")) != QmkHash || Hash(Resource("zadig.exe")) != ZadigHash) throw new Exception("Resource hashes failed");
        if (Csv.Trim().Split(',').Length != 5 || !Csv.StartsWith("winusb,STM32 Bootloader,0483,df11,")) throw new Exception("Unsafe driver target");
        if (Quote(@"C:\path with spaces\qmk.exe") != "\"C:\\path with spaces\\qmk.exe\"") throw new Exception("Path quoting failed");
        if (Quote("a\"b") != "\"a\\\"b\"") throw new Exception("Quote escaping failed");
        if (Resource("COPYING").Length < 1000 || Resource("COPYING-LGPL").Length < 1000) throw new Exception("Licenses missing");
    }

    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length == 1 && args[0] == "--self-test") { try { SelfTest(); return 0; } catch { return 1; } }
        Application.EnableVisualStyles(); Application.SetCompatibleTextRenderingDefault(false);
        string expected = args.Length == 2 && args[0] == "--install" && IsDfu(args[1]) ? args[1] : null;
        if (args.Length > 0 && expected == null) return 2;
        Application.Run(new SetupForm(expected));
        return 0;
    }
}

internal sealed class SetupForm : Form
{
    private readonly Label status = new Label();
    private readonly Button install = new Button(), check = new Button(), manual = new Button();
    private readonly Label confirm = new Label();
    private readonly string expected;
    private bool busy;
    private string folder;

    internal SetupForm(string expectedId)
    {
        expected = expectedId;
        Text = "MALAHIT · STM32 DFU USB Setup 1.0.0";
        ClientSize = new Size(620, 490); MinimumSize = new Size(580, 510); StartPosition = FormStartPosition.CenterScreen;
        Font = new Font("Segoe UI", 10); AutoScaleMode = AutoScaleMode.Dpi;
        var layout = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(20), ColumnCount = 1, RowCount = 7 };
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 95));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 62));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 45));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 40));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 40));
        layout.Controls.Add(new Label { Text = Setup.T("Настройка USB для приёмников «Малахит»", "USB setup for MALAHIT receivers"), Font = new Font(Font.FontFamily, 15, FontStyle.Bold), Dock = DockStyle.Fill }, 0, 0);
        layout.Controls.Add(new Label { Text = Setup.T(
            "Подключите один нужный приёмник в режиме DFU по его руководству. Для MLite-880: удерживайте 1 при включении, подождите 3 секунды.\r\nУстанавливается только WinUSB для STM32 DFU 0483:DF11. Прошивка приёмника не меняется.",
            "Connect only the intended receiver in DFU mode according to its manual. MLite-880: hold 1 at power-on for 3 seconds.\r\nInstalls WinUSB for STM32 DFU 0483:DF11 only. Receiver firmware is not changed."), Dock = DockStyle.Fill }, 0, 1);
        status.Dock = DockStyle.Fill; status.BorderStyle = BorderStyle.FixedSingle; status.Padding = new Padding(8); status.AutoEllipsis = true;
        layout.Controls.Add(status, 0, 2);
        confirm.Text = Setup.T("Нажимая «Установить WinUSB», вы подтверждаете, что это нужный приёмник. ID 0483:DF11 сам по себе не определяет модель.",
            "By clicking Install WinUSB you confirm this is the intended receiver. ID 0483:DF11 alone does not identify the model.");
        confirm.Dock = DockStyle.Fill; layout.Controls.Add(confirm, 0, 3);
        install.Text = Setup.T("Установить WinUSB", "Install WinUSB"); install.Dock = DockStyle.Fill; install.Click += async delegate { await Install(); }; layout.Controls.Add(install, 0, 4);
        check.Text = Setup.T("Проверить USB", "Check USB"); check.Dock = DockStyle.Fill; check.Click += delegate { RefreshDevice(); }; layout.Controls.Add(check, 0, 5);
        manual.Text = Setup.T("Открыть оригинальный Zadig (вручную)", "Open original Zadig (manual)"); manual.Dock = DockStyle.Fill; manual.Click += delegate { OpenZadig(); }; layout.Controls.Add(manual, 0, 6);
        Controls.Add(layout);
        FormClosing += delegate(object sender, FormClosingEventArgs e) { if (busy) e.Cancel = true; };
        Shown += async delegate { RefreshDevice(); if (expected != null) await Install(); };
    }

    private void SetStatus(string text, bool success = false) { status.Text = text; status.ForeColor = success ? Color.DarkGreen : Color.Black; }
    private void UpdateButtons() { install.Enabled = !busy; manual.Enabled = !busy; check.Enabled = !busy; }
    private void RefreshDevice()
    {
        try {
            var d = Setup.OnlyDevice(expected);
            bool ready = String.Equals(d.Service, "WinUSB", StringComparison.OrdinalIgnoreCase) && d.Problem == 0;
            SetStatus(d.Name + "\r\n" + d.Id + "\r\nDriver: " + d.Service + " · Windows status: " + d.Problem + "\r\n\r\n" +
                (ready ? Setup.T("WinUSB уже работает. Вернитесь в браузер и подключитесь снова.", "WinUSB is ready. Return to the browser and connect again.") :
                Setup.T("Можно установить WinUSB. Windows запросит права администратора.", "WinUSB can be installed. Windows will request administrator permission.")), ready);
        } catch (Exception e) { SetStatus(e.Message); }
        UpdateButtons();
    }

    private string WorkFolder() { if (folder == null) folder = Setup.Extract(); return folder; }

    private async Task Install()
    {
        if (busy) return;
        busy = true; UpdateButtons();
        try {
            var target = Setup.OnlyDevice(expected);
            if (!Setup.IsAdmin()) {
                Process.Start(new ProcessStartInfo { FileName = Assembly.GetExecutingAssembly().Location,
                    Arguments = "--install " + Setup.Quote(target.Id), UseShellExecute = true, Verb = "runas" });
                busy = false; Close(); return;
            }
            string work = WorkFolder();
            SetStatus(Setup.T("Устанавливается WinUSB… Не отключайте USB.", "Installing WinUSB… Keep USB connected."));
            // Recheck after extraction and elevation; the CSV contains only this VID/PID.
            Setup.OnlyDevice(target.Id);
            string logfile = Path.Combine(work, "install.log");
            int code = await Task.Run(() => {
                using (var process = new Process { StartInfo = new ProcessStartInfo {
                    FileName = Path.Combine(work, "qmk.exe"), Arguments = "--force " + Setup.Quote(Path.Combine(work, "drivers.txt")),
                    WorkingDirectory = work, UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true, RedirectStandardError = true } }) {
                    process.Start();
                    var output = process.StandardOutput.ReadToEndAsync(); var errors = process.StandardError.ReadToEndAsync();
                    process.WaitForExit(); Task.WaitAll(output, errors);
                    File.WriteAllText(logfile, "Exit: " + process.ExitCode + "\r\n" + output.Result + errors.Result);
                    return process.ExitCode;
                }
            });
            if (code != 0) throw new IOException(Setup.T("Установка завершилась с ошибкой. Журнал: ", "Installation failed. Log: ") + logfile);
            // Driver staging alone is not acceptance: inspect the actual bound service.
            await Task.Delay(1200);
            var actual = Setup.OnlyDevice(target.Id);
            bool ready = String.Equals(actual.Service, "WinUSB", StringComparison.OrdinalIgnoreCase) && actual.Problem == 0;
            SetStatus((ready ? Setup.T("WinUSB установлен и привязан к устройству.\r\nВернитесь в браузер и подключитесь снова.",
                "WinUSB is installed and bound to the device.\r\nReturn to the browser and connect again.") :
                Setup.T("Пакет установлен, но привязка WinUSB ещё не подтверждена. Переподключите USB, снова войдите в DFU и нажмите «Проверить USB».",
                "Driver package installed; WinUSB binding is not yet confirmed. Reconnect USB in DFU mode, then click Check USB.")) + "\r\n\r\n" + logfile, ready);
        } catch (System.ComponentModel.Win32Exception e) {
            SetStatus(e.NativeErrorCode == 1223 ? Setup.T("Запрос прав администратора отменён. Драйвер не устанавливался.", "Administrator prompt cancelled. No driver was installed.") : e.Message);
        } catch (Exception e) { SetStatus(e.Message); }
        finally { busy = false; UpdateButtons(); }
    }

    private void OpenZadig()
    {
        try {
            Setup.OnlyDevice();
            if (MessageBox.Show(Setup.T("В Zadig выберите только USB ID 0483 DF11 и драйвер WinUSB. В списке могут быть другие устройства — не меняйте их драйверы.",
                "In Zadig select only USB ID 0483 DF11 and WinUSB. Other devices may be listed; do not change their drivers."), "Zadig", MessageBoxButtons.OKCancel) != DialogResult.OK) return;
            string work = WorkFolder(); Setup.OnlyDevice();
            Process.Start(new ProcessStartInfo { FileName = Path.Combine(work, "zadig.exe"), WorkingDirectory = work, UseShellExecute = true, Verb = "runas" });
        } catch (Exception e) { SetStatus(e.Message); }
    }
}
