import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_trace.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_canon_ontology_runtime_mapping.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_internal_evidence_badge.dart';
/// Aggregated coverage metrics for the internal evidence review panel.
class ThaiCanonEvidenceReviewSummary {
  const ThaiCanonEvidenceReviewSummary({
    required this.totalAttachments,
    required this.totalEvidenceRefs,
    required this.byType,
    required this.sectionsWithEvidence,
    required this.sectionsWithoutEvidence,
    required this.lifePeriodAttachmentCount,
    required this.predictionRuleAttachmentCount,
    required this.remedySkippedCount,
    required this.taksaSkippedCount,
    required this.taksaRolesMappedCount,
    required this.taksaCanonUnitsAvailable,
    required this.taksaEvidenceAttachedCount,
    required this.taksaEvidenceTraceOnlyCount,
    required this.taksaSkippedReason,
    required this.taksaRotationAssignmentCount,
    required this.taksaRotationBlocker,
    required this.unmappedCandidateCount,
    required this.signalsWithoutEvidenceCount,
    required this.badgeSummary,
    required this.lifePeriodsWithRuntimeStatus,
    required this.lifePeriodsWithoutRuntimeStatus,
    required this.blockedAmbiguousCount,
    required this.blockedSourceConflictCount,
    required this.mahabhutPositionsMappedCount,
    required this.khumsapMapped,
    required this.khumsapEvidenceAttachedCount,
    required this.khumsapEvidenceCandidateCount,
  });

  factory ThaiCanonEvidenceReviewSummary.fromBundle(
    ThaiMirrorCanonEvidenceBundle bundle,
  ) {
    final attachments = bundle.attachments;
    final byType = <ThaiCanonEvidenceType, int>{};
    for (final type in ThaiCanonEvidenceType.values) {
      byType[type] =
          attachments.where((a) => a.evidenceType == type).length;
    }

    final sectionIdsWithEvidence = attachments
        .map((a) => a.sectionId)
        .whereType<String>()
        .where((id) => !id.startsWith('future') && id != 'lifeTimeline')
        .toSet();

    final mirror = bundle.pipelineResult.mirrorResult!;
    final mirrorSectionIds =
        mirror.sections.map((s) => s.id.name).toSet();
    final without = mirrorSectionIds
        .where((id) => !sectionIdsWithEvidence.contains(id))
        .toList()
      ..sort();

    final withEvidence = sectionIdsWithEvidence
        .where(mirrorSectionIds.contains)
        .toList()
      ..sort();

    final trace = bundle.trace;

    return ThaiCanonEvidenceReviewSummary(
      totalAttachments: attachments.length,
      totalEvidenceRefs: bundle.totalEvidenceRefs,
      byType: byType,
      sectionsWithEvidence: withEvidence,
      sectionsWithoutEvidence: without,
      lifePeriodAttachmentCount:
          byType[ThaiCanonEvidenceType.lifePeriodStructural] ?? 0,
      predictionRuleAttachmentCount:
          byType[ThaiCanonEvidenceType.predictionRule] ?? 0,
      remedySkippedCount: trace.skippedRemedyEvidenceCount,
      taksaSkippedCount: trace.skippedTaksaEvidenceCount,
      taksaRolesMappedCount: trace.taksaRolesMapped.length,
      taksaCanonUnitsAvailable: trace.taksaCanonUnitsAvailable,
      taksaEvidenceAttachedCount: trace.taksaEvidenceAttachedCount,
      taksaEvidenceTraceOnlyCount: trace.taksaEvidenceTraceOnlyCount,
      taksaSkippedReason: trace.taksaSkippedReason ?? trace.taksaRotationBlocker ?? '',
      taksaRotationAssignmentCount: trace.taksaRotationAssignmentCount,
      taksaRotationBlocker: trace.taksaRotationBlocker ?? '',
      unmappedCandidateCount: trace.unmappedCanonEvidenceCandidates.length,
      signalsWithoutEvidenceCount: trace.signalsWithoutCanonEvidence.length,
      badgeSummary: ThaiInternalEvidenceBadgeSummary.fromBundle(bundle),
      lifePeriodsWithRuntimeStatus: trace.lifePeriodsWithRuntimeStatus.length,
      lifePeriodsWithoutRuntimeStatus:
          trace.lifePeriodsWithoutRuntimeStatus.length,
      blockedAmbiguousCount: trace.runtimeStatusBlockedByAmbiguousPosition.length,
      blockedSourceConflictCount: trace.conflictedArchetypePlanetPairs.length,
      mahabhutPositionsMappedCount: ThaiCanonOntologyRuntimeMapping
          .mahabhutPositionMappings()
          .where((m) => m.isMapped)
          .length,
      khumsapMapped: trace.khumsapMapped,
      khumsapEvidenceAttachedCount: trace.khumsapEvidenceAttachedCount,
      khumsapEvidenceCandidateCount: trace.khumsapEvidenceCandidateCount,
    );
  }

