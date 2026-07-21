import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// The kind of knowledge a node carries (from the audit vocabulary:
/// rule / concept / formula / meaning / interpretation / exception).
enum KnowledgeNodeCategory {
  rule,
  concept,
  formula,
  meaning,
  interpretation,
  exception,
}

/// Lifecycle status of a knowledge node (shared vocabulary with the rest of the
/// knowledge layer).
enum KnowledgeNodeStatus { draft, reviewed, verified, disputed, deprecated }

/// Confidence placed in the node.
enum KnowledgeConfidence { none, low, medium, high }

/// A citable fragment backing a node — quote-first (never summarize a source
/// away without keeping its words).
class KnowledgeNodeEvidence {
  const KnowledgeNodeEvidence({this.page, this.quote, this.note});

  final String? page;
  final String? quote;
  final String? note;

  bool get hasQuote => quote != null && quote!.trim().isNotEmpty;
}

/// One node of canonical knowledge.
///
/// Every node supports the eight required facets: **Source** ([sourceId]),
/// **Tier** ([tier], resolved from the source registry), **Canonical**
/// ([canonical]), **Confidence**, **Evidence**, **References**, **Conditions**
/// and **Exceptions**.
///
/// [tier]/[canonical] are *resolved by the engine from the source registry* so a
/// node cannot self-promote its authority. The optional [value] is the
/// normalized assertion for rule-type nodes (e.g. `friend` for a planet
/// relationship), used by conflict resolution; interpretive nodes leave it null.
class CanonicalKnowledgeNode {
  const CanonicalKnowledgeNode({
    required this.id,
    required this.topic,
    required this.subject,
    required this.category,
    required this.statement,
    required this.sourceId,
    required this.tier,
    required this.canonical,
    required this.confidence,
    required this.status,
    this.value,
    this.evidence = const [],
    this.references = const [],
    this.conditions = const [],
    this.exceptions = const [],
    this.notes,
  });

  final String id;

  /// Knowledge domain, e.g. `planet_relationship`, `day_meaning`, `lagna`,
  /// `bhava`, `planet_meaning`, `life_period`.
  final String topic;

  /// The entity the node is about, e.g. `venus->saturn`, `sun`, `monday`.
  final String subject;
  final KnowledgeNodeCategory category;

  /// The knowledge text (meaning / interpretation / rule statement).
  final String statement;

  /// Normalized assertion for rule-type nodes (e.g. `friend`/`neutral`/`enemy`),
  /// or null for interpretive nodes. Conflict resolution compares [value]s.
  final String? value;

  final String sourceId;

  /// Resolved from the source registry by the engine.
  final KnowledgeTier tier;
  final bool canonical;

  final KnowledgeConfidence confidence;
  final KnowledgeNodeStatus status;
  final List<KnowledgeNodeEvidence> evidence;

  /// Ids of related nodes or external references.
  final List<String> references;

  /// When this knowledge applies (e.g. "only when birth time is known").
  final List<String> conditions;

  /// When this knowledge does NOT apply (ยกเว้น).
  final List<String> exceptions;

  final String? notes;

  bool get isCanonical => canonical && tier.isCanon;
  bool get hasEvidence => evidence.any((e) => e.hasQuote || e.page != null);

  /// Subject identity used for grouping during conflict resolution.
  String get subjectKey => '$topic::$subject';

  CanonicalKnowledgeNode withResolvedTier({
    required KnowledgeTier tier,
    required bool canonical,
  }) =>
      CanonicalKnowledgeNode(
        id: id,
        topic: topic,
        subject: subject,
        category: category,
        statement: statement,
        value: value,
        sourceId: sourceId,
        tier: tier,
        canonical: canonical,
        confidence: confidence,
        status: status,
        evidence: evidence,
        references: references,
        conditions: conditions,
        exceptions: exceptions,
        notes: notes,
      );
}
