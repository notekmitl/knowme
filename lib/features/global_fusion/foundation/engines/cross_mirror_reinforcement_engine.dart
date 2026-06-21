import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot_findings.dart';

import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_findings.dart';
import 'cross_mirror_agreement_engine.dart';

/// GF5 — cross-mirror agreement elevates reinforcement confidence.
abstract final class CrossMirrorReinforcementEngine {
  static List<GlobalFusionCrossMirrorReinforcement> detect({
    required GlobalFusionInput input,
    required List<GlobalFusionCrossMirrorAgreement> agreements,
  }) {
    if (agreements.isEmpty) return const [];

    final agreementKeys = agreements.map((item) => item.mirrorKey).toSet();
    final byKey = <String, _ReinforcementCluster>{};

    for (final ref in input.mirrors) {
      for (final reinforcement in ref.snapshot.reinforcements) {
        if (!agreementKeys.contains(reinforcement.mirrorKey)) continue;

        final cluster = byKey.putIfAbsent(
          reinforcement.mirrorKey,
          () => _ReinforcementCluster(
            mirrorKey: reinforcement.mirrorKey,
            mirrorDimension: reinforcement.mirrorDimension,
          ),
        );
        cluster.add(ref.mirrorRoleId, reinforcement);
      }

      for (final agreement in ref.snapshot.agreements) {
        if (!agreementKeys.contains(agreement.mirrorKey)) continue;

        final cluster = byKey.putIfAbsent(
          agreement.mirrorKey,
          () => _ReinforcementCluster(
            mirrorKey: agreement.mirrorKey,
            mirrorDimension: agreement.mirrorDimension,
          ),
        );
        cluster.addAgreement(ref.mirrorRoleId, agreement);
      }
    }

    final results = <GlobalFusionCrossMirrorReinforcement>[];
    for (final entry in byKey.entries) {
      final cluster = entry.value;
      if (cluster.mirrorRoleIds.length < 2) continue;

      final roles = cluster.mirrorRoleIds.toList()..sort();
      final boost = (0.15 * roles.length + cluster.evidenceCount * 0.05)
          .clamp(0.0, 0.45);

      results.add(
        GlobalFusionCrossMirrorReinforcement(
          id: _reinforcementId(entry.key, roles),
          mirrorKey: entry.key,
          mirrorDimension: cluster.mirrorDimension,
          mirrorRoleIds: roles,
          mirrorFindingIds: cluster.findingIds.toList()..sort(),
          themeIds: cluster.themeIds.toList()..sort(),
          evidenceCount: cluster.evidenceCount,
          reinforcementBoost: boost,
        ),
      );
    }

    results.sort((a, b) => a.mirrorKey.compareTo(b.mirrorKey));
    return results;
  }

  static String _reinforcementId(String mirrorKey, List<String> roles) {
    final payload = 'gf_reinforcement|$mirrorKey|${roles.join(',')}';
    return 'gf_reinforcement_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}

class _ReinforcementCluster {
  _ReinforcementCluster({
    required this.mirrorKey,
    required this.mirrorDimension,
  });

  final String mirrorKey;
  final String mirrorDimension;
  final Set<String> mirrorRoleIds = {};
  final Set<String> themeIds = {};
  final Set<String> findingIds = {};
  var evidenceCount = 0;

  void add(String roleId, KnowMeMirrorSnapshotReinforcement reinforcement) {
    mirrorRoleIds.add(roleId);
    themeIds.addAll(reinforcement.themeIds);
    findingIds.add(reinforcement.id);
    evidenceCount += reinforcement.evidenceCount;
  }

  void addAgreement(String roleId, KnowMeMirrorSnapshotAgreement agreement) {
    mirrorRoleIds.add(roleId);
    themeIds.addAll(agreement.themeIds);
    findingIds.add(agreement.id);
  }
}
