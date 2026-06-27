import 'life_natal_context.dart';
import 'life_period_engine.dart';
import 'period_intelligence.dart';

/// Where inside the current period the person stands.
enum LifePhaseStage { opening, peak, closing }

extension LifePhaseStageInfo on LifePhaseStage {
  String get labelTh => switch (this) {
        LifePhaseStage.opening => 'ช่วงต้นของจังหวะนี้',
        LifePhaseStage.peak => 'ช่วงกลางของจังหวะนี้',
        LifePhaseStage.closing => 'ช่วงท้ายของจังหวะนี้',
      };
}

/// A structured reason why the current period matters — evidence the presenter
/// turns into copy. No prose here.
enum CurrentAgeFactor {
  longDefiningPeriod,
  briefIntensePeriod,
  alignedWithNature,
  testsYourNature,
  openingMomentum,
  midPeak,
  transitionApproaching,
}

/// V9 — Current Age Analysis (evidence only).
///
/// Explains the *current* life period: where the person is inside it, the
/// dominant influences acting now, and structured factors for "why this period
/// matters". Reuses [PeriodIntelligence] so relationship/element logic lives in
/// exactly one place.
class CurrentAgeAnalysis {
  const CurrentAgeAnalysis({
    required this.currentAge,
    required this.period,
    required this.intelligence,
    required this.stage,
    required this.transitionApproaching,
    required this.dominantInfluences,
    required this.factors,
  });

  final int currentAge;
  final PeriodState period;
  final PeriodIntelligence intelligence;
  final LifePhaseStage stage;

  /// True when the person is near the end of the current period (a change is
  /// coming soon).
  final bool transitionApproaching;

  /// Influences acting now, strongest first (excludes the next-period planet —
  /// that belongs to the Future Preview).
  final List<PeriodInfluence> dominantInfluences;

  final List<CurrentAgeFactor> factors;
}

abstract final class CurrentAgeAnalysisEngine {
  /// Periods are considered "transition approaching" when the closing stage is
  /// reached and few years remain.
  static const int _transitionYears = 3;

  static LifePhaseStage stageForProgress(double progress) {
    if (progress < 0.34) return LifePhaseStage.opening;
    if (progress < 0.67) return LifePhaseStage.peak;
    return LifePhaseStage.closing;
  }

  static CurrentAgeAnalysis evaluate({
    required LifeTimeline timeline,
    required LifeNatalContext natal,
  }) {
    final period = timeline.current;
    final intel = PeriodIntelligenceEngine.evaluate(
      period: period,
      natal: natal,
    );
    final stage = stageForProgress(period.progress);
    final transitionApproaching = stage == LifePhaseStage.closing &&
        period.remainingYears <= _transitionYears;

    final dominant = intel.influences
        .where((i) => i.role != InfluenceRole.nextPeriod)
        .toList(growable: false);

    final factors = <CurrentAgeFactor>[];
    switch (intel.strengthTier) {
      case PeriodStrengthTier.strong:
      case PeriodStrengthTier.dominant:
        factors.add(CurrentAgeFactor.longDefiningPeriod);
      case PeriodStrengthTier.brief:
        factors.add(CurrentAgeFactor.briefIntensePeriod);
      case PeriodStrengthTier.moderate:
        break;
    }
    if (intel.isNatalHarmonious) {
      factors.add(CurrentAgeFactor.alignedWithNature);
    } else if (intel.isNatalChallenging) {
      factors.add(CurrentAgeFactor.testsYourNature);
    }
    switch (stage) {
      case LifePhaseStage.opening:
        factors.add(CurrentAgeFactor.openingMomentum);
      case LifePhaseStage.peak:
        factors.add(CurrentAgeFactor.midPeak);
      case LifePhaseStage.closing:
        break;
    }
    if (transitionApproaching) {
      factors.add(CurrentAgeFactor.transitionApproaching);
    }

    return CurrentAgeAnalysis(
      currentAge: timeline.currentAge,
      period: period,
      intelligence: intel,
      stage: stage,
      transitionApproaching: transitionApproaching,
      dominantInfluences: dominant,
      factors: factors,
    );
  }
}
