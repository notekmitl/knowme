import 'package:knowme/features/astrology/thai/core/runtime/reasoning_request.dart';
import 'package:knowme/features/astrology/thai/core/runtime/reasoning_response.dart';
import 'package:knowme/features/astrology/thai/core/runtime/thai_reasoning_runtime.dart';

import 'enhanced_reasoning_response.dart';
import 'transit_context.dart';
import 'transit_intelligence_engine.dart';

/// V15 — the Enhanced Runtime: **Runtime + Transit**.
///
/// It wraps the frozen V13 [ThaiReasoningRuntime] (it never modifies it),
/// mirrors its five APIs, and for each call evaluates the current transit and
/// merges its evidence into the response. Transit is an enhancement layer that
/// contributes evidence only — the base reasoning (decisions, predictions,
/// answers, confidence) is left exactly as the runtime produced it.
///
/// Reasoning stays inside the runtime; transit never bypasses it. Future
/// Compatibility and AI Conversation features consume this Enhanced Runtime.
class EnhancedReasoningRuntime {
  const EnhancedReasoningRuntime({
    this.runtime = const ThaiReasoningRuntime(),
  });

  final ThaiReasoningRuntime runtime;

  EnhancedReasoningResponse evaluate(ReasoningRequest request) =>
      _enhance(runtime.evaluate(request), request);

  EnhancedReasoningResponse predict(ReasoningRequest request) =>
      _enhance(runtime.predict(request), request);

  EnhancedReasoningResponse decide(ReasoningRequest request) =>
      _enhance(runtime.decide(request), request);

  EnhancedReasoningResponse question(ReasoningRequest request) =>
      _enhance(runtime.question(request), request);

  EnhancedReasoningResponse answer(ReasoningRequest request) =>
      _enhance(runtime.answer(request), request);

  EnhancedReasoningResponse _enhance(
    ReasoningResponse base,
    ReasoningRequest request,
  ) {
    final context = TransitContext.fromResponse(
      base,
      birthDate: request.birthDate,
      asOf: request.asOf,
    );
    return EnhancedReasoningResponse(
      base: base,
      transit: TransitIntelligenceEngine.evaluate(context),
    );
  }
}
