# «Мастерская творений» Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Создать и визуально проверить автономный одностраничный MVP-лендинг «Мастерская творений», который честно показывает три демонстрационных концепта и ведёт экспертов и владельцев малого бизнеса в Telegram.

**Architecture:** Один `index.html` содержит семантическую разметку, CSS-дизайн-систему, встроенные SVG и минимальный vanilla JavaScript. Отдельный PowerShell-скрипт выполняет воспроизводимые статические проверки контента, доступности и отсутствия внешних зависимостей; интерактивность, адаптивность и визуальное качество проверяются в реальном браузере.

**Tech Stack:** HTML5, CSS3, inline SVG, vanilla JavaScript, PowerShell 7/Windows PowerShell, in-app Browser для визуальной и интерактивной QA.

**Spec:** `docs/superpowers/specs/2026-08-18-masterskaya-tvoreniy-landing-design.md`

## Global Constraints

- Основной артефакт — один автономный `index.html`; внешние JavaScript/CSS-библиотеки и CDN запрещены.
- Язык страницы — русский (`lang="ru"`).
- Главный CTA во всех точках — «Обсудить задачу в Telegram».
- Telegram URL хранится в одном JS/HTML-источнике конфигурации и до публикации заменяется на реальный username.
- Три работы постоянно маркируются «Собственный концепт — не клиентский проект».
- Запрещены вымышленные клиенты, отзывы, логотипы, награды, гарантии и метрики.
- Без JavaScript остаются доступными весь контент, FAQ, якоря и Telegram-ссылки.
- Обязательны keyboard navigation, `:focus-visible`, WCAG AA-контраст и `prefers-reduced-motion`.
- Запрещены scroll-jacking, autoplay, WebGL, кастомный курсор и критический контент только по hover.
- Целевые Web Vitals после публикации: LCP ≤ 2,5 с, INP ≤ 200 мс, CLS ≤ 0,1 на 75-м перцентиле.
- Визуальная QA обязательна на 375×812, 768×1024 и 1440×900.
- В папке проекта пока нет Git-репозитория. Перед первым коммитом исполнитель должен получить разрешение Кети на `git init`; отсутствие разрешения не блокирует создание и тестирование файлов, но коммиты пропускаются с явной отметкой.

---

## File Map

- Create: `index.html` — весь лендинг: метаданные, контент, стили, SVG и поведение.
- Create: `tests/verify_landing.ps1` — статические проверки требований ТЗ.
- Create: `tests/manual-qa.md` — зафиксированные результаты browser-QA и проверок доступности.
- Reference: `research.md` — исследование и экспертный аудит.
- Reference: `docs/superpowers/specs/2026-08-18-masterskaya-tvoreniy-landing-design.md` — утверждённое ТЗ.

---

### Task 1: Static Contract and Semantic Skeleton

**Files:**
- Create: `tests/verify_landing.ps1`
- Create: `index.html`

**Interfaces:**
- Consumes: утверждённое ТЗ и точные обязательные тексты.
- Produces: семантический DOM с ID `main`, `solutions`, `concepts`, `method`, `process`, `about`, `faq`, `contact`; тестовая команда `powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1`.

- [ ] **Step 1: Create the static verification script with failing structure checks**

Использовать следующий базовый контракт:

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$landingPath = Join-Path $root 'index.html'

if (-not (Test-Path -LiteralPath $landingPath)) {
    throw 'index.html is missing'
}

$html = [System.IO.File]::ReadAllText($landingPath, [System.Text.Encoding]::UTF8)

function Assert-Contains([string]$Pattern, [string]$Message) {
    if ($html -notmatch $Pattern) { throw $Message }
}

function Assert-Count([string]$Pattern, [int]$Minimum, [string]$Message) {
    $count = [regex]::Matches($html, $Pattern).Count
    if ($count -lt $Minimum) { throw "$Message Actual: $count" }
}

