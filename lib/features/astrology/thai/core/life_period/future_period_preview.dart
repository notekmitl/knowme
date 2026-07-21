import 'life_natal_context.dart';
import 'life_period_engine.dart';
import 'life_planet.dart';
import 'planet_element.dart';
import 'period_intelligence.dart';
import 'planet_relationship_engine.dart';

/// How the move from the current period into the next one tends to feel,
/// derived from the bond between the two ruling planets.
enum TransitionQuality { smooth, gentleShift, markedShift, turbulent }

extension TransitionQualityInfo on TransitionQuality {
  String get labelTh => switch (this) {
        TransitionQuality.smooth => 'เปลี่ยนผ่านอย่างราบรื่น',
        TransitionQuality.gentleShift => 'เปลี่ยนผ่านแบบค่อยเป็นค่อยไป',
        TransitionQuality.markedShift => 'เปลี่ยนผ่านที่รู้สึกได้ชัด',
        TransitionQuality.turbulent => 'เปลี่ยนผ่านที่ท้าทาย',
      };
}

/// The element shift across the transition (e.g. ไฟ → น้ำ).
class ElementShift {
  const ElementShift({
    required this.from,
    required this.to,
    required this.relation,
  });

  final ThaiElement from;
  final ThaiElement to;
  final ElementRelation relation;

  bool get changes => from != to;
}

/// V9 — Future Period Preview (evidence only).
///
/// Looks one period ahead: when it begins, how the transition tends to feel,
/// what it intrinsically opens up (opportunities) and where it asks for care
/// (challenges). Opportunities/challenges are expressed as [LifeDomain] tags
/// from the next planet's intrinsic affinity — deterministic evidence, not the
/// personalized 0–100 composite (which stays in presentation).
class FuturePeriodPreview {
  const FuturePeriodPreview({
    required this.hasNext,
    required this.yearsUntil,
    this.nextPeriod,
    this.nextIntelligence,
    this.transition,
    this.elementShift,
    this.opportunities = const [],
    this.challenges = const [],
  });

  /// No next period (already in the final period of the ring).
  const FuturePeriodPreview.none()
      : hasNext = false,
        yearsUntil = 0,
        nextPeriod = null,
        nextIntelligence = null,
        transition = null,
        elementShift = null,
        opportunities = const [],
        challenges = const [];

  final bool hasNext;

  /// Whole years until the next period begins (from the current age).
  final int yearsUntil;

  final PeriodState? nextPeriod;
  final PeriodIntelligence? nextIntelligence;
  final TransitionQuality? transition;
  final ElementShift? elementShift;

  /// Domains the next period tends to open up (strongest intrinsic support).
  final List<LifeDomain> opportunities;

  /// Domains the next period tends to ask care of (friction-prone).
  final List<LifeDomain> challenges;
}

abstract final class FuturePeriodPreviewEngine {
  static const int _opportunityCount = 2;
  static const int _challengeCount = 2;

  static TransitionQuality _transitionFor(PlanetRelationshipAssessment bond) {
    return switch (bond.bond) {
      PlanetBond.support => TransitionQuality.smooth,
      PlanetBond.harmony => TransitionQuality.gentleShift,
      PlanetBond.neutral => TransitionQuality.gentleShift,
      PlanetBond.friction => TransitionQuality.markedShift,
      PlanetBond.conflict => TransitionQuality.turbulent,
    };
  }

  static FuturePeriodPreview evaluate({
    required LifeTimeline timeline,
    required LifeNatalContext natal,
  }) {
    final next = timeline.next;
    if (next == null) return const FuturePeriodPreview.none();

    final current = timeline.current;
    final nextIntel = PeriodIntelligenceEngine.evaluate(
      period: next,
      natal: natal,
    );

    final transitionBond =
        PlanetRelationshipEngine.assess(current.planet, next.planet);
    final fromElement = PlanetElements.of(current.planet);
    final toElement = PlanetElements.of(next.planet);

    final affinity = LifePlanets.of(next.planet).affinity;
    final ranked = affinity.supportRanked;
    final opportunities = ranked.take(_opportunityCount).toList(growable: false);
    final challenges = _challengesFor(ranked, transitionBond);

    return FuturePeriodPreview(
      hasNext: true,
      yearsUntil: current.remainingYears,
      nextPeriod: next,
      nextIntelligence: nextIntel,
      transition: _transitionFor(transitionBond),
      elementShift: ElementShift(
        from: fromElement,
        to: toElement,
        relation: PlanetElements.relation(current.planet, next.planet),
      ),
      opportunities: opportunities,
      challenges: challenges,
    );
  }

  /// Challenges = the next planet's weakest supportive domains. A conflicting
  /// transition widens the challenge set by one.
  static List<LifeDomain> _challengesFor(
    List<LifeDomain> ranked,
    PlanetRelationshipAssessment transitionBond,
  ) {
    final count = transitionBond.isConflicting
        ? _challengeCount + 1
        : _challengeCount;
    return ranked.reversed.take(count).toList(growable: false);
  }
}
