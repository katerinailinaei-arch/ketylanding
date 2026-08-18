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
