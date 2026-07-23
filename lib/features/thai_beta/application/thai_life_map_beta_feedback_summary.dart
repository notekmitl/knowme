import '../domain/thai_life_map_beta_feedback.dart';

/// Pure aggregates for invited Life Map validation (admin/QA).
class ThaiLifeMapBetaFeedbackSummary {
  const ThaiLifeMapBetaFeedbackSummary({
    required this.realUserCount,
    required this.qaSubmissionCount,
    required this.submissionCount,
    required this.avgLifeFit,
    required this.avgClarity,
    required this.avgTrust,
    required this.avgUsefulness,
    required this.periodCategoryCounts,
    required this.uxIssueCounts,
    required this.buildVersions,
    required this.latestFeedbackAt,
    required this.comments,
  });

  final int realUserCount;
  final int qaSubmissionCount;
  final int submissionCount;
  final double avgLifeFit;
  final double avgClarity;
  final double avgTrust;
  final double avgUsefulness;
  final Map<ThaiLifeMapPeriodFeedbackCategory, int> periodCategoryCounts;
  final Map<ThaiLifeMapUxIssue, int> uxIssueCounts;
  final Set<String> buildVersions;
  final DateTime? latestFeedbackAt;

  /// Truncated comments for analysis (no PII fields).
  final List<String> comments;

  factory ThaiLifeMapBetaFeedbackSummary.from({
    required List<ThaiLifeMapBetaFeedback> overall,
    required List<ThaiLifeMapPeriodFeedback> periods,
  }) {
    final real = overall.where((f) => !f.isQaTest).toList();
    final qa = overall.where((f) => f.isQaTest).toList();

    double avg(Iterable<int> values) {
      final list = values.where(ThaiLifeMapBetaScores.isValidScore).toList();
      if (list.isEmpty) return 0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    final periodCounts = {
      for (final c in ThaiLifeMapPeriodFeedbackCategory.values) c: 0,
    };
    for (final p in periods) {
      periodCounts[p.category] = (periodCounts[p.category] ?? 0) + 1;
    }

    final uxCounts = {for (final u in ThaiLifeMapUxIssue.values) u: 0};
    for (final f in real) {
      for (final u in f.uxIssues) {
        uxCounts[u] = (uxCounts[u] ?? 0) + 1;
      }
    }

    DateTime? latest;
    for (final f in overall) {
      final t = f.updatedAt ?? f.createdAt;
      if (t == null) continue;
      if (latest == null || t.isAfter(latest)) latest = t;
    }

    final comments = <String>[];
    for (final f in real) {
      final c = f.optionalComment?.trim();
      if (c != null && c.isNotEmpty) comments.add(c);
    }
    for (final p in periods) {
      final c = p.optionalComment?.trim();
      if (c != null && c.isNotEmpty) comments.add(c);
    }

    return ThaiLifeMapBetaFeedbackSummary(
      realUserCount: real.length,
      qaSubmissionCount: qa.length,
      submissionCount: overall.length,
      avgLifeFit: avg(real.map((f) => f.scores.lifeFit)),
      avgClarity: avg(real.map((f) => f.scores.clarity)),
      avgTrust: avg(real.map((f) => f.scores.trust)),
      avgUsefulness: avg(real.map((f) => f.scores.usefulness)),
      periodCategoryCounts: periodCounts,
      uxIssueCounts: uxCounts,
      buildVersions: {
        for (final f in overall)
          if (f.buildVersion.trim().isNotEmpty) f.buildVersion.trim(),
      },
      latestFeedbackAt: latest,
      comments: comments.take(40).toList(),
    );
  }
}

/// Validation phase — never "Passed" without real invited users meeting bars.
enum ThaiLifeMapValidationPhase {
  readyForValidation,
  collectingEvidence,
  evidenceReady,
  validationPassed,
}

abstract final class ThaiLifeMapValidationStatus {
  static const int minRealUsersForEvidence = 5;

  static ThaiLifeMapValidationPhase evaluate(
    ThaiLifeMapBetaFeedbackSummary summary, {
    bool hasSecurityOrPrivacyDefect = false,
    bool hasUxBlocker = false,
    bool hasConfirmedCalculationDefect = false,
  }) {
    if (summary.realUserCount == 0) {
      return ThaiLifeMapValidationPhase.readyForValidation;
    }
    if (summary.realUserCount < minRealUsersForEvidence) {
      return ThaiLifeMapValidationPhase.collectingEvidence;
    }

    final scoresComplete =
        summary.avgClarity > 0 &&
        summary.avgUsefulness > 0 &&
        summary.avgTrust > 0 &&
        summary.avgLifeFit > 0;

    if (!scoresComplete) {
      return ThaiLifeMapValidationPhase.collectingEvidence;
    }

    final meetsBars =
        summary.avgClarity >= 4.0 &&
        summary.avgUsefulness >= 4.0 &&
        summary.avgTrust >= 3.5 &&
        summary.avgLifeFit >= 3.5 &&
        !hasSecurityOrPrivacyDefect &&
        !hasUxBlocker &&
        !hasConfirmedCalculationDefect;

    if (meetsBars) {
      return ThaiLifeMapValidationPhase.validationPassed;
    }
    return ThaiLifeMapValidationPhase.evidenceReady;
  }

  static String labelTh(ThaiLifeMapValidationPhase phase) {
    switch (phase) {
      case ThaiLifeMapValidationPhase.readyForValidation:
        return 'Ready for Invited Beta Validation';
      case ThaiLifeMapValidationPhase.collectingEvidence:
        return 'Collecting Evidence';
      case ThaiLifeMapValidationPhase.evidenceReady:
        return 'Evidence Ready';
      case ThaiLifeMapValidationPhase.validationPassed:
        return 'Validation Passed';
    }
  }
}
