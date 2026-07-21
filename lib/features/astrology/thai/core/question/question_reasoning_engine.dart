import 'package:knowme/features/astrology/thai/core/decision/decision_action.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_evidence.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_reason.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_recommendation.dart';
import 'package:knowme/features/astrology/thai/core/decision/decision_window.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';

import 'question_answer.dart';
import 'question_constraint.dart';
import 'question_context.dart';
import 'question_evidence.dart';
import 'question_intent.dart';
import 'question_reason.dart';
import 'question_result.dart';
import 'question_scenario.dart';
import 'question_topic.dart';
import 'question_window.dart';

/// V12 — Question Reasoning Foundation engine.
///
/// A pure, deterministic layer that turns a structured [QuestionIntent] (intent
/// object, **never parsed text**) into a structured [QuestionResult] by routing
/// into the V11 [DecisionIntelligence] and re-projecting the existing decision
/// evidence through the lens of the asked intent. It recomputes nothing.
///
/// It is **not** AI, has **no LLM, no parser, no copy, no presenter and no UI**,
/// so it can be reused by Transit, Compatibility, Future AI and a Voice
/// Assistant.
abstract final class QuestionReasoningEngine {
  /// Relevance boost when an evidence source matches the intent's emphasis.
  static const int _emphasisBonus = 50;

  /// Max number of relevant-evidence atoms surfaced per question.
  static const int _maxEvidence = 5;

  // --- Entry points --------------------------------------------------------

