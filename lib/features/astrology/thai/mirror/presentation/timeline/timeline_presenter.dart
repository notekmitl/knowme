import 'package:knowme/features/astrology/thai/core/life_period/annual_taksa_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_sub_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/mahabhut_planet_position_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/thai_life_map_mahabhut_resolution.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/thai_canon_evidence_index.dart';

import '../copy/thai_mirror_evidence_composer.dart';
import 'period_composite_score.dart';
import 'period_intelligence_composer.dart';
import 'period_narrative_composer.dart';
import 'thai_mirror_life_timeline_state.dart';

/// V8 — TimelinePresenter.
///
/// Single place that wires the Life Period Engine, composite scorer and
/// narrative composer into the UI-facing [ThaiMirrorLifeTimelineState]. Keeps
/// the widgets free of any astrology types.
abstract final class TimelinePresenter {
  static const _domainLabel = {
    'career': 'การงาน',
    'money': 'การเงิน',
    'love': 'ความรัก',
    'health': 'สุขภาพ',
    'growth': 'เติบโต',
    'opportunity': 'โอกาส',
  };

  /// Builds the timeline view state from precomputed [lifePeriods] *evidence*
  /// (produced by [LifePeriodEngine], which consumed the canonical birth
  /// profile upstream). The presenter never receives a raw birth date — only
  /// engine evidence — so birth-profile resolution stays in one place.
  ///
  /// [canonIndex] (or the Frozen Canon process cache) plus [profile]/[birthData]
  /// feed existing Mahabhut resolvers — never invent placement tables here.
  ///
  /// Returns null when no timeline evidence is available.
  static ThaiMirrorLifeTimelineState? build({
    required LifeTimeline? lifePeriods,
    required String? lagnaLordKey,
    required List<String> orderedThemeIds,
    required List<String> topThemeTags,
    required int profileSeed,
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (lifePeriods == null) return null;

    final timeline = lifePeriods;
    final age = timeline.currentAge;
    final lagnaLord = LifePlanets.fromLagnaLordKey(lagnaLordKey);
    final evidence = ThaiMirrorEvidenceComposer.profileFor(orderedThemeIds);
    final mahabhutResolution = ThaiLifeMapMahabhutResolution.tryCreate(
      profile: profile,
      birthData: birthData,
      canonIndex: canonIndex,
    );

    String ageLabel(PeriodState p) => '${p.startAge}–${p.endAge}';

    List<ThaiMirrorPeriodScoreBar> bars(PeriodScores sc) => [
      ThaiMirrorPeriodScoreBar(
        label: _domainLabel['career']!,
        value: sc.career,
      ),
      ThaiMirrorPeriodScoreBar(label: _domainLabel['money']!, value: sc.money),
      ThaiMirrorPeriodScoreBar(label: _domainLabel['love']!, value: sc.love),
      ThaiMirrorPeriodScoreBar(
        label: _domainLabel['health']!,
        value: sc.health,
      ),
      ThaiMirrorPeriodScoreBar(
        label: _domainLabel['growth']!,
        value: sc.growth,
      ),
      ThaiMirrorPeriodScoreBar(
        label: _domainLabel['opportunity']!,
        value: sc.opportunity,
      ),
    ];

    final segments = <ThaiMirrorTimelineSegmentState>[];
    final periods = <ThaiMirrorLifePeriodState>[];

    for (final p in timeline.periods) {
      final data = LifePlanets.of(p.planet);
      final seed =
          profileSeed ^ (p.planet.index * 2246822519) ^ (p.index * 40503);
      final scores = PeriodCompositeScore.evaluate(
        period: p,
        lagnaLord: lagnaLord,
        evidence: evidence,
        seed: seed,
      );
      final narrative = PeriodNarrativeComposer.compose(
        period: p,
        scores: scores,
        lagnaLord: lagnaLord,
        evidence: evidence,
        topThemeTags: topThemeTags,
        seed: seed,
      );

      segments.add(
        ThaiMirrorTimelineSegmentState(
          ageLabel: ageLabel(p),
          phaseName: data.phaseName,
          planetName: data.thaiName,
          strength: p.strength,
          isCurrent: p.isCurrent,
          isPast: p.isPast,
          progress: p.progress,
          accentIndex: p.planet.index,
        ),
      );

      final subPeriods = LifeSubPeriodEngine.forMajor(p.planet)
          .map(
            (s) => ThaiMirrorLifeSubPeriodState(
              label: s.thaiLabel,
              durationLabel: s.durationLabel,
            ),
          )
          .toList(growable: false);

      final taksaYears =
          AnnualTaksaEngine.forAgeRange(
                startPlanet: timeline.startPlanet,
                startAge: p.startAge,
                endAge: p.endAge,
              )
              .map(
                (y) => ThaiMirrorAnnualTaksaYearState(
                  ageLabel: 'อายุ ${y.age}',
                  boriwanLabel: y.isTagklang
                      ? 'ตากลาง (บริวารจร)'
                      : '${y.boriwanLabel} (บริวารจร)',
                  houseLabel: y.isTagklang ? 'เรือน ๙' : 'เรือน ${y.house}',
                  isTagklang: y.isTagklang,
                ),
              )
              .toList(growable: false);

      final mahabhut = mahabhutResolution?.resolve(p) ??
          MahabhutPlanetPositionEngine.resolve(period: p);

      periods.add(
        ThaiMirrorLifePeriodState(
          ageLabel: ageLabel(p),
          phaseName: data.phaseName,
          planetLine: 'อิทธิพล${data.thaiName} • ${data.keyword}',
          keyword: data.keyword,
          isCurrent: p.isCurrent,
          isPast: p.isPast,
          summary: narrative.summary,
          whatChanges: narrative.whatChanges,
          easier: narrative.easier,
          harder: narrative.harder,
          comparison: narrative.comparison,
          evidenceLine: narrative.evidenceLine,
          scores: bars(scores),
          easeIndex: scores.easeIndex,
          accentIndex: p.planet.index,
          timeBucketLabel: p.isCurrent
              ? 'ปัจจุบัน'
              : p.isPast
              ? 'อดีต'
              : 'อนาคต',
          mahabhutPositionLabel: mahabhut.displayLabel,
          subPeriods: subPeriods,
          annualTaksaYears: taksaYears,
        ),
      );
    }

    // V9 — Life Timeline Intelligence: relationship/element/strength evidence
    // for the current and next periods, composed into consumer copy here.
    final intelligence = LifeTimelineIntelligenceEngine.fromTimeline(
      timeline,
      lagnaLord: lagnaLord,
    );
    final currentAnalysis = PeriodIntelligenceComposer.composeCurrent(
      analysis: intelligence.currentAge,
      seed: profileSeed,
    );
    final futurePreview = PeriodIntelligenceComposer.composeFuture(
      preview: intelligence.futurePreview,
      seed: profileSeed,
    );

    final cur = timeline.current;
    final curData = LifePlanets.of(cur.planet);
    final prev = timeline.previous;
    final next = timeline.next;

    final currentStage = ThaiMirrorCurrentStageState(
      eyebrow: 'คุณอยู่ช่วงไหนของชีวิต',
      currentAge: age,
      ageLabel: ageLabel(cur),
      phaseName: curData.phaseName,
      planetLine: 'อิทธิพล${curData.thaiName} • ${curData.keyword}',
      keyword: curData.keyword,
      yearsRemaining: cur.remainingYears,
      progress: cur.progress,
      intro: _stageIntro(
        age,
        curData.phaseName,
        cur.remainingYears,
        profileSeed,
      ),
      previousLabel: prev == null
          ? ''
          : 'ช่วงก่อนหน้า: ${LifePlanets.of(prev.planet).phaseName} '
                '(${ageLabel(prev)})',
      nextLabel: next == null
          ? ''
          : 'ช่วงถัดไป: ${LifePlanets.of(next.planet).phaseName} '
                '(${ageLabel(next)})',
      accentIndex: cur.planet.index,
    );

    return ThaiMirrorLifeTimelineState(
      sectionTitle: 'แผนที่ชีวิตของคุณ',
      sectionIntro:
          'แปดช่วงดาวเสวยอายุจากอายุโหร 1–108 ปี '
          'แบ่งเป็นอดีต ปัจจุบัน และอนาคต — กดดูรายละเอียดแต่ละช่วงเพื่อดูดาวแทรกและทักษาจร',
      currentStage: currentStage,
      currentAnalysis: currentAnalysis.isEmpty ? null : currentAnalysis,
      futurePreview: futurePreview,
      segments: segments,
      periods: periods,
    );
  }

  static String _stageIntro(int age, String phase, int remaining, int seed) {
    final frames = <String>[
      'ตอนนี้คุณอายุ $age ปี กำลังอยู่ใน$phase '
          'และจะอยู่ในจังหวะนี้ไปอีกประมาณ $remaining ปี',
      'ที่อายุ $age ปี ชีวิตของคุณกำลังเดินอยู่ใน$phase '
          'เหลือเวลาในช่วงนี้อีกราว $remaining ปีก่อนจะเปลี่ยนผ่าน',
      'วันนี้ ในวัย $age ปี คุณอยู่กลาง$phase พอดี '
          'อีกประมาณ $remaining ปีจะเริ่มก้าวสู่จังหวะใหม่',
    ];
    return frames[seed.abs() % frames.length];
  }
}
