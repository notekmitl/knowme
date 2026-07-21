import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/evidence/evidence_record.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart';
import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';

/// Severity of an evidence-linking issue.
enum EvidenceIssueSeverity { error, warning }

/// One problem found while linking evidence ↔ research.
class EvidenceLinkIssue {
  const EvidenceLinkIssue({
    required this.severity,
    required this.code,
    required this.message,
  });

  final EvidenceIssueSeverity severity;

  /// `duplicate_evidence`, `broken_link`, `missing_evidence`,
  /// `unused_evidence`, `circular_reference`.
  final String code;
  final String message;

  bool get isError => severity == EvidenceIssueSeverity.error;

  @override
  String toString() =>
      '${isError ? 'ERROR' : 'WARN '} $code: $message';
}

/// Validation outcome of the evidence ↔ research linkage.
class EvidenceValidationResult {
  EvidenceValidationResult(List<EvidenceLinkIssue> issues)
      : issues = List.unmodifiable(issues);

  final List<EvidenceLinkIssue> issues;

  List<EvidenceLinkIssue> get errors =>
      issues.where((i) => i.isError).toList(growable: false);
  List<EvidenceLinkIssue> get warnings =>
      issues.where((i) => !i.isError).toList(growable: false);

  bool get ok => errors.isEmpty;
}

/// Links the evidence corpus to the research corpus and audits the linkage.
///
/// Pure knowledge layer: depends only on the evidence + research models (no
/// engine, no matrix, no runtime, no prediction).
class KnowledgeEvidenceEngine {
  KnowledgeEvidenceEngine({
    required Iterable<EvidenceRecord> evidence,
    required Iterable<KnowledgeResearchRecord> research,
  })  : evidence = List.unmodifiable(evidence),
        research = List.unmodifiable(research) {
    for (final e in this.evidence) {
      _evidenceById.putIfAbsent(e.id, () => e);
    }
  }

  final List<EvidenceRecord> evidence;
  final List<KnowledgeResearchRecord> research;
  final Map<String, EvidenceRecord> _evidenceById = {};

  // ---------------------------------------------------------------------------
  // load
  // ---------------------------------------------------------------------------

  static const String evidenceAssetKey =
      'knowledge/evidence/evidence.knowme.json';

