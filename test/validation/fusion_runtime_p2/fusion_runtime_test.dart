import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';
import 'package:knowme/features/runtime/adapters/thai_runtime_adapter.dart';
import 'package:knowme/features/runtime/fusion/fusion_confidence.dart';
import 'package:knowme/features/runtime/fusion/fusion_context.dart';
import 'package:knowme/features/runtime/fusion/fusion_runtime.dart';
import 'package:knowme/features/runtime/reasoning_capability.dart';
import 'package:knowme/features/runtime/reasoning_evidence.dart';
import 'package:knowme/features/runtime/reasoning_module.dart';
import 'package:knowme/features/runtime/reasoning_provider.dart';
import 'package:knowme/features/runtime/reasoning_request.dart';
import 'package:knowme/features/runtime/reasoning_response.dart';
import 'package:knowme/features/runtime/reasoning_runtime.dart';
import 'package:knowme/features/runtime/reasoning_trace.dart';

/// A deterministic stub provider that emits fixed, domain-tagged evidence.
class _StubProvider extends ReasoningProvider {
  const _StubProvider(this.module, this.id, this._domainNets, this._confidence);

  @override
  final ReasoningModule module;
  @override
  final String id;
  final Map<String, int> _domainNets;
  final int _confidence;

  @override
  String get displayName => id;

  @override
  Set<ReasoningCapability> get capabilities =>
      const {ReasoningCapability.evaluate};

  @override
  ReasoningResponse run(ReasoningRequest request) => ReasoningResponse(
        module: module,
        capability: request.capability,
        confidence: _confidence,
        evidence: [
          for (final e in _domainNets.entries)
            ReasoningEvidence(
              module: module,
              layer: 'stub',
              sourceName: 'stub_${e.key}',
              magnitude: e.value,
              domain: e.key,
            ),
        ],
        trace: ReasoningTrace(
          module: module,
          capability: request.capability,
        ),
      );
}

FusionContext _evaluate() => FusionContext(
      capability: ReasoningCapability.evaluate,
      birthDate: DateTime(1990, 7, 17),
      asOf: DateTime(2026, 6, 27),
    );

void main() {
  group('P2 — single-provider mode (Thai only)', () {
    const fusion = FusionRuntime(ReasoningRuntime([ThaiRuntimeAdapter()]));

    test('detects single-provider mode and still produces a result', () {
      final result = fusion.fuse(FusionContext(
        capability: ReasoningCapability.question,
        birthDate: DateTime(1990, 7, 17),
        asOf: DateTime(2026, 6, 27),
        parameters: const {
          'questionIntent': QuestionIntent(
            kind: QuestionIntentKind.shouldI,
            topic: QuestionTopic.career,
          ),
        },
      ));

      expect(result.singleProviderMode, isTrue);
      expect(result.observations.single.module, ReasoningModule.thaiAstrology);
      expect(result.agreements, isEmpty);
      expect(result.conflicts, isEmpty);
      expect(result.missingEvidence, isEmpty);
      expect(result.mergedEvidence, isNotEmpty);
      // Confidence passes through unchanged from the sole provider.
      expect(result.confidence.value, result.observations.single.confidence);
      expect(result.confidence.providerCount, 1);
    });
  });

  group('P2 — agreement detection', () {
    test('same-sign domains across two providers agree', () {
      const fusion = FusionRuntime(ReasoningRuntime([
        _StubProvider(ReasoningModule.thaiAstrology, 'a', {'career': 10}, 60),
        _StubProvider(ReasoningModule.westernAstrology, 'b', {'career': 6}, 50),
      ]));

      final result = fusion.fuse(_evaluate());

      expect(result.singleProviderMode, isFalse);
      final career = result.agreements.singleWhere((x) => x.domain == 'career');
      expect(career.direction, 1);
      expect(career.magnitude, 16);
      expect(career.modules, hasLength(2));
      expect(result.conflicts, isEmpty);
      // Agreement boosts confidence above the provider average (55).
      expect(result.confidence.value, greaterThan(55));
    });
  });

  group('P2 — conflict detection', () {
    test('opposite-sign domains across two providers conflict', () {
      const fusion = FusionRuntime(ReasoningRuntime([
        _StubProvider(ReasoningModule.thaiAstrology, 'a', {'money': 8}, 60),
        _StubProvider(ReasoningModule.bazi, 'b', {'money': -8}, 60),
      ]));

      final result = fusion.fuse(_evaluate());

      final money = result.conflicts.singleWhere((x) => x.domain == 'money');
      expect(money.positiveModules, [ReasoningModule.thaiAstrology]);
      expect(money.negativeModules, [ReasoningModule.bazi]);
      expect(money.spread, 16);
      expect(result.agreements, isEmpty);
      // Conflict penalises confidence below the provider average (60).
      expect(result.confidence.value, lessThan(60));
    });
  });

  group('P2 — priority ordering', () {
    test('domains rank by strength with an agreement boost', () {
      const fusion = FusionRuntime(ReasoningRuntime([
        _StubProvider(
            ReasoningModule.thaiAstrology, 'a', {'career': 5, 'money': 9}, 60),
        _StubProvider(ReasoningModule.westernAstrology, 'b', {'career': 5}, 60),
      ]));

      final result = fusion.fuse(_evaluate());

      // career: |10| + agreement boost 10 = 20; money: |9| + 0 = 9.
      expect(result.priorities.first.domain, 'career');
      expect(result.priorities.first.rank, 1);
      expect(result.priorities.first.agreed, isTrue);
      expect(result.priorities.first.score,
          greaterThan(result.priorities.last.score));
      final ranks = result.priorities.map((p) => p.rank).toList();
      expect(ranks, [for (var i = 1; i <= ranks.length; i++) i]);
    });
  });

  group('P2 — evidence merge & missing detection', () {
    test('merges domain magnitudes and flags partial coverage', () {
      const fusion = FusionRuntime(ReasoningRuntime([
        _StubProvider(
            ReasoningModule.thaiAstrology, 'a', {'career': 7, 'health': 4}, 60),
        _StubProvider(ReasoningModule.westernAstrology, 'b', {'career': 3}, 60),
      ]));

      final result = fusion.fuse(_evaluate());

      final career =
          result.mergedEvidence.singleWhere((e) => e.domain == 'career');
      expect(career.netMagnitude, 10);
      expect(career.modules, hasLength(2));

      // health came from only one provider → missing across providers.
      expect(result.missingEvidence, contains('health'));
      expect(result.missingEvidence, isNot(contains('career')));
    });
  });

  group('P2 — confidence banding', () {
    test('bands the fused value via the rule thresholds', () {
      const fusion = FusionRuntime(ReasoningRuntime([
        _StubProvider(ReasoningModule.thaiAstrology, 'a', {'career': 5}, 80),
        _StubProvider(ReasoningModule.westernAstrology, 'b', {'career': 5}, 80),
      ]));

      final result = fusion.fuse(_evaluate());
      expect(result.confidence.band, FusionConfidenceBand.high);
    });
  });
}
