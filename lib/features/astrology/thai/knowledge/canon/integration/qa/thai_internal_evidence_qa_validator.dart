import '../presentation/thai_canon_evidence_review_summary.dart';
import '../presentation/thai_internal_evidence_badge.dart';
import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_ref.dart';
import '../thai_canon_evidence_trace.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_canon_evidence_alignment_classification.dart';
import 'thai_canon_evidence_alignment_classifier.dart';

/// One badge correctness finding for an attachment or trace row.
class ThaiInternalEvidenceBadgeAuditRecord {
  const ThaiInternalEvidenceBadgeAuditRecord({
    required this.fixtureId,
    required this.signalId,
    required this.expected,
    required this.actual,
    this.sectionId,
    this.evidenceType,
  });

  final String fixtureId;
  final String signalId;
  final String? sectionId;
  final ThaiCanonEvidenceType? evidenceType;
  final ThaiInternalEvidenceBadgeCategory expected;
  final ThaiInternalEvidenceBadgeCategory actual;

  bool get isMatch => expected == actual;
}

/// Provenance gap on one evidence ref row.
class ThaiInternalEvidenceProvenanceGap {
  const ThaiInternalEvidenceProvenanceGap({
    required this.fixtureId,
    required this.signalId,
    required this.unitId,
    required this.missingFields,
  });

  final String fixtureId;
  final String signalId;
  final String unitId;
  final List<String> missingFields;
}

/// Per-fixture internal evidence QA snapshot.
class ThaiInternalEvidenceFixtureQaResult {
  const ThaiInternalEvidenceFixtureQaResult({
    required this.fixtureId,
    required this.bundle,
    required this.badgeMismatches,
    required this.weakPromotedToStrong,
    required this.provenanceGaps,
    required this.badgeCounts,
  });

  final String fixtureId;
  final ThaiMirrorCanonEvidenceBundle bundle;
  final List<ThaiInternalEvidenceBadgeAuditRecord> badgeMismatches;
  final List<String> weakPromotedToStrong;
  final List<ThaiInternalEvidenceProvenanceGap> provenanceGaps;
  final Map<String, int> badgeCounts;

  int get attachmentCount => bundle.attachmentCount;
  int get evidenceRefCount => bundle.totalEvidenceRefs;
}

/// Aggregate internal evidence QA audit.
class ThaiInternalEvidenceQaAudit {
  const ThaiInternalEvidenceQaAudit({
    required this.fixtureResults,
    required this.aggregateBadgeCounts,
    required this.totalBadgeMismatches,
    required this.totalWeakPromoted,
    required this.totalProvenanceGaps,
    required this.runtimeMetadata,
    required this.remedySafety,
    required this.allCategoriesProduced,
  });

  final List<ThaiInternalEvidenceFixtureQaResult> fixtureResults;
  final Map<String, int> aggregateBadgeCounts;
  final int totalBadgeMismatches;
  final int totalWeakPromoted;
  final int totalProvenanceGaps;
  final ThaiInternalEvidenceRuntimeMetadataSummary runtimeMetadata;
  final ThaiInternalEvidenceRemedySafetySummary remedySafety;
  final Set<String> allCategoriesProduced;

  bool get passed =>
      totalBadgeMismatches == 0 &&
      totalWeakPromoted == 0 &&
      totalProvenanceGaps == 0 &&
      remedySafety.passed;
}

class ThaiInternalEvidenceRuntimeMetadataSummary {
  const ThaiInternalEvidenceRuntimeMetadataSummary({
    required this.lifePeriodsWithRuntimeStatus,
    required this.lifePeriodsWithoutRuntimeStatus,
    required this.blockedAmbiguous,
    required this.blockedSourceConflict,
    required this.blockedMissingPosition,
    required this.blockedNoP17Rule,
    required this.conflictedArchetypePlanetPairs,
    required this.perFixture,
  });

  final int lifePeriodsWithRuntimeStatus;
  final int lifePeriodsWithoutRuntimeStatus;
  final int blockedAmbiguous;
  final int blockedSourceConflict;
  final int blockedMissingPosition;
  final int blockedNoP17Rule;
  final int conflictedArchetypePlanetPairs;
  final List<Map<String, int>> perFixture;
}

class ThaiInternalEvidenceRemedySafetySummary {
  const ThaiInternalEvidenceRemedySafetySummary({
    required this.skippedRemedyCountAggregate,
    required this.remedyAttachmentsOnReport,
    required this.remedyUserFacingRows,
    required this.perFixtureSkippedCounts,
  });

  final int skippedRemedyCountAggregate;
  final int remedyAttachmentsOnReport;
  final int remedyUserFacingRows;
  final List<int> perFixtureSkippedCounts;