  static QuestionResult fromBirthDate(
    DateTime birthDate,
    QuestionIntent intent, {
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) {
    return fromDecision(
      DecisionIntelligenceEngine.fromBirthDate(
        birthDate,
        lagnaLord: lagnaLord,
        asOf: asOf,
      ),
      intent,
    );
  }

  static QuestionResult fromDecision(
    DecisionIntelligence decision,
    QuestionIntent intent,
  ) =>
      resolve(QuestionContext.fromDecision(decision), intent);

  /// The core deterministic resolution.
  static QuestionResult resolve(QuestionContext context, QuestionIntent intent) {
    final scenario = intent.topic.scenario;
    final recommendation = context.decision.forScenario(scenario)!;

    final focus = _focusWindow(recommendation, intent.constraint);

    return QuestionResult(
      intent: intent,
      scenario: QuestionScenario(
        topic: intent.topic,
        scenario: scenario,
        recommendation: recommendation,
      ),
      answer: _answer(recommendation, intent.kind, focus),
      windows: _windows(recommendation, intent.kind, focus),
      evidence: _evidence(recommendation, intent.kind),
      reasons: _reasons(recommendation, intent.kind),
      confidence: recommendation.confidence.value,
    );
  }

  // --- Window selection ----------------------------------------------------

  static DecisionWindow _focusWindow(
    DecisionRecommendation recommendation,
    QuestionConstraint constraint,
  ) {
    final best = recommendation.bestTiming;
    final worst = recommendation.worstTiming;
    final horizon = constraint.horizon;
    if (horizon != null) {
      if (best.available && best.kind == horizon) return best;
      if (worst.available && worst.kind == horizon) return worst;
    }
    return best;
  }

  static List<QuestionWindow> _windows(
    DecisionRecommendation recommendation,
    QuestionIntentKind kind,
    DecisionWindow focus,
  ) {
    final best = recommendation.bestTiming;
    final worst = recommendation.worstTiming;
    final list = <QuestionWindow>[];
    final seenKinds = <Object>{};

    void add(DecisionWindow w, QuestionWindowRole role) {
      if (!w.available) return;
      if (!seenKinds.add(w.kind)) return;
      list.add(QuestionWindow.fromDecision(w, role));
    }

    add(focus, QuestionWindowRole.focus);
    add(best, QuestionWindowRole.best);
    if (kind == QuestionIntentKind.whenShouldI ||
        kind == QuestionIntentKind.shouldIWait) {
      add(worst, QuestionWindowRole.worst);
    }
    return list;
  }

  // --- Reasons (priority by intent) ----------------------------------------

  static List<QuestionReason> _reasons(
    DecisionRecommendation recommendation,
    QuestionIntentKind kind,
  ) {
    final emphasis = _emphasisKind(kind);
    final sorted = [...recommendation.reasons];
    sorted.sort((a, b) {
      final ae = (emphasis != null && a.kind == emphasis) ? 0 : 1;
      final be = (emphasis != null && b.kind == emphasis) ? 0 : 1;
      if (ae != be) return ae - be;
      final m = b.magnitude.abs().compareTo(a.magnitude.abs());
      if (m != 0) return m;
      return a.kind.index.compareTo(b.kind.index);
    });
    return [
      for (var i = 0; i < sorted.length; i++)
        QuestionReason.fromDecision(sorted[i], i),
    ];
  }

  // --- Evidence (relevance by intent) --------------------------------------

  static List<QuestionEvidence> _evidence(
    DecisionRecommendation recommendation,
    QuestionIntentKind kind,
  ) {
    final emphasis = _emphasisSources(kind);
    final preferNegative = kind == QuestionIntentKind.whatShouldIPrepare ||
        kind == QuestionIntentKind.biggestRisk;
    final preferPositive = kind == QuestionIntentKind.biggestOpportunity;

    final scored = <QuestionEvidence>[
      for (final atom in recommendation.evidence)
        QuestionEvidence(
          atom: atom,
          relevance: atom.magnitude.abs() +
              (emphasis.contains(atom.source) ? _emphasisBonus : 0) +
              (preferNegative && atom.magnitude < 0 ? _emphasisBonus : 0) +
              (preferPositive && atom.magnitude > 0 ? _emphasisBonus : 0),
        ),
    ]..sort((a, b) {
        final c = b.relevance.compareTo(a.relevance);
        if (c != 0) return c;
        final m = b.atom.magnitude.abs().compareTo(a.atom.magnitude.abs());
        if (m != 0) return m;
        return a.atom.source.index.compareTo(b.atom.source.index);
      });

    return scored.take(_maxEvidence).toList(growable: false);
  }

  // --- Structured answer ---------------------------------------------------

  static QuestionAnswer _answer(
    DecisionRecommendation recommendation,
    QuestionIntentKind kind,
    DecisionWindow focus,
  ) {
    final action = recommendation.action;
    final tradeoffs = recommendation.tradeoffs;
    final outcome = recommendation.outcome;

    final LifeDomain? domain = switch (kind) {
      QuestionIntentKind.biggestOpportunity => outcome.leadingOpportunity,
      QuestionIntentKind.biggestRisk => outcome.leadingRisk,
      QuestionIntentKind.whatShouldIPrepare => outcome.leadingRisk,
      _ => null,
    };

    return QuestionAnswer(
      stance: _stance(kind, action),
      action: action,
      focusWindow: QuestionWindow.fromDecision(focus, QuestionWindowRole.focus),
      focusDomain: domain,
      focusTradeoff: tradeoffs.isEmpty ? null : tradeoffs.first,
    );
  }

  static QuestionStance _stance(QuestionIntentKind kind, DecisionAction action) {
    final directional = kind == QuestionIntentKind.shouldI ||
        kind == QuestionIntentKind.shouldIWait;
    if (!directional) return QuestionStance.informational;
    return switch (action) {
      DecisionAction.shouldAct => QuestionStance.yes,
      DecisionAction.shouldPrepare => QuestionStance.prepareFirst,
      DecisionAction.shouldWait => QuestionStance.waitForBetterWindow,
      DecisionAction.shouldAvoid => QuestionStance.avoid,
    };
  }

  // --- Intent emphasis maps ------------------------------------------------

  static DecisionReasonKind? _emphasisKind(QuestionIntentKind kind) =>
      switch (kind) {
        QuestionIntentKind.shouldI => DecisionReasonKind.favourability,
        QuestionIntentKind.whenShouldI => DecisionReasonKind.timing,
        QuestionIntentKind.shouldIWait => DecisionReasonKind.timing,
        QuestionIntentKind.whatShouldIPrepare => DecisionReasonKind.risk,
        QuestionIntentKind.biggestOpportunity =>
          DecisionReasonKind.favourability,
        QuestionIntentKind.biggestRisk => DecisionReasonKind.risk,
      };

  static Set<DecisionEvidenceSource> _emphasisSources(
    QuestionIntentKind kind,
  ) =>
      switch (kind) {
        QuestionIntentKind.shouldI => const {},
        QuestionIntentKind.whenShouldI => const {
            DecisionEvidenceSource.futureOutlook,
            DecisionEvidenceSource.currentStage,
            DecisionEvidenceSource.timelineStrength,
          },
        QuestionIntentKind.shouldIWait => const {
            DecisionEvidenceSource.futureOutlook,
            DecisionEvidenceSource.currentStage,
          },
        QuestionIntentKind.whatShouldIPrepare => const {
            DecisionEvidenceSource.predictionRisk,
            DecisionEvidenceSource.natalAlignment,
          },
        QuestionIntentKind.biggestOpportunity => const {
            DecisionEvidenceSource.predictionStrength,
            DecisionEvidenceSource.planetRelationship,
            DecisionEvidenceSource.natalAlignment,
          },
        QuestionIntentKind.biggestRisk => const {
            DecisionEvidenceSource.predictionRisk,
            DecisionEvidenceSource.natalAlignment,
          },
      };
}
