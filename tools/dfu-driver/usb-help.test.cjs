const { test } = require('node:test');
const assert = require('node:assert/strict');
const help = require('../../docs/usb-help.js');

test('inline page script parses and the matching helper script is loaded first', () => {
  const fs = require('node:fs'), path = require('node:path'), vm = require('node:vm');
  const html = fs.readFileSync(path.resolve(__dirname, '../../docs/index.html'), 'utf8');
  const inline = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
  assert.equal(inline.length, 1);
  assert.doesNotThrow(() => new vm.Script(inline[0][1]));
  assert.ok(html.indexOf('src="usb-help.js?v=0.1.23"') < html.indexOf('<script>'));
});

test('chooser cancellation is never diagnosed as a missing driver', () => {
  assert.equal(help.classify({ name: 'NotFoundError' }, 'request'), 'cancel');
  assert.equal(help.classify({ name: 'NotFoundError' }, 'open'), 'open');
});
test('browser permissions are distinct from native device opening failures', () => {
  for (const name of ['SecurityError', 'NotAllowedError']) {
    assert.equal(help.classify({ name }, 'request'), 'permission');
    assert.equal(help.classify({ name }, 'open'), 'open');
  }
  assert.equal(help.classify({ name: 'Error' }, 'memory-map'), 'device');
});
test('Windows installer is offered only for Windows and never for permission denial/cancel', () => {
  for (const lang of ['en', 'ru', 'de', 'be', 'uk']) {
    assert.equal(help.advice('open', 'windows', lang).download, true);
    assert.equal(help.advice('other', 'windows', lang).download, true);
    for (const kind of ['permission', 'cancel', 'device']) assert.equal(help.advice(kind, 'windows', lang).download, false);
    for (const os of ['linux', 'mac', 'android', 'other']) assert.equal(help.advice('open', os, lang).download, false);
    assert.ok(help.advice('open', 'windows', lang).message.includes('0483:DF11'));
    assert.deepEqual(Object.keys(help.text(lang)), Object.keys(help.text('en')));
  }
});
test('platform detection checks Android before Linux', () => {
  assert.equal(help.platform('Mozilla/5.0 (Linux; Android 15)'), 'android');
  assert.equal(help.platform('Mozilla/5.0 (Windows NT 10.0; Win64; x64)'), 'windows');
  assert.equal(help.platform('Mozilla/5.0 (Macintosh; Intel Mac OS X)'), 'mac');
  assert.equal(help.platform('Mozilla/5.0 (X11; Linux x86_64)'), 'linux');
  assert.match(help.download, /^https:\/\/github\.com\/Alex-Electron\/.+\.exe$/);
});
