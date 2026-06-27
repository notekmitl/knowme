import 'package:knowme/features/astrology/thai/core/life_period/current_age_analysis.dart';
import 'package:knowme/features/astrology/thai/core/life_period/future_period_preview.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_timeline_intelligence.dart';
import 'package:knowme/features/astrology/thai/core/life_period/period_intelligence.dart';

import 'prediction.dart';
import 'prediction_category.dart';
import 'prediction_context.dart';
import 'prediction_evidence.dart';
import 'prediction_reason.dart';
import 'prediction_score.dart';
import 'prediction_window.dart';

/// V10 — the full deterministic prediction result for one person.
///
/// A flat list of [predictions] (one per available category × window) plus the
/// computed [windows]. Evidence only — no copy, no AI, no presenter.
class PredictionIntelligence {
  const PredictionIntelligence({
    required this.context,
    required this.windows,
    required this.predictions,
  });

  final PredictionContext context;

  /// The three computed horizons (an unavailable next period is still listed
  /// with `available == false`).
  final List<PredictionWindow> windows;

  /// All predictions, grouped window-major then category order.
  final List<Prediction> predictions;

  List<Prediction> forWindow(PredictionWindowKind kind) =>
      predictions.where((p) => p.window.kind == kind).toList(growable: false);

  List<Prediction> forCategory(PredictionCategory category) =>
      predictions.where((p) => p.category == category).toList(growable: false);

  Prediction? predictionFor(
    PredictionCategory category,
    PredictionWindowKind kind,
  ) {
    for (final p in predictions) {
      if (p.category == category && p.window.kind == kind) return p;
    }
    return null;
  }

  /// Predictions ranked by confidence-weighted strength (stable tie-break).
  List<Prediction> get ranked {
    final list = [...predictions];
    list.sort((a, b) {
      final c = b.score.weighted.compareTo(a.score.weighted);
      if (c != 0) return c;
      final s = b.score.strength.compareTo(a.score.strength);
      if (s != 0) return s;
      final w = a.window.kind.index.compareTo(b.window.kind.index);
      if (w != 0) return w;
      return a.category.index.compareTo(b.category.index);
    });
    return list;
  }
}

/// V10 — Prediction Intelligence Foundation engine.
///
/// A pure, deterministic reasoning layer over V9. It consumes
/// [LifeTimelineIntelligence] (timeline + natal + period intelligence + current
/// age + future preview) and emits structured [Prediction] evidence for the
/// seven [PredictionCategory]s across the three [PredictionWindow]s.
///
/// It is **not** AI and **not** Transit. It contains no Thai copy, no UI, no
/// Firestore and no routing, so it can be reused by Future Prediction, Transit,
/// Compatibility and AI Conversation.
abstract final class PredictionIntelligenceEngine {
  // --- Entry points --------------------------------------------------------

