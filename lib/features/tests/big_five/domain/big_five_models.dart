import 'big_five_depth_tier.dart';
import 'big_five_trait_id.dart';

/// Firestore test/result id for the progressive Big Five module.
const String bigFiveTestId = 'big_five';

/// Bumped when result field names moved to `*Score` / `*Band`.
const int bigFiveScoringVersion = 2;

/// Trait tendency bands — deterministic, no clinical labels.
abstract final class BigFiveBandId {
  static const emerging = 'emerging';
  static const moderate = 'moderate';
  static const strong = 'strong';
}

enum BigFiveSessionStatus { loading, ready, empty, error }

/// Stored in `users/{uid}/results/big_five`.
class BigFiveResultSummary {
  const BigFiveResultSummary({
    required this.testId,
    required this.traitScoreFields,
    required this.traitBandFields,
    required this.depthTier,
    required this.scoredQuestionCount,
    required this.scoredAt,
    this.scoringVersion = bigFiveScoringVersion,
  });

  final String testId;

  /// Keys: [BigFiveTraitId.scoreField] (e.g. `opennessScore`).
  final Map<String, double> traitScoreFields;

  /// Keys: [BigFiveTraitId.bandField] (e.g. `opennessBand`).
  final Map<String, String> traitBandFields;

  final BigFiveDepthTier depthTier;
  final int scoredQuestionCount;
  final DateTime scoredAt;
  final int scoringVersion;

  double scoreForTrait(String traitId) =>
      traitScoreFields[BigFiveTraitId.scoreField(traitId)] ?? 0;

  String bandForTrait(String traitId) =>
      traitBandFields[BigFiveTraitId.bandField(traitId)] ??
      BigFiveBandId.moderate;

  bool get isQuickResult => depthTier == BigFiveDepthTier.quick;

  bool get isStandardResult => depthTier == BigFiveDepthTier.standard;

  bool get isDeepResult => depthTier == BigFiveDepthTier.deep;
}

/// Working session loaded from `users/{uid}/tests/big_five`.
class BigFiveSession {
  const BigFiveSession({
    required this.answers,
    required this.answered,
    required this.index,
    required this.total,
    required this.depthTier,
    this.completed = false,
  });

  final Map<String, int> answers;
  final int answered;
  final int index;
  final int total;
  final BigFiveDepthTier depthTier;
  final bool completed;

  factory BigFiveSession.empty({
    required int total,
    BigFiveDepthTier depthTier = BigFiveDepthTier.quick,
  }) {
    return BigFiveSession(
      answers: const {},
      answered: 0,
      index: 0,
      total: total,
      depthTier: depthTier,
    );
  }
}

/// Lightweight progress snapshot for streams/UI hooks (future PR).
class BigFiveProgress {
  const BigFiveProgress({
    required this.answered,
    required this.total,
    required this.depthTier,
    required this.completed,
  });

  final int answered;
  final int total;
  final BigFiveDepthTier depthTier;
  final bool completed;
}

Map<String, double> traitAveragesToScoreFields(Map<String, double> averages) {
  return {
    for (final trait in BigFiveTraitId.all)
      BigFiveTraitId.scoreField(trait): averages[trait] ?? 0,
  };
}

Map<String, String> traitBandsToBandFields(Map<String, String> bands) {
  return {
    for (final trait in BigFiveTraitId.all)
      BigFiveTraitId.bandField(trait): bands[trait] ?? BigFiveBandId.moderate,
  };
}

Map<String, double> normalizeTraitScoreFields(Map<String, double> raw) {
  return {
    for (final field in BigFiveTraitId.scoreFields) field: raw[field] ?? 0,
  };
}

Map<String, String> normalizeTraitBandFields(Map<String, String> raw) {
  return {
    for (final field in BigFiveTraitId.bandFields)
      field: raw[field] ?? BigFiveBandId.moderate,
  };
}
