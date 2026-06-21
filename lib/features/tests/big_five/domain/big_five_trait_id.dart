/// Internal Big Five trait identifiers (domain layer).
abstract final class BigFiveTraitId {
  static const openness = 'openness';
  static const conscientiousness = 'conscientiousness';
  static const extraversion = 'extraversion';
  static const agreeableness = 'agreeableness';
  static const neuroticism = 'neuroticism';

  static const all = <String>[
    openness,
    conscientiousness,
    extraversion,
    agreeableness,
    neuroticism,
  ];

  /// Firestore / fusion field names (e.g. `opennessScore`, `opennessBand`).
  static String scoreField(String traitId) => '${traitId}Score';

  static String bandField(String traitId) => '${traitId}Band';

  static const scoreFields = <String>[
    'opennessScore',
    'conscientiousnessScore',
    'extraversionScore',
    'agreeablenessScore',
    'neuroticismScore',
  ];

  static const bandFields = <String>[
    'opennessBand',
    'conscientiousnessBand',
    'extraversionBand',
    'agreeablenessBand',
    'neuroticismBand',
  ];
}
