import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';

import 'thai_canon_evidence_safety.dart';

/// Internal evidence traceability record for one frozen Canon atomic unit.
///
/// Reference-only — never carries copyrighted prose. Not for direct UI display.
class ThaiCanonEvidenceRef {
  const ThaiCanonEvidenceRef({
    required this.unitId,
    required this.relation,
    required this.subject,
    required this.object,
    required this.sourceBookId,
    this.sourcePage,
    this.sourceRef,
    this.contextType,
    this.contextValue,
    this.condition,
    this.confidence,
    this.domain,
    required this.safety,
  });

  final String unitId;
  final String relation;
  final String subject;
  final String object;
  final String sourceBookId;
  final String? sourcePage;

  /// Optional locator / section token from provenance (never prose).
  final String? sourceRef;
  final String? contextType;
  final String? contextValue;
  final String? condition;
  final String? confidence;
  final String? domain;
  final ThaiCanonEvidenceSafety safety;

  factory ThaiCanonEvidenceRef.fromUnit(
    AtomicKnowledgeUnit unit, {
    required ThaiCanonEvidenceSafety safety,
  }) {
    return ThaiCanonEvidenceRef(
      unitId: unit.id,
      relation: unit.relation.wire,
      subject: unit.subject,
      object: unit.object,
      sourceBookId: unit.evidence.bookId,
      sourcePage: unit.evidence.page,
      sourceRef: unit.evidence.locator,
      contextType: unit.context?.type.wire,
      contextValue: unit.context?.value,
      condition: unit.condition,
      confidence: unit.confidence.name,
      domain: unit.domain.name,
      safety: safety,
    );
  }

  static ThaiCanonEvidenceSafety safetyForDomain(KnowledgeDomain domain) {
    if (domain == KnowledgeDomain.remedies) {
      return ThaiCanonEvidenceSafety.remedyInternalOnly;
    }
    return ThaiCanonEvidenceSafety.traceabilityInternal;
  }
}
