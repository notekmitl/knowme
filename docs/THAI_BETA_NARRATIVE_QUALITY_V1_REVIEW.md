# Thai Beta Narrative Quality V1 — Review

**Date:** July 2026  
**Branch:** `ai-worker/20260721-113408-6ec06c-knowme-ai-worker-execution-brief-thai-beta`  
**Scope:** Thai Beta consumer narrative / presentation / export text only

---

## Root cause

1. **Wrong-domain text** — Life dashboard and some sections picked themes by engine score without domain semantic filtering. A high-scoring trait (e.g. teaching, word-choice) could appear under สุขภาพ or การเงิน even when the phrase had no health/finance meaning.
2. **Repetition** — Shared templates from `ThaiMirrorReportCopy.buildExpandedStrength` (`สิ่งที่คนมักสัมผัสได้...`, `อย่างเช่น เมื่อต้องใช้`) and facet-level scaffolding reused across sections without presentation dedupe.
3. **Low specificity** — Single-trait Barnum lines (`คุณมุ่งมั่น`, `คุณคิดละเอียด`) without situational layering from secondary traits or life domain.
4. **Formatting** — Export polish handled some spacing but missed em-dash, bullet, age-label, and Thai transition-word gluing (`ปกติลอง`). An early normalizer regex also risked splitting valid compounds (`ตั้งแต่`, `ทดลอง`) when splitting on `แต่`/`ลอง` substrings inside words.

---

## Narrative pipeline

### Before

```
ThaiBetaInput → Engine (ThaiMirrorPipeline) → ThaiMirrorConsumerPresenter
  → ThaiMirrorConsumerViewState (raw)
  → ThaiBetaReportPage / ThaiBetaReportExportDocument.fromAnalysis (direct)
  → ThaiBetaReportExportPolish (spacing only)
```

### After

```
ThaiBetaInput → Engine (unchanged) → ThaiMirrorConsumerPresenter (unchanged)
  → ThaiMirrorConsumerViewState (source)
  → ThaiBetaNarrativeComposer (NEW — presentation only)
      ├─ ThaiBetaDomainSemanticTags (domain theme selection)
      ├─ ThaiBetaNarrativeHero (WOW opening)
      ├─ ThaiBetaNarrativeSpecificity (2-layer copy)
      ├─ ThaiBetaNarrativeDedupe (section + global)
      └─ ThaiBetaNarrativeFormatting (Thai normalizer)
  → ThaiBetaReportPage + ThaiBetaReportExportDocument (same composed view)
  → ThaiBetaReportExportPolish (+ narrative formatting pass)
```

---

## Semantic mapping

| Domain | Selection inputs | Required topics |
|--------|------------------|-----------------|
| การงาน | `ThemeLifeHints.work`, facet affinity (leadership, action, drive), `workHint` | work method, goals, collaboration, pressure |
| การเงิน | `ThemeLifeHints.money`, structure/thinking facets, `moneyHint` | stability, spending, saving, risk |
| ความรัก | `ThemeLifeHints.love`, people/emotion facets, `loveHint` | trust, intimacy, communication, space |
| สุขภาพ | `ThemeLifeHints.health`, emotion/caution facets, `healthHint` | rest, stress, body signals, recovery |
| โชคและโอกาส | `ThemeLifeHints.luck`, novelty/drive facets, `luckHint` | timing, readiness, adapt, courage |

Selection: `compatibilityScore(themeId, domain)` → deterministic pick via `profileSeed + domain offset`.  
Rejection: `isTextDomainCompatible()` uses domain marker sets + life-hint evidence (not keyword-only).

---

## Dedupe strategy

- Normalize keys via `ThaiBetaNarrativeFormatting.normalizedKey`
- Per-section dedupe + global `used` set across dashboard, hero, strengths, narrative sections
- Narrative section fields (`whyItAppears`, `advice`, `example`, etc.) use `_fieldAfterSectionDedupe()` so removed duplicates are cleared or replaced — not silently kept
- Rewrite strength expanded intro template (`สิ่งที่คนมักสัมผัสได้...` → `คนที่รู้จักคุณมักสังเกตว่า`)
- Block overused fixed templates when already seen globally
- Allow fixed disclaimers (`นี่ไม่ใช่คำฟันธง`, etc.) to repeat where intended

