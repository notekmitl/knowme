import 'fusion_recovery_enums.dart';

/// FCR4 — supplemental finding recovered by V2 layer (V1 untouched).
class GlobalFusionSupplementalReinforcement {
  const GlobalFusionSupplementalReinforcement({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.mirrorRoleIds,
    required this.mirrorFindingIds,
    required this.themeIds,
    required this.evidenceCount,
    required this.reinforcementBoost,
    required this.riskLevel,
    required this.recoveryRuleId,
    required this.sourceFindingIds,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> mirrorRoleIds;
  final List<String> mirrorFindingIds;
  final List<String> themeIds;
  final int evidenceCount;
  final double reinforcementBoost;
  final FusionRecoveryRiskLevel riskLevel;
  final String recoveryRuleId;
  final List<String> sourceFindingIds;
}

class GlobalFusionSupplementalAgreement {
  const GlobalFusionSupplementalAgreement({
    required this.id,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.mirrorRoleIds,
    required this.mirrorFindingIds,
    required this.themeIds,
    required this.agreementStrength,
    required this.riskLevel,
    required this.recoveryRuleId,
    required this.sourceFindingIds,
  });

  final String id;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> mirrorRoleIds;
  final List<String> mirrorFindingIds;
  final List<String> themeIds;
  final double agreementStrength;
  final FusionRecoveryRiskLevel riskLevel;
  final String recoveryRuleId;
  final List<String> sourceFindingIds;
}

class GlobalFusionSupplementalThemeSignal {
  const GlobalFusionSupplementalThemeSignal({
    required this.id,
    required this.themeId,
    required this.mirrorKey,
    required this.mirrorRoleId,
    required this.mirrorFindingId,
    required this.riskLevel,
    required this.recoveryRuleId,
  });

  final String id;
  final String themeId;
  final String mirrorKey;
  final String mirrorRoleId;
  final String mirrorFindingId;
  final FusionRecoveryRiskLevel riskLevel;
  final String recoveryRuleId;
}
