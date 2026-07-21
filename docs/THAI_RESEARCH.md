# Thai Astrology Research

A standalone, production-deployed surface that collects real-world validation
feedback for the Thai Astrology lens. It **reuses** the completed Birth
Normalization layer and the production Thai Engine + report — it adds **no**
astrology pipeline and makes **no** runtime/reasoning change.

- **Package:** `lib/features/thai_beta/`
- **Routes:** `/beta/thai` (public), `/internal/thai-beta` (admin, gated)
- **Collection:** `thai_beta_feedback` (rules in `firestore.rules`)
- **Decisions:** D-038 (launch + hardening), D-039 (UX V1)

> The route and collection retain the `beta` identifier to avoid breaking the
> deployed link / orphaning data; all **user-facing copy** says
> “Thai Astrology Research” (งานวิจัย), never “Beta”.

## Flow

```
ThaiBetaLandingPage (/beta/thai)          purpose · time · privacy · participation · participant count → "เริ่มการวิเคราะห์"
  → ThaiBetaInputPage          [step 1]   name, birth date, 24h birth time, province, gender → "เริ่มวิเคราะห์"
  → ThaiBetaAnalysisRunner.run            RawBirthInput → BirthNormalizer → ThaiEngineAdapter → ThaiMirrorPipeline
  → ThaiBetaSummaryPage        [step 2]   "ข้อมูลที่ใช้วิเคราะห์" card + transparency banner + technical debug panel → "ยืนยันข้อมูลและดูผล"
  → ThaiBetaReportPage         [step 3]   the existing ThaiMirrorResultPage (unchanged) + feedback CTA
  → ThaiBetaFeedbackPage       [step 4]   rating, free-text (incl. "why recommend"), perceived method, consent → "ส่งความคิดเห็น"
  → ThaiBetaStore.save                    sequential researchId + timing + reportHash → thai_beta_feedback
  → ThaiBetaCompletionPage                thank-you + Reference ID + invite to return after improvements
```

Every step carries a 4-step progress indicator (`ThaiBetaProgressBar`:
กรอกข้อมูล · ตรวจสอบข้อมูล · อ่านผล · ส่งความคิดเห็น). The session is forward-only
and shows **no navigation controls** (no back arrows) — it is a standalone
research experience.

## UX V1 (D-039)

1. **No back buttons.** Every step sets `automaticallyImplyLeading: false`
   (the report page has no app bar).
2. **True 24-hour birth time**, **never** AM/PM — users frequently misread
   12 AM / 12 PM around midnight. (Originally a wheel; replaced in D-041 by two
   inline hour/minute controls — see below.)
3. **Research summary** before the report (`ThaiBetaSummaryPage`) so users are
   reassured about what was used *before they start reading*:
   - **ข้อมูลที่ใช้วิเคราะห์** card — ชื่อ, นามสกุล, วันเกิด, เวลาเกิด, จังหวัดเกิด,
     เพศ, พระอาทิตย์ขึ้น, วันโหราศาสตร์ไทย, Timezone. Dates render in the Thai
     Buddhist era with Thai month names (`8 มิถุนายน 2525`).
   - **Transparency banner**: when the birth was before sunrise it explains that
     the Thai day starts at sunrise and that the previous weekday is used
     (e.g. *ใช้ วันเสาร์ แทน วันอาทิตย์*); otherwise *ระบบใช้วันเกิดตามปฏิทิน*.
   - **Collapsible technical panel** ("ข้อมูลที่ใช้คำนวณ"): Latitude, Longitude,
     Coordinates, Timezone, Sunrise, Hash (SHA-256), Research ID.

The displayed Thai astrological date is derived directly from Birth
Normalization (`birth.thai.astrologicalDate`); the summary only formats it. A
validation test asserts the displayed date equals normalization for birth times
`00:00 / 03:00 / 05:47 / 05:48 / 12:00 / 23:59`.

## UX polish (D-040)

