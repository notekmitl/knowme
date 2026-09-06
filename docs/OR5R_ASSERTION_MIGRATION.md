# OR5R assertion migration ledger

This is a contract migration review index, not Owner Product Acceptance. Full Before/After assertions, source hashes, line references and diffs are in OR5R_ASSERTION_MIGRATION_LEDGER.json. No text is truncated.

Original failures: 76. Individually classified A=68, B=7, C=0, D=0, E=1. Migrated A/E test files: 34.
The six B-only files are not migrated. Their valid assertions pass after restoring Unknown metadata/omission-banner behavior; chapter-kind metadata is repaired at the export boundary.
Additional validator defect encountered while enabling the R7 prose audit: empty phase/motif counted every character boundary. Empty labels now count zero; real fourfold phase repetition, C0 text and rejected prose remain rejected by negative controls.
V124 corrected enumeration: 22 fixtures = 19 Known + 3 Unknown (F09/F18/F20); 152 generated Known periods + 24 historical synthetic Unknown periods explicitly omitted. The initial 20/one rationale was corrected, not silently retained.
PDF legacy test fixtures: Known 6 pages unchanged; Unknown measured 1 page with pdfinfo, rasterized and visually opened for both actual fixtures before changing expected page count. Printable-margin/body-ink gates retained.

| Test file | Failure IDs | Before / After lexical calls | Exact retained | Test declarations |
|---|---|---:|---:|---:|
| test/thai_foundation_engine_test.dart | F075, F076 | 44 / 46 | 39 | 21 / 21 |
| test/validation/thai/thai_archetype_context_metadata_test.dart | F062 | 24 / 25 | 19 | 10 / 10 |
| test/validation/thai/thai_engine_life_period_rise_fall_metadata_completion_test.dart | F063 | 31 / 35 | 28 | 12 / 12 |
| test/validation/thai/thai_engine_life_period_rise_fall_metadata_rerun_test.dart | F064, F065, F066 | 29 / 36 | 25 | 11 / 11 |
| test/validation/thai/thai_engine_life_period_rise_fall_metadata_test.dart | F067, F068 | 29 / 31 | 23 | 13 / 13 |
| test/validation/thai/thai_internal_evidence_qa_pass_test.dart | F069 | 57 / 58 | 53 | 22 / 22 |
| test/validation/thai/thai_life_period_position_metadata_completion_test.dart | F070 | 43 / 45 | 39 | 15 / 15 |
| test/validation/thai/thai_life_period_position_metadata_test.dart | F071 | 29 / 31 | 25 | 12 / 12 |
| test/validation/thai/thai_life_period_position_strategy_correction_test.dart | F072, F073 | 38 / 41 | 32 | 14 / 14 |
| test/validation/thai/thai_period_context_normalization_test.dart | F074 | 34 / 35 | 26 | 14 / 14 |
| test/validation/thai_beta/core_reading/thai_beta_readability_acceptance_test.dart | F001 | 34 / 39 | 34 | 2 / 2 |
| test/validation/thai_beta/core_reading/thai_birth_profile_core_reading_test.dart | F002, F003 | 150 / 151 | 145 | 31 / 31 |
| test/validation/thai_beta/life_map/v124/thai_life_map_v124_accuracy_audit_test.dart | F004, F005 | 28 / 37 | 25 | 14 / 14 |
| test/validation/thai_beta/life_map/v135/thai_life_map_v135_evidence_detail_test.dart | F010 | 43 / 45 | 40 | 10 / 10 |
| test/validation/thai_beta/life_map/v135/thai_life_map_v135_product_qa_artifact_test.dart | F011 | 3 / 4 | 3 | 1 / 1 |
| test/validation/thai_beta/live_asof/thai_beta_copy_normalization_scope_test.dart | F012 | 26 / 33 | 24 | 2 / 2 |
| test/validation/thai_beta/live_asof/thai_beta_copy_semantic_safety_test.dart | F013, F014, F015 | 15 / 24 | 12 | 4 / 4 |
| test/validation/thai_beta/live_asof/thai_beta_cross_runtime_300_vm_test.dart | F016 | 12 / 16 | 11 | 1 / 1 |
| test/validation/thai_beta/live_asof/thai_beta_date_aware_contract_test.dart | F017 | 22 / 27 | 20 | 7 / 7 |
| test/validation/thai_beta/live_asof/thai_beta_live_oracle_parity_test.dart | F018 | 10 / 15 | 10 | 1 / 1 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v111_test.dart | F019 | 25 / 26 | 20 | 10 / 10 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v11_test.dart | F020 | 51 / 52 | 45 | 25 / 25 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_claim_planning_test.dart | F022 | 8 / 9 | 8 | 2 / 2 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_r3_report_composer_test.dart | F023, F024, F025 | 15 / 18 | 15 | 3 / 3 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_r4_acceptance_test.dart | F026, F027, F028, F029 | 30 / 33 | 26 | 6 / 6 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_r5_acceptance_test.dart | F030, F031, F032 | 17 / 20 | 14 | 5 / 5 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_r6_reader_quality_test.dart | F033, F034, F035, F036 | 14 / 18 | 13 | 5 / 5 |
| test/validation/thai_beta/narrative/thai_beta_narrative_v15_r7_reader_quality_test.dart | F037, F038, F039 | 15 / 19 | 12 | 5 / 5 |
| test/validation/thai_beta/narrative/thai_consumer_narrative_voice_v1_test.dart | F041, F042, F043, F044 | 116 / 125 | 98 | 22 / 22 |
| test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart | F045, F046, F047 | 59 / 71 | 51 | 6 / 6 |
| test/validation/thai_beta/thai_beta_report_export_test.dart | F048, F049, F050, F051, F052, F053, F054 | 222 / 230 | 205 | 54 / 54 |
| test/validation/thai_beta/thai_report_copy_candidate_300_audit_test.dart | F055 | 27 / 34 | 27 | 1 / 1 |
| test/validation/thai_beta/thai_report_experience_infographic_vnext_test.dart | F056, F057, F058, F059, F060 | 70 / 82 | 66 | 9 / 9 |
| test/validation/thai_beta/thai_report_vnext_cross_runtime_vm_test.dart | F061 | 1 / 1 | 1 | 1 / 1 |

Counting call sites alone does not measure executed assertions: shared exact Unknown contract checks run for every applicable profile. Replacement groups deliberately show every added call plus full surrounding diff. Runtime baseline and negative-control results must be read alongside this ledger.
