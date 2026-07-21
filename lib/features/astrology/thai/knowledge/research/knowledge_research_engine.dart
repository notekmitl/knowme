import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_record.dart';

/// The eight planets the research corpus is scoped to, as plain keys. Declared
/// here (not imported from the engine) so the research layer stays independent
/// of the engine and the matrix. Used only to size "relationships without
/// evidence" (the 8 × 7 = 56 directed-pair universe).
const List<String> kKnowledgeResearchPlanets = [
  'sun',
  'moon',
  'mars',
  'mercury',
  'jupiter',
  'venus',
  'saturn',
  'rahu',
];

/// A relationship for which research records disagree on the asserted relation.
class ResearchConflict {
  const ResearchConflict({
    required this.from,
    required this.to,
    required this.relations,
    required this.recordIds,
  });

  final String from;
  final String to;

  /// The differing relation values asserted for this pair, e.g. {friend, enemy}.
  final Set<String> relations;

  /// Ids of the records involved.
  final List<String> recordIds;

  String get pairKey => '$from->$to';
}

/// Research engine over a corpus of [KnowledgeResearchRecord]s.
///
/// Pure knowledge layer: no engine, no matrix. It loads, finds supporting
/// evidence and conflicts, and reports research coverage. Bibliographic grouping
/// (by source/school) moved to `KnowledgeEvidenceEngine` in V4, since those
/// fields now live on `EvidenceRecord`.
class KnowledgeResearchEngine {
  KnowledgeResearchEngine(Iterable<KnowledgeResearchRecord> records)
      : records = List.unmodifiable(records);

  final List<KnowledgeResearchRecord> records;

  // ---------------------------------------------------------------------------
  // load
  // ---------------------------------------------------------------------------

  static const String assetKey = 'knowledge/research/research.knowme.json';

  /// Parse an engine from a JSON string. Records missing required fields or
  /// using unknown enum values are skipped (research is collected gradually).
  static KnowledgeResearchEngine load(String jsonString) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      return KnowledgeResearchEngine(const []);
    }
    if (decoded is! Map<String, dynamic>) {
      return KnowledgeResearchEngine(const []);
    }
    final rawList = decoded['records'];
    if (rawList is! List) return KnowledgeResearchEngine(const []);

    final records = <KnowledgeResearchRecord>[];
    for (final raw in rawList) {
      if (raw is! Map<String, dynamic>) continue;
      final record = recordFromMap(raw);
      if (record != null) records.add(record);
    }
    return KnowledgeResearchEngine(records);
  }

  /// Load from the bundled research asset (when present).
  static Future<KnowledgeResearchEngine> loadFromAsset({
    String key = assetKey,
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    return load(await b.loadString(key));
  }

  /// Parse a single record map. Returns null when required fields are missing
  /// or enum values are unknown. Exposed for reuse by `KnowledgeEvidenceEngine`.
  static KnowledgeResearchRecord? recordFromMap(Map<String, dynamic> raw) {
    final id = raw['id'];
    final topic = raw['topic'];
    final entity = raw['entity'];
    final interpretation = raw['interpretation'];
    final status = _status(raw['status']);
    final confidence = _confidence(raw['confidence']);
    if (id is! String ||
        topic is! String ||
        entity is! String ||
        interpretation is! String ||
        status == null ||
        confidence == null) {
      return null;
    }

    final rels = <ResearchRelationship>[];
    final rawRels = raw['relationship'];
    if (rawRels is List) {
      for (final r in rawRels) {
        if (r is! Map<String, dynamic>) continue;
        final from = r['from'];
        final to = r['to'];
        final relation = r['relation'];
        if (from is String && to is String && relation is String) {
          rels.add(
            ResearchRelationship(from: from, to: to, relation: relation),
          );
        }
      }
    }

    final evidenceIds = <String>[];
    final rawIds = raw['evidenceIds'];
    if (rawIds is List) {
      for (final e in rawIds) {
        if (e is String && e.trim().isNotEmpty) evidenceIds.add(e.trim());
      }
    }

    return KnowledgeResearchRecord(
      id: id,
      topic: topic,
      entity: entity,
      interpretation: interpretation,
      relationship: rels,
      evidenceIds: evidenceIds,
      confidence: confidence,
      reviewedBy: _str(raw['reviewedBy']),
      status: status,
      notes: _str(raw['notes']),
    );
  }

  // ---------------------------------------------------------------------------
  // evidence + conflicts
  // ---------------------------------------------------------------------------

  /// Records that support the directed relationship `from → to`. When
  /// [relation] is given, only records asserting that relation are returned.
  List<KnowledgeResearchRecord> findSupportingEvidence(
    String from,
    String to, {
    String? relation,
  }) {
    return records
        .where((r) => r.relationship.any((rel) =>
            rel.from == from &&
            rel.to == to &&
            (relation == null || rel.relation == relation)))
        .toList(growable: false);
  }

  /// Directed pairs where records disagree on the asserted relation.
  List<ResearchConflict> findConflicts() {
    final relationsByPair = <String, Set<String>>{};
    final idsByPair = <String, List<String>>{};
    final fromToByPair = <String, List<String>>{};
    for (final r in records) {
      for (final rel in r.relationship) {
        final key = rel.pairKey;
        (relationsByPair[key] ??= <String>{}).add(rel.relation);
        (idsByPair[key] ??= <String>[]).add(r.id);
        fromToByPair[key] ??= [rel.from, rel.to];
      }
    }
    final conflicts = <ResearchConflict>[];
    relationsByPair.forEach((key, relations) {
      if (relations.length > 1) {
        final ft = fromToByPair[key]!;
        conflicts.add(
          ResearchConflict(
            from: ft[0],
            to: ft[1],
            relations: relations,
            recordIds: idsByPair[key]!,
          ),
        );
      }
    });
    return conflicts;
  }

  // ---------------------------------------------------------------------------
  // coverage
  // ---------------------------------------------------------------------------

  ResearchCoverageReport coverage() => ResearchCoverageReport.of(records);

  // ---------------------------------------------------------------------------
  // parsing helpers
  // ---------------------------------------------------------------------------

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }

  static ResearchStatus? _status(Object? v) {
    if (v is! String) return null;
    for (final s in ResearchStatus.values) {
      if (s.name == v) return s;
    }
    return null;
  }

  static ResearchConfidence? _confidence(Object? v) {
    if (v is! String) return null;
    for (final c in ResearchConfidence.values) {
      if (c.name == v) return c;
    }
    return null;
  }
}

