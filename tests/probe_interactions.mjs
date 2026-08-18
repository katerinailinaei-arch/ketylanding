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

class FakeElement {
  constructor(document, name) {
    this.document = document;
    this.name = name;
    this.dataset = {};
    this.attributes = new Map();
    this.listeners = new Map();
    this.children = [];
    const classes = new Set();
    this.classList = {
      add: (...names) => names.forEach((value) => classes.add(value)),
      remove: (...names) => names.forEach((value) => classes.delete(value)),
      toggle: (value, force) => force ? classes.add(value) : classes.delete(value),
      contains: (value) => classes.has(value)
    };
  }

  addEventListener(type, listener) {
    if (!this.listeners.has(type)) this.listeners.set(type, []);
    this.listeners.get(type).push(listener);
  }

  dispatch(type, event = {}) {
    event.target ??= this;
    event.preventDefault ??= () => { event.defaultPrevented = true; };
    for (const listener of this.listeners.get(type) || []) listener(event);
    return event;
  }

  setAttribute(name, value) { this.attributes.set(name, String(value)); }
  getAttribute(name) { return this.attributes.get(name) ?? null; }
  focus() { this.document.activeElement = this; }
  contains(target) { return target === this || this.children.includes(target); }
  querySelector(selector) { return selector === 'a[href]' ? this.children[0] ?? null : null; }
  querySelectorAll(selector) { return selector === 'a[href]' ? this.children : []; }
}

function createDocument() {
  const listeners = new Map();
  return {
    activeElement: null,
    listeners,
    addEventListener(type, listener) {
      if (!listeners.has(type)) listeners.set(type, []);
      listeners.get(type).push(listener);
    },
    dispatch(type, event = {}) {
      event.preventDefault ??= () => { event.defaultPrevented = true; };
      for (const listener of listeners.get(type) || []) listener(event);
      return event;
    }
  };
}

const menuStart = behaviorScript.indexOf('function initMenu()');
const menuEnd = behaviorScript.indexOf('function initConcepts()');
if (menuStart < 0 || menuEnd < 0) throw new Error('initMenu function boundaries are missing');

const menuDocument = createDocument();
const nav = new FakeElement(menuDocument, 'nav');
const toggle = new FakeElement(menuDocument, 'toggle');
const links = new FakeElement(menuDocument, 'links');
const firstLink = new FakeElement(menuDocument, 'first-link');
const lastLink = new FakeElement(menuDocument, 'last-link');
links.children = [firstLink, lastLink];
nav.children = [toggle, links];
toggle.setAttribute('aria-expanded', 'false');
links.dataset.open = 'false';
menuDocument.querySelector = (selector) => selector === '.site-nav' ? nav : selector === '.nav-menu-toggle' ? toggle : null;
menuDocument.getElementById = (id) => id === 'primary-navigation' ? links : null;
const menuWindow = {
  matchMedia() { return { matches: true, addEventListener() {} }; }
};
const initMenu = new Function('document', 'window', `${behaviorScript.slice(menuStart, menuEnd)}; return initMenu;`)(menuDocument, menuWindow);
initMenu();

toggle.dispatch('click');
if (menuDocument.activeElement !== firstLink) throw new Error('Opening the mobile menu must focus its first link');
lastLink.focus();
const forwardTab = menuDocument.dispatch('keydown', { key: 'Tab', shiftKey: false });
if (!forwardTab.defaultPrevented || menuDocument.activeElement !== toggle) throw new Error('Tab must wrap from the last menu link to the toggle');
toggle.focus();
const reverseTab = menuDocument.dispatch('keydown', { key: 'Tab', shiftKey: true });
if (!reverseTab.defaultPrevented || menuDocument.activeElement !== lastLink) throw new Error('Shift+Tab must wrap from the toggle to the last menu link');
menuDocument.dispatch('keydown', { key: 'Escape' });
if (links.dataset.open !== 'false' || toggle.getAttribute('aria-expanded') !== 'false' || menuDocument.activeElement !== toggle) {
  throw new Error('Escape must close the mobile menu and return focus to its toggle');
}
console.log('PASS: mobile menu manages and traps keyboard focus');

const methodStart = behaviorScript.indexOf('function initMethod()');
const methodEnd = behaviorScript.indexOf('function initFaq()');
if (methodStart < 0 || methodEnd < 0) throw new Error('initMethod function boundaries are missing');
const methodDocument = createDocument();
const methodStages = Array.from({ length: 5 }, (_, index) => new FakeElement(methodDocument, `method-${index + 1}`));
methodDocument.querySelectorAll = (selector) => selector === '[data-method-stage]' ? methodStages : [];
const initMethod = new Function('document', `${behaviorScript.slice(methodStart, methodEnd)}; return initMethod;`)(methodDocument);
initMethod();
if (methodStages[0].getAttribute('aria-current') !== 'step' || !methodStages[0].classList.contains('is-active')) {
  throw new Error('The first method stage must start active');
}
methodStages[2].dispatch('click');
const activeStages = methodStages.filter((stage) => stage.getAttribute('aria-current') === 'step' && stage.classList.contains('is-active'));
if (activeStages.length !== 1 || activeStages[0] !== methodStages[2]) throw new Error('Click must select exactly one method stage');
console.log('PASS: method stages expose one accessible active state');
