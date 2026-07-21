import '../constants/thai_theme_engine_version.dart';

/// Frozen T1 contracts for Theme Layer V2 aggregation domain.
abstract final class ThaiThemeEngineContract {
  static const themeEngineVersion =
      ThaiThemeEngineVersionContract.themeEngineVersion;

  /// Fields permitted on [ThaiThemeScore].
  static const themeScoreFieldNames = <String>[
    'themeId',
    'category',
    'score',
    'confidence',
    'rank',
    'contributions',
  ];

  /// Fields permitted on [ThaiThemeContribution].
  static const themeContributionFieldNames = <String>[
    'sourceFactId',
    'contentKey',
    'contribution',
  ];

  /// Fields permitted on [ThaiThemeBundle].
  static const themeBundleFieldNames = <String>[
    'bundleId',
    'sourceInterpretationBundleId',
    'generatedAt',
    'themes',
    'warnings',
  ];

  /// Fields explicitly forbidden on theme domain models (T1 revised).
  static const forbiddenThemeFieldNames = <String>[
    'title',
    'summary',
    'narrative',
    'description',
    'strengths',
    'challenges',
    'growthPathText',
    'mirrorCopy',
    'uiLabel',
    'presentation',
    'evidenceFactIds',
    'fragmentText',
    'predicate',
    'objectRef',
    'provenance',
    'provenanceRef',
    'factConfidence',
    'mappingWeight',
    'sourceTypeWeight',
  ];

  /// Delimiter for [ThaiThemeBundleIdentityContract.bundleId].
  static const bundleIdDelimiter = '|';

  /// All supported theme categories (T1).
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
}
