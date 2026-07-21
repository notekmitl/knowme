import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';

import '../models/synthetic_human_profile.dart';

/// Per-human pipeline metrics for population audits.
class SyntheticHumanRunRecord {
  const SyntheticHumanRunRecord({
    required this.profile,
    required this.astrologyInput,
    required this.personalityInput,
    required this.astrologyMirrorSnapshot,
    required this.personalityMirrorSnapshot,
    required this.globalFusionSnapshot,
    required this.humanPatternSnapshot,
    required this.narrativeResult,
    required this.generatedAt,
  });

  final SyntheticHumanProfile profile;
  final KnowMeMirrorEngineInput astrologyInput;
  final KnowMeMirrorEngineInput personalityInput;
  final KnowMeMirrorSnapshot astrologyMirrorSnapshot;
  final KnowMeMirrorSnapshot personalityMirrorSnapshot;
  final GlobalFusionSnapshot globalFusionSnapshot;
  final HumanPatternSnapshot humanPatternSnapshot;
  final NarrativeResult narrativeResult;
  final DateTime generatedAt;

  String get mirrorFingerprint =>
      '${astrologyMirrorSnapshot.structuralHash}|${personalityMirrorSnapshot.structuralHash}';

  String get fusionFingerprint => globalFusionSnapshot.structuralHash;

  List<String> get activatedPatternIds => humanPatternSnapshot.activations
      .map((item) => item.patternId)
      .toList()
    ..sort();

  String get patternFingerprint => activatedPatternIds.join('|');

  String get narrativeFingerprint {
    final parts = <String>[];
    for (final section in narrativeResult.sections) {
      for (final paragraph in section.paragraphs) {
        parts.add(paragraph.text.trim().toLowerCase());
      }
    }
    return parts.join('\n');
  }

  Map<String, int> mirrorSignalCountsBySystem() {
    final counts = <String, int>{};
    for (final signal in [
      ...astrologyInput.signals,
      ...personalityInput.signals,
    ]) {
      final key = _coverageKey(signal.systemId);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static String _coverageKey(KnowMeMirrorSystemId systemId) {
    return switch (systemId) {
      KnowMeMirrorSystemId.thaiAstrology => 'thai',
      KnowMeMirrorSystemId.mbti => 'mbti',
      KnowMeMirrorSystemId.bigFive => 'big_five',
      KnowMeMirrorSystemId.eq => 'eq',
      KnowMeMirrorSystemId.knowMeMirror => 'bazi_zodiac',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profile.profileId,
      'archetypeId': profile.archetypeId,
      'variant': profile.variant.label,
      'mirrorFingerprint': mirrorFingerprint,
      'fusionFingerprint': fusionFingerprint,
      'activatedPatternCount': activatedPatternIds.length,
      'activatedPatternIds': activatedPatternIds,
      'narrativeParagraphCount': narrativeResult.paragraphCount,
      'mirrorSignalCounts': mirrorSignalCountsBySystem(),
      'fusionAgreements': globalFusionSnapshot.agreements.length,
      'fusionTensions': globalFusionSnapshot.tensions.length,
      'fusionBlindSpots': globalFusionSnapshot.blindSpots.length,
      'fusionReinforcements': globalFusionSnapshot.reinforcements.length,
    };
  }
}
