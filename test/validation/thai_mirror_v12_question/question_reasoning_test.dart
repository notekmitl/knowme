import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_evidence.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_reason.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/question/question_answer.dart';
import 'package:knowme/features/astrology/thai/core/question/question_constraint.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_reasoning_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';

final _asOf = DateTime(2026, 6, 27);

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

DecisionIntelligence _decision(DateTime birth, {LifePlanet? lagnaLord}) =>
    DecisionIntelligenceEngine.fromBirthDate(
      birth,
      lagnaLord: lagnaLord,
      asOf: _asOf,
    );

/// Documented topic → scenario routing (V1).
const _expectedScenario = <QuestionTopic, DecisionScenario>{
  QuestionTopic.career: DecisionScenario.careerChange,
  QuestionTopic.finance: DecisionScenario.financialPlanning,
  QuestionTopic.investment: DecisionScenario.investment,
  QuestionTopic.relationship: DecisionScenario.relationship,
  QuestionTopic.marriage: DecisionScenario.marriage,
  QuestionTopic.health: DecisionScenario.healthImprovement,
  QuestionTopic.education: DecisionScenario.education,
  QuestionTopic.business: DecisionScenario.businessStart,
  QuestionTopic.relocation: DecisionScenario.relocation,
  QuestionTopic.family: DecisionScenario.familyPlanning,
};

QuestionStance _directionalStance(DecisionAction a) => switch (a) {
      DecisionAction.shouldAct => QuestionStance.yes,
      DecisionAction.shouldPrepare => QuestionStance.prepareFirst,
      DecisionAction.shouldWait => QuestionStance.waitForBetterWindow,
      DecisionAction.shouldAvoid => QuestionStance.avoid,
    };

DecisionReasonKind _emphasisKind(QuestionIntentKind k) => switch (k) {
      QuestionIntentKind.shouldI => DecisionReasonKind.favourability,
      QuestionIntentKind.whenShouldI => DecisionReasonKind.timing,
      QuestionIntentKind.shouldIWait => DecisionReasonKind.timing,
      QuestionIntentKind.whatShouldIPrepare => DecisionReasonKind.risk,
      QuestionIntentKind.biggestOpportunity => DecisionReasonKind.favourability,
      QuestionIntentKind.biggestRisk => DecisionReasonKind.risk,
    };

