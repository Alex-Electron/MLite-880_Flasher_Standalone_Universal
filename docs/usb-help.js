/* USB connection advice only. Never installs a driver or starts firmware writing. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.MalahitUsbHelp = factory();
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const download = 'https://github.com/Alex-Electron/MLite-880_Flasher_Standalone_Universal/releases/download/dfu-driver-v1.0.0/Malahit-STM32-DFU-Setup.exe';
  function classify(error, stage) {
    const name = error && error.name || '';
    if (stage === 'request' && name === 'NotFoundError') return 'cancel';
    if (stage === 'request' && (name === 'SecurityError' || name === 'NotAllowedError')) return 'permission';
    if (stage === 'open') return 'open';
    if (stage === 'interface' || stage === 'memory-map') return 'device';
    return 'other';
  }
  function platform(ua) {
    if (/Windows/i.test(ua)) return 'windows';
    if (/Android/i.test(ua)) return 'android';
    if (/Macintosh|Mac OS/i.test(ua)) return 'mac';
    if (/Linux/i.test(ua)) return 'linux';
    return 'other';
  }
  const translations = {
    en: {
      usb_title: 'USB connection help', usb_help: '[ USB CONNECTION HELP ]', usb_download: 'Download Windows USB setup (.exe)', usb_retry: '[ RETRY CONNECTION ]', usb_close: '[ CLOSE ]',
      usb_cancel: 'No device selected. If the receiver is missing from the list, open USB connection help below.',
      usb_permission: 'The browser did not allow the USB request. Open site settings using the icon next to the address, find USB devices and allow this site to ask for access. In Chrome you can also check chrome://settings/content/usbDevices. A managed-browser policy may require your administrator. This does not establish a driver fault.',
      usb_open: 'The receiver was selected, but the DFU interface could not be opened. Close other flashers, dfu-util, STM32CubeProgrammer and other tabs using the receiver; reconnect USB in DFU mode. The browser cannot determine the exact cause from this error alone.',
      usb_other: 'Check that the intended receiver is connected in DFU mode according to its manual, using a USB data cable. Then retry. This error alone does not prove that a driver is missing.',
      usb_windows: 'Windows: if opening still fails, WinUSB may be missing or bound incorrectly. Download the single EXE below, run it, confirm the intended receiver and click Install WinUSB; approve the Windows administrator prompt. No manual extraction is needed. It supports MALAHIT MLite/DSP receivers exposing STM32 DFU 0483:DF11. Disconnect other STM32 DFU devices first. Then return here and retry. Firmware and browser permissions are not changed.',
      usb_mac: 'macOS: WinUSB is not needed. Unlock the Mac and approve the USB accessory prompt if shown. Check System Settings → Privacy & Security → Allow accessories to connect.',
      usb_linux: 'Linux: check USB permissions and the udev instructions in Help. Reconnect USB after applying the rule. A Windows driver installer will not help on Linux.',
      usb_android: 'Android: approve both the browser device chooser and the Android USB permission prompt. Check the OTG data cable and receiver power.',
      usb_manual: 'Enter DFU according to the manual for your model. For MLite-880: hold 1 at power-on for 3 seconds. USB ID 0483:DF11 identifies STM32 DFU, not the receiver model. Select only the intended receiver.',
      usb_unsigned: 'This community setup EXE is not digitally signed; Windows may show a warning. Source code and component details are available in the repository.',
      usb_source: 'Setup source and component details', usb_details: 'Technical details'
    },
    ru: {
      usb_title: 'Помощь с подключением USB', usb_help: '[ ПОМОЩЬ С USB ]', usb_download: 'Скачать настройку USB для Windows (.exe)', usb_retry: '[ ПОВТОРИТЬ ПОДКЛЮЧЕНИЕ ]', usb_close: '[ ЗАКРЫТЬ ]',
      usb_cancel: 'Устройство не выбрано. Если приёмника нет в списке, откройте помощь с USB под кнопкой подключения.',
      usb_permission: 'Браузер не разрешил запрос USB. Нажмите значок настроек слева от адреса, найдите USB-устройства и разрешите сайту запрашивать доступ. В Chrome также можно проверить chrome://settings/content/usbDevices. Ограничение управляемого браузера может потребовать обращения к администратору. Эта ошибка не доказывает неисправность драйвера.',
      usb_open: 'Приёмник выбран, но открыть DFU-интерфейс не удалось. Закройте другие прошивальщики, dfu-util, STM32CubeProgrammer и вкладки, использующие приёмник; переподключите USB в режиме DFU. По одной этой ошибке браузер не может определить точную причину.',
      usb_other: 'Проверьте подключение нужного приёмника USB-кабелем с передачей данных и режим DFU по руководству вашей модели. Затем повторите подключение. Сама ошибка не доказывает отсутствие драйвера.',
      usb_windows: 'Windows: если открыть устройство по-прежнему не удаётся, возможно, отсутствует или неверно привязан WinUSB. Скачайте один EXE ниже, запустите, подтвердите нужный приёмник и нажмите «Установить WinUSB»; разрешите запрос прав администратора Windows. Распаковывать ничего не нужно. Поддерживаются приёмники «Малахит» MLite/DSP с STM32 DFU 0483:DF11. Другие STM32 DFU предварительно отключите. Затем вернитесь сюда и повторите подключение. Прошивка и разрешения браузера не меняются.',
      usb_mac: 'macOS: WinUSB не нужен. Разблокируйте Mac и разрешите подключение USB-аксессуара, если появится запрос. Проверьте «Системные настройки → Конфиденциальность и безопасность → Разрешить подключение аксессуаров».',
      usb_linux: 'Linux: проверьте права USB и инструкцию udev в разделе помощи. После применения правила переподключите USB. Установщик Windows на Linux не поможет.',
      usb_android: 'Android: подтвердите выбор устройства в браузере и системный запрос доступа к USB. Проверьте OTG-кабель с передачей данных и питание приёмника.',
      usb_manual: 'Входите в DFU по руководству вашей модели. Для MLite-880: удерживайте 1 при включении 3 секунды. USB ID 0483:DF11 определяет STM32 DFU, а не модель приёмника. Выбирайте только нужный приёмник.',
      usb_unsigned: 'Этот EXE от сообщества не имеет цифровой подписи; Windows может показать предупреждение. Исходники и состав пакета доступны в репозитории.',
      usb_source: 'Исходники установщика и состав пакета', usb_details: 'Технические сведения'
    },
    de: {
      usb_title: 'Hilfe zur USB-Verbindung', usb_help: '[ USB-HILFE ]', usb_download: 'Windows-USB-Setup herunterladen (.exe)', usb_retry: '[ ERNEUT VERBINDEN ]', usb_close: '[ SCHLIESSEN ]',
      usb_cancel: 'Kein Gerät ausgewählt. Fehlt der Empfänger, öffnen Sie die USB-Hilfe unter der Verbindungsschaltfläche.',
      usb_permission: 'Der Browser hat die USB-Anfrage nicht erlaubt. Öffnen Sie die Website-Einstellungen neben der Adresse und erlauben Sie USB-Anfragen. In Chrome: chrome://settings/content/usbDevices. Eine Verwaltungsrichtlinie kann einen Administrator erfordern. Dies beweist keinen Treiberfehler.',
      usb_open: 'Der Empfänger wurde ausgewählt, aber die DFU-Schnittstelle ließ sich nicht öffnen. Schließen Sie andere Flasher, dfu-util, STM32CubeProgrammer und andere Tabs mit USB-Zugriff. Verbinden Sie USB im DFU-Modus erneut. Die genaue Ursache ist im Browser nicht eindeutig erkennbar.',
      usb_other: 'Prüfen Sie Datenkabel und DFU-Modus gemäß der Anleitung Ihres Modells. Versuchen Sie es erneut. Dieser Fehler allein beweist keinen fehlenden Treiber.',
      usb_windows: 'Windows: WinUSB fehlt möglicherweise oder ist falsch zugeordnet. Laden Sie die einzelne EXE herunter, starten Sie sie, bestätigen Sie den Empfänger und klicken Sie auf Install WinUSB. Bestätigen Sie die Windows-Administratorabfrage. Kein manuelles Entpacken. Für MALAHIT MLite/DSP mit STM32 DFU 0483:DF11. Trennen Sie vorher andere STM32-DFU-Geräte. Danach hier erneut verbinden. Firmware und Browserberechtigungen bleiben unverändert.',
      usb_mac: 'macOS benötigt kein WinUSB. Entsperren Sie den Mac und erlauben Sie das USB-Zubehör. Prüfen Sie Systemeinstellungen → Datenschutz & Sicherheit → Verbinden von Zubehör erlauben.',
      usb_linux: 'Linux: Prüfen Sie die USB-Rechte und die udev-Anleitung unter Hilfe. Danach USB neu verbinden. Der Windows-Installer hilft unter Linux nicht.',
      usb_android: 'Android: Bestätigen Sie Geräteauswahl und Android-USB-Berechtigung. Prüfen Sie OTG-Datenkabel und Stromversorgung.',
      usb_manual: 'DFU gemäß Modellanleitung aktivieren. MLite-880: beim Einschalten 1 für 3 Sekunden halten. 0483:DF11 kennzeichnet STM32 DFU, nicht das Empfängermodell. Wählen Sie nur den gewünschten Empfänger.',
      usb_unsigned: 'Diese Community-EXE ist nicht digital signiert; Windows kann warnen. Quellcode und Komponenten stehen im Repository.', usb_source: 'Setup-Quellcode und Komponenten', usb_details: 'Technische Details'
    },
    be: {
      usb_title: 'Дапамога з USB', usb_help: '[ ДАПАМОГА З USB ]', usb_download: 'Спампаваць наладку USB для Windows (.exe)', usb_retry: '[ ПАЎТАРЫЦЬ ПАДКЛЮЧЭННЕ ]', usb_close: '[ ЗАКРЫЦЬ ]',
      usb_cancel: 'Прылада не выбрана. Калі прымача няма ў спісе, адкрыйце дапамогу з USB пад кнопкай падключэння.',
      usb_permission: 'Браўзер не дазволіў запыт USB. Адкрыйце налады сайта побач з адрасам і дазвольце запыты USB. У Chrome: chrome://settings/content/usbDevices. Палітыка кіраванага браўзера можа патрабаваць адміністратара. Гэта не даказвае памылку драйвера.',
      usb_open: 'Прымач выбраны, але DFU-інтэрфейс не адкрыўся. Закрыйце іншыя прашывальнікі, dfu-util, STM32CubeProgrammer і ўкладкі з доступам да прымача. Перападключыце USB ў DFU. Дакладная прычына па гэтай памылцы невядомая.',
      usb_other: 'Праверце кабель перадачы даных і рэжым DFU паводле кіраўніцтва вашай мадэлі. Паўтарыце падключэнне. Памылка сама па сабе не даказвае адсутнасць драйвера.',
      usb_windows: 'Windows: магчыма, WinUSB адсутнічае або няправільна прывязаны. Спампуйце адзін EXE, запусціце, пацвердзіце прымач і націсніце Install WinUSB; дазвольце правы адміністратара Windows. Распакоўка не патрэбна. Для MALAHIT MLite/DSP з STM32 DFU 0483:DF11. Іншыя STM32 DFU адключыце. Потым паўтарыце падключэнне тут. Прашыўка і дазволы браўзера не змяняюцца.',
      usb_mac: 'macOS: WinUSB не патрэбны. Разблакіруйце Mac і дазвольце USB-аксесуар. Праверце налады прыватнасці і бяспекі для аксесуараў.',
      usb_linux: 'Linux: праверце правы USB і інструкцыю udev у дапамозе. Затым перападключыце USB. Усталёўшчык Windows тут не дапаможа.',
      usb_android: 'Android: пацвердзіце выбар прылады ў браўзеры і сістэмны дазвол USB. Праверце OTG-кабель і сілкаванне.',
      usb_manual: 'Увайдзіце ў DFU паводле кіраўніцтва мадэлі. MLite-880: трымайце 1 пры ўключэнні 3 секунды. 0483:DF11 вызначае STM32 DFU, а не мадэль. Выбірайце толькі патрэбны прымач.',
      usb_unsigned: 'EXE супольнасці без лічбавага подпісу; Windows можа паказаць папярэджанне. Зыходнікі і склад ёсць у рэпазіторыі.', usb_source: 'Зыходнікі і склад усталёўшчыка', usb_details: 'Тэхнічныя звесткі'
    },
    uk: {
      usb_title: 'Допомога з USB', usb_help: '[ ДОПОМОГА З USB ]', usb_download: 'Завантажити налаштування USB для Windows (.exe)', usb_retry: '[ ПОВТОРИТИ ПІДКЛЮЧЕННЯ ]', usb_close: '[ ЗАКРИТИ ]',
      usb_cancel: 'Пристрій не вибрано. Якщо приймача немає у списку, відкрийте допомогу з USB під кнопкою підключення.',
      usb_permission: 'Браузер не дозволив запит USB. Відкрийте налаштування сайту біля адреси й дозвольте запити USB. У Chrome: chrome://settings/content/usbDevices. Політика керованого браузера може вимагати адміністратора. Це не доводить несправність драйвера.',
      usb_open: 'Приймач вибрано, але відкрити DFU-інтерфейс не вдалося. Закрийте інші прошивальники, dfu-util, STM32CubeProgrammer та вкладки з доступом до приймача. Перепідключіть USB у DFU. Точна причина за цією помилкою невідома.',
      usb_other: 'Перевірте кабель передачі даних і режим DFU за посібником вашої моделі. Повторіть підключення. Помилка сама по собі не доводить відсутність драйвера.',
      usb_windows: 'Windows: можливо, WinUSB відсутній або неправильно прив’язаний. Завантажте один EXE, запустіть, підтвердьте приймач і натисніть Install WinUSB; дозвольте права адміністратора Windows. Розпаковування не потрібне. Для MALAHIT MLite/DSP зі STM32 DFU 0483:DF11. Інші STM32 DFU від’єднайте. Потім повторіть підключення тут. Прошивка й дозволи браузера не змінюються.',
      usb_mac: 'macOS: WinUSB не потрібний. Розблокуйте Mac і дозвольте USB-аксесуар. Перевірте налаштування приватності й безпеки для аксесуарів.',
      usb_linux: 'Linux: перевірте права USB й інструкцію udev у допомозі. Потім перепідключіть USB. Інсталятор Windows тут не допоможе.',
      usb_android: 'Android: підтвердьте вибір пристрою в браузері й системний дозвіл USB. Перевірте OTG-кабель і живлення.',
      usb_manual: 'Увійдіть у DFU за посібником моделі. MLite-880: тримайте 1 під час увімкнення 3 секунди. 0483:DF11 визначає STM32 DFU, а не модель. Вибирайте лише потрібний приймач.',
      usb_unsigned: 'EXE спільноти без цифрового підпису; Windows може показати попередження. Вихідний код і склад є в репозиторії.', usb_source: 'Вихідний код і склад інсталятора', usb_details: 'Технічні відомості'
    }
  };
  function text(lang) { return translations[lang] || translations.en; }
  function advice(kind, os, lang) {
    const t = text(lang);
    let message = t['usb_' + kind] || t.usb_other;
    if (kind !== 'permission') {
      if (t['usb_' + os] && (os !== 'windows' || kind === 'open' || kind === 'other')) message += '\n\n' + t['usb_' + os];
    }
    return { message, download: os === 'windows' && (kind === 'open' || kind === 'other') };
  }
  return { classify, platform, text, advice, download };
});
