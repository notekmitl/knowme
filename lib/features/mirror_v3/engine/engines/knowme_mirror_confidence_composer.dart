import '../models/knowme_mirror_agreement.dart';
import '../models/knowme_mirror_blind_spot.dart';
import '../models/knowme_mirror_reinforcement.dart';
import '../models/knowme_mirror_tension.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Composes mirror-level confidence from coverage, agreement, tension, reinforcement.
abstract final class KnowMeMirrorConfidenceComposer {
  static const agreementBoostPerCrossSystem = 0.08;
  static const agreementBoostCap = 0.24;
  static const reinforcementBoostPerFact = 0.04;
  static const reinforcementBoostCap = 0.16;
  static const tensionPenaltyPerTension = 0.06;
  static const tensionPenaltyCap = 0.18;
  static const blindSpotPenaltyPerGap = 0.03;
  static const blindSpotPenaltyCap = 0.15;

  static double compose({
    required List<KnowMeMirrorThemeSignal> signals,
    required List<KnowMeMirrorAgreement> agreements,
    required List<KnowMeMirrorTension> tensions,
    required List<KnowMeMirrorReinforcement> reinforcements,
    required List<KnowMeMirrorBlindSpot> blindSpots,
  }) {
    if (signals.isEmpty) return 0;

    final base = _weightedSignalMean(signals);
    final coverageFactor = _coverageFactor(signals);
    final agreementBoost = _agreementBoost(agreements);
    final reinforcementBoost = _reinforcementBoost(reinforcements);
    final tensionPenalty = _tensionPenalty(tensions);
    final blindSpotPenalty = _blindSpotPenalty(blindSpots);

    return (base * coverageFactor +
            agreementBoost +
            reinforcementBoost -
            tensionPenalty -
            blindSpotPenalty)
        .clamp(0.0, 1.0);
  }

  static double _weightedSignalMean(List<KnowMeMirrorThemeSignal> signals) {
    var weightedSum = 0.0;
    var weightTotal = 0.0;

    for (final signal in signals) {
      final weight = signal.prominence.clamp(0.01, 1.0);
      weightedSum += signal.confidence * weight;
      weightTotal += weight;
    }

    if (weightTotal <= 0) return 0;
    return weightedSum / weightTotal;
  }

  static double _coverageFactor(List<KnowMeMirrorThemeSignal> signals) {
    final systems = signals.map((signal) => signal.systemId).toSet();
    if (systems.isEmpty) return 0;
    if (systems.length >= 2) return 1.0;
    return 0.6;
  }

  static double _agreementBoost(List<KnowMeMirrorAgreement> agreements) {
    var boost = 0.0;
    for (final agreement in agreements) {
      if (agreement.supportingSystems.length >= 2) {
        boost += agreementBoostPerCrossSystem;
      }
    }
    return boost.clamp(0.0, agreementBoostCap);
  }

  static double _reinforcementBoost(
    List<KnowMeMirrorReinforcement> reinforcements,
  ) {
    var boost = 0.0;
    for (final reinforcement in reinforcements) {
      final extraFacts = reinforcement.evidenceCount - 1;
      if (extraFacts > 0) {
        boost += extraFacts * reinforcementBoostPerFact;
      }
    }
    return boost.clamp(0.0, reinforcementBoostCap);
  }

  static double _tensionPenalty(List<KnowMeMirrorTension> tensions) {
    final raw = tensions.length * tensionPenaltyPerTension;
    return raw.clamp(0.0, tensionPenaltyCap);
  }

  static double _blindSpotPenalty(List<KnowMeMirrorBlindSpot> blindSpots) {
    final raw = blindSpots.length * blindSpotPenaltyPerGap;
    return raw.clamp(0.0, blindSpotPenaltyCap);
  }
}
