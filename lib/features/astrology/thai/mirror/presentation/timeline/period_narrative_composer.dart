import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

import '../copy/thai_mirror_evidence_composer.dart';
import 'life_map_plain_thai_renderer.dart';
import 'life_map_semantic_mapper.dart';
import 'life_map_verdict_semantics.dart';
import 'life_map_current_domain_composer.dart';
import 'life_period_domain_composer.dart';
import 'period_composite_score.dart';
import 'past_retrospective_composer.dart';
import 'thai_life_stage_context.dart';
import 'thai_mirror_life_timeline_state.dart';

/// Human narrative for one life period.
class PeriodNarrative {
  const PeriodNarrative({
    required this.summary,
    required this.whatChanges,
    required this.easier,
    required this.harder,
    required this.comparison,
    required this.evidenceLine,
    this.advice = '',
    this.stageLabel = '',
    this.semantics,
    this.lifeDomains = const [],
  });

  final String summary;

  /// Highlight / dominant situation detail (often empty in V1.3.0).
  final String whatChanges;

  /// Kept for compatibility; mirrors highlight-friendly wording.
  final String easier;

  /// Pressure / conflict slot.
  final String harder;

  /// Previous → current bridge (empty for first period).
  final String comparison;

  /// Soft evidence line (no engine keys).
  final String evidenceLine;

  /// Life impact / consequence.
  final String advice;

  /// Human life-stage label (presentation only).
  final String stageLabel;

  /// Structured claims for semantic tests (not shown as raw IDs in UI).
  final LifeMapVerdictSemantics? semantics;

  /// Current keeps the accepted V1.3.4 domain set. Thai Beta V3 additionally
  /// receives evidence-derived past/future domain blocks; the established
  /// standalone report decides whether to render them.
  final List<ThaiMirrorLifeDomainBlock> lifeDomains;
}

/// V1.3.0 — Period Narrative Composer (plain Thai life-situation verdicts).
abstract final class PeriodNarrativeComposer {
  static PeriodNarrative compose({
    required PeriodState period,
    required int narrativeAge,
    required PeriodScores scores,
    required LifePlanet? lagnaLord,
    required EvidenceProfile evidence,
    required List<String> topThemeTags,
    required int seed,
  }) {
    final data = LifePlanets.of(period.planet);
    final band = ThaiLifeStageContext.fromAge(narrativeAge);
    final s = seed.abs();
    final stageLabel = ThaiLifeStageContext.bandLabelTh(band);

    if (period.isPast) {
      final past = PastRetrospectiveComposer.composeStructured(
        band: band,
        data: data,
        scores: scores,
        seed: s,
        periodIndex: period.index,
      );
      final lifeDomains = LifePeriodDomainComposer.compose(
        semantics: past.semantics,
        scores: scores,
        data: data,
      );
      return PeriodNarrative(
        summary: past.text,
        whatChanges: '',
        easier: '',
        harder: '',
        comparison: '',
        evidenceLine: '',
        advice: '',
        stageLabel: stageLabel,
        semantics: past.semantics,
        lifeDomains: lifeDomains,
      );
    }

    final tense = period.isCurrent
        ? LifeMapVerdictTense.current
        : LifeMapVerdictTense.future;
    final semantics = LifeMapSemanticMapper.build(
      tense: tense,
      band: band,
      data: data,
      scores: scores,
      seed: s,
    );
    final rendered = LifeMapPlainThaiRenderer.renderPresentFuture(semantics);

    final comparison = period.isCurrent ? _comparison(period, band, s) : '';
    final evidenceLine = period.isCurrent
        ? _evidenceLine(period, lagnaLord, evidence, topThemeTags, seed, band)
        : '';

    // V1.3.4: Current UI keeps its accepted four-domain composition. Thai Beta
    // V3 adds a separate work/money/love/health set for future periods.
    final lifeDomains = period.isCurrent
        ? LifeMapCurrentDomainComposer.compose(
            semantics: semantics,
            scores: scores,
            data: data,
            comparison: comparison,
            seed: s,
          )
        : LifePeriodDomainComposer.compose(
            semantics: semantics,
            scores: scores,
            data: data,
          );

    return PeriodNarrative(
      summary: rendered.summary,
      whatChanges: rendered.whatChanges,
      easier: rendered.whatChanges,
      harder: rendered.harder,
      comparison: comparison,
      evidenceLine: evidenceLine,
      advice: rendered.advice,
      stageLabel: stageLabel,
      semantics: semantics,
      lifeDomains: lifeDomains,
    );
  }

  static String _comparison(
    PeriodState period,
    ThaiLifeStageBand band,
    int seed,
  ) {
    final prev = period.previousPlanet;
    if (prev == null) return '';
    final p = LifePlanets.of(prev);
    final current = LifePlanets.of(period.planet);
    final frames = ThaiLifeStageContext.isChildOriented(band)
        ? [
            'ก่อนหน้านี้เน้นเรื่อง${p.keyword} ตอนนี้เรื่อง${current.keyword}มาก่อน',
            'จาก${p.phaseName}มาสู่${current.phaseName} โฟกัสย้ายจาก${p.keyword}ไป${current.keyword}',
          ]
        : [
            'ก่อนหน้านี้เน้นเรื่อง${p.keyword} ตอนนี้เรื่อง${current.keyword}มาก่อนในการตัดสินใจ',
            'จาก${p.phaseName}สู่${current.phaseName} โฟกัสย้ายจาก${p.keyword}ไป${current.keyword}',
          ];
    return frames[seed.abs() % frames.length];
  }

  static const _relationTails = <PlanetRelation, List<String>>{
    PlanetRelation.friend: [
      'จุดเด่นข้อนี้ช่วยให้เดินหน้าได้',
      'จุดเด่นข้อนี้ช่วยจัดการหน้าที่ในช่วงนี้ได้ชัดขึ้น',
    ],
    PlanetRelation.enemy: [
      'จุดเด่นข้อนี้ออกแรงกับตัวเองมากขึ้น',
      'ช่วงนี้ออกแรงกับตัวเองมากขึ้น และผลวัดได้ชัด',
    ],
    PlanetRelation.neutral: [
      'จุดเด่นข้อนี้เปิดทางให้เลือกได้ว่าจะใช้อย่างไร',
      'ผลชัดขึ้นเมื่อนำจุดเด่นข้อนี้มาใช้จริง',
    ],
  };

  static String _evidenceLine(
    PeriodState period,
    LifePlanet? lagnaLord,
    EvidenceProfile evidence,
    List<String> topThemeTags,
    int seed,
    ThaiLifeStageBand band,
  ) {
    final relation = lagnaLord == null
        ? PlanetRelation.neutral
        : PlanetRelationshipMatrix.relation(period.planet, lagnaLord);
    final relationTail =
        _relationTails[relation]![(seed.abs() ~/ 3) %
            _relationTails[relation]!.length];
    final tags = topThemeTags
        .where((t) => t.trim().isNotEmpty)
        .take(2)
        .join(' · ');
    if (tags.isEmpty) return relationTail;
    return 'จุดที่สอดคล้องกับตัวคุณคือ$tags — $relationTail';
  }
}