---

## Specificity strategy

- `composeTraitPair(primary, secondary, domain)` — two-layer when secondary facet differs
- `composeContrast()` — only when two distinct facets exist in ordered themes
- `observableBehavior()` — facet micro-story from existing composer (traceable)
- Dashboard `whyItAppears` combines primary headline + domain life hint + optional secondary
- Trace metadata (`ThaiBetaNarrativeTrace`) records section, field, primary/secondary trait tags, domain, life-period label, and relationship for hero, dashboard (currentState/whyItAppears/suggestedAction), and narrative sections (overview/whyItAppears/advice)

---

## WOW opening strategy

Five blocks in hero summary (max 3 tag traits):

1. External observation (primary `heroDetail`)
2. Inner drive (primary + secondary or discovery)
3. Contrast (only if contrast facet ≠ primary)
4. Observable micro-story
5. Reflective closing + grounded caution when available

No-time profiles append limitation line; no hourly-depth claims.

---

## Formatting fixes

| Before | After |
|--------|-------|
| `อายุ42–62` | `อายุ 42–62` |
| `ดาวศุกร์•` | `ดาวศุกร์ •` |
| `อยากรู้—` | `อยากรู้ —` |
| `ดี(ผ่าน` | `ดี (ผ่าน` |
| `ปกติลอง` | `ปกติ ลอง` |
| `**bold**` | stripped |
| `ตั้งแต่` / `ทดลอง` | preserved (explicit allowlist fixes only) |

Normalizer rule: transition-word spacing uses an explicit glued-phrase map (`ปกติลอง`, `ด้านนี้ลอง`) plus punctuation-boundary rules for `แต่` / `อีกด้าน` / `อย่างไรก็ตาม` — never mid-word substring insertion.

---

## Determinism proof

- All variant selection uses `profileSeed`, `reportHash` prefix, `ThaiBetaNarrativeStableHash.fnv1a32` (FNV-1a), `domain.index`, `themeId` order — no `String.hashCode`, no `Random`, no LLM
- Tests: `thai_beta_narrative_determinism_test.dart` — same input → identical hero, dashboard, export text (5 consecutive runs)

---

## Fixtures A–E

| Fixture | Birth | Time | ~Age @ 2026-07-21 | Purpose |
|---------|-------|------|-------------------|---------|
| A | 1982-04-04 | 10:30 | 44 | Full time, primary+secondary traits |
| B | 1981-06-15 | none | 45 | Confidence limitation, no hourly depth |
| C | 1990-08-20 | 14:00 | 35 | Facet tension |
| D | 1982-04-05 | 10:30 | 44 | Near-duplicate trait check |
| E | 2000-01-10 | 08:00 | 26 | Different life period |

---

## Before / after examples (8+)

### 1. Hero headline
- **Before:** Multi-line template `คุณเป็นคนที่… แต่ในเวลาเดียวกัน ก็…`
- **After:** `คุณมักชอบเรียนรู้ ในขณะที่ อีกด้านหนึ่งคุณรู้สึกลึกซึ้งเมื่อสถานการณ์เร่ง` (Fixture A)

### 2. Strength intro template
- **Before:** `สิ่งที่คนมักสัมผัสได้จากคุณก่อนเลยคือ **มุ่งมั่น** — คุณมุ่งมั่นและไม่หยุด...`
- **After:** `คนที่รู้จักคุณมักสังเกตว่า คุณฟื้นตัวจากความยากลำบาก...`

### 3. Behavior example
- **Before:** `อย่างเช่น เมื่อต้องใช้มุ่งมั่น...`
- **After:** `ตัวอย่างที่พบได้บ่อยคือเมื่อต้องใช้ฟื้นตัวจากความยาลำบาก...`

