# PR115 Final Merge Manifest

Owner Product Acceptance is bound to implementation `6d4d4d1a4a03d2a97d8d1c11afd67baa05f4e48d`, accepted evidence/docs HEAD `44949815a08139b25b376d473b9495372197d17a`, Candidate 0023 SHA-256 `FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2`, and Owner Review ZIP SHA-256 `CE95A3A1757C269D356178D4232D58A282FFBD6C68309351D4877F335380B488`.

## Gate result

- Base: `origin/main` at `cd2718f6cfb6aff66ca46ebe6811e2a56379a8d7`
- Changed paths: **239**; unknown/unclassified: **0**
- Machine-local path payloads in final PR diff: **0**. Detector/redaction literals remain intentionally in three QA tools and are not path payloads.
- Tracked build/binary output, `product-acceptance/`, Firebase/deployment configuration, rejected-candidate production imports, fixture/minute overrides, Candidate 0011 active override, cross-mode leakage, secrets, unresolved tokens, and unsafe archive paths: **0**
- Candidate 0023 and Candidate 0011 historical oracle hashes: exact
- Node: 9/9; runtime/fixture/export: 26/26; narrative/export/infographic/artifact: 283/283; PDF title-only: 4/4; copy audit: 1/1; full Flutter: 1,646/1,646
- Runtime audit: 49/49 contexts, 392/392 periods, 300 profiles, Known 225/225, Unknown 75/75, claim bindings 2,925, unsupported claims 0
- Analyzer: baseline/current 298/298, new diagnostics in changed files 0
- `git diff --check`, PreCommit and PostCommit: PASS

## Classification summary

| Category | Paths |
|---|---:|
| production source | 13 |
| tests | 62 |
| Canon/contracts | 7 |
| evidence/tooling | 62 |
| status docs | 6 |
| historical evidence | 89 |

## Every changed path

### production source

- `M` `lib/features/astrology/thai/foundation/lunar/providers/thai_lunar_calendar_provider.dart` — PR115 runtime/application source.
- `M` `lib/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart` — PR115 runtime/application source.
- `M` `lib/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart` — PR115 runtime/application source.
- `M` `lib/features/birth_normalization/application/adapters/thai_birth_adapter.dart` — PR115 runtime/application source.
- `M` `lib/features/birth_normalization/application/birth_normalizer.dart` — PR115 runtime/application source.
- `M` `lib/features/birth_normalization/domain/birth_normalization_reason.dart` — PR115 runtime/application source.
- `A` `lib/features/thai_beta/application/narrative/predictive_runtime_v2_catalog.g.dart` — PR115 runtime/application source.
- `A` `lib/features/thai_beta/application/narrative/predictive_runtime_v2.dart` — PR115 runtime/application source.
- `M` `lib/features/thai_beta/application/narrative/thai_beta_clause_repetition_audit.dart` — PR115 runtime/application source.
- `M` `lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart` — PR115 runtime/application source.
- `M` `lib/features/thai_beta/application/thai_beta_report_export_document.dart` — PR115 runtime/application source.
- `M` `lib/features/thai_beta/application/thai_beta_report_pdf_exporter.dart` — PR115 runtime/application source.
- `M` `lib/features/thai_beta/presentation/widgets/thai_beta_shared_report_view.dart` — PR115 runtime/application source.

### tests

