import 'dart:convert';
import 'dart:io';

import 'chinese_zodiac_impact_runner.dart';

/// Aggregated audit output for Chinese Zodiac Impact Validation V1.
class ChineseZodiacImpactAudit {
  const ChineseZodiacImpactAudit({
    required this.profileCount,
    required this.comparisons,
    required this.aggregateBefore,
    required this.aggregateAfter,
    required this.highValueAnimals,
    required this.lowValueAnimals,
    required this.themeCollisions,
    required this.narrativeImpactSummary,
    required this.duplicationAnalysis,
    required this.recommendation,
  });

  final int profileCount;
  final List<ChineseZodiacProfileComparison> comparisons;
  final Map<String, num> aggregateBefore;
  final Map<String, num> aggregateAfter;
  final List<String> highValueAnimals;
  final List<String> lowValueAnimals;
  final Map<String, int> themeCollisions;
  final String narrativeImpactSummary;
  final String duplicationAnalysis;
  final String recommendation;

  Map<String, dynamic> toJson() {
    return {
      'profileCount': profileCount,
      'methodology': ChineseZodiacImpactReport.methodology,
      'productionScopeNote': ChineseZodiacImpactReport.productionScopeNote,
      'aggregateBefore': aggregateBefore,
      'aggregateAfter': aggregateAfter,
      'aggregateDeltas': _deltas(aggregateBefore, aggregateAfter),
      'highValueAnimals': highValueAnimals,
      'lowValueAnimals': lowValueAnimals,
      'themeCollisions': themeCollisions,
      'narrativeImpactSummary': narrativeImpactSummary,
      'duplicationAnalysis': duplicationAnalysis,
      'recommendation': recommendation,
      'profiles': comparisons.map((item) => item.toJson()).toList(),
    };
  }

  static Map<String, num> _deltas(
    Map<String, num> before,
    Map<String, num> after,
  ) {
    return {
      for (final key in before.keys) key: (after[key] ?? 0) - (before[key] ?? 0),
    };
  }
}

abstract final class ChineseZodiacImpactReport {
  static const methodology = '''
Controlled A/B comparison per profile:
A) BaZi core only (Day Master + Dominant Element + Element Balance)
B) BaZi core + Chinese Zodiac Year Animal (runtime integration path)

Each arm runs through:
1. Lens theme outputs (Western baseline + BaZi arm)
2. Astrology Fusion Generator (cross-lens agreements/tensions/signals)
3. Simulated downstream pipeline (validation-only lens→mirror bridge):
   Global Fusion Foundation → Human Model → Human Pattern → Narrative Runtime

Fixed Western chart (Aries/Cancer/Leo) and fixed overlapping personality mirror
(MBTI + Big Five with expressive/driven/supportive themes) hold non-BaZi inputs
constant so deltas isolate Year Animal impact.
''';

  static const productionScopeNote = '''
Production KnowMeRuntimePipeline currently feeds Thai astrology into Mirror Platform;
BaZi Zodiac integrates at BaziRealAdapter → AstrologyFusionGenerator today.
Downstream Mirror→Global Fusion→Human Model→Narrative metrics use a validation-only
bridge that maps BaZi fusion themes into MV1 signals without modifying frozen systems.
''';

