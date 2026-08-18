import fs from 'node:fs';

const html = fs.readFileSync(new URL('../index.html', import.meta.url), 'utf8');
const behaviorScript = html
  .split('<script')
  .slice(1)
  .filter((part) => !part.slice(0, part.indexOf('>')).includes('application/json'))
  .map((part) => part.slice(part.indexOf('>') + 1, part.indexOf('</script>')))
  .at(-1);
const start = behaviorScript.indexOf('function applySiteConfig()');
const end = behaviorScript.indexOf('function initMenu()');

if (start < 0 || end < 0) throw new Error('applySiteConfig function boundaries are missing');

const applySiteConfig = new Function('document', `${behaviorScript.slice(start, end)}; return applySiteConfig;`);
let updated = false;
const fakeDocument = {
  getElementById(id) {
    return id === 'site-config' ? { textContent: 'null' } : null;
  },
  querySelectorAll() {
    updated = true;
    return [];
  }
};

applySiteConfig(fakeDocument)();
if (updated) throw new Error('Null site configuration must not update Telegram links');
console.log('PASS: null site configuration is ignored');