- `A` `test/evidence/fixtures/or5r_known_baseline.json` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or4_content.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or4_generation.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or5r_actual_authority_v2.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or5r_sentinel_runtime_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or5r_unknown_contract.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or5r_unknown_contract_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/or5r_unknown_projection.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/pr115_or10r_predictive_signature.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/pr115_or6_content_candidate.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/pr115_or7_content_candidate.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/pr115_or8_content_candidate.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/pr115_or9_content_candidate.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/predictive_content_truth_or3.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/predictive_editorial_candidate_0019.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/predictive_runtime_v2_foundation.test.mjs` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/predictive_runtime_v2_or1_evidence_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/evidence/predictive_runtime_v2_or5_actual_input_export_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/thai_foundation_engine_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/core_reading/thai_beta_readability_acceptance_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/core_reading/thai_birth_profile_core_reading_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/thai_life_map_v123_report_acceptance_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v124/thai_life_map_v124_accuracy_audit_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v124/thai_life_map_v124_audit_runner.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v126/thai_life_map_v126_time_bucket_ux_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v135/thai_life_map_v135_evidence_detail_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v135/thai_life_map_v135_product_qa_artifact_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/life_map/v135/thai_life_map_v135_ui_primary_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_copy_normalization_scope_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_copy_semantic_safety_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_cross_runtime_300_vm_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_cross_runtime_manifest.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_date_aware_contract_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/live_asof/thai_beta_live_oracle_parity_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_input_fixture_separation_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v111_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v11_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_claim_planning_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_r3_report_composer_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_r4_acceptance_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_r5_acceptance_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_r6_reader_quality_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_narrative_v15_r7_reader_quality_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_report_v121_acceptance_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_beta_report_v122_editorial_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/narrative/thai_consumer_narrative_voice_v1_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/validation/thai_beta/narrative/thai_predictive_runtime_v2_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `A` `test/validation/thai_beta/thai_beta_pdf_title_only_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/thai_beta_report_export_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/thai_report_copy_candidate_300_audit_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/thai_report_experience_infographic_vnext_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai_beta/thai_report_vnext_artifact_generation_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_archetype_context_metadata_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_engine_life_period_rise_fall_metadata_completion_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_engine_life_period_rise_fall_metadata_rerun_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_engine_life_period_rise_fall_metadata_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_internal_evidence_qa_pass_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_life_period_position_metadata_completion_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_life_period_position_metadata_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_life_period_position_strategy_correction_test.dart` — Regression, fixture, canonical, export, or evidence test.
- `M` `test/validation/thai/thai_period_context_normalization_test.dart` — Regression, fixture, canonical, export, or evidence test.

### Canon/contracts

- `A` `docs/PREDICTIVE_EDITORIAL_COMPONENT_LIBRARY_V2.json` — Runtime contract, generated rule mapping, or task contract.
- `A` `docs/PREDICTIVE_EDITORIAL_COMPONENT_LIBRARY_V2.md` — Runtime contract, generated rule mapping, or task contract.
- `A` `docs/PREDICTIVE_RUNTIME_V2_392_PERIOD_RUNTIME_MAPPING.json` — Runtime contract, generated rule mapping, or task contract.
- `A` `docs/PREDICTIVE_RUNTIME_V2_49_CONTEXT_READER_COPY.json` — Runtime contract, generated rule mapping, or task contract.
- `A` `docs/PREDICTIVE_RUNTIME_V2_CLAIM_LEVEL_BINDINGS.json` — Runtime contract, generated rule mapping, or task contract.
- `A` `docs/PREDICTIVE_SIGNATURE_OUTPUT_CONTRACT_V1.md` — Runtime contract, generated rule mapping, or task contract.
- `M` `task_scope.json` — Runtime contract, generated rule mapping, or task contract.

### evidence/tooling

- `A` `docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_CLAIM_MAP.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_CLAIM_MAP.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_CONTENT_AUDIT.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_CONTENT_AUDIT.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_FINAL_MERGE_MANIFEST.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_FINAL_MERGE_MANIFEST.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10_CONTRACT_CONFLICT_TRUTH_CORRECTION.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10_CONTRACT_CONFLICT_TRUTH_CORRECTION.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10R_R1_BEFORE_EVIDENCE.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10R_R1_OWNER_REVIEW.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10R_R1_VALIDATION.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10R_R1_VISUAL_REVIEW.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR10R_VALIDATION.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_OR9_VALIDATION.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_PATH_SANITIZATION_LEDGER.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PR115_PATH_SANITIZATION_LEDGER.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_CONTENT_QUALITY_AUDIT.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_GOLDEN_NEIGHBOR_COMPARISON.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_HUMAN_REVIEW_49_CONTEXTS.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_OR2_TRUTH_CORRECTION.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_OR2_TRUTH_CORRECTION.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_OR3_SEMANTIC_FEASIBILITY.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_OR3_SEMANTIC_FEASIBILITY.md` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_OWNER_REUSE_AUDIT.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `docs/PREDICTIVE_RUNTIME_V2_RAW_300_PROFILE_AUDIT.json` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/build_or4_candidate.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/build_or4_truth.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/build_predictive_content_truth_or3.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/build_predictive_editorial_candidate_0019.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/build_predictive_runtime_v2_audit.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/generate_predictive_runtime_v2_catalog.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or4_content_validator.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or4_negative_controls.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or4_reader_generator.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_actual_authority_v2.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_actual_pdf_gate.py` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_artifact_app.dart` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_authority_matrix.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_capture.cjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_migration_evidence.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_neutral_evidence.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_neutral_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_package.py` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/or5r_validation_evidence.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/package_or4.py` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or10r_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or6_content_candidate.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or6_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or7_content_candidate.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or7_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or8_content_candidate.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or8_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or9_content_candidate.mjs` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `A` `tool/pr115_or9_validation.ps1` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.
- `M` `tool/thai_report_vnext_cross_runtime_manifest.dart` — Accepted evidence, validation output, audit, ledger, manifest, or generation/QA tooling.