Assert-Contains '<html[^>]+lang="ru"' 'Missing lang=ru'
Assert-Count '<h1\b' 1 'Missing h1'
if ([regex]::Matches($html, '<h1\b').Count -ne 1) { throw 'Page must contain exactly one h1' }
Assert-Contains '<header\b' 'Missing header'
Assert-Contains '<nav\b' 'Missing nav'
Assert-Contains '<main[^>]+id="main"' 'Missing main landmark'
Assert-Contains '<footer\b' 'Missing footer'

@('solutions','concepts','method','process','about','faq','contact') | ForEach-Object {
    Assert-Contains "id=`"$_`"" "Missing section id: $_"
}

Write-Host 'PASS: semantic skeleton'
```

- [ ] **Step 2: Run the verifier and confirm the red state**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1
```

Expected: FAIL with `index.html is missing`.

- [ ] **Step 3: Add the minimum semantic HTML skeleton**

Создать `index.html` с `<!doctype html>`, `lang="ru"`, skip-link, `header/nav`, `main#main`, семью обязательными section ID, одним `h1` и `footer`. Добавить временно только утверждённые заголовки секций, без визуальных деталей.

- [ ] **Step 4: Run the verifier and confirm green**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1
```

Expected: `PASS: semantic skeleton`, exit code 0.

- [ ] **Step 5: Request Git initialization permission if still absent**

Run first:

```powershell
Test-Path -LiteralPath .git
```

Expected now: `False`. Ask Кети whether to initialize Git. Only after approval run `git init`, then:

```powershell
git add index.html tests/verify_landing.ps1
git commit -m "test: define landing page structure contract"
```

If approval is not given, record `Commit skipped: repository not initialized` and continue.

---

### Task 2: Complete Approved Content and Conversion Path

**Files:**
- Modify: `index.html`
- Modify: `tests/verify_landing.ps1`

**Interfaces:**
- Consumes: section IDs from Task 1 and copy from the spec.
- Produces: full no-JS content, three scenarios, three concept disclosures, four process stages, seven FAQ entries and five consistent Telegram CTA occurrences.

- [ ] **Step 1: Extend the verifier with content checks**

Добавить:

```powershell
Assert-Contains 'Превращаю идеи в цифровые решения, которые работают на вас' 'Hero copy mismatch'
Assert-Contains 'Нужны заявки' 'Missing leads scenario'
Assert-Contains 'Нужно запустить идею' 'Missing MVP scenario'
Assert-Contains 'Нужно убрать рутину' 'Missing automation scenario'
Assert-Count 'Собственный концепт — не клиентский проект' 3 'Every concept needs disclosure.'
Assert-Contains 'Точка опоры' 'Missing website concept'
Assert-Contains 'Пульс проекта' 'Missing app concept'
Assert-Contains 'Навигатор' 'Missing AI concept'
Assert-Count 'class="process-step' 4 'Four process steps required.'
Assert-Count 'class="faq-item' 7 'Seven FAQ items required.'
Assert-Count 'Обсудить задачу в Telegram' 3 'Telegram CTA must repeat at least three times.'

$forbiddenClaims = @('гарантированный результат','лучший эксперт','№1','увеличу продажи в 3 раза')
$forbiddenClaims | ForEach-Object {
    if ($html.Contains($_)) { throw "Forbidden unsupported claim: $_" }
}

Write-Host 'PASS: approved content'
```

- [ ] **Step 2: Run the verifier and confirm the new checks fail**

Run the verifier. Expected: first failure is `Hero copy mismatch`.

- [ ] **Step 3: Implement the complete content in semantic order**

Перенести точные тексты из раздела 6 ТЗ. Структура каждой концептуальной работы:

```html
<article class="concept" data-concept="website">
  <p class="concept__disclosure">Собственный концепт — не клиентский проект</p>
  <p class="eyebrow">САЙТ ДЛЯ ЭКСПЕРТА</p>
  <h3>Точка опоры</h3>
  <dl class="concept__facts">
    <div><dt>Задача</dt><dd>Ясно раскрыть ценность услуги и привести посетителя к записи.</dd></div>
    <div><dt>Решение</dt><dd>Оффер, программа, формат работы, доверие, FAQ и запись.</dd></div>
  </dl>
</article>
```

По той же семантике добавить «Пульс проекта» и «Навигатор». Не использовать client logos, testimonial или метрики.

- [ ] **Step 4: Add a single Telegram configuration source**

В начале `body` добавить:

```html
<script type="application/json" id="site-config">
{"telegramUrl":"https://t.me/USERNAME"}
</script>
```

Все CTA получают `data-telegram-link`, а базовый `href="https://t.me/USERNAME"`. До публикации ссылка обязана быть заменена; во время разработки marker допустим и должен выявляться preflight-проверкой.

- [ ] **Step 5: Run the verifier**

Expected: both `PASS: semantic skeleton` and `PASS: approved content`.

- [ ] **Step 6: Commit if Git is available**

```powershell
git add index.html tests/verify_landing.ps1
git commit -m "feat: add approved landing content"
```

---

### Task 3: Design System and Responsive Layout

**Files:**
- Modify: `index.html`
- Modify: `tests/verify_landing.ps1`

**Interfaces:**
- Consumes: semantic classes and content from Task 2.
- Produces: CSS custom properties, responsive grid, usable 320–1920 px layout and stable image geometry.

- [ ] **Step 1: Add failing design-contract checks**

```powershell
@('--bg: #101116','--surface: #181A22','--text: #F4F1EA','--accent: #806BFF') | ForEach-Object {
    if (-not $html.Contains($_)) { throw "Missing design token: $_" }
}
Assert-Contains '@media\s*\(max-width:\s*767px\)' 'Missing mobile breakpoint'
Assert-Contains '@media\s*\(min-width:\s*768px\)' 'Missing tablet/desktop breakpoint'
Assert-Contains 'min-height:\s*44px' 'Missing minimum tap target rule'
Assert-Contains ':focus-visible' 'Missing focus-visible styles'
Write-Host 'PASS: design contract'
```

- [ ] **Step 2: Run tests and confirm failure on the first missing token**

- [ ] **Step 3: Implement the CSS foundation**

Встроить `<style>` в `head`. Добавить:

- exact color tokens from the spec;
- spacing, radius, shadow and typography tokens;
- `box-sizing: border-box` reset;
- system sans/mono stacks without network fonts;
- container max-width 1240 px;
- `clamp()` typography;
- visible skip-link and focus ring;
- button minimum height 44 px;
- line length limits;
- responsive header, hero, scenario cards, concepts, process and footer.

- [ ] **Step 4: Build the hero workshop diagram with inline SVG/CSS**

SVG needs a `viewBox`, stable aspect ratio and decorative accessibility treatment:

```html
<svg class="workshop-map" viewBox="0 0 720 520" aria-hidden="true" focusable="false">
  <g class="workshop-map__node" data-node="input">...</g>
  <g class="workshop-map__hub" data-node="workshop">...</g>
  <g class="workshop-map__node" data-node="website">...</g>
  <g class="workshop-map__node" data-node="mvp">...</g>
  <g class="workshop-map__node" data-node="agent">...</g>
</svg>
```

Тот же смысл обязан быть текстом рядом; SVG не является единственным объяснением.

- [ ] **Step 5: Run static tests**

Expected: `PASS: design contract` and previous checks remain green.

- [ ] **Step 6: Open locally and inspect 375/768/1440 screenshots**

Запустить простой локальный server из workspace разрешённым способом, открыть `http://127.0.0.1:<port>/index.html` во встроенном браузере и сохранить первичные screenshots. На этом шаге допускаются найденные визуальные дефекты; записать их в черновик `tests/manual-qa.md`.

- [ ] **Step 7: Commit if Git is available**

```powershell
git add index.html tests/verify_landing.ps1 tests/manual-qa.md
git commit -m "feat: build responsive workshop design system"
```

---

### Task 4: Progressive Interactions and Motion Safety

**Files:**
- Modify: `index.html`
- Modify: `tests/verify_landing.ps1`

**Interfaces:**
- Consumes: DOM sections and `data-*` hooks from Tasks 2–3.
- Produces: `initMenu()`, `initConcepts()`, `initFaq()`, `initReveal()`, `applySiteConfig()`; baseline remains usable without JS.

- [ ] **Step 1: Add failing interaction-contract checks**

```powershell
@('function initMenu','function initConcepts','function initFaq','function initReveal','function applySiteConfig') | ForEach-Object {
    if (-not $html.Contains($_)) { throw "Missing interaction function: $_" }
}
Assert-Contains 'prefers-reduced-motion:\s*reduce' 'Missing reduced motion CSS'
Assert-Contains 'aria-expanded' 'Missing expandable control semantics'
Assert-Contains 'IntersectionObserver' 'Missing progressive reveal observer'
Assert-Contains 'class="no-js"' 'Missing no-js baseline class'
Write-Host 'PASS: interaction contract'
```

- [ ] **Step 2: Run tests and confirm red**

- [ ] **Step 3: Add no-JS baseline and enhancement initialization**

Document starts with `class="no-js"`. First inline script changes it to `js` only after script execution. CSS must show all content under `.no-js`.

- [ ] **Step 4: Implement `applySiteConfig()`**

```js
function applySiteConfig() {
  const configNode = document.getElementById('site-config');
  if (!configNode) return;
  let config;
  try { config = JSON.parse(configNode.textContent); } catch { return; }
  if (!config.telegramUrl) return;
  document.querySelectorAll('[data-telegram-link]').forEach((link) => {
    link.href = config.telegramUrl;
  });
}
```

- [ ] **Step 5: Implement accessible mobile menu**

`initMenu()` must:

- synchronize `aria-expanded`;
- close on Escape, nav selection and outside click;
- return focus to toggle after Escape;
- never hide desktop navigation from keyboard at desktop widths;
- reset state after resizing above mobile breakpoint.

- [ ] **Step 6: Implement concepts as progressive tabs**

At baseline, all three concepts are visible. With JS at desktop, controls use `role="tablist"`, each trigger uses `role="tab"`, and each panel uses `role="tabpanel"`. Implement click, Enter/Space and arrow-key navigation; selected panel updates `aria-selected`, `tabindex` and `hidden`. On small screens, either preserve tabs with all required controls or disable enhancement and show sequential articles.

- [ ] **Step 7: Implement accessible FAQ**

At baseline, answers are visible. With JS, each button toggles `aria-expanded` and panel `hidden`. Button text and answers remain in DOM.

- [ ] **Step 8: Implement safe reveals**

`initReveal()` applies enhancement only when Intersection Observer exists and reduced motion is not requested. Never assign hidden initial state before successful observer setup.

- [ ] **Step 9: Run static verifier**

Expected: interaction contract and all earlier contracts pass.

- [ ] **Step 10: Browser-test keyboard and reduced motion**

Verify Tab order, skip-link, menu Escape behavior, concept controls, FAQ, visible focus and reduced-motion emulation. Record concrete pass/fail rows in `tests/manual-qa.md`.

- [ ] **Step 11: Commit if Git is available**

```powershell
git add index.html tests/verify_landing.ps1 tests/manual-qa.md
git commit -m "feat: add accessible landing interactions"
```

---

### Task 5: SEO, Metadata and Publication Preflight

**Files:**
- Modify: `index.html`
- Modify: `tests/verify_landing.ps1`

**Interfaces:**
- Consumes: final public copy and Telegram configuration.
- Produces: complete metadata, safe structured data and a publication gate that rejects unresolved markers.

- [ ] **Step 1: Add failing metadata checks**

```powershell
Assert-Contains '<title>Мастерская творений — сайты, MVP и ИИ-автоматизации</title>' 'Title mismatch'
Assert-Contains '<meta[^>]+name="description"' 'Missing meta description'
Assert-Contains '<meta[^>]+property="og:title"' 'Missing Open Graph title'
Assert-Contains '<meta[^>]+property="og:description"' 'Missing Open Graph description'
Assert-Contains '<meta[^>]+property="og:image"' 'Missing Open Graph image'
Assert-Contains '<meta[^>]+name="theme-color"' 'Missing theme color'
Assert-Contains 'application/ld\+json' 'Missing JSON-LD'
Assert-Contains 'data-event="cta_telegram_click"' 'Missing analytics hook'
Write-Host 'PASS: metadata contract'
```

- [ ] **Step 2: Run verifier and confirm red**

- [ ] **Step 3: Implement metadata using only real facts**

Add exact title and description from the spec, Open Graph/Twitter tags, inline SVG favicon or local favicon, theme color and JSON-LD for `Person`/`ProfessionalService` using only name `Кети`, brand `Мастерская творений` and actual public URLs once available. Do not add AggregateRating, review, client count or postal address.

- [ ] **Step 4: Add stable analytics hooks without analytics SDK**

Add `data-event` and contextual `data-location`, `data-scenario`, `data-concept` attributes. Do not transmit anything.

- [ ] **Step 5: Add a strict optional publication switch**

Extend verifier with parameter:

```powershell
param([switch]$PublishReady)

if ($PublishReady) {
    @('USERNAME','placeholder') | ForEach-Object {
        if ($html -match [regex]::Escape($_)) { throw "Publication marker remains: $_" }
    }
    if ($html -match 'https://example\.') { throw 'Example URL remains' }
}
```

The normal development test may pass with the Telegram marker; publish-ready mode must fail until real data exists.

- [ ] **Step 6: Run both modes**

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1 -PublishReady
```

Expected during development: normal PASS; publish-ready FAIL on `USERNAME` until Кети supplies it. This is an explicit external-content gate, not an implementation failure.

- [ ] **Step 7: Commit if Git is available**

```powershell
git add index.html tests/verify_landing.ps1
git commit -m "feat: add metadata and publication preflight"
```

---

### Task 6: Cross-Viewport Visual QA and Accessibility Repair

**Files:**
- Modify: `index.html`
- Modify: `tests/manual-qa.md`

**Interfaces:**
- Consumes: complete page from Tasks 1–5.
- Produces: verified visual states at required sizes and a completed QA record.

- [ ] **Step 1: Create the manual QA matrix**

Use this exact structure in `tests/manual-qa.md`:

```markdown
# Manual QA — Мастерская творений

| Check | 375×812 | 768×1024 | 1440×900 | Notes |
|---|---|---|---|---|
| Hero communicates offer and CTA | | | | |
| No horizontal page scroll | | | | |
| H1 has intentional line breaks | | | | |
| Header/menu usable | | | | |
| Three scenarios readable | | | | |
| Three disclosures permanently visible | | | | |
| Concept controls usable | | | | |
| Process layout readable | | | | |
| About section honest and complete | | | | |
| FAQ works | | | | |
| Final Telegram CTA visible | | | | |

## Accessibility

- [ ] Skip link works
- [ ] Full keyboard path works
- [ ] Focus is always visible
- [ ] Menu returns focus on Escape
- [ ] FAQ state is announced
- [ ] Concept state is announced
- [ ] 200% zoom remains usable
- [ ] Reduced motion removes nonessential motion
- [ ] Text and UI contrast pass AA

## Runtime

- [ ] No console errors
- [ ] No unexpected external requests
- [ ] JavaScript-disabled baseline works
```

- [ ] **Step 2: Capture and inspect 375×812**

Check hero before scrolling, opened menu, all sections, active concept and FAQ. Record PASS/FAIL and exact defect, never a vague `looks good`.

- [ ] **Step 3: Capture and inspect 768×1024**

Verify grid transitions, navigation, card widths and no awkward desktop/mobile hybrid state.

- [ ] **Step 4: Capture and inspect 1440×900**

Verify max-width, hero balance, line length, concept panel, whitespace and final CTA.

- [ ] **Step 5: Repair all blocking visual defects**

For each FAIL, modify only the relevant CSS/markup, recapture the same state and change to PASS with a concise note. Do not add decorative features during repair.

- [ ] **Step 6: Run accessibility checks**

Complete keyboard, zoom, reduced-motion and contrast rows. If an automated accessibility tool is available through the selected browser, use it as a supplement and record violations and fixes.

- [ ] **Step 7: Verify runtime conditions**

Inspect console and network. Any unexpected HTTP request, uncaught error or missing resource is blocking.

- [ ] **Step 8: Commit if Git is available**

```powershell
git add index.html tests/manual-qa.md
git commit -m "fix: complete responsive and accessibility QA"
```

---

### Task 7: Performance and Final Requirement Verification

**Files:**
- Modify: `index.html` only if verification finds defects
- Modify: `tests/verify_landing.ps1` only if a missing invariant is discovered
- Modify: `tests/manual-qa.md`

**Interfaces:**
- Consumes: visually accepted page.
- Produces: final evidence that static contracts, runtime, performance and spec coverage pass; publication remains blocked only by explicitly missing real-world values.

- [ ] **Step 1: Run the complete static verifier fresh**

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1
```

Expected: every `PASS:` line and exit code 0.

- [ ] **Step 2: Check external dependency absence**

Add or run these assertions:

```powershell
if ($html -match '<script[^>]+src=') { throw 'External script dependency found' }
if ($html -match '<link[^>]+rel="stylesheet"') { throw 'External stylesheet dependency found' }
if ($html -match 'https://fonts\.') { throw 'Remote font dependency found' }
Write-Host 'PASS: no external runtime dependencies'
```

- [ ] **Step 3: Run browser performance audit**

Record mobile and desktop audit results in `tests/manual-qa.md`. Treat accessibility or best-practice errors, blocking main-thread work, large layout shifts and missing image dimensions as defects. Lab results do not prove field Web Vitals; document that field targets require real traffic.

- [ ] **Step 4: Run the five-second comprehension check**

Show only the hero to five available representatives of experts/small business and ask the three exact questions from the spec. Record anonymized responses. Acceptance: at least four of five correctly identify the service category, audience/business purpose and Telegram next step. If not, revise only hero copy/hierarchy and repeat with fresh participants when possible.

- [ ] **Step 5: Perform spec coverage review**

Check every criterion in spec section 16 against code or QA evidence. Add a final table to `tests/manual-qa.md` with criterion number, PASS/BLOCKED and evidence. `USERNAME`, portrait, domain and OG image may be `BLOCKED BY OWNER MATERIAL`; no implemented requirement may remain unverified.

- [ ] **Step 6: Run publish-ready preflight**

```powershell
powershell -ExecutionPolicy Bypass -File tests/verify_landing.ps1 -PublishReady
```

Expected before materials arrive: explicit failure naming each owner-supplied marker. After Кети supplies real values: PASS.

- [ ] **Step 7: Commit if Git is available**

```powershell
git add index.html tests/verify_landing.ps1 tests/manual-qa.md
git commit -m "test: verify landing MVP for handoff"
```

- [ ] **Step 8: Report exact completion state**

Report:

- static test exit code;
- required viewport QA results;
- keyboard/reduced-motion results;
- console/network results;
- performance audit results;
- publish-ready status;
- exact remaining owner materials, if any.

Do not claim the site is publication-ready while the Telegram username, domain, portrait decision or social image remains unresolved.

---

## Execution Order and Review Gates

1. Task 1 establishes the tested DOM contract.
2. Task 2 completes honest content before decoration.
3. Task 3 creates the responsive visual system.
4. Task 4 progressively enhances interactions.
5. Task 5 adds metadata and a strict publication gate.
6. Task 6 repairs visual and accessibility defects using real browser evidence.
7. Task 7 runs full verification and reports blockers without overstating readiness.

Each task is independently reviewable and must leave all prior static checks green. A failing prior contract blocks progression to the next task.
