import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';

/// Input contract — human model snapshot only.
class HumanPatternInput {
  const HumanPatternInput({
    required this.humanModelSnapshot,
  });

  final HumanModelSnapshot humanModelSnapshot;
}
