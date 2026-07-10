import '../../foundation/models/thai_birth_data.dart';
import 'current_age_analysis.dart';
import 'future_period_preview.dart';
import 'life_natal_context.dart';
import 'life_period_engine.dart';
import 'life_planet.dart';
import 'period_intelligence.dart';

/// V9 — Life Timeline Intelligence bundle.
///
/// The single evidence object the presentation layer consumes for the upgraded
/// timeline. It composes the V8 [LifeTimeline] (period sequence) with the V9
/// intelligence layers:
///   • [periodIntelligence] — per-period relationship/element/strength evidence
///   • [currentAge]         — current-period analysis (dominant influences)
///   • [futurePreview]      — next-period transition, opportunities, challenges
///
/// Everything here is **evidence only** — deterministic, copy-free, reusable by
/// Timeline, Future/Annual Prediction, Compatibility and Fusion.
class LifeTimelineIntelligence {
  const LifeTimelineIntelligence({
    required this.timeline,
    required this.natal,
    required this.periodIntelligence,
    required this.currentAge,
    required this.futurePreview,
  });

  final LifeTimeline timeline;
  final LifeNatalContext natal;

  /// One [PeriodIntelligence] per [LifeTimeline.periods], same order/index.
  final List<PeriodIntelligence> periodIntelligence;

  final CurrentAgeAnalysis currentAge;
  final FuturePeriodPreview futurePreview;

  /// Intelligence for the current period.
  PeriodIntelligence get currentIntelligence =>
      periodIntelligence[timeline.currentIndex];

  PeriodIntelligence intelligenceFor(int periodIndex) =>
      periodIntelligence[periodIndex];
}

/// V9 — engine entry point. Pure, deterministic, evidence only.
abstract final class LifeTimelineIntelligenceEngine {
  /// Builds the full intelligence bundle directly from a canonical birth date.
  ///
  /// [lagnaLord] is resolved upstream from the foundation engine (null when the
  /// birth time / lagna is unknown). The birth (weekday) ruler is derived by
  /// the period engine, so the caller never duplicates that resolution.
  static LifeTimelineIntelligence fromBirthDate(
    DateTime birthDate, {
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) {
    final timeline = LifePeriodEngine.fromBirthDate(birthDate, asOf: asOf);
    return fromTimeline(timeline, lagnaLord: lagnaLord);
  }

  /// Consistency-safe entry: builds from normalized [ThaiBirthData] so the
  /// timeline uses the single sunrise-adjusted Thai astrological date.
  static LifeTimelineIntelligence fromBirthData(
    ThaiBirthData birthData, {
    LifePlanet? lagnaLord,
    DateTime? asOf,
  }) {
    final timeline = LifePeriodEngine.fromBirthData(birthData, asOf: asOf);
    return fromTimeline(timeline, lagnaLord: lagnaLord);
  }

  /// Builds intelligence for an already-computed [timeline] (e.g. when the QA
  /// harness re-derives the timeline at a chosen `asOf`).
  static LifeTimelineIntelligence fromTimeline(
    LifeTimeline timeline, {
    LifePlanet? lagnaLord,
  }) {
    final natal = LifeNatalContext(
      birthRuler: timeline.startPlanet,
      lagnaLord: lagnaLord,
    );
    return build(timeline: timeline, natal: natal);
  }

  static LifeTimelineIntelligence build({
    required LifeTimeline timeline,
    required LifeNatalContext natal,
  }) {
    final periodIntelligence = [
      for (final period in timeline.periods)
        PeriodIntelligenceEngine.evaluate(period: period, natal: natal),
    ];
    final currentAge = CurrentAgeAnalysisEngine.evaluate(
      timeline: timeline,
      natal: natal,
    );
    final futurePreview = FuturePeriodPreviewEngine.evaluate(
      timeline: timeline,
      natal: natal,
    );
    return LifeTimelineIntelligence(
      timeline: timeline,
      natal: natal,
      periodIntelligence: periodIntelligence,
      currentAge: currentAge,
      futurePreview: futurePreview,
    );
  }
}
