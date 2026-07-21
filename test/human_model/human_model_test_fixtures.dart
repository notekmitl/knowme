import 'package:knowme/features/global_fusion/foundation/global_fusion_foundation_domain.dart';
import 'package:knowme/features/human_model/human_model_domain.dart';

import '../global_fusion/foundation/global_fusion_mirror_snapshot_fixtures.dart';

/// Test fixtures chaining global fusion → human model.
abstract final class HumanModelTestFixtures {
  static GlobalFusionSnapshot fusionSnapshot({int seed = 4}) {
    final input = GlobalFusionMirrorSnapshotFixtures.dualMirrorInput(seed: seed);
    return GlobalFusionFoundationBuilder.build(
      input,
      createdAt: DateTime.utc(2026, 6, 21, seed),
    );
  }

  static HumanModelInput humanModelInput({int seed = 4}) {
    return HumanModelInput(fusionSnapshot: fusionSnapshot(seed: seed));
  }
}
