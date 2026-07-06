import 'dart:convert';

import '../thai_canon_evidence_repository.dart';
import 'thai_internal_evidence_mapping_refresh.dart';
import 'thai_internal_evidence_qa_validator.dart';

/// JSON report for internal evidence QA (aggregate counts only).
abstract final class ThaiInternalEvidenceQaReport {
  static String toJson(ThaiInternalEvidenceQaAudit audit) {
    return const JsonEncoder.withIndent('  ').convert(toMap(audit));
  }

  static Map<String, Object?> toMap(
    ThaiInternalEvidenceQaAudit audit, {
    ThaiInternalEvidenceMappingCoverageReport? mappingCoverage,
    ThaiInternalEvidenceRefreshAggregate? refreshAggregate,
  }) {
    final coverage = mappingCoverage;
    final refresh = refreshAggregate;
    return {
      'phase': 'Internal Evidence Mapping Refresh',
      'prerequisiteCommits': ['654133c', '5da1faa'],
      'fixtureCount': audit.fixtureResults.length,
      'fixtures': [
        for (final r in audit.fixtureResults)
          {
            'id': r.fixtureId,
            'attachmentCount': r.attachmentCount,
            'evidenceRefCount': r.evidenceRefCount,
            'badgeMismatches': r.badgeMismatches.length,
            'weakPromotedToStrong': r.weakPromotedToStrong.length,
            'provenanceGaps': r.provenanceGaps.length,
            'badgeCounts': r.badgeCounts,
            'skippedRemedyCount': r.bundle.trace.skippedRemedyEvidenceCount,
            'taksaKhumsap': {
              'taksaAttached': r.bundle.trace.taksaEvidenceAttachedCount,
              'taksaTraceOnly': r.bundle.trace.taksaEvidenceTraceOnlyCount,
              'taksaRotationAssignments':
                  r.bundle.trace.taksaRotationAssignmentCount,
              'khumsapMapped': r.bundle.trace.khumsapMapped,
              'khumsapAttached': r.bundle.trace.khumsapEvidenceAttachedCount,
              'khumsapCandidates': r.bundle.trace.khumsapEvidenceCandidateCount,
              'unmappedCandidates': r.bundle.trace.unmappedCanonEvidenceCandidates,
            },
            'runtimeMetadata': {
              'withRuntimeStatus':
                  r.bundle.trace.lifePeriodsWithRuntimeStatus.length,
              'withoutRuntimeStatus':
                  r.bundle.trace.lifePeriodsWithoutRuntimeStatus.length,
              'blockedAmbiguous':
                  r.bundle.trace.runtimeStatusBlockedByAmbiguousPosition.length,
              'blockedSourceConflict':
                  r.bundle.trace.runtimeStatusBlockedBySourceConflict.length,
              'conflictedPairs':
                  r.bundle.trace.conflictedArchetypePlanetPairs.length,
            },
          },
      ],
      'aggregateBadgeCounts': audit.aggregateBadgeCounts,
      'badgeQa': {
        'mismatches': audit.totalBadgeMismatches,
        'weakPromotedToCanonSupported': audit.totalWeakPromoted,
        'categoriesProduced': audit.allCategoriesProduced.toList()..sort(),
        'passed': audit.totalBadgeMismatches == 0 &&
            audit.totalWeakPromoted == 0,
      },
      'provenanceQa': {
        'gaps': audit.totalProvenanceGaps,
        'passed': audit.totalProvenanceGaps == 0,
      },
      'runtimeMetadata': {
        'lifePeriodsWithRuntimeStatus':
            audit.runtimeMetadata.lifePeriodsWithRuntimeStatus,
        'lifePeriodsWithoutRuntimeStatus':
            audit.runtimeMetadata.lifePeriodsWithoutRuntimeStatus,
        'blockedAmbiguous': audit.runtimeMetadata.blockedAmbiguous,
        'blockedSourceConflict': audit.runtimeMetadata.blockedSourceConflict,
        'blockedMissingPosition': audit.runtimeMetadata.blockedMissingPosition,
        'blockedNoP17Rule': audit.runtimeMetadata.blockedNoP17Rule,
        'conflictedArchetypePlanetPairs':
            audit.runtimeMetadata.conflictedArchetypePlanetPairs,
        'perFixture': [
          for (var i = 0; i < audit.fixtureResults.length; i++)
            {
              'fixtureId': audit.fixtureResults[i].fixtureId,
              ...audit.runtimeMetadata.perFixture[i],
            },
        ],
      },
      'remedySafety': {
        'skippedRemedyCountAggregate':
            audit.remedySafety.skippedRemedyCountAggregate,
        'remedyAttachmentsOnReport':
            audit.remedySafety.remedyAttachmentsOnReport,
        'remedyUserFacingRows': audit.remedySafety.remedyUserFacingRows,
        'perFixtureSkippedCounts': audit.remedySafety.perFixtureSkippedCounts,
        'passed': audit.remedySafety.passed,
      },
      'overallPassed': audit.passed,
      if (coverage != null) 'mappingCoverage': coverage.toMap(),
      if (refresh != null) 'evidenceRefresh': refresh.toMap(),
    };
  }

  static Map<String, Object?> toMapFromRepository({
    required ThaiInternalEvidenceQaAudit audit,
    required ThaiCanonEvidenceRepository repository,
  }) {
    return toMap(
      audit,
      mappingCoverage:
          ThaiInternalEvidenceMappingCoverageReport.fromRepository(repository),
      refreshAggregate: ThaiInternalEvidenceRefreshAggregate.fromAudit(audit),
    );
  }
}