  static ChineseZodiacImpactAudit build(
    List<ChineseZodiacProfileComparison> comparisons,
  ) {
    final before = _aggregate(comparisons, (item) => item.withoutZodiac);
    final after = _aggregate(comparisons, (item) => item.withZodiac);

    final animalScores = <String, _AnimalScore>{};
    for (final comparison in comparisons) {
      final score = animalScores.putIfAbsent(
        comparison.profile.animalKey,
        () => _AnimalScore(comparison.profile.animalEn),
      );
      score.add(comparison);
    }
    for (final score in animalScores.values) {
      score.finalizeScore();
    }

    final ranked = animalScores.values.toList()
      ..sort((a, b) => b.valueScore.compareTo(a.valueScore));

    final highValue = ranked
        .where((item) => item.valueScore > 0)
        .take(4)
        .map((item) => '${item.animalEn} (${item.animalKey})')
        .toList();

    final lowValue = _lowValueAnimals(comparisons);

    final collisions = <String, int>{};
    for (final comparison in comparisons) {
      for (final themeId in comparison.qualitative.collisionThemeIds) {
        collisions[themeId] = (collisions[themeId] ?? 0) + 1;
      }
    }
    final sortedCollisions = Map.fromEntries(
      collisions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return ChineseZodiacImpactAudit(
      profileCount: comparisons.length,
      comparisons: comparisons,
      aggregateBefore: before,
      aggregateAfter: after,
      highValueAnimals: highValue,
      lowValueAnimals: lowValue,
      themeCollisions: sortedCollisions,
      narrativeImpactSummary: _narrativeImpact(comparisons),
      duplicationAnalysis: _duplicationAnalysis(comparisons, sortedCollisions),
      recommendation: _recommendation(comparisons, before, after, ranked),
    );
  }

  static Map<String, num> _aggregate(
    List<ChineseZodiacProfileComparison> comparisons,
    ChineseZodiacImpactMetrics Function(ChineseZodiacProfileComparison) pick,
  ) {
    num sum(num Function(ChineseZodiacImpactMetrics) field) {
      return comparisons.fold<num>(
        0,
        (total, item) => total + field(pick(item)),
      );
    }

    num avg(num Function(ChineseZodiacImpactMetrics) field) {
      if (comparisons.isEmpty) return 0;
      return sum(field) / comparisons.length;
    }

    final metrics = comparisons.map(pick).toList();
    return {
      'themeCountTotal': sum((m) => m.themeCount),
      'themeCountAvg': avg((m) => m.themeCount),
      'fusionAgreementsTotal': sum((m) => m.fusionAgreements),
      'fusionAgreementsAvg': avg((m) => m.fusionAgreements),
      'fusionTensionsTotal': sum((m) => m.fusionTensions),
      'fusionTensionsAvg': avg((m) => m.fusionTensions),
      'fusionSignalsTotal': sum((m) => m.fusionSignals),
      'fusionSignalsAvg': avg((m) => m.fusionSignals),
      'globalAgreementsTotal': sum((m) => m.globalAgreements),
      'globalAgreementsAvg': avg((m) => m.globalAgreements),
      'globalTensionsTotal': sum((m) => m.globalTensions),
      'globalTensionsAvg': avg((m) => m.globalTensions),
      'globalReinforcementsTotal': sum((m) => m.globalReinforcements),
      'globalReinforcementsAvg': avg((m) => m.globalReinforcements),
      'globalBlindSpotsTotal': sum((m) => m.globalBlindSpots),
      'globalBlindSpotsAvg': avg((m) => m.globalBlindSpots),
      'humanPatternCountTotal': sum((m) => m.humanPatternCount),
      'humanPatternCountAvg': avg((m) => m.humanPatternCount),
      'humanActivationCountTotal': sum((m) => m.humanActivationCount),
      'humanActivationCountAvg': avg((m) => m.humanActivationCount),
      'narrativeParagraphCountTotal': sum((m) => m.narrativeParagraphCount),
      'narrativeParagraphCountAvg': avg((m) => m.narrativeParagraphCount),
      'narrativeEvidenceCountTotal': sum((m) => m.narrativeEvidenceCount),
      'narrativeEvidenceCountAvg': avg((m) => m.narrativeEvidenceCount),
      'narrativeConfidenceAvg': metrics.isEmpty
          ? 0
          : metrics.fold<double>(
                0,
                (total, item) => total + item.narrativeConfidenceComposite,
              ) /
              metrics.length,
    };
  }

  static String _narrativeImpact(
    List<ChineseZodiacProfileComparison> comparisons,
  ) {
    final richer = comparisons
        .where(
          (item) =>
              item.narrativeParagraphDelta > 0 &&
              item.narrativeEvidenceDelta > 0,
        )
        .length;
    final longerOnly = comparisons
        .where(
          (item) =>
              item.narrativeParagraphDelta > 0 &&
              item.narrativeEvidenceDelta <= 0,
        )
        .length;
    final unchanged = comparisons
        .where((item) => item.narrativeParagraphDelta == 0)
        .length;

    return 'Of ${comparisons.length} profiles: $richer gained paragraphs with '
        'evidence anchors; $longerOnly grew longer without new evidence; '
        '$unchanged unchanged at narrative layer.';
  }

  static String _duplicationAnalysis(
    List<ChineseZodiacProfileComparison> comparisons,
    Map<String, int> collisions,
  ) {
    final totalCollisions = comparisons.fold<int>(
      0,
      (sum, item) => sum + item.qualitative.duplicatedInformationCount,
    );
    final totalNetNew = comparisons.fold<int>(
      0,
      (sum, item) => sum + item.qualitative.newInformationCount,
    );
    final topCollision = collisions.entries.take(5).map(
          (entry) => '${entry.key} (${entry.value} profiles)',
        );

    return 'Across all profiles: $totalNetNew net-new zodiac theme slots vs '
        '$totalCollisions theme collisions with BaZi core. '
        'Most repeated collisions: ${topCollision.join(', ')}.';
  }

  static String _recommendation(
    List<ChineseZodiacProfileComparison> comparisons,
    Map<String, num> before,
    Map<String, num> after,
    List<_AnimalScore> ranked,
  ) {
    final themeDelta =
        (after['themeCountAvg'] ?? 0) - (before['themeCountAvg'] ?? 0);
    final activationDelta = (after['humanActivationCountAvg'] ?? 0) -
        (before['humanActivationCountAvg'] ?? 0);
    final narrativeDelta = (after['narrativeParagraphCountAvg'] ?? 0) -
        (before['narrativeParagraphCountAvg'] ?? 0);
    final tensionDelta =
        (after['fusionTensionsAvg'] ?? 0) - (before['fusionTensionsAvg'] ?? 0);
    final highTier = comparisons
        .where(
          (item) =>
              item.qualitative.tier == ChineseZodiacQualitativeTier.high ||
              item.qualitative.tier == ChineseZodiacQualitativeTier.medium,
        )
        .length;

    if (themeDelta >= 3 &&
        activationDelta > 0 &&
        narrativeDelta > 0 &&
        tensionDelta <= 2) {
      return 'KEEP AND PROMOTE: Zodiac adds measurable fusion and downstream '
          'richness ($highTier/${comparisons.length} profiles MEDIUM+ impact) '
          'without material tension inflation. Prioritize wiring BaZi zodiac '
          'into production Mirror path so live users receive Human Pattern and '
          'Narrative gains.';
    }

    if (themeDelta >= 2 && activationDelta == 0) {
      return 'PARTIAL VALUE: Zodiac enriches Astrology Fusion themes '
          '(+${themeDelta.toStringAsFixed(1)} avg) but downstream Human Pattern '
          'and Narrative remain flat until BaZi themes reach Mirror Platform. '
          'Complete Mirror integration before user-facing narrative claims.';
    }

    if (tensionDelta > 2) {
      return 'CALIBRATE: Zodiac increases cross-lens tension disproportionately. '
          'Review bridge weight tiers and collision-prone themes before expansion.';
    }

    return 'MONITOR: Mixed signal — fusion layer benefits are present but '
        'downstream narrative impact is limited in current architecture. '
        'Top animals: ${ranked.take(3).map((a) => a.animalEn).join(', ')}.';
  }

  static void writeArtifacts({
    required ChineseZodiacImpactAudit audit,
    required String jsonPath,
    required String markdownPath,
  }) {
    final jsonFile = File(jsonPath);
    jsonFile.parent.createSync(recursive: true);
    jsonFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(audit.toJson()),
    );

    final mdFile = File(markdownPath);
    mdFile.parent.createSync(recursive: true);
    mdFile.writeAsStringSync(_markdown(audit));
  }

