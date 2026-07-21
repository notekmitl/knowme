import '../../domain/global_agreement.dart';
import '../../domain/global_agreement_strength.dart';
import '../../domain/global_lens_id.dart';
import '../../domain/global_theme_activation.dart';

/// Detects themes independently supported by both mirrors (GF-F1 Rule V1).
abstract final class GlobalAgreementEngine {
  static List<GlobalAgreement> detect(List<GlobalThemeActivation> activations) {
    final support = _mirrorSupportByTheme(activations);
    final agreements = <GlobalAgreement>[];

    for (final entry in support.entries) {
      final themeId = entry.key;
      final mirrors = entry.value.mirrors;
      if (!mirrors.contains(GlobalLensId.astrologyMirror) ||
          !mirrors.contains(GlobalLensId.personalityMirror)) {
        continue;
      }

      final evidenceCount = entry.value.evidenceCount;
      agreements.add(
        GlobalAgreement(
          id: GlobalAgreement.idForTheme(themeId),
          themeId: themeId,
          supportingMirrors: const [
            GlobalLensId.astrologyMirror,
            GlobalLensId.personalityMirror,
          ],
          supportingEvidenceCount: evidenceCount,
          strength: GlobalAgreementStrengthRules.forEvidenceCount(evidenceCount),
        ),
      );
    }

    agreements.sort((a, b) => a.themeId.compareTo(b.themeId));
    return agreements;
  }

  static Map<String, _ThemeMirrorSupport> _mirrorSupportByTheme(
    List<GlobalThemeActivation> activations,
  ) {
    final support = <String, _ThemeMirrorSupport>{};

    for (final activation in activations) {
      final bucket = support.putIfAbsent(
        activation.globalThemeId,
        () => _ThemeMirrorSupport(),
      );

      for (final evidence in activation.evidence) {
        bucket.mirrors.add(evidence.sourceMirror);
        bucket.evidenceCount++;
      }
    }

    return support;
  }
}

class _ThemeMirrorSupport {
  final Set<GlobalLensId> mirrors = {};
  int evidenceCount = 0;
}
