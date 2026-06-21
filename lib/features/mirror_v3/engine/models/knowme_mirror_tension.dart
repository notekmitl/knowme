import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';

/// Opposing pattern tension across lenses or systems.
class KnowMeMirrorTension {
  const KnowMeMirrorTension({
    required this.id,
    required this.patternType,
    required this.mirrorDimension,
    required this.themeIds,
    required this.patternFamilies,
    required this.supportingSystems,
    required this.supportingLensKeys,
    required this.reasonCode,
  });

  final String id;
  final KnowMeMirrorPatternType patternType;
  final KnowMeMirrorDimensionId mirrorDimension;
  final List<String> themeIds;
  final List<String> patternFamilies;
  final List<KnowMeMirrorSystemId> supportingSystems;
  final List<String> supportingLensKeys;
  final String reasonCode;
}
