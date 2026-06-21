import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_findings.dart';
import 'cross_mirror_agreement_engine.dart';

/// GF6 — one mirror reflects a key another mirror does not surface.
abstract final class CrossMirrorBlindSpotEngine {
  static List<GlobalFusionCrossMirrorBlindSpot> detect(
    GlobalFusionInput input,
  ) {
    final reflected = _reflectedKeys(input);
    final results = <GlobalFusionCrossMirrorBlindSpot>[];

    for (final ref in input.mirrors) {
      for (final blindSpot in ref.snapshot.blindSpots) {
        final blindKey = blindSpot.mirrorKey;
        if (blindKey == null || blindKey.isEmpty) continue;

        for (final other in input.mirrors) {
          if (other.mirrorRoleId == ref.mirrorRoleId) continue;

          final otherReflection = reflected[other.mirrorRoleId];
          if (otherReflection == null) continue;
          if (!otherReflection.containsKey(blindKey)) continue;

          final reflection = otherReflection[blindKey]!;
          results.add(
            GlobalFusionCrossMirrorBlindSpot(
              id: _blindSpotId(
                reflectingRole: other.mirrorRoleId,
                blindRole: ref.mirrorRoleId,
                mirrorKey: blindKey,
              ),
              mirrorKey: blindKey,
              mirrorDimension: blindSpot.mirrorDimension,
              reflectingMirrorRoleId: other.mirrorRoleId,
              blindMirrorRoleId: ref.mirrorRoleId,
              reflectingMirrorFindingId: reflection.findingId,
              blindMirrorFindingId: blindSpot.id,
              reasonCode: blindSpot.reasonCode,
            ),
          );
        }
      }
    }

    results.sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  static Map<String, Map<String, _Reflection>> _reflectedKeys(
    GlobalFusionInput input,
  ) {
    final map = <String, Map<String, _Reflection>>{};

    for (final ref in input.mirrors) {
      final keys = <String, _Reflection>{};
      for (final agreement in ref.snapshot.agreements) {
        keys[agreement.mirrorKey] = _Reflection(
          findingId: agreement.id,
        );
      }
      for (final reinforcement in ref.snapshot.reinforcements) {
        keys.putIfAbsent(
          reinforcement.mirrorKey,
          () => _Reflection(findingId: reinforcement.id),
        );
      }
      map[ref.mirrorRoleId] = keys;
    }

    return map;
  }

  static String _blindSpotId({
    required String reflectingRole,
    required String blindRole,
    required String mirrorKey,
  }) {
    final payload = 'gf_blind|$reflectingRole|$blindRole|$mirrorKey';
    return 'gf_blind_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}

class _Reflection {
  const _Reflection({required this.findingId});

  final String findingId;
}
