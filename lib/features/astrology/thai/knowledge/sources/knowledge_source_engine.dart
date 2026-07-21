import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'package:knowme/features/astrology/thai/knowledge/research/knowledge_research_engine.dart'
    show kKnowledgeResearchPlanets;
import 'package:knowme/features/astrology/thai/knowledge/sources/source_record.dart';

/// Allowed relation vocabulary for source assertions.
const Set<String> kSourceRelations = {'friend', 'neutral', 'enemy'};

/// Severity of a source-collection issue.
enum SourceIssueSeverity { error, warning }

/// One problem found while validating the source corpus.
class SourceIssue {
  const SourceIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.sourceId,
    this.pairKey,
  });

  final SourceIssueSeverity severity;

  /// `duplicate_assertion`, `conflicting_assertion`, `missing_page`,
  /// `missing_quote`, `broken_reference`, `duplicate_source`.
  final String code;
  final String message;
  final String? sourceId;
  final String? pairKey;

  bool get isError => severity == SourceIssueSeverity.error;

  @override
  String toString() =>
      '${isError ? 'ERROR' : 'WARN '} $code: $message';
}

/// Engine over a corpus of real astrology [SourceRecord]s (V7).
///
/// Pure knowledge layer: no engine, no matrix. Loads sources (one JSON per
/// source), validates them, and reports source coverage.
class KnowledgeSourceEngine {
  KnowledgeSourceEngine(Iterable<SourceRecord> sources)
      : sources = List.unmodifiable(sources);

  final List<SourceRecord> sources;

  /// All assertions across all sources, in load order.
  List<SourceAssertion> get assertions =>
      [for (final s in sources) ...s.assertions];

  // ---------------------------------------------------------------------------
  // load
  // ---------------------------------------------------------------------------

  static const String indexAssetKey = 'knowledge/sources/sources.index.json';
  static const String sourcesDir = 'knowledge/sources/';

  /// Parse a single source document. Returns null when required fields (id,
  /// title, author, school, language) are missing.
  static SourceRecord? sourceFromJson(String jsonString) {
    Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    return sourceFromMap(decoded);
  }

  /// Parse a source from a decoded map.
  static SourceRecord? sourceFromMap(Map<String, dynamic> raw) {
    final id = raw['id'];
    final title = raw['title'];
    final author = raw['author'];
    final school = raw['school'];
    final language = raw['language'];
    if (id is! String ||
        title is! String ||
        author is! String ||
        school is! String ||
        language is! String) {
      return null;
    }

    final assertions = <SourceAssertion>[];
    final rawAssertions = raw['assertions'];
    if (rawAssertions is List) {
      for (final a in rawAssertions) {
        if (a is! Map<String, dynamic>) continue;
        final from = a['from'];
        final to = a['to'];
        final relation = a['relation'];
        if (from is String && to is String && relation is String) {
          assertions.add(
            SourceAssertion(
              from: from,
              to: to,
              relation: relation,
              page: _str(a['page']),
              quote: _str(a['quote']),
              note: _str(a['note']),
            ),
          );
        }
      }
    }

    final yearRaw = raw['year'];
    return SourceRecord(
      id: id,
      title: title,
      author: author,
      edition: _str(raw['edition']),
      publisher: _str(raw['publisher']),
      year: yearRaw is int ? yearRaw : int.tryParse('${yearRaw ?? ''}'),
      language: language,
      school: school,
      isbn: _str(raw['isbn']),
      url: _str(raw['url']),
      license: _str(raw['license']),
      notes: _str(raw['notes']),
      assertions: assertions,
    );
  }

  /// Build an engine from many source JSON documents (one per source).
  static KnowledgeSourceEngine loadAll(Iterable<String> jsonDocuments) {
    final out = <SourceRecord>[];
    for (final doc in jsonDocuments) {
      final s = sourceFromJson(doc);
      if (s != null) out.add(s);
    }
    return KnowledgeSourceEngine(out);
  }

  /// Load every source listed in `sources.index.json` (`{ "sources": [...] }`)
  /// from the bundled assets. An empty / missing index yields an empty engine.
  static Future<KnowledgeSourceEngine> loadFromAssets({
    String indexKey = indexAssetKey,
    String dir = sourcesDir,
    AssetBundle? bundle,
  }) async {
    final b = bundle ?? rootBundle;
    List<String> files;
    try {
      final index = jsonDecode(await b.loadString(indexKey));
      final raw = index is Map<String, dynamic> ? index['sources'] : null;
      files = raw is List ? raw.whereType<String>().toList() : <String>[];
    } catch (_) {
      return KnowledgeSourceEngine(const []);
    }
    final docs = <String>[];
    for (final f in files) {
      try {
        docs.add(await b.loadString('$dir$f'));
      } catch (_) {
        // Listed-but-missing file: skip; coverage simply won't include it.
      }
    }
    return loadAll(docs);
  }

  // ---------------------------------------------------------------------------
  // validation
  // ---------------------------------------------------------------------------