Trust / completion / feedback-quality pass (UX only):

- **Landing screen** (`ThaiBetaLandingPage`) before the form — purpose, estimated
  time (3–5 min), privacy, research-participation note, and a best-effort
  participant count (the shared counter `seq`, omitted if unavailable) → primary
  CTA **เริ่มการวิเคราะห์**.
- **4-step progress indicator** on every step (`ThaiBetaProgressBar`).
- **Clearer button copy:** input → **เริ่มวิเคราะห์**, summary →
  **ยืนยันข้อมูลและดูผล**, feedback → **ส่งความคิดเห็น**.
- **Completion screen** (`ThaiBetaCompletionPage`) replaces the success dialog —
  thank-you, large Reference ID, and an invite to return after future
  improvements (restart resets the flow to the landing screen).

## Desktop/web fixes (D-041)

Web/desktop usability only (no engine/runtime/report change):

- **Birth time = two inline controls** (`ThaiBetaTimeField`): hour `00–23` +
  minute `00–59` via Material 3 `DropdownMenu`s — click, **type**, and keyboard
  navigation; **no scrolling wheel**. Each menu's height is bounded so it stays
  on-screen.
- **Province = searchable autocomplete** (`ThaiBetaProvinceField`): type-ahead
  filtering (`เชียง` → เชียงใหม่/เชียงราย; `อุดร` → อุดรธานี) with keyboard nav,
  mouse selection, touch support, a clear button, and a height-bounded options
  popup. Exact-text matches sync the selection; partial text never silently
  counts as a province.
- The birth **date** still uses the centered Material `showDatePicker` dialog;
  with time now inline there is no off-screen popup.

## Security & data quality (D-038)

- **Repo-managed `firestore.rules`** (deploy with `firebase deploy --only
  firestore:rules`): existing data stays owner-only under `users/{uid}/**`;
  `thai_beta_feedback` is public **create** (validated) / **admin-only read**;
  `counters/thai_research` allows only `+1` increments (backs research ids).
- **Admin gate** (`ThaiResearchAdminGuard`): reuses FirebaseAuth + an
  `admins/{uid}` allow-list (same source of truth as the rules) and **fails
  closed**. Provision an admin out-of-band (`admins/{uid}`); client writes to
  `admins/` are denied.
- **No silent save failures:** `ThaiBetaStore.save` returns success (with the
  Reference ID) or an error; the UI shows Thank-you / “please try again”.
- **Provenance per submission:** sequential `researchId` (`TH-00000001`),
  `startedAt` / `submittedAt` / `durationSeconds`, and a deterministic SHA-256
  `reportHash` of the report snapshot.

## Admin

`/internal/thai-beta` — search/filter by rating, engine version, Thai date; the
list shows `researchId` + duration; the detail view shows `researchId`,
duration, and `reportHash`; the dashboard shows totals, average rating, rating
distribution, and most-frequent feedback themes.

## Key files

| Concern | File |
|---------|------|
| Input form (24h picker) | `presentation/pages/thai_beta_input_page.dart`, `presentation/widgets/thai_beta_time_picker.dart` |
| Summary / transparency / debug | `presentation/pages/thai_beta_summary_page.dart`, `presentation/widgets/thai_beta_{summary_card,transparency_banner,debug_panel}.dart` |
| Thai date formatting | `presentation/thai_beta_thai_date_format.dart` |
| Analysis runner | `application/thai_beta_analysis.dart` |
| Store + research id | `application/thai_beta_store.dart` |
| Admin gate / dashboard | `application/thai_research_admin_access.dart`, `presentation/admin/*` |

## Related documents

- [`PRODUCT_VALIDATION.md`](PRODUCT_VALIDATION.md) §8 — research surface in the validation program.
- [`BIRTH_NORMALIZATION.md`](BIRTH_NORMALIZATION.md) — the birth-input layer this reuses.
- [`DECISION_LOG.md`](DECISION_LOG.md) D-038, D-039.
