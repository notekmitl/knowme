import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/period_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_intelligence_engine.dart';
import 'package:knowme/features/astrology/thai/core/prediction/prediction_window.dart';

import 'decision_action.dart';
import 'decision_confidence.dart';
import 'decision_context.dart';
import 'decision_evidence.dart';
import 'decision_outcome.dart';
import 'decision_reason.dart';
import 'decision_recommendation.dart';
import 'decision_scenario.dart';
import 'decision_tradeoff.dart';
import 'decision_window.dart';

/// V11 — the full deterministic decision result for one person: one
/// [DecisionRecommendation] per [DecisionScenario]. Evidence only.
class DecisionIntelligence {
  const DecisionIntelligence({
    required this.context,
    required this.recommendations,
  });

  final DecisionContext context;
  final List<DecisionRecommendation> recommendations;

  DecisionRecommendation? forScenario(DecisionScenario scenario) {
    for (final r in recommendations) {
      if (r.scenario == scenario) return r;
    }
    return null;
  }

  /// Recommendations ranked: actionable first, then by confidence, then by
  /// outcome favourability (stable tie-break on scenario order).
  List<DecisionRecommendation> get ranked {
    final list = [...recommendations];
    list.sort((a, b) {
      final d = b.action.direction.compareTo(a.action.direction);
      if (d != 0) return d;
      final c = b.confidence.value.compareTo(a.confidence.value);
      if (c != 0) return c;
      final f = b.outcome.favourability.compareTo(a.outcome.favourability);
      if (f != 0) return f;
      return a.scenario.index.compareTo(b.scenario.index);
    });
    return list;
  }
}

/// V11 — Decision Intelligence Foundation engine.
///
/// A pure, deterministic reasoning layer that converts V10
/// [PredictionIntelligence] into actionable decision guidance for the ten
/// Supported Scenarios. It is **not** AI, **not** Transit and **not**
/// Compatibility. It contains no Thai copy, no UI, no Firestore and no routing,
/// so it can be reused by Transit, Compatibility, AI Conversation and Future
/// Chat.
abstract final class DecisionIntelligenceEngine {
  /// A future window must beat acting-now by this margin to change the verdict.
  static const int _gap = 8;

  // --- Entry points --------------------------------------------------------