  static List<String> _lowValueAnimals(
    List<ChineseZodiacProfileComparison> comparisons,
  ) {
    final byAnimal = <String, List<ChineseZodiacProfileComparison>>{};
    for (final comparison in comparisons) {
      byAnimal.putIfAbsent(comparison.profile.animalKey, () => []).add(comparison);
    }

    final scored = byAnimal.entries.map((entry) {
      final avgThemeDelta = entry.value.fold<double>(
            0,
            (sum, item) => sum + item.themeCountDelta,
          ) /
          entry.value.length;
      final avgNarrativeDelta = entry.value.fold<double>(
            0,
            (sum, item) => sum + item.narrativeParagraphDelta,
          ) /
          entry.value.length;
      final lowTierCount = entry.value
          .where(
            (item) =>
                item.qualitative.tier == ChineseZodiacQualitativeTier.low ||
                item.qualitative.tier == ChineseZodiacQualitativeTier.none,
          )
          .length;
      return (
        key: entry.key,
        en: entry.value.first.profile.animalEn,
        score: avgThemeDelta + avgNarrativeDelta - lowTierCount,
      );
    }).toList()
      ..sort((a, b) => a.score.compareTo(b.score));

    return scored
        .take(4)
        .map((item) => '${item.en} (${item.key})')
        .toList();
  }

