import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import 'personality_agreement_kind.dart';
import 'personality_agreement_lens_id.dart';
import 'personality_confidence.dart';

/// Cross-lens agreement record produced by [PersonalityAgreementEngine].
class PersonalityAgreement {
  const PersonalityAgreement({
    required this.kind,
    required this.themeId,
    required this.supportingAgreementLenses,
    required this.confidence,
    this.sourceThemeIds = const [],
    this.family,
    this.category,
    @Deprecated('Use kind == PersonalityAgreementKind.family')
    this.familyLevel = false,
  });

  final PersonalityAgreementKind kind;
  final String themeId;
  final List<PersonalityAgreementLensId> supportingAgreementLenses;
  final PersonalityConfidence confidence;
  final List<String> sourceThemeIds;
  final ThemeFamily? family;
  final FusionCategory? category;
  final bool familyLevel;
}
