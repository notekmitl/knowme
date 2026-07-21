/// Frozen meaning-preservation policy for Content Lookup Layer C0.
abstract final class ThaiMeaningPreservationContract {
  /// Fields permitted on [ThaiContentFragment].
  static const allowedFragmentFieldNames = <String>[
    'resolutionId',
    'fragmentKind',
    'text',
    'sourceFactId',
    'contentKey',
    'contentVersion',
    'meaningRef',
    'fragmentIndex',
  ];

  /// Fields explicitly forbidden on presentation fragments (C0).
  static const forbiddenFragmentFieldNames = <String>[
    'confidence',
    'evidence',
    'provenanceRef',
    'provenance',
    'themeId',
    'category',
    'domain',
    'semanticAnchorId',
  ];

  /// Minimum trace in the default bundled pipeline.
  static const bundledMinimumTraceFieldNames = <String>[
    'sourceFactId',
    'resolutionId',
    'contentKey',
  ];

  /// Additional fields required for standalone fragment export (C1+).
  static const standaloneExportFieldNames = <String>[
    'meaningRef',
  ];

  /// Bundled pipeline must not emit [meaningRef] on fragments.
  static const bundledPipelineEmitMeaningRef = false;
}