  static String _markdown(ChineseZodiacImpactAudit audit) {
    final before = audit.aggregateBefore;
    final after = audit.aggregateAfter;
    final buffer = StringBuffer();

    buffer.writeln('# Chinese Zodiac Impact Validation V1');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln('Profiles: ${audit.profileCount}');
    buffer.writeln();
    buffer.writeln('## Validation Methodology');
    buffer.writeln(ChineseZodiacImpactReport.methodology);
    buffer.writeln('### Production Scope Note');
    buffer.writeln(ChineseZodiacImpactReport.productionScopeNote);
    buffer.writeln();

    buffer.writeln('## Before vs After Metrics (Aggregate)');
    buffer.writeln('| Metric | Before (Core) | After (+Zodiac) | Delta |');
    buffer.writeln('| --- | ---: | ---: | ---: |');
    for (final key in before.keys) {
      final b = before[key] ?? 0;
      final a = after[key] ?? 0;
      final delta = a - b;
      buffer.writeln(
        '| $key | ${_fmt(b)} | ${_fmt(a)} | ${_fmt(delta)} |',
      );
    }
    buffer.writeln();

    buffer.writeln('## High-Value Animals');
    for (final animal in audit.highValueAnimals) {
      buffer.writeln('- $animal');
    }
    buffer.writeln();

    buffer.writeln('## Low-Value Animals');
    for (final animal in audit.lowValueAnimals) {
      buffer.writeln('- $animal');
    }
    buffer.writeln();

    buffer.writeln('## Theme Collisions');
    for (final entry in audit.themeCollisions.entries.take(12)) {
      buffer.writeln('- `${entry.key}` — ${entry.value} profiles');
    }
    buffer.writeln();

    buffer.writeln('## Narrative Impact');
    buffer.writeln(audit.narrativeImpactSummary);
    buffer.writeln();

    buffer.writeln('## Duplication Analysis');
    buffer.writeln(audit.duplicationAnalysis);
    buffer.writeln();

    buffer.writeln('## Per-Profile Summary');
    buffer.writeln('| Profile | Animal | Tier | Theme Δ | Pattern Δ | Narrative Δ |');
    buffer.writeln('| --- | --- | --- | ---: | ---: | ---: |');
    for (final item in audit.comparisons) {
      buffer.writeln(
        '| ${item.profile.profileId} | ${item.profile.animalEn} '
        '| ${item.qualitative.tier.label} '
        '| ${item.themeCountDelta} '
        '| ${item.patternCountDelta} '
        '| ${item.narrativeParagraphDelta} |',
      );
    }
    buffer.writeln();

    buffer.writeln('## Recommendation');
    buffer.writeln(audit.recommendation);
    buffer.writeln();

    return buffer.toString();
  }

  static String _fmt(num value) {
    if (value is int || value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class _AnimalScore {
  _AnimalScore(this.animalEn);

  final String animalEn;
  String animalKey = '';
  var valueScore = 0.0;
  var avgTier = ChineseZodiacQualitativeTier.none;
  var samples = 0;
  var tierSum = 0;

  void add(ChineseZodiacProfileComparison comparison) {
    animalKey = comparison.profile.animalKey;
    samples++;
    tierSum += comparison.qualitative.tier.index;
    valueScore += comparison.themeCountDelta +
        comparison.activationCountDelta +
        comparison.narrativeParagraphDelta +
        comparison.globalAgreementDelta -
        comparison.qualitative.duplicatedInformationCount * 0.5;
  }

  void finalizeScore() {
    if (samples == 0) return;
    final avgIndex = tierSum / samples;
    avgTier = ChineseZodiacQualitativeTier.values[avgIndex.round().clamp(0, 3)];
  }
}
