import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';

import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR4 — recovers high-evidence single-mirror reinforcements (medium risk).
abstract final class SupplementalSingleMirrorReinforcementEngine {
  static const ruleId = 'single_mirror_reinforcement_recovery';
  static const minEvidenceCount = 3;

  static List<GlobalFusionSupplementalReinforcement> recover({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    required Set<String> recoveredSourceIds,
  }) {
    final fusedIds = _fusedReinforcementIds(foundationSnapshot);
    final results = <GlobalFusionSupplementalReinforcement>[];

    for (final ref in input.mirrors) {
      for (final reinforcement in ref.snapshot.reinforcements) {
        if (fusedIds.contains(reinforcement.id)) continue;
        if (recoveredSourceIds.contains(reinforcement.id)) continue;
        if (reinforcement.evidenceCount < minEvidenceCount) continue;

        final boost =
            (0.10 + reinforcement.evidenceCount * 0.03).clamp(0.15, 0.35);

        results.add(
          GlobalFusionSupplementalReinforcement(
            id: _id(reinforcement.mirrorKey, ref.mirrorRoleId, reinforcement.id),
            mirrorKey: reinforcement.mirrorKey,
            mirrorDimension: reinforcement.mirrorDimension,
            mirrorRoleIds: [ref.mirrorRoleId],
            mirrorFindingIds: [reinforcement.id],
            themeIds: List<String>.from(reinforcement.themeIds)..sort(),
            evidenceCount: reinforcement.evidenceCount,
            reinforcementBoost: boost,
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

  static Set<String> _fusedReinforcementIds(GlobalFusionSnapshot snapshot) {
    return snapshot.reinforcements.expand((item) => item.mirrorFindingIds).toSet();
  }

  static String _id(String mirrorKey, String roleId, String findingId) {
    final payload = 'gf_recov_single_rf|$mirrorKey|$roleId|$findingId';
    return 'gf_recov_single_rf_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}
