import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';

import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR4 — recovers theme signals present in mirror but absent from fusion (high risk).
abstract final class SupplementalThemeRecoveryEngine {
  static const ruleId = 'orphan_theme_signal_recovery';

  static List<GlobalFusionSupplementalThemeSignal> recover({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
    required Set<String> recoveredThemeKeys,
  }) {
    final fusionThemes = foundationSnapshot.evidence
        .map((row) => row.sourceThemeId)
        .where((id) => !id.startsWith('fusion_finding:'))
        .toSet();

    final results = <GlobalFusionSupplementalThemeSignal>[];
    final seen = <String>{};

    for (final ref in input.mirrors) {
      for (final reinforcement in ref.snapshot.reinforcements) {
        for (final themeId in reinforcement.themeIds) {
          final key = '$themeId|${reinforcement.mirrorKey}';
          if (fusionThemes.contains(themeId)) continue;
          if (recoveredThemeKeys.contains(themeId)) continue;
          if (!seen.add(key)) continue;

          results.add(
            GlobalFusionSupplementalThemeSignal(
              id: _id(themeId, reinforcement.mirrorKey, ref.mirrorRoleId),
              themeId: themeId,
              mirrorKey: reinforcement.mirrorKey,
              mirrorRoleId: ref.mirrorRoleId,
              mirrorFindingId: reinforcement.id,
              riskLevel: FusionRecoveryRiskLevel.high,
              recoveryRuleId: ruleId,
            ),
          );
        }
      }

      for (final agreement in ref.snapshot.agreements) {
        for (final themeId in agreement.themeIds) {
          final key = '$themeId|${agreement.mirrorKey}';
          if (fusionThemes.contains(themeId)) continue;
          if (recoveredThemeKeys.contains(themeId)) continue;
          if (!seen.add(key)) continue;

          results.add(
            GlobalFusionSupplementalThemeSignal(
              id: _id(themeId, agreement.mirrorKey, ref.mirrorRoleId),
              themeId: themeId,
              mirrorKey: agreement.mirrorKey,
              mirrorRoleId: ref.mirrorRoleId,
              mirrorFindingId: agreement.id,
              riskLevel: FusionRecoveryRiskLevel.high,
              recoveryRuleId: ruleId,
            ),
          );
        }
      }
    }

    results.sort((a, b) => a.themeId.compareTo(b.themeId));
    return results;
  }

  static String _id(String themeId, String mirrorKey, String roleId) {
    final payload = 'gf_recov_theme|$themeId|$mirrorKey|$roleId';
    return 'gf_recov_theme_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}
