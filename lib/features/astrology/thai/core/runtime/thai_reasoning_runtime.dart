import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_recommendation.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_reasoning_engine.dart';
import 'package:knowme/features/astrology/thai/core/question/question_result.dart';

import 'reasoning_context.dart';
import 'reasoning_evidence.dart';
import 'reasoning_request.dart';
import 'reasoning_response.dart';
import 'reasoning_snapshot.dart';
import 'reasoning_trace.dart';

/// V13 — Unified Reasoning Runtime.
///
/// The single public entry point for Thai reasoning. It orchestrates the V9
/// Timeline, V10 Prediction, V11 Decision and V12 Question layers behind one
/// surface, so callers never wire the layers together themselves and never
/// depend on the internal pipeline. It is **not** AI, **not** Transit and
/// **not** Compatibility — it is pure, deterministic orchestration with no copy,
/// no presenter, no UI, no Firestore, no parser and no LLM.
///
/// Future features (Transit, Compatibility, AI Conversation) must consume this
/// runtime only.
class ThaiReasoningRuntime {
  const ThaiReasoningRuntime();

  // --- Public APIs ---------------------------------------------------------

  /// Run the full pipeline appropriate to the [request]: through Decision, and
  /// through Question when the request carries an intent.
  ReasoningResponse evaluate(ReasoningRequest request) => _run(
        request,
        request.question != null
            ? ReasoningDepth.question
            : ReasoningDepth.decision,
      );

  /// Timeline + Prediction only.
  ReasoningResponse predict(ReasoningRequest request) =>
      _run(request, ReasoningDepth.prediction);

  /// Timeline + Prediction + Decision.
  ReasoningResponse decide(ReasoningRequest request) =>
      _run(request, ReasoningDepth.decision);

  /// Full pipeline including the Question layer. Requires [request.question].
  ReasoningResponse question(ReasoningRequest request) {
    assert(
      request.question != null,
      'question() requires request.question to be set',
    );
    return _run(request, ReasoningDepth.question);
  }

  /// Ergonomic alias for [question]: answer a structured question end-to-end.
  ReasoningResponse answer(ReasoningRequest request) => question(request);

  // --- Orchestration -------------------------------------------------------

  ReasoningResponse _run(ReasoningRequest request, ReasoningDepth depth) {
    final runDecision = depth.index >= ReasoningDepth.decision.index;
    final runQuestion =
        depth == ReasoningDepth.question && request.question != null;

    final timeline = LifeTimelineIntelligenceEngine.fromBirthDate(
      request.birthDate,
      lagnaLord: request.lagnaLord,
      asOf: request.asOf,
    );
    final prediction = PredictionIntelligenceEngine.fromIntelligence(timeline);

    DecisionIntelligence? decision;
    QuestionResult? question;
    if (runDecision || runQuestion) {
      decision = DecisionIntelligenceEngine.fromPrediction(prediction);
    }
    if (runQuestion) {
      question = QuestionReasoningEngine.fromDecision(
        decision!,
        request.question!,
      );
    }

    final context = ReasoningContext(
      timeline: timeline,
      prediction: prediction,
      decision: decision,
      question: question,
    );
    // The effective depth honours what actually ran.
    final effectiveDepth = question != null
        ? ReasoningDepth.question
        : decision != null
            ? ReasoningDepth.decision
            : ReasoningDepth.prediction;
    return _assemble(request, effectiveDepth, context);
  }

