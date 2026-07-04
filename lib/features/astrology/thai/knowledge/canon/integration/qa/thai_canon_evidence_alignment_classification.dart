/// Alignment quality between a Canon evidence attachment and its report signal.
enum ThaiCanonEvidenceAlignmentClassification {
  strongMatch,
  relatedButWeak,
  unmappedSignal,
  outOfCanonScope,
  internalOnly,
  skippedRemedy,
  skippedTaksa,
  skippedPeriodStatus,
}

extension ThaiCanonEvidenceAlignmentClassificationWire on
    ThaiCanonEvidenceAlignmentClassification {
  String get wire => switch (this) {
        ThaiCanonEvidenceAlignmentClassification.strongMatch => 'STRONG_MATCH',
        ThaiCanonEvidenceAlignmentClassification.relatedButWeak =>
          'RELATED_BUT_WEAK',
        ThaiCanonEvidenceAlignmentClassification.unmappedSignal =>
          'UNMAPPED_SIGNAL',
        ThaiCanonEvidenceAlignmentClassification.outOfCanonScope =>
          'OUT_OF_CANON_SCOPE',
        ThaiCanonEvidenceAlignmentClassification.internalOnly =>
          'INTERNAL_ONLY',
        ThaiCanonEvidenceAlignmentClassification.skippedRemedy =>
          'SKIPPED_REMEDY',
        ThaiCanonEvidenceAlignmentClassification.skippedTaksa =>
          'SKIPPED_TAKSA',
        ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus =>
          'SKIPPED_PERIOD_STATUS',
      };
}

/// Readiness of a Canon evidence domain for internal badge display.
enum ThaiCanonEvidenceIntegrationReadiness {
  readyForInternalBadge,
  needsBetterMapping,
  internalOnly,
  doNotDisplay,
}

extension ThaiCanonEvidenceIntegrationReadinessWire on
    ThaiCanonEvidenceIntegrationReadiness {
  String get wire => switch (this) {
        ThaiCanonEvidenceIntegrationReadiness.readyForInternalBadge =>
          'READY_FOR_INTERNAL_BADGE',
        ThaiCanonEvidenceIntegrationReadiness.needsBetterMapping =>
          'NEEDS_BETTER_MAPPING',
        ThaiCanonEvidenceIntegrationReadiness.internalOnly => 'INTERNAL_ONLY',
        ThaiCanonEvidenceIntegrationReadiness.doNotDisplay => 'DO_NOT_DISPLAY',
      };
}
