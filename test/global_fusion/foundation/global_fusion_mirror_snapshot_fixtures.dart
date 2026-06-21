import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/mirror_v3/validation/fixtures/mirror_synthetic_bundle_factory.dart';

import 'package:knowme/features/global_fusion/foundation/global_fusion_foundation_domain.dart';

/// Test-only mirror snapshot fixtures for global fusion foundation.
abstract final class GlobalFusionMirrorSnapshotFixtures {
  static KnowMeMirrorSnapshot mirrorSnapshot(int caseIndex) {
    final input = MirrorSyntheticBundleFactory.buildCase(caseIndex);
    final result = KnowMeMirrorEngine.reflect(input);
    return KnowMeMirrorSnapshotBuilder.fromEngineResult(
      result,
      createdAt: DateTime.utc(2026, 6, 21, caseIndex),
    );
  }

  static GlobalFusionInput dualMirrorInput({int seed = 0}) {
    return GlobalFusionInput(
      mirrors: [
        GlobalFusionMirrorRef(
          mirrorRoleId: GlobalFusionMirrorRoles.astrology,
          snapshot: mirrorSnapshot(seed * 2),
        ),
        GlobalFusionMirrorRef(
          mirrorRoleId: GlobalFusionMirrorRoles.personality,
          snapshot: mirrorSnapshot(seed * 2 + 1),
        ),
      ],
    );
  }

  static GlobalFusionInput nMirrorInput(List<int> caseIndices) {
    final roles = [
      GlobalFusionMirrorRoles.astrology,
      GlobalFusionMirrorRoles.personality,
      'supplemental_mirror',
    ];

    return GlobalFusionInput(
      mirrors: [
        for (var i = 0; i < caseIndices.length; i++)
          GlobalFusionMirrorRef(
            mirrorRoleId: roles[i % roles.length],
            snapshot: mirrorSnapshot(caseIndices[i]),
          ),
      ],
    );
  }
}
