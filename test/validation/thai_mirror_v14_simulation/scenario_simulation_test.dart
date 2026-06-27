import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';
import 'package:knowme/features/astrology/thai/core/simulation/scenario_simulation_engine.dart';
import 'package:knowme/features/astrology/thai/core/simulation/simulation_option.dart';
import 'package:knowme/features/astrology/thai/core/simulation/simulation_outcome.dart';
import 'package:knowme/features/astrology/thai/core/simulation/simulation_result.dart';
import 'package:knowme/features/astrology/thai/core/simulation/simulation_scenario.dart';

const _runtime = ThaiReasoningRuntime();
final _asOf = DateTime(2026, 6, 27);

final _birthDates = <DateTime>[
  DateTime(1988, 3, 14),
  DateTime(1990, 7, 17),
  DateTime(1995, 1, 4),
  DateTime(1979, 11, 8),
  DateTime(2001, 5, 18),
  DateTime(1966, 9, 24),
  DateTime(2010, 2, 7),
  DateTime(1948, 12, 30),
];

const _optionOrder = <SimulationOptionKind>[
  SimulationOptionKind.actNow,
  SimulationOptionKind.actAtBestWindow,
  SimulationOptionKind.actAtAlternativeWindow,
  SimulationOptionKind.doNothing,
];

SimulationResult _simulate(DateTime birth, SimulationScenario scenario) =>
    ScenarioSimulationEngine.simulate(
      birthDate: birth,
      scenario: scenario,
      asOf: _asOf,
    );

void main() {
  group('V14 — scenario consistency', () {
    test('every scenario yields the four options in fixed order', () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          final r = _simulate(b, s);
          expect(r.scenario, s);
          expect(r.outcomes.length, 4);
          expect(
            r.outcomes.map((o) => o.option.kind).toList(),
            _optionOrder,
          );
        }
      }
    });

    test('acting paths carry an action; Do Nothing does not; baseline is neutral',
        () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          final r = _simulate(b, s);
          final doNothing = r.outcomes.last;
          expect(doNothing.option.kind, SimulationOptionKind.doNothing);
          expect(doNothing.action, isNull);
          expect(doNothing.expected.score,
              ScenarioSimulationEngine.neutralBaseline);
          expect(doNothing.timing, isNull);

          for (final o in r.outcomes.take(3)) {
            expect(o.action, isNotNull);
            expect(o.timing, isNotNull);
          }
        }
      }
    });
  });

  group('V14 — runtime consistency (consumes the runtime only)', () {
    test('each option outcome matches the runtime decide at its evaluatedAsOf',
        () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          final r = _simulate(b, s);
          final ds = s.decisionScenario;

          for (final o in r.outcomes) {
            final asOf = o.option.evaluatedAsOf!;
            final response = _runtime.decide(ReasoningRequest(
              birthDate: b,
              asOf: asOf,
              scenarioFocus: ds,
            ));

            if (o.option.kind == SimulationOptionKind.doNothing) {
              // Status quo: neutral expected, but evidence comes from the runtime.
              expect(o.expected.score,
                  ScenarioSimulationEngine.neutralBaseline);
            } else {
              expect(
                o.expected.score,
                response.decision!.focus.outcome.favourability,
              );
              expect(o.action, response.decision!.focus.action);
              expect(o.confidence.value, response.confidence);
            }
          }
        }
      }
    });
  });

  group('V14 — evidence traceability', () {
    test('every evidence atom traces to a runtime atom; capped; relevance set',
        () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          final r = _simulate(b, s);
          final ds = s.decisionScenario;

          for (final o in r.outcomes) {
            final response = _runtime.decide(ReasoningRequest(
              birthDate: b,
              asOf: o.option.evaluatedAsOf!,
              scenarioFocus: ds,
            ));
            final runtimeAtoms = response.evidence
                .map((e) => '${e.layer.name}:${e.sourceName}:${e.magnitude}')
                .toSet();

            expect(o.evidence.length,
                lessThanOrEqualTo(ScenarioSimulationEngine.maxEvidence));
            expect(o.evidence, isNotEmpty);
            for (final ev in o.evidence) {
              expect(ev.option, o.option.kind);
              expect(ev.relevance, ev.atom.magnitude.abs());
              final sig =
                  '${ev.atom.layer.name}:${ev.atom.sourceName}:${ev.atom.magnitude}';
              expect(runtimeAtoms, contains(sig));
            }
          }
        }
      }
    });
  });

  group('V14 — comparison stability', () {
    test('ranked is a non-increasing permutation; ends are best/worst', () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          final r = _simulate(b, s);
          final c = r.comparison;

          expect(c.ranked.length, 4);
          expect(c.ranked.toSet().length, 4);
          expect(c.ranked.toSet(), r.outcomes.toSet());

          for (var i = 0; i < c.ranked.length - 1; i++) {
            expect(
              c.ranked[i].expected.score,
              greaterThanOrEqualTo(c.ranked[i + 1].expected.score),
            );
          }
          expect(c.best, c.ranked.first);
          expect(c.worst, c.ranked.last);
          expect(c.doNothing.option.kind, SimulationOptionKind.doNothing);
          expect(
            c.valueOfActing,
            c.best.expected.score - c.doNothing.expected.score,
          );
          expect(r.confidence.value, c.best.confidence.value);
        }
      }
    });
  });

  group('V14 — determinism', () {
    test('identical inputs → identical result', () {
      for (final b in _birthDates) {
        for (final s in SimulationScenario.values) {
          expect(_sig(_simulate(b, s)), _sig(_simulate(b, s)));
        }
      }
    });
  });
}

String _outcomeSig(SimulationOutcome o) => [
      o.option.kind.name,
      o.option.targetAge?.toString() ?? '-',
      o.option.evaluatedAsOf?.toIso8601String() ?? '-',
      o.expected.score,
      o.expected.band.name,
      o.opportunity?.score.toString() ?? '-',
      o.opportunity?.domain?.name ?? '-',
      o.risk?.score.toString() ?? '-',
      o.risk?.domain?.name ?? '-',
      o.timing?.startAge.toString() ?? '-',
      o.timing?.endAge.toString() ?? '-',
      o.confidence.value,
      o.action?.name ?? '-',
      o.evidence
          .map((e) =>
              '${e.atom.layer.name}/${e.atom.sourceName}/${e.atom.magnitude}/${e.relevance}')
          .join(','),
    ].join(':');

String _sig(SimulationResult r) => [
      r.scenario.name,
      r.confidence.value,
      r.comparison.best.option.kind.name,
      r.comparison.worst.option.kind.name,
      r.comparison.valueOfActing,
      r.comparison.ranked.map((o) => o.option.kind.name).join('>'),
      r.outcomes.map(_outcomeSig).join('#'),
    ].join('|');
