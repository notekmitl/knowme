import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_semantic_mapper.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// V1.2.9 Past Verdict — life-situation claims from period evidence.
///
/// Renders situation → domain impact → consequence. Does not invent Canon
/// events or use meta-language as the prophecy body.
abstract final class PastRetrospectiveComposer {
  static String compose({
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required PeriodScores scores,
    required int seed,
    required int periodIndex,
  }) {
    final payload = composeStructured(
      band: band,
      data: data,
      scores: scores,
      seed: seed,
      periodIndex: periodIndex,
    );
    return payload.text;
  }

  static ({String text, LifeMapVerdictSemantics semantics}) composeStructured({
    required ThaiLifeStageBand band,
    required LifePlanetData data,
    required PeriodScores scores,
    required int seed,
    required int periodIndex,
  }) {
    final s = seed.abs() + periodIndex * 17;
    final semantics = LifeMapSemanticMapper.build(
      tense: LifeMapVerdictTense.past,
      band: band,
      data: data,
      scores: scores,
      seed: s,
    );
    final primary = semantics.primary;
    final secondary = semantics.secondary;
    final pressure = semantics.pressure;
    final consequence = semantics.consequence ?? primary;

    final opening =
        '${primary.situationTh} ผลกระทบหลักอยู่ที่${primary.domain.labelTh}';
    final middle = secondary == null
        ? (pressure?.pressureTh ??
              'คุณต้องรับการเปลี่ยนแปลงด้าน${primary.domain.labelTh}ภายใต้ข้อจำกัดที่มีจริง')
        : '${secondary.situationTh} ควบคู่กับด้าน${secondary.domain.labelTh}';
    final closing = consequence.consequenceTh;

    final text = _fitWordBudget('$opening\n\n$middle\n\n$closing');
    return (text: text, semantics: semantics);
  }

  static int approxWordCount(String text) {
    final chars = text.replaceAll(RegExp(r'\s+'), '').runes.length;
    if (chars == 0) return 0;
    return (chars / 2.5).round();
  }

  static bool containsRetrospectivePrompt(String text) =>
      LifeMapVerdictCopy.containsBannedCoaching(text);

  static String _fitWordBudget(String text) {
    var words = approxWordCount(text);
    if (words >= 70 && words <= 170) return text;
    if (words < 70) {
      final pad =
          'การเลือกในช่วงนั้นเปลี่ยนวิธีจัดชีวิตต่อจากนี้ และผลวัดได้จากหน้าที่ที่รับจริง';
      final denser = '$text\n\n$pad';
      if (approxWordCount(denser) <= 170) return denser;
    }
    final parts = text.split('\n\n');
    if (parts.length >= 3 && words > 170) {
      final trimmed = '${parts[0]}\n\n${parts[2]}';
      if (approxWordCount(trimmed) >= 70) return trimmed;
    }
    return text;
  }
}
