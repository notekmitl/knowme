import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_engine.dart';

/// Which axis a [PredictionReason] explains.
enum PredictionReasonKind { timing, planet, lifePeriod }

/// A finite vocabulary of *why* codes. The engine emits codes only — the
/// presentation layer (later, outside V10) maps codes to copy. This keeps the
/// copy boundary intact: no prose ever lives in the engine.
enum PredictionReasonCode {
  // timing ------------------------------------------------------------------
  windowOpening,
  windowPeak,
  windowClosing,
  transitionWithinWindow,
  steadyWindow,
  // planet ------------------------------------------------------------------
  rulerSupportsNature,
  rulerChallengesNature,
  rulerNeutralNature,
  // life period -------------------------------------------------------------
  longDefiningPeriod,
  briefIntensePeriod,
  periodFavoursCategory,
  periodStrainsCategory,
}

/// A single structured reason behind a prediction — evidence only.
///
/// [magnitude] is the signed contribution this reason made to the prediction's
/// strength (so a presenter can rank reasons and a test can verify integrity).
class PredictionReason {
  const PredictionReason({
    required this.kind,
    required this.code,
    required this.magnitude,
    this.planet,
    this.bond,
  });

  final PredictionReasonKind kind;
  final PredictionReasonCode code;

  /// Signed strength contribution attributable to this reason.
  final int magnitude;

  /// The planet this reason references (planet reasons), when applicable.
  final LifePlanet? planet;

  /// The bond this reason references (planet reasons), when applicable.
  final PlanetBond? bond;
}
