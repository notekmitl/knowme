/// Duplicate semantic meaning detected in registry audit.
class MirrorRegistrySemanticDuplicate {
  const MirrorRegistrySemanticDuplicate({
    required this.patternFamily,
    required this.mirrorKeys,
    required this.mirrorDimensions,
  });

  final String patternFamily;
  final List<String> mirrorKeys;
  final List<String> mirrorDimensions;

  Map<String, dynamic> toMap() {
    return {
      'patternFamily': patternFamily,
      'mirrorKeys': mirrorKeys,
      'mirrorDimensions': mirrorDimensions,
    };
  }
}

/// MV2.5 registry coverage audit report.
class MirrorRegistryAuditReport {
  const MirrorRegistryAuditReport({
    required this.totalRegistryKeys,
    required this.usedKeys,
    required this.unusedKeys,
    required this.orphanKeys,
    required this.keyUsageCounts,
    required this.semanticDuplicates,
    required this.passed,
  });

  final int totalRegistryKeys;
  final List<String> usedKeys;
  final List<String> unusedKeys;
  final List<String> orphanKeys;
  final Map<String, int> keyUsageCounts;
  final List<MirrorRegistrySemanticDuplicate> semanticDuplicates;
  final bool passed;

  Map<String, dynamic> toMap() {
    return {
      'totalRegistryKeys': totalRegistryKeys,
      'usedKeys': usedKeys,
      'unusedKeys': unusedKeys,
      'orphanKeys': orphanKeys,
      'keyUsageCounts': keyUsageCounts,
      'semanticDuplicates':
          semanticDuplicates.map((item) => item.toMap()).toList(),
      'passed': passed,
    };
  }
}
