import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/human_pattern/domain/pattern_evidence.dart';

import '../domain/narrative_mode.dart';
import 'narrative_insight_plan.dart';

/// Lineage composition profile for one insight plan.
class NarrativeEvidenceLineageProfile {
  const NarrativeEvidenceLineageProfile({
    required this.lineageFingerprint,
    required this.evidenceBranchKey,
    required this.mirrorComposition,
    required this.fusionComposition,
    required this.densityTier,
    required this.confidenceTier,
    required this.sourceDiversityScore,
  });

  final String lineageFingerprint;
  final String evidenceBranchKey;
  final String mirrorComposition;
  final String fusionComposition;
  final String densityTier;
  final String confidenceTier;
  final double sourceDiversityScore;
}

/// Deterministic evidence branching for Narrative Intelligence V5.
abstract final class NarrativeEvidenceBrancher {
  static NarrativeInsightPlan enrich(NarrativeInsightPlan plan) {
    final profile = analyze(plan.evidenceRows);
    return NarrativeInsightPlan(
      mode: plan.mode,
      interactionType: plan.interactionType,
      interactionThemeKey: plan.interactionThemeKey,
      primaryActivation: plan.primaryActivation,
      contributingActivations: plan.contributingActivations,
      evidenceRows: orderEvidenceRows(plan.evidenceRows, profile),
      primaryTier: plan.primaryTier,
      evidenceBranchKey: profile.evidenceBranchKey,
      lineageFingerprint: profile.lineageFingerprint,
    );
  }

  static List<NarrativeInsightPlan> enrichAll(List<NarrativeInsightPlan> plans) {
    return plans.map(enrich).toList(growable: false);
  }

  static NarrativeEvidenceLineageProfile analyze(List<PatternEvidence> rows) {
    if (rows.isEmpty) {
      return const NarrativeEvidenceLineageProfile(
        lineageFingerprint: '',
        evidenceBranchKey: 'empty',
        mirrorComposition: 'none',
        fusionComposition: 'none',
        densityTier: 'none',
        confidenceTier: 'none',
        sourceDiversityScore: 0,
      );
    }

    final mirrorWeights = <String, double>{};
    final systems = <String>{};
    final mirrorKeys = <String>{};
    final fusionFindings = <String>{};
    final themeIds = <String>{};
    var weightSum = 0.0;

    for (final row in rows) {
      mirrorWeights[row.mirrorRoleId] =
          (mirrorWeights[row.mirrorRoleId] ?? 0) + row.weight;
      systems.add(row.systemId);
      mirrorKeys.add(row.mirrorKey);
      fusionFindings.add(row.fusionFindingId);
      themeIds.addAll(row.themeIds);
      weightSum += row.weight;
    }

    final astrologyWeight =
        mirrorWeights[GlobalFusionMirrorRoles.astrology] ?? 0;
    final personalityWeight =
        mirrorWeights[GlobalFusionMirrorRoles.personality] ?? 0;
    final mirrorComposition = _mirrorComposition(
      astrologyWeight: astrologyWeight,
      personalityWeight: personalityWeight,
    );

    final fusionComposition = switch (fusionFindings.length) {
      >= 4 => 'fusion_dense',
      >= 2 => 'fusion_moderate',
      _ => 'fusion_sparse',
    };

    final densityTier = switch (rows.length) {
      >= 5 => 'density_high',
      >= 3 => 'density_moderate',
      _ => 'density_low',
    };

    final avgWeight = weightSum / rows.length;
    final confidenceTier = switch (avgWeight) {
      >= 0.55 => 'confidence_high',
      >= 0.35 => 'confidence_moderate',
      _ => 'confidence_low',
    };

    final sourceDiversityScore = ((systems.length +
                mirrorKeys.length +
                themeIds.length / 2) /
            12)
        .clamp(0.0, 1.0);

    final lineageFingerprint = _lineageFingerprint(rows);
    final evidenceBranchKey =
        '$mirrorComposition|$fusionComposition|$densityTier|$confidenceTier';

    return NarrativeEvidenceLineageProfile(
      lineageFingerprint: lineageFingerprint,
      evidenceBranchKey: evidenceBranchKey,
      mirrorComposition: mirrorComposition,
      fusionComposition: fusionComposition,
      densityTier: densityTier,
      confidenceTier: confidenceTier,
      sourceDiversityScore: sourceDiversityScore,
    );
  }

