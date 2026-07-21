import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';

import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// GF2-R004 — filtered mirror reinforcement recovery (medium risk).
abstract final class FilteredMirrorReinforcementRecoveryEngine {
  static const ruleId = 'filtered_mirror_reinforcement_recovery';

  static List<GlobalFusionSupplementalReinforcement> recover({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    required List<GlobalFusionSupplementalAgreement> supplementalAgreements,
    required Set<String> recoveredSourceIds,
  }) {
    final agreementKeys =
        supplementalAgreements.map((item) => item.mirrorKey).toSet();
    final foundationReinforcementKeys = foundationSnapshot.reinforcements
        .map((item) => item.mirrorKey)
        .toSet();
    final results = <GlobalFusionSupplementalReinforcement>[];

    for (final ref in input.mirrors) {
      for (final reinforcement in ref.snapshot.reinforcements) {
        if (!agreementKeys.contains(reinforcement.mirrorKey)) continue;
        if (foundationReinforcementKeys.contains(reinforcement.mirrorKey)) {
          continue;
        }
        if (recoveredSourceIds.contains(reinforcement.id)) continue;

        results.add(
          GlobalFusionSupplementalReinforcement(
            id: _id(
              reinforcement.mirrorKey,
              ref.mirrorRoleId,
              reinforcement.id,
            ),
            mirrorKey: reinforcement.mirrorKey,
            mirrorDimension: reinforcement.mirrorDimension,
            mirrorRoleIds: [ref.mirrorRoleId],
            mirrorFindingIds: [reinforcement.id],
            themeIds: List<String>.from(reinforcement.themeIds)..sort(),
            evidenceCount: reinforcement.evidenceCount,
            reinforcementBoost:
                reinforcement.structuralWeight.clamp(0.15, 0.35),
            riskLevel: FusionRecoveryRiskLevel.medium,
            recoveryRuleId: ruleId,
            sourceFindingIds: [reinforcement.id],
          ),
        );
      }
    }

    results.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return results;
  }

  static String _id(String mirrorKey, String roleId, String findingId) {
    final payload = 'gf_recov_r004|$mirrorKey|$roleId|$findingId';
    return 'gf_recov_r004_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}
