# Astrology QA Harness V1

A reusable, production-faithful preview + validation platform for KnowMe's
astrology reports. It was built first for the **Thai Astrology Consumer Report**,
but is intentionally generic so the same pattern serves **Western, Chinese,
Fusion, Future Prediction and Compatibility** reports.

The harness has three goals:

1. **Preview** any report state from a URL (shareable, deterministic).
2. **Screenshot regression** — a frozen visual baseline that fails on drift.
3. **Story coverage validation** — automated copy/layout quality gates in CI.

The golden rule: **the harness renders the real production pipeline and the real
production page. It never duplicates report UI.** It only chooses the inputs and
frames the output.

---

## 1. Components

| Concern | File |
| --- | --- |
| Spec (URL → render description) | `lib/features/astrology/thai/qa/harness/thai_qa_harness_spec.dart` |
| Profiles (A…H birth data) | `lib/features/astrology/thai/qa/harness/thai_qa_harness_profiles.dart` |
| Harness page (drives prod pipeline) | `lib/features/astrology/thai/qa/harness/thai_qa_harness_page.dart` |
| Preview page (thin wrapper) | `lib/features/astrology/thai/mirror/presentation/pages/thai_mirror_consumer_preview_page.dart` |
| Screenshot regression | `test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart` |
| Story coverage validation | `test/validation/thai_mirror_qa_harness/story_coverage_validation_test.dart` |

`ThaiQaHarnessPage` calls exactly what production calls:

```
ThaiMirrorPipeline.generate(birthData)        // production pipeline
  → ThaiMirrorConsumerPresenter.present(...)   // production presenter
    → ThaiMirrorResultPage(consumerState)      // production page
```

It then *frames* the page (theme / locale / viewport) and re-derives the Life
Timeline at a chosen "as of" date for age / future scenarios.

---

## 2. URL / Query API

Route: `/thai-mirror/consumer-preview`

| Param | Values | Meaning |
| --- | --- | --- |
| `profile` | `A`…`H` | Which birth profile to render |
| `age` | integer | Override the current life-stage age |
| `future` | integer | Simulate aging N years from today (ignored if `age` set) |
| `viewport` | `desktop` `tablet` `mobile` `full` | Frame width (1440 / 768 / 390 / fill) |
| `theme` | `light` `dark` | Brightness |
| `locale` | `th` `en` | Localizations override |
| `scenario` | `no_time` | Render the "no birth time" product state |
| `birthtime` | `false` | Alias for `scenario=no_time` |

Examples:

```
/#/thai-mirror/consumer-preview?profile=C&viewport=mobile&theme=dark
/#/thai-mirror/consumer-preview?profile=A&age=58
/#/thai-mirror/consumer-preview?profile=F&future=20&locale=th
```

These deep links bypass `AuthGate` on web (see `WebLaunchRouter`) so visual QA
needs no login, incognito, or manual service-worker refresh.

---

## 3. No-stale-build policy (service worker)

The deprecated Flutter web service worker was the reason a fresh deploy needed
`Ctrl+Shift+R` / incognito. It is now **disabled**:

* `web/index.html` loads `flutter.js` and calls `_flutter.loader.load(...)`
  **without** `serviceWorkerSettings`, so no worker is ever registered. It also
  unregisters any previously-installed worker and clears its caches once, so
  existing devices self-heal.
* `firebase.json` serves `index.html`, `main.dart.js`, `flutter.js`,
  `flutter_bootstrap.js` and `flutter_service_worker.js` as `no-cache`. The
  immutable rule for hashed `*.js/css/wasm` is listed **before** these overrides
  so the entry files always win and are re-fetched.

Net effect: the latest production build activates automatically on the next
normal page load.

---

## 4. Screenshot Regression Harness

`screenshot_regression_test.dart` renders A…H × {desktop, tablet, mobile} and
saves per-section PNG baselines with deterministic filenames:

```
screenshots/<profile>_<viewport>_<section>.png
e.g. a_mobile_thai_consumer_life_timeline.png
```

The Life Timeline current age is pinned to a fixed `asOf` date so baselines do
not drift day-to-day. Captured sections are the high-signal ones (hero, life
timeline, life dashboard, strengths, advice) to avoid large-raster flakiness.

Regenerate after intentional UI changes:

```
flutter test test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart --update-goldens
```

---

## 5. Story Coverage Validation

`story_coverage_validation_test.dart` fails CI when the report regresses. For
every profile it asserts:

* every required section renders,
* no empty cards (each section has real text),
* no placeholder copy (`TODO`, `lorem`, `null`, `{{`, `${`, …),
* no duplicated section headings,
* no English leakage (Thai report stays Thai; short Latin labels allow-listed),
* no layout overflow (`tester.takeException()` is null).

```
flutter test test/validation/thai_mirror_qa_harness/story_coverage_validation_test.dart
```

---

## 6. Reusing the harness for another report

To stand up the same platform for Western / Chinese / Fusion / Future /
Compatibility:

1. **Profiles** — add a `<system>_qa_harness_profiles.dart` with a small,
   diverse A…H birth-data set (vary the inputs that change that system's output).
2. **Spec** — reuse `ThaiQaHarnessSpec` as-is, or copy it and add system-specific
   scenario flags. Keep `screenshotToken` for deterministic filenames.
3. **Harness page** — copy `ThaiQaHarnessPage` and swap the three production
   calls (`<System>Pipeline.generate` → `<System>Presenter.present` →
   `<System>ResultPage`). Do **not** re-implement report widgets.
4. **Route** — add `/<system>/consumer-preview` and parse the spec with
   `fromQueryParameters`. Add the public deep link to `WebLaunchRouter` if it
   should bypass auth.
5. **Validation** — copy the two test files, point them at the new profiles +
   page, and generate baselines with `--update-goldens`.

Because every report is rendered through its own production pipeline, the harness
stays a thin, shared QA layer rather than a parallel UI.
