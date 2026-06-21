/// Barrel export for Global Fusion domain types (GF-F0).
library;

export 'global_agreement.dart';
export 'global_agreement_strength.dart';
export 'global_confidence.dart';
export 'global_confidence_band.dart';
export 'global_core_themes.dart';
export 'global_coverage.dart';
export 'global_evidence.dart';
export 'global_fusion_constants.dart';
export 'global_fusion_input.dart';
export 'global_fusion_snapshot.dart';
export 'global_lens_id.dart';
export 'global_tension.dart';
export 'global_theme_activation.dart';
export 'global_reflection_unit.dart';
export 'global_theme_contract.dart';

export '../application/agreement/global_agreement_engine.dart';
export '../application/confidence/global_confidence_composer.dart';
export '../application/narrative/global_narrative_builder.dart';
export '../application/narrative/global_narrative_registry.dart';
export '../application/global_fusion_builder.dart';
export '../application/global_fusion_input_loader.dart';
export '../application/tension/global_tension_engine.dart';
export '../application/tension/global_tension_pairs.dart';
export '../application/theme_normalization/global_theme_mapping_policy.dart';
export '../application/theme_normalization/global_theme_normalizer.dart';
export '../application/theme_normalization/mirror_theme_mappings.dart';

export '../validation/global_confidence_golden_scenario.dart';
export '../validation/global_confidence_validation_harness.dart';
export '../validation/global_narrative_golden_scenario.dart';
export '../validation/global_narrative_validation_harness.dart';
export '../validation/global_fusion_golden_scenario.dart';
export '../validation/global_fusion_golden_fixtures.dart';
export '../validation/global_fusion_validation_harness.dart';
export '../validation/global_fusion_validation_result.dart';
export '../validation/global_theme_mapping_validator.dart';
