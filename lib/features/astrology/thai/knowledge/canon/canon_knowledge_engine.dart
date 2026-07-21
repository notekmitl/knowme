import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/canon/canon_conflict_resolver.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canon_json.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_source.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// Asset paths for the canon data files.
const String kCanonSourcesAsset = 'knowledge/canon/canon_sources.json';
const String kCanonNodesAsset = 'knowledge/canon/canon.knowme.json';

enum CanonIssueSeverity { error, warning, info }

class CanonIssue {
  const CanonIssue(this.severity, this.code, this.message, {this.ref});

  final CanonIssueSeverity severity;
  final String code;
  final String message;
  final String? ref;

  bool get isError => severity == CanonIssueSeverity.error;

  @override
  String toString() =>
      '[${severity.name}] $code: $message${ref == null ? '' : ' ($ref)'}';
}

/// Result of loading + validating the canon corpus.
class CanonLoadResult {
  const CanonLoadResult({
    required this.engine,
    required this.issues,
  });

  final CanonKnowledgeEngine engine;
  final List<CanonIssue> issues;

  bool get hasErrors => issues.any((i) => i.isError);
  List<CanonIssue> get errors => issues.where((i) => i.isError).toList();
  List<CanonIssue> get warnings =>
      issues.where((i) => i.severity == CanonIssueSeverity.warning).toList();
}

/// Coverage snapshot across the canon corpus.
///
/// Named to avoid collision with the ingestion-layer `CanonCoverageReport`
/// (`canon/ingestion/canon_coverage_analysis.dart`), which measures per-book
/// extraction coverage rather than corpus authority.
class CanonCorpusCoverageReport {
  const CanonCorpusCoverageReport({
    required this.totalNodes,
    required this.totalSources,
    required this.nodesByTier,
    required this.nodesByCategory,
    required this.totalSubjects,
    required this.canonicalSubjects,
    required this.supportingOnlySubjects,
    required this.canonInternalConflicts,
    required this.overruledNodes,
    required this.canonSources,
  });

  final int totalNodes;
  final int totalSources;
  final Map<KnowledgeTier, int> nodesByTier;
  final Map<KnowledgeNodeCategory, int> nodesByCategory;
  final int totalSubjects;

  /// Subjects whose authority is Canon (Tier 1).
  final int canonicalSubjects;

  /// Subjects covered only by supporting sources (provisional).
  final int supportingOnlySubjects;

  /// Subjects where canon disagrees with canon (needs human review).
  final int canonInternalConflicts;

  /// Count of supporting nodes overruled by Canon.
  final int overruledNodes;

  /// Number of registered Tier-1 canonical sources.
  final int canonSources;

  double get canonicalShare =>
      totalSubjects == 0 ? 0 : canonicalSubjects / totalSubjects;

  String get summary =>
      '$totalNodes node(s) from $totalSources source(s); '
      '$canonicalSubjects/$totalSubjects subject(s) canon-backed '
      '(${(canonicalShare * 100).toStringAsFixed(1)}%), '
      '$supportingOnlySubjects provisional, '
      '$canonInternalConflicts canon conflict(s).';
}

/// Loads the canon source registry + knowledge nodes, validates referential
/// integrity, and applies the Source Priority via [CanonConflictResolver].
///
/// Pure knowledge layer: it never imports the calculation engine or
/// `PlanetRelationshipMatrix`, and changes no engine behaviour.
class CanonKnowledgeEngine {
  CanonKnowledgeEngine({
    required Iterable<CanonicalSource> sources,
    required Iterable<CanonicalKnowledgeNode> nodes,
  })  : _sources = {for (final s in sources) s.id: s},
        _nodes = List.unmodifiable(nodes);

  final Map<String, CanonicalSource> _sources;
  final List<CanonicalKnowledgeNode> _nodes;

  List<CanonicalSource> get sources => _sources.values.toList(growable: false);
  List<CanonicalKnowledgeNode> get nodes => _nodes;
  CanonicalSource? source(String id) => _sources[id];

  /// All registered Tier-1 canonical sources.
  List<CanonicalSource> get canonSources =>
      _sources.values.where((s) => s.isCanon).toList(growable: false);

  Map<String, CanonResolution> resolveAll() =>
      CanonConflictResolver.resolveAll(_nodes);

  CanonResolution? resolve(String topic, String subject) {
    final group =
        _nodes.where((n) => n.topic == topic && n.subject == subject).toList();
    if (group.isEmpty) return null;
    return CanonConflictResolver.resolveSubject(group);
  }

