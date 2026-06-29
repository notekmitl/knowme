/// Mahabhut Ingestion Toolchain V1 — Candidate Layer.
///
/// Everything extracted from book text lands here as a **Candidate** first. A
/// candidate is never canon: it holds the verbatim paragraph plus human-assigned
/// annotations, and only enters the Canon Database after Validation → Review →
/// Approval.
///
/// Pure Dart (no Flutter imports). Reuses Canon Database enums/entities.
library;

import 'dart:convert';

import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';

/// Candidate lifecycle, matching the required Approval Workflow:
/// `candidate → validated → reviewed → canonApproved`.
enum CanonCandidateStatus { candidate, validated, reviewed, canonApproved }

extension CanonCandidateStatusX on CanonCandidateStatus {
  int get rank => index;
  bool get isApproved => this == CanonCandidateStatus.canonApproved;
}

/// A directed cross-reference proposed on a candidate.
class CanonCandidateCrossRef {
  const CanonCandidateCrossRef({required this.toId, required this.type, this.note});

  final String toId;
  final CanonCrossReferenceType type;
  final String? note;

  Map<String, dynamic> toJson() =>
      {'toId': toId, 'type': type.name, if (note != null) 'note': note};

  static CanonCandidateCrossRef? fromJson(Map<String, dynamic> m) {
    final toId = (m['toId'] as String?)?.trim();
    final type = canonEnumByName(CanonCrossReferenceType.values, m['type'] as String?);
    if (toId == null || toId.isEmpty || type == null) return null;
    return CanonCandidateCrossRef(
      toId: toId,
      type: type,
      note: (m['note'] as String?)?.trim(),
    );
  }
}

/// One candidate knowledge unit. [statement] is the verbatim book paragraph
/// (set by extraction). The semantic fields ([type], [topic], [subject],
/// [value]) are **left empty by extraction** and filled by a human reviewer —
/// the toolchain never guesses them.
class CanonCandidateUnit {
  CanonCandidateUnit({
    required this.id,
    required this.bookId,
    required this.statement,
    this.sourceId,
    this.status = CanonCandidateStatus.candidate,
    this.type,
    this.topic = '',
    this.subject = '',
    this.title,
    this.value,
    this.page,
    this.chapterId,
    this.sectionId,
    this.topicId,
    this.evidenceQuote,
    this.confidence = KnowledgeConfidence.none,
    List<String>? conditions,
    List<String>? exceptions,
    List<String>? examples,
    List<CanonCandidateCrossRef>? crossRefs,
    List<String>? extractionNotes,
  })  : conditions = conditions ?? [],
        exceptions = exceptions ?? [],
        examples = examples ?? [],
        crossRefs = crossRefs ?? [],
        extractionNotes = extractionNotes ?? [];

  final String id;
  final String bookId;

  /// Working material read from the book. Under the Atomic Knowledge model (V2)
  /// the canonical object is the `AtomicKnowledgeUnit` (one atomic fact), not this
  /// free-text statement; reviewers decompose this into atomic units.
  final String statement;
  final String? sourceId;

  CanonCandidateStatus status;
  CanonUnitType? type;
  String topic;
  String subject;
  String? title;
  String? value;
  String? page;
  String? chapterId;
  String? sectionId;
  String? topicId;

  /// Optional short locator phrase (e.g. a term or table label) — **not** the
  /// copyrighted paragraph. Provenance is carried by the page + chapter/section
  /// reference, never by storing book narrative.
  String? evidenceQuote;
  KnowledgeConfidence confidence;
  final List<String> conditions;
  final List<String> exceptions;
  final List<String> examples;
  final List<CanonCandidateCrossRef> crossRefs;

  /// Recorded problems in the source (duplicate text, archaic spelling, hard
  /// tables, ambiguity) — never edits to the source itself.
  final List<String> extractionNotes;