void main() {
  group('V12 — coverage & structure', () {
    test('every topic × intent yields a well-formed result', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          for (final kind in QuestionIntentKind.values) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            expect(r.windows, isNotEmpty);
            expect(r.evidence, isNotEmpty);
            expect(r.reasons, isNotEmpty);
            expect(r.reasons.length, 4);
            expect(r.answer.focusWindow, isNotNull);
            expect(DecisionAction.values, contains(r.answer.action));
            expect(QuestionStance.values, contains(r.answer.stance));
          }
        }
      }
    });
  });

  group('V12 — scenario resolution', () {
    test('each topic routes to the documented decision scenario', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final r = QuestionReasoningEngine.fromDecision(
            decision,
            QuestionIntent(kind: QuestionIntentKind.shouldI, topic: topic),
          );
          expect(r.scenario.scenario, _expectedScenario[topic]);
          // routes to the exact V11 recommendation (no recomputation)
          expect(
            identical(
              r.scenario.recommendation,
              decision.forScenario(_expectedScenario[topic]!),
            ),
            isTrue,
          );
        }
      }
    });
  });

  group('V12 — intent mapping', () {
    test('directional intents map the verdict to a stance', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final rec = decision.forScenario(topic.scenario)!;
          for (final kind in [
            QuestionIntentKind.shouldI,
            QuestionIntentKind.shouldIWait,
          ]) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            expect(r.answer.action, rec.action);
            expect(r.answer.stance, _directionalStance(rec.action));
          }
        }
      }
    });

    test('informational intents are stance-informational', () {
      const infoIntents = [
        QuestionIntentKind.whenShouldI,
        QuestionIntentKind.whatShouldIPrepare,
        QuestionIntentKind.biggestOpportunity,
        QuestionIntentKind.biggestRisk,
      ];
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          for (final kind in infoIntents) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            expect(r.answer.stance, QuestionStance.informational);
          }
        }
      }
    });

    test('opportunity/risk intents focus the right outcome domain', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final rec = decision.forScenario(topic.scenario)!;
          final opp = QuestionReasoningEngine.fromDecision(
            decision,
            QuestionIntent(
              kind: QuestionIntentKind.biggestOpportunity,
              topic: topic,
            ),
          );
          final risk = QuestionReasoningEngine.fromDecision(
            decision,
            QuestionIntent(kind: QuestionIntentKind.biggestRisk, topic: topic),
          );
          expect(opp.answer.focusDomain, rec.outcome.leadingOpportunity);
          expect(risk.answer.focusDomain, rec.outcome.leadingRisk);
        }
      }
    });

    test('priority reasons lead with the intent emphasis axis', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          for (final kind in QuestionIntentKind.values) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            expect(r.reasons.first.kind, _emphasisKind(kind));
            expect(r.reasons.first.priority, 0);
            // priorities are a stable 0..n-1 sequence
            for (var i = 0; i < r.reasons.length; i++) {
              expect(r.reasons[i].priority, i);
            }
          }
        }
      }
    });
  });

  group('V12 — evidence traceability', () {
    test('every question-evidence atom comes from the V11 recommendation', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final rec = decision.forScenario(topic.scenario)!;
          for (final kind in QuestionIntentKind.values) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            for (final e in r.evidence) {
              expect(DecisionEvidenceSource.values, contains(e.atom.source));
              expect(e.relevance, greaterThanOrEqualTo(0));
              expect(
                rec.evidence.any((a) => identical(a, e.atom)),
                isTrue,
                reason: 'evidence atom not traceable to the recommendation',
              );
            }
            expect(r.evidence.length, lessThanOrEqualTo(5));
          }
        }
      }
    });
  });

  group('V12 — confidence stability', () {
    test('confidence equals the underlying decision confidence', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final rec = decision.forScenario(topic.scenario)!;
          for (final kind in QuestionIntentKind.values) {
            final r = QuestionReasoningEngine.fromDecision(
              decision,
              QuestionIntent(kind: kind, topic: topic),
            );
            expect(r.confidence, rec.confidence.value);
          }
        }
      }
    });

    test('all intents for a topic share the same confidence', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final values = <int>{
            for (final kind in QuestionIntentKind.values)
              QuestionReasoningEngine.fromDecision(
                decision,
                QuestionIntent(kind: kind, topic: topic),
              ).confidence,
          };
          expect(values.length, 1);
        }
      }
    });

    test('minConfidence constraint is reported, never silently applied', () {
      final decision = _decision(_birthDates.first);
      final rec = decision.forScenario(QuestionTopic.career.scenario)!;
      final c = rec.confidence.value;

      final met = QuestionReasoningEngine.fromDecision(
        decision,
        QuestionIntent(
          kind: QuestionIntentKind.shouldI,
          topic: QuestionTopic.career,
          constraint: QuestionConstraint(minConfidence: c),
        ),
      );
      expect(met.meetsConfidence, isTrue);
      expect(met.confidence, c);

      final unmet = QuestionReasoningEngine.fromDecision(
        decision,
        QuestionIntent(
          kind: QuestionIntentKind.shouldI,
          topic: QuestionTopic.career,
          constraint: QuestionConstraint(minConfidence: c + 1),
        ),
      );
      expect(unmet.meetsConfidence, isFalse);
      // the verdict/confidence are unchanged — only the flag differs
      expect(unmet.confidence, c);
      expect(unmet.answer.action, met.answer.action);
    });
  });

  group('V12 — horizon constraint', () {
    test('horizon focuses the matching best/worst window', () {
      for (final birth in _birthDates) {
        final decision = _decision(birth);
        for (final topic in QuestionTopic.values) {
          final rec = decision.forScenario(topic.scenario)!;
          final r = QuestionReasoningEngine.fromDecision(
            decision,
            QuestionIntent(
              kind: QuestionIntentKind.whenShouldI,
              topic: topic,
              constraint: QuestionConstraint(horizon: rec.worstTiming.kind),
            ),
          );
          if (rec.worstTiming.available) {
            expect(r.answer.focusWindow!.kind, rec.worstTiming.kind);
          }
        }
      }
    });
  });

  group('V12 — determinism', () {
    test('identical input → byte-identical results', () {
      for (final birth in _birthDates) {
        for (final topic in QuestionTopic.values) {
          for (final kind in QuestionIntentKind.values) {
            final intent = QuestionIntent(kind: kind, topic: topic);
            final a = QuestionReasoningEngine.fromBirthDate(
              birth,
              intent,
              lagnaLord: LifePlanet.venus,
              asOf: _asOf,
            );
            final b = QuestionReasoningEngine.fromBirthDate(
              birth,
              intent,
              lagnaLord: LifePlanet.venus,
              asOf: _asOf,
            );
            expect(a.answer.stance, b.answer.stance);
            expect(a.answer.action, b.answer.action);
            expect(a.confidence, b.confidence);
            expect(a.scenario.scenario, b.scenario.scenario);
            expect(a.windows.map((w) => w.kind).toList(),
                b.windows.map((w) => w.kind).toList());
            expect(a.windows.map((w) => w.role).toList(),
                b.windows.map((w) => w.role).toList());
            expect(a.reasons.map((x) => x.code).toList(),
                b.reasons.map((x) => x.code).toList());
            expect(a.evidence.map((e) => e.atom.source).toList(),
                b.evidence.map((e) => e.atom.source).toList());
            expect(a.evidence.map((e) => e.relevance).toList(),
                b.evidence.map((e) => e.relevance).toList());
          }
        }
      }
    });
  });
}
