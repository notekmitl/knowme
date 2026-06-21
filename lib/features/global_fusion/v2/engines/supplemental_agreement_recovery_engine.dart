import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';

import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR4 — recovers single-mirror agreements not bridged (medium risk).
abstract final class SupplementalAgreementRecoveryEngine {
  static const ruleId = 'single_mirror_agreement_recovery';

  static List<GlobalFusionSupplementalAgreement> recover({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    required Set<String> recoveredSourceIds,
  }) {
    final fusedIds = _fusedAgreementIds(foundationSnapshot);
    final results = <GlobalFusionSupplementalAgreement>[];

    for (final ref in input.mirrors) {
      for (final agreement in ref.snapshot.agreements) {
        if (fusedIds.contains(agreement.id)) continue;
        if (recoveredSourceIds.contains(agreement.id)) continue;

        results.add(
          GlobalFusionSupplementalAgreement(
            id: _id(agreement.mirrorKey, ref.mirrorRoleId, agreement.id),
            mirrorKey: agreement.mirrorKey,
            mirrorDimension: agreement.mirrorDimension,
            mirrorRoleIds: [ref.mirrorRoleId],
            mirrorFindingIds: [agreement.id],
            themeIds: List<String>.from(agreement.themeIds)..sort(),
            agreementStrength: agreement.confidence.clamp(0.0, 1.0),
            riskLevel: FusionRecoveryRiskLevel.medium,
            recoveryRuleId: ruleId,
            sourceFindingIds: [agreement.id],
          ),
        );
      }

      for (final promoted in ref.snapshot.promotedFindings) {
        if (fusedIds.contains(promoted.id)) continue;
        if (recoveredSourceIds.contains(promoted.id)) continue;

        results.add(
          GlobalFusionSupplementalAgreement(
            id: _id(promoted.mirrorKey, ref.mirrorRoleId, promoted.id),
            mirrorKey: promoted.mirrorKey,
            mirrorDimension: promoted.mirrorDimension,
            mirrorRoleIds: [ref.mirrorRoleId],
            mirrorFindingIds: [promoted.id],
            themeIds: List<String>.from(promoted.themeIds)..sort(),
            agreementStrength: promoted.confidence.clamp(0.0, 0.75),
            riskLevel: FusionRecoveryRiskLevel.medium,
            recoveryRuleId: ruleId,
            sourceFindingIds: [promoted.id],
          ),
        );
      }
    }

    results.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return results;
  }

  static Set<String> _fusedAgreementIds(GlobalFusionSnapshot snapshot) {
    return snapshot.agreements.expand((item) => item.mirrorFindingIds).toSet();
  }

  static String _id(String mirrorKey, String roleId, String findingId) {
    final payload = 'gf_recov_agreement|$mirrorKey|$roleId|$findingId';
    return 'gf_recov_agreement_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}
