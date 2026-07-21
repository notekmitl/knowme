import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';

/// Multiple evidence sources reinforcing the same mirror pattern.
class KnowMeMirrorReinforcement {
  const KnowMeMirrorReinforcement({
    required this.id,
    required this.patternType,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
    required this.supportingSystem,
    required this.supportingLensKey,
    required this.evidenceCount,
    required this.structuralWeight,
  });

  final String id;
  final KnowMeMirrorPatternType patternType;
  final String mirrorKey;
  final KnowMeMirrorDimensionId mirrorDimension;
  final List<String> themeIds;
  final KnowMeMirrorSystemId supportingSystem;
  final String supportingLensKey;
  final int evidenceCount;
  final double structuralWeight;
}