  ReasoningResponse _assemble(
    ReasoningRequest request,
    ReasoningDepth depth,
    ReasoningContext context,
  ) {
    final topPrediction = _topPrediction(context.prediction);
    final focus = context.decision == null
        ? null
        : _focusRecommendation(request, context.decision!);

    final timelineSnap = TimelineSnapshot.of(context.timeline);
    final predictionSnap = PredictionSnapshot.of(context.prediction);
    final decisionSnap = (context.decision != null && focus != null)
        ? DecisionSnapshot.of(context.decision!, focus)
        : null;
    final questionSnap = context.question == null
        ? null
        : QuestionSnapshot(result: context.question!);

    final confidence = questionSnap != null
        ? questionSnap.confidence
        : focus != null
            ? focus.confidence.value
            : (topPrediction?.confidence ?? 0);

    return ReasoningResponse(
      depth: depth,
      timeline: timelineSnap,
      prediction: predictionSnap,
      decision: decisionSnap,
      question: questionSnap,
      evidence: _evidence(context, topPrediction, focus),
      trace: _trace(context, topPrediction, focus, confidence),
      confidence: confidence,
    );
  }

  // --- Trace ---------------------------------------------------------------

  ReasoningTrace _trace(
    ReasoningContext context,
    Prediction? topPrediction,
    DecisionRecommendation? focus,
    int confidence,
  ) {
    ReasoningStep step(
      ReasoningLayer layer,
      bool ran,
      int outputCount,
      int conf,
    ) =>
        ReasoningStep(
          layer: layer,
          status: ran ? ReasoningStepStatus.ran : ReasoningStepStatus.skipped,
          outputCount: ran ? outputCount : 0,
          confidence: ran ? conf : 0,
        );

    return ReasoningTrace(
      steps: [
        step(ReasoningLayer.timeline, true, 1, 0),
        step(
          ReasoningLayer.prediction,
          true,
          context.prediction.predictions.length,
          topPrediction?.confidence ?? 0,
        ),
        step(
          ReasoningLayer.decision,
          context.decision != null,
          context.decision?.recommendations.length ?? 0,
          focus?.confidence.value ?? 0,
        ),
        step(
          ReasoningLayer.question,
          context.question != null,
          context.question != null ? 1 : 0,
          context.question?.confidence ?? 0,
        ),
      ],
    );
  }

  // --- Evidence (flattened across ran layers) ------------------------------

  List<ReasoningEvidence> _evidence(
    ReasoningContext context,
    Prediction? topPrediction,
    DecisionRecommendation? focus,
  ) {
    final intel = context.timeline.currentAge.intelligence;
    final list = <ReasoningEvidence>[
      ReasoningEvidence(
        layer: ReasoningLayer.timeline,
        sourceName: 'natalHarmony',
        magnitude: intel.natalHarmonyScore,
        planet: intel.planet,
      ),
    ];

    if (topPrediction != null) {
      for (final e in topPrediction.evidence) {
        list.add(ReasoningEvidence(
          layer: ReasoningLayer.prediction,
          sourceName: e.source.name,
          magnitude: e.magnitude,
          domain: e.domain,
          planet: e.planet,
        ));
      }
    }

    if (focus != null) {
      for (final e in focus.evidence) {
        list.add(ReasoningEvidence(
          layer: ReasoningLayer.decision,
          sourceName: e.source.name,
          magnitude: e.magnitude,
          domain: e.domain,
          planet: e.planet,
        ));
      }
    }

    if (context.question != null) {
      for (final qe in context.question!.evidence) {
        list.add(ReasoningEvidence(
          layer: ReasoningLayer.question,
          sourceName: qe.atom.source.name,
          magnitude: qe.atom.magnitude,
          domain: qe.atom.domain,
          planet: qe.atom.planet,
        ));
      }
    }

    return list;
  }

  // --- Selection helpers ---------------------------------------------------

  Prediction? _topPrediction(PredictionIntelligence prediction) {
    final ranked = prediction.ranked;
    return ranked.isEmpty ? null : ranked.first;
  }

  DecisionRecommendation _focusRecommendation(
    ReasoningRequest request,
    DecisionIntelligence decision,
  ) {
    final scenario = request.scenarioFocus;
    if (scenario != null) {
      final r = decision.forScenario(scenario);
      if (r != null) return r;
    }
    return decision.ranked.first;
  }
}