  List<SourceIssue> validate() {
    final issues = <SourceIssue>[];

    // Duplicate source ids — an assertion could not be traced unambiguously.
    final idCounts = <String, int>{};
    for (final s in sources) {
      idCounts[s.id] = (idCounts[s.id] ?? 0) + 1;
    }
    idCounts.forEach((id, n) {
      if (n > 1) {
        issues.add(SourceIssue(
          severity: SourceIssueSeverity.error,
          code: 'duplicate_source',
          message: 'Source id "$id" is used by $n files.',
          sourceId: id,
        ));
      }
    });

    for (final s in sources) {
      final relationsByPair = <String, Set<String>>{};
      final seenTriples = <String>{};
      for (final a in s.assertions) {
        // Broken reference: planet / relation outside the known vocabulary, so
        // the assertion cannot be tied to a real directed relationship.
        final knownPair = kKnowledgeResearchPlanets.contains(a.from) &&
            kKnowledgeResearchPlanets.contains(a.to) &&
            a.from != a.to;
        final knownRelation = kSourceRelations.contains(a.relation);
        if (!knownPair || !knownRelation) {
          issues.add(SourceIssue(
            severity: SourceIssueSeverity.error,
            code: 'broken_reference',
            message:
                'Source "${s.id}" asserts ${a.from}->${a.to}=${a.relation}, '
                'which is not a known relationship.',
            sourceId: s.id,
            pairKey: a.pairKey,
          ));
          continue;
        }

        // Duplicate assertion: same (from,to,relation) repeated in one source.
        final triple = '${a.pairKey}=${a.relation}';
        if (!seenTriples.add(triple)) {
          issues.add(SourceIssue(
            severity: SourceIssueSeverity.warning,
            code: 'duplicate_assertion',
            message: 'Source "${s.id}" repeats ${a.pairKey}=${a.relation}.',
            sourceId: s.id,
            pairKey: a.pairKey,
          ));
        }
        (relationsByPair[a.pairKey] ??= <String>{}).add(a.relation);

        // Missing page / quote — required to keep the assertion citable.
        if (a.page == null) {
          issues.add(SourceIssue(
            severity: SourceIssueSeverity.warning,
            code: 'missing_page',
            message: 'Source "${s.id}" assertion ${a.pairKey} has no page.',
            sourceId: s.id,
            pairKey: a.pairKey,
          ));
        }
        if (a.quote == null) {
          issues.add(SourceIssue(
            severity: SourceIssueSeverity.warning,
            code: 'missing_quote',
            message: 'Source "${s.id}" assertion ${a.pairKey} has no quote.',
            sourceId: s.id,
            pairKey: a.pairKey,
          ));
        }
      }

      // Conflicting assertion: the SAME source asserts two relations for a pair.
      relationsByPair.forEach((pair, relations) {
        if (relations.length > 1) {
          issues.add(SourceIssue(
            severity: SourceIssueSeverity.error,
            code: 'conflicting_assertion',
            message: 'Source "${s.id}" asserts $pair as '
                '${relations.join(' and ')}.',
            sourceId: s.id,
            pairKey: pair,
          ));
        }
      });
    }

    return issues;
  }

  // ---------------------------------------------------------------------------
  // coverage
  // ---------------------------------------------------------------------------

  SourceCoverageReport coverage() => SourceCoverageReport.of(sources);

  static String? _str(Object? v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }
}

/// Source Coverage Report — books, schools, authors, assertions, and how much
/// of the directed-relationship universe the sources cover.
class SourceCoverageReport {
  const SourceCoverageReport({
    required this.books,
    required this.schools,
    required this.authors,
    required this.assertions,
    required this.relationshipsCovered,
    required this.relationshipsMissing,
  });

  factory SourceCoverageReport.of(Iterable<SourceRecord> sources) {
    final schools = <String>{};
    final authors = <String>{};
    final coveredPairs = <String>{};
    var books = 0;
    var assertions = 0;
    for (final s in sources) {
      books++;
      schools.add(s.school);
      authors.add(s.author);
      for (final a in s.assertions) {
        assertions++;
        if (kKnowledgeResearchPlanets.contains(a.from) &&
            kKnowledgeResearchPlanets.contains(a.to) &&
            a.from != a.to &&
            kSourceRelations.contains(a.relation)) {
          coveredPairs.add(a.pairKey);
        }
      }
    }
    final universe = kKnowledgeResearchPlanets.length *
        (kKnowledgeResearchPlanets.length - 1);
    return SourceCoverageReport(
      books: books,
      schools: schools.length,
      authors: authors.length,
      assertions: assertions,
      relationshipsCovered: coveredPairs.length,
      relationshipsMissing: universe - coveredPairs.length,
    );
  }

  final int books;
  final int schools;
  final int authors;
  final int assertions;
  final int relationshipsCovered;
  final int relationshipsMissing;

  int get relationshipUniverse => relationshipsCovered + relationshipsMissing;

  double get coveragePercent => relationshipUniverse == 0
      ? 0
      : relationshipsCovered / relationshipUniverse * 100;

  List<String> toReportLines() => [
        'Thai Astrology — Source Coverage Report',
        'Books                  : $books',
        'Schools                : $schools',
        'Authors                : $authors',
        'Assertions             : $assertions',
        'Relationships covered  : $relationshipsCovered / $relationshipUniverse',
        'Relationships missing  : $relationshipsMissing',
        'Coverage               : ${coveragePercent.toStringAsFixed(1)}%',
      ];
}
