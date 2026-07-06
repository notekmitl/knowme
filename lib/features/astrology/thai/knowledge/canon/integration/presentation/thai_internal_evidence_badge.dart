import 'package:knowme/features/astrology/thai/core/life_period/thai_life_period_rise_fall_metadata.dart';

import '../qa/thai_canon_evidence_alignment_classification.dart';
import '../qa/thai_canon_evidence_alignment_classifier.dart';
import '../thai_canon_evidence_attachment.dart';
import '../thai_canon_evidence_trace.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_mirror_canon_evidence_bundle.dart';

/// Internal QA badge — never user-facing.
enum ThaiInternalEvidenceBadgeCategory {
  canonSupported,
  partialCanonSupport,
  canonDerivedInternal,
  runtimeMetadataSupported,
  outOfCanonScope,
  blockedAmbiguous,
  blockedSourceConflict,
  internalOnly,
  remedyHidden,
  noCanonEvidence,
}

extension ThaiInternalEvidenceBadgeCategoryWire
    on ThaiInternalEvidenceBadgeCategory {
  String get wire => switch (this) {
        ThaiInternalEvidenceBadgeCategory.canonSupported => 'CANON_SUPPORTED',
        ThaiInternalEvidenceBadgeCategory.partialCanonSupport =>
          'PARTIAL_CANON_SUPPORT',
        ThaiInternalEvidenceBadgeCategory.canonDerivedInternal =>
          'CANON_DERIVED_INTERNAL',
        ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported =>
          'RUNTIME_METADATA_SUPPORTED',
        ThaiInternalEvidenceBadgeCategory.outOfCanonScope =>
          'OUT_OF_CANON_SCOPE',
        ThaiInternalEvidenceBadgeCategory.blockedAmbiguous =>
          'BLOCKED_AMBIGUOUS',
        ThaiInternalEvidenceBadgeCategory.blockedSourceConflict =>
          'BLOCKED_SOURCE_CONFLICT',
        ThaiInternalEvidenceBadgeCategory.internalOnly => 'INTERNAL_ONLY',
        ThaiInternalEvidenceBadgeCategory.remedyHidden => 'REMEDY_HIDDEN',
        ThaiInternalEvidenceBadgeCategory.noCanonEvidence => 'NO_CANON_EVIDENCE',
      };

  String get label => switch (this) {
        ThaiInternalEvidenceBadgeCategory.canonSupported => 'Canon Supported',
        ThaiInternalEvidenceBadgeCategory.partialCanonSupport => 'Partial Evidence',
        ThaiInternalEvidenceBadgeCategory.canonDerivedInternal =>
          'Canon Derived (Internal)',
        ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported =>
          'Runtime Metadata Supported',
        ThaiInternalEvidenceBadgeCategory.outOfCanonScope => 'Out of Canon Scope',
        ThaiInternalEvidenceBadgeCategory.blockedAmbiguous => 'Blocked Ambiguous',
        ThaiInternalEvidenceBadgeCategory.blockedSourceConflict =>
          'Source Conflict',
        ThaiInternalEvidenceBadgeCategory.internalOnly => 'Internal Only',
        ThaiInternalEvidenceBadgeCategory.remedyHidden => 'Remedy Hidden',
        ThaiInternalEvidenceBadgeCategory.noCanonEvidence => 'No Canon Evidence',
      };
}

/// Aggregate badge counts for internal review summary cards.
class ThaiInternalEvidenceBadgeSummary {
  const ThaiInternalEvidenceBadgeSummary({
    required this.byCategory,
    required this.totalBadgedRows,
  });

  final Map<ThaiInternalEvidenceBadgeCategory, int> byCategory;
  final int totalBadgedRows;

  int count(ThaiInternalEvidenceBadgeCategory category) =>
      byCategory[category] ?? 0;

