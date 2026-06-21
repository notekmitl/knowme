/// Frozen B0 contracts for the Thai Interpretation meaning layer.

abstract final class ThaiInterpretationContract {

  /// Fields permitted on [ThaiInterpretationFact].

  static const interpretationFactFieldNames = <String>[

    'factId',

    'predicate',

    'objectRef',

    'context',

    'tier',

    'evidence',

    'confidence',

    'provenance',

  ];



  /// Fields explicitly forbidden on meaning facts (B0).

  static const forbiddenFactFieldNames = <String>[

    'title',

    'summary',

    'strengths',

    'challenges',

    'narrative',

    'themeId',

    'category',

    'domain',

    'semanticAnchorId',

    'contentKeyRefs',

  ];



  /// B0 atomic meaning rule identifiers (logic implemented in B1).

  static const lagnaSignRuleId = 'lagna_sign_rule_v1';

  static const lagnaLordRuleId = 'lagna_lord_rule_v1';

  static const houseSignRuleId = 'house_sign_rule_v1';

  static const houseLordRuleId = 'house_lord_rule_v1';

  static const myanmarPositionRuleId = 'myanmar_position_rule_v1';

  static const mahabhutaPositionRuleId = 'mahabhuta_position_rule_v1';



  /// Deterministic bundle identity formula (generation in B1).

  ///

  /// `{sourceBundleId}|{interpreterVersion}|{sorted factIds joined by ','}`

  static const bundleIdDelimiter = '|';

}