  static String lineageFingerprintForRows(List<PatternEvidence> rows) {
    return analyze(rows).lineageFingerprint;
  }

  static String evidenceFingerprintForPlans(List<NarrativeInsightPlan> plans) {
    final parts = plans
        .map(
          (plan) =>
              '${plan.mode.key}:${plan.evidenceBranchKey}:${plan.lineageFingerprint}',
        )
        .toList()
      ..sort();
    return parts.join('|');
  }

  static List<PatternEvidence> orderEvidenceRows(
    List<PatternEvidence> rows,
    NarrativeEvidenceLineageProfile profile,
  ) {
    if (rows.length <= 1) return rows;

    final sorted = List<PatternEvidence>.from(rows)
      ..sort((a, b) {
        final scoreA = _rowAnchorScore(a, profile);
        final scoreB = _rowAnchorScore(b, profile);
        final compare = scoreB.compareTo(scoreA);
        if (compare != 0) return compare;
        return a.fusionFindingId.compareTo(b.fusionFindingId);
      });
    return List.unmodifiable(sorted);
  }

  static String applyLineageModifier({
    required String baseText,
    required NarrativeEvidenceLineageProfile profile,
    required NarrativeMode mode,
    required String patternId,
  }) {
    if (baseText.trim().isEmpty || profile.lineageFingerprint.isEmpty) {
      return baseText;
    }

    final hash = _hash('${profile.lineageFingerprint}|$patternId|${mode.key}');
    final sourceClause = _sourceClause(profile, hash);
    final fusionClause = _fusionClause(profile, hash);
    final anchorClause = _anchorClause(profile, hash, mode);

    return switch (hash % 5) {
      0 => '$baseText — $sourceClause',
      1 => '$baseText — $fusionClause',
      2 => '$baseText — $sourceClause $fusionClause',
      3 => '$baseText — $anchorClause',
      _ => '$baseText — $fusionClause $anchorClause',
    };
  }

  static String _mirrorComposition({
    required double astrologyWeight,
    required double personalityWeight,
  }) {
    if (astrologyWeight <= 0 && personalityWeight <= 0) return 'mirror_unknown';
    if (astrologyWeight <= 0) return 'personality_primary';
    if (personalityWeight <= 0) return 'astrology_primary';
    final total = astrologyWeight + personalityWeight;
    final astrologyShare = astrologyWeight / total;
    if (astrologyShare >= 0.62) return 'astrology_primary';
    if (astrologyShare <= 0.38) return 'personality_primary';
    return 'cross_mirror_balanced';
  }

  static double _rowAnchorScore(
    PatternEvidence row,
    NarrativeEvidenceLineageProfile profile,
  ) {
    var score = row.weight;
    if (profile.mirrorComposition == 'astrology_primary' &&
        row.mirrorRoleId == GlobalFusionMirrorRoles.astrology) {
      score += 0.12;
    }
    if (profile.mirrorComposition == 'personality_primary' &&
        row.mirrorRoleId == GlobalFusionMirrorRoles.personality) {
      score += 0.12;
    }
    if (profile.mirrorComposition == 'cross_mirror_balanced') {
      score += 0.04;
    }
    score += row.themeIds.length * 0.02;
    return score;
  }

  static String _lineageFingerprint(List<PatternEvidence> rows) {
    final parts = rows
        .map(
          (row) =>
              '${row.mirrorRoleId}:${row.systemId}:${row.mirrorKey}:${row.fusionFindingId}:${row.sourceThemeId}',
        )
        .toList()
      ..sort();
    return parts.join('|');
  }

