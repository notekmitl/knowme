# Thai Beta Full Page Screenshot Mode

**Status:** ACTIVE  
**Date:** July 2026  
**Related commit:** Thai Beta Full Page Screenshot Mode  
**Prior attempt:** `46fa035` — nested scroll fix (insufficient for Flutter Web host)

---

## Root cause (round 2)

After removing nested `Expanded` + inner vertical scroll, GoFullPage still captured only the top of `/beta/thai` because:

1. **Flutter Web host elements** (`flt-glass-pane`, `flutter-view`, `flt-scene-host`) remain **viewport-height** (`100vh` / `100%`) with overflow clipped.
2. **`SingleChildScrollView`** keeps scroll inside the Flutter view — the **browser document** `scrollHeight` stays ≈ `window.innerHeight`.
3. **Fixed `bottomNavigationBar`** on `Scaffold` does not contribute to document growth.

GoFullPage scrolls the **document**, not Flutter's internal scrollable. Without host height sync, there is nothing to scroll.

---

## Why Flutter Web host needed a fix

Flutter Web mounts the app in a glass pane sized to the viewport. CSS `html.screenshot-friendly` alone is not enough — the engine re-applies viewport sizing. Screenshot mode therefore:

1. Adds `html.screenshot-friendly` **only in screenshot mode** (not normal `/beta/thai`).
2. Measures report content via `thaiBetaReportCaptureContentKey`.
3. Calls `window.__syncThaiBetaScreenshotHost(heightPx)` to set `--thai-beta-report-content-height` and expand host nodes.

---

## Screenshot URLs

| URL | Purpose |
|-----|---------|
| `/beta/thai?screenshot=1` | Normal flow; report uses capture layout at end |
| `/beta/thai?capture=1` | Alias of screenshot mode |
| `/beta/thai/capture` | **Fallback** — static sample report, capture-only layout |

---

## Screenshot mode behavior

When active:

- No step progress bar
- No fixed bottom feedback bar (static caption at content end)
- No mount animations on mirror sections
- No inner vertical scroll — one long `Column`
- No nested `Scaffold` on mirror (embedded mode)
- Web host height synced to measured content
- Internal diagnostics panel (screenshot mode only)

Normal `/beta/thai` (without query param) is **unchanged**: progress bar, scroll view, fixed feedback CTA.

---

## JS verification (browser console)

After report renders in screenshot mode:

```javascript
window.innerHeight
document.documentElement.scrollHeight
document.body.scrollHeight
```

**Pass:** `document.documentElement.scrollHeight` is clearly greater than `window.innerHeight` (target: > 2× for long reports).

Also check:

```javascript
getComputedStyle(document.querySelector('flt-glass-pane')).minHeight
document.documentElement.style.getPropertyValue('--thai-beta-report-content-height')
```

---

## GoFullPage verification steps

1. Complete beta flow to report **or** open `/beta/thai/capture`.
2. Append `?screenshot=1` if using normal flow URL.
3. Wait for report + diagnostics panel to show synced heights.
4. Run GoFullPage — extension should auto-scroll through full document.
5. Confirm capture includes footer / source section / disclaimers.

---

## Fallback capture route

`/beta/thai/capture` — sample birth data, no progress stepper, no fixed bar, no animations. For ops/QA when query param flow is inconvenient.

Does **not** change normal user report output.

---

## Actual URL verification

**Status: NOT YET VERIFIED in production browser** (code fix applied; deploy + manual check required).

After deploying, verify on `https://knowme-app-694e1.web.app`:

| Check | URL | Expected |
|-------|-----|----------|
| Capture route | `/beta/thai/capture` | Capture report page; banner **Thai Beta Capture Mode Active**; not Home/Today |
| Screenshot query | `/beta/thai?screenshot=1` | Report uses screenshot layout (after flow or direct report) |
| Capture query alias | `/beta/thai?capture=1` | Same as screenshot=1 |
| Progress stepper | screenshot mode | Hidden on report |
| Fixed bottom bar | screenshot mode | Hidden on report |
| Diagnostics | screenshot mode | Visible panel with route/query/scroll heights |
| Document scroll | screenshot mode | `document.documentElement.scrollHeight > window.innerHeight` |
| GoFullPage | screenshot mode | Full report captured (manual extension test) |
| Normal beta | `/beta/thai` | Unchanged — stepper + feedback bar |

Do **not** mark this section as fixed until each row is checked in a real browser against the deployed build.

---

## Manual verification checklist

- [ ] `?screenshot=1` enables diagnostics panel
- [ ] `docScrollHeight > innerHeight` after layout settles
- [ ] GoFullPage reaches bottom of report
- [ ] Normal `/beta/thai` still has feedback bar + progress
- [ ] Mobile scroll works in normal mode
- [ ] Public fingerprint unchanged (`flutter test test/validation/thai/`)

---

## Tests

```bash
flutter test test/validation/thai_beta/thai_beta_screenshot_mode_test.dart
flutter test test/validation/thai_beta/thai_beta_report_scroll_layout_test.dart
flutter test test/validation/thai/
```

---

**Report content / engine / copy unchanged. Layout + web host only in screenshot mode.**
