import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';

/// Coverage gap or single-source blind spot in a mirror dimension.
class KnowMeMirrorBlindSpot {
  const KnowMeMirrorBlindSpot({
    required this.id,
    required this.patternType,
    required this.mirrorDimension,
    required this.mirrorKey,
    required this.reasonCode,
    this.availableSystems = const [],
  });

  final String id;
  final KnowMeMirrorPatternType patternType;
  final KnowMeMirrorDimensionId mirrorDimension;
  final String? mirrorKey;
  final String reasonCode;
  final List<String> availableSystems;
}
