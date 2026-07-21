/// Mahabhut Canon Database — entity model (Canon Extraction V1).
///
/// A normalized, multi-book schema for turning canonical astrology books (the
/// first being `หลักมหาภูต`, ส. หยกฟ้า) into structured, fully-traceable
/// knowledge. **Structure only — no book content is extracted yet.**
///
/// Structural hierarchy: Book → Chapter → Section → Topic → KnowledgeUnit.
/// Supporting entities: Evidence, CrossReference, SourceReference, Location.
///
/// Boundary: pure knowledge layer. Reuses the Canon V1 tier/confidence
/// vocabulary; imports no calculation engine and no `PlanetRelationshipMatrix`.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

// =============================================================================
// Enums
// =============================================================================

/// The kind of a [CanonKnowledgeUnit]. A superset of [KnowledgeNodeCategory]
/// that adds the structural/illustrative kinds the book carries.
enum CanonUnitType {
  topic,
  concept,
  rule,
  formula,
  interpretation,
  meaning,
  example,
  exception,
  condition,
}

extension CanonUnitTypeX on CanonUnitType {
  /// Maps to the Canon V1 resolver category when the unit is an assertion that
  /// can participate in conflict resolution; otherwise null (structural /
  /// illustrative units do not assert a resolvable value).
  KnowledgeNodeCategory? get resolverCategory => switch (this) {
        CanonUnitType.rule => KnowledgeNodeCategory.rule,
        CanonUnitType.concept => KnowledgeNodeCategory.concept,
        CanonUnitType.formula => KnowledgeNodeCategory.formula,
        CanonUnitType.interpretation => KnowledgeNodeCategory.interpretation,
        CanonUnitType.meaning => KnowledgeNodeCategory.meaning,
        CanonUnitType.exception => KnowledgeNodeCategory.exception,
        CanonUnitType.topic ||
        CanonUnitType.example ||
        CanonUnitType.condition =>
          null,
      };
}

/// The extraction/validation lifecycle of any extractable entity.
///
/// `draft → extracted → reviewed → validated → canonApproved`. Only
/// [canonApproved] units are eligible to act as Tier-1 Canon for the reasoning
/// engine.
enum CanonValidationStatus {
  draft,
  extracted,
  reviewed,
  validated,
  canonApproved,
}

extension CanonValidationStatusX on CanonValidationStatus {
  /// Monotonic rank used for "at least this status" queries.
  int get rank => index;
  bool get isCanonApproved => this == CanonValidationStatus.canonApproved;
  bool atLeast(CanonValidationStatus other) => rank >= other.rank;
}

/// Directed relationship between two canon entities.
enum CanonCrossReferenceType {
  ruleToRule,
  conceptToConcept,
  chapterToChapter,
  conceptToFormula,
  formulaToInterpretation,
  seeAlso,
  refines,
  dependsOn,
  exampleOf,
  contradicts,
}

// =============================================================================
// Traceability
// =============================================================================

/// Where a knowledge unit lives — the spine of the Traceability System. Every
/// unit can be traced back to book → chapter → section → topic → page →
/// position, plus its source references.
class CanonLocation {
  const CanonLocation({
    required this.bookId,
    this.chapterId,
    this.sectionId,
    this.topicId,
    this.page,
    this.position,
  });

  final String bookId;
  final String? chapterId;
  final String? sectionId;
  final String? topicId;

  /// Printed page reference (string to allow "128", "128–129", "ก-3").
  final String? page;

  /// Free-form position hint within the page/section (e.g. paragraph, line).
  final String? position;

  static CanonLocation fromMap(Map<String, dynamic> m, {String? fallbackBookId}) {
    return CanonLocation(
      bookId: (m['bookId'] as String?)?.trim() ?? fallbackBookId ?? '',
      chapterId: _s(m['chapterId']),
      sectionId: _s(m['sectionId']),
      topicId: _s(m['topicId']),
      page: _s(m['page']),
      position: _s(m['position']),
    );
  }
}

// =============================================================================
// Structural entities
// =============================================================================

/// A canonical book registered in the database. [sourceId] links to the Canon
/// V1 source registry (`canon_sources.json`), from which tier/canonical
/// authority is derived.
class CanonBook {
  const CanonBook({
    required this.id,
    required this.sourceId,
    required this.title,
    this.author,
    this.edition,
    this.publisher,
    this.year,
    this.language,
    this.isbn,
    this.notes,
  });

