import 'personality_lens_id.dart';

/// Agreement-level lens groups (EQ modules collapse to [eq]).
enum PersonalityAgreementLensId {
  mbti,
  bigFive,
  eq;

  String get storageKey => switch (this) {
        PersonalityAgreementLensId.mbti => 'mbti',
        PersonalityAgreementLensId.bigFive => 'big_five',
        PersonalityAgreementLensId.eq => 'eq',
      };

  static PersonalityAgreementLensId? fromPersonalityLensId(
    PersonalityLensId lensId,
  ) {
    return switch (lensId) {
      PersonalityLensId.mbti => PersonalityAgreementLensId.mbti,
      PersonalityLensId.bigFive => PersonalityAgreementLensId.bigFive,
      PersonalityLensId.eqAwareness ||
      PersonalityLensId.eqRegulation ||
      PersonalityLensId.eqEmpathy ||
      PersonalityLensId.eqSocial ||
      PersonalityLensId.eqDecision ||
      PersonalityLensId.eqStress =>
        PersonalityAgreementLensId.eq,
    };
  }

  static const primaryLenses = <PersonalityAgreementLensId>[
    PersonalityAgreementLensId.mbti,
    PersonalityAgreementLensId.bigFive,
    PersonalityAgreementLensId.eq,
  ];
}
