import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';

/// Normalized theme row for MV1 cross-system engines.
class KnowMeMirrorThemeSignal {
  const KnowMeMirrorThemeSignal({
    required this.systemId,
    required this.sourceType,
    required this.sourceLensKey,
    required this.themeId,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.patternFamily,
    required this.confidence,
    required this.prominence,
    required this.evidenceCount,
    required this.sourceSnapshotId,
    required this.mappingRuleId,
    this.interpretationIds = const [],
    this.signalIds = const [],
    this.meaningIds = const [],
  });

  final KnowMeMirrorSystemId systemId;
  final KnowMeMirrorSourceType sourceType;
  final String sourceLensKey;
  final String themeId;
  final String mirrorKey;
  final KnowMeMirrorDimensionId mirrorDimension;
  final String patternFamily;
  final double confidence;
  final double prominence;
  final int evidenceCount;
  final String sourceSnapshotId;
  final String mappingRuleId;
  final List<String> interpretationIds;
  final List<String> signalIds;
  final List<String> meaningIds;
}
