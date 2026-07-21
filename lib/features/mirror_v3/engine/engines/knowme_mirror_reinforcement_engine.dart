import '../../enums/knowme_mirror_pattern_type.dart';
import '../models/knowme_mirror_reinforcement.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Detects multi-fact reinforcement within a mirror key.
abstract final class KnowMeMirrorReinforcementEngine {
  static const minEvidenceCount = 2;

  static List<KnowMeMirrorReinforcement> detect(
    List<KnowMeMirrorThemeSignal> signals,
  ) {
    if (signals.isEmpty) return const [];

    final reinforcements = <KnowMeMirrorReinforcement>[];

    for (final signal in signals) {
      if (signal.evidenceCount < minEvidenceCount) continue;

      reinforcements.add(
        KnowMeMirrorReinforcement(
          id:
              'reinforcement:${signal.mirrorKey}:${signal.sourceLensKey}:${signal.themeId}',
          patternType: KnowMeMirrorPatternType.themeFactReinforcement,
          mirrorKey: signal.mirrorKey,
          mirrorDimension: signal.mirrorDimension,
          themeIds: [signal.themeId],
          supportingSystem: signal.systemId,
          supportingLensKey: signal.sourceLensKey,
          evidenceCount: signal.evidenceCount,
          structuralWeight: signal.prominence,
        ),
      );
    }

    reinforcements.sort((a, b) => a.id.compareTo(b.id));
    return reinforcements;
  }
}
