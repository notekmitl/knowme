import 'package:knowme/features/astrology/thai/core/life_period/annual_taksa_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';
import 'package:knowme/features/astrology/thai/foundation/constants/thai_lagna_rulership.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/house_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/models/thai_lagna.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/period_composite_score.dart';

import 'thai_birthday_year_window.dart';
import 'thai_detected_event.dart';
import 'thai_evidence_item.dart';
import 'thai_v135_labels.dart';

/// Bundle of deterministic evidence + events for V1.3.5.
class ThaiDetailedEvidenceBundle {
  const ThaiDetailedEvidenceBundle({
    required this.items,
    required this.events,
    required this.birthdayYear,
    required this.periodScores,
    required this.taksaForCurrentAge,
  });

  final List<ThaiEvidenceItem> items;
  final List<ThaiDetectedEvent> events;
  final ThaiBirthdayYearWindow birthdayYear;
  final Map<int, PeriodScores> periodScores;
  final AnnualTaksaYear? taksaForCurrentAge;
}

/// Builds read-only evidence from verified Flutter Thai calculators only.
///
/// Does **not** invent natal longitudes, Ketu, Uranus, or house occupancy.
abstract final class ThaiDetailedEvidenceBuilder {
  static const pressureEventThreshold = 65;
  static const strongScoreThreshold = 70;

