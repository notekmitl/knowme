import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/database/canon_entities.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

const String kCanonDatabaseAsset = 'knowledge/canon/canon_database.knowme.json';

enum CanonDbIssueSeverity { error, warning, info }

class CanonDbIssue {
  const CanonDbIssue(this.severity, this.code, this.message, {this.ref});

  final CanonDbIssueSeverity severity;
  final String code;
  final String message;
  final String? ref;

  bool get isError => severity == CanonDbIssueSeverity.error;

  @override
  String toString() =>
      '[${severity.name}] $code: $message${ref == null ? '' : ' ($ref)'}';
}

/// The full back-trace of one knowledge unit: book → chapter → section → topic
/// → page, plus its source references. Powers the Traceability System.
class CanonTrace {
  const CanonTrace({
    required this.unit,
    this.book,
    this.chapter,
    this.section,
    this.topic,
    this.sourceReferences = const [],
  });

  final CanonKnowledgeUnit unit;
  final CanonBook? book;
  final CanonChapter? chapter;
  final CanonSection? section;
  final CanonTopicEntity? topic;
  final List<CanonSourceReference> sourceReferences;

  /// Human-readable provenance, e.g.
  /// `หลักมหาภูต › บทที่ 3 › ความสัมพันธ์ดาว › ศุกร์-เสาร์ › น.128`.
  String get citation {
    final parts = <String>[
      if (book != null) book!.title,
      if (chapter != null) chapter!.title,
      if (section != null) section!.title,
      if (topic != null) topic!.title,
      if (unit.location.page != null) 'น.${unit.location.page}',
    ];
    return parts.join(' › ');
  }
}

/// Coverage snapshot of the database.
class CanonDatabaseCoverage {
  const CanonDatabaseCoverage({
    required this.books,
    required this.chapters,
    required this.sections,
    required this.topics,
    required this.units,
    required this.evidence,
    required this.crossReferences,
    required this.sourceReferences,
    required this.unitsByType,
    required this.unitsByStatus,
    required this.unitsByBook,
    required this.canonApprovedUnits,
  });

  final int books;
  final int chapters;
  final int sections;
  final int topics;
  final int units;
  final int evidence;
  final int crossReferences;
  final int sourceReferences;
  final Map<CanonUnitType, int> unitsByType;
  final Map<CanonValidationStatus, int> unitsByStatus;
  final Map<String, int> unitsByBook;
  final int canonApprovedUnits;

  double get approvedShare => units == 0 ? 0 : canonApprovedUnits / units;

  String get summary =>
      '$books book(s), $units unit(s) '
      '($canonApprovedUnits canon-approved, '
      '${(approvedShare * 100).toStringAsFixed(1)}%), '
      '$evidence evidence, $crossReferences cross-ref(s).';
}

class CanonDatabaseLoadResult {
  const CanonDatabaseLoadResult({required this.database, required this.issues});

  final CanonDatabase database;
  final List<CanonDbIssue> issues;

  bool get hasErrors => issues.any((i) => i.isError);
  List<CanonDbIssue> get errors => issues.where((i) => i.isError).toList();
  List<CanonDbIssue> get warnings => issues
      .where((i) => i.severity == CanonDbIssueSeverity.warning)
      .toList();
}

/// In-memory Mahabhut Canon Database. Holds all entities, resolves
/// traceability, validates referential integrity, reports coverage, and bridges
/// to the Canon V1 [CanonicalKnowledgeNode] model so the existing resolver /
/// engine (V1) keep working unchanged.
class CanonDatabase {
  CanonDatabase({
    Iterable<CanonBook> books = const [],
    Iterable<CanonChapter> chapters = const [],
    Iterable<CanonSection> sections = const [],
    Iterable<CanonTopicEntity> topics = const [],
    Iterable<CanonKnowledgeUnit> units = const [],
    Iterable<CanonEvidence> evidence = const [],
    Iterable<CanonCrossReference> crossReferences = const [],
    Iterable<CanonSourceReference> sourceReferences = const [],
  })  : _books = {for (final b in books) b.id: b},
        _chapters = {for (final c in chapters) c.id: c},
        _sections = {for (final s in sections) s.id: s},
        _topics = {for (final t in topics) t.id: t},
        _units = {for (final u in units) u.id: u},
        _evidence = {for (final e in evidence) e.id: e},
        _crossRefs = {for (final x in crossReferences) x.id: x},
        _sourceRefs = {for (final r in sourceReferences) r.id: r};