  static DecisionIntelligence fromBirthDate(
    DateTime birthDate, {
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) {
    return fromPrediction(
      PredictionIntelligenceEngine.fromBirthDate(
        birthDate,
        lagnaLord: lagnaLord,
        asOf: asOf,
      ),
    );
  }

  static DecisionIntelligence fromIntelligence(
    LifeTimelineIntelligence intelligence,
  ) =>
      fromPrediction(
        PredictionIntelligenceEngine.fromIntelligence(intelligence),
      );

  static DecisionIntelligence fromPrediction(
    PredictionIntelligence prediction,
  ) =>
      evaluate(DecisionContext.fromPrediction(prediction));

  /// The core deterministic evaluation.
  static DecisionIntelligence evaluate(DecisionContext context) {
    final recommendations = <DecisionRecommendation>[
      for (final scenario in DecisionScenario.values)
        _evaluateScenario(context, scenario),
    ];
    return DecisionIntelligence(
      context: context,
      recommendations: recommendations,
    );
  }

  // --- Per-scenario reasoning ----------------------------------------------

  static DecisionRecommendation _evaluateScenario(
    DecisionContext context,
    DecisionScenario scenario,
  ) {
    final config = scenario.config;

    final windows = <PredictionWindowKind, _ScenarioWindow>{
      for (final kind in PredictionWindowKind.values)
        kind: _assessWindow(context, scenario, config, kind),
    };
    final current = windows[PredictionWindowKind.current]!;
    final available =
        windows.values.where((w) => w.available).toList(growable: false);

    final best = _extremeWindow(available, best: true);
    final worst = _extremeWindow(available, best: false);

    final action = _decide(config, current, best);
    final decisive = _decisiveWindow(action, windows, current);

    final reasons = _reasons(context, config, current, best, decisive, action);
    final evidence = _evidence(context, config, current, decisive, windows);
    final supporting =
        evidence.where((e) => e.magnitude > 0).toList(growable: false);
    final conflicting =
        evidence.where((e) => e.magnitude < 0).toList(growable: false);

    final confidence =
        _confidence(config, decisive, action, conflicting.length);

    return DecisionRecommendation(
      scenario: scenario,
      action: action,
      confidence: confidence,
      reasons: reasons,
      supportingEvidence: supporting,
      conflictingEvidence: conflicting,
      bestTiming: best.toDecisionWindow(),
      worstTiming: worst.toDecisionWindow(),
      tradeoffs: _tradeoffs(decisive),
      outcome: _outcome(decisive),
    );
  }

  // --- Window assessment ---------------------------------------------------

  static _ScenarioWindow _assessWindow(
    DecisionContext context,
    DecisionScenario scenario,
    DecisionScenarioConfig config,
    PredictionWindowKind kind,
  ) {
    final prediction = context.prediction;
    final picked = <({ScenarioCategoryWeight cw, Prediction p})>[];
    for (final cw in config.categories) {
      final p = prediction.predictionFor(cw.category, kind);
      if (p == null) return _ScenarioWindow.unavailable(kind);
      picked.add((cw: cw, p: p));
    }

    final bounds = picked.first.p.window;
    var fSum = 0.0;
    var rSum = 0.0;
    var cSum = 0.0;
    var wSum = 0.0;
    final oppByDomain = <LifeDomain, double>{};
    final riskByDomain = <LifeDomain, double>{};

    for (final entry in picked) {
      final w = entry.cw.weight;
      final p = entry.p;
      fSum += p.strength * w;
      cSum += p.confidence * w;
      final topRisk = p.risks.isEmpty ? 0 : p.risks.first.magnitude;
      rSum += topRisk * w;
      wSum += w;
      for (final o in p.opportunities) {
        oppByDomain[o.domain] = (oppByDomain[o.domain] ?? 0) + o.magnitude * w;
      }
      for (final r in p.risks) {
        riskByDomain[r.domain] = (riskByDomain[r.domain] ?? 0) + r.magnitude * w;
      }
    }

    final strength = (fSum / wSum).round();
    final confidence = (cSum / wSum).round();
    final risk = (rSum / wSum).round();
    final favourability = DecisionConfidence.clamp(
      strength - (risk * config.riskWeightPct / 100).round(),
    );

    return _ScenarioWindow(
      kind: kind,
      startAge: bounds.startAge,
      endAge: bounds.endAge,
      strength: strength,
      risk: risk,
      confidence: confidence,
      favourability: favourability,
      available: true,
      oppByDomain: _rounded(oppByDomain),
      riskByDomain: _rounded(riskByDomain),
    );
  }

  /// Best (or worst) window by net favourability; ties break to the nearer
  /// window (smaller kind index) so selection is deterministic.
  static _ScenarioWindow _extremeWindow(
    List<_ScenarioWindow> windows, {
    required bool best,
  }) {
    final sorted = [...windows]..sort((a, b) {
        final c = best
            ? b.favourability.compareTo(a.favourability)
            : a.favourability.compareTo(b.favourability);
        if (c != 0) return c;
        return a.kind.index.compareTo(b.kind.index);
      });
    return sorted.first;
  }

  // --- Verdict -------------------------------------------------------------

  static DecisionAction _decide(
    DecisionScenarioConfig config,
    _ScenarioWindow current,
    _ScenarioWindow best,
  ) {
    // 1) Avoid: risk dominates and the present is not favourable enough.
    if (current.risk >= config.avoidRisk &&
        current.favourability < config.actThreshold) {
      return DecisionAction.shouldAvoid;
    }
    // 2) Act: the present is strong enough and not clearly beaten by a future.
    if (current.favourability >= config.actThreshold &&
        current.favourability + _gap >= best.favourability) {
      return DecisionAction.shouldAct;
    }
    // 3) A materially better window lies ahead.
    if (best.favourability - current.favourability >= _gap) {
      return best.kind == PredictionWindowKind.nextLifePeriod
          ? DecisionAction.shouldWait
          : DecisionAction.shouldPrepare;
    }
    // 4) Nothing decisive now and nothing clearly better soon → prepare.
    return DecisionAction.shouldPrepare;
  }

  static _ScenarioWindow _decisiveWindow(
    DecisionAction action,
    Map<PredictionWindowKind, _ScenarioWindow> windows,
    _ScenarioWindow current,
  ) {
    _ScenarioWindow at(PredictionWindowKind kind) {
      final w = windows[kind];
      return (w != null && w.available) ? w : current;
    }

    return switch (action) {
      DecisionAction.shouldAct => current,
      DecisionAction.shouldAvoid => current,
      DecisionAction.shouldPrepare => at(PredictionWindowKind.next12Months),
      DecisionAction.shouldWait => at(PredictionWindowKind.nextLifePeriod),
    };
  }

  // --- Reasons -------------------------------------------------------------

  static List<DecisionReason> _reasons(
    DecisionContext context,
    DecisionScenarioConfig config,
    _ScenarioWindow current,
    _ScenarioWindow best,
    _ScenarioWindow decisive,
    DecisionAction action,
  ) {
    final favourabilityCode = decisive.favourability >= 60
        ? DecisionReasonCode.strongFavourableOutlook
        : decisive.favourability >= 45
            ? DecisionReasonCode.mixedOutlook
            : DecisionReasonCode.weakFavourableOutlook;

    final timingCode = switch (action) {
      DecisionAction.shouldAct => DecisionReasonCode.currentWindowOptimal,
      DecisionAction.shouldPrepare =>
        best.kind == PredictionWindowKind.next12Months
            ? DecisionReasonCode.nearWindowBetter
            : DecisionReasonCode.timingStable,
      DecisionAction.shouldWait => DecisionReasonCode.futureWindowBetter,
      DecisionAction.shouldAvoid => DecisionReasonCode.timingStable,
    };

    final riskCode = decisive.risk >= config.avoidRisk
        ? DecisionReasonCode.highRiskEnvironment
        : decisive.risk >= 45
            ? DecisionReasonCode.elevatedRisk
            : DecisionReasonCode.lowRiskEnvironment;

    final harmony = context.currentAge.intelligence.natalHarmonyScore;
    final natalCode = harmony > 0
        ? DecisionReasonCode.natalSupportsScenario
        : harmony < 0
            ? DecisionReasonCode.natalChallengesScenario
            : DecisionReasonCode.natalNeutralScenario;

    return [
      DecisionReason(
        kind: DecisionReasonKind.favourability,
        code: favourabilityCode,
        magnitude: decisive.favourability - 50,
      ),
      DecisionReason(
        kind: DecisionReasonKind.timing,
        code: timingCode,
        magnitude: current.favourability - best.favourability,
      ),
      DecisionReason(
        kind: DecisionReasonKind.risk,
        code: riskCode,
        magnitude: -(decisive.risk - 40),
      ),
      DecisionReason(
        kind: DecisionReasonKind.natal,
        code: natalCode,
        magnitude: harmony * 3,
      ),
    ];
  }

  // --- Evidence (six required sources) -------------------------------------

  static List<DecisionEvidence> _evidence(
    DecisionContext context,
    DecisionScenarioConfig config,
    _ScenarioWindow current,
    _ScenarioWindow decisive,
    Map<PredictionWindowKind, _ScenarioWindow> windows,
  ) {
    final intel = context.currentAge.intelligence;
    final list = <DecisionEvidence>[];

    // 1–3) Prediction Intelligence: strength, risk, confidence.
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.predictionStrength,
      magnitude: decisive.strength - 50,
      window: decisive.kind,
    ));
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.predictionRisk,
      magnitude: -(decisive.risk - 40),
      window: decisive.kind,
      domain: _leadingDomain(decisive.riskByDomain),
    ));
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.predictionConfidence,
      magnitude: (decisive.confidence - 50) ~/ 2,
      window: decisive.kind,
    ));

    // 4) Timeline Intelligence: governing period strength tier.
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.timelineStrength,
      magnitude: _tierContribution(intel.strengthTier),
      planet: intel.planet,
    ));

    // 5) Current Age: where the person stands inside the period.
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.currentStage,
      magnitude: _stageContribution(context.currentAge.stage),
    ));

    // 6) Future Window: how the best future compares to acting now.
    final futureNets = <int>[
      for (final k in const [
        PredictionWindowKind.next12Months,
        PredictionWindowKind.nextLifePeriod,
      ])
        if (windows[k]?.available ?? false) windows[k]!.favourability,
    ];
    if (futureNets.isNotEmpty) {
      final bestFuture = futureNets.reduce((a, b) => a > b ? a : b);
      list.add(DecisionEvidence(
        source: DecisionEvidenceSource.futureOutlook,
        magnitude: current.favourability - bestFuture,
        window: current.favourability >= bestFuture
            ? PredictionWindowKind.current
            : (windows[PredictionWindowKind.nextLifePeriod]?.favourability ==
                    bestFuture
                ? PredictionWindowKind.nextLifePeriod
                : PredictionWindowKind.next12Months),
      ));
    }

    // 7) Planet Relationship: governing ruler ↔ natal anchor bond.
    final natalBond = intel.natalRulerBond;
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.planetRelationship,
      magnitude: natalBond.bond.direction * 4,
      planet: natalBond.to,
      bond: natalBond.bond,
    ));

    // 8) Natal Context: net natal alignment of the governing period.
    list.add(DecisionEvidence(
      source: DecisionEvidenceSource.natalAlignment,
      magnitude: intel.natalHarmonyScore * 3,
    ));

    return list.where((e) => e.magnitude != 0).toList(growable: false);
  }

  // --- Confidence ----------------------------------------------------------

  static DecisionConfidence _confidence(
    DecisionScenarioConfig config,
    _ScenarioWindow decisive,
    DecisionAction action,
    int conflictCount,
  ) {
    // How decisively the favourability cleared (or missed) the act threshold.
    final margin =
        (decisive.favourability - config.actThreshold).abs().clamp(0, 12);
    final value = DecisionConfidence.clamp(
      decisive.confidence + (margin ~/ 3) - conflictCount * 2,
    );
    return DecisionConfidence(value: value);
  }

  // --- Tradeoffs & outcome -------------------------------------------------

  static List<DecisionTradeoff> _tradeoffs(_ScenarioWindow w) {
    final opps = _sortedDesc(w.oppByDomain);
    final risks = _sortedDesc(w.riskByDomain);
    if (opps.isEmpty || risks.isEmpty) return const [];

    final tradeoffs = <DecisionTradeoff>[];
    final usedCost = <LifeDomain>{};
    for (var i = 0; i < opps.length && tradeoffs.length < 2; i++) {
      final gain = opps[i];
      MapEntry<LifeDomain, int>? cost;
      for (final r in risks) {
        if (r.key == gain.key) continue;
        if (usedCost.contains(r.key)) continue;
        cost = r;
        break;
      }
      cost ??= risks.firstWhere(
        (r) => r.key != gain.key,
        orElse: () => risks.first,
      );
      usedCost.add(cost.key);
      tradeoffs.add(DecisionTradeoff(
        gain: gain.key,
        gainMagnitude: gain.value,
        cost: cost.key,
        costMagnitude: cost.value,
      ));
    }
    return tradeoffs;
  }

  static DecisionOutcome _outcome(_ScenarioWindow w) {
    return DecisionOutcome(
      band: DecisionOutcome.bandFor(w.favourability),
      favourability: w.favourability,
      leadingOpportunity: _leadingDomain(w.oppByDomain),
      leadingRisk: _leadingDomain(w.riskByDomain),
    );
  }

  // --- Small helpers -------------------------------------------------------

  static int _tierContribution(PeriodStrengthTier tier) => switch (tier) {
        PeriodStrengthTier.dominant => 6,
        PeriodStrengthTier.strong => 3,
        PeriodStrengthTier.moderate => 0,
        PeriodStrengthTier.brief => 1,
      };

  static int _stageContribution(LifePhaseStage stage) => switch (stage) {
        LifePhaseStage.opening => 2,
        LifePhaseStage.peak => 4,
        LifePhaseStage.closing => -2,
      };

  static Map<LifeDomain, int> _rounded(Map<LifeDomain, double> raw) => {
        for (final e in raw.entries) e.key: e.value.round(),
      };

  static List<MapEntry<LifeDomain, int>> _sortedDesc(
    Map<LifeDomain, int> map,
  ) {
    final list = map.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.index.compareTo(b.key.index);
      });
    return list;
  }

  static LifeDomain? _leadingDomain(Map<LifeDomain, int> map) {
    final sorted = _sortedDesc(map);
    return sorted.isEmpty ? null : sorted.first.key;
  }
}