  final String id;
  final String sourceId;
  final String title;
  final String? author;
  final String? edition;
  final String? publisher;
  final int? year;
  final String? language;
  final String? isbn;
  final String? notes;

  static CanonBook? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final sourceId = _s(m['sourceId']);
    final title = _s(m['title']);
    if (id == null || sourceId == null || title == null) return null;
    return CanonBook(
      id: id,
      sourceId: sourceId,
      title: title,
      author: _s(m['author']),
      edition: _s(m['edition']),
      publisher: _s(m['publisher']),
      year: m['year'] is int ? m['year'] as int : null,
      language: _s(m['language']),
      isbn: _s(m['isbn']),
      notes: _s(m['notes']),
    );
  }
}

class CanonChapter {
  const CanonChapter({
    required this.id,
    required this.bookId,
    required this.title,
    this.number,
    this.notes,
  });

  final String id;
  final String bookId;
  final String title;
  final int? number;
  final String? notes;

  static CanonChapter? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final bookId = _s(m['bookId']);
    final title = _s(m['title']);
    if (id == null || bookId == null || title == null) return null;
    return CanonChapter(
      id: id,
      bookId: bookId,
      title: title,
      number: m['number'] is int ? m['number'] as int : null,
      notes: _s(m['notes']),
    );
  }
}

class CanonSection {
  const CanonSection({
    required this.id,
    required this.chapterId,
    required this.bookId,
    required this.title,
    this.topic,
    this.pageStart,
    this.pageEnd,
    this.notes,
  });

  final String id;
  final String chapterId;
  final String bookId;
  final String title;

  /// Hint of the knowledge domain this section feeds (e.g. `planet_relationship`).
  final String? topic;
  final String? pageStart;
  final String? pageEnd;
  final String? notes;

  static CanonSection? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final chapterId = _s(m['chapterId']);
    final bookId = _s(m['bookId']);
    final title = _s(m['title']);
    if (id == null || chapterId == null || bookId == null || title == null) {
      return null;
    }
    return CanonSection(
      id: id,
      chapterId: chapterId,
      bookId: bookId,
      title: title,
      topic: _s(m['topic']),
      pageStart: _s(m['pageStart']),
      pageEnd: _s(m['pageEnd']),
      notes: _s(m['notes']),
    );
  }
}

/// A heading-level grouping inside a section (the book's own ภพ/หัวข้อ).
class CanonTopicEntity {
  const CanonTopicEntity({
    required this.id,
    required this.sectionId,
    required this.bookId,
    required this.title,
    this.order,
    this.notes,
  });

  final String id;
  final String sectionId;
  final String bookId;
  final String title;
  final int? order;
  final String? notes;

  static CanonTopicEntity? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final sectionId = _s(m['sectionId']);
    final bookId = _s(m['bookId']);
    final title = _s(m['title']);
    if (id == null || sectionId == null || bookId == null || title == null) {
      return null;
    }
    return CanonTopicEntity(
      id: id,
      sectionId: sectionId,
      bookId: bookId,
      title: title,
      order: m['order'] is int ? m['order'] as int : null,
      notes: _s(m['notes']),
    );
  }
}

// =============================================================================
// Supporting entities
// =============================================================================

/// A first-class, citable evidence fragment — quote-first. Linked to a unit and
/// optionally to a [CanonSourceReference].
class CanonEvidence {
  const CanonEvidence({
    required this.id,
    this.unitId,
    this.sourceReferenceId,
    this.page,
    this.quote,
    this.note,
  });

  final String id;
  final String? unitId;
  final String? sourceReferenceId;
  final String? page;
  final String? quote;
  final String? note;

  bool get hasQuote => quote != null && quote!.trim().isNotEmpty;

  KnowledgeNodeEvidence toNodeEvidence() =>
      KnowledgeNodeEvidence(page: page, quote: quote, note: note);

  static CanonEvidence? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    if (id == null) return null;
    return CanonEvidence(
      id: id,
      unitId: _s(m['unitId']),
      sourceReferenceId: _s(m['sourceReferenceId']),
      page: _s(m['page']),
      quote: _s(m['quote']),
      note: _s(m['note']),
    );
  }
}

/// A directed link between two entities (Rule↔Rule, Concept↔Formula, …).
class CanonCrossReference {
  const CanonCrossReference({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.type,
    this.note,
  });

  final String id;
  final String fromId;
  final String toId;
  final CanonCrossReferenceType type;
  final String? note;