  final Map<String, CanonBook> _books;
  final Map<String, CanonChapter> _chapters;
  final Map<String, CanonSection> _sections;
  final Map<String, CanonTopicEntity> _topics;
  final Map<String, CanonKnowledgeUnit> _units;
  final Map<String, CanonEvidence> _evidence;
  final Map<String, CanonCrossReference> _crossRefs;
  final Map<String, CanonSourceReference> _sourceRefs;

  List<CanonBook> get books => _books.values.toList(growable: false);
  List<CanonChapter> get chapters => _chapters.values.toList(growable: false);
  List<CanonSection> get sections => _sections.values.toList(growable: false);
  List<CanonTopicEntity> get topics => _topics.values.toList(growable: false);
  List<CanonKnowledgeUnit> get units => _units.values.toList(growable: false);
  List<CanonEvidence> get evidence => _evidence.values.toList(growable: false);
  List<CanonCrossReference> get crossReferences =>
      _crossRefs.values.toList(growable: false);
  List<CanonSourceReference> get sourceReferences =>
      _sourceRefs.values.toList(growable: false);

  CanonBook? book(String id) => _books[id];
  CanonKnowledgeUnit? unit(String id) => _units[id];
  CanonEvidence? evidenceById(String id) => _evidence[id];

  List<CanonKnowledgeUnit> unitsForBook(String bookId) =>
      _units.values.where((u) => u.bookId == bookId).toList();
  List<CanonKnowledgeUnit> unitsForSection(String sectionId) =>
      _units.values.where((u) => u.location.sectionId == sectionId).toList();
  List<CanonKnowledgeUnit> unitsForTopic(String topicId) =>
      _units.values.where((u) => u.location.topicId == topicId).toList();

  List<CanonCrossReference> crossReferencesFrom(String id) =>
      _crossRefs.values.where((x) => x.fromId == id).toList();
  List<CanonCrossReference> crossReferencesInvolving(String id) =>
      _crossRefs.values.where((x) => x.fromId == id || x.toId == id).toList();

  // --- traceability ----------------------------------------------------------

  /// Resolve the full provenance chain for a unit. Returns null if unknown.
  CanonTrace? trace(String unitId) {
    final u = _units[unitId];
    if (u == null) return null;
    final section =
        u.location.sectionId == null ? null : _sections[u.location.sectionId];
    final chapter = u.location.chapterId != null
        ? _chapters[u.location.chapterId]
        : (section == null ? null : _chapters[section.chapterId]);
    return CanonTrace(
      unit: u,
      book: _books[u.bookId],
      chapter: chapter,
      section: section,
      topic: u.location.topicId == null ? null : _topics[u.location.topicId],
      sourceReferences: u.sourceReferenceIds
          .map((id) => _sourceRefs[id])
          .whereType<CanonSourceReference>()
          .toList(),
    );
  }

  // --- coverage --------------------------------------------------------------

  CanonDatabaseCoverage coverage() {
    final byType = <CanonUnitType, int>{};
    final byStatus = <CanonValidationStatus, int>{};
    final byBook = <String, int>{};
    var approved = 0;
    for (final u in _units.values) {
      byType[u.type] = (byType[u.type] ?? 0) + 1;
      byStatus[u.validationStatus] = (byStatus[u.validationStatus] ?? 0) + 1;
      byBook[u.bookId] = (byBook[u.bookId] ?? 0) + 1;
      if (u.validationStatus.isCanonApproved) approved++;
    }
    return CanonDatabaseCoverage(
      books: _books.length,
      chapters: _chapters.length,
      sections: _sections.length,
      topics: _topics.length,
      units: _units.length,
      evidence: _evidence.length,
      crossReferences: _crossRefs.length,
      sourceReferences: _sourceRefs.length,
      unitsByType: byType,
      unitsByStatus: byStatus,
      unitsByBook: byBook,
      canonApprovedUnits: approved,
    );
  }

  // --- validation ------------------------------------------------------------

