param([switch]$PublishReady)

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

Assert-Contains '<title>Мастерская творений — сайты, MVP и ИИ-автоматизации</title>' 'Title mismatch'
Assert-Contains '<meta[^>]+name="description"' 'Missing meta description'
Assert-Contains '<meta[^>]+property="og:title"' 'Missing Open Graph title'
Assert-Contains '<meta[^>]+property="og:description"' 'Missing Open Graph description'
Assert-Contains '<meta[^>]+property="og:image"' 'Missing Open Graph image'
Assert-Contains '<meta[^>]+name="theme-color"' 'Missing theme color'
Assert-Contains 'application/ld\+json' 'Missing JSON-LD'
Assert-Contains 'data-event="cta_telegram_click"' 'Missing analytics hook'
$globalFaqButtons = [regex]::Matches($html, '(?is)<button\b(?=[^>]*\bdata-event="faq_open")(?=[^>]*\bdata-faq="[^"]+")[^>]*>')
if ($globalFaqButtons.Count -ne 7) { throw "Expected exactly seven global qualifying FAQ controls. Actual: $($globalFaqButtons.Count)" }
$faqItems = [regex]::Matches($html, '(?s)<article class="faq-item">.*?</article>')
if ($faqItems.Count -ne 7) { throw "Expected exactly seven FAQ items. Actual: $($faqItems.Count)" }
$faqIds = @()
$qualifyingFaqButtonCount = 0
foreach ($faqItem in $faqItems) {
    $faqButtons = [regex]::Matches($faqItem.Value, '<button[^>]+data-event="faq_open"[^>]+data-faq="([^"]+)"')
    if ($faqButtons.Count -ne 1) { throw "Every FAQ item needs exactly one analytics control. Actual: $($faqButtons.Count)" }
    if ([string]::IsNullOrWhiteSpace($faqButtons[0].Groups[1].Value)) { throw 'FAQ context must not be empty.' }
    $faqIds += $faqButtons[0].Groups[1].Value
    $qualifyingFaqButtonCount += $faqButtons.Count
}
if ($qualifyingFaqButtonCount -ne 7) { throw "Expected exactly seven qualifying FAQ controls. Actual: $qualifyingFaqButtonCount" }
if ((@($faqIds | Select-Object -Unique)).Count -ne 7) { throw 'FAQ context values must be unique.' }
if ($html -match '<section id="faq"[^>]*data-event=') { throw 'FAQ analytics hook must be on interactive controls.' }
Write-Host 'PASS: metadata contract'

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
Assert-Contains '<img\b[^>]*class="portrait"[^>]*src="data:image/jpeg;base64,[^"]+"[^>]*alt="Кети — создатель Мастерской творений"[^>]*width="410"[^>]*height="574"[^>]*loading="lazy"[^>]*decoding="async"' 'Keti portrait must be embedded for a self-contained HTML file.'
if ($html -match 'portrait-placeholder') { throw 'Portrait placeholder must be removed.' }

$forbiddenClaims = @('гарантированный результат','лучший эксперт','№1','увеличу продажи в 3 раза')
$forbiddenClaims | ForEach-Object {
    if ($html.Contains($_)) { throw "Forbidden unsupported claim: $_" }
}

Write-Host 'PASS: approved content'

@('--bg: #101116','--surface: #181A22','--text: #F4F1EA','--accent: #806BFF') | ForEach-Object {
    if (-not $html.Contains($_)) { throw "Missing design token: $_" }
}
Assert-Contains '@media\s*\(max-width:\s*767px\)' 'Missing mobile breakpoint'
Assert-Contains '@media\s*\(min-width:\s*768px\)' 'Missing tablet/desktop breakpoint'
Assert-Contains 'min-height:\s*44px' 'Missing minimum tap target rule'
Assert-Contains ':focus-visible' 'Missing focus-visible styles'
Write-Host 'PASS: design contract'

