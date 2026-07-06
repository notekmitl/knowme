import 'thai_internal_evidence_qa_validator.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';

import '../thai_canon_evidence_repository.dart';
import '../thai_canon_khumsap_runtime_mapping.dart';
import '../thai_canon_ontology_runtime_mapping.dart';
import '../thai_canon_taksa_role_runtime_mapping.dart';
import '../thai_mahabhut_khumsap_runtime_key.dart';
import '../thai_taksa_rotation_metadata.dart';
import 'thai_internal_evidence_qa_validator.dart';

/// Mapping coverage snapshot for internal evidence refresh reporting.
class ThaiInternalEvidenceMappingCoverageReport {
  const ThaiInternalEvidenceMappingCoverageReport({
    required this.canonAtomicCount,
    required this.planetsMapped,
    required this.planetsTotal,
    required this.mahabhutPositionsMapped,
    required this.mahabhutPositionsTotal,
    required this.khumsapMapped,
    required this.khumsapInternalRuntimeKey,
    required this.taksaRolesMapped,
    required this.taksaRolesTotal,
    required this.periodStatusMapped,
    required this.periodStatusTotal,
    required this.remedyCanonUnitsInternalOnly,
    required this.lookupTableUnitsReferenceOnly,
    required this.archetypeChartEntityCount,
    required this.rotationIndexEntityCount,
    required this.taksaSupportedWeekdays,
    required this.taksaPartialReviewWeekdays,
    required this.taksaNotInSourceWeekdays,
    required this.mahabhutaThayaOutOfCanonScope,
  });

  final int canonAtomicCount;
  final int planetsMapped;
  final int planetsTotal;
  final int mahabhutPositionsMapped;
  final int mahabhutPositionsTotal;
  final bool khumsapMapped;
  final String khumsapInternalRuntimeKey;
  final int taksaRolesMapped;
  final int taksaRolesTotal;
  final int periodStatusMapped;
  final int periodStatusTotal;
  final int remedyCanonUnitsInternalOnly;
  final int lookupTableUnitsReferenceOnly;
  final int archetypeChartEntityCount;
  final int rotationIndexEntityCount;
  final List<int> taksaSupportedWeekdays;
  final List<int> taksaPartialReviewWeekdays;
  final List<int> taksaNotInSourceWeekdays;
  final bool mahabhutaThayaOutOfCanonScope;

  static ThaiInternalEvidenceMappingCoverageReport fromRepository(
    ThaiCanonEvidenceRepository repository,
  ) {
    final planetMaps = repository.planetMappings;
    final mahabhutMaps = repository.mahabhutPositionMappings;
    final taksaMaps = ThaiCanonOntologyRuntimeMapping.taksaRoleMappings();
    final periodMaps = ThaiCanonOntologyRuntimeMapping.periodStatusMappings();
    final rotationAudit = ThaiTaksaRotationFeasibilityAudit.audit(
      repository: repository,
    );

    return ThaiInternalEvidenceMappingCoverageReport(
      canonAtomicCount: repository.atomicCount,
      planetsMapped: planetMaps.where((m) => m.isMapped).length,
      planetsTotal: planetMaps.length,
      mahabhutPositionsMapped: mahabhutMaps.where((m) => m.isMapped).length,
      mahabhutPositionsTotal: mahabhutMaps.length,
      khumsapMapped: mahabhutMaps
          .any((m) => m.canonEntityId == ThaiCanonKhumsapRuntimeMapping.canonEntityId && m.isMapped),
      khumsapInternalRuntimeKey: ThaiMahabhutKhumsapRuntimeKey.khumsap,
      taksaRolesMapped: taksaMaps.where((m) => m.isMapped).length,
      taksaRolesTotal: taksaMaps.length,
      periodStatusMapped: periodMaps.where((m) => m.isMapped).length,
      periodStatusTotal: periodMaps.length,
      remedyCanonUnitsInternalOnly: repository.index.units
          .where((u) => u.domain == KnowledgeDomain.remedies)
          .length,
      lookupTableUnitsReferenceOnly: repository.index.units
          .where((u) => u.domain == KnowledgeDomain.lookupTables)
          .length,
      archetypeChartEntityCount: CanonOntologyData.archetypeCharts.length,
      rotationIndexEntityCount: CanonOntologyData.rotationIndices.length,
      taksaSupportedWeekdays: rotationAudit.supportedWeekdayNumbers,
      taksaPartialReviewWeekdays:
          rotationAudit.partialSourceReviewWeekdayNumbers,
      taksaNotInSourceWeekdays: rotationAudit.notInSourceWeekdayNumbers,
      mahabhutaThayaOutOfCanonScope: true,
    );
  }

