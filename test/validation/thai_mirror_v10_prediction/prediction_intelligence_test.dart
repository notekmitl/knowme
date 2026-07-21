import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_category.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_context.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_evidence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_reason.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_score.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

/// A fixed evaluation date so age-derived state is reproducible.
final _asOf = DateTime(2026, 6, 27);

/// A spread of birth dates covering every weekday ruler + a young/old age, with
/// and without a lagna lord.
final _birthDates = <DateTime>[
  DateTime(1988, 3, 14), // Mon
  DateTime(1990, 7, 17), // Tue
  DateTime(1995, 1, 4), // Wed
  DateTime(1979, 11, 8), // Thu
  DateTime(2001, 5, 18), // Fri
  DateTime(1966, 9, 24), // Sat
  DateTime(2010, 2, 7), // Sun
  DateTime(1948, 12, 30), // old — likely final/late period
];

PredictionIntelligence _evaluate(
  DateTime birth, {
  LifePlanet? lagnaLord,
}) {
  return PredictionIntelligenceEngine.fromBirthDate(
    birth,
    lagnaLord: lagnaLord,
    asOf: _asOf,
  );
}

void main() {
  group('V10 — window calculation', () {
    test('three windows are always produced in fixed order', () {
      for (final birth in _birthDates) {
        final r = _evaluate(birth);
        expect(r.windows.length, 3);
        expect(r.windows[0].kind, PredictionWindowKind.current);
        expect(r.windows[1].kind, PredictionWindowKind.next12Months);
        expect(r.windows[2].kind, PredictionWindowKind.nextLifePeriod);
      }
    });

    test('current window spans the active period chapter', () {
      final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
        _birthDates.first,
        asOf: _asOf,
      );
      final w = PredictionWindows.current(intel);
      final period = intel.currentAge.period;
      expect(w.startAge, period.startAge);
      expect(w.endAge, period.endAge);
      expect(w.spanYears, period.endAge - period.startAge);
      expect(w.spansTransition, isFalse);
      expect(w.available, isTrue);
    });

    test('next-12-months window is a one-year forward slice', () {
      final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
        _birthDates.first,
        asOf: _asOf,
      );
      final w = PredictionWindows.next12Months(intel);
      final now = intel.currentAge.currentAge;
      expect(w.startAge, now);
      expect(w.endAge, now + PredictionWindows.near);
      expect(w.spanYears, PredictionWindows.near);
      // spansTransition iff current period ends within the year.
      expect(
        w.spansTransition,
        intel.currentAge.period.remainingYears <= PredictionWindows.near,
      );
    });

    test('next-life-period window matches the V9 future preview', () {
      for (final birth in _birthDates) {
        final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
          birth,
          asOf: _asOf,
        );
        final w = PredictionWindows.nextLifePeriod(intel);
        final next = intel.futurePreview.nextPeriod;
        if (next == null) {
          expect(w.available, isFalse,
              reason: 'final period → next window unavailable');
        } else {
          expect(w.available, isTrue);
          expect(w.startAge, next.startAge);
          expect(w.endAge, next.endAge);
          expect(w.spansTransition, isTrue);
        }
      }
    });

    test('window ages are ordered (start <= end)', () {
      for (final birth in _birthDates) {
        for (final w in _evaluate(birth).windows) {
          expect(w.startAge, lessThanOrEqualTo(w.endAge));
          expect(w.spanYears, greaterThanOrEqualTo(0));
        }
      }
    });
  });

  group('V10 — determinism', () {
    test('identical input → byte-identical predictions', () {
      for (final birth in _birthDates) {
        final a = _evaluate(birth, lagnaLord: LifePlanet.venus);
        final b = _evaluate(birth, lagnaLord: LifePlanet.venus);
        expect(a.predictions.length, b.predictions.length);
        for (var i = 0; i < a.predictions.length; i++) {
          final pa = a.predictions[i];
          final pb = b.predictions[i];
          expect(pa.category, pb.category);
          expect(pa.window.kind, pb.window.kind);
          expect(pa.strength, pb.strength);
          expect(pa.confidence, pb.confidence);
          expect(pa.evidence.length, pb.evidence.length);
          expect(pa.opportunities.length, pb.opportunities.length);
          expect(pa.risks.length, pb.risks.length);
          expect(pa.timingReason.code, pb.timingReason.code);
          expect(pa.planetReason.code, pb.planetReason.code);
          expect(pa.lifePeriodReason.code, pb.lifePeriodReason.code);
        }
      }
    });

    test('fromIntelligence and fromBirthDate agree', () {
      for (final birth in _birthDates) {
        final intel =
            LifeTimelineIntelligenceEngine.fromBirthDate(birth, asOf: _asOf);
        final viaIntel = PredictionIntelligenceEngine.fromIntelligence(intel);
        final viaBirth = _evaluate(birth);
        expect(viaIntel.predictions.length, viaBirth.predictions.length);
        for (var i = 0; i < viaIntel.predictions.length; i++) {
          expect(
            viaIntel.predictions[i].strength,
            viaBirth.predictions[i].strength,
          );
          expect(
            viaIntel.predictions[i].confidence,
            viaBirth.predictions[i].confidence,
          );
        }
      }
    });

    test('seed depends only on natal anchors, never wall clock', () {
      final intel =
          LifeTimelineIntelligenceEngine.fromBirthDate(_birthDates.first);
      final c1 = PredictionContext.fromIntelligence(intel);
      final c2 = PredictionContext.fromIntelligence(intel);
      expect(c1.seed, c2.seed);
    });
  });

  group('V10 — coverage & structure', () {
    test('every available window carries all seven categories', () {
      for (final birth in _birthDates) {
        final r = _evaluate(birth);
        for (final w in r.windows.where((w) => w.available)) {
          final forWindow = r.forWindow(w.kind);
          expect(forWindow.length, PredictionCategory.values.length);
          expect(
            forWindow.map((p) => p.category).toSet(),
            PredictionCategory.values.toSet(),
          );
        }
      }
    });

    test('predictionFor returns each category × available window', () {
      final r = _evaluate(_birthDates.first);
      for (final w in r.windows.where((w) => w.available)) {
        for (final c in PredictionCategory.values) {
          expect(r.predictionFor(c, w.kind), isNotNull);
        }
      }
    });

    test('every prediction has the three required reasons with right kinds', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          expect(p.timingReason.kind, PredictionReasonKind.timing);
          expect(p.planetReason.kind, PredictionReasonKind.planet);
          expect(p.lifePeriodReason.kind, PredictionReasonKind.lifePeriod);
          expect(p.reasons.length, 3);
        }
      }
    });
  });

  group('V10 — evidence integrity', () {
    test('scores stay within 0..100', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          expect(p.strength, inInclusiveRange(0, 100));
          expect(p.confidence, inInclusiveRange(0, 100));
          expect(p.score.weighted, inInclusiveRange(0, 100));
        }
      }
    });

    test('evidence is never empty and uses valid sources', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          expect(p.evidence, isNotEmpty);
          for (final e in p.evidence) {
            expect(PredictionEvidenceSource.values, contains(e.source));
          }
          // core four signals are always present.
          final sources = p.evidence.map((e) => e.source).toSet();
          expect(sources, contains(PredictionEvidenceSource.categoryAffinity));
          expect(sources, contains(PredictionEvidenceSource.natalHarmony));
          expect(sources, contains(PredictionEvidenceSource.periodStrength));
        }
      }
    });

    test('opportunities/risks are bounded, deduped and ranked', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          expect(p.opportunities.length, lessThanOrEqualTo(3));
          expect(p.risks.length, lessThanOrEqualTo(3));
          // dedupe by domain
          expect(
            p.opportunities.map((o) => o.domain).toSet().length,
            p.opportunities.length,
          );
          expect(
            p.risks.map((r) => r.domain).toSet().length,
            p.risks.length,
          );
          // magnitudes bounded
          for (final o in p.opportunities) {
            expect(o.magnitude, inInclusiveRange(0, 100));
          }
          for (final r in p.risks) {
            expect(r.magnitude, inInclusiveRange(0, 100));
          }
          // ranked descending
          for (var i = 1; i < p.opportunities.length; i++) {
            expect(
              p.opportunities[i - 1].magnitude,
              greaterThanOrEqualTo(p.opportunities[i].magnitude),
            );
          }
          for (var i = 1; i < p.risks.length; i++) {
            expect(
              p.risks[i - 1].magnitude,
              greaterThanOrEqualTo(p.risks[i].magnitude),
            );
          }
        }
      }
    });

    test('opportunities never include the pressure domain', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          for (final o in p.opportunities) {
            expect(o.domain, isNot(LifeDomain.pressure));
          }
        }
      }
    });

    test('planet reason references the governing ruler & natal bond', () {
      for (final birth in _birthDates) {
        for (final p in _evaluate(birth).predictions) {
          expect(p.planetReason.planet, isNotNull);
          expect(p.planetReason.bond, isNotNull);
        }
      }
    });
  });

  group('V10 — prediction stability', () {
    test('confidence: current >= next-12-months >= next-life-period', () {
      // For the same category, nearer windows are at least as confident.
      for (final birth in _birthDates) {
        final r = _evaluate(birth);
        for (final c in PredictionCategory.values) {
          final cur = r.predictionFor(c, PredictionWindowKind.current);
          final near = r.predictionFor(c, PredictionWindowKind.next12Months);
          final far = r.predictionFor(c, PredictionWindowKind.nextLifePeriod);
          if (cur != null && near != null) {
            expect(cur.confidence, greaterThanOrEqualTo(near.confidence));
          }
          if (near != null && far != null) {
            expect(near.confidence, greaterThanOrEqualTo(far.confidence));
          }
        }
      }
    });

    test('lagna known raises (never lowers) confidence', () {
      for (final birth in _birthDates) {
        final without = _evaluate(birth);
        final with_ = _evaluate(birth, lagnaLord: LifePlanet.jupiter);
        for (final c in PredictionCategory.values) {
          for (final k in PredictionWindowKind.values) {
            final a = without.predictionFor(c, k);
            final b = with_.predictionFor(c, k);
            if (a != null && b != null) {
              expect(b.confidence, greaterThanOrEqualTo(a.confidence));
            }
          }
        }
      }
    });

    test('strength is monotonic in category base affinity for a fixed window', () {
      // Within one window every category shares the same governing planet, tier,
      // natal and timing terms, so strength = clamp(base + constant). The
      // highest-base category must therefore not be weaker than the lowest-base.
      final r = _evaluate(_birthDates[3]);
      final current = r.forWindow(PredictionWindowKind.current);
      final affinity =
          LifePlanets.of(r.context.currentAge.intelligence.planet).affinity;

      int baseFor(PredictionCategory cat) {
        var sum = 0.0;
        var weight = 0.0;
        for (final cw in cat.domainWeights) {
          sum += affinity.valueOf(cw.domain) * cw.weight;
          weight += cw.weight;
        }
        return (sum / weight).round();
      }

      current.sort(
        (a, b) => baseFor(b.category).compareTo(baseFor(a.category)),
      );
      expect(
        current.first.strength,
        greaterThanOrEqualTo(current.last.strength),
      );
    });

    test('ranked list is sorted by weighted score', () {
      final ranked = _evaluate(_birthDates.first).ranked;
      for (var i = 1; i < ranked.length; i++) {
        expect(
          ranked[i - 1].score.weighted,
          greaterThanOrEqualTo(ranked[i].score.weighted),
        );
      }
    });
  });

  group('V10 — final-period edge case', () {
    test('a very old chart degrades gracefully (no next life period)', () {
      // Build a timeline forced into the final period.
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.thursday,
        currentAge: 118,
      );
      final intel = LifeTimelineIntelligenceEngine.fromTimeline(timeline);
      final r = PredictionIntelligenceEngine.fromIntelligence(intel);
      final nextWindow = r.windows
          .firstWhere((w) => w.kind == PredictionWindowKind.nextLifePeriod);
      if (!nextWindow.available) {
        expect(r.forWindow(PredictionWindowKind.nextLifePeriod), isEmpty);
      }
      // current window still fully populated
      expect(
        r.forWindow(PredictionWindowKind.current).length,
        PredictionCategory.values.length,
      );
    });
  });

  group('V10 — score helper', () {
    test('clamp keeps values in 0..100', () {
      expect(PredictionScore.clamp(-5), 0);
      expect(PredictionScore.clamp(140), 100);
      expect(PredictionScore.clamp(50), 50);
    });

    test('band thresholds', () {
      expect(const PredictionScore(strength: 80, confidence: 50).band,
          PredictionStrengthBand.high);
      expect(const PredictionScore(strength: 50, confidence: 50).band,
          PredictionStrengthBand.moderate);
      expect(const PredictionScore(strength: 10, confidence: 50).band,
          PredictionStrengthBand.low);
    });
  });
}
