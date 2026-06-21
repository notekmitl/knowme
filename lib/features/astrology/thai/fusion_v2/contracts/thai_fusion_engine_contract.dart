import '../constants/thai_fusion_version_contract.dart';

/// Frozen F1 contracts for Thai Fusion V2 synthesis domain.
abstract final class ThaiFusionEngineContract {
  static const fusionVersion = ThaiFusionVersionContract.fusionVersion;

  /// Delimiter for [ThaiFusionIdentityContract.fusionSnapshotId].
  static const fusionSnapshotIdDelimiter = '|';

  /// Allowed engine input types (F2+).
  static const allowedInputTypeNames = <String>[
    'ThaiMirrorSnapshot',
    'ThaiThemeBundle',
    'ThaiInterpretationBundle',
  ];

  static const snapshotFieldNames = <String>[
    'fusionSnapshotId',
    'sourceMirrorSnapshotId',
    'sourceThemeBundleId',
    'sourceInterpretationBundleId',
    'fusionVersion',
    'generatedAt',
    'categories',
    'insights',
    'agreements',
    'tensions',
    'confidence',
    'coverage',
    'warnings',
  ];

  static const insightFieldNames = <String>[
    'insightId',
    'categoryId',
    'patternType',
    'structuralWeight',
    'confidence',
    'evidence',
    'sourceRefs',
  ];

  static const evidenceFieldNames = <String>[
    'sourceLayer',
    'sourceRefId',
    'categoryId',
    'structuralWeight',
    'confidence',
  ];

  static const agreementFieldNames = <String>[
    'agreementId',
    'categoryId',
    'themeIds',
    'factIds',
    'dimensionIds',
    'strength',
    'confidence',
  ];

  static const tensionFieldNames = <String>[
    'tensionId',
    'categoryId',
    'leftRefId',
    'rightRefId',
    'tensionStrength',
    'confidence',
  ];

  static const categoryActivationFieldNames = <String>[
    'categoryId',
    'prominence',
    'themeCount',
    'factCount',
    'dimensionRefId',
    'confidence',
  ];

  static const coverageFieldNames = <String>[
    'mappedCategoryCount',
    'totalCategoryCount',
    'mirrorDimensionCount',
    'interpretationFactCount',
    'hasSparseDimensions',
  ];

  static const confidenceFieldNames = <String>[
    'overallLevel',
    'mirrorLevel',
    'themeLevel',
    'interpretationLevel',
    'distinctSourceFactCount',
  ];

  static const sourceRefsFieldNames = <String>[
    'dimensionIds',
    'themeIds',
    'factIds',
  ];

  static const forbiddenFusionFieldNames = <String>[
    'title',
    'summary',
    'description',
    'narrative',
    'prediction',
    'contentText',
    'contentKey',
    'fragmentText',
    'uiLabel',
    'heroCopy',
    'mirrorCopy',
    'disclaimer',
  ];

  static const supportedCategoryIds = <String>[
    'core_self',
    'thinking_style',
    'emotional_world',
    'relationships',
    'work_ambition',
    'strengths',
    'growth_areas',
    'growth_path',
  ];

  static const supportedPatternTypeIds = <String>[
    'cross_layer_agreement',
    'cross_layer_tension',
    'theme_fact_reinforcement',
    'dimension_theme_alignment',
    'coverage_gap',
    'sparse_fusion_coverage',
  ];
}