  static CanonCrossReference? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final fromId = _s(m['fromId']);
    final toId = _s(m['toId']);
    if (id == null || fromId == null || toId == null) return null;
    final type = canonEnumByName(CanonCrossReferenceType.values, _s(m['type']));
    if (type == null) return null;
    return CanonCrossReference(
      id: id,
      fromId: fromId,
      toId: toId,
      type: type,
      note: _s(m['note']),
    );
  }
}

/// A specific citation into a registered Canon V1 source. [sourceId] points at
/// `canon_sources.json`; [citation] carries the human-readable reference.
class CanonSourceReference {
  const CanonSourceReference({
    required this.id,
    required this.sourceId,
    this.citation,
    this.page,
    this.note,
  });

  final String id;
  final String sourceId;
  final String? citation;
  final String? page;
  final String? note;

  static CanonSourceReference? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final sourceId = _s(m['sourceId']);
    if (id == null || sourceId == null) return null;
    return CanonSourceReference(
      id: id,
      sourceId: sourceId,
      citation: _s(m['citation']),
      page: _s(m['page']),
      note: _s(m['note']),
    );
  }
}

// =============================================================================
// Knowledge unit
// =============================================================================

/// The atomic unit of canonical knowledge: a Concept / Rule / Formula /
/// Interpretation / Meaning / Example / Exception / Condition extracted from a
/// book, with full traceability and provenance.
class CanonKnowledgeUnit {
  const CanonKnowledgeUnit({
    required this.id,
    required this.type,
    required this.topic,
    required this.subject,
    required this.statement,
    required this.location,
    this.title,
    this.value,
    this.confidence = KnowledgeConfidence.none,
    this.validationStatus = CanonValidationStatus.draft,
    this.evidenceIds = const [],
    this.crossReferenceIds = const [],
    this.sourceReferenceIds = const [],
    this.conditions = const [],
    this.exceptions = const [],
    this.notes,
  });

  final String id;
  final CanonUnitType type;

  /// Knowledge domain, e.g. `planet_relationship`, `lagna`, `bhava`.
  final String topic;

  /// The entity the unit is about, e.g. `venus->saturn`, `sun`.
  final String subject;
  final String statement;
  final CanonLocation location;
  final String? title;

  /// Normalized assertion for rule-type units (e.g. `friend`), used by the
  /// Canon V1 conflict resolver. Null for non-assertive units.
  final String? value;

  final KnowledgeConfidence confidence;
  final CanonValidationStatus validationStatus;
  final List<String> evidenceIds;
  final List<String> crossReferenceIds;
  final List<String> sourceReferenceIds;
  final List<String> conditions;
  final List<String> exceptions;
  final String? notes;

  String get bookId => location.bookId;
  String get subjectKey => '$topic::$subject';

  static CanonKnowledgeUnit? fromMap(Map<String, dynamic> m) {
    final id = _s(m['id']);
    final topic = _s(m['topic']);
    final subject = _s(m['subject']);
    final statement = _s(m['statement']);
    if (id == null || topic == null || subject == null || statement == null) {
      return null;
    }
    final type = canonEnumByName(CanonUnitType.values, _s(m['type']));
    if (type == null) return null;
    final location = m['location'] is Map<String, dynamic>
        ? CanonLocation.fromMap(m['location'] as Map<String, dynamic>)
        : CanonLocation(bookId: _s(m['bookId']) ?? '');
    return CanonKnowledgeUnit(
      id: id,
      type: type,
      topic: topic,
      subject: subject,
      statement: statement,
      location: location,
      title: _s(m['title']),
      value: _s(m['value']),
      confidence: canonEnumByName(
              KnowledgeConfidence.values, _s(m['confidence'])) ??
          KnowledgeConfidence.none,
      validationStatus:
          canonEnumByName(CanonValidationStatus.values, _s(m['validationStatus'])) ??
              CanonValidationStatus.draft,
      evidenceIds: canonStringList(m['evidenceIds']),
      crossReferenceIds: canonStringList(m['crossReferenceIds']),
      sourceReferenceIds: canonStringList(m['sourceReferenceIds']),
      conditions: canonStringList(m['conditions']),
      exceptions: canonStringList(m['exceptions']),
      notes: _s(m['notes']),
    );
  }
}

// =============================================================================
// helpers
// =============================================================================

String? _s(Object? v) {
  if (v is String) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
  return null;
}

/// Tier label helper re-exported for convenience.
String tierLabel(KnowledgeTier tier) => tier.label;
