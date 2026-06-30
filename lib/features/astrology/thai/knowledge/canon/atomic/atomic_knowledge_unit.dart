/// Canon Atomic Knowledge V2 — the atomic knowledge object.
///
/// Replaces the conceptual "Statement" with **one atomic fact**:
///
///   subject (entity) --relation--> object (entity)  [+ condition/effect/strength]
///
/// e.g. `jupiter --owns--> wealth` with `condition = jupiter_in_house_2`,
/// `strength = high`, `confidence = high`, evidence = a book *reference* (page).
///
/// A unit carries exactly one (subject, relation, object). It is NOT narrative:
/// no paragraphs, summaries, rewrites, interpretation or prediction. Provenance
/// is by reference only (D-057) — never store copyrighted text.
///
/// Pure Dart; reuses [KnowledgeConfidence]. No Flutter/engine/runtime imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;

/// A reference to where in a book a fact came from. Reference-only — no quote
/// text is required or expected (see D-057).
class AtomicEvidenceRef {
  const AtomicEvidenceRef({
    required this.bookId,
    this.chapter,
    this.section,
    this.page,
    this.locator,
  });

  final String bookId;
  final String? chapter;
  final String? section;
  final String? page;

  /// Optional short locator (a term or table label), never a paragraph.
  final String? locator;

  bool get hasReference =>
      (page != null && page!.trim().isNotEmpty) ||
      (chapter != null && chapter!.trim().isNotEmpty) ||
      (section != null && section!.trim().isNotEmpty);

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        if (chapter != null) 'chapter': chapter,
        if (section != null) 'section': section,
        if (page != null) 'page': page,
        if (locator != null) 'locator': locator,
      };

  static AtomicEvidenceRef? fromJson(Map<String, dynamic> m) {
    final bookId = (m['bookId'] as String?)?.trim();
    if (bookId == null || bookId.isEmpty) return null;
    return AtomicEvidenceRef(
      bookId: bookId,
      chapter: (m['chapter'] as String?)?.trim(),
      section: (m['section'] as String?)?.trim(),
      page: (m['page'] as String?)?.trim(),
      locator: (m['locator'] as String?)?.trim(),
    );
  }
}

/// The **scope under which an atomic fact is true** (D-068).
///
/// A single, optional qualifier — *not* a set of separate fields. A unit with no
/// context is a general/unconditional Canon fact. A unit with a context asserts
/// the *same* atomic fact, but applicable **only within that scope** (e.g. inside
/// one archetype chart, one lagna, or one life period). It is purely additive:
/// the (subject, relation, object) identity of the unit is unchanged.
///
/// Both [type] and [value] come **from the source page** (e.g. the archetype
/// chart's own name); never inferred and never sourced from external knowledge.
/// [value] is an atomic token, never prose.
class AtomicContext {
  const AtomicContext({required this.type, required this.value});

  final AtomicContextType type;

  /// The specific scope token, e.g. `scholar`, `aries`, `saturn`. Atomic, not
  /// prose; stated by the source (often the chart/section name on the page).
  final String value;

  /// Deterministic key, e.g. `archetype_chart:scholar`.
  String get key => '${type.wire}:${value.trim()}';

  Map<String, dynamic> toJson() => {'type': type.wire, 'value': value};

  /// Returns null when no usable scope value is present (so an empty/blank
  /// context is treated as "no context", never a malformed one).
  static AtomicContext? fromJson(Map<String, dynamic> m) {
    final value = (m['value'] as String?)?.trim();
    if (value == null || value.isEmpty) return null;
    return AtomicContext(
      type: AtomicContextType.fromWire(m['type'] as String?),
      value: value,
    );
  }
}