  final int totalAttachments;
  final int totalEvidenceRefs;
  final Map<ThaiCanonEvidenceType, int> byType;
  final List<String> sectionsWithEvidence;
  final List<String> sectionsWithoutEvidence;
  final int lifePeriodAttachmentCount;
  final int predictionRuleAttachmentCount;
  final int remedySkippedCount;
  final int taksaSkippedCount;
  final int taksaRolesMappedCount;
  final int taksaCanonUnitsAvailable;
  final int taksaEvidenceAttachedCount;
  final int taksaEvidenceTraceOnlyCount;
  final String taksaSkippedReason;
  final int taksaRotationAssignmentCount;
  final String taksaRotationBlocker;
  final int unmappedCandidateCount;
  final int signalsWithoutEvidenceCount;
  final ThaiInternalEvidenceBadgeSummary badgeSummary;
  final int lifePeriodsWithRuntimeStatus;
  final int lifePeriodsWithoutRuntimeStatus;
  final int blockedAmbiguousCount;
  final int blockedSourceConflictCount;
  final int mahabhutPositionsMappedCount;
  final bool khumsapMapped;
  final int khumsapEvidenceAttachedCount;
  final int khumsapEvidenceCandidateCount;
}

/// One flattened row for the evidence review table.
class ThaiCanonEvidenceReviewRow {
  const ThaiCanonEvidenceReviewRow({
    required this.sectionId,
    required this.signalId,
    required this.evidenceType,
    required this.unitId,
    required this.subject,
    required this.relation,
    required this.object,
    required this.contextLabel,
    required this.sourcePage,
    required this.condition,
    required this.userFacingAllowed,
    required this.badge,
  });

  final String sectionId;
  final String signalId;
  final ThaiCanonEvidenceType evidenceType;
  final String unitId;
  final String subject;
  final String relation;
  final String object;
  final String contextLabel;
  final String sourcePage;
  final String condition;
  final bool userFacingAllowed;
  final ThaiInternalEvidenceBadgeCategory badge;
}

List<ThaiCanonEvidenceReviewRow> flattenEvidenceRows(
  ThaiMirrorCanonEvidenceBundle bundle,
) {
  final rows = <ThaiCanonEvidenceReviewRow>[];
  final trace = bundle.trace;
  for (final attachment in bundle.attachments) {
    final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
      attachment,
      trace: trace,
    );
    for (final ref in attachment.evidenceRefs) {
      final ctx = ref.contextType == null
          ? ''
          : '${ref.contextType}${ref.contextValue == null ? '' : ':${ref.contextValue}'}';
      rows.add(
        ThaiCanonEvidenceReviewRow(
          sectionId: attachment.sectionId ?? '—',
          signalId: attachment.signalId,
          evidenceType: attachment.evidenceType,
          unitId: ref.unitId,
          subject: ref.subject,
          relation: ref.relation,
          object: ref.object,
          contextLabel: ctx,
          sourcePage: ref.sourcePage ?? '',
          condition: ref.condition ?? '',
          userFacingAllowed: attachment.userFacingAllowed,
          badge: badge,
        ),
      );
    }
  }
  rows.sort((a, b) {
    final section = a.sectionId.compareTo(b.sectionId);
    if (section != 0) return section;
    return a.unitId.compareTo(b.unitId);
  });
  return rows;
}
