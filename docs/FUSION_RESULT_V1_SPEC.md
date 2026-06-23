# Fusion Result V1 — Frozen Presentation Spec

**Status:** Frozen v1 (presentation polish passes 1–4 complete, June 2026)  
**Scope of freeze:** presentation, copy, formatting only  
**Not frozen without strong reason:** `FusionBuilder` synthesis logic, lens threshold (≥2 usable lenses), loader/Firestore paths, architecture

**Implementation:**

| File | Role |
|------|------|
| `lib/features/tests/fusion/presentation/fusion_result_page.dart` | Page UI |
| `lib/features/tests/fusion/application/fusion_builder.dart` | Synthesis logic |
| `lib/features/tests/fusion/application/fusion_lens_loader.dart` | Lens loading |
| `lib/core/i18n/app_text.dart` | `fusion_v11_*` keys |

Legacy files in `application/fusion_engine.dart`, etc. remain for compatibility — do not aggressively delete.

---

## What Fusion Is

Reflection-based overview across available lenses.

**Mental model:** *หลายมุมกำลังช่วยสะท้อนตัวฉัน*

**NOT:** personality verdict, diagnosis, astrology dump, mega-report, psychometric dashboard.

Fusion exposes: what exists, what is missing, how lenses connect.

---

## Reading Structure (Frozen)

```
Foundation
  ↓
Lens snapshots
  ↓
Self-discovery status
  ↓
Synthesis
  ↓
Disclosure
```

**Reading model:** context → reflection → exploration progress → connection → trust

**Page title (TH):** หลายมุมของคุณเชื่อมกันอย่างไร

---

## Section Spec

### Foundation

- Context only: birth date, time, place
- Label/value rows (`เกิด:` / `สถานที่:`)
- **No** astrology summary here (avoids duplicate with snapshot)
- If no birth meta: short intro only

### Lens snapshots

- Short reflective paragraphs per **completed** lens only
- Astrology title: **มุมมองจากโหรา** (not ดวงชะตา)
- Reuse `AstrologyHeroSynthesis` when chart exists
- Pending lenses **not** listed (reduces noise)

### Self-discovery status

- Compact exploration map — not admin checklist
- Zero tests: `ยังไม่ได้สำรวจแบบทดสอบในตอนนี้` + lens names
- Partial: `สำรวจแล้ว:` / `ยังไม่ได้สำรวจ:`

### Synthesis

| Mode | Condition | Behavior |
|------|-----------|----------|
| **Case A — True Empty** | No astrology | Soft neutral state (guest / abnormal) |
| **Case B — Astrology-first** | Astrology only, &lt;2 lenses | Fusion started; warm copy, not blocked |
| **Case C — Synthesis** | ≥2 usable lenses | Agreement + tension + synthesis (deterministic) |

**Case B example tone:** ตอนนี้ภาพรวมยังอ้างอิงจากโหราเป็นหลัก เมื่อคุณลองสำรวจตัวเองในด้านอื่นเพิ่มขึ้น คุณอาจเริ่มเห็นว่าหลายมุมของตัวเองค่อย ๆ เชื่อมโยงกันมากขึ้น

### Disclosure

- Subtle footer (~13.5px, readable contrast)
- Reflective interpretation, not objective truth

---

## Formatting Rules

| Item | Rule |
|------|------|
| Birth date/time (TH) | `12 เม.ย. 1958 • 15:00 น.` (zero-padded time) |
| Birth place (presentation) | `ลำพูน, Thailand` → `ลำพูน ประเทศไทย` (display only) |

**Visual hierarchy:** Foundation (highest) → Lens snapshots → Self-discovery (lightest) → Synthesis → Disclosure (quiet)

**Tone:** calm, reflective, warm, believable, readable

**Avoid:** debug/admin UI, placeholders, `—` empty values, duplicate paragraphs, daily horoscope vibe, verbose labels

**Target feeling:** *โอเค นี่คือภาพรวมหลายมุมของฉัน*

---

## Maintenance Rule

Allowed: blocker fixes, meaningful friction, analytics-driven usability, real user feedback.

Avoid: spacing churn, copy churn, repeated redesign, micro polish loops.

Revisit only when product direction changes or production friction is proven.

---

## Regression Checklist (B5)

- [ ] Foundation: date/time, place format, hierarchy
- [ ] Lens snapshots: only available lenses; no dump; astrology/EQ/MBTI when present
- [ ] Self-discovery: explored/unexplored correct; compact; no checklist feel
- [ ] Synthesis: Case B and Case C; agreement/tension/synthesis render
- [ ] Disclosure: readable, subtle, trust-building
- [ ] Reading order matches frozen structure
- [ ] TH copy grounded; EN fallback works
