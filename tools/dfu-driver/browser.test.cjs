// Run with Playwright installed; all USB calls are mocks, never real hardware.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '../../docs');
const server = http.createServer((req, res) => {
  const filename = path.join(root, req.url.split('?')[0] === '/' ? 'index.html' : req.url.split('?')[0]);
  if (!filename.startsWith(root + path.sep)) { res.writeHead(403).end(); return; }
  fs.readFile(filename, (err, data) => {
    if (err) { res.writeHead(404).end(); return; }
    res.setHeader('Content-Type', filename.endsWith('.js') ? 'text/javascript' : 'text/html'); res.end(data);
  });
});
(async () => {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const browser = await chromium.launch({ headless: true, ...(process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE ? { executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE } : {}) });
  try {
    for (const [os, ua] of [['windows', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/140.0.0.0'], ['linux', 'Mozilla/5.0 (X11; Linux x86_64) Chrome/140.0.0.0']]) {
      const context = await browser.newContext({ userAgent: ua, viewport: { width: 1100, height: 900 } });
      const page = await context.newPage(); const errors = [];
      page.on('pageerror', e => errors.push(e.message));
      page.on('dialog', async d => { errors.push(d.message()); await d.dismiss(); });
      await page.route('https://api.github.com/**', route => route.fulfill({ json: [] }));
      await page.addInitScript(() => {
        window.usbMode = 'cancel'; window.usbRequests = 0; window.usbCloses = 0;
        Object.defineProperty(navigator, 'usb', { value: { async requestDevice() {
          window.usbRequests++;
          if (window.usbMode === 'permission') throw new DOMException('USB blocked by browser policy', 'SecurityError');
          if (window.usbMode === 'cancel') throw new DOMException('No device selected', 'NotFoundError');
          return { vendorId: 0x0483, productId: 0xdf11 };
        }, getDevices: async () => [], addEventListener() {} } });
      });
      await page.goto('http://127.0.0.1:' + server.address().port);
      await page.locator('#appVer').filter({ hasText: '0.1.23' }).waitFor();
      await page.click('#btnConnect');
      await page.waitForFunction(() => !document.querySelector('#btnConnect').disabled);
      assert.equal(await page.locator('#modal').isVisible(), false);
      assert.match(await page.locator('#log').innerText(), /No device selected/);
      await page.evaluate(() => window.usbMode = 'permission');
      await page.click('#btnConnect'); await page.locator('#modal').waitFor({ state: 'visible' });
      assert.equal(await page.locator('#usbDownload').isVisible(), false);
      assert.match(await page.locator('#modalMsg').innerText(), /browser did not allow/);
      await page.keyboard.press('Escape'); assert.equal(await page.locator('#modal').isVisible(), false);
      await page.evaluate(() => {
        window.usbMode = 'open';
        dfu.findDeviceDfuInterfaces = () => [{ name: 'Internal Flash' }];
        dfuse.Device = function () { this.open = async () => { throw new DOMException('Access denied', 'NetworkError'); }; this.close = async () => { window.usbCloses++; }; };
      });
      await page.click('#btnConnect'); await page.locator('#modal').waitFor({ state: 'visible' });
      assert.equal(await page.locator('#usbDownload').isVisible(), os === 'windows');
      assert.equal(await page.evaluate(() => window.usbCloses), 1);
      assert.equal(await page.locator('#btnFlash').isEnabled(), false);
      for (const lang of ['ru', 'de', 'be', 'uk', 'en']) {
        await page.evaluate(code => setLang(code), lang);
        assert.ok((await page.locator('#modalMsg').innerText()).length > 100);
        assert.equal(await page.locator('#usbDownload').isVisible(), os === 'windows');
      }
      const before = await page.evaluate(() => window.usbRequests);
      await page.evaluate(() => window.usbMode = 'cancel');
      await page.click('#modalRetry'); await page.waitForFunction(() => !document.querySelector('#btnConnect').disabled);
      assert.equal(await page.evaluate(() => window.usbRequests), before + 1);
      await page.click('#btnUsbHelp'); await page.locator('#modal').waitFor({ state: 'visible' });
      if (os === 'windows') {
        await page.evaluate(() => setLang('ru'));
        await page.screenshot({ path: process.env.USB_HELP_SCREENSHOT || '/private/tmp/malahit-usb-help-desktop.png' });
        await page.setViewportSize({ width: 390, height: 844 });
        await page.screenshot({ path: '/private/tmp/malahit-usb-help-mobile.png' });
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true);
      }
      assert.deepEqual(errors, []);
      await context.close(); console.log(os + ': cancellation, permissions, opening failure, cleanup, retry, languages and layout OK');
    }
  } finally { await browser.close(); server.close(); }
})().catch(error => { console.error(error); server.close(); process.exitCode = 1; });
