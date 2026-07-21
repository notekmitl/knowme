/// Context extracted from [ThaiBetaAnalysis] for narrative composition.
library;

import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_narrative_stable_hash.dart';

class ThaiBetaNarrativeContext {
  const ThaiBetaNarrativeContext({
    required this.orderedThemeIds,
    required this.profileSeed,
    required this.hasBirthTime,
    this.referenceDate,
    this.lifePeriodLabel,
  });

  final List<String> orderedThemeIds;
  final int profileSeed;
  final bool hasBirthTime;
  final DateTime? referenceDate;
  final String? lifePeriodLabel;

  factory ThaiBetaNarrativeContext.fromAnalysis(ThaiBetaAnalysis analysis) {
    return ThaiBetaNarrativeContext(
      orderedThemeIds: _orderedThemeIds(analysis),
      profileSeed: _profileSeed(analysis),
      hasBirthTime: analysis.input.hasBirthTime,
      referenceDate: analysis.startedAt,
      lifePeriodLabel: _lifePeriodLabel(analysis),
    );
  }

  static String? _lifePeriodLabel(ThaiBetaAnalysis analysis) {
    final stage = analysis.consumerViewState?.lifeTimeline?.currentStage;
    if (stage == null) return null;
    final phase = stage.phaseName.trim();
    if (phase.isEmpty) return null;
    return phase;
  }

  static List<String> _orderedThemeIds(ThaiBetaAnalysis analysis) {
    final result = analysis.pipelineResult?.mirrorResult;
    if (result == null) {
      return _themeIdsFromTags(analysis);
    }

    final seen = <String>{};
    final ordered = <String>[];

    void add(Iterable<String> ids) {
      for (final id in ids) {
        if (seen.add(id)) ordered.add(id);
      }
    }

    add(result.topThemes.map((t) => t.themeId));
    for (final sectionId in ThaiMirrorSectionId.values) {
      final section = result.sectionById(sectionId);
      if (section == null) continue;
      add(section.supportingThemes.map((t) => t.themeId));
    }
    return ordered;
  }

  static List<String> _themeIdsFromTags(ThaiBetaAnalysis analysis) {
    final tags = analysis.consumerViewState?.hero.tags ?? const [];
    final out = <String>[];
    for (final tag in tags) {
      for (final entry in _tagToThemeId.entries) {
        if (entry.key == tag && !out.contains(entry.value)) {
          out.add(entry.value);
        }
      }
    }
    return out;
  }

  static int _profileSeed(ThaiBetaAnalysis analysis) {
    final hash = analysis.reportHash;
    if (hash != null && hash.length >= 8) {
      return int.parse(hash.substring(0, 8), radix: 16);
    }
    var seed = 0;
    final themeIds = _orderedThemeIds(analysis);
    for (var i = 0; i < themeIds.length; i++) {
      seed ^=
          ThaiBetaNarrativeStableHash.fnv1a32(themeIds[i]) * (i + 17);
    }
    return seed;
  }

  static const _tagToThemeId = <String, String>{
    'มุ่งมั่น': 'ambitious',
    'คิดละเอียด': 'analytical',
    'ลงมือทำ': 'practical',
    'อยากรู้': 'curious',
    'เอาใจใส่': 'protective',
    'มั่นคง': 'grounded',
    'ปรับตัวเก่ง': 'adaptable',
    'ชอบทำเอง': 'independent',
    'รับผิดชอบ': 'disciplined',
  };
}