  /// Convenience: build V9 intelligence from a birth date, then predict.
  static PredictionIntelligence fromBirthDate(
    DateTime birthDate, {
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) {
    final intel = LifeTimelineIntelligenceEngine.fromBirthDate(
      birthDate,
      lagnaLord: lagnaLord,
      asOf: asOf,
    );
    return fromIntelligence(intel);
  }

  static PredictionIntelligence fromIntelligence(
    LifeTimelineIntelligence intelligence,
  ) =>
      evaluate(PredictionContext.fromIntelligence(intelligence));

  /// The core deterministic evaluation.
  static PredictionIntelligence evaluate(PredictionContext context) {
    final windows = PredictionWindows.forIntelligence(context.intelligence);
    final predictions = <Prediction>[];
    for (final window in windows) {
      if (!window.available) continue;
      final governing = _governingFor(context, window);
      if (governing == null) continue;
      for (final category in PredictionCategory.values) {
        predictions.add(_predict(context, window, governing, category));
      }
    }
    return PredictionIntelligence(
      context: context,
      windows: windows,
      predictions: predictions,
    );
  }

  // --- Per-prediction reasoning -------------------------------------------

  static Prediction _predict(
    PredictionContext context,
    PredictionWindow window,
    _Governing g,
    PredictionCategory category,
  ) {
    final base = _baseStrength(g.intel.planet, category);
    final natalC = _natalContribution(g.intel.natalHarmonyScore);
    final tierC = _tierContribution(g.intel.strengthTier);
    final timingC = _timingContribution(window, g.stage, g.transition);

    final strength = PredictionScore.clamp(base + natalC + tierC + timingC);
    final confidence = _confidence(context, window, g);

    final preview = context.futurePreview;

    return Prediction(
      category: category,
      window: window,
      score: PredictionScore(strength: strength, confidence: confidence),
      evidence: _evidence(g, category, base, natalC, tierC, timingC, window, preview),
      opportunities: _opportunities(g.intel.planet, category, window, preview),
      risks: _risks(g.intel.planet, category, g.intel, window, preview),
      timingReason: _timingReason(window, g, timingC),
      planetReason: _planetReason(g, natalC),
      lifePeriodReason: _lifePeriodReason(g, base, tierC),
    );
  }

  // --- Governing period selection -----------------------------------------

  static _Governing? _governingFor(
    PredictionContext context,
    PredictionWindow window,
  ) {
    final current = context.currentAge;
    switch (window.kind) {
      case PredictionWindowKind.current:
        return _Governing(
          intel: current.intelligence,
          stage: current.stage,
          transition: null,
        );
      case PredictionWindowKind.next12Months:
        final remaining = current.period.remainingYears;
        final preview = context.futurePreview;
        final crossesToNext = remaining < PredictionWindows.near &&
            preview.hasNext &&
            preview.nextIntelligence != null;
        if (crossesToNext) {
          return _Governing(
            intel: preview.nextIntelligence!,
            stage: LifePhaseStage.opening,
            transition: preview.transition,
          );
        }
        return _Governing(
          intel: current.intelligence,
          stage: current.stage,
          transition: null,
        );
      case PredictionWindowKind.nextLifePeriod:
        final preview = context.futurePreview;
        final next = preview.nextIntelligence;
        if (next == null) return null;
        return _Governing(
          intel: next,
          stage: LifePhaseStage.opening,
          transition: preview.transition,
        );
    }
  }

  // --- Strength components --------------------------------------------------

  /// Weighted intrinsic affinity of the governing planet over a category's
  /// domains (0–100).
  static int _baseStrength(LifePlanet planet, PredictionCategory category) {
    final affinity = LifePlanets.of(planet).affinity;
    var sum = 0.0;
    var weightSum = 0.0;
    for (final cw in category.domainWeights) {
      sum += affinity.valueOf(cw.domain) * cw.weight;
      weightSum += cw.weight;
    }
    if (weightSum == 0) return 0;
    return (sum / weightSum).round();
  }

  /// Natal alignment contribution (−18..+18).
  static int _natalContribution(int harmonyScore) =>
      harmonyScore.clamp(-6, 6) * 3;

  static int _tierContribution(PeriodStrengthTier tier) => switch (tier) {
        PeriodStrengthTier.dominant => 5,
        PeriodStrengthTier.strong => 3,
        PeriodStrengthTier.moderate => 0,
        PeriodStrengthTier.brief => 1,
      };

  static int _timingContribution(
    PredictionWindow window,
    LifePhaseStage stage,
    TransitionQuality? transition,
  ) {
    switch (window.kind) {
      case PredictionWindowKind.current:
        return switch (stage) {
          LifePhaseStage.opening => 2,
          LifePhaseStage.peak => 4,
          LifePhaseStage.closing => -1,
        };
      case PredictionWindowKind.next12Months:
        return window.spansTransition ? -3 : 2;
      case PredictionWindowKind.nextLifePeriod:
        return switch (transition) {
          TransitionQuality.smooth => 3,
          TransitionQuality.gentleShift => 1,
          TransitionQuality.markedShift => -2,
          TransitionQuality.turbulent => -4,
          null => 0,
        };
    }
  }

  // --- Confidence ----------------------------------------------------------

  /// Window proximity is the dominant confidence driver (gaps of 16) so that
  /// the bounded per-period adjustments below can never reorder the windows:
  /// a nearer horizon is always at least as confident as a farther one.
  static int _proximityBase(PredictionWindowKind kind) => switch (kind) {
        PredictionWindowKind.current => 80,
        PredictionWindowKind.next12Months => 64,
        PredictionWindowKind.nextLifePeriod => 48,
      };

  static int _confidence(
    PredictionContext context,
    PredictionWindow window,
    _Governing g,
  ) {
    var c = _proximityBase(window.kind);
    // Constant per person — does not affect window ordering.
    if (context.hasLagna) c += 6;
    // Bounded adjustments (range −2..+4) — kept small vs the 16-pt gaps.
    c += switch (g.intel.strengthTier) {
      PeriodStrengthTier.dominant => 4,
      PeriodStrengthTier.strong => 2,
      PeriodStrengthTier.moderate => 0,
      PeriodStrengthTier.brief => -2,
    };
    // Corroboration (0..4): a stronger natal signal (either direction).
    final corroboration = g.intel.natalHarmonyScore.abs();
    c += corroboration > 4 ? 4 : corroboration;
    // The far horizon loses confidence on a rough transition only (never gains).
    if (window.kind == PredictionWindowKind.nextLifePeriod) {
      c += switch (g.transition) {
        TransitionQuality.turbulent => -6,
        TransitionQuality.markedShift => -3,
        _ => 0,
      };
    }
    return PredictionScore.clamp(c);
  }

  // --- Evidence / opportunities / risks ------------------------------------

  static List<PredictionEvidence> _evidence(
    _Governing g,
    PredictionCategory category,
    int base,
    int natalC,
    int tierC,
    int timingC,
    PredictionWindow window,
    FuturePeriodPreview preview,
  ) {
    final affinity = LifePlanets.of(g.intel.planet).affinity;
    final list = <PredictionEvidence>[
      PredictionEvidence(
        source: PredictionEvidenceSource.categoryAffinity,
        magnitude: base,
        planet: g.intel.planet,
        domain: category.primaryDomain,
      ),
      PredictionEvidence(
        source: PredictionEvidenceSource.natalHarmony,
        magnitude: natalC,
        planet: g.intel.natalRulerBond.to,
        bond: g.intel.natalRulerBond.bond,
      ),
      PredictionEvidence(
        source: PredictionEvidenceSource.periodStrength,
        magnitude: tierC,
        planet: g.intel.planet,
      ),
      PredictionEvidence(
        source: window.kind == PredictionWindowKind.nextLifePeriod
            ? PredictionEvidenceSource.transition
            : PredictionEvidenceSource.timing,
        magnitude: timingC,
        planet: g.intel.planet,
      ),
    ];
    if (window.kind == PredictionWindowKind.nextLifePeriod) {
      for (final d in preview.opportunities) {
        list.add(
          PredictionEvidence(
            source: PredictionEvidenceSource.futureOpportunity,
            magnitude: affinity.valueOf(d),
            planet: g.intel.planet,
            domain: d,
          ),
        );
      }
      for (final d in preview.challenges) {
        list.add(
          PredictionEvidence(
            source: PredictionEvidenceSource.futureChallenge,
            magnitude: -(100 - affinity.valueOf(d)),
            planet: g.intel.planet,
            domain: d,
          ),
        );
      }
    }
    return list;
  }

  static List<PredictionOpportunity> _opportunities(
    LifePlanet planet,
    PredictionCategory category,
    PredictionWindow window,
    FuturePeriodPreview preview,
  ) {
    final affinity = LifePlanets.of(planet).affinity;
    final byDomain = <LifeDomain, PredictionOpportunity>{};
    for (final cw in category.domainWeights) {
      if (cw.domain == LifeDomain.pressure) continue;
      byDomain[cw.domain] = PredictionOpportunity(
        domain: cw.domain,
        magnitude: affinity.valueOf(cw.domain),
        source: PredictionEvidenceSource.categoryAffinity,
      );
    }
    for (final d in affinity.supportRanked.take(2)) {
      byDomain.putIfAbsent(
        d,
        () => PredictionOpportunity(
          domain: d,
          magnitude: affinity.valueOf(d),
          source: PredictionEvidenceSource.categoryAffinity,
        ),
      );
    }
    if (window.kind == PredictionWindowKind.nextLifePeriod) {
      for (final d in preview.opportunities) {
        byDomain[d] = PredictionOpportunity(
          domain: d,
          magnitude: affinity.valueOf(d),
          source: PredictionEvidenceSource.futureOpportunity,
        );
      }
    }
    final list = byDomain.values.toList()
      ..sort((a, b) {
        final c = b.magnitude.compareTo(a.magnitude);
        return c != 0 ? c : a.domain.index.compareTo(b.domain.index);
      });
    return list.take(3).toList(growable: false);
  }

  static List<PredictionRisk> _risks(
    LifePlanet planet,
    PredictionCategory category,
    PeriodIntelligence intel,
    PredictionWindow window,
    FuturePeriodPreview preview,
  ) {
    final affinity = LifePlanets.of(planet).affinity;
    final byDomain = <LifeDomain, PredictionRisk>{
      LifeDomain.pressure: PredictionRisk(
        domain: LifeDomain.pressure,
        magnitude: affinity.pressure,
        source: PredictionEvidenceSource.categoryAffinity,
      ),
    };
    if (intel.isNatalChallenging) {
      final d = category.primaryDomain;
      final mag = (intel.natalHarmonyScore.abs() * 8).clamp(0, 100);
      byDomain[d] = PredictionRisk(
        domain: d,
        magnitude: mag,
        source: PredictionEvidenceSource.natalHarmony,
      );
    }
    if (window.kind == PredictionWindowKind.nextLifePeriod) {
      for (final d in preview.challenges) {
        byDomain[d] = PredictionRisk(
          domain: d,
          magnitude: (100 - affinity.valueOf(d)).clamp(0, 100),
          source: PredictionEvidenceSource.futureChallenge,
        );
      }
    }
    final list = byDomain.values.toList()
      ..sort((a, b) {
        final c = b.magnitude.compareTo(a.magnitude);
        return c != 0 ? c : a.domain.index.compareTo(b.domain.index);
      });
    return list.take(3).toList(growable: false);
  }

  // --- Reasons -------------------------------------------------------------

  static PredictionReason _timingReason(
    PredictionWindow window,
    _Governing g,
    int magnitude,
  ) {
    final code = switch (window.kind) {
      PredictionWindowKind.current => switch (g.stage) {
          LifePhaseStage.opening => PredictionReasonCode.windowOpening,
          LifePhaseStage.peak => PredictionReasonCode.windowPeak,
          LifePhaseStage.closing => PredictionReasonCode.windowClosing,
        },
      PredictionWindowKind.next12Months => window.spansTransition
          ? PredictionReasonCode.transitionWithinWindow
          : PredictionReasonCode.steadyWindow,
      PredictionWindowKind.nextLifePeriod => switch (g.transition) {
          TransitionQuality.markedShift ||
          TransitionQuality.turbulent =>
            PredictionReasonCode.transitionWithinWindow,
          _ => PredictionReasonCode.steadyWindow,
        },
    };
    return PredictionReason(
      kind: PredictionReasonKind.timing,
      code: code,
      magnitude: magnitude,
    );
  }

  static PredictionReason _planetReason(_Governing g, int magnitude) {
    final code = g.intel.isNatalHarmonious
        ? PredictionReasonCode.rulerSupportsNature
        : g.intel.isNatalChallenging
            ? PredictionReasonCode.rulerChallengesNature
            : PredictionReasonCode.rulerNeutralNature;
    return PredictionReason(
      kind: PredictionReasonKind.planet,
      code: code,
      magnitude: magnitude,
      planet: g.intel.planet,
      bond: g.intel.natalRulerBond.bond,
    );
  }

  static PredictionReason _lifePeriodReason(
    _Governing g,
    int base,
    int magnitude,
  ) {
    final PredictionReasonCode code;
    if (base >= 60) {
      code = PredictionReasonCode.periodFavoursCategory;
    } else if (base <= 40) {
      code = PredictionReasonCode.periodStrainsCategory;
    } else if (g.intel.strengthTier == PeriodStrengthTier.brief) {
      code = PredictionReasonCode.briefIntensePeriod;
    } else {
      code = PredictionReasonCode.longDefiningPeriod;
    }
    return PredictionReason(
      kind: PredictionReasonKind.lifePeriod,
      code: code,
      magnitude: magnitude + (base - 50),
      planet: g.intel.planet,
    );
  }
}

/// The period whose ruler governs a given window (internal).
class _Governing {
  const _Governing({
    required this.intel,
    required this.stage,
    required this.transition,
  });

  final PeriodIntelligence intel;
  final LifePhaseStage stage;
  final TransitionQuality? transition;
}
