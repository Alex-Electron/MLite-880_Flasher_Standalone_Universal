# MLite-880 Firmware Changelog

Firmware author: **RX9CIM (Георгий)**.

Sources:
- «Технический чат - MLite-880» Telegram topic — discussion + occasional release notes by the author. Export window: 2026-02-03 — 2026-05-27.
- «Прошивки» Telegram topic — author's release-only posts (consolidated changelogs). Coverage: 2024-04-25 — 2026-05-27.

This document is NOT the flasher changelog — for that see [CHANGELOG.md](CHANGELOG.md).
This file collects what changed inside each firmware `.bin`, based on what the author wrote in the chat.

Each release section has an **English** block and a **Русский** block. Author's direct quotes are kept in Russian inside the Русский block; the English block paraphrases them. Author's naming is preserved: `1.20` and `1.2` mean the same build, same with `1.51`/`1.5`, etc.

Firmware files the author actually attached to the chat:

| Version | File name in chat | Message timestamp |
| ------- | ----------------- | ----------------- |
| 1.20 | `MLite_1_2_060226.zip` | 2026-02-19 15:27 (build dated 2026-02-06) |
| 1.30 | *— (not attached to chat; released on `malahiteam.com`)* | 2026-03-15 21:24 release post in «Прошивки» topic |
| 1.51 | `MLite880_1_51_180526.zip` | 2026-05-18 12:39 |
| 1.52 | `MLite880_1_52_190526.zip` | 2026-05-19 07:58 |
| 1.53 | `MLite880_1_53_210526.zip` | 2026-05-21 21:14 |
| 1.54 | `MLite880_1_54_250526.zip` | 2026-05-25 08:55 |
| 1.55 | `MLite880_1_55_270526.zip` | 2026-05-27 08:39 (re-upload) |
| 1.56 | `MLite880_1_56_020626.zip` | 2026-06-02 12:00 |
| 1.57 | `MLite880_1_57_080626.zip` | 2026-06-08 12:44 |

Firmware 1.40 and 1.50 were never posted to the chat nor to «Прошивки» — the author calls both "interim" releases (1.40 was a factory-only build for new hardware, 1.50 leaked through the manufacturer and was effectively rolled into 1.51).

---

## [1.57] — 2026-06-08

### English

Author's release post: 2026-06-08.

The author did not publish a detailed changelog for this build. His summary:
- Bug fixes.
- Performance improvements.

### Русский

Релизное сообщение автора: 2026-06-08.

Подробный список изменений автор не публиковал. Его краткое резюме:
- Исправлены баги.
- Улучшена производительность.

---

## [1.56] — 2026-06-02

### English

Author's release post: 2026-06-02.

**Added:**
- SAMU and SAML modes added. Switch using button 9 in menu 2 (select SAM first, then cycle through SAM, SAMU, SAML).
- Menu 0: "GEN" function added to return to the frequency, modulation, and step settings used before selecting a preset.
- Menu 1, page 1, item 4: option to toggle whether presets are used when entering frequency.
- Menu "About": now displays the hardware version.

**Changed:**
- Encoder auto-reset: if in "Volume" mode, it automatically returns to "Frequency" mode after 5 seconds of inactivity. Note: if Volume mode was entered using the `#` key, the auto-reset is disabled.
- S-meter accuracy improved (though it remains an indicative "posometer").
- Preset editing remains restricted to menu 0 only.

### Русский

Релизное сообщение автора: 2026-06-02.

**Добавлено:**
- Добавлены режимы SAMU и SAML. Переключаются кнопкой 9 в меню 2 (сначала нужно выбрать SAM, а затем — конкретный тип: SAM, SAMU, SAML).
- В меню 0 добавлена функция GEN — возврат к частоте, модуляции и шагу, которые были до выбора пресета.
- В меню 1 (стр. 1, пункт 4) добавлена настройка: использовать ли пресеты при вводе частоты.
- В меню About теперь указывается версия железа.

**Изменено:**
- Сброс энкодера: если установлен режим ГРОМКОСТЬ, через 5 секунд бездействия он автоматически переключается в режим ЧАСТОТА. Если режим ГРОМКОСТЬ был выбран кнопкой `#`, автосброс не происходит.
- Повышена точность S-метра (остаётся оценочным «показометром»).
- Редактирование пресетов по-прежнему доступно только при их выборе через меню 0.

---

## [1.55] — 2026-05-27

### English

Author's release post: 2026-05-27 07:38:41.

**Added:**
- Presets: new "Another bands" tab with pirate radio bands.
- Presets: NOAA band added.

