import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

/// HM input contract — global fusion snapshot only.
class HumanModelInput {
  const HumanModelInput({
    required this.fusionSnapshot,
  });

  final GlobalFusionSnapshot fusionSnapshot;
}