  /// A book *reference* (page, or chapter/section locator) backs this unit.
  /// Provenance is by reference; the platform never requires storing copyrighted
  /// paragraph text to cite the source.
  bool get hasCitation =>
      hasPage ||
      (chapterId != null && chapterId!.trim().isNotEmpty) ||
      (sectionId != null && sectionId!.trim().isNotEmpty);
  bool get hasPage => page != null && page!.trim().isNotEmpty;
  String get subjectKey => '$topic::$subject';

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'statement': statement,
        if (sourceId != null) 'sourceId': sourceId,
        'status': status.name,
        if (type != null) 'type': type!.name,
        'topic': topic,
        'subject': subject,
        if (title != null) 'title': title,
        if (value != null) 'value': value,
        if (page != null) 'page': page,
        if (chapterId != null) 'chapterId': chapterId,
        if (sectionId != null) 'sectionId': sectionId,
        if (topicId != null) 'topicId': topicId,
        if (evidenceQuote != null) 'evidenceQuote': evidenceQuote,
        'confidence': confidence.name,
        'conditions': conditions,
        'exceptions': exceptions,
        'examples': examples,
        'crossRefs': crossRefs.map((x) => x.toJson()).toList(),
        'extractionNotes': extractionNotes,
      };

  static CanonCandidateUnit? fromJson(Map<String, dynamic> m) {
    final id = (m['id'] as String?)?.trim();
    final bookId = (m['bookId'] as String?)?.trim();
    final statement = (m['statement'] as String?) ?? '';
    if (id == null || id.isEmpty || bookId == null || bookId.isEmpty) {
      return null;
    }
    return CanonCandidateUnit(
      id: id,
      bookId: bookId,
      statement: statement,
      sourceId: (m['sourceId'] as String?)?.trim(),
      status: canonEnumByName(CanonCandidateStatus.values, m['status'] as String?) ??
          CanonCandidateStatus.candidate,
      type: canonEnumByName(CanonUnitType.values, m['type'] as String?),
      topic: (m['topic'] as String?)?.trim() ?? '',
      subject: (m['subject'] as String?)?.trim() ?? '',
      title: (m['title'] as String?)?.trim(),
      value: (m['value'] as String?)?.trim(),
      page: (m['page'] as String?)?.trim(),
      chapterId: (m['chapterId'] as String?)?.trim(),
      sectionId: (m['sectionId'] as String?)?.trim(),
      topicId: (m['topicId'] as String?)?.trim(),
      evidenceQuote: (m['evidenceQuote'] as String?),
      confidence:
          canonEnumByName(KnowledgeConfidence.values, m['confidence'] as String?) ??
              KnowledgeConfidence.none,
      conditions: canonStringList(m['conditions']),
      exceptions: canonStringList(m['exceptions']),
      examples: canonStringList(m['examples']),
      crossRefs: (m['crossRefs'] is List)
          ? (m['crossRefs'] as List)
              .whereType<Map<String, dynamic>>()
              .map(CanonCandidateCrossRef.fromJson)
              .whereType<CanonCandidateCrossRef>()
              .toList()
          : <CanonCandidateCrossRef>[],
      extractionNotes: canonStringList(m['extractionNotes']),
    );
  }
}

/// An in-memory, serialisable store of candidates for one ingestion batch
/// (typically one book or one chapter). This is the **Candidate Layer** — kept
/// separate from the Canon Database; nothing here is canon until promoted.
class CanonCandidateStore {
  CanonCandidateStore({
    required this.bookId,
    this.version = 1,
    Iterable<CanonCandidateUnit> candidates = const [],
  }) : _candidates = {for (final c in candidates) c.id: c};

  final String bookId;
  final int version;
  final Map<String, CanonCandidateUnit> _candidates;

  List<CanonCandidateUnit> get candidates =>
      _candidates.values.toList(growable: false);
  CanonCandidateUnit? byId(String id) => _candidates[id];
  bool contains(String id) => _candidates.containsKey(id);
  int get length => _candidates.length;

  void add(CanonCandidateUnit unit) => _candidates[unit.id] = unit;

  List<CanonCandidateUnit> withStatus(CanonCandidateStatus s) =>
      _candidates.values.where((c) => c.status == s).toList();

  String toJsonString() => const JsonEncoder.withIndent('  ').convert({
        'bookId': bookId,
        'version': version,
        'candidates': candidates.map((c) => c.toJson()).toList(),
      });

  static CanonCandidateStore fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Candidate store root must be an object.');
    }
    final bookId = (decoded['bookId'] as String?)?.trim() ?? '';
    final version = decoded['version'] is int ? decoded['version'] as int : 1;
    final list = decoded['candidates'];
    final candidates = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(CanonCandidateUnit.fromJson)
            .whereType<CanonCandidateUnit>()
            .toList()
        : <CanonCandidateUnit>[];
    return CanonCandidateStore(
      bookId: bookId,
      version: version,
      candidates: candidates,
    );
  }
}

