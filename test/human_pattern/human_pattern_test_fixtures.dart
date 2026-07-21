import 'package:knowme/features/human_model/human_model_domain.dart';
import 'package:knowme/features/human_pattern/human_pattern_domain.dart';

import '../human_model/human_model_test_fixtures.dart';

/// Test fixtures chaining human model → human pattern system.
abstract final class HumanPatternTestFixtures {
  static HumanModelSnapshot humanModelSnapshot({int seed = 4}) {
    return HumanModelFoundationBuilder.build(
      HumanModelTestFixtures.humanModelInput(seed: seed),
      createdAt: DateTime.utc(2026, 6, 21, seed),
    );
  }

  static HumanPatternInput patternInput({int seed = 4}) {
    return HumanPatternInput(
      humanModelSnapshot: humanModelSnapshot(seed: seed),
    );
  }
}
