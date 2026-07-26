import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'life_map_plain_thai_renderer.dart';
import 'life_map_semantic_mapper.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'thai_life_stage_context.dart';

/// V1.3.0 Past Verdict — plain Thai life story from period evidence.
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
    final text = LifeMapPlainThaiRenderer.renderPastBody(semantics);
    return (text: text, semantics: semantics);
  }

  static int approxWordCount(String text) {
    final chars = text.replaceAll(RegExp(r'\s+'), '').runes.length;
    if (chars == 0) return 0;
    return (chars / 2.5).round();
  }

  static bool containsRetrospectivePrompt(String text) =>
      LifeMapVerdictCopy.containsBannedCoaching(text);
}