/// One (scenario × window) assessment (internal).
class _ScenarioWindow {
  const _ScenarioWindow({
    required this.kind,
    required this.startAge,
    required this.endAge,
    required this.strength,
    required this.risk,
    required this.confidence,
    required this.favourability,
    required this.available,
    required this.oppByDomain,
    required this.riskByDomain,
  });

  const _ScenarioWindow.unavailable(this.kind)
      : startAge = 0,
        endAge = 0,
        strength = 0,
        risk = 0,
        confidence = 0,
        favourability = 0,
        available = false,
        oppByDomain = const {},
        riskByDomain = const {};

  final PredictionWindowKind kind;
  final int startAge;
  final int endAge;

  /// Weighted prediction strength (0–100), before risk subtraction.
  final int strength;
  final int risk;
  final int confidence;

  /// Net favourability (strength − weighted risk).
  final int favourability;
  final bool available;

  final Map<LifeDomain, int> oppByDomain;
  final Map<LifeDomain, int> riskByDomain;

  DecisionWindow toDecisionWindow() => available
      ? DecisionWindow(
          kind: kind,
          startAge: startAge,
          endAge: endAge,
          favourability: favourability,
          risk: risk,
          confidence: confidence,
          available: true,
        )
      : DecisionWindow.unavailable(kind);
}