### 4. Health dashboard (semantic)
- **Before (pattern):** Health card describing teaching/explaining to others
- **After:** Domain life hint e.g. `ด้านพลังใจ คุณมัก... — สังเกตสัญญาณจากร่างกาย...`

### 5. Finance dashboard
- **Before (pattern):** Generic personality trait unrelated to money
- **After:** `เรื่องเงิน คุณมัก... — คุณเปรียบเทียบตัวเลือกก่อนใช้เงินก้อนใหญ่`

### 6. No-time limitation (Fixture B)
- **After hero includes:** `โดยไม่มีเวลาเกิด รายงานนี้เน้นภาพรวมจากวันเกิด และไม่ลงลึกเรื่องจังหวะชีวิตรายชั่วโมง`

### 7. Formatting age
- **Before:** `อายุ42–62`
- **After:** `อายุ 42–62`

### 8. Title vs body echo
- **Before:** Title `มีแรงขับเคลื่อนสูง` + immediate repeat `คุณมักมุ่งมั่น...`
- **After:** Dedupe removes adjacent semantic duplicate; title and body serve different roles

### Hero samples (3 profiles)

**Fixture A:** Headline combines อยากรู้ + รู้สึกลึก; summary includes contrast + observable meeting behavior.  
**Fixture B:** Headline combines นำทีมได้ + รับผิดชอบ; limitation block present.  
**Fixture E:** Different period/tags vs A/B (verified by determinism + specificity tests).

---

## Forbidden patterns (regression)

Regex suite in `ThaiBetaNarrativeFormatting.forbiddenPatterns` — no `**`, no `อายุ\d`, no unspaced `•` / `—` / `(`, no `ปกติลอง`.

---

## Test results

```
flutter test test/validation/thai_beta/narrative/  → 40 passed (exit 0)
flutter test test/validation/thai_beta/             → 156 passed (exit 0)
flutter test test/validation/thai/                    → 919 passed (exit 0)
flutter test test/validation/thai_beta/ test/validation/thai/ → 1075 passed (exit 0)
flutter analyze --no-fatal-warnings --no-fatal-infos → exit 0, 299 issues
flutter analyze lib/features/thai_beta/application/narrative/ → exit 0, 0 issues
```

### Scope revision (independent review)

Reverted out-of-scope **edits** from checkpoint rounds 9–10; restored files incorrectly deleted in `14610b6 KnowMe Clean Checkout Baseline Repair`:

| Item | Action |
|------|--------|
| `lib/features/human_model/coverage/*` (4 files) | **Restored** from pre-deletion state — base `4c2828f` imports these modules |
| `lib/features/human_pattern/coverage/*` (2 files) | **Restored** |
| `lib/features/human_model/builder/human_model_foundation_builder.dart` | **Restored** to match base `4c2828f` exactly (theme-evidence merge) |
| `lib/features/human_model/lineage/human_evidence_preserver.dart` | **Restored** to base |
| `lib/features/human_model/human_model_domain.dart` | **Restored** to base |
| `lib/features/human_pattern/human_pattern_domain.dart` | **Restored** to base |
| `test/human_coverage/human_pattern_coverage_expansion_test.dart` | **Restored** |
| `.gitignore`, fusion VM, mirror contracts, `test/astrology_fusion/`, `test/mirror_v3/` deletions | Absent from branch diff vs `4c2828f` |

Human model / pattern **source** files now match production base. The six coverage files appear as **new** in `git diff 4c2828f` because they were missing from the base tree but referenced by imports — restoring them fixes compilation without changing Thai Beta narrative logic.

New files:
- `thai_beta_narrative_semantic_correctness_test.dart`
- `thai_beta_narrative_dedupe_test.dart`
- `thai_beta_narrative_specificity_test.dart`
- `thai_beta_narrative_formatting_test.dart`
- `thai_beta_narrative_determinism_test.dart`
- `thai_beta_narrative_screen_pdf_parity_test.dart`
- `thai_beta_narrative_fixtures.dart`
- `thai_beta_narrative_sample_export_test.dart`

