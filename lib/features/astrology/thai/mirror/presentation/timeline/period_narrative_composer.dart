import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';

import '../copy/thai_mirror_evidence_composer.dart';
import 'life_map_semantic_mapper.dart';
import 'life_map_verdict_semantics.dart';
import 'period_composite_score.dart';
import 'past_retrospective_composer.dart';
import 'thai_life_stage_context.dart';

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
  });

  final String summary;

  /// Highlight / dominant situation detail.
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
}

/// V1.2.9 — Period Narrative Composer (semantic life-situation verdicts).
///
/// Uses engine scores/signals only. Does not change calculation or Canon.
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
    final primary = semantics.primary;
    final pressure = semantics.pressure ?? primary;
    final consequence = semantics.consequence ?? primary;

    // Keep slots semantically distinct; drop paraphrase copies.
    final highlight = primary.situationTh.contains(primary.domain.labelTh)
        ? primary.situationTh
        : '${primary.situationTh} โดยกระทบ${primary.domain.labelTh}โดยตรง';
    var harder = pressure.pressureTh;
    if (harder == highlight || pressure.semanticKey == primary.semanticKey) {
      harder =
          'แรงกดดันหลักอยู่ที่${pressure.domain.labelTh}ที่รับไว้พร้อมกันจนเลือกไม่ได้ทุกทาง';
    }
    var advice = consequence.consequenceTh;
    if (advice == highlight || advice == harder) {
      advice =
          'ผลต่อชีวิตคือทิศทางด้าน${primary.domain.labelTh}ถูกกำหนดจากการเลือกในช่วงนี้';
    }

    final comparison = period.isCurrent ? _comparison(period, band, s) : '';
    final evidenceLine = period.isCurrent
        ? _evidenceLine(period, lagnaLord, evidence, topThemeTags, seed, band)
        : '';

    return PeriodNarrative(
      summary: highlight,
      whatChanges:
          'ด้านที่ได้รับผลชัดคือ${primary.domain.labelTh} '
          'และถูกบังคับให้จัดการก่อนเรื่องรอง',
      easier:
          'ด้านที่ได้รับผลชัดคือ${primary.domain.labelTh} '
          'และถูกบังคับให้จัดการก่อนเรื่องรอง',
      harder: harder,
      comparison: comparison,
      evidenceLine: evidenceLine,
      advice: advice,
      stageLabel: stageLabel,
      semantics: semantics,
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
            'เทียบกับช่วงก่อนที่เน้น${p.keyword} ช่วงนี้ผลักเรื่อง${current.keyword}ให้เป็นหน้าที่ที่ต้องจัดการในชีวิตประจำวัน',
            'จากช่วง${p.phaseName} มาสู่${current.phaseName} เด็กต้องรับการเปลี่ยนจาก${p.keyword}ไปสู่${current.keyword}',
          ]
        : [
            'เทียบกับช่วงก่อนที่เน้น${p.keyword} ช่วงนี้ให้ความสำคัญกับ${current.keyword}ในการตัดสินใจจริง',
            'จาก${p.phaseName} สู่${current.phaseName} โฟกัสของชีวิตย้ายจาก${p.keyword}ไปสู่${current.keyword}',
          ];
    return frames[seed.abs() % frames.length];
  }

  static const _relationTails = <PlanetRelation, List<String>>{
    PlanetRelation.friend: [
      'จุดเด่นข้อนี้จึงทำงานได้ลื่นและช่วยให้เดินหน้าได้',
      'จุดเด่นข้อนี้ช่วยให้จัดการหน้าที่ในช่วงนี้ได้ชัดขึ้น',
    ],
    PlanetRelation.enemy: [
      'จุดเด่นข้อนี้ฝืนกับนิสัยเดิม และบังคับให้ฝึกความอดทนกับการปรับตัว',
      'ช่วงนี้ออกแรงกับตัวเองมากขึ้น และผลของการปรับตัววัดได้ชัด',
    ],
    PlanetRelation.neutral: [
      'จุดเด่นข้อนี้เปิดทางให้เลือกได้ว่าจะใช้พลังนี้อย่างไร',
      'ผลลัพธ์ชัดขึ้นเมื่อนำจุดเด่นข้อนี้มาใช้จริง',
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
