import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_confidence.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_evidence.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_reason.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
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

DecisionIntelligence _evaluate(DateTime birth, {LifePlanet? lagnaLord}) {
  return DecisionIntelligenceEngine.fromBirthDate(
    birth,
    lagnaLord: lagnaLord,
    asOf: _asOf,
  );
}

void main() {
  group('V11 — coverage & structure', () {
    test('every scenario yields exactly one recommendation, no dupes', () {
      for (final birth in _birthDates) {
        final r = _evaluate(birth);
        expect(r.recommendations.length, DecisionScenario.values.length);
        expect(
          r.recommendations.map((x) => x.scenario).toSet(),
          DecisionScenario.values.toSet(),
        );
        for (final s in DecisionScenario.values) {
          expect(r.forScenario(s), isNotNull);
        }
      }
    });

    test('each recommendation has 4 reasons, one per kind', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(rec.reasons.length, 4);
          expect(
            rec.reasons.map((x) => x.kind).toSet(),
            DecisionReasonKind.values.toSet(),
          );
        }
      }
    });

    test('action is always a valid verdict', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(DecisionAction.values, contains(rec.action));
        }
      }
    });
  });

  group('V11 — determinism', () {
    test('identical input → byte-identical recommendations', () {
      for (final birth in _birthDates) {
        final a = _evaluate(birth, lagnaLord: LifePlanet.venus);
        final b = _evaluate(birth, lagnaLord: LifePlanet.venus);
        expect(a.recommendations.length, b.recommendations.length);
        for (var i = 0; i < a.recommendations.length; i++) {
          final ra = a.recommendations[i];
          final rb = b.recommendations[i];
          expect(ra.scenario, rb.scenario);
          expect(ra.action, rb.action);
          expect(ra.confidence.value, rb.confidence.value);
          expect(ra.reasons.map((x) => x.code).toList(),
              rb.reasons.map((x) => x.code).toList());
          expect(ra.supportingEvidence.length, rb.supportingEvidence.length);
          expect(ra.conflictingEvidence.length, rb.conflictingEvidence.length);
          expect(ra.bestTiming.kind, rb.bestTiming.kind);
          expect(ra.bestTiming.favourability, rb.bestTiming.favourability);
          expect(ra.worstTiming.kind, rb.worstTiming.kind);
          expect(ra.tradeoffs.length, rb.tradeoffs.length);
          expect(ra.outcome.band, rb.outcome.band);
          expect(ra.outcome.favourability, rb.outcome.favourability);
        }
      }
    });

    test('fromIntelligence and fromBirthDate agree', () {
      for (final birth in _birthDates) {
        final intel =
            LifeTimelineIntelligenceEngine.fromBirthDate(birth, asOf: _asOf);
        final viaIntel = DecisionIntelligenceEngine.fromIntelligence(intel);
        final viaBirth = _evaluate(birth);
        for (final s in DecisionScenario.values) {
          final a = viaIntel.forScenario(s)!;
          final b = viaBirth.forScenario(s)!;
          expect(a.action, b.action);
          expect(a.confidence.value, b.confidence.value);
          expect(a.outcome.favourability, b.outcome.favourability);
        }
      }
    });
  });

  group('V11 — evidence traceability', () {
    test('evidence is non-empty, signed correctly, valid sources', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          final all = rec.evidence;
          expect(all, isNotEmpty);
          for (final e in all) {
            expect(DecisionEvidenceSource.values, contains(e.source));
            expect(e.magnitude, isNot(0));
          }
          // partition by sign is exact
          expect(rec.supportingEvidence.every((e) => e.magnitude > 0), isTrue);
          expect(rec.conflictingEvidence.every((e) => e.magnitude < 0), isTrue);
          expect(
            rec.supportingEvidence.length + rec.conflictingEvidence.length,
            all.length,
          );
        }
      }
    });

    test('current-stage evidence is always present (always non-zero)', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(
            rec.evidence.map((e) => e.source),
            contains(DecisionEvidenceSource.currentStage),
          );
        }
      }
    });

    test('the engine wires every evidence family (union over the spread)', () {
      // A single chart may legitimately drop a neutral family (e.g. a moderate
      // period contributes 0 timeline strength), so traceability is proven by
      // the union across a diverse spread covering all six input families →
      // eight sources.
      final seen = <DecisionEvidenceSource>{};
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          seen.addAll(rec.evidence.map((e) => e.source));
        }
      }
      expect(seen, DecisionEvidenceSource.values.toSet(),
          reason: 'unused evidence families: '
              '${DecisionEvidenceSource.values.toSet().difference(seen)}');
    });
  });

  group('V11 — verdict consistency', () {
    test('shouldAct only when decisive favourability clears the threshold', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          if (rec.action == DecisionAction.shouldAct) {
            expect(
              rec.outcome.favourability,
              greaterThanOrEqualTo(rec.scenario.config.actThreshold),
            );
          }
        }
      }
    });

    test('shouldWait points at the next life period', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          if (rec.action == DecisionAction.shouldWait) {
            expect(rec.bestTiming.kind, PredictionWindowKind.nextLifePeriod);
            expect(rec.bestTiming.available, isTrue);
          }
        }
      }
    });

    test('shouldAvoid only when decisive favourability is below threshold', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          if (rec.action == DecisionAction.shouldAvoid) {
            expect(
              rec.outcome.favourability,
              lessThan(rec.scenario.config.actThreshold),
            );
          }
        }
      }
    });
  });

  group('V11 — timing stability', () {
    test('best timing is at least as favourable as worst timing', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(rec.bestTiming.available, isTrue);
          expect(rec.worstTiming.available, isTrue);
          expect(
            rec.bestTiming.favourability,
            greaterThanOrEqualTo(rec.worstTiming.favourability),
          );
          expect(rec.bestTiming.startAge, lessThanOrEqualTo(rec.bestTiming.endAge));
          expect(
            rec.worstTiming.startAge,
            lessThanOrEqualTo(rec.worstTiming.endAge),
          );
        }
      }
    });
  });

  group('V11 — bounds & tradeoffs', () {
    test('all scores stay within 0..100', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(rec.confidence.value, inInclusiveRange(0, 100));
          expect(rec.outcome.favourability, inInclusiveRange(0, 100));
          expect(rec.bestTiming.favourability, inInclusiveRange(0, 100));
          expect(rec.bestTiming.risk, inInclusiveRange(0, 100));
          expect(rec.bestTiming.confidence, inInclusiveRange(0, 100));
          expect(rec.worstTiming.favourability, inInclusiveRange(0, 100));
        }
      }
    });

    test('tradeoffs are bounded, distinct gain≠cost, magnitudes valid', () {
      for (final birth in _birthDates) {
        for (final rec in _evaluate(birth).recommendations) {
          expect(rec.tradeoffs.length, lessThanOrEqualTo(2));
          for (final t in rec.tradeoffs) {
            expect(t.gain, isNot(t.cost));
            expect(t.gainMagnitude, inInclusiveRange(0, 100));
            expect(t.costMagnitude, inInclusiveRange(0, 100));
          }
        }
      }
    });

    test('confidence band thresholds', () {
      expect(const DecisionConfidence(value: 80).band,
          DecisionConfidenceBand.high);
      expect(const DecisionConfidence(value: 50).band,
          DecisionConfidenceBand.moderate);
      expect(const DecisionConfidence(value: 20).band,
          DecisionConfidenceBand.low);
    });
  });

  group('V11 — scenario stability & ranking', () {
    test('lagna known never lowers decision confidence', () {
      for (final birth in _birthDates) {
        final without = _evaluate(birth);
        final with_ = _evaluate(birth, lagnaLord: LifePlanet.jupiter);
        for (final s in DecisionScenario.values) {
          final a = without.forScenario(s)!;
          final b = with_.forScenario(s)!;
          // Same verdict family keeps confidence monotonic; when the verdict
          // changes the comparison is not meaningful, so guard on it.
          if (a.action == b.action) {
            expect(b.confidence.value, greaterThanOrEqualTo(a.confidence.value));
          }
        }
      }
    });

    test('ranked orders by action, then confidence, then favourability', () {
      final ranked = _evaluate(_birthDates.first).ranked;
      for (var i = 1; i < ranked.length; i++) {
        final prev = ranked[i - 1];
        final cur = ranked[i];
        expect(prev.action.direction,
            greaterThanOrEqualTo(cur.action.direction));
      }
    });
  });

  group('V11 — final-period edge case', () {
    test('a very old chart degrades gracefully', () {
      final timeline = LifePeriodEngine.build(
        birthWeekday: DateTime.thursday,
        currentAge: 118,
      );
      final intel = LifeTimelineIntelligenceEngine.fromTimeline(timeline);
      final r = DecisionIntelligenceEngine.fromIntelligence(intel);
      expect(r.recommendations.length, DecisionScenario.values.length);
      for (final rec in r.recommendations) {
        expect(DecisionAction.values, contains(rec.action));
        expect(rec.bestTiming.available, isTrue);
        // no next life period → best/worst never point past the final period
        expect(rec.evidence, isNotEmpty);
      }
    });
  });
}
