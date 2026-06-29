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
| [`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md) | V12 Question Reasoning Foundation (deterministic structured-intent → decision-query resolver over V11; resolved scenario, relevant windows/evidence, priority reasons, structured answer, confidence; no AI, no LLM, no parser, no presenter) | Devs, validation | CURRENT (engine layer) | THAI_DECISION_INTELLIGENCE_V11, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) | V13 Unified Reasoning Runtime (single orchestration entry point over V9–V12; `evaluate`/`predict`/`decide`/`question`/`answer` → unified snapshots + flattened evidence + trace + confidence; the only public reasoning entry point; no AI, no presenter, no LLM) | Devs, validation | CURRENT (orchestration layer) | THAI_QUESTION_REASONING_FOUNDATION_V12, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_SCENARIO_SIMULATION_V14.md`](THAI_SCENARIO_SIMULATION_V14.md) | V14 Scenario Simulation Foundation (deterministic hypothetical decision-path evaluation over the V13 runtime; Act now/Best window/Alternative window/Do nothing → expected/opportunity/risk/tradeoffs/timing/confidence/evidence + ranked comparison; consumes the runtime only; no AI, no presenter, no parser) | Devs, validation | CURRENT (simulation layer) | THAI_REASONING_RUNTIME_V13, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_TRANSIT_INTEGRATION_V15.md`](THAI_TRANSIT_INTEGRATION_V15.md) | V15 Transit Intelligence Integration (day-of-week-ruler transit assessed vs natal + current period via the shared V9 relationship engine, merged through an Enhanced Runtime wrapper; enhancement layer, transit contributes evidence only; runtime untouched; no AI, no presenter) | Devs, validation | CURRENT (enhancement layer) | THAI_REASONING_RUNTIME_V13, DECISION_LOG, PROJECT_FREEZE |
| [`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md) | V16 Mirror Conversation Experience Foundation (deterministic guided conversation over the V13 runtime; 8 topics, predefined question catalog → runtime → structured answer → suggested follow-ups; consumes the runtime only; no AI, no LLM, no chat model, no parser, no free text) | Devs, validation | CURRENT (experience foundation) | THAI_REASONING_RUNTIME_V13, THAI_QUESTION_REASONING_FOUNDATION_V12, DECISION_LOG, PROJECT_FREEZE |
| [`GLOBAL_REASONING_RUNTIME_V17.md`](GLOBAL_REASONING_RUNTIME_V17.md) | V17 Global Reasoning Runtime Foundation (system-agnostic provider/dispatch runtime generalizing the V13 Thai runtime — now the reference implementation; provider discovery, capability detection, evidence aggregation; only `ThaiRuntimeAdapter` implemented; no hard-coded Thai dependency; Mirror Conversation consumes it) | Devs, validation | CURRENT (cross-system foundation) | THAI_REASONING_RUNTIME_V13, THAI_MIRROR_CONVERSATION_V16, ARCHITECTURE, DECISION_LOG, PROJECT_FREEZE |
| [`GLOBAL_FUSION_RUNTIME_P2.md`](GLOBAL_FUSION_RUNTIME_P2.md) | P2 Cross-System Fusion Runtime (fusion layer above the Global Runtime; fans a capability across providers and detects agreement/conflict/missing-evidence/priority + merged evidence + fused confidence into one `FusionResult`; single-provider mode for Thai-only; Conversation consumes it) | Devs, validation | CURRENT (cross-system fusion) | GLOBAL_REASONING_RUNTIME_V17, THAI_MIRROR_CONVERSATION_V16, ARCHITECTURE, DECISION_LOG, PROJECT_FREEZE |
| [`BIRTH_NORMALIZATION.md`](BIRTH_NORMALIZATION.md) | Birth Normalization Foundation — the single birth-input layer before every astrology engine (`RawBirthInput` → `BirthNormalizer` → `NormalizedBirth`: Thai/Western/BaZi-placeholder contexts; deterministic location-/season-/timezone-aware sunrise day boundary superseding hardcoded 06:00; traceable reasons; architecture only, engine migration is follow-up) | Devs | CURRENT (foundation) | ARCHITECTURE, DOMAIN_MODEL, DECISION_LOG, THAI_FOUNDATION_ENGINE_V1_1_NOTES |
| [`THAI_KNOWLEDGE_FOUNDATION_V1.md`](THAI_KNOWLEDGE_FOUNDATION_V1.md) | Thai Astrology Knowledge Foundation V1 — traceable read-only evidence layer over the frozen engine rules (`lib/features/astrology/thai/knowledge/`); V1 = Planet Relationship only (one record per directed inter-planet pair with source/confidence/verified/notes + coverage report; values mirror the frozen `PlanetRelationshipMatrix`, no drift; all `Unknown`/`verified=false` today); no engine change, no deploy | Devs | CURRENT (knowledge foundation; records now data-driven — see Importer V2) | DOMAIN_MODEL, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_KNOWLEDGE_IMPORTER_V2.md`](THAI_KNOWLEDGE_IMPORTER_V2.md) | Thai Astrology Knowledge Importer V2 — knowledge moved out of code into JSON (`knowledge/planet_relationships/`: schema + canonical 56-record data + template; Flutter asset); `PlanetRelationshipKnowledgeImporter` validates (schema/missing/unknown-enum/duplicate/broken-ref/matrix-consistency/coverage) and loads into a data-driven `PlanetRelationshipKnowledge` (no hardcoded records) + Knowledge Import Report; records add `status` + source author/edition/publisher/year/quote; no invented references, no engine change, no deploy | Devs | CURRENT (knowledge importer) | THAI_KNOWLEDGE_FOUNDATION_V1, DOMAIN_MODEL, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_KNOWLEDGE_RESEARCH_V3.md`](THAI_KNOWLEDGE_RESEARCH_V3.md) | Thai Astrology Knowledge Research Infrastructure V3 — primary-source research layer (`knowledge/research/`: schema + template; `lib/.../knowledge/research/`) for documenting interpretations that support planet relationships; `KnowledgeResearchEngine` (load/findSupportingEvidence/findConflicts/coverage) + Research Coverage Report; one record may support multiple relationships; status draft→…→verified/disputed/rejected; **engine- and matrix-independent** (plain strings, decoupling enforced by test); evidence-linked in V4; no engine change, no deploy | Devs, research | CURRENT (knowledge research) | THAI_KNOWLEDGE_EVIDENCE_LINKING_V4, THAI_KNOWLEDGE_IMPORTER_V2, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md`](THAI_KNOWLEDGE_EVIDENCE_LINKING_V4.md) | Thai Astrology Knowledge Evidence Linking V4 — `EvidenceRecord` (citable source; review draft→reviewed→verified→disputed→deprecated) in `knowledge/evidence/`; research records reference evidence via `evidenceIds[]` (many-to-many) instead of embedding source fields; `KnowledgeEvidenceEngine` (loadEvidence/findEvidence/findResearch/findRelationships/findOrphans/coverage/validate) audits duplicate/broken-link/missing/unused/circular + Evidence Coverage Report; knowledge-only (no engine/matrix/runtime/prediction); no deploy | Devs, research | CURRENT (knowledge evidence) | THAI_KNOWLEDGE_RESEARCH_V3, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_KNOWLEDGE_WORKSPACE_V5.md`](THAI_KNOWLEDGE_WORKSPACE_V5.md) | Thai Astrology Research Workspace V5 — read-only admin workspace at `/internal/knowledge` (`lib/features/knowledge_workspace/`) over the V1–V4 knowledge layer; browse evidence/research/relationships, filter (school/author/book/relationship/status/planet), coverage + per-relationship detail (current matrix · research · evidence · conflicts); no editing; no runtime/prediction dependency; deployed admin-only | Admins, research | CURRENT (internal tool) | THAI_KNOWLEDGE_EVIDENCE_LINKING_V4, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_KNOWLEDGE_ACQUISITION_V6.md`](THAI_KNOWLEDGE_ACQUISITION_V6.md) | Thai Astrology Knowledge Acquisition V6 — JSON-only acquisition workbench at `/internal/knowledge/acquire` (`lib/features/knowledge_workspace/acquisition/`) to populate the platform gradually; `knowledge/acquisition/` schema+template; `KnowledgeAcquisitionEngine`/`Session` validate→preview→apply→rollback batches (evidence[]+research[]) with classification (imported/updated/skipped/error) + conflict detection + Import Report; `toAssetJson()` export to commit back; **never modifies PlanetRelationshipMatrix**; no runtime/prediction dependency; no deploy | Admins, research | CURRENT (internal tool) | THAI_KNOWLEDGE_WORKSPACE_V5, THAI_KNOWLEDGE_EVIDENCE_LINKING_V4, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_SOURCE_COLLECTION_V7.md`](THAI_SOURCE_COLLECTION_V7.md) | Thai Astrology Source Collection V7 — collect real sources, one JSON per source in `knowledge/sources/` (`lib/features/astrology/thai/knowledge/sources/`); each source carries cited assertions (from→to→relation→page→quote, quote always kept); `KnowledgeSourceEngine` validate (duplicate/conflicting/missing-page/missing-quote/broken-reference/duplicate-source) + Source Coverage Report (books/schools/authors/assertions/covered/missing); knowledge only, no engine/matrix dependency; no deploy | Devs, research | CURRENT (knowledge sources) | THAI_CONSENSUS_ENGINE_V8, THAI_MATRIX_REVIEW_V9, ARCHITECTURE, ROADMAP, DECISION_LOG |
| [`THAI_CONSENSUS_ENGINE_V8.md`](THAI_CONSENSUS_ENGINE_V8.md) | Thai Astrology Consensus Engine V8 — `KnowledgeConsensusEngine` (`lib/features/astrology/thai/knowledge/consensus/`) counts friend/enemy/neutral votes per directed relationship across V7 sources; classifies consensus/majority/split/disputed/uncovered; confidence from source count (downgraded for split/disputed) + Consensus Report; never reads/modifies the matrix; no deploy | Devs, research | CURRENT (consensus) | THAI_SOURCE_COLLECTION_V7, THAI_MATRIX_REVIEW_V9, DECISION_LOG |
| [`THAI_MATRIX_REVIEW_V9.md`](THAI_MATRIX_REVIEW_V9.md) | Thai Astrology Matrix Review V9 — `MatrixReviewEngine` (`lib/features/astrology/thai/knowledge/review/`) reviews the frozen matrix (read via V2 mirror) vs consensus + user research; per relationship current matrix/consensus/supporting/conflicting sources/user research/recommendation Keep-Review-Replace + rationale; engine-impact estimate (timeline/prediction/decision/compatibility/conversation); **proposal only, no code/engine change**; baseline 56 Keep; no deploy | Devs, research, decision-makers | CURRENT (matrix review proposal) | THAI_CONSENSUS_ENGINE_V8, THAI_SOURCE_COLLECTION_V7, DECISION_LOG |
| [`THAI_ASTROLOGY_CANON_V1.md`](THAI_ASTROLOGY_CANON_V1.md) | Thai Astrology Canon V1 — Canonical Knowledge Architecture (`lib/features/astrology/thai/knowledge/canon/`): `KnowledgeTier` Source Priority ladder (Tier0 engine→Tier1 Canon `หลักมหาภูต`→Tier2 Thai classical→Tier3 research→Tier4 internet); `CanonicalKnowledgeNode` (Source/Tier/Canonical/Confidence/Evidence/References/Conditions/Exceptions; authority derived from source registry); `CanonConflictResolver` = **Canon always wins** (supporting adds detail/overruled; canon-vs-canon → human review; no-canon → provisional); `CanonKnowledgeEngine` load/validate/resolve/coverage; `CanonBookManifest` + `knowledge/canon/` data (schema/template/sources/book skeleton) = architecture to extract `หลักมหาภูต` later (not extracted); engine/matrix frozen; no fabricated knowledge; no deploy | Devs, research, decision-makers | CURRENT (canonical knowledge) | THAI_ASTROLOGY_CANON_AUDIT_V1, THAI_MATRIX_REVIEW_V9, THAI_SOURCE_COLLECTION_V7, ARCHITECTURE, DECISION_LOG |
| [`THAI_ASTROLOGY_CANON_AUDIT_V1.md`](THAI_ASTROLOGY_CANON_AUDIT_V1.md) | Thai Astrology Canon Audit V1 — read-only audit of all Thai-astrology docs + knowledge data (rules/concepts/formulas/meanings/interpretations/exceptions/conflicts); where each lives, existing authority signals, documented conflicts, and mapping into the Canon layer; companion to THAI_ASTROLOGY_CANON_V1 | Devs, research | CURRENT (audit) | THAI_ASTROLOGY_CANON_V1, DECISION_LOG |
| [`THAI_MAHABHUT_CANON_EXTRACTION_V1.md`](THAI_MAHABHUT_CANON_EXTRACTION_V1.md) | Thai Astrology Mahabhut Canon Extraction V1 — multi-book Canon Database (`lib/features/astrology/thai/knowledge/canon/database/`): entities Book→Chapter→Section→Topic→`CanonKnowledgeUnit` (concept/rule/formula/interpretation/meaning/example/exception/condition) + Evidence/CrossReference/SourceReference/Location; `CanonLibraryManifest` multi-book registry (extraction/validation state, version, progress); auditable extraction pipeline (Book→…→Knowledge Index→Reasoning Engine, error-gated); `CanonDatabase.trace` traceability (book/chapter/section/topic/page/citation); cross-reference system; validation layer (draft→extracted→reviewed→validated→canonApproved); read-only `CanonKnowledgeIndex` reasoning seam; V1 bridge `toCanonNodes`; structure only (no extraction); engine/matrix frozen; no deploy | Devs, research | CURRENT (canon database) | THAI_ASTROLOGY_CANON_V1, THAI_ASTROLOGY_CANON_AUDIT_V1, ARCHITECTURE, DECISION_LOG |
| [`THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1.md`](THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1.md) | Thai Astrology Mahabhut Ingestion Toolchain V1 — pure-Dart toolchain (`lib/features/astrology/thai/knowledge/canon/ingestion/`) + CLI `tool/canon_ingest.dart` to bring book text into the Canon Database: import pipeline (OCR/plain/Markdown/TXT, no PDF) → extraction engine (verbatim Candidate units, no interpretation, never auto-approved) → candidate layer → validation engine (required/duplicate/broken-ref/missing-citation/missing-page/invalid-xref/empty-rule/empty-concept) → approval workflow (candidate→validated→reviewed→canonApproved) + `promote()`→`CanonDatabasePatch` → diff engine + QA tools + extraction metrics; restructures provided text only (no fabricated knowledge); engine frozen; no deploy | Devs, research | CURRENT (canon ingestion tooling) | THAI_MAHABHUT_CANON_EXTRACTION_V1, THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK, ARCHITECTURE, DECISION_LOG |
| [`THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md`](THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK.md) | Thai Astrology Mahabhut Canon Extraction V2 (Runbook) — book-ingestion intake + per-chapter extraction protocol; field-by-field book→`CanonKnowledgeUnit` mapping, validation gates, reasoning readiness; blocked on source text (drop verbatim text in `knowledge/canon/sources/mahabhut/`) | Devs, research | CURRENT (runbook, blocked on source) | THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1, THAI_MAHABHUT_CANON_EXTRACTION_V1, DECISION_LOG |
| [`THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md`](THAI_MAHABHUT_CONTENT_ENGINEERING_V1.md) | Thai Astrology Mahabhut Content Engineering V1 — human-review layer over the ingestion toolchain: Reviewer Workspace (`lib/features/knowledge_workspace/canon_review/`, route `/internal/knowledge/canon-review`, admin-guarded) showing source text + candidate + citation + cross references + validation errors with Coverage/Consistency tabs + per-unit checklist; Review Assistant highlights + `CanonReviewChecklist`; Coverage Analysis; Consistency Checker; read-only aids that compose existing engines (no parallel checker); no fabricated knowledge; engine frozen; no deploy | Devs, research | CURRENT (canon reviewer tooling) | THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1, THAI_MAHABHUT_CANON_STYLE_GUIDE, THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST, DECISION_LOG |
| [`THAI_MAHABHUT_CANON_STYLE_GUIDE.md`](THAI_MAHABHUT_CANON_STYLE_GUIDE.md) | Thai Astrology Canon Style Guide (Mahabhut) — extraction standards: ID/Concept/Rule/Formula naming; writing Meaning/Interpretation/Exception/Cross Reference; conditions/examples/notes; confidence; verbatim-in/structure-only | Devs, research | CURRENT (standard) | THAI_MAHABHUT_CONTENT_ENGINEERING_V1, THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST |
| [`THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md`](THAI_MAHABHUT_CONTENT_REVIEW_CHECKLIST.md) | Thai Astrology Content Review Checklist (Mahabhut) — per-unit + per-chapter checklist (verbatim, citation, page, no added interpretation, metadata, cross refs, consistency) gating reviewed→canonApproved; auto vs manual items mirror `CanonReviewChecklist` | Devs, research | CURRENT (standard) | THAI_MAHABHUT_CONTENT_ENGINEERING_V1, THAI_MAHABHUT_CANON_STYLE_GUIDE |
| [`THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md`](THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1.md) | Thai Astrology Canon Platform Freeze V1 — declares the Canon Platform **FROZEN / Production Ready**; audit result (build-break fix + duplicate-helper consolidation into `canon_json.dart`; verified no circular deps / layer leakage; complementary not duplicate manifests; consistent data/schema namespacing); frozen platform map; future work is Content Engineering only (no new layers/schemas/workflows/architecture); + D-057 reference-only provenance addendum | Devs, research, leads | FROZEN (platform) | DECISION_LOG, ARCHITECTURE, THAI_MAHABHUT_INGESTION_TOOLCHAIN_V1, THAI_MAHABHUT_CONTENT_ENGINEERING_V1 |
| [`THAI_CANON_ATOMIC_KNOWLEDGE_V2.md`](THAI_CANON_ATOMIC_KNOWLEDGE_V2.md) | KnowMe Canon Platform — Atomic Knowledge Foundation V2 — Statement→**Atomic Knowledge** model; `canon/atomic/`: `AtomicKnowledgeUnit` (one fact subject→relation→object + condition/effect/strength/confidence + reference evidence), relation/entity/`KnowledgeDomain` vocabulary, `AtomicExtractionRules` (one fact/meaning/rule; reject paragraphs/summaries/narrative/interpretation/prediction), `AtomicKnowledgeGraph` (entities=nodes, relations=first-class edges, validate + queries), deterministic `CanonCompletenessReport` (domain-based coverage + evidence/verified/unknown metrics); pure Dart, no engine/runtime/UI/deploy | Devs, research | CURRENT (atomic knowledge) | DECISION_LOG, ARCHITECTURE, THAI_MAHABHUT_CANON_PLATFORM_FREEZE_V1, THAI_MAHABHUT_CANON_STYLE_GUIDE |
| [`THAI_CANON_ONTOLOGY_V3.md`](THAI_CANON_ONTOLOGY_V3.md) | KnowMe Canon Platform — Ontology Foundation V3 — **Canonical Ontology Layer** (mandatory controlled vocabulary); `canon/ontology/`: `CanonicalEntity` (stable id `<category>.<slug>`, canonicalName, category, aliases, structured description, taxonomy `parentId`, status), `CanonicalOntology` (deterministic multilingual alias resolution — unknown/ambiguous unresolved, relationship registry = superset of V2 `AtomicRelation`, domain taxonomy queries), deterministic `OntologyValidationReport` (dup ids/alias collisions/unregistered rel/category mismatch/orphans/cycles), seeded `CanonOntologyData.standard` (9 grahas, 4 elements, life domains, relationship entities — vocabulary only); no package may invent entity/relationship names; pure Dart, no engine/runtime/UI/deploy | Devs, research | CURRENT (ontology) | DECISION_LOG, ARCHITECTURE, THAI_CANON_ATOMIC_KNOWLEDGE_V2, THAI_MAHABHUT_CANON_STYLE_GUIDE |
| [`THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md`](THAI_CANON_KNOWLEDGE_EXTRACTION_WORKSPACE_V4.md) | KnowMe Canon Platform — Knowledge Extraction Workspace V4 — **only supported Canon ingestion path**; `canon/workspace/`: `KnowledgeExtractionSession` (deterministic lifecycle Draft→Extracting→Validated→Reviewed→Approved→Imported→Archived; nothing enters Canon directly), `ExtractionSource` (provenance-only: book/edition/chapter/page range/reviewer/date/progress), `WorkspaceValidator` (deterministic; catches atomicity/ontology/relationship/evidence/duplicate/graph+baseline conflict/coverage), `KnowledgeDiff` (NEW/UPDATED/UNCHANGED/CONFLICT/DEPRECATED — never overwrite blindly), `CompletenessDelta` (before/after `CanonCompletenessReport`; conflicts not applied), `ReviewReport` (deterministic structured non-narrative gate `readyForImport`); consumes atomic+ontology read-only, no engine depends on it; pure Dart, no engine/runtime/UI/deploy | Devs, research, reviewers | CURRENT (workspace) | DECISION_LOG, ARCHITECTURE, THAI_CANON_ONTOLOGY_V3, THAI_CANON_ATOMIC_KNOWLEDGE_V2, THAI_MAHABHUT_CANON_EXTRACTION_V2_RUNBOOK |

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
| [`THAI_QUESTION_REASONING_FOUNDATION_V12.md`](THAI_QUESTION_REASONING_FOUNDATION_V12.md) | V12 Question Reasoning Foundation (engine) | CURRENT (engine) | Additive reusable core over V11; structured-intent → decision-query resolver; D-023 |
| [`THAI_REASONING_RUNTIME_V13.md`](THAI_REASONING_RUNTIME_V13.md) | V13 Unified Reasoning Runtime (orchestration) | CURRENT (orchestration) | Additive reusable orchestration over V9–V12; the only public reasoning entry point; D-024 |
| [`THAI_SCENARIO_SIMULATION_V14.md`](THAI_SCENARIO_SIMULATION_V14.md) | V14 Scenario Simulation Foundation (simulation) | CURRENT (simulation) | Additive reusable engine over the V13 runtime; hypothetical decision-path evaluation; D-025 |
| [`THAI_TRANSIT_INTEGRATION_V15.md`](THAI_TRANSIT_INTEGRATION_V15.md) | V15 Transit Intelligence Integration (enhancement) | CURRENT (enhancement) | Additive enhancement layer over the V13 runtime; day-ruler transit as merged evidence; Enhanced Runtime wrapper; D-026 |
| [`THAI_MIRROR_CONVERSATION_V16.md`](THAI_MIRROR_CONVERSATION_V16.md) | V16 Mirror Conversation Experience Foundation (experience) | CURRENT (experience) | Additive deterministic guided conversation over the V13 runtime; predefined question catalog → runtime → answer → suggestions; D-027 |
| [`GLOBAL_REASONING_RUNTIME_V17.md`](GLOBAL_REASONING_RUNTIME_V17.md) | V17 Global Reasoning Runtime Foundation (cross-system) | CURRENT (cross-system) | Additive system-agnostic provider/dispatch runtime; generalizes the V13 Thai reference runtime; only ThaiRuntimeAdapter; D-028 |
| [`GLOBAL_FUSION_RUNTIME_P2.md`](GLOBAL_FUSION_RUNTIME_P2.md) | P2 Cross-System Fusion Runtime (fusion) | CURRENT (fusion) | Additive fusion layer above the Global Runtime; agreement/conflict/missing/priority + merged evidence + fused confidence; single-provider mode; D-029 |
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
