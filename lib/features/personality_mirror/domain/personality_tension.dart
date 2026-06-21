import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import 'personality_agreement_lens_id.dart';

/// Cross-lens tension between opposing families in the same category.
class PersonalityTension {
  const PersonalityTension({
    required this.category,
    required this.themeIds,
    required this.agreementLensIds,
    required this.families,
    required this.reasonCode,
  });

  final FusionCategory category;
  final List<String> themeIds;
  final List<PersonalityAgreementLensId> agreementLensIds;
  final List<ThemeFamily> families;
  final String reasonCode;
}