**Changed:**
- MW preset extended to 510–1710 kHz. Scan step is 10 kHz when the preset itself is configured for 10 kHz, otherwise 9 kHz.
- The archive now contains `.hex` instead of `.bin` — the author says this was done "so that some people don't run into address issues in Cube" (RX9CIM, 2026-05-27 07:59).

**Fixed:**
- Preset handling (the author reminds users that presets can only be edited when called from menu 0).
- Reception on 108 MHz.
- The letter "P" in the font.

### Русский

Релизное сообщение автора: 2026-05-27 07:38:41.

**Добавлено:**
- В пресетах добавлена вкладка «Another bands» с пиратскими диапазонами.
- В пресеты добавлен диапазон NOAA.

**Изменено:**
- Расширен пресет MW: теперь 510–1710 кГц. Если в пресете установлен шаг 10 кГц — сканирование идёт с шагом 10 кГц, в иных случаях — 9 кГц.
- В архив вложен `*.hex` вместо `*.bin` — «специально сделано, чтобы у некоторых не было проблем с адресами в Cube» (RX9CIM, 2026-05-27 07:59).

**Исправлено:**
- Ошибка при работе с пресетами (напоминание автора: пресеты можно редактировать только выбрав их в меню 0).
- Ошибка приёма на частоте 108 МГц.
- Буква «P» в шрифте.

---

## [1.54] — 2026-05-25

### English

Author's release post: 2026-05-25 08:58:32 (file attached at 08:55).

**Added:**
- Extra encoder speed when holding `*`.
- Band labels displayed below the battery icon ("25 m", "31 m", etc.).

**Changed:**
- Preset handling only takes effect when the preset is invoked from menu 0. In that case step, modulation and frequency are saved into the preset; otherwise they are not.

**Fixed:**
- The 108 MHz reception bug.
- The "step in presets" bug (mentioned earlier in the chat).

### Русский

Релизное сообщение автора: 2026-05-25 08:58:32 (файл выложен в 08:55).

**Добавлено:**
- Экстра-скорость энкодера при нажатии «*».
- Отображение диапазонов под знаком батарейки (метровые обозначения «25 m», «31 m» и т.п.).

**Изменено:**
- Работа с пресетами осуществляется только при вызове пресета из меню 0. Если пресет вызывался из меню 0, то шаг, модуляция и частота в нём будут сохраняться, иначе — не будут.

**Исправлено:**
- Баг с частотой 108 МГц.
- Баг с сохранением шага в пресетах (упоминался в чате ранее).

---

## [1.53] — 2026-05-21

### English

Author's release post: 2026-05-21 21:04:07 (file attached at 21:14).

**Fixed:**
- A memory-handling bug.
- Presets — saving should now work.
- Entering 133.2 (MHz).

**Known issues reported in the chat:**
- Right after the release users reported a 108 MHz FM bug — no signal exactly at 108.000, but it appears at 107.995. Author: "That's what caused the lockup in the firmware."
- A user on 2026-05-24 21:03 confirms the same 108 MHz bug existed in 1.52.

### Русский

Релизное сообщение автора: 2026-05-21 21:04:07 (файл выложен в 21:14).

**Исправлено:**
- Баг с памятью.
- Пресеты — теперь сохранение должно работать.
- Баг с вводом 133.2 (МГц).

**Известные проблемы (по чату):**
- Пользователи сразу после релиза сообщили о баге с частотой 108 МГц на FM (отсутствие сигнала ровно на 108.000, появляется на 107.995). Автор: «Это и вызвало клинч в прошивке.»
- 2026-05-24 21:03 пользователь подтверждает: тот же баг 108 МГц был и в 1.52.

---

## [1.52] — 2026-05-19

### English

Initial release in the Tech chat: 2026-05-19 07:57:51 — "Looks like the menu 8 bug is fixed" (RX9CIM), file attached at 07:58:00, no details.

Author later posted a consolidated cumulative changelog in the «Прошивки» topic on 2026-05-20 10:14:25 — same full feature list as the 1.51 release post above, and one explicit delta against 1.51:

**Fixed (vs. 1.51):**
- Memory-cell handling bug.

**Known issues:**
- A "preset step" bug surfaced shortly after release in 1.52/1.53 (per the author on 2026-05-24 22:48: "was mentioned in the chat earlier, almost right away").

### Русский

Первое сообщение в Тех. чате: 2026-05-19 07:57:51 — «Вроде баг при работе с меню 8 устранил» (RX9CIM), файл выложен в 07:58:00, без деталей.