  /// Referential-integrity + provenance validation. Pure; never throws.
  List<CanonDbIssue> validate() {
    final issues = <CanonDbIssue>[];

    for (final c in _chapters.values) {
      if (!_books.containsKey(c.bookId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_parent',
            'Chapter "${c.id}" → unknown book "${c.bookId}".', ref: c.id));
      }
    }
    for (final s in _sections.values) {
      if (!_chapters.containsKey(s.chapterId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_parent',
            'Section "${s.id}" → unknown chapter "${s.chapterId}".', ref: s.id));
      }
    }
    for (final t in _topics.values) {
      if (!_sections.containsKey(t.sectionId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_parent',
            'Topic "${t.id}" → unknown section "${t.sectionId}".', ref: t.id));
      }
    }

    for (final u in _units.values) {
      if (!_books.containsKey(u.bookId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_location',
            'Unit "${u.id}" → unknown book "${u.bookId}".', ref: u.id));
      }
      final secId = u.location.sectionId;
      if (secId != null && !_sections.containsKey(secId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_location',
            'Unit "${u.id}" → unknown section "$secId".', ref: u.id));
      }
      final topId = u.location.topicId;
      if (topId != null && !_topics.containsKey(topId)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_location',
            'Unit "${u.id}" → unknown topic "$topId".', ref: u.id));
      }
      for (final eid in u.evidenceIds) {
        if (!_evidence.containsKey(eid)) {
          issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_evidence',
              'Unit "${u.id}" → unknown evidence "$eid".', ref: u.id));
        }
      }
      for (final rid in u.sourceReferenceIds) {
        if (!_sourceRefs.containsKey(rid)) {
          issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_source_ref',
              'Unit "${u.id}" → unknown source reference "$rid".', ref: u.id));
        }
      }
      for (final xid in u.crossReferenceIds) {
        if (!_crossRefs.containsKey(xid)) {
          issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_cross_ref',
              'Unit "${u.id}" → unknown cross-reference "$xid".', ref: u.id));
        }
      }
      // Canon-approved units must carry evidence (traceability guarantee).
      if (u.validationStatus.isCanonApproved && u.evidenceIds.isEmpty) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.warning,
            'approved_without_evidence',
            'Canon-approved unit "${u.id}" has no evidence.', ref: u.id));
      }
    }

    for (final x in _crossRefs.values) {
      final fromOk = _exists(x.fromId);
      final toOk = _exists(x.toId);
      if (!fromOk || !toOk) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'dangling_cross_ref',
            'Cross-reference "${x.id}" has unknown endpoint(s).', ref: x.id));
      }
    }

    for (final e in _evidence.values) {
      // Provenance is by reference: a page (or other locator) is enough. We do
      // NOT require a stored quote — the platform never stores copyrighted
      // paragraphs. Warn only when there is no provenance at all.
      if (!e.hasQuote && e.page == null) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.warning, 'evidence_no_quote',
            'Evidence "${e.id}" has no provenance (needs a page or locator).',
            ref: e.id));
      }
      final sr = e.sourceReferenceId;
      if (sr != null && !_sourceRefs.containsKey(sr)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'broken_source_ref',
            'Evidence "${e.id}" → unknown source reference "$sr".', ref: e.id));
      }
    }

    return issues;
  }

  bool _exists(String id) =>
      _units.containsKey(id) ||
      _chapters.containsKey(id) ||
      _sections.containsKey(id) ||
      _topics.containsKey(id) ||
      _books.containsKey(id);

  // --- Canon V1 compatibility bridge -----------------------------------------

  /// Convert assertive, canon-approved units into Canon V1
  /// [CanonicalKnowledgeNode]s so the existing resolver/engine consume them
  /// unchanged. [tierOf]/[isCanonOf] resolve authority from the source registry
  /// (keeping authority *derived, not self-declared*). Non-assertive units
  /// (topic/example/condition) and non-approved units are skipped by default.
  List<CanonicalKnowledgeNode> toCanonNodes({
    required KnowledgeTier Function(String sourceId) tierOf,
    bool Function(String sourceId)? isCanonOf,
    bool approvedOnly = true,
  }) {
    final nodes = <CanonicalKnowledgeNode>[];
    for (final u in _units.values) {
      final category = u.type.resolverCategory;
      if (category == null) continue;
      if (approvedOnly && !u.validationStatus.isCanonApproved) continue;
      final book = _books[u.bookId];
      if (book == null) continue;
      final tier = tierOf(book.sourceId);
      final canonical = isCanonOf?.call(book.sourceId) ?? tier.isCanon;
      final ev = u.evidenceIds
          .map((id) => _evidence[id])
          .whereType<CanonEvidence>()
          .map((e) => e.toNodeEvidence())
          .toList();
      nodes.add(CanonicalKnowledgeNode(
        id: u.id,
        topic: u.topic,
        subject: u.subject,
        category: category,
        statement: u.statement,
        value: u.value,
        sourceId: book.sourceId,
        tier: tier,
        canonical: canonical,
        confidence: u.confidence,
        status: _statusToNodeStatus(u.validationStatus),
        evidence: ev,
        references: u.crossReferenceIds,
        conditions: u.conditions,
        exceptions: u.exceptions,
        notes: u.notes,
      ));
    }
    return nodes;
  }

  static KnowledgeNodeStatus _statusToNodeStatus(CanonValidationStatus s) =>
      switch (s) {
        CanonValidationStatus.draft => KnowledgeNodeStatus.draft,
        CanonValidationStatus.extracted => KnowledgeNodeStatus.draft,
        CanonValidationStatus.reviewed => KnowledgeNodeStatus.reviewed,
        CanonValidationStatus.validated => KnowledgeNodeStatus.reviewed,
        CanonValidationStatus.canonApproved => KnowledgeNodeStatus.verified,
      };

  // --- loading ---------------------------------------------------------------

  static CanonDatabaseLoadResult fromMaps(Map<String, dynamic> root) {
    final issues = <CanonDbIssue>[];

    List<Map<String, dynamic>> list(String key) {
      final v = root[key];
      if (v is List) return v.whereType<Map<String, dynamic>>().toList();
      return const [];
    }

    final books = _collect(list('books'), CanonBook.fromMap, 'book', issues);
    final chapters =
        _collect(list('chapters'), CanonChapter.fromMap, 'chapter', issues);
    final sections =
        _collect(list('sections'), CanonSection.fromMap, 'section', issues);
    final topics =
        _collect(list('topics'), CanonTopicEntity.fromMap, 'topic', issues);
    final units = _collect(
        list('units'), CanonKnowledgeUnit.fromMap, 'unit', issues);
    final evidence =
        _collect(list('evidence'), CanonEvidence.fromMap, 'evidence', issues);
    final crossRefs = _collect(
        list('crossReferences'), CanonCrossReference.fromMap, 'crossRef', issues);
    final sourceRefs = _collect(list('sourceReferences'),
        CanonSourceReference.fromMap, 'sourceRef', issues);

    final db = CanonDatabase(
      books: books,
      chapters: chapters,
      sections: sections,
      topics: topics,
      units: units,
      evidence: evidence,
      crossReferences: crossRefs,
      sourceReferences: sourceRefs,
    );
    return CanonDatabaseLoadResult(
      database: db,
      issues: [...issues, ...db.validate()],
    );
  }

  static CanonDatabaseLoadResult load(String jsonString) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException catch (e) {
      return CanonDatabaseLoadResult(
        database: CanonDatabase(),
        issues: [CanonDbIssue(CanonDbIssueSeverity.error, 'invalid_json', '$e')],
      );
    }
    if (decoded is! Map<String, dynamic>) {
      return CanonDatabaseLoadResult(
        database: CanonDatabase(),
        issues: const [
          CanonDbIssue(
              CanonDbIssueSeverity.error, 'invalid_root', 'Root must be object.')
        ],
      );
    }
    return fromMaps(decoded);
  }

  static Future<CanonDatabaseLoadResult> loadFromAsset({
    String asset = kCanonDatabaseAsset,
  }) async {
    return load(await rootBundle.loadString(asset));
  }

  static List<T> _collect<T>(
    List<Map<String, dynamic>> maps,
    T? Function(Map<String, dynamic>) parse,
    String kind,
    List<CanonDbIssue> issues,
  ) {
    final out = <T>[];
    final seen = <String>{};
    for (final m in maps) {
      final parsed = parse(m);
      if (parsed == null) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'invalid_$kind',
            'Could not parse $kind: missing required fields.'));
        continue;
      }
      final id = (m['id'] as String?)?.trim() ?? '';
      if (id.isNotEmpty && !seen.add(id)) {
        issues.add(CanonDbIssue(CanonDbIssueSeverity.error, 'duplicate_$kind',
            '$kind id "$id" defined more than once.', ref: id));
        continue;
      }
      out.add(parsed);
    }
    return out;
  }
}