/// Research Coverage Report — research records, their status split, and how much
/// of the relationship universe has any research backing it.
class ResearchCoverageReport {
  const ResearchCoverageReport({
    required this.totalRecords,
    required this.draft,
    required this.candidate,
    required this.reviewed,
    required this.verified,
    required this.disputed,
    required this.rejected,
    required this.relationshipsSupported,
    required this.relationshipsWithoutEvidence,
  });

  factory ResearchCoverageReport.of(
    Iterable<KnowledgeResearchRecord> records,
  ) {
    final supportedPairs = <String>{};
    var total = 0;
    var draft = 0;
    var candidate = 0;
    var reviewed = 0;
    var verified = 0;
    var disputed = 0;
    var rejected = 0;
    for (final r in records) {
      total++;
      switch (r.status) {
        case ResearchStatus.draft:
          draft++;
        case ResearchStatus.candidate:
          candidate++;
        case ResearchStatus.reviewed:
          reviewed++;
        case ResearchStatus.verified:
          verified++;
        case ResearchStatus.disputed:
          disputed++;
        case ResearchStatus.rejected:
          rejected++;
      }
      for (final rel in r.relationship) {
        if (kKnowledgeResearchPlanets.contains(rel.from) &&
            kKnowledgeResearchPlanets.contains(rel.to) &&
            rel.from != rel.to) {
          supportedPairs.add(rel.pairKey);
        }
      }
    }

    final universe =
        kKnowledgeResearchPlanets.length * (kKnowledgeResearchPlanets.length - 1);
    return ResearchCoverageReport(
      totalRecords: total,
      draft: draft,
      candidate: candidate,
      reviewed: reviewed,
      verified: verified,
      disputed: disputed,
      rejected: rejected,
      relationshipsSupported: supportedPairs.length,
      relationshipsWithoutEvidence: universe - supportedPairs.length,
    );
  }

  final int totalRecords;
  final int draft;
  final int candidate;
  final int reviewed;
  final int verified;
  final int disputed;
  final int rejected;
  final int relationshipsSupported;
  final int relationshipsWithoutEvidence;

  int get relationshipUniverse =>
      kKnowledgeResearchPlanets.length * (kKnowledgeResearchPlanets.length - 1);

  double get relationshipCoveragePercent => relationshipUniverse == 0
      ? 0
      : relationshipsSupported / relationshipUniverse * 100;

  List<String> toReportLines() => [
        'Knowledge Research — Coverage Report',
        'Total records                 : $totalRecords',
        'Draft / Candidate / Reviewed  : $draft / $candidate / $reviewed',
        'Verified / Disputed / Rejected: $verified / $disputed / $rejected',
        'Relationships supported       : $relationshipsSupported / '
            '$relationshipUniverse',
        'Relationships without evidence: $relationshipsWithoutEvidence',
        'Relationship coverage         : '
            '${relationshipCoveragePercent.toStringAsFixed(1)}%',
      ];
}
