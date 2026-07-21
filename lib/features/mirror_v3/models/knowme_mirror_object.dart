import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';

import '../enums/knowme_mirror_dimension_id.dart';
import '../enums/knowme_mirror_source_type.dart';
import '../enums/knowme_mirror_system_id.dart';
import 'knowme_mirror_evidence_refs.dart';
import 'knowme_mirror_metadata.dart';

/// Atomic cross-system mirror pattern.
class KnowMeMirrorObject {
  const KnowMeMirrorObject({
    required this.mirrorId,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.sourceThemeIds,
    required this.sourceSystems,
    required this.sourceTypes,
    required this.evidenceRefs,
    required this.metadata,
    this.warnings = const [],
  });

  final String mirrorId;
  final String mirrorKey;
  final KnowMeMirrorDimensionId mirrorDimension;
  final List<String> sourceThemeIds;
  final List<KnowMeMirrorSystemId> sourceSystems;
  final List<KnowMeMirrorSourceType> sourceTypes;
  final KnowMeMirrorEvidenceRefs evidenceRefs;
  final KnowMeMirrorMetadata metadata;
  final List<ProfileWarning> warnings;

  Map<String, dynamic> toMap() {
    return {
      'mirrorId': mirrorId,
      'mirrorKey': mirrorKey,
      'mirrorDimension': mirrorDimension.id,
      'sourceThemeIds': sourceThemeIds,
      'sourceSystems': sourceSystems.map((s) => s.id).toList(),
      'sourceTypes': sourceTypes.map((s) => s.id).toList(),
      'evidenceRefs': evidenceRefs.toMap(),
      'metadata': metadata.toMap(),
      'warnings': warnings
          .map(
            (warning) => {
              'code': warning.code,
              'severity': warning.severity.name,
              'message': warning.message,
              'affectedFields': warning.affectedFields,
            },
          )
          .toList(),
    };
  }
}