Автор позже выложил накопительный changelog в topic «Прошивки» 2026-05-20 10:14:25 — тот же полный список фич, что и в релиз-посте 1.51 выше, плюс одно явное отличие от 1.51:

**Исправлено (vs. 1.51):**
- Ошибка при работе с ячейками памяти.

**Известные проблемы:**
- Позже выяснился баг с шагом в 1.52/53 (по словам автора 2026-05-24 22:48 «писалось ранее в чате, почти сразу же»).

---

## [1.51] — 2026-05-18

### English

Author's release post: 2026-05-18 12:39:00 (file attached at 12:39:10). This is the first official stable build of the 1.5 branch, posted with a consolidated changelog "relative to 1.3":

**Added:**
- One more brightness-control mode — manual.
- Encoder switching can now also be triggered with the `#` key.
- Recording is disabled while SQL (Squelch) is active.
- In menu 8, you can preview memory cells while scrolling through them.
- In menu 8, direct numeric input of a cell number.
- In menu 8, ability to re-save a cell.
- Frequency range extended up to 165 MHz ("this is beyond the rated range; sensitivity above 148 MHz drops, that's expected").

**Changed:**
- Cursor direction reversed when navigating the list in menu 7.
- Firmware is now universal — for all hardware revisions (the 1.3 branch for old hardware and the 1.4 branch for new hardware were merged).

**Fixed:**
- Recorder file-naming bug.
- "Out of preset band range" bug.
- Frequency offset in CW mode.
- Receiver hang when trying to play a zero-size file.

### Русский

Релизное сообщение автора: 2026-05-18 12:39:00 (файл выложен в 12:39:10). Это первая официальная стабильная сборка ветки 1.5, расписана как сводный changelog «относительно версии 1.3»:

**Добавлено:**
- Добавлен ещё один пункт регулировки яркости — ручной режим.
- Добавлено дублирование переключения энкодера кнопкой `#`.
- Добавлено отключение записи при работе SQL (Squelch).
- Добавлена возможность прослушивания ячеек памяти при переборе ячеек в меню 8.
- При работе в меню 8 добавлена возможность прямого ввода номера ячейки.
- Добавлена возможность пересохранения ячейки в меню 8.
- Частотный диапазон расширен до 165 МГц («это за пределами заявленных частот, чувствительность выше 148 МГц снижается и это нормально»).

**Изменено:**
- Изменено направление перемещения курсора при работе со списком в меню 7.
- Прошивка универсальная — для всех версий схемотехники (объединение веток 1.3 для старого железа и 1.4 для нового).

**Исправлено:**
- Ошибка наименования файлов в рекордере.
- Баг с выходом за границы пресетов диапазонов.
- Частотный сдвиг в режиме CW.
- Баг с зависанием приёмника при попытке воспроизведения файла с нулевым размером.

---

## [1.50] — 2026-05-09

### English

Interim release. No detailed release post.

- 2026-05-09 16:13:10 RX9CIM: "1.5 is OK to install. Two sources — me and elecevolve. Changelog will come after the holidays."
- Later in chat RX9CIM clarifies: "1.5 is currently only at the Chinese side and flashes with the utility I gave you a link to. The whole 1.5 mess happened because the Chinese received and posted the firmware before the weekend. I forgot to warn them not to post and to wait for workdays."
- File not posted to Telegram. The standalone changelog never materialised — its content effectively rolled into 1.51.

**Known issues (from chat on 1.5):**
- In manual brightness mode the screen briefly flashes bright before the backlight switches off.
- Recorder did not record (`#bug 1.5 не записывает`).

### Русский

Промежуточная версия. Релизного сообщения с подробностями нет.

- 2026-05-09 16:13:10 RX9CIM: «1.5 можно загружать. Источников два — я и elecevolve. Описание изменений будет после праздников».
- Позднее RX9CIM пояснил: «1.5 выложена пока у китайцев и шьется той утилитой на которую дал вам ссылку. Вся суета с 1.5 произошла из за того, что китайцы получили и выложили прошивку до выходных. Я их забыл предупредить, чтобы не выкладывали и подождали рабочих дней.»
- Файл в Telegram не выкладывался. Описание новшеств в чате так и не было опубликовано отдельно — фактически вошло в changelog 1.51.

**Известные проблемы (по чату 1.5):**
- В режиме manual в брайтнес-настройке экран на секунду становится ярким перед выключением подсветки.
- Не работала запись в рекордер (`#bug 1.5 не записывает`).

---

## [1.40] — April 2026

### English

Interim release. The author never posted a standalone release note for it.

