/// Thai Astrology — **Knowledge Research** layer (V3, evidence-linked in V4).
///
/// A [KnowledgeResearchRecord] captures one researcher interpretation and the
/// relationships it supports. As of **V4** it no longer owns bibliographic
/// fields (book/author/edition/…/quote/school): those live on `EvidenceRecord`
/// and a research record references them by id via [evidenceIds]. One evidence
/// record may back many research records, and one research record may reference
/// many evidence records.
///
/// Boundary (enforced by design): this layer has **no dependency on the engine
/// or the PlanetRelationshipMatrix**. Planets and relations are recorded as
/// plain strings so the research corpus can be collected, grouped and audited
/// completely independently of any engine value.
library;

/// Lifecycle status of a research record.
enum ResearchStatus {
  /// Just entered; not yet checked.
  draft,

  /// Proposed as evidence, awaiting review.
  candidate,

  /// A reviewer has read it.
  reviewed,

  /// Confirmed against the cited source.
  verified,

  /// Sources / reviewers disagree.
  disputed,

  /// Checked and does not hold.
  rejected,
}

/// Confidence the researcher places in the record.
enum ResearchConfidence { none, low, medium, high }

/// A single planet relationship a record supports. Plain strings — no engine
/// enums — so the research layer never depends on the matrix.
class ResearchRelationship {
  const ResearchRelationship({
    required this.from,
    required this.to,
    required this.relation,
  });

  final String from;
  final String to;

  /// `friend` | `neutral` | `enemy` (recorded as written in the source).
  final String relation;

  /// Directed pair key, e.g. `saturn->venus`.
  String get pairKey => '$from->$to';

  @override
  bool operator ==(Object other) =>
      other is ResearchRelationship &&
      other.from == from &&
      other.to == to &&
      other.relation == relation;

  @override
  int get hashCode => Object.hash(from, to, relation);
}

/// One research interpretation. References its sources by [evidenceIds] and may
/// support multiple relationships.
class KnowledgeResearchRecord {
  const KnowledgeResearchRecord({
    required this.id,
    required this.topic,
    required this.entity,
    required this.interpretation,
    required this.relationship,
    required this.evidenceIds,
    required this.confidence,
    required this.status,
    this.reviewedBy,
    this.notes,
  });

  final String id;
  final String topic;
  final String entity;
  final String interpretation;
  final List<ResearchRelationship> relationship;

  /// Ids of the [EvidenceRecord]s that back this interpretation (V4 linkage).
  final List<String> evidenceIds;
  final ResearchConfidence confidence;
  final String? reviewedBy;
  final ResearchStatus status;
  final String? notes;

  bool get isVerified => status == ResearchStatus.verified;

  /// Pending = not yet a settled outcome (draft/candidate/reviewed).
  bool get isPending =>
      status == ResearchStatus.draft ||
      status == ResearchStatus.candidate ||
      status == ResearchStatus.reviewed;
}
