import 'fusion_support_level.dart';
import 'theme_family.dart';

/// Cross-lens theme or family alignment.
class FusionAgreement {
  const FusionAgreement({
    required this.sourceThemeIds,
    required this.supportingLenses,
    required this.supportLevel,
    this.family,
    this.familyLevel = false,
  });

  final List<String> sourceThemeIds;
  final List<String> supportingLenses;
  final FusionSupportLevel supportLevel;

  /// Set when agreement is resolved at semantic family level.
  final ThemeFamily? family;
  final bool familyLevel;

  String get primaryThemeId => sourceThemeIds.first;
}