  static ThaiDetailedEvidenceBundle build({
    required ThaiBirthData birthData,
    required ThaiAstrologyProfile profile,
    required LifeTimeline timeline,
    required DateTime asOfLocal,
    required int profileSeed,
    List<String> orderedThemeIds = const [],
  }) {
    final items = <ThaiEvidenceItem>[];
    final events = <ThaiDetectedEvent>[];
    final lagnaLord = LifePlanets.fromLagnaLordKey(profile.lagnaLordKey);
    final evidenceProfile = ThaiMirrorEvidenceComposer.profileFor(
      orderedThemeIds,
    );

    final birthday = ThaiBirthdayYearWindow.resolve(
      birthLocalDate: birthData.localDateTime,
      asOfLocal: asOfLocal,
    );
    items.add(
      ThaiEvidenceItem(
        evidenceId: 'ev.birthday_year.window',
        category: ThaiEvidenceCategory.birthdayYear,
        topic: ThaiEvidenceTopic.birthdayYear,
        facts: [
          'ช่วงปีเกิดล่าสุด ${birthday.labelTh}',
          'วันเปิดรายงาน ${birthday.asOfLocalDate.day}/'
              '${birthday.asOfLocalDate.month}/${birthday.asOfLocalDate.year}',
        ],
        ageOrDateRange: birthday.labelTh,
        derivationRef: 'ThaiBirthdayYearWindow.resolve',
        direction: ThaiEvidenceDirection.neutral,
        strength: 50,
      ),
    );

    // Natal foundation
    final weekday = birthData.astrologicalDate.weekday;
    items.add(
      ThaiEvidenceItem(
        evidenceId: 'ev.natal.weekday',
        category: ThaiEvidenceCategory.natalFoundation,
        topic: ThaiEvidenceTopic.overview,
        facts: [
          'วันโหราศาสตร์ ${ThaiV135Labels.weekdayTh(weekday)}',
          'ดาวเริ่มต้นวงจร ${ThaiV135Labels.planet(timeline.startPlanet)}',
        ],
        derivationRef: 'ThaiBirthData.astrologicalDate + LifePeriodEngine',
        direction: ThaiEvidenceDirection.neutral,
        strength: 80,
      ),
    );

    if (profile.hasBirthTime &&
        profile.lagnaKey != null &&
        profile.siderealAscendantDeg != null) {
      items.add(
        ThaiEvidenceItem(
          evidenceId: 'ev.lagna.sign',
          category: ThaiEvidenceCategory.natalFoundation,
          topic: ThaiEvidenceTopic.personality,
          facts: [
            'ลัคนา ${ThaiV135Labels.lagna(profile.lagnaKey)}',
            'องศาลัคนา ${profile.siderealAscendantDeg!.toStringAsFixed(1)}° '
                '(sidereal Lahiri)',
            'เจ้าเรือนลัคนา ${ThaiV135Labels.lord(profile.lagnaLordKey)}',
          ],
          derivationRef: 'LagnaEngine / ThaiFoundationEngine',
          direction: ThaiEvidenceDirection.supportive,
          strength: 90,
        ),
      );

      final lagna = ThaiLagna(
        signKey: profile.lagnaKey!,
        lordKey: profile.lagnaLordKey ??
            ThaiLagnaRulership.lordForLagna(profile.lagnaKey) ??
            '',
        siderealDeg: profile.siderealAscendantDeg!,
        signIndex: ThaiContentKeysSignIndex.of(profile.lagnaKey!),
      );
      if (lagna.lordKey.isNotEmpty) {
        final houses = HouseEngine.calculate(lagna: lagna);
        for (final h in houses) {
          // Topic mapping for key life houses only (1,2,6,7,10).
          final topic = switch (h.houseNumber) {
            1 => ThaiEvidenceTopic.personality,
            2 => ThaiEvidenceTopic.money,
            6 => ThaiEvidenceTopic.health,
            7 => ThaiEvidenceTopic.love,
            10 => ThaiEvidenceTopic.career,
            _ => null,
          };
          if (topic == null) continue;
          items.add(
            ThaiEvidenceItem(
              evidenceId: 'ev.house.${h.houseNumber}.lord',
              category: ThaiEvidenceCategory.houseFrame,
              topic: topic,
              facts: [
                'เรือน ${h.houseNumber} ราศี ${ThaiV135Labels.lagna(h.signKey)}',
                'เจ้าเรือน ${ThaiV135Labels.lord(h.lordKey)} '
                    '(whole-sign จากลัคนา — ไม่ใช่ตำแหน่งดาวในเรือน)',
              ],
              derivationRef: 'HouseEngine.calculate',
              direction: ThaiEvidenceDirection.neutral,
              strength: 70,
            ),
          );
        }
      }
    } else {
      items.add(
        ThaiEvidenceItem(
          evidenceId: 'ev.lagna.unavailable',
          category: ThaiEvidenceCategory.natalFoundation,
          topic: ThaiEvidenceTopic.personality,
          facts: [
            'ไม่มีเวลาเกิดที่ยืนยันได้ จึงยังไม่คำนวณลัคนาและกรอบเรือน',
          ],
          derivationRef: 'ThaiAstrologyProfile.hasBirthTime',
          direction: ThaiEvidenceDirection.quiet,
          strength: 20,
        ),
      );
    }

    final periodScores = <int, PeriodScores>{};
    AnnualTaksaYear? currentTaksa;

    for (final p in timeline.periods) {
      final data = LifePlanets.of(p.planet);
      final seed =
          profileSeed ^ (p.planet.index * 2246822519) ^ (p.index * 40503);
      final scores = PeriodCompositeScore.evaluate(
        period: p,
        lagnaLord: lagnaLord,
        evidence: evidenceProfile,
        seed: seed,
      );
      periodScores[p.index] = scores;

      final ageRange = '${p.startAge}–${p.endAge}';
      final topic = p.isPast
          ? ThaiEvidenceTopic.periodPast
          : p.isCurrent
              ? ThaiEvidenceTopic.periodCurrent
              : ThaiEvidenceTopic.periodFuture;

      items.add(
        ThaiEvidenceItem(
          evidenceId: 'ev.period.${p.planet.name}.ages',
          category: ThaiEvidenceCategory.lifePeriod,
          topic: topic,
          facts: [
            'ช่วง${data.phaseName} อายุ $ageRange',
            'ดาวเสวยอายุ ${data.thaiName} ความยาว ${p.strength} ปี',
            'แก่นจังหวะ: ${data.phaseEssence}',
          ],
          ageOrDateRange: ageRange,
          derivationRef: 'LifePeriodEngine',
          direction: ThaiEvidenceDirection.neutral,
          strength: p.strength * 4,
        ),
      );

      if (lagnaLord != null) {
        final bond = PlanetRelationshipEngine.assess(p.planet, lagnaLord);
        final natural = PlanetRelationshipMatrix.relation(p.planet, lagnaLord);
        items.add(
          ThaiEvidenceItem(
            evidenceId:
                'ev.bond.${p.planet.name}_${lagnaLord.name}.${natural.name}',
            category: ThaiEvidenceCategory.planetBond,
            topic: topic,
            facts: [
              'ความสัมพันธ์ธรรมชาติ ${data.thaiName}–'
                  '${LifePlanets.of(lagnaLord).thaiName}: ${natural.name}',
              'พันธะรวม: ${bond.bond.labelTh} (คะแนน ${bond.score})',
            ],
            ageOrDateRange: ageRange,
            derivationRef: 'PlanetRelationshipEngine.assess',
            direction: bond.isSupportive
                ? ThaiEvidenceDirection.supportive
                : bond.isConflicting
                    ? ThaiEvidenceDirection.challenging
                    : ThaiEvidenceDirection.neutral,
            strength: (bond.score.abs() + 1) * 20,
            conflictGroupId: bond.isConflicting
                ? 'conflict.period_${p.index}.natal'
                : null,
          ),
        );
      }

      for (final domain in [
        ('career', scores.career, ThaiEvidenceTopic.career),
        ('money', scores.money, ThaiEvidenceTopic.money),
        ('love', scores.love, ThaiEvidenceTopic.love),
        ('health', scores.health, ThaiEvidenceTopic.health),
      ]) {
        items.add(
          ThaiEvidenceItem(
            evidenceId: 'ev.score.${domain.$1}.p${p.index}',
            category: ThaiEvidenceCategory.periodScore,
            topic: domain.$3,
            facts: [
              'คะแนนโครงสร้าง ${domain.$1}=${domain.$2} '
                  'pressure=${scores.pressure} ในช่วงอายุ $ageRange',
            ],
            ageOrDateRange: ageRange,
            derivationRef: 'PeriodCompositeScore.evaluate',
            direction: domain.$2 >= strongScoreThreshold
                ? ThaiEvidenceDirection.supportive
                : scores.pressure >= pressureEventThreshold
                    ? ThaiEvidenceDirection.challenging
                    : ThaiEvidenceDirection.neutral,
            strength: domain.$2,
          ),
        );
      }

      // Events — only when rules fire
      if (scores.pressure >= pressureEventThreshold) {
        events.add(
          ThaiDetectedEvent(
            eventKey: 'pressure.p${p.index}',
            evidenceIds: ['ev.score.career.p${p.index}', 'ev.period.${p.planet.name}.ages'],
            topic: topic,
            summaryFact:
                'แรงกดดันโครงสร้างสูง (pressure=${scores.pressure}) ในช่วง${data.phaseName}',
            tense: p.isPast
                ? ThaiEventTense.pastLikely
                : p.isFuture
                    ? ThaiEventTense.futureLikely
                    : ThaiEventTense.present,
            weight: scores.pressure,
          ),
        );
      }
      if (scores.career >= strongScoreThreshold) {
        events.add(
          ThaiDetectedEvent(
            eventKey: 'career_focus.p${p.index}',
            evidenceIds: ['ev.score.career.p${p.index}'],
            topic: ThaiEvidenceTopic.career,
            summaryFact:
                'สัญญาณงาน/หน้าที่เด่น (career=${scores.career}) ในช่วง${data.phaseName}',
            tense: p.isPast
                ? ThaiEventTense.pastLikely
                : p.isFuture
                    ? ThaiEventTense.futureLikely
                    : ThaiEventTense.present,
            weight: scores.career,
          ),
        );
      }
      if (lagnaLord != null) {
        final bond = PlanetRelationshipEngine.assess(p.planet, lagnaLord);
        if (bond.isConflicting) {
          events.add(
            ThaiDetectedEvent(
              eventKey: 'natal_friction.p${p.index}',
              evidenceIds: [
                'ev.bond.${p.planet.name}_${lagnaLord.name}.'
                    '${PlanetRelationshipMatrix.relation(p.planet, lagnaLord).name}',
              ],
              topic: topic,
              summaryFact:
                  'แรงเสียดทานระหว่างดาวเสวยอายุกับเจ้าเรือนลัคนา '
                  '(${bond.bond.labelTh})',
              tense: p.isPast
                  ? ThaiEventTense.pastLikely
                  : p.isFuture
                      ? ThaiEventTense.futureLikely
                      : ThaiEventTense.present,
              conflictGroupId: 'conflict.period_${p.index}.natal',
              weight: bond.score.abs() * 20,
            ),
          );
        }
      }
    }

    // Annual Taksa for current Thai age
    final ageYears = AnnualTaksaEngine.build(
      startPlanet: timeline.startPlanet,
      maxAge: LifePeriodEngine.lifeMapMaxAge,
    );
    final match = ageYears.where((y) => y.age == timeline.currentAge);
    if (match.isNotEmpty) {
      currentTaksa = match.first;
      final y = currentTaksa;
      items.add(
        ThaiEvidenceItem(
          evidenceId: 'ev.taksa.age.${y.age}.boriwan',
          category: ThaiEvidenceCategory.annualTaksa,
          topic: ThaiEvidenceTopic.birthdayYear,
          facts: [
            y.isTagklang
                ? 'อายุโหร ${y.age} เป็นตากลาง เรือน ${y.house}'
                : 'อายุโหร ${y.age} บริวารจร ${y.boriwanLabel} เรือน ${y.house}',
            if (y.roleByPlanet[timeline.current.planet] != null)
              'บทบาท${LifePlanets.of(timeline.current.planet).thaiName}ปีนี้: '
                  '${y.roleByPlanet[timeline.current.planet]}',
          ],
          ageOrDateRange: 'อายุ ${y.age}',
          derivationRef: 'AnnualTaksaEngine',
          direction: y.isTagklang
              ? ThaiEvidenceDirection.mixed
              : ThaiEvidenceDirection.neutral,
          strength: 60,
        ),
      );

      final kalakini = y.roleByPlanet.entries
          .where((e) => e.value == AnnualTaksaRoles.kalakini)
          .toList();
      if (kalakini.isNotEmpty) {
        final kp = kalakini.first.key;
        events.add(
          ThaiDetectedEvent(
            eventKey: 'taksa.kalakini.${y.age}',
            evidenceIds: ['ev.taksa.age.${y.age}.boriwan'],
            topic: ThaiEvidenceTopic.birthdayYear,
            summaryFact:
                'ในปีอายุโหร ${y.age} ดาว${LifePlanets.of(kp).thaiName}อยู่ในกาฬกิณี',
            tense: ThaiEventTense.present,
            weight: 55,
          ),
        );
      }
    }

    // Conflict: age-period vs birthday-year emphasis
    final cur = timeline.current;
    final curScores = periodScores[cur.index];
    if (curScores != null && currentTaksa != null) {
      final periodHeavy = cur.remainingYears <= 2 || cur.progress >= 0.75;
      final yearRole = currentTaksa.roleByPlanet[cur.planet];
      final yearChallenging = yearRole == AnnualTaksaRoles.kalakini ||
          currentTaksa.isTagklang;
      if (periodHeavy && yearChallenging) {
        const group = 'conflict.current.period_vs_year';
        items.add(
          ThaiEvidenceItem(
            evidenceId: 'ev.conflict.current.period_vs_year',
            category: ThaiEvidenceCategory.conflict,
            topic: ThaiEvidenceTopic.periodCurrent,
            facts: [
              'ชั้นช่วงอายุ: ใกล้จบ/เข้มข้นของ${LifePlanets.of(cur.planet).phaseName}',
              'ชั้นปีเกิด: ทักษาจรปีนี้มีสัญญาณปรับตัว'
                  '${currentTaksa.isTagklang ? " (ตากลาง)" : ""}',
              'น้ำหนักปัจจุบัน: ชั้นช่วงอายุมีน้ำหนักมากกว่าจนกว่าจะเปลี่ยนช่วง',
            ],
            ageOrDateRange: birthday.labelTh,
            derivationRef: 'LifePeriodEngine + AnnualTaksaEngine',
            direction: ThaiEvidenceDirection.mixed,
            strength: 75,
            conflictGroupId: group,
          ),
        );
      }
    }

    return ThaiDetailedEvidenceBundle(
      items: List.unmodifiable(items),
      events: _dedupeEvents(events),
      birthdayYear: birthday,
      periodScores: Map.unmodifiable(periodScores),
      taksaForCurrentAge: currentTaksa,
    );
  }

