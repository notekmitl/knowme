import 'package:knowme/features/astrology/thai/core/decision/decision_scenario.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/question/question_intent.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart'
    as thai;
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart'
    as thai;
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart'
    as thai;

import '../reasoning_capability.dart';
import '../reasoning_evidence.dart';
import '../reasoning_module.dart';
import '../reasoning_provider.dart';
import '../reasoning_provider_registry.dart';
import '../reasoning_request.dart';
import '../reasoning_response.dart';
import '../reasoning_trace.dart';

/// V17 — the Thai reference system as a global [ReasoningProvider].
///
/// This is the **only** provider implemented in V17. It does not merge or
/// rewrite the Thai runtime: it wraps the frozen `ThaiReasoningRuntime`, builds a
/// Thai request from the generic [ReasoningRequest]'s common fields +
/// `parameters` (`lagnaLord`, `questionIntent`, `scenarioFocus`), and maps the
/// Thai response into the system-agnostic [ReasoningResponse]. The native Thai
/// response is preserved in [ReasoningResponse.raw] for consumers that need it.
class ThaiRuntimeAdapter extends ReasoningProvider {
  const ThaiRuntimeAdapter({
    thai.ThaiReasoningRuntime runtime = const thai.ThaiReasoningRuntime(),
  }) : _runtime = runtime;

  final thai.ThaiReasoningRuntime _runtime;

  /// Registers a default Thai adapter into the global provider registry.
  static void register() =>
      ReasoningProviderRegistry.instance.register(const ThaiRuntimeAdapter());

  @override
  ReasoningModule get module => ReasoningModule.thaiAstrology;

  @override
  String get id => 'thai';

  @override
  String get displayName => 'Thai Astrology';

  @override
  Set<ReasoningCapability> get capabilities => const {
        ReasoningCapability.evaluate,
        ReasoningCapability.predict,
        ReasoningCapability.decide,
        ReasoningCapability.question,
        ReasoningCapability.answer,
      };

  @override
  ReasoningResponse run(ReasoningRequest request) {
    final birthDate = request.birthDate;
    if (birthDate == null) {
      throw ArgumentError('Thai reasoning requires a birthDate');
    }

    final thaiRequest = thai.ReasoningRequest(
      birthDate: birthDate,
      lagnaLord: request.parameters['lagnaLord'] as LifePlanet?,
      asOf: request.asOf,
      question: request.parameters['questionIntent'] as QuestionIntent?,
      scenarioFocus: request.parameters['scenarioFocus'] as DecisionScenario?,
    );

    final response = switch (request.capability) {
      ReasoningCapability.evaluate => _runtime.evaluate(thaiRequest),
      ReasoningCapability.predict => _runtime.predict(thaiRequest),
      ReasoningCapability.decide => _runtime.decide(thaiRequest),
      ReasoningCapability.question => _runtime.question(thaiRequest),
      ReasoningCapability.answer => _runtime.answer(thaiRequest),
    };

    return _map(request.capability, response);
  }

  ReasoningResponse _map(
    ReasoningCapability capability,
    thai.ReasoningResponse response,
  ) {
    final evidence = [
      for (final e in response.evidence)
        ReasoningEvidence(
          module: ReasoningModule.thaiAstrology,
          layer: e.layer.name,
          sourceName: e.sourceName,
          magnitude: e.magnitude,
          domain: e.domain?.name,
          tag: e.planet?.name,
        ),
    ];

    return ReasoningResponse(
      module: ReasoningModule.thaiAstrology,
      capability: capability,
      evidence: evidence,
      confidence: response.confidence,
      raw: response,
      trace: ReasoningTrace(
        module: ReasoningModule.thaiAstrology,
        capability: capability,
        steps: [
          ReasoningStep(label: 'provider', detail: id),
          ReasoningStep(label: 'thai.depth', detail: response.depth.name),
          ReasoningStep(label: 'evidence', detail: '${evidence.length}'),
        ],
      ),
    );
  }
}
