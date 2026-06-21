import '../adapters/lens_theme_output.dart';
import '../domain/entities/fusion_agreement.dart';
import '../domain/entities/fusion_signal.dart';
import '../domain/entities/fusion_support_level.dart';
import '../registry/family_registry.dart';
import '../registry/signal_registry.dart';
import '../registry/theme_registry.dart';

/// Detects exact and family-level cross-lens theme agreement.
abstract final class AgreementEngine {
  static List<FusionAgreement> detect(List<LensThemeOutput> outputs) {
    final known = outputs
        .where((output) => FusionThemeRegistry.contains(output.themeId))
        .toList();

    final agreements = <FusionAgreement>[
      ..._detectExact(known),
      ..._detectFamilyLevel(known),
    ];

    return _dedupeAgreements(agreements);
  }

  static List<FusionAgreement> _detectExact(List<LensThemeOutput> outputs) {
    final byTheme = <String, List<LensThemeOutput>>{};
    for (final output in outputs) {
      final themeId = output.themeId.trim().toLowerCase();
      byTheme.putIfAbsent(themeId, () => []).add(output);
    }

    final agreements = <FusionAgreement>[];
    for (final entry in byTheme.entries) {
      final lenses = entry.value.map((output) => output.lensId).toSet().toList()
        ..sort();
      if (lenses.length < 2) continue;

      agreements.add(
        FusionAgreement(
          sourceThemeIds: [entry.key],
          supportingLenses: lenses,
          supportLevel: fusionSupportLevelFromLensCount(lenses.length),
        ),
      );
    }
    return agreements;
  }

  static List<FusionAgreement> _detectFamilyLevel(
    List<LensThemeOutput> outputs,
  ) {
    final bySignal = <FusionSignalType, List<LensThemeOutput>>{};

    for (final output in outputs) {
      final signal = FusionSignalRegistry.signalForTheme(output.themeId);
      if (signal == null) continue;
      bySignal.putIfAbsent(signal, () => []).add(output);
    }

    final agreements = <FusionAgreement>[];
    for (final entry in bySignal.entries) {
      final themes = entry.value
          .map((output) => output.themeId.trim().toLowerCase())
          .toSet()
          .toList()
        ..sort();
      final lenses = entry.value.map((output) => output.lensId).toSet().toList()
        ..sort();

      if (lenses.length < 2) continue;
      if (themes.length < 2) continue;

      final family = FusionFamilyRegistry.familyForThemeId(themes.first);
      agreements.add(
        FusionAgreement(
          sourceThemeIds: themes,
          supportingLenses: lenses,
          supportLevel: fusionSupportLevelFromLensCount(lenses.length),
          family: family,
          familyLevel: true,
        ),
      );
    }
    return agreements;
  }

  static List<FusionAgreement> _dedupeAgreements(
    List<FusionAgreement> agreements,
  ) {
    final seen = <String>{};
    final deduped = <FusionAgreement>[];

    for (final agreement in agreements) {
      final key = [
        agreement.familyLevel,
        agreement.family?.name,
        ...agreement.sourceThemeIds,
        ...agreement.supportingLenses,
      ].join('|');
      if (seen.add(key)) deduped.add(agreement);
    }

    return deduped;
  }
}