Context from RX9CIM messages:
- 2026-05-03 08:18:40 (EN, by the author): "Fw 1.4 is temproraly fw for new hardware. Next FW will be unified for all types."
- 2026-05-04 06:51:08: "Firmware 1.4 is temporary, for the new hardware revision. It was made for a simple logistical reason — the new hardware took about a month to reach me, and during that time the Chinese managed to set up production, assemble units and start selling them. Now the new hardware is in my hands, the unified firmware is built and being tested."
- 2026-05-03 08:02:42 (EN, by the author): "backlight issue was fixed in 1.4 … But it is not fixed yet fully, backlight dimmed just in 'night' mode. In next FW i will add manual adjustments for backlights mode."

Bottom line: 1.40 was never publicly distributed; it was installed at the factory on new hardware revisions. It does not run on old hardware and vice versa.

### Русский

Промежуточная версия. Нет описания от автора в чате как самостоятельного релиза.

Контекст из сообщений RX9CIM:
- 2026-05-03 08:18:40: «Fw 1.4 is temproraly fw for new hardware. Next FW will be unified for all types.»
- 2026-05-04 06:51:08: «Прошивка 1.4 временная, для новой версии железа. И сделана она была по простой и банальной причине — логистической причине. Ко мне новое железо ехало около месяца, а за это время в Китае смогли организовать производство, провести сборку и продать. Сейчас новое железо у меня на руках, универсальная прошивка сделана и тестируется.»
- 2026-05-03 08:02:42: «backlight issue was fixed in 1.4 … But it is not fixed yet fully, backlight dimmed just in "night" mode. In next FW i will add manual adjustments for backlights mode».

Итог: 1.40 публично не распространялась, ставилась на заводе на новые ревизии. Не работает на старых ревизиях железа и наоборот.

---

## [1.30] — 2026-03-16

### English

Author's release post: 2026-03-15 21:24:13, posted to the «Прошивки» topic (not the Tech chat).
File never posted to Telegram — distributed via malahiteam.com (RX9CIM 2026-03-28 06:35:46: "Posted the firmware and the manual on malahiteam.com.").

**Added:**
- Another brightness-control option — night mode ("the smouldering effect is perfect at night").
- Deemphasis setting, multipath-suppression and channel-equalizer options in menu 1.
- S-meter display in dBm — improved S-meter item in the Visual menu. Note: levels above ~73 dBm are not displayed due to a hardware limitation.
- Spectrum range adjustment — new "Spectrum gain" item in menu 5.
- WFM reception-window indicator (visir).

**Changed:**
- Frequency correction is now split for frequencies below 27 MHz and above 108 MHz.
- SD card data format changed from FAT to exFAT (1.2 required FAT) — RX9CIM 2026-03-18: "if the firmware is 1.3, both extFAT and FAT32 are supported."
- Display no longer wakes up on encoder rotation if it was turned off via key 9.
- "Display off" overlay removed when toggling display with key 9.
- Volume leveled across AM, FM, SSB.

**Fixed:**
- File creation-date bug and player display.
- Font fixes — letters `g`, `:`, `I`.
- Encoder behavior.
- Recorder file-naming bug.
- Recorder not recording in CW mode.

**Known issues (from chat on 1.3):**
- In the Visual menu, rotating the encoder on page 2/2 (S-meter / Spectrum gain) changes the inactive item instead (reported 2026-03-18).
- AM Scan on the air band "jumps to 30 MHz and below or to 130 kHz and above."
- In AM mode there is no 25 kHz or 12.5 kHz step on the air band.
- The NR level in the Audio menu only becomes active after NR has been physically turned on via the C key.
- 2026-03-16 author notes: "to make the step work correctly a fairly large rework is needed" — by context, this had not yet been done in 1.30.

### Русский

Релизное сообщение автора: 2026-03-15 21:24:13, выложено в topic «Прошивки» (не в Тех. чат).
Файл в Telegram не выкладывался — распространялся через malahiteam.com (RX9CIM 2026-03-28 06:35:46: «На сайте malahiteam.com выложил прошивку и инструкцию.»).

**Добавлено:**
- Ещё один пункт регулировки яркости — ночной режим («тлеющий эффект ночью самое то»).
- В меню 1 — настройка деэмфазиса, опции подавления многолучевого приёма и канального эквалайзера.
- Вывод S-метра в dBm — доработан пункт S-метр в меню Visual. Внимание: уровни выше ~73 дБм не отображаются, связано с аппаратным ограничением.
- Регулировка диапазона отображения спектра — новый пункт «Spectrum gain» в меню 5.
- Отображение визира (области приёма) в режиме WFM.

