import 'global_agreement_strength.dart';
import 'global_lens_id.dart';

/// Cross-mirror theme alignment detected by [GlobalAgreementEngine].
class GlobalAgreement {
  const GlobalAgreement({
    required this.id,
    required this.themeId,
    required this.supportingMirrors,
    required this.supportingEvidenceCount,
    required this.strength,
  });

  final String id;
  final String themeId;
  final List<GlobalLensId> supportingMirrors;
  final int supportingEvidenceCount;
  final GlobalAgreementStrength strength;

  static String idForTheme(String themeId) => 'agreement:$themeId';
}