  bool get passed =>
      remedyAttachmentsOnReport == 0 &&
      remedyUserFacingRows == 0 &&
      skippedRemedyCountAggregate > 0;
}

/// Independent badge rule verification — mirrors QA policy, not assigner internals.
abstract final class ThaiInternalEvidenceQaValidator {
  static ThaiInternalEvidenceFixtureQaResult auditFixture({
    required String fixtureId,
    required ThaiMirrorCanonEvidenceBundle bundle,
  }) {
    final trace = bundle.trace;
    final mismatches = <ThaiInternalEvidenceBadgeAuditRecord>[];
    final weakPromoted = <String>[];
    final provenanceGaps = <ThaiInternalEvidenceProvenanceGap>[];
    final badgeCounts = <String, int>{
      for (final c in ThaiInternalEvidenceBadgeCategory.values) c.wire: 0,
    };

    for (final attachment in bundle.attachments) {
      final (classification, _) =
          ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(attachment);
      final expected = _expectedBadge(
        attachment: attachment,
        classification: classification,
      );
      final actual = ThaiInternalEvidenceBadgeAssigner.forAttachment(
        attachment,
        trace: trace,
      );

      badgeCounts[actual.wire] = (badgeCounts[actual.wire] ?? 0) + 1;

      if (expected != actual) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: attachment.signalId,
            sectionId: attachment.sectionId,
            evidenceType: attachment.evidenceType,
            expected: expected,
            actual: actual,
          ),
        );
      }

      if (_isWeakClassification(classification) &&
          actual == ThaiInternalEvidenceBadgeCategory.canonSupported) {
        weakPromoted.add(attachment.signalId);
      }

      for (final ref in attachment.evidenceRefs) {
        provenanceGaps.addAll(
          _provenanceGaps(fixtureId, attachment.signalId, ref),
        );
      }
    }

    for (final signal in trace.outOfCanonScopeSignals) {
      final actual = ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
        signal,
        trace: trace,
      );
      badgeCounts[actual.wire] = (badgeCounts[actual.wire] ?? 0) + 1;
      if (actual != ThaiInternalEvidenceBadgeCategory.outOfCanonScope) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: signal,
            expected: ThaiInternalEvidenceBadgeCategory.outOfCanonScope,
            actual: actual,
          ),
        );
      }
    }

    for (final signal in trace.inCanonScopeUnmappedSignals) {
      final actual = ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
        signal,
        trace: trace,
      );
      badgeCounts[actual.wire] = (badgeCounts[actual.wire] ?? 0) + 1;
      if (actual != ThaiInternalEvidenceBadgeCategory.noCanonEvidence) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: signal,
            expected: ThaiInternalEvidenceBadgeCategory.noCanonEvidence,
            actual: actual,
          ),
        );
      }
    }

    for (final entry in trace.runtimeStatusWithoutPositionBreakdown) {
      final expected =
          ThaiInternalEvidenceBadgeAssigner.forRuntimeBlocker(entry);
      badgeCounts[expected.wire] = (badgeCounts[expected.wire] ?? 0) + 1;
      if (entry.contains('AMBIGUOUS_POSITION') &&
          expected != ThaiInternalEvidenceBadgeCategory.blockedAmbiguous) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: 'blocker:$entry',
            expected: ThaiInternalEvidenceBadgeCategory.blockedAmbiguous,
            actual: expected,
          ),
        );
      }
      if (entry.contains('SOURCE_CONFLICT') &&
          expected != ThaiInternalEvidenceBadgeCategory.blockedSourceConflict) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: 'blocker:$entry',
            expected: ThaiInternalEvidenceBadgeCategory.blockedSourceConflict,
            actual: expected,
          ),
        );
      }
    }

    for (final _ in trace.runtimeStatusBlockedByAmbiguousPosition) {
      badgeCounts[ThaiInternalEvidenceBadgeCategory.blockedAmbiguous.wire] =
          (badgeCounts[ThaiInternalEvidenceBadgeCategory.blockedAmbiguous.wire] ??
              0) +
          1;
    }
    for (final _ in trace.conflictedArchetypePlanetPairs) {
      badgeCounts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict.wire] =
          (badgeCounts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict.wire] ??
              0) +
          1;
    }
    for (final candidate in trace.traceOnlyEvidenceCandidates) {
      badgeCounts[ThaiInternalEvidenceBadgeCategory.partialCanonSupport.wire] =
          (badgeCounts[ThaiInternalEvidenceBadgeCategory.partialCanonSupport.wire] ??
              0) +
          1;
      final actual = ThaiInternalEvidenceBadgeAssigner.forTraceSignal(
        candidate,
        trace: trace,
      );
      if (actual != ThaiInternalEvidenceBadgeCategory.partialCanonSupport) {
        mismatches.add(
          ThaiInternalEvidenceBadgeAuditRecord(
            fixtureId: fixtureId,
            signalId: candidate,
            expected: ThaiInternalEvidenceBadgeCategory.partialCanonSupport,
            actual: actual,
          ),
        );
      }
    }

    if (trace.skippedRemedyEvidenceCount > 0) {
      badgeCounts[ThaiInternalEvidenceBadgeCategory.remedyHidden.wire] =
          (badgeCounts[ThaiInternalEvidenceBadgeCategory.remedyHidden.wire] ??
              0) +
          1;
    }

    for (final row in flattenEvidenceRows(bundle)) {
      if (row.userFacingAllowed) {
        provenanceGaps.add(
          ThaiInternalEvidenceProvenanceGap(
            fixtureId: fixtureId,
            signalId: row.signalId,
            unitId: row.unitId,
            missingFields: ['userFacingAllowed'],
          ),
        );
      }
    }

    return ThaiInternalEvidenceFixtureQaResult(
      fixtureId: fixtureId,
      bundle: bundle,
      badgeMismatches: mismatches,
      weakPromotedToStrong: weakPromoted,
      provenanceGaps: provenanceGaps,
      badgeCounts: badgeCounts,
    );
  }

  static ThaiInternalEvidenceBadgeCategory _expectedBadge({
    required ThaiCanonEvidenceAttachment attachment,
    required ThaiCanonEvidenceAlignmentClassification classification,
  }) {
    if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
      return ThaiInternalEvidenceBadgeCategory.remedyHidden;
    }
    if (attachment.signalId.contains(':periodStatus:canonDerived:')) {
      return ThaiInternalEvidenceBadgeCategory.canonDerivedInternal;
    }
    if (attachment.evidenceType ==
            ThaiCanonEvidenceType.periodStatusStructural &&
        !attachment.signalId.contains(':periodStatus:canonDerived:')) {
      if (classification ==
          ThaiCanonEvidenceAlignmentClassification.strongMatch) {
        return ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported;
      }
      return ThaiInternalEvidenceBadgeCategory.partialCanonSupport;
    }
    return switch (classification) {
      ThaiCanonEvidenceAlignmentClassification.strongMatch =>
        ThaiInternalEvidenceBadgeCategory.canonSupported,
      ThaiCanonEvidenceAlignmentClassification.relatedButWeak =>
        ThaiInternalEvidenceBadgeCategory.partialCanonSupport,
      ThaiCanonEvidenceAlignmentClassification.unmappedSignal =>
        ThaiInternalEvidenceBadgeCategory.noCanonEvidence,
      ThaiCanonEvidenceAlignmentClassification.outOfCanonScope =>
        ThaiInternalEvidenceBadgeCategory.outOfCanonScope,
      ThaiCanonEvidenceAlignmentClassification.internalOnly =>
        ThaiInternalEvidenceBadgeCategory.internalOnly,
      ThaiCanonEvidenceAlignmentClassification.skippedRemedy =>
        ThaiInternalEvidenceBadgeCategory.remedyHidden,
      ThaiCanonEvidenceAlignmentClassification.skippedTaksa =>
        ThaiInternalEvidenceBadgeCategory.internalOnly,
      ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus =>
        ThaiInternalEvidenceBadgeCategory.internalOnly,
    };
  }

  static bool _isWeakClassification(
    ThaiCanonEvidenceAlignmentClassification classification,
  ) {
    return classification ==
            ThaiCanonEvidenceAlignmentClassification.relatedButWeak ||
        classification ==
            ThaiCanonEvidenceAlignmentClassification.unmappedSignal ||
        classification ==
            ThaiCanonEvidenceAlignmentClassification.internalOnly ||
        classification ==
            ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus;
  }

  static List<ThaiInternalEvidenceProvenanceGap> _provenanceGaps(
    String fixtureId,
    String signalId,
    ThaiCanonEvidenceRef ref,
  ) {
    final missing = <String>[];
    if (ref.unitId.isEmpty) missing.add('unitId');
    if (ref.subject.isEmpty) missing.add('subject');
    if (ref.relation.isEmpty) missing.add('relation');
    if (ref.object.isEmpty) missing.add('object');
    if (ref.sourcePage == null || ref.sourcePage!.isEmpty) {
      missing.add('sourcePage');
    }
    if (missing.isEmpty) return const [];
    return [
      ThaiInternalEvidenceProvenanceGap(
        fixtureId: fixtureId,
        signalId: signalId,
        unitId: ref.unitId,
        missingFields: missing,
      ),
    ];
  }
}
