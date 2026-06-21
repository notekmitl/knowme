import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_system_id.dart';

/// Cross-system or cross-lens agreement record.
class KnowMeMirrorAgreement {
  const KnowMeMirrorAgreement({
    required this.id,
    required this.patternType,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
    required this.supportingSystems,
    required this.supportingLensKeys,
    required this.confidence,
  });

  final String id;
  final KnowMeMirrorPatternType patternType;
  final String mirrorKey;
  final KnowMeMirrorDimensionId mirrorDimension;
  final List<String> themeIds;
  final List<KnowMeMirrorSystemId> supportingSystems;
  final List<String> supportingLensKeys;
  final double confidence;
}
