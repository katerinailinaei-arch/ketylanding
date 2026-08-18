# Manual viewport QA — Task 6

Evidence reviewed on 2026-08-18. Task 6 CSS changes fully reverted; no post-fix visual or runtime claim is made. The 375 px headless PNG is unreliable evidence because Edge may have used a minimum layout viewport width and/or cropped the capture. Therefore a reproducible real overflow, `.hero__copy` as root cause, and RED/GREEN or post-fix results must not be asserted.

## Cross-viewport visual checks

| Required check | 375×812 | 768×1024 | 1440×900 | Notes / evidence |
| --- | --- | --- | --- | --- |
| Hero communicates the offer and exposes a primary CTA | BLOCKED | PASS | PASS | 768 and 1440 first-screen screenshots show a readable offer and CTA. The 375 PNG cannot establish reliable viewport geometry or clipping. |
| No horizontal page overflow | BLOCKED | BLOCKED | BLOCKED | No reliable full-page geometry measurement exists. The 375 capture is unreliable evidence; 768/1440 screenshots cover only the first screen. |
| H1 line breaks are intentional and unclipped | BLOCKED | PASS | PASS | 768/1440 H1 is fully visible in first-screen evidence. 375 cannot be judged from the unreliable capture. |
| Header/menu is usable and does not obscure content | BLOCKED | BLOCKED | PASS (visual only) | Desktop header is visually clear at 1440. Mobile/tablet interaction and focus behavior were not exercised. |
| Three scenarios are readable | BLOCKED | BLOCKED | BLOCKED | Below captured first screen; no inspection evidence. |
| Three permanent concept disclosures are readable | BLOCKED | BLOCKED | BLOCKED | Below captured first screen; no inspection evidence. |
| Concept panels do not clip or overflow | BLOCKED | BLOCKED | BLOCKED | No concept-panel screenshots or geometry measurements. |
| Process layout remains readable | BLOCKED | BLOCKED | BLOCKED | Section not inspected. |
| About layout remains readable | BLOCKED | BLOCKED | BLOCKED | Section not inspected. |
| FAQ state and final CTA are clear | BLOCKED | BLOCKED | BLOCKED | Sections not inspected. |
| No layout jump during load | BLOCKED | BLOCKED | BLOCKED | Settled screenshots cannot prove load stability. |

## Interaction and accessibility checks

All browser runtime interaction and accessibility checks remain BLOCKED: skip link, keyboard/focus traversal, mobile menu, concept tabs, FAQ ARIA state, zoom/reflow, reduced motion, contrast, and JavaScript-disabled rendered baseline were not exercised in a controllable browser session.

## Runtime and release checks

| Check | Status | Evidence |
| --- | --- | --- |
| No console errors | BLOCKED | No controllable browser console capture. |
| No unexpected external network requests | BLOCKED | No browser network capture. |
| Telegram placeholder is the known publication blocker | BLOCKED | Publish-ready remains blocked by placeholder configuration; do not claim release readiness. |
| Development-mode static test | PASS | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify_landing.ps1` exits 0. |
| Node probe | PASS | `node tests/probe_interactions.mjs` exits 0; this is a static/null-site-config regression probe, not browser interaction QA. |
| Publish-ready | BLOCKED | Placeholder Telegram/owner publication markers remain unresolved. |

## Repair record

- Task 6 CSS changes are fully reverted.
- The 375 headless PNG is unreliable evidence due to probable Edge minimum layout width and/or crop; no reproducible real overflow is claimed.
- `.hero__copy` is not established as a root cause.
- No RED/GREEN or post-fix result is claimed for the unverified 375 issue.
- Runtime interaction QA remains BLOCKED.