  static List<ThaiDetectedEvent> _dedupeEvents(List<ThaiDetectedEvent> raw) {
    final byKey = <String, ThaiDetectedEvent>{};
    for (final e in raw) {
      final prev = byKey[e.eventKey];
      if (prev == null || e.weight > prev.weight) {
        byKey[e.eventKey] = e;
      } else if (prev.weight == e.weight) {
        final merged = <String>{...prev.evidenceIds, ...e.evidenceIds}.toList()
          ..sort();
        byKey[e.eventKey] = ThaiDetectedEvent(
          eventKey: prev.eventKey,
          evidenceIds: merged,
          topic: prev.topic,
          summaryFact: prev.summaryFact,
          tense: prev.tense,
          conflictGroupId: prev.conflictGroupId ?? e.conflictGroupId,
          weight: prev.weight,
        );
      }
    }
    final out = byKey.values.toList()
      ..sort((a, b) => b.weight.compareTo(a.weight));
    return List.unmodifiable(out);
  }
}

/// Sign index lookup for whole-sign house frame (matches LagnaEngine order).
abstract final class ThaiContentKeysSignIndex {
  static int of(String lagnaKey) {
    const order = [
      'lagna_aries',
      'lagna_taurus',
      'lagna_gemini',
      'lagna_cancer',
      'lagna_leo',
      'lagna_virgo',
      'lagna_libra',
      'lagna_scorpio',
      'lagna_sagittarius',
      'lagna_capricorn',
      'lagna_aquarius',
      'lagna_pisces',
    ];
    final i = order.indexOf(lagnaKey);
    return i < 0 ? 0 : i;
  }
}