  CanonCorpusCoverageReport coverage() {
    final byTier = <KnowledgeTier, int>{};
    final byCat = <KnowledgeNodeCategory, int>{};
    for (final n in _nodes) {
      byTier[n.tier] = (byTier[n.tier] ?? 0) + 1;
      byCat[n.category] = (byCat[n.category] ?? 0) + 1;
    }
    final resolutions = resolveAll();
    var canonical = 0;
    var supportingOnly = 0;
    var conflicts = 0;
    var overruled = 0;
    for (final r in resolutions.values) {
      switch (r.outcome) {
        case CanonResolutionOutcome.canonical:
          canonical++;
        case CanonResolutionOutcome.supportingOnly:
          supportingOnly++;
        case CanonResolutionOutcome.canonInternalConflict:
          conflicts++;
        case CanonResolutionOutcome.empty:
          break;
      }
      overruled += r.overruledByCanon.length;
    }
    return CanonCorpusCoverageReport(
      totalNodes: _nodes.length,
      totalSources: _sources.length,
      nodesByTier: byTier,
      nodesByCategory: byCat,
      totalSubjects: resolutions.length,
      canonicalSubjects: canonical,
      supportingOnlySubjects: supportingOnly,
      canonInternalConflicts: conflicts,
      overruledNodes: overruled,
      canonSources: canonSources.length,
    );
  }

  // --- loading + validation --------------------------------------------------

  /// Build an engine from already-parsed maps. Resolves each node's tier from
  /// the source registry and collects validation issues.
  static CanonLoadResult build({
    required List<Map<String, dynamic>> sourceMaps,
    required List<Map<String, dynamic>> nodeMaps,
  }) {
    final issues = <CanonIssue>[];
    final sources = <String, CanonicalSource>{};

    for (final m in sourceMaps) {
      final src = _sourceFromMap(m, issues);
      if (src == null) continue;
      if (sources.containsKey(src.id)) {
        issues.add(CanonIssue(CanonIssueSeverity.error, 'duplicate_source',
            'Source id "${src.id}" defined more than once.',
            ref: src.id));
        continue;
      }
      sources[src.id] = src;
    }

    final nodes = <CanonicalKnowledgeNode>[];
    final seenNodeIds = <String>{};
    for (final m in nodeMaps) {
      final node = _nodeFromMap(m, sources, issues);
      if (node == null) continue;
      if (!seenNodeIds.add(node.id)) {
        issues.add(CanonIssue(CanonIssueSeverity.error, 'duplicate_node',
            'Node id "${node.id}" defined more than once.',
            ref: node.id));
        continue;
      }
      nodes.add(node);
    }

    // Reference integrity: references[] should point at known node ids.
    final ids = nodes.map((n) => n.id).toSet();
    for (final n in nodes) {
      for (final r in n.references) {
        if (!ids.contains(r)) {
          issues.add(CanonIssue(CanonIssueSeverity.warning, 'broken_reference',
              'Node "${n.id}" references unknown node "$r".',
              ref: n.id));
        }
      }
      if (n.isCanonical && !n.hasEvidence) {
        issues.add(CanonIssue(CanonIssueSeverity.warning,
            'canon_missing_evidence',
            'Canonical node "${n.id}" has no evidence/quote.',
            ref: n.id));
      }
    }

    final engine = CanonKnowledgeEngine(
      sources: sources.values,
      nodes: nodes,
    );

    // Surface canon-internal conflicts as warnings.
    for (final r in engine.resolveAll().values) {
      if (r.needsHumanReview) {
        issues.add(CanonIssue(CanonIssueSeverity.warning,
            'canon_internal_conflict',
            'Canon disagrees with canon for "${r.subjectKey}".',
            ref: r.subjectKey));
      }
    }

    return CanonLoadResult(engine: engine, issues: issues);
  }

  /// Build from JSON strings (sources file + nodes file).
  static CanonLoadResult load({
    required String sourcesJson,
    required String nodesJson,
  }) {
    final issues = <CanonIssue>[];
    final sourceMaps = _records(sourcesJson, 'sources', issues);
    final nodeMaps = _records(nodesJson, 'nodes', issues);
    final result = build(sourceMaps: sourceMaps, nodeMaps: nodeMaps);
    return CanonLoadResult(
      engine: result.engine,
      issues: [...issues, ...result.issues],
    );
  }

  /// Load from bundled assets.
  static Future<CanonLoadResult> loadFromAssets({
    String sourcesAsset = kCanonSourcesAsset,
    String nodesAsset = kCanonNodesAsset,
  }) async {
    final sourcesJson = await rootBundle.loadString(sourcesAsset);
    final nodesJson = await rootBundle.loadString(nodesAsset);
    return load(sourcesJson: sourcesJson, nodesJson: nodesJson);
  }

