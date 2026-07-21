/// MV1 engine contract — structural reflection only.
abstract final class KnowMeMirrorEngineContract {
  static const mirrorEngineVersion = 'v0.1.0';
  static const allowedInputTypeName = 'KnowMeMirrorEngineInput';

  static const forbiddenInputLayers = <String>[
    'Fusion',
    'Content',
    'Presentation',
    'Narrative',
  ];

  static const forbiddenMirrorFieldNames = <String>[
    'title',
    'summary',
    'narrative',
    'description',
    'prediction',
    'contentText',
    'advice',
    'mirrorCopy',
  ];

  static const engineFieldNames = <String>[
    'bundle',
    'agreements',
    'tensions',
    'reinforcements',
    'blindSpots',
    'compositeConfidence',
  ];
}