/// One atomic fact of canonical knowledge.
class AtomicKnowledgeUnit {
  AtomicKnowledgeUnit({
    required this.id,
    required this.subject,
    required this.relation,
    required this.object,
    required this.evidence,
    this.subjectKind = AtomicEntityKind.other,
    this.objectKind = AtomicEntityKind.other,
    this.domain = KnowledgeDomain.other,
    this.condition,
    this.effect,
    this.strength = AtomicStrength.none,
    this.confidence = KnowledgeConfidence.none,
    this.context,
    this.notes,
  });

  final String id;

  /// The entity the fact is about, e.g. `jupiter`. An atomic token, not prose.
  final String subject;
  final AtomicEntityKind subjectKind;

  final AtomicRelation relation;

  /// The target entity/value, e.g. `wealth`. An atomic token, not prose.
  final String object;
  final AtomicEntityKind objectKind;

  final KnowledgeDomain domain;

  /// At most one structured condition token, e.g. `jupiter_in_house_2`.
  final String? condition;

  /// At most one structured effect token, e.g. `financial_growth`.
  final String? effect;

  final AtomicStrength strength;
  final KnowledgeConfidence confidence;

  /// Optional applicability scope (D-068). `null` ⇒ a general/unconditional fact.
  final AtomicContext? context;

  final String? notes;

  final AtomicEvidenceRef evidence;

  /// A deterministic, structured rendering of the fact (a label, NOT narrative).
  String get label {
    final base = '$subject ${relation.wire} $object';
    final withCond = condition == null ? base : '$base [if $condition]';
    return context == null ? withCond : '$withCond @${context!.key}';
  }

  /// A unit is "verified" for completeness purposes when it has a source
  /// reference and a non-zero confidence.
  bool get isVerified =>
      evidence.hasReference && confidence != KnowledgeConfidence.none;

  /// The unordered entity pair this fact connects, e.g. for relationship counts.
  String get entityPairKey {
    final a = '${subjectKind.name}:$subject';
    final b = '${objectKind.name}:$object';
    return (a.compareTo(b) <= 0) ? '$a|$b' : '$b|$a';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'subjectKind': subjectKind.name,
        'relation': relation.wire,
        'object': object,
        'objectKind': objectKind.name,
        'domain': domain.name,
        if (condition != null) 'condition': condition,
        if (effect != null) 'effect': effect,
        'strength': strength.name,
        'confidence': confidence.name,
        if (context != null) 'context': context!.toJson(),
        if (notes != null) 'notes': notes,
        'evidence': evidence.toJson(),
      };

  static AtomicKnowledgeUnit? fromJson(Map<String, dynamic> m) {
    final id = (m['id'] as String?)?.trim();
    final subject = (m['subject'] as String?)?.trim();
    final object = (m['object'] as String?)?.trim();
    final relation = AtomicRelation.fromWire(m['relation'] as String?);
    final evidence = m['evidence'] is Map<String, dynamic>
        ? AtomicEvidenceRef.fromJson(m['evidence'] as Map<String, dynamic>)
        : null;
    if (id == null ||
        id.isEmpty ||
        subject == null ||
        subject.isEmpty ||
        object == null ||
        object.isEmpty ||
        relation == null ||
        evidence == null) {
      return null;
    }
    return AtomicKnowledgeUnit(
      id: id,
      subject: subject,
      subjectKind: AtomicEntityKind.fromName(m['subjectKind'] as String?),
      relation: relation,
      object: object,
      objectKind: AtomicEntityKind.fromName(m['objectKind'] as String?),
      domain: KnowledgeDomain.fromName(m['domain'] as String?),
      condition: (m['condition'] as String?)?.trim(),
      effect: (m['effect'] as String?)?.trim(),
      strength: AtomicStrength.fromName(m['strength'] as String?),
      confidence: canonEnumByName(
              KnowledgeConfidence.values, m['confidence'] as String?) ??
          KnowledgeConfidence.none,
      context: m['context'] is Map<String, dynamic>
          ? AtomicContext.fromJson(m['context'] as Map<String, dynamic>)
          : null,
      notes: (m['notes'] as String?)?.trim(),
      evidence: evidence,
    );
  }
}
