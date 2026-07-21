import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_reasoning_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_evidence.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';

const _runtime = ThaiReasoningRuntime();
final _asOf = DateTime(2026, 6, 27);

final _birthDates = <DateTime>[
  DateTime(1988, 3, 14), // Mon
  DateTime(1990, 7, 17), // Tue
  DateTime(1995, 1, 4), // Wed
  DateTime(1979, 11, 8), // Thu
  DateTime(2001, 5, 18), // Fri
  DateTime(1966, 9, 24), // Sat
  DateTime(2010, 2, 7), // Sun
  DateTime(1948, 12, 30), // old
];

ReasoningRequest _req(DateTime birth, {QuestionIntent? q}) =>
    ReasoningRequest(birthDate: birth, asOf: _asOf, question: q);

const _intent = QuestionIntent(
  kind: QuestionIntentKind.shouldI,
  topic: QuestionTopic.career,
);

void main() {
  group('V13 — API depth', () {
    test('predict runs timeline+prediction only', () {
      for (final b in _birthDates) {
        final r = _runtime.predict(_req(b));
        expect(r.depth, ReasoningDepth.prediction);
        expect(r.decision, isNull);
        expect(r.question, isNull);
        expect(r.prediction.predictionCount, greaterThan(0));
      }
    });

    test('decide runs through decision, not question', () {
      for (final b in _birthDates) {
        final r = _runtime.decide(_req(b));
        expect(r.depth, ReasoningDepth.decision);
        expect(r.decision, isNotNull);
        expect(r.question, isNull);
      }
    });

    test('question/answer run the full pipeline', () {
      for (final b in _birthDates) {
        final r = _runtime.question(_req(b, q: _intent));
        expect(r.depth, ReasoningDepth.question);
        expect(r.decision, isNotNull);
        expect(r.question, isNotNull);

        final a = _runtime.answer(_req(b, q: _intent));
        expect(a.depth, ReasoningDepth.question);
        expect(a.question, isNotNull);
      }
    });

    test('evaluate picks depth from whether a question is present', () {
      for (final b in _birthDates) {
        expect(_runtime.evaluate(_req(b)).depth, ReasoningDepth.decision);
        expect(_runtime.evaluate(_req(b, q: _intent)).depth,
            ReasoningDepth.question);
      }
    });
  });

  group('V13 — runtime consistency (matches the layers it orchestrates)', () {
    test('snapshots equal direct engine outputs', () {
      for (final b in _birthDates) {
        final r = _runtime.question(_req(b, q: _intent));

        final prediction = PredictionIntelligenceEngine.fromBirthDate(
          b,
          asOf: _asOf,
        );
        final decision = DecisionIntelligenceEngine.fromBirthDate(b, asOf: _asOf);
        final question = QuestionReasoningEngine.fromDecision(decision, _intent);

        expect(r.prediction.predictionCount, prediction.predictions.length);
        expect(
          r.decision!.recommendations.length,
          decision.recommendations.length,
        );
        // decision focus = most actionable when no scenario focus
        expect(r.decision!.focus.scenario, decision.ranked.first.scenario);
        expect(r.decision!.focus.action, decision.ranked.first.action);
        // question snapshot mirrors the question engine
        expect(r.question!.result.answer.action, question.answer.action);
        expect(r.question!.result.confidence, question.confidence);
        expect(r.confidence, question.confidence);
      }
    });

    test('scenarioFocus centres the decision snapshot', () {
      for (final b in _birthDates) {
        final r = _runtime.decide(ReasoningRequest(
          birthDate: b,
          asOf: _asOf,
          scenarioFocus: DecisionScenario.marriage,
        ));
        expect(r.decision!.focus.scenario, DecisionScenario.marriage);
        expect(r.confidence, r.decision!.focus.confidence.value);
      }
    });
  });

  group('V13 — trace integrity', () {
    test('trace always lists four layers in pipeline order', () {
      for (final b in _birthDates) {
        for (final r in [
          _runtime.predict(_req(b)),
          _runtime.decide(_req(b)),
          _runtime.question(_req(b, q: _intent)),
        ]) {
          expect(r.trace.steps.map((s) => s.layer).toList(), [
            ReasoningLayer.timeline,
            ReasoningLayer.prediction,
            ReasoningLayer.decision,
            ReasoningLayer.question,
          ]);
        }
      }
    });

    test('step status matches the depth that ran', () {
      for (final b in _birthDates) {
        final predict = _runtime.predict(_req(b));
        expect(predict.trace.stepFor(ReasoningLayer.timeline).ran, isTrue);
        expect(predict.trace.stepFor(ReasoningLayer.prediction).ran, isTrue);
        expect(predict.trace.stepFor(ReasoningLayer.decision).ran, isFalse);
        expect(predict.trace.stepFor(ReasoningLayer.question).ran, isFalse);

        final decide = _runtime.decide(_req(b));
        expect(decide.trace.stepFor(ReasoningLayer.decision).ran, isTrue);
        expect(decide.trace.stepFor(ReasoningLayer.question).ran, isFalse);

        final q = _runtime.question(_req(b, q: _intent));
        expect(q.trace.stepFor(ReasoningLayer.question).ran, isTrue);
      }
    });

    test('ran steps have positive output, skipped steps are zeroed', () {
      for (final b in _birthDates) {
        final q = _runtime.question(_req(b, q: _intent));
        for (final s in q.trace.steps) {
          if (s.ran) {
            expect(s.outputCount, greaterThan(0));
          } else {
            expect(s.outputCount, 0);
            expect(s.confidence, 0);
          }
        }
        final predict = _runtime.predict(_req(b));
        expect(predict.trace.stepFor(ReasoningLayer.decision).outputCount, 0);
      }
    });
  });

  group('V13 — evidence integrity', () {
    test('evidence is non-empty and only from layers that ran', () {
      for (final b in _birthDates) {
        final predict = _runtime.predict(_req(b));
        expect(predict.evidence, isNotEmpty);
        final ranLayers =
            predict.trace.ranSteps.map((s) => s.layer).toSet();
        for (final e in predict.evidence) {
          expect(ranLayers, contains(e.layer));
        }
        expect(
          predict.evidence.any((e) => e.layer == ReasoningLayer.decision),
          isFalse,
        );
      }
    });

    test('timeline evidence carries the natal harmony score', () {
      for (final b in _birthDates) {
        final r = _runtime.decide(_req(b));
        final natal = r.evidence.firstWhere(
          (e) => e.layer == ReasoningLayer.timeline,
        );
        expect(
          natal.magnitude,
          r.timeline.source.currentAge.intelligence.natalHarmonyScore,
        );
      }
    });

    test('decision evidence magnitudes match the focus recommendation', () {
      for (final b in _birthDates) {
        final r = _runtime.decide(_req(b));
        final decisionAtoms = r.evidence
            .where((e) => e.layer == ReasoningLayer.decision)
            .map((e) => e.magnitude)
            .toList();
        final focusMagnitudes =
            r.decision!.focus.evidence.map((e) => e.magnitude).toList();
        expect(decisionAtoms, focusMagnitudes);
      }
    });

    test('full-pipeline evidence covers all four layers', () {
      for (final b in _birthDates) {
        final r = _runtime.question(_req(b, q: _intent));
        final layers = r.evidence.map((e) => e.layer).toSet();
        expect(layers, contains(ReasoningLayer.timeline));
        expect(layers, contains(ReasoningLayer.prediction));
        expect(layers, contains(ReasoningLayer.decision));
        expect(layers, contains(ReasoningLayer.question));
      }
    });
  });

  group('V13 — determinism', () {
    test('identical request → byte-identical response', () {
      for (final b in _birthDates) {
        final req = ReasoningRequest(
          birthDate: b,
          asOf: _asOf,
          lagnaLord: LifePlanet.venus,
          question: _intent,
        );
        final a = _runtime.evaluate(req);
        final c = _runtime.evaluate(req);
        expect(a.depth, c.depth);
        expect(a.confidence, c.confidence);
        expect(_sig(a), _sig(c));
      }
    });
  });
}

/// A stable signature of a response for determinism comparison.
String _sig(ReasoningResponse r) {
  final evidence = r.evidence
      .map((e) => '${e.layer.name}:${e.sourceName}:${e.magnitude}')
      .join('|');
  final trace = r.trace.steps
      .map((s) => '${s.layer.name}:${s.status.name}:${s.outputCount}:${s.confidence}')
      .join('|');
  return [
    r.depth.name,
    r.confidence.toString(),
    r.timeline.currentAge.toString(),
    r.timeline.currentPlanet.name,
    r.prediction.predictionCount.toString(),
    r.decision?.focus.scenario.name ?? '-',
    r.decision?.focus.action.name ?? '-',
    r.question?.result.answer.stance.name ?? '-',
    trace,
    evidence,
  ].join('#');
}