  /// Parse a list of [EvidenceRecord]s from a JSON string. Malformed entries
  /// are skipped.
  static List<EvidenceRecord> loadEvidence(String jsonString) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      return const [];
    }
    if (decoded is! Map<String, dynamic>) return const [];
    final rawList = decoded['records'] ?? decoded['evidence'];
    if (rawList is! List) return const [];
    final out = <EvidenceRecord>[];
    for (final raw in rawList) {
      if (raw is! Map<String, dynamic>) continue;
      final e = evidenceRecordFromMap(raw);
      if (e != null) out.add(e);
    }
    return out;
  }

  /// Convenience: build an engine from evidence + research JSON strings.
  static KnowledgeEvidenceEngine load({
    required String evidenceJson,
    required String researchJson,
  }) {
    return KnowledgeEvidenceEngine(
      evidence: loadEvidence(evidenceJson),
      research: KnowledgeResearchEngine.load(researchJson).records,
    );
  }

  /// Load both corpora from bundled assets.
  static Future<KnowledgeEvidenceEngine> loadFromAssets({
    String evidenceKey = evidenceAssetKey,
    String researchKey = KnowledgeResearchEngine.assetKey,
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    return load(
      evidenceJson: await b.loadString(evidenceKey),
      researchJson: await b.loadString(researchKey),
    );
  }

  /// Parse a single [EvidenceRecord] from a JSON map. Returns null when a
  /// required field is missing or `reviewStatus` is unknown. Exposed for reuse
  /// by the acquisition layer (V6).
  static EvidenceRecord? evidenceRecordFromMap(Map<String, dynamic> raw) {
    final id = raw['id'];
    final sourceType = raw['sourceType'];
    final school = raw['school'];
    final author = raw['author'];
    final book = raw['book'];
    final language = raw['language'];
    final reviewStatus = _reviewStatus(raw['reviewStatus']);
    if (id is! String ||
        sourceType is! String ||
        school is! String ||
        author is! String ||
        book is! String ||
        language is! String ||
        reviewStatus == null) {
      return null;
    }
    final yearRaw = raw['year'];
    return EvidenceRecord(
      id: id,
      sourceType: sourceType,
      school: school,
      author: author,
      book: book,
      edition: _str(raw['edition']),
      publisher: _str(raw['publisher']),
      year: yearRaw is int ? yearRaw : int.tryParse('${yearRaw ?? ''}'),
      page: _str(raw['page']),
      language: language,
      quote: _str(raw['quote']),
      summary: _str(raw['summary']),
      url: _str(raw['url']),
      license: _str(raw['license']),
      reviewStatus: reviewStatus,
      reviewer: _str(raw['reviewer']),
      createdAt: DateTime.tryParse('${raw['createdAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${raw['updatedAt'] ?? ''}'),
      notes: _str(raw['notes']),
    );
  }

  // ---------------------------------------------------------------------------
  // lookups
  // ---------------------------------------------------------------------------

  /// Evidence by id, or null.
  EvidenceRecord? findEvidence(String id) => _evidenceById[id];

  /// Research records that reference [evidenceId].
  List<KnowledgeResearchRecord> findResearch(String evidenceId) => research
      .where((r) => r.evidenceIds.contains(evidenceId))
      .toList(growable: false);

  /// Distinct relationships supported by research that references [evidenceId].
  List<ResearchRelationship> findRelationships(String evidenceId) {
    final seen = <String>{};
    final out = <ResearchRelationship>[];
    for (final r in findResearch(evidenceId)) {
      for (final rel in r.relationship) {
        if (seen.add('${rel.pairKey}:${rel.relation}')) out.add(rel);
      }
    }
    return out;
  }

  /// Evidence referenced by no research record.
  List<EvidenceRecord> findOrphans() {
    final referenced = _referencedEvidenceIds();
    return evidence
        .where((e) => !referenced.contains(e.id))
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // grouping (for the workspace)
  // ---------------------------------------------------------------------------

  Map<String, List<EvidenceRecord>> groupEvidenceBySchool() =>
      _group(evidence, (e) => e.school);
  Map<String, List<EvidenceRecord>> groupEvidenceByAuthor() =>
      _group(evidence, (e) => e.author);
  Map<String, List<EvidenceRecord>> groupEvidenceBySource() =>
      _group(evidence, (e) => e.sourceLabel);

  // ---------------------------------------------------------------------------
  // validation
  // ---------------------------------------------------------------------------

  EvidenceValidationResult validate() {
    final issues = <EvidenceLinkIssue>[];
    void err(String code, String message) => issues.add(EvidenceLinkIssue(
        severity: EvidenceIssueSeverity.error, code: code, message: message));
    void warn(String code, String message) => issues.add(EvidenceLinkIssue(
        severity: EvidenceIssueSeverity.warning, code: code, message: message));

    // Duplicate evidence ids.
    final counts = <String, int>{};
    for (final e in evidence) {
      counts[e.id] = (counts[e.id] ?? 0) + 1;
    }
    counts.forEach((id, n) {
      if (n > 1) err('duplicate_evidence', 'Evidence id "$id" appears $n times.');
    });

    // Broken links + research with no evidence.
    for (final r in research) {
      if (r.evidenceIds.isEmpty) {
        warn('missing_evidence',
            'Research "${r.id}" references no evidence.');
      }
      for (final id in r.evidenceIds) {
        if (!_evidenceById.containsKey(id)) {
          err('broken_link',
              'Research "${r.id}" references missing evidence "$id".');
        }
      }
    }

    // Unused (orphan) evidence.
    for (final o in findOrphans()) {
      warn('unused_evidence', 'Evidence "${o.id}" is referenced by no research.');
    }

    // Circular references (defensive — the research→evidence graph is bipartite
    // and acyclic by construction, so this normally finds nothing).
    for (final cycle in _findCycles()) {
      err('circular_reference', 'Circular reference: ${cycle.join(' -> ')}.');
    }

    return EvidenceValidationResult(issues);
  }

  /// Detects cycles in the id-reference graph (research id → evidence ids).
  List<List<String>> _findCycles() {
    final edges = <String, List<String>>{};
    for (final r in research) {
      edges[r.id] = [...r.evidenceIds];
    }
    final cycles = <List<String>>[];
    final visiting = <String>{};
    final done = <String>{};
    final stack = <String>[];

    void dfs(String node) {
      if (done.contains(node)) return;
      if (visiting.contains(node)) {
        final start = stack.indexOf(node);
        cycles.add([...stack.sublist(start), node]);
        return;
      }
      visiting.add(node);
      stack.add(node);
      for (final next in edges[node] ?? const <String>[]) {
        dfs(next);
      }
      stack.removeLast();
      visiting.remove(node);
      done.add(node);
    }

    for (final node in edges.keys) {
      dfs(node);
    }
    return cycles;
  }

  // ---------------------------------------------------------------------------
  // coverage
  // ---------------------------------------------------------------------------

  EvidenceCoverageReport coverage() {
    final referenced = _referencedEvidenceIds();
    final existingReferenced =
        referenced.where(_evidenceById.containsKey).toSet();

    final supportedPairs = <String>{};
    var researchSupported = 0;
    for (final r in research) {
      final hasValidEvidence =
          r.evidenceIds.any(_evidenceById.containsKey);
      if (hasValidEvidence) {
        researchSupported++;
        for (final rel in r.relationship) {
          supportedPairs.add(rel.pairKey);
        }
      }
    }

    return EvidenceCoverageReport(
      evidenceCount: evidence.length,
      referencedEvidence: existingReferenced.length,
      orphanEvidence: evidence.length - existingReferenced.length,
      relationshipsSupported: supportedPairs.length,
      researchRecordsSupported: researchSupported,
    );
  }

  Set<String> _referencedEvidenceIds() {
    final out = <String>{};
    for (final r in research) {
      out.addAll(r.evidenceIds);
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // helpers
  // ---------------------------------------------------------------------------

  static Map<String, List<T>> _group<T>(
    Iterable<T> items,
    String Function(T) key,
  ) {
    final out = <String, List<T>>{};
    for (final item in items) {
      (out[key(item)] ??= []).add(item);
    }
    return out;
  }

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }

  static EvidenceReviewStatus? _reviewStatus(Object? v) {
    if (v is! String) return null;
    for (final s in EvidenceReviewStatus.values) {
      if (s.name == v) return s;
    }
    return null;
  }
}

/// Evidence Coverage Report.
class EvidenceCoverageReport {
  const EvidenceCoverageReport({
    required this.evidenceCount,
    required this.referencedEvidence,
    required this.orphanEvidence,
    required this.relationshipsSupported,
    required this.researchRecordsSupported,
  });

  final int evidenceCount;
  final int referencedEvidence;
  final int orphanEvidence;
  final int relationshipsSupported;
  final int researchRecordsSupported;

  List<String> toReportLines() => [
        'Knowledge Evidence — Coverage Report',
        'Evidence count            : $evidenceCount',
        'Referenced evidence       : $referencedEvidence',
        'Orphan evidence           : $orphanEvidence',
        'Relationships supported   : $relationshipsSupported',
        'Research records supported: $researchRecordsSupported',
      ];
}