---

## Analyze baseline comparison

Command: `flutter analyze --no-fatal-warnings --no-fatal-infos` (exit 0 with policy flags)

| Scope | Before (`4c2828f`) | After (revision) | Delta |
|-------|-------------------|------------------|-------|
| Full repo | **317** issues (documented baseline) | **299** issues | **−18** (pre-existing; narrative adds 0) |
| Changed narrative files (`lib/features/thai_beta/application/narrative/*`) | 0 | 0 | 0 |
| `lib/features/thai_beta` (whole feature) | 6 info | 6 info | 0 |

Pre-existing info only in whole feature (dart:html, unnecessary_import). **No new issues in narrative changed files.**

---

## Files changed

**New (presentation layer):**
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_context.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_domain.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_dedupe.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_formatting.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_hero.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_specificity.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_stable_hash.dart`
- `lib/features/thai_beta/application/narrative/thai_beta_narrative_trace.dart`

**Hook points:**
- `lib/features/thai_beta/presentation/pages/thai_beta_report_page.dart`
- `lib/features/thai_beta/application/thai_beta_report_export_document.dart`
- `lib/features/thai_beta/application/thai_beta_report_export_polish.dart`

**Tests + docs:**
- `test/validation/thai_beta/narrative/*`
- `test/validation/thai_beta/thai_beta_report_export_test.dart` (expectations)
- `docs/THAI_BETA_NARRATIVE_QUALITY_V1_REVIEW.md`

**Scope cleanup (restored to base, not narrative):**
- `lib/features/human_model/coverage/*` (4 files)
- `lib/features/human_pattern/coverage/*` (2 files)
- `lib/features/human_model/builder/human_model_foundation_builder.dart` (matches base)
- `lib/features/human_model/lineage/human_evidence_preserver.dart` (matches base)
- `lib/features/human_model/human_model_domain.dart` (matches base)
- `lib/features/human_pattern/human_pattern_domain.dart` (matches base)
- `test/human_coverage/human_pattern_coverage_expansion_test.dart` (restored)

**Not changed:** Engine, Canon, Thai Mirror presenter, prediction, Firestore, capture scroll, PDF mechanism, goldens.

---

## Internal quality rubric (Fixtures A–E)

Scores 1–5:

| Fixture | Semantic | Specificity | Coherence | Non-repetition | Emotional resonance | Safety |
|---------|----------|-------------|-----------|----------------|---------------------|--------|
| A | 5 | 5 | 5 | 5 | 4 | 5 |
| B | 5 | 4 | 5 | 5 | 4 | 5 |
| C | 5 | 5 | 4 | 5 | 4 | 5 |
| D | 4 | 4 | 5 | 5 | 4 | 5 |
| E | 5 | 5 | 5 | 5 | 4 | 5 |

All fixtures ≥4 semantic, coherence, non-repetition. Emotional resonance average = 4.0. Safety = 5 all.

---

## Confirmations

- No runtime LLM / random
- Age, life period, timeline, traits, predictions unchanged (engine output untouched)
- Real-user export + stale-analysis protection unchanged
- Capture scroll unchanged
- Engine / Canon / Thai Mirror / goldens unchanged
- Human model / pattern source restored to base; six coverage support files re-added (no Thai Beta narrative impact)
- Stash `wip-thai-beta-export-before-capture-scroll` not applied
- Not deployed
- Commit `Thai Beta Narrative Quality V1` **not created** in this revision pass (per revision instructions)

---

## Sample output paths (local, not committed)

- `build/thai_beta_narrative_samples/fixture_a_with_time.txt`
- `build/thai_beta_narrative_samples/fixture_b_no_time.txt`

Generated via `flutter test test/validation/thai_beta/narrative/thai_beta_narrative_sample_export_test.dart`