  static String _sourceClause(NarrativeEvidenceLineageProfile profile, int hash) {
    final variants = switch (profile.mirrorComposition) {
      'astrology_primary' => const [
          'สัญญาณนี้ได้รับการยืนยันจากดวงชะตาและโหราศาสตร์ไทยเป็นหลัก',
          'แนวโน้มนี้สะท้อนจากภาพรวมดวงชะตามากกว่าแหล่งอื่น',
          'จุดนี้มีรากฐานจากการตีความดวงชะตาอย่างชัดเจน',
        ],
      'personality_primary' => const [
          'สัญญาณนี้ได้รับการยืนยันจากโปรไฟล์บุคลิกภาพเป็นหลัก',
          'แนวโน้มนี้สะท้อนจาก Big Five และมิติบุคลิกภาพมากกว่าแหล่งอื่น',
          'จุดนี้มีรากฐานจากการมองบุคลิกภาพอย่างชัดเจน',
        ],
      'cross_mirror_balanced' => const [
          'ทั้งดวงชะตาและบุคลิกภาพชี้ไปทางเดียวกันในแนวนี้',
          'สองแหล่งหลักของคุณสนับสนุนสัญญาณนี้ร่วมกัน',
          'การมองจากโหราศาสตร์และบุคลิกภาพสอดคล้องกันที่จุดนี้',
        ],
      _ => const [
          'สัญญาณนี้มีแหล่งที่มาชัดจากข้อมูลที่ระบบประมวลผล',
          'จุดนี้ได้รับการสนับสนุนจากหลักฐานที่ระบบรวบรวมไว้',
        ],
    };
    return variants[hash % variants.length];
  }

  static String _fusionClause(NarrativeEvidenceLineageProfile profile, int hash) {
    final variants = switch (profile.fusionComposition) {
      'fusion_dense' => const [
          'หลายจุดยืนยันใน Global Fusion ชี้มาที่แนวนี้',
          'การสังเคราะห์ข้ามมิติหลายจุดสนับสนุนภาพนี้',
          'สัญญาณนี้ปรากฏซ้ำในหลาย finding ของ fusion',
        ],
      'fusion_moderate' => const [
          'มีการยืนยันร่วมจากมากกว่าหนึ่ง finding ใน fusion',
          'ข้อมูล fusion หลายจุดสอดคล้องกับแนวนี้',
        ],
      _ => const [
          'สัญญาณนี้มาจาก finding หลักที่ชัดใน fusion',
          'จุดนี้ยึดจากหลักฐาน fusion ที่เด่นที่สุด',
        ],
    };
    return variants[hash % variants.length];
  }

  static String _anchorClause(
    NarrativeEvidenceLineageProfile profile,
    int hash,
    NarrativeMode mode,
  ) {
    final modeVariants = switch (mode) {
      NarrativeMode.identity => const [
          'ตัวตนที่เห็นได้สะท้อนจากแหล่งหลักของคุณ',
          'ภาพตัวตนนี้เชื่อมกับหลักฐานที่คุณยึดมั่น',
        ],
      NarrativeMode.relationship => const [
          'แนวความสัมพันธ์นี้สะท้อนจากหลักฐานที่คุณใช้จริง',
          'วิธีเชื่อมต่อของคุณมีรากฐานจากแหล่งที่มาชัด',
        ],
      NarrativeMode.decision => const [
          'วิธีตัดสินใจนี้มีหลักฐานสนับสนุนจากแหล่งหลัก',
          'การเลือกของคุณสะท้อนจากข้อมูลที่ระบบเห็นชัด',
        ],
      NarrativeMode.growth => const [
          'เส้นทางเติบโตนี้สะท้อนจากหลักฐานที่สะสมในระบบ',
          'การพัฒนาของคุณมีรากฐานจากแหล่งที่ระบบยืนยัน',
        ],
    };

    final densitySuffix = switch (profile.densityTier) {
      'density_high' => ' (หลักฐานหนาแน่น)',
      'density_low' => ' (หลักฐานเฉพาะจุด)',
      _ => '',
    };

    final clause = modeVariants[(hash + mode.index) % modeVariants.length];
    return '$clause$densitySuffix';
  }

  static int _hash(String seed) {
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }
}
