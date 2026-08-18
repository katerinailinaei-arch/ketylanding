# Manual viewport QA

Initial browser inspection was not completed during Task 3. The local browser setup attempt did not return, so no visual result is inferred from static checks.

## 375×812

- Status: **PENDING — scheduled for Task 6**
- Check: no horizontal page scroll; full-width primary CTA; hero copy precedes workshop map; sticky header does not obstruct content.
- Screenshot: pending.

## 768×1024

- Status: **PENDING — scheduled for Task 6**
- Check: two-column hero; readable concept panels; process cards preserve DOM order; focus indicators remain visible.
- Screenshot: pending.

## 1440×900

- Status: **PENDING — scheduled for Task 6**
- Check: 1240 px inner container and 1440 px page cap; three scenario columns; workshop map geometry; line lengths and CTA hierarchy.
- Screenshot: pending.

## Task 4 interaction and motion QA

| Check | Status | Evidence |
| --- | --- | --- |
| Keyboard: skip link, menu Escape/focus return, concept tabs, FAQ toggle and visible focus | BLOCKED | No controllable browser was available in this environment on 2026-08-18; do not infer interactive behavior from static checks. |
| Reduced motion: no reveal transition or decorative motion | BLOCKED | Browser emulation was unavailable. The implementation gates `initReveal()` on `prefers-reduced-motion` and has a reduced-motion CSS override; this still requires browser confirmation. |
| JavaScript syntax | PASS | `node` compiled both behavioral inline scripts successfully. |
