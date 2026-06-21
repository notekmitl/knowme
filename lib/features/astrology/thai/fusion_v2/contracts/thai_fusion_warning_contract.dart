/// Frozen warning codes for Thai Fusion V2.
abstract final class ThaiFusionWarningContract {
  static const inputLineageMismatch = 'FUSION_INPUT_LINEAGE_MISMATCH';

  static const insufficientCoverage = 'FUSION_INSUFFICIENT_COVERAGE';

  static const sparseSynthesis = 'FUSION_SPARSE_SYNTHESIS';

  static const mirrorThemeDivergence = 'FUSION_MIRROR_THEME_DIVERGENCE';

  static const allowedWarningCodes = <String>[
    inputLineageMismatch,
    insufficientCoverage,
    sparseSynthesis,
    mirrorThemeDivergence,
  ];
}
