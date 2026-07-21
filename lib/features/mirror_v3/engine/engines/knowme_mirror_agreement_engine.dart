import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../models/knowme_mirror_agreement.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Detects cross-system and cross-lens agreement on mirror keys and themes.
abstract final class KnowMeMirrorAgreementEngine {
  static List<KnowMeMirrorAgreement> detect(
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    if (signals.isEmpty) return const [];

    return [
      ..._detectMirrorKeyAgreement(signals),
      ..._detectThemeAgreement(signals),
    ];
  }

  static List<KnowMeMirrorAgreement> _detectMirrorKeyAgreement(
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    final byMirrorKey = <String, List<KnowMeMirrorThemeSignal>>{};
    for (final signal in signals) {
      byMirrorKey.putIfAbsent(signal.mirrorKey, () => []).add(signal);
    }

    final agreements = <KnowMeMirrorAgreement>[];
    for (final entry in byMirrorKey.entries) {
      final systems = entry.value.map((s) => s.systemId).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      if (systems.length < 2) continue;

      final lenses = entry.value.map((s) => s.sourceLensKey).toSet().toList()
        ..sort();
      final themes = entry.value.map((s) => s.themeId).toSet().toList()..sort();
      final sample = entry.value.first;

      agreements.add(
        KnowMeMirrorAgreement(
          id: _agreementId(
            kind: 'mirror_key',
            key: entry.key,
            themes: themes,
            lenses: lenses,
          ),
          patternType: KnowMeMirrorPatternType.crossSystemAgreement,
          mirrorKey: entry.key,
          mirrorDimension: sample.mirrorDimension,
          themeIds: themes,
          supportingSystems: List<KnowMeMirrorSystemId>.from(systems),
          supportingLensKeys: lenses,
          confidence: _averageConfidence(entry.value),
        ),
      );
    }

    return agreements;
  }

  static List<KnowMeMirrorAgreement> _detectThemeAgreement(
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    final byTheme = <String, List<KnowMeMirrorThemeSignal>>{};
    for (final signal in signals) {
      byTheme.putIfAbsent(signal.themeId, () => []).add(signal);
    }

    final agreements = <KnowMeMirrorAgreement>[];
    for (final entry in byTheme.entries) {
      final lenses = entry.value.map((s) => s.sourceLensKey).toSet().toList()
        ..sort();
      if (lenses.length < 2) continue;

      final systems = entry.value.map((s) => s.systemId).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final sample = entry.value.first;
      final patternType = systems.length >= 2
          ? KnowMeMirrorPatternType.crossSystemAgreement
          : KnowMeMirrorPatternType.crossLensAgreement;

      agreements.add(
        KnowMeMirrorAgreement(
          id: _agreementId(
            kind: 'theme',
            key: entry.key,
            themes: [entry.key],
            lenses: lenses,
          ),
          patternType: patternType,
          mirrorKey: sample.mirrorKey,
          mirrorDimension: sample.mirrorDimension,
          themeIds: [entry.key],
          supportingSystems: List<KnowMeMirrorSystemId>.from(systems),
          supportingLensKeys: lenses,
          confidence: _averageConfidence(entry.value),
        ),
      );
    }

    return agreements;
  }

  static double _averageConfidence(List<KnowMeMirrorThemeSignal> signals) {
    if (signals.isEmpty) return 0;
    final sum = signals.fold<double>(0, (total, s) => total + s.confidence);
    return (sum / signals.length).clamp(0.0, 1.0);
  }

  static String _agreementId({
    required String kind,
    required String key,
    required List<String> themes,
    required List<String> lenses,
  }) {
    return 'agreement:$kind:$key:${themes.join(',')}:${lenses.join(',')}';
  }
}