  factory ThaiInternalEvidenceBadgeSummary.fromBundle(
    ThaiMirrorCanonEvidenceBundle bundle,
  ) {
    final counts = <ThaiInternalEvidenceBadgeCategory, int>{};
    for (final category in ThaiInternalEvidenceBadgeCategory.values) {
      counts[category] = 0;
    }

    for (final attachment in bundle.attachments) {
      final badge = ThaiInternalEvidenceBadgeAssigner.forAttachment(
        attachment,
        trace: bundle.trace,
      );
      counts[badge] = (counts[badge] ?? 0) + 1;
    }

    for (final _ in bundle.trace.outOfCanonScopeSignals) {
      counts[ThaiInternalEvidenceBadgeCategory.outOfCanonScope] =
          (counts[ThaiInternalEvidenceBadgeCategory.outOfCanonScope] ?? 0) + 1;
    }
    for (final _ in bundle.trace.inCanonScopeUnmappedSignals) {
      counts[ThaiInternalEvidenceBadgeCategory.noCanonEvidence] =
          (counts[ThaiInternalEvidenceBadgeCategory.noCanonEvidence] ?? 0) + 1;
    }
    for (final _ in bundle.trace.runtimeStatusBlockedByAmbiguousPosition) {
      counts[ThaiInternalEvidenceBadgeCategory.blockedAmbiguous] =
          (counts[ThaiInternalEvidenceBadgeCategory.blockedAmbiguous] ?? 0) + 1;
    }
    for (final _ in bundle.trace.runtimeStatusBlockedBySourceConflict) {
      counts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict] =
          (counts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict] ??
              0) +
          1;
    }
    for (final _ in bundle.trace.conflictedArchetypePlanetPairs) {
      counts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict] =
          (counts[ThaiInternalEvidenceBadgeCategory.blockedSourceConflict] ??
              0) +
          1;
    }
    if (bundle.trace.skippedRemedyEvidenceCount > 0) {
      counts[ThaiInternalEvidenceBadgeCategory.remedyHidden] =
          (counts[ThaiInternalEvidenceBadgeCategory.remedyHidden] ?? 0) + 1;
    }
    for (final _ in bundle.trace.traceOnlyEvidenceCandidates) {
      counts[ThaiInternalEvidenceBadgeCategory.partialCanonSupport] =
          (counts[ThaiInternalEvidenceBadgeCategory.partialCanonSupport] ?? 0) +
          1;
    }

    final total = counts.values.fold<int>(0, (sum, n) => sum + n);
    return ThaiInternalEvidenceBadgeSummary(
      byCategory: counts,
      totalBadgedRows: total,
    );
  }
}

/// Deterministic internal badge assignment — QA indicators only.
abstract final class ThaiInternalEvidenceBadgeAssigner {
  static ThaiInternalEvidenceBadgeCategory forAttachment(
    ThaiCanonEvidenceAttachment attachment, {
    ThaiCanonEvidenceTrace? trace,
  }) {
    if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
      return ThaiInternalEvidenceBadgeCategory.remedyHidden;
    }

    final (classification, _) =
        ThaiCanonEvidenceAlignmentClassifier.classifyAttachment(attachment);

    if (attachment.signalId.contains(':periodStatus:canonDerived:')) {
      return ThaiInternalEvidenceBadgeCategory.canonDerivedInternal;
    }

    if (attachment.evidenceType == ThaiCanonEvidenceType.periodStatusStructural &&
        !attachment.signalId.contains(':periodStatus:canonDerived:')) {
      if (classification ==
          ThaiCanonEvidenceAlignmentClassification.strongMatch) {
        return ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported;
      }
      return ThaiInternalEvidenceBadgeCategory.partialCanonSupport;
    }

