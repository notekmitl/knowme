import 'personality_confidence.dart';

/// Transparent confidence composition for validation and debug inspection.
class PersonalityConfidenceBreakdown {
  const PersonalityConfidenceBreakdown({
    required this.baseLensMean,
    required this.coverageFactor,
    required this.agreementBoost,
    required this.contradictionPenalty,
    required this.compositeConfidence,
  });

  final double baseLensMean;
  final double coverageFactor;
  final double agreementBoost;
  final double contradictionPenalty;
  final PersonalityConfidence compositeConfidence;

  double get coverageAdjustedBase => baseLensMean * coverageFactor;

  String get compositeBand =>
      PersonalityConfidenceBands.bandLabel(compositeConfidence);

  Map<String, dynamic> toJson() => {
        'baseLensMean': baseLensMean,
        'coverageFactor': coverageFactor,
        'coverageAdjustedBase': coverageAdjustedBase,
        'agreementBoost': agreementBoost,
        'contradictionPenalty': contradictionPenalty,
        'compositeConfidence': compositeConfidence,
        'compositeBand': compositeBand,
      };
}
