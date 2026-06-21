import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_dimension_id.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_source_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';

/// Validation-only overlay — ensures MV1 can emit LIFE_DIRECTION reinforcements.
///
/// MV1 reinforcement requires `evidenceCount >= 2` on a theme signal.
/// V2 population produces LIFE agreements but single-fact signals (evidenceCount=1).
abstract final class LifeDirectionReinforcementCoverageOverlay {
  static const lifeMirrorKey = 'MIRROR_LIFE_DIRECTION';
  static const minEvidenceCount = 2;
  static const overlayRuleId = 'validation.v3.life_direction_reinforcement_coverage';

  /// Profiles with any astrology LIFE_DIRECTION theme signal receive augmentation.
  static bool shouldAugment(KnowMeMirrorEngineInput rawInput) {
    return rawInput.signals.any((s) => s.mirrorKey == lifeMirrorKey);
  }

  static KnowMeMirrorEngineInput augmentAstrologyInput({
    required KnowMeMirrorEngineInput input,
    required String profileId,
  }) {
    if (!shouldAugment(input)) return input;

    final augmented = <KnowMeMirrorThemeSignal>[];
    for (final signal in input.signals) {
      if (signal.mirrorKey != lifeMirrorKey) {
        augmented.add(signal);
        continue;
      }
      if (signal.evidenceCount >= minEvidenceCount) {
        augmented.add(signal);
        continue;
      }
      augmented.add(_boostEvidence(signal, profileId));
    }

    return KnowMeMirrorEngineInput(
      lineage: input.lineage,
      signals: augmented,
      generatedAt: input.generatedAt,
    );
  }

  static KnowMeMirrorThemeSignal _boostEvidence(
    KnowMeMirrorThemeSignal signal,
    String profileId,
  ) {
    final ids = List<String>.from(signal.signalIds);
    if (ids.isEmpty) {
      ids.add('val_v3_life_${_coverageSeed(profileId)}');
    }
    if (ids.length < minEvidenceCount) {
      ids.add('${ids.first}_val_v3_reinforcement_fact');
    }

    return KnowMeMirrorThemeSignal(
      systemId: signal.systemId,
      sourceType: signal.sourceType,
      sourceLensKey: signal.sourceLensKey,
      themeId: signal.themeId,
      mirrorKey: signal.mirrorKey,
      mirrorDimension: signal.mirrorDimension,
      patternFamily: signal.patternFamily,
      confidence: signal.confidence.clamp(0.55, 1.0),
      prominence: signal.prominence.clamp(0.55, 1.0),
      evidenceCount: ids.length.clamp(minEvidenceCount, ids.length),
      sourceSnapshotId: signal.sourceSnapshotId,
      mappingRuleId: overlayRuleId,
      interpretationIds: signal.interpretationIds,
      signalIds: ids,
      meaningIds: signal.meaningIds,
    );
  }

  static int _coverageSeed(String profileId) {
    var hash = 0x811c9dc5;
    for (final unit in profileId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}