    return _fromAlignmentClassification(classification);
  }

  static ThaiInternalEvidenceBadgeCategory forTraceSignal(
    String signalId, {
    required ThaiCanonEvidenceTrace trace,
  }) {
    if (trace.outOfCanonScopeSignals.contains(signalId)) {
      return ThaiInternalEvidenceBadgeCategory.outOfCanonScope;
    }
    if (trace.inCanonScopeUnmappedSignals.contains(signalId)) {
      return ThaiInternalEvidenceBadgeCategory.noCanonEvidence;
    }
    if (signalId == 'trace:skipped_remedy' ||
        trace.skippedRemedyEvidenceCount > 0 &&
            signalId.startsWith('trace:skipped_remedy')) {
      return ThaiInternalEvidenceBadgeCategory.remedyHidden;
    }
    if (signalId.startsWith('trace:runtimeStatus:') ||
        trace.lifePeriodsWithRuntimeStatus.any(
          (s) => signalId.contains(s) || signalId.endsWith(s),
        )) {
      return ThaiInternalEvidenceBadgeCategory.runtimeMetadataSupported;
    }
    if (signalId.startsWith('trace:canonDerivedStatus:') ||
        signalId.contains(':periodStatus:canonDerived:')) {
      return ThaiInternalEvidenceBadgeCategory.canonDerivedInternal;
    }
    if (_matchesAny(signalId, trace.runtimeStatusBlockedByAmbiguousPosition) ||
        trace.ambiguousArchetypePlanetPairs.isNotEmpty &&
            signalId.contains('AMBIGUOUS')) {
      return ThaiInternalEvidenceBadgeCategory.blockedAmbiguous;
    }
    if (_matchesAny(signalId, trace.runtimeStatusBlockedBySourceConflict) ||
        trace.conflictedArchetypePlanetPairs.isNotEmpty &&
            signalId.contains('SOURCE_CONFLICT')) {
      return ThaiInternalEvidenceBadgeCategory.blockedSourceConflict;
    }
    if (trace.traceOnlyEvidenceCandidates.contains(signalId)) {
      return ThaiInternalEvidenceBadgeCategory.partialCanonSupport;
    }
    if (signalId.startsWith('trace:noStatusInRuntime:')) {
      final periodKey = signalId.substring('trace:noStatusInRuntime:'.length);
      if (trace.runtimeStatusBlockedByAmbiguousPosition
          .any((a) => periodKey.contains(a) || a.contains(periodKey))) {
        return ThaiInternalEvidenceBadgeCategory.blockedAmbiguous;
      }
      if (trace.runtimeStatusBlockedBySourceConflict
          .any((a) => periodKey.contains(a) || a.contains(periodKey))) {
        return ThaiInternalEvidenceBadgeCategory.blockedSourceConflict;
      }
      return ThaiInternalEvidenceBadgeCategory.internalOnly;
    }
    return ThaiInternalEvidenceBadgeCategory.internalOnly;
  }

  static ThaiInternalEvidenceBadgeCategory forRuntimeBlocker(
    String blockerReason,
  ) {
    if (blockerReason.contains(RuntimeStatusBlockerReason.ambiguousPosition) ||
        blockerReason.contains('AMBIGUOUS')) {
      return ThaiInternalEvidenceBadgeCategory.blockedAmbiguous;
    }
    if (blockerReason.contains(RuntimeStatusBlockerReason.sourceConflict) ||
        blockerReason.contains('SOURCE_CONFLICT')) {
      return ThaiInternalEvidenceBadgeCategory.blockedSourceConflict;
    }
    if (blockerReason.contains(RuntimeStatusBlockerReason.missingPosition) ||
        blockerReason.contains('MISSING')) {
      return ThaiInternalEvidenceBadgeCategory.noCanonEvidence;
    }
    return ThaiInternalEvidenceBadgeCategory.internalOnly;
  }

  static ThaiInternalEvidenceBadgeCategory _fromAlignmentClassification(
    ThaiCanonEvidenceAlignmentClassification classification,
  ) {
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

  static bool _matchesAny(String signalId, List<String> anchors) {
    for (final anchor in anchors) {
      if (signalId.contains(anchor) || anchor.contains(signalId)) {
        return true;
      }
    }
    return false;
  }
}
