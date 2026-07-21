import '../constants/thai_mirror_version_contract.dart';

/// Frozen M1 contracts for Thai Mirror V2 domain.
abstract final class ThaiMirrorEngineContract {
  static const mirrorVersion = ThaiMirrorVersionContract.mirrorVersion;

  /// Allowed engine input type (M2+).
  static const allowedInputTypeName = 'ThaiThemeBundle';

  /// Forbidden upstream layers for direct reads.
  static const forbiddenInputLayers = <String>[
    'Signal',
    'Interpretation',
    'Content Lookup',
  ];

  /// Delimiter for [ThaiMirrorSnapshotIdentityContract.snapshotId].
  static const snapshotIdDelimiter = '|';

  /// Fields permitted on [ThaiMirrorSnapshot].
  static const snapshotFieldNames = <String>[
    'snapshotId',
    'sourceThemeBundleId',
    'mirrorVersion',
    'generatedAt',
    'dimensions',
    'insights',
    'warnings',
  ];

  /// Fields permitted on [ThaiMirrorDimension].
  static const dimensionFieldNames = <String>[
    'dimensionId',
    'prominence',
    'confidence',
    'leadingThemeIds',
    'evidence',
  ];

  /// Fields permitted on [ThaiMirrorEvidence].
  static const evidenceFieldNames = <String>[
    'themeId',
    'category',
    'score',
    'rank',
    'confidence',
    'distinctSourceFactCount',
  ];

  /// Fields permitted on [ThaiMirrorInsight].
  static const insightFieldNames = <String>[
    'insightId',
    'dimensionId',
    'patternType',
    'themeIds',
    'structuralWeight',
    'confidence',
  ];

  /// Fields explicitly forbidden on mirror domain models (M1).
  static const forbiddenMirrorFieldNames = <String>[
    'title',
    'summary',
    'narrative',
    'description',
    'prediction',
    'contentText',
    'fragmentText',
    'contentKey',
    'contentTitle',
    'lensSource',
    'uiLabel',
    'mirrorCopy',
    'heroCopy',
    'disclaimer',
    'strengths',
    'challenges',
    'growthPathText',
    'predicate',
    'objectRef',
    'provenance',
    'sourceFactId',
  ];

  static const supportedDimensionIds = <String>[
    'prominent_strengths',
    'thinking_pattern',
    'emotional_pattern',
    'relationship_pattern',
    'growth_focus',
  ];

  static const supportedPatternTypeIds = <String>[
    'dominant_theme',
    'co_activated_themes',
    'sparse_coverage',
    'balanced_spread',
  ];
}
