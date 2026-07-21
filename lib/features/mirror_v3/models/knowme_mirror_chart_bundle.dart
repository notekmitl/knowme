import 'package:knowme/features/astrology/thai/foundation/models/profile_warning.dart';

import '../constants/knowme_mirror_version_contract.dart';
import 'knowme_mirror_lineage_chain.dart';
import 'knowme_mirror_object.dart';

/// Engine output container produced by MV1.
class KnowMeMirrorChartBundle {
  const KnowMeMirrorChartBundle({
    required this.mirrorBundleId,
    required this.mirrorDomainVersion,
    required this.mirrorScopeId,
    required this.generatedAt,
    required this.lineage,
    required this.mirrors,
    required this.structuralHash,
    this.warnings = const [],
  });

  final String mirrorBundleId;
  final String mirrorDomainVersion;
  final String mirrorScopeId;
  final DateTime generatedAt;
  final KnowMeMirrorLineageChain lineage;
  final List<KnowMeMirrorObject> mirrors;
  final String structuralHash;
  final List<ProfileWarning> warnings;

  Map<String, dynamic> toMap() {
    return {
      'mirrorBundleId': mirrorBundleId,
      'mirrorDomainVersion': mirrorDomainVersion,
      'mirrorScopeId': mirrorScopeId,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'lineage': lineage.toMap(),
      'mirrors': mirrors.map((mirror) => mirror.toMap()).toList(),
      'structuralHash': structuralHash,
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

/// Alias for domain snapshot contract — mirrors are the snapshot payload.
typedef KnowMeMirrorSnapshot = KnowMeMirrorChartBundle;

abstract final class KnowMeMirrorBundleContract {
  static const mirrorDomainVersion =
      KnowMeMirrorVersionContract.mirrorDomainVersion;
}