### status docs

- `M` `docs/CURRENT_STATUS.md` — Required current status and handoff record.
- `M` `docs/HANDOFF.md` — Required current status and handoff record.
- `M` `docs/ROADMAP.md` — Required current status and handoff record.
- `M` `docs/THAI_REPORT_READER_EXPERIENCE_V2.md` — Required current status and handoff record.
- `M` `task.md` — Required current status and handoff record.
- `M` `TASK_RESULT.md` — Required current status and handoff record.

### historical evidence

- `A` `docs/ACTUAL_0035_AUTHORITY_MATRIX_V2.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_AUTHORITY_MATRIX_V2.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_CONTENT_REVIEW.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_CONTENT_REVIEW.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_EMITTED_PREDICTIONS.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_EMITTED_PREDICTIONS.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_FULL_READER_COPY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_PAST_PERIOD_EQUIVALENCE.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_PAST_PERIOD_EQUIVALENCE.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_SEMANTIC_SLOT_COVERAGE.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/ACTUAL_0035_SEMANTIC_SLOT_COVERAGE.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_49_CONTEXT_SIMULATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_ACTUAL_0035.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_CONTENT_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_CONTENT_AUDIT.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_GOLDEN_0003_REFERENCE.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_REPRESENTATIVE_12.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0019_REPRESENTATIVE_12.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_ACTUAL_0035_FULL_READER_COPY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_ACTUAL_0035.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_ACTUAL_0035.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_BEFORE_AFTER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CLAIM_MAP.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CLAIM_MAP.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CONTENT_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CONTENT_AUDIT.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CONTENT_TRUTH_CORRECTION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_CONTENT_TRUTH_CORRECTION.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0020_TO_0021_BEFORE_AFTER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_ACTUAL_0035_FULL_READER_COPY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_CLAIM_MAP.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_CLAIM_MAP.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_CONTENT_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_CONTENT_AUDIT.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_OWNER_REVIEW.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_OWNER_REVIEW.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_SEMANTIC_OWNERSHIP.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0021_TO_0022_BEFORE_AFTER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_ACTUAL_0035_FULL_READER_COPY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_CLAIM_MAP.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_CLAIM_MAP.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_CONTENT_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_CONTENT_AUDIT.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_EXACT_COPY_EVIDENCE.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_OWNER_REVIEW.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_SEMANTIC_OWNERSHIP.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/CANDIDATE_0022_TO_0023_BEFORE_AFTER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_49_CONTEXT_SIMULATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_AGE_BINDING_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_CLOSEOUT.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_COMPONENT_LIBRARY.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_COMPONENT_LIBRARY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_CONTENT_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_DOMAIN_LANGUAGE_AUDIT.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_GENERATION_TRACE.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_GOLDEN_COMPARISON.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_NEGATIVE_CONTROLS.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_REPRESENTATIVE_FULL_COPY.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_REPRESENTATIVE_FULL_COPY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_SEMANTIC_FEASIBILITY.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_SEMANTIC_FEASIBILITY.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_TRUTH_CORRECTION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR4_TRUTH_CORRECTION.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_ACTUAL_0035_AUTHORITY_MATRIX.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_ASSERTION_MIGRATION_LEDGER.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_ASSERTION_MIGRATION.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_AUTHORITY_GATE_TRUTH_CORRECTION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_AUTHORITY_GATE_TRUTH_CORRECTION.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_FAILURE_CLASSIFICATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_FAILURE_RESOLUTION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_FULL_SUITE_FIRST_RUN_FAILURES.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_FULL_SUITE_GATE_FAILURES.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_NEUTRAL_V2_VALIDATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_OWNER_PACKAGE_VERIFICATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_PDF_REPAIR.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_PDF_REPAIR_VALIDATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_POST_GATE_PARITY_BLOCKER.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_POST_GATE_PARITY_BLOCKER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5R_RUNTIME_REPAIR_STATUS.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/OR5_SENTINEL_CONTAINMENT_BLOCKER.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/PR115_OR6_OWNER_CONTENT_DECISION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/PR115_OR6_OWNER_CONTENT_DECISION.md` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/PR115_OR6_VALIDATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/PR115_OR7_VALIDATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.
- `A` `docs/PR115_OR8_VALIDATION.json` — Retained rejected/diagnostic evidence; not imported by production runtime.

The detailed machine-readable record is `docs/PR115_FINAL_MERGE_MANIFEST.json`. This closeout does not merge or deploy PR #115.
