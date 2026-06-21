import '../domain/fusion_recovery_enums.dart';

/// FCR2 — compression rule impact analysis.
class FusionCompressionRuleAudit {
  const FusionCompressionRuleAudit({
    required this.rule,
    required this.filteredFindingCount,
    required this.description,
    required this.classification,
  });

  final FusionCompressionRule rule;
  final int filteredFindingCount;
  final String description;
  final CompressionClassification classification;
}

class FusionCompressionAuditReport {
  const FusionCompressionAuditReport({
    required this.totalMirrorFindings,
    required this.fusionFindingCount,
    required this.compressionRate,
    required this.rules,
    required this.expectedCompressionCount,
    required this.overCompressionCount,
  });

  final int totalMirrorFindings;
  final int fusionFindingCount;
  final double compressionRate;
  final List<FusionCompressionRuleAudit> rules;
  final int expectedCompressionCount;
  final int overCompressionCount;
}

abstract final class FusionCompressionAudit {
  static FusionCompressionAuditReport analyze({
    required int totalMirrorFindings,
    required int fusionFindingCount,
    required Map<FusionCompressionRule, int> filteredByRule,
  }) {
    final rules = <FusionCompressionRuleAudit>[];

    for (final rule in FusionCompressionRule.values) {
      final count = filteredByRule[rule] ?? 0;
      if (count == 0) continue;
      rules.add(
        FusionCompressionRuleAudit(
          rule: rule,
          filteredFindingCount: count,
          description: _description(rule),
          classification: _classification(rule),
        ),
      );
    }

    rules.sort((a, b) => b.filteredFindingCount.compareTo(a.filteredFindingCount));

    var expected = 0;
    var over = 0;
    for (final rule in rules) {
      if (rule.classification == CompressionClassification.expectedCompression) {
        expected += rule.filteredFindingCount;
      } else {
        over += rule.filteredFindingCount;
      }
    }

    return FusionCompressionAuditReport(
      totalMirrorFindings: totalMirrorFindings,
      fusionFindingCount: fusionFindingCount,
      compressionRate: totalMirrorFindings == 0
          ? 0.0
          : 1.0 - (fusionFindingCount / totalMirrorFindings),
      rules: rules,
      expectedCompressionCount: expected,
      overCompressionCount: over,
    );
  }

  static String _description(FusionCompressionRule rule) {
    return switch (rule) {
      FusionCompressionRule.crossMirrorAgreementRequiresTwoRoles =>
        'Agreement requires same mirrorKey in 2+ mirror roles',
      FusionCompressionRule.reinforcementRequiresCrossMirrorAgreement =>
        'Reinforcement elevation requires prior cross-mirror agreement',
      FusionCompressionRule.tensionRequiresCrossRolePolarity =>
        'Tension requires cross-role positive vs tension signal overlap',
      FusionCompressionRule.blindSpotRequiresCrossMirrorReflection =>
        'Blind spot requires reflecting mirror on same key',
      FusionCompressionRule.singleMirrorAgreementExcluded =>
        'Single-role agreement excluded from cross-mirror fusion',
      FusionCompressionRule.singleMirrorReinforcementExcluded =>
        'Single-role reinforcement excluded without agreement bridge',
    };
  }

  static CompressionClassification _classification(FusionCompressionRule rule) {
    return switch (rule) {
      FusionCompressionRule.tensionRequiresCrossRolePolarity ||
      FusionCompressionRule.blindSpotRequiresCrossMirrorReflection =>
        CompressionClassification.expectedCompression,
      FusionCompressionRule.crossMirrorAgreementRequiresTwoRoles ||
      FusionCompressionRule.reinforcementRequiresCrossMirrorAgreement ||
      FusionCompressionRule.singleMirrorAgreementExcluded ||
      FusionCompressionRule.singleMirrorReinforcementExcluded =>
        CompressionClassification.overCompression,
    };
  }
}
