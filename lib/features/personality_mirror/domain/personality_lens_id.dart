/// Stable identifiers for personality lenses consumed by Personality Mirror.
enum PersonalityLensId {
  mbti,
  bigFive,
  eqAwareness,
  eqRegulation,
  eqEmpathy,
  eqSocial,
  eqDecision,
  eqStress;

  String get storageKey => switch (this) {
        PersonalityLensId.mbti => 'mbti',
        PersonalityLensId.bigFive => 'big_five',
        PersonalityLensId.eqAwareness => 'eq_awareness',
        PersonalityLensId.eqRegulation => 'eq_regulation',
        PersonalityLensId.eqEmpathy => 'eq_empathy',
        PersonalityLensId.eqSocial => 'eq_social',
        PersonalityLensId.eqDecision => 'eq_decision',
        PersonalityLensId.eqStress => 'eq_stress',
      };

  /// Firestore `results/{docId}` for this lens.
  String get resultDocId => switch (this) {
        PersonalityLensId.mbti => 'mbti_mini',
        PersonalityLensId.bigFive => 'big_five',
        PersonalityLensId.eqAwareness => 'eq_awareness',
        PersonalityLensId.eqRegulation => 'eq_regulation',
        PersonalityLensId.eqEmpathy => 'eq_empathy',
        PersonalityLensId.eqSocial => 'eq_social',
        PersonalityLensId.eqDecision => 'eq_decision',
        PersonalityLensId.eqStress => 'eq_stress',
      };

  static PersonalityLensId? fromResultDocId(String docId) {
    final normalized = docId.trim();
    for (final lens in PersonalityLensId.values) {
      if (lens.resultDocId == normalized) return lens;
    }
    if (normalized == 'mbti_progressive' || normalized.startsWith('mbti_')) {
      return PersonalityLensId.mbti;
    }
    return null;
  }

  static const primaryLenses = <PersonalityLensId>[
    PersonalityLensId.mbti,
    PersonalityLensId.bigFive,
  ];

  static const eqLenses = <PersonalityLensId>[
    PersonalityLensId.eqAwareness,
    PersonalityLensId.eqRegulation,
    PersonalityLensId.eqEmpathy,
    PersonalityLensId.eqSocial,
    PersonalityLensId.eqDecision,
    PersonalityLensId.eqStress,
  ];

  static const all = <PersonalityLensId>[
    ...primaryLenses,
    ...eqLenses,
  ];
}
