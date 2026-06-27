# PROJECT INDEX — Master Documentation Map

**Status:** CURRENT
**Audience:** Everyone (humans + AI agents).
**Last updated:** June 2026

This is the master index for all KnowMe documentation. It classifies every document,
states its purpose and audience, and defines the reading order. **No orphan docs:**
everything below links from here.

**Classification legend** (see [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) §12):

| Class | Meaning |
|-------|---------|
| **CURRENT** | Living reference, kept up to date — trust it |
| **HISTORICAL** | Point-in-time record, still valid as a record |
| **SUPERSEDED** | Replaced by a newer doc (named) — kept for lineage |
| **ARCHIVED** | One-off investigation, no longer maintained |
| **DEPRECATED** | Describes something no longer true/used |

---

## 1. Required reading order (any AI or new developer)

1. [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — how to behave here. **Required.**
2. [`PROJECT_INDEX.md`](PROJECT_INDEX.md) — this map. **Required.**
3. [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — fastest whole-project understanding. **Required.**
4. [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) — highest-level conceptual model (engines, ownership, flow). **Required.**
5. [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) — vision, philosophy, subsystems. **Required.**
6. [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — done / focus / risks / tech debt. **Required.**
7. [`ARCHITECTURE.md`](ARCHITECTURE.md) — pipeline layers + code organization. **Required.**
8. [`GOVERNANCE.md`](GOVERNANCE.md) + [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — what you may change. **Required.**
9. [`DECISION_LOG.md`](DECISION_LOG.md) — why decisions were made (read before reopening one). **Required.**
10. [`ROADMAP.md`](ROADMAP.md) — completed / active / future. **Required.**
11. [`HANDOFF.md`](HANDOFF.md) — setup, branches, validation commands. Recommended.
12. Domain docs as needed (§4–§7 below).

---

## 2. Core reference set (CURRENT — start here)

| Document | Purpose | Audience | Required | Related |
|----------|---------|----------|----------|---------|
| [`../README.md`](../README.md) | Repo entry point + doc index | All | Yes | PROJECT_INDEX, EXECUTIVE_SUMMARY |
| [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) | Permanent AI alignment: rules, reading order, never-do | AI agents, devs | Yes | GOVERNANCE, PROJECT_FREEZE, MASTER_CONTEXT |
| [`PROJECT_INDEX.md`](PROJECT_INDEX.md) | This master index | All | Yes | everything |
| [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) | Fastest full-project understanding; architecture, freeze map, tech debt, decisions, roadmap | All | Yes | ARCHITECTURE, PROJECT_FREEZE, ROADMAP, DECISION_LOG |
| [`DOMAIN_MODEL.md`](DOMAIN_MODEL.md) | Highest-level conceptual model: Human Understanding, Personality, Runtime, engine ownership + data flow (diagrams) | All | Yes | ARCHITECTURE, EXECUTIVE_SUMMARY, DECISION_LOG |
| [`DECISION_LOG.md`](DECISION_LOG.md) | Why major architectural/product decisions were made (D-001…) | Devs, AI | Yes | DOMAIN_MODEL, PROJECT_FREEZE, EXECUTIVE_SUMMARY |
| [`KNOWME_MASTER_CONTEXT.md`](KNOWME_MASTER_CONTEXT.md) | Canonical vision, philosophy, subsystem map, copy rules | All | Yes | CURRENT_STATUS, ARCHITECTURE, ROADMAP, GOVERNANCE |
| [`CURRENT_STATUS.md`](CURRENT_STATUS.md) | What's done, active focus, risks, technical debt, deployment | All | Yes | ROADMAP, GOVERNANCE, DEPLOYMENT |
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | Stack layers, runtime paths, code organization | Devs, AI | Yes | MASTER_CONTEXT, EXECUTIVE_SUMMARY |
| [`ROADMAP.md`](ROADMAP.md) | Evidence-based completed / active / future | All | Yes | CURRENT_STATUS, GOVERNANCE |
| [`GOVERNANCE.md`](GOVERNANCE.md) | Freeze policy + active/deferred/exception programs | Devs, AI | Yes | PROJECT_FREEZE, CURRENT_STATUS |
| [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) | Per-system freeze registry + replacement plans | Devs, AI | Yes | GOVERNANCE, EXECUTIVE_SUMMARY |
| [`HANDOFF.md`](HANDOFF.md) | Onboarding: setup, branches, app flow, validation commands | Devs | Recommended | DEPLOYMENT, FIRESTORE_SCHEMA, ARCHITECTURE |
| [`DEPLOYMENT.md`](DEPLOYMENT.md) | Firebase web deploy, URLs, scripts, rollback | Devs | Recommended | HANDOFF, CURRENT_STATUS |
| [`FIRESTORE_SCHEMA.md`](FIRESTORE_SCHEMA.md) | `tests/*` vs `results/*`, profile/astrology paths | Devs | Recommended | HANDOFF, MBTI_ARCHITECTURE |

---

## 3. Subsystem references (CURRENT)

| Document | Purpose | Audience | Class | Related |
|----------|---------|----------|-------|---------|
| [`MBTI_ARCHITECTURE.md`](MBTI_ARCHITECTURE.md) | MBTI Progressive/Cognitive/Summary; sessions, scoring, storage | Devs | CURRENT | FIRESTORE_SCHEMA, FUSION_RESULT_V1_SPEC |
| [`FUSION_RESULT_V1_SPEC.md`](FUSION_RESULT_V1_SPEC.md) | Frozen Fusion Result UI/copy spec | Product, devs | CURRENT (frozen contract) | GOVERNANCE, ARCHITECTURE |
| [`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md) | Reusable astrology preview + screenshot/story validation harness | Devs, QA | CURRENT | EXECUTIVE_SUMMARY |
| [`GF2_PRODUCTION_IMPLEMENTATION_V1.md`](GF2_PRODUCTION_IMPLEMENTATION_V1.md) | Production wiring of MV2 promotion + GF2 recovery (the GF2 status of record) | Devs, validation | CURRENT (implementation record) | GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION, GF2_ROOT_CAUSE_ISOLATION_REPORT |
| [`NARRATIVE_EVIDENCE_BRANCHING_V5.md`](NARRATIVE_EVIDENCE_BRANCHING_V5.md) | Terminal narrative-intelligence state (1000/1000 unique) | Devs, validation | CURRENT | NARRATIVE_PLAN_TOPOLOGY_V4, NARRATIVE_INTELLIGENCE_SELECTION_V3 |
| [`GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md`](GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md) | MV2 + GF2 architecture/design spec (now implemented) | Devs | CURRENT (design ref; implemented) | GF2_PRODUCTION_IMPLEMENTATION_V1 |
| [`THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`](THAI_FOUNDATION_ENGINE_V1_1_NOTES.md) | Thai foundation engine V1.1 implementation notes | Devs | CURRENT (engine layer) | THAI_MIRROR_SPECIFICATION_V1, EXECUTIVE_SUMMARY |
| [`THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`](THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md) | V9 Life Timeline Intelligence (planet relationship engine + per-period/current/future intelligence, evidence only) | Devs, validation | CURRENT (engine layer) | EXECUTIVE_SUMMARY, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md) | V10 Prediction Intelligence Foundation (deterministic prediction substrate over V9; category × window evidence; no AI, no presenter). V10.5 (D-021) adds the consumer-report Future Prediction presentation surface | Devs, validation | CURRENT (engine + V10.5 presentation) | THAI_LIFE_TIMELINE_INTELLIGENCE_V9, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md) | V11 Decision Intelligence Foundation (deterministic per-scenario decision substrate over V10; verdict/confidence/reasons/evidence/timing/tradeoffs; no AI, no presenter) | Devs, validation | CURRENT (engine layer) | THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10, DECISION_LOG, PROJECT_FREEZE |

---

## 4. Thai Astrology documents

| Document | Purpose | Class | Notes |
|----------|---------|-------|-------|
| [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) | Authoritative current Thai architecture (and whole project) | CURRENT | Read this for Thai, not the V1 specs |
| [`ASTROLOGY_QA_HARNESS_V1.md`](ASTROLOGY_QA_HARNESS_V1.md) | QA harness for the consumer report | CURRENT | |
| [`THAI_FOUNDATION_ENGINE_V1_1_NOTES.md`](THAI_FOUNDATION_ENGINE_V1_1_NOTES.md) | Foundation engine V1.1 | CURRENT (engine) | |
| [`THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md`](THAI_LIFE_TIMELINE_INTELLIGENCE_V9.md) | V9 Life Timeline Intelligence engine + presentation | CURRENT (engine) | Additive on the frozen Thai engine; D-019 |
| [`THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md`](THAI_PREDICTION_INTELLIGENCE_FOUNDATION_V10.md) | V10 Prediction Intelligence Foundation (engine) + V10.5 consumer-report presentation | CURRENT (engine + presentation) | Additive reusable core over V9; V10.5 Future Prediction section; D-020, D-021 |
| [`THAI_DECISION_INTELLIGENCE_V11.md`](THAI_DECISION_INTELLIGENCE_V11.md) | V11 Decision Intelligence Foundation (engine) | CURRENT (engine) | Additive reusable core over V10; per-scenario decision guidance; D-022 |
| [`THAI_MIRROR_SPECIFICATION_V1.md`](THAI_MIRROR_SPECIFICATION_V1.md) | Original domain/contract spec | HISTORICAL | Engine contract still accurate; consumer IA evolved → EXECUTIVE_SUMMARY |
| [`THAI_MIRROR_UI_SPECIFICATION_V1.md`](THAI_MIRROR_UI_SPECIFICATION_V1.md) | Original analyst-style UI spec | SUPERSEDED | by consumer report → EXECUTIVE_SUMMARY |
| [`THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md`](THAI_ASTROLOGY_DOMAIN_VALIDATION_V1.md) | Pre-impl calculation-standards research | HISTORICAL | Standards later locked in V1.1 |
| [`THAI_GOLDEN_CASE_EXPANSION_V1.md`](THAI_GOLDEN_CASE_EXPANSION_V1.md) | Golden cases 5→20 sprint | HISTORICAL | Chart-validation record |
| [`THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md`](THAI_LUNAR_CALENDAR_INFRASTRUCTURE_V1.md) | Lunar lookup infrastructure | HISTORICAL | Infra record; coverage still limited |
| [`THAI_LUNAR_DATASET_ACQUISITION_V1.md`](THAI_LUNAR_DATASET_ACQUISITION_V1.md) | Plan to license/import lunar dataset | HISTORICAL (active plan) | License-blocked; still the plan of record |

---

## 5. Fusion / Mirror / Narrative pipeline documents

| Document | Purpose | Class | Notes |
|----------|---------|-------|-------|
| [`GF2_PRODUCTION_IMPLEMENTATION_V1.md`](GF2_PRODUCTION_IMPLEMENTATION_V1.md) | GF2 production wiring + validation | CURRENT | GF2 status of record |
| [`GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md`](GLOBAL_FUSION_FOUNDATION_V2_SPECIFICATION.md) | MV2+GF2 design spec | CURRENT (design, implemented) | |
| [`GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md`](GLOBAL_FUSION_FOUNDATION_VALIDATION_V2.md) | 200-human fusion dead-zone forensics | HISTORICAL | Explains *why* GF2 exists; metrics superseded by 1000-human runs |
| [`GF2_IMPLEMENTATION_READINESS_REPORT.md`](GF2_IMPLEMENTATION_READINESS_REPORT.md) | V2 gate scorecard (pre-ship) | SUPERSEDED | by GF2_FINAL_IMPLEMENTATION_DECISION → GF2_PRODUCTION_IMPLEMENTATION_V1 |
| [`GF2_V2_COLLAPSE_ANALYSIS.md`](GF2_V2_COLLAPSE_ANALYSIS.md) | Collapse-zone metric forensics | ARCHIVED | One-off; absorbed into VG-005 redefinition |
| [`GF2_FINAL_IMPLEMENTATION_DECISION.md`](GF2_FINAL_IMPLEMENTATION_DECISION.md) | V3 calibration "reject" decision | SUPERSEDED | by GF2_ROOT_CAUSE_ISOLATION_REPORT + GF2_PRODUCTION_IMPLEMENTATION_V1 |
| [`GF2_ROOT_CAUSE_ISOLATION_REPORT.md`](GF2_ROOT_CAUSE_ISOLATION_REPORT.md) | Re-attributes failure to Human Pattern layer | HISTORICAL | Pivotal investigation behind the HP fix |
| [`stable_orientation_trace_report.md`](stable_orientation_trace_report.md) | Task A pipeline trace (258 cohort) | ARCHIVED | Fragment of root-cause isolation |
| [`stable_orientation_layer_audit.md`](stable_orientation_layer_audit.md) | Task B per-layer pass/fail | ARCHIVED | Fragment of root-cause isolation |
| [`vg002_scope_audit.md`](vg002_scope_audit.md) | Task C VG-002 scope argument | ARCHIVED | Fragment of root-cause isolation |
| [`HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md`](HUMAN_PATTERN_ACTIVATION_AUDIT_V1.md) | 200-human dead-pattern baseline | HISTORICAL | Superseded at 1000-human scale by dead-zone forensics |
| [`HUMAN_PATTERN_DEAD_ZONE_FORENSICS_V1.md`](HUMAN_PATTERN_DEAD_ZONE_FORENSICS_V1.md) | 1000-human per-pattern taxonomy | HISTORICAL | Drove Recovery V2 |
| [`HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md`](HUMAN_PATTERN_ACTIVATION_RECOVERY_V2.md) | Shipped HP-engine fix record | HISTORICAL | Implementation record |
| [`NARRATIVE_INTELLIGENCE_SELECTION_V3.md`](NARRATIVE_INTELLIGENCE_SELECTION_V3.md) | Selection-scoring change (586→875) | HISTORICAL | Step in V3→V5 chain |
| [`NARRATIVE_PLAN_TOPOLOGY_V4.md`](NARRATIVE_PLAN_TOPOLOGY_V4.md) | Plan-topology branching (875→969) | HISTORICAL | Step in V3→V5 chain |
| [`NARRATIVE_PATTERN_COPY_EXPANSION_V1.md`](NARRATIVE_PATTERN_COPY_EXPANSION_V1.md) | Thai copy expansion for 30 patterns | HISTORICAL | Copy layer record |
| [`NARRATIVE_INTELLIGENCE_V2.md`](NARRATIVE_INTELLIGENCE_V2.md) | Thin auto-metrics for an early tweak | SUPERSEDED | by V3/V4/V5 |

---

## 6. Validation / measurement documents

| Document | Purpose | Class | Notes |
|----------|---------|-------|-------|
| [`SYNTHETIC_HUMAN_POPULATION_V1.md`](SYNTHETIC_HUMAN_POPULATION_V1.md) | 200-human validation baseline | HISTORICAL | Superseded by V2/V3 gates |
| [`SYNTHETIC_POPULATION_V2_1000_REPORT.md`](SYNTHETIC_POPULATION_V2_1000_REPORT.md) | 1000-human collapse report | HISTORICAL | Problem state before GF2 + Narrative fixes |
| [`REAL_USER_RUNTIME_VALIDATION_V1.md`](REAL_USER_RUNTIME_VALIDATION_V1.md) | 38-user Firestore funnel replay | HISTORICAL | Point-in-time; methodology current |
| [`PRODUCTION_FUNNEL_RECOVERY_V1.md`](PRODUCTION_FUNNEL_RECOVERY_V1.md) | Funnel-cliff strategy (MBTI mini) | HISTORICAL (strategy) | Strategy reference; June metrics |
| [`BAZI_MIRROR_INTEGRATION_V1.md`](BAZI_MIRROR_INTEGRATION_V1.md) | BaZi-into-astrology-mirror proof | HISTORICAL | Integration record |
| [`CHINESE_ZODIAC_IMPACT_VALIDATION_V1.md`](CHINESE_ZODIAC_IMPACT_VALIDATION_V1.md) | Year-animal impact A/B | HISTORICAL | Flags validation-bridge vs prod path |
| [`../test/validation/thai_mirror_consumer_ux/output/PRE_PRODUCTION_VALIDATION_REPORT.md`](../test/validation/thai_mirror_consumer_ux/output/PRE_PRODUCTION_VALIDATION_REPORT.md) | Pre-prod consumer UI gate (mid-June) | SUPERSEDED | by V7/V8 + QA harness |
| [`../test/validation/thai_mirror_consumer_ux/output/consumer_ux_validation_report.md`](../test/validation/thai_mirror_consumer_ux/output/consumer_ux_validation_report.md) | Early consumer-UX validation (A–J) | SUPERSEDED | by V7/V8 + QA harness |

---

## 7. Out-of-scope / non-managed files

| File | Why not managed here |
|------|----------------------|
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | Auto-generated iOS asset readme — not project documentation |
| `KNOWME MASTER CONTEXT vNEXT (FULL STRUCTURED v2).txt` | A future-direction brainstorm (`.txt`, not part of the canonical doc set). Treated as an idea backlog, not current-state documentation. Do not treat its "vNEXT" items as committed scope. |

---

## 8. Maintenance rules for this index

- Register every new doc here with purpose, audience, and classification.
- When a doc is superseded, set its class to SUPERSEDED here and add a banner to the
  doc naming its successor.
- Never delete historical docs — reclassify and banner them.
- Keep the required-reading list (§1) in sync with `AI_ALIGNMENT_CONTEXT.md` §1.

---

## Related documents

- [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) — classification taxonomy + reading order.
- [`EXECUTIVE_SUMMARY.md`](EXECUTIVE_SUMMARY.md) — project understanding.
- [`PROJECT_FREEZE.md`](PROJECT_FREEZE.md) — freeze registry.