if ($html -match 'scroll-behavior:\s*smooth') { throw 'Smooth scrolling is not allowed in Task 3' }
Write-Host 'PASS: no Task 3 animation behavior'
Assert-Contains '(?s)\.button\s*\{[^}]*color:\s*var\(--bg\)' 'Primary CTA foreground must contrast with the accent background'
Write-Host 'PASS: primary CTA contrast contract'
@('website','mvp','agent') | ForEach-Object {
    Assert-Contains "data-route=`"$_-to-output`"" "Missing workshop route from $_ to final output"
}
Write-Host 'PASS: workshop convergence contract'

@('function initMenu','function initConcepts','function initFaq','function initReveal','function applySiteConfig') | ForEach-Object {
    if (-not $html.Contains($_)) { throw "Missing interaction function: $_" }
}
@('function initBackToTop','function initContactForm','function initCounters') | ForEach-Object {
    if (-not $html.Contains($_)) { throw "Missing requested interaction function: $_" }
}
Assert-Contains 'function initMethod' 'Missing method-stage interaction function'
Assert-Count '<button\b[^>]*\bdata-method-stage(?:\s|=|>)' 5 'Five native method-stage buttons required.'
Assert-Contains 'prefers-reduced-motion:\s*reduce' 'Missing reduced motion CSS'
Assert-Contains 'aria-expanded' 'Missing expandable control semantics'
Assert-Contains 'IntersectionObserver' 'Missing progressive reveal observer'
Assert-Contains 'class="no-js"' 'Missing no-js baseline class'
Write-Host 'PASS: interaction contract'

Assert-Contains '(?s)\.no-js\s+\.nav-menu-toggle\s*\{[^}]*display:\s*none' 'No-JS baseline must hide the inert menu toggle'
Assert-Contains '(?s)\.no-js\s+\.nav-links\s*\{[^}]*display:\s*flex' 'No-JS baseline must keep navigation links visible'
Write-Host 'PASS: no-JS navigation baseline'

Assert-Contains '<button\b[^>]*class="nav-menu-toggle"[^>]*aria-label="Открыть меню"[^>]*>\s*<span[^>]*></span>\s*<span[^>]*></span>\s*<span[^>]*></span>\s*</button>' 'Mobile menu must use an accessible three-line hamburger control.'
Assert-Contains '<button\b[^>]*id="back-to-top"[^>]*aria-label="Наверх"[^>]*hidden' 'Missing accessible back-to-top button.'
Assert-Contains '<form\b[^>]*id="contact-form"[^>]*novalidate' 'Missing demo contact form.'
Assert-Contains '<input\b[^>]*id="contact-name"[^>]*name="name"[^>]*autocomplete="name"[^>]*required' 'Contact name field contract is missing.'
Assert-Contains '<input\b[^>]*id="contact-email"[^>]*name="email"[^>]*type="email"[^>]*autocomplete="email"[^>]*required' 'Contact email field contract is missing.'
Assert-Contains '<textarea\b[^>]*id="contact-message"[^>]*name="message"[^>]*required' 'Contact message field contract is missing.'
Assert-Contains 'id="form-status"[^>]*role="status"[^>]*aria-live="polite"' 'Contact form needs an accessible success status.'
Assert-Contains 'Демонстрационная форма: сообщение не отправляется' 'Demo form disclosure is missing.'
Assert-Count 'data-counter-target="(?:3|5|1)"' 3 'Three honest counters are required.'
if ($html -match '(?i)(?:src|href)="(?:assets/|\.\.?/)') { throw 'index.html must not depend on relative local assets.' }
Write-Host 'PASS: requested interactive and self-contained contracts'

if ($PublishReady) {
    $unresolvedMarkers = @(
        @{ Pattern = 'USERNAME'; Message = 'Publish-ready blocked: replace Telegram USERNAME with the owner-supplied username.' },
        @{ Pattern = 'https://example\.'; Message = 'Publish-ready blocked: replace example public URL markers with the owner-supplied public URL and OG image URL.' },
        @{ Pattern = '(?i)(?:src|href|content)="[^"]*placeholder[^"]*"'; Message = 'Publish-ready blocked: replace placeholder final asset markers.' },
        @{ Pattern = 'OWNER_SUPPLIED_(?:PUBLIC_URL|OG_IMAGE)'; Message = 'Publish-ready blocked: replace unresolved canonical or Open Graph URL markers.' }
    )

    foreach ($marker in $unresolvedMarkers) {
        if ($html -match $marker.Pattern) { throw $marker.Message }
    }

    Write-Host 'PASS: publish-ready gate'
}
