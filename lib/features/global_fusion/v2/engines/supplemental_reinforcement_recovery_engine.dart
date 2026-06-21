import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/foundation/engines/cross_mirror_agreement_engine.dart';

import '../domain/fusion_recovery_enums.dart';
import '../domain/global_fusion_supplemental_findings.dart';

/// FCR4 — recovers cross-role reinforcement bridges (low risk).
abstract final class SupplementalReinforcementRecoveryEngine {
  static const ruleId = 'reinforcement_agreement_bridge';

  static List<GlobalFusionSupplementalReinforcement> recover({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
  }) {
    final coveredKeys = _coveredMirrorKeys(foundationSnapshot);
    final byKey = <String, _MirrorKeySignals>{};

    for (final ref in input.mirrors) {
      for (final reinforcement in ref.snapshot.reinforcements) {
        byKey
            .putIfAbsent(reinforcement.mirrorKey, () => _MirrorKeySignals())
            .addReinforcement(ref.mirrorRoleId, reinforcement);
      }
      for (final agreement in ref.snapshot.agreements) {
        byKey
            .putIfAbsent(agreement.mirrorKey, () => _MirrorKeySignals())
            .addAgreement(ref.mirrorRoleId, agreement);
      }
    }

    final results = <GlobalFusionSupplementalReinforcement>[];

    for (final entry in byKey.entries) {
      final key = entry.key;
      if (coveredKeys.contains(key)) continue;

      final signals = entry.value;
      if (!signals.hasCrossRoleBridge) continue;

      final roles = signals.roleIds.toList()..sort();
      final themes = signals.themeIds.toList()..sort();
      final findingIds = signals.findingIds.toList()..sort();
      final sourceIds = signals.sourceFindingIds.toList()..sort();

      final boost = (0.12 * roles.length + signals.evidenceCount * 0.04)
          .clamp(0.15, 0.40);

      results.add(
        GlobalFusionSupplementalReinforcement(
          id: _id(key, roles),
          mirrorKey: key,
          mirrorDimension: signals.mirrorDimension,
          mirrorRoleIds: roles,
          mirrorFindingIds: findingIds,
          themeIds: themes,
          evidenceCount: signals.evidenceCount,
          reinforcementBoost: boost,
          riskLevel: FusionRecoveryRiskLevel.low,
          recoveryRuleId: ruleId,
          sourceFindingIds: sourceIds,
        ),
      );
    }

    results.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return results;
  }

  static Set<String> _coveredMirrorKeys(GlobalFusionSnapshot snapshot) {
    final keys = <String>{};
    for (final finding in snapshot.reinforcements) {
      keys.add(finding.mirrorKey);
    }
    for (final finding in snapshot.agreements) {
      keys.add(finding.mirrorKey);
    }
    return keys;
  }

  static String _id(String mirrorKey, List<String> roles) {
    final payload = 'gf_recov_reinforcement|$mirrorKey|${roles.join(',')}';
    return 'gf_recov_reinforcement_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}

class _MirrorKeySignals {
  final Set<String> roleIds = {};
  final Set<String> themeIds = {};
  final Set<String> findingIds = {};
  final Set<String> sourceFindingIds = {};
  var evidenceCount = 0;
  var hasReinforcement = false;
  var hasAgreement = false;
  String mirrorDimension = '';

  bool get hasCrossRoleBridge =>
      roleIds.length >= 2 && hasReinforcement && hasAgreement;

  void addReinforcement(String roleId, dynamic reinforcement) {
    roleIds.add(roleId);
    hasReinforcement = true;
    themeIds.addAll(reinforcement.themeIds);
    findingIds.add(reinforcement.id);
    sourceFindingIds.add(reinforcement.id);
    evidenceCount += reinforcement.evidenceCount as int;
    if (mirrorDimension.isEmpty) {
      mirrorDimension = reinforcement.mirrorDimension as String;
    }
  }

  void addAgreement(String roleId, dynamic agreement) {
    roleIds.add(roleId);
    hasAgreement = true;
    themeIds.addAll(agreement.themeIds);
    findingIds.add(agreement.id);
    sourceFindingIds.add(agreement.id);
    if (mirrorDimension.isEmpty) {
      mirrorDimension = agreement.mirrorDimension as String;
    }
  }
}