**Изменено:**
- Коррекция частоты разделена для частот ниже 27 МГц и выше 108 МГц.
- Формат данных на SD карте изменён с FAT на exFAT (на 1.2 нужно было FAT) — RX9CIM 2026-03-18: «если прошивка 1.3 то поддерживается и extFAT и FAT32».
- Дисплей не просыпается при вращении энкодера, если был выключен кнопкой 9.
- Убрана надпись при выключении дисплея кнопкой 9.
- Выровнена громкость в АМ, ЧМ, SSB.

**Исправлено:**
- Баг с датой создания файлов и отображением в плеере.
- Шрифт — буквы `g`, `:`, `I`.
- Работа энкодера.
- Ошибка наименования файлов рекордера.
- Отсутствие записи рекордера в режиме CW.

**Известные проблемы (из чата по 1.3):**
- В меню Visual вращение энкодера на странице 2/2 (S-meter / Spectrum gain) меняет настройку неактивного пункта (баг от 2026-03-18).
- AM Scan на авиа-диапазоне «перепрыгивает на 30 МГц и ниже или на 130 кГц и выше».
- В режиме AM нет шага 25 кГц или 12.5 кГц на авиа-диапазоне.
- Уровень NR в меню Аудио активируется только после физического включения NR кнопкой С.
- 2026-03-16 автор отмечает: «для того, чтобы шаг корректно работал нужна достаточно большая переделка» — судя по контексту, в 1.30 это ещё не было сделано.

---

## [1.20] — 2026-02-06 (posted to chat 2026-02-19)

### English

File `MLite_1_2_060226.zip` posted by the author on 2026-02-19 15:27.

The author deliberately did not write a release note. When asked for a changelog on 2026-02-16 23:05:50, RX9CIM replied:

> "No notes. Treat 1.2 as the baseline. Earlier firmware mostly contained minor bugs. There's no point describing bug fixes. There are no new features."

**From discussion:**
- 1.20 is the "baseline." Earlier 1.0 and 1.1 firmware "mostly contained minor bugs" (RX9CIM).
- Users reported a frequency calibration issue after upgrading from 1.0/1.1 to 1.2 (worked around by rolling back; fixed later).

### Русский

Файл `MLite_1_2_060226.zip` залит автором в чат 2026-02-19 15:27.

Развёрнутого release notes автор сознательно не делал. На просьбу о changelog RX9CIM ответил (2026-02-16 23:05:50):

> «Нет ноутс. Считать 1.2 как базу. Предыдущие прошивки содержали в основном мелкие ошибки. Смысла описывать исправление багов нет никакого. Из нововведений там нет ничего.»

**Известно из обсуждения:**
- 1.20 — это «база» (baseline). Предыдущие прошивки 1.0 и 1.1 содержали «в основном мелкие ошибки» (RX9CIM).
- Пользователи отмечали проблему с калибровкой частоты после обновления с 1.0/1.1 на 1.2 (которая решалась откатом, позднее починена).

---

## Versions 1.0 and 1.1 / Версии 1.0 и 1.1

### English

Factory firmware on the first production batches. Never posted to the chat, no release notes from the author.

RX9CIM (2026-02-16): "Earlier firmware mostly contained minor bugs. There's no point describing bug fixes."

### Русский

Заводские прошивки первых партий. В чате не выкладывались, описаний от автора нет.

RX9CIM (2026-02-16): «Предыдущие прошивки содержали в основном мелкие ошибки. Смысла описывать исправление багов нет никакого.»

---

## Timeline / Хронологическая сводка

```
2026-02-06  build 1.20   (MLite_1_2_060226.zip, posted to chat on 02-19)
2026-02-19  post 1.20    RX9CIM uploads the file to Telegram
2026-03-16  1.30         reaches users
2026-03-28  1.30         official release on malahiteam.com
2026-05-03  1.40         author calls it an interim build for new hardware
2026-05-09  1.50         "1.5 is OK to install", leaked through the manufacturer
2026-05-18  1.51         first proper 1.5-branch release with a changelog
2026-05-19  1.52         menu 8 fix
2026-05-21  1.53         memory / preset / 133.2 input fixes
2026-05-25  1.54         108 MHz fix, preset step fix, band labels added
2026-05-27  1.55         preset fix, 108 MHz fix, P-letter fix, NOAA + pirate bands added
```

---

## References / Ссылки

- Author's Telegram channel (MalahitReceiver) — release post used as the source for several entries above: <https://t.me/MalahitReceiver/212201>
- malahiteam.com — official site where the author distributes firmware and manuals.