  Map<String, Object?> toMap() => {
        'canonAtomicCount': canonAtomicCount,
        'planets': '$planetsMapped / $planetsTotal',
        'mahabhutPositions': '$mahabhutPositionsMapped / $mahabhutPositionsTotal',
        'khumsapMapped': khumsapMapped,
        'khumsapInternalRuntimeKey': khumsapInternalRuntimeKey,
        'taksaRoles': '$taksaRolesMapped / $taksaRolesTotal',
        'periodStatus': '$periodStatusMapped / $periodStatusTotal',
        'lookupTableUnitsReferenceOnly': lookupTableUnitsReferenceOnly,
        'remedyCanonUnitsInternalOnly': remedyCanonUnitsInternalOnly,
        'archetypeChartEntityCount': archetypeChartEntityCount,
        'rotationIndexEntityCount': rotationIndexEntityCount,
        'taksaSupportedWeekdays': taksaSupportedWeekdays,
        'taksaPartialReviewWeekdays': taksaPartialReviewWeekdays,
        'taksaNotInSourceWeekdays': taksaNotInSourceWeekdays,
        'mahabhutaThayaOutOfCanonScope': mahabhutaThayaOutOfCanonScope,
      };
}

/// Aggregate evidence enrichment metrics across the 9-fixture harness.
class ThaiInternalEvidenceRefreshAggregate {
  const ThaiInternalEvidenceRefreshAggregate({
    required this.totalAttachments,
    required this.totalEvidenceRefs,
    required this.taksaEvidenceAttachedCount,
    required this.taksaEvidenceTraceOnlyCount,
    required this.khumsapEvidenceAttachedCount,
    required this.khumsapEvidenceCandidateCount,
    required this.unmappedCanonCandidateIds,
    required this.traceOnlyCandidateCount,
    required this.outOfCanonScopeSignalCount,
  });

  final int totalAttachments;
  final int totalEvidenceRefs;
  final int taksaEvidenceAttachedCount;
  final int taksaEvidenceTraceOnlyCount;
  final int khumsapEvidenceAttachedCount;
  final int khumsapEvidenceCandidateCount;
  final List<String> unmappedCanonCandidateIds;
  final int traceOnlyCandidateCount;
  final int outOfCanonScopeSignalCount;

  static ThaiInternalEvidenceRefreshAggregate fromAudit(
    ThaiInternalEvidenceQaAudit audit,
  ) {
    var attachments = 0;
    var refs = 0;
    var taksaAttached = 0;
    var taksaTrace = 0;
    var khumsapAttached = 0;
    var khumsapCandidates = 0;
    var traceOnly = 0;
    var outOfScope = 0;
    final unmapped = <String>{};

    for (final result in audit.fixtureResults) {
      final trace = result.bundle.trace;
      attachments += result.attachmentCount;
      refs += result.evidenceRefCount;
      taksaAttached += trace.taksaEvidenceAttachedCount;
      taksaTrace += trace.taksaEvidenceTraceOnlyCount;
      khumsapAttached += trace.khumsapEvidenceAttachedCount;
      khumsapCandidates += trace.khumsapEvidenceCandidateCount;
      traceOnly += trace.traceOnlyEvidenceCandidates.length;
      outOfScope += trace.outOfCanonScopeSignals.length;
      unmapped.addAll(trace.unmappedCanonEvidenceCandidates);
    }

    final sortedUnmapped = unmapped.toList()..sort();

    return ThaiInternalEvidenceRefreshAggregate(
      totalAttachments: attachments,
      totalEvidenceRefs: refs,
      taksaEvidenceAttachedCount: taksaAttached,
      taksaEvidenceTraceOnlyCount: taksaTrace,
      khumsapEvidenceAttachedCount: khumsapAttached,
      khumsapEvidenceCandidateCount: khumsapCandidates,
      unmappedCanonCandidateIds: sortedUnmapped,
      traceOnlyCandidateCount: traceOnly,
      outOfCanonScopeSignalCount: outOfScope,
    );
  }

  Map<String, Object?> toMap() => {
        'totalAttachments': totalAttachments,
        'totalEvidenceRefs': totalEvidenceRefs,
        'taksaEvidenceAttachedCount': taksaEvidenceAttachedCount,
        'taksaEvidenceTraceOnlyCount': taksaEvidenceTraceOnlyCount,
        'khumsapEvidenceAttachedCount': khumsapEvidenceAttachedCount,
        'khumsapEvidenceCandidateCount': khumsapEvidenceCandidateCount,
        'unmappedCanonCandidateIds': unmappedCanonCandidateIds,
        'traceOnlyCandidateCount': traceOnlyCandidateCount,
        'outOfCanonScopeSignalCount': outOfCanonScopeSignalCount,
      };
}