  static List<Map<String, dynamic>> _records(
    String jsonString,
    String key,
    List<CanonIssue> issues,
  ) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException catch (e) {
      issues.add(CanonIssue(
          CanonIssueSeverity.error, 'invalid_json', 'Malformed JSON: $e'));
      return const [];
    }
    if (decoded is Map<String, dynamic>) {
      final list = decoded[key];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
      issues.add(CanonIssue(CanonIssueSeverity.error, 'missing_array',
          'Expected array field "$key".'));
      return const [];
    }
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }
    issues.add(CanonIssue(CanonIssueSeverity.error, 'invalid_root',
        'Root must be an object with "$key" or an array.'));
    return const [];
  }

  static CanonicalSource? _sourceFromMap(
    Map<String, dynamic> m,
    List<CanonIssue> issues,
  ) {
    final id = (m['id'] as String?)?.trim();
    final title = (m['title'] as String?)?.trim();
    final tierKey = (m['tier'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      issues.add(const CanonIssue(
          CanonIssueSeverity.error, 'missing_field', 'Source missing "id".'));
      return null;
    }
    if (title == null || title.isEmpty) {
      issues.add(CanonIssue(CanonIssueSeverity.error, 'missing_field',
          'Source "$id" missing "title".',
          ref: id));
      return null;
    }
    final tier = tierKey == null ? null : KnowledgeTierAuthority.fromKey(tierKey);
    if (tier == null) {
      issues.add(CanonIssue(CanonIssueSeverity.error, 'unknown_tier',
          'Source "$id" has unknown tier "$tierKey".',
          ref: id));
      return null;
    }
    var canonical = m['canonical'] == true;
    if (canonical && tier != KnowledgeTier.canon) {
      issues.add(CanonIssue(CanonIssueSeverity.warning, 'canonical_tier_mismatch',
          'Source "$id" is canonical but not Tier 1; coercing to non-canonical.',
          ref: id));
      canonical = false;
    }
    return CanonicalSource(
      id: id,
      title: title,
      tier: tier,
      canonical: canonical,
      author: (m['author'] as String?)?.trim(),
      edition: (m['edition'] as String?)?.trim(),
      publisher: (m['publisher'] as String?)?.trim(),
      year: m['year'] is int ? m['year'] as int : null,
      language: (m['language'] as String?)?.trim(),
      isbn: (m['isbn'] as String?)?.trim(),
      url: (m['url'] as String?)?.trim(),
      notes: (m['notes'] as String?)?.trim(),
    );
  }

  static CanonicalKnowledgeNode? _nodeFromMap(
    Map<String, dynamic> m,
    Map<String, CanonicalSource> sources,
    List<CanonIssue> issues,
  ) {
    final id = (m['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      issues.add(const CanonIssue(
          CanonIssueSeverity.error, 'missing_field', 'Node missing "id".'));
      return null;
    }
    final topic = (m['topic'] as String?)?.trim();
    final subject = (m['subject'] as String?)?.trim();
    final statement = (m['statement'] as String?)?.trim();
    final sourceId = (m['sourceId'] as String?)?.trim();
    if (topic == null || topic.isEmpty) {
      _missing(issues, id, 'topic');
      return null;
    }
    if (subject == null || subject.isEmpty) {
      _missing(issues, id, 'subject');
      return null;
    }
    if (statement == null || statement.isEmpty) {
      _missing(issues, id, 'statement');
      return null;
    }
    if (sourceId == null || sourceId.isEmpty) {
      _missing(issues, id, 'sourceId');
      return null;
    }
    final source = sources[sourceId];
    if (source == null) {
      issues.add(CanonIssue(CanonIssueSeverity.error, 'broken_source_ref',
          'Node "$id" references unknown source "$sourceId".',
          ref: id));
      return null;
    }
    final category = canonEnumByName(
      KnowledgeNodeCategory.values,
      (m['category'] as String?)?.trim(),
    );
    if (category == null) {
      issues.add(CanonIssue(CanonIssueSeverity.error, 'unknown_category',
          'Node "$id" has unknown category "${m['category']}".',
          ref: id));
      return null;
    }
    final status = canonEnumByName(
          KnowledgeNodeStatus.values,
          (m['status'] as String?)?.trim(),
        ) ??
        KnowledgeNodeStatus.draft;
    final confidence = canonEnumByName(
          KnowledgeConfidence.values,
          (m['confidence'] as String?)?.trim(),
        ) ??
        KnowledgeConfidence.none;

    return CanonicalKnowledgeNode(
      id: id,
      topic: topic,
      subject: subject,
      category: category,
      statement: statement,
      value: (m['value'] as String?)?.trim(),
      sourceId: sourceId,
      // Authority is derived from the source registry — never self-declared.
      tier: source.tier,
      canonical: source.isCanon,
      confidence: confidence,
      status: status,
      evidence: _evidence(m['evidence']),
      references: canonStringList(m['references']),
      conditions: canonStringList(m['conditions']),
      exceptions: canonStringList(m['exceptions']),
      notes: (m['notes'] as String?)?.trim(),
    );
  }

  static void _missing(List<CanonIssue> issues, String id, String field) {
    issues.add(CanonIssue(CanonIssueSeverity.error, 'missing_field',
        'Node "$id" missing "$field".',
        ref: id));
  }

  static List<KnowledgeNodeEvidence> _evidence(Object? raw) {
    if (raw is! List) return const [];
    final out = <KnowledgeNodeEvidence>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(KnowledgeNodeEvidence(
          page: (e['page'] as String?)?.trim(),
          quote: (e['quote'] as String?)?.trim(),
          note: (e['note'] as String?)?.trim(),
        ));
      }
    }
    return out;
  }
}
