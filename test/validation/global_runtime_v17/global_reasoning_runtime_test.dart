import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/question/question_topic.dart';
import 'package:knowme/features/runtime/adapters/thai_runtime_adapter.dart';
import 'package:knowme/features/runtime/reasoning_capability.dart';
import 'package:knowme/features/runtime/reasoning_module.dart';
import 'package:knowme/features/runtime/reasoning_provider_registry.dart';
import 'package:knowme/features/runtime/reasoning_request.dart';
import 'package:knowme/features/runtime/reasoning_runtime.dart';

final _asOf = DateTime(2026, 6, 27);
final _birth = DateTime(1990, 7, 17);

const _runtime = ReasoningRuntime([ThaiRuntimeAdapter()]);

ReasoningRequest _request(
  ReasoningCapability capability, {
  QuestionIntent? intent,
}) =>
    ReasoningRequest(
      module: ReasoningModule.thaiAstrology,
      capability: capability,
      birthDate: _birth,
      asOf: _asOf,
      parameters: {'questionIntent': intent},
    );

void main() {
  group('V17 — provider registration & discovery', () {
    setUp(ReasoningProviderRegistry.instance.clear);
    tearDown(ReasoningProviderRegistry.instance.clear);

    test('registry registers a provider and discovery picks it up', () {
      expect(ReasoningProviderRegistry.instance.providers, isEmpty);

      ThaiRuntimeAdapter.register();
      expect(ReasoningProviderRegistry.instance.providers.single.id, 'thai');

      final runtime = ReasoningRuntime.discover();
      expect(runtime.modules, {ReasoningModule.thaiAstrology});
    });

    test('registration is idempotent by id', () {
      ThaiRuntimeAdapter.register();
      ThaiRuntimeAdapter.register();
      expect(ReasoningProviderRegistry.instance.providers.length, 1);
    });
  });

  group('V17 — runtime dispatch', () {
    test('dispatches a Thai request to the Thai provider', () {
      final response = _runtime.run(_request(
        ReasoningCapability.question,
        intent: const QuestionIntent(
          kind: QuestionIntentKind.shouldI,
          topic: QuestionTopic.career,
        ),
      ));
      expect(response.module, ReasoningModule.thaiAstrology);
      expect(response.capability, ReasoningCapability.question);
      expect(response.confidence, inInclusiveRange(0, 100));
      expect(response.raw, isNotNull);
    });

    test('convenience methods set the capability', () {
      expect(_runtime.evaluate(_request(ReasoningCapability.question)).capability,
          ReasoningCapability.evaluate);
      expect(_runtime.predict(_request(ReasoningCapability.evaluate)).capability,
          ReasoningCapability.predict);
    });

    test('throws for an unregistered module', () {
      expect(
        () => _runtime.run(ReasoningRequest(
          module: ReasoningModule.westernAstrology,
          capability: ReasoningCapability.evaluate,
          birthDate: _birth,
        )),
        throwsStateError,
      );
    });
  });

  group('V17 — capability detection', () {
    test('exposes the Thai provider capabilities', () {
      expect(_runtime.capabilitiesFor(ReasoningModule.thaiAstrology), {
        ReasoningCapability.evaluate,
        ReasoningCapability.predict,
        ReasoningCapability.decide,
        ReasoningCapability.question,
        ReasoningCapability.answer,
      });
      expect(
          _runtime.supports(
              ReasoningModule.thaiAstrology, ReasoningCapability.question),
          isTrue);
    });

    test('reports unsupported modules/capabilities', () {
      expect(_runtime.capabilitiesFor(ReasoningModule.bazi), isEmpty);
      expect(
          _runtime.supports(
              ReasoningModule.mbti, ReasoningCapability.evaluate),
          isFalse);
    });
  });

  group('V17 — evidence aggregation', () {
    test('flattens module-tagged evidence from a response', () {
      final response = _runtime.evaluate(_request(ReasoningCapability.evaluate));
      expect(response.evidence, isNotEmpty);
      for (final e in response.evidence) {
        expect(e.module, ReasoningModule.thaiAstrology);
        expect(e.layer, isNotEmpty);
        expect(e.sourceName, isNotEmpty);
      }
    });

    test('aggregate() merges evidence across responses in order', () {
      final a = _runtime.evaluate(_request(ReasoningCapability.evaluate));
      final b = _runtime.predict(_request(ReasoningCapability.predict));
      final merged = _runtime.aggregate([a, b]);
      expect(merged.length, a.evidence.length + b.evidence.length);
    });
  });
}
