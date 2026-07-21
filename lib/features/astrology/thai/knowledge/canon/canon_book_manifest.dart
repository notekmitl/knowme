import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

const String kCanonBookManifestAsset = 'knowledge/canon/mahabhut.manifest.json';

/// Whether a book unit has been turned into structured knowledge nodes yet.
enum CanonExtractionStatus { notStarted, inProgress, extracted }

/// A leaf unit of the canonical book — the future home of extracted knowledge.
/// It is a *placeholder*: extraction has not happened yet, but each section can
/// later list the [nodeIds] it produced (linking back to [CanonicalKnowledgeNode]).
class CanonBookSection {
  const CanonBookSection({
    required this.id,
    required this.title,
    this.topic,
    this.pageStart,
    this.pageEnd,
    this.status = CanonExtractionStatus.notStarted,
    this.nodeIds = const [],
  });

  final String id;
  final String title;

  /// Optional hint of the knowledge domain this section feeds
  /// (e.g. `planet_relationship`, `bhava`).
  final String? topic;
  final String? pageStart;
  final String? pageEnd;
  final CanonExtractionStatus status;

  /// Ids of [CanonicalKnowledgeNode]s extracted from this section (empty until
  /// extraction begins).
  final List<String> nodeIds;

  bool get isExtracted => status == CanonExtractionStatus.extracted;
}

class CanonBookChapter {
  const CanonBookChapter({
    required this.id,
    required this.title,
    this.number,
    this.sections = const [],
  });

  final String id;
  final String title;
  final int? number;
  final List<CanonBookSection> sections;
}

class CanonBookPart {
  const CanonBookPart({
    required this.id,
    required this.title,
    this.chapters = const [],
  });

  final String id;
  final String title;
  final List<CanonBookChapter> chapters;
}

/// Extraction-readiness snapshot for the book.
class CanonBookExtractionReport {
  const CanonBookExtractionReport({
    required this.totalSections,
    required this.extractedSections,
    required this.totalNodes,
  });

  final int totalSections;
  final int extractedSections;
  final int totalNodes;

  double get progress =>
      totalSections == 0 ? 0 : extractedSections / totalSections;

  String get summary => totalSections == 0
      ? 'Skeleton only — no sections defined yet.'
      : '$extractedSections/$totalSections section(s) extracted '
          '(${(progress * 100).toStringAsFixed(1)}%), $totalNodes node(s).';
}

/// The structural manifest of the canonical book `หลักมหาภูต` (ส. หยกฟ้า).
///
/// This is the **architecture for future extraction** (Task 5). It holds
/// bibliographic metadata plus a part/chapter/section skeleton. No book content
/// is extracted yet; sections are placeholders whose [CanonBookSection.nodeIds]
/// will be filled when extraction begins.
class CanonBookManifest {
  const CanonBookManifest({
    required this.sourceId,
    required this.title,
    this.author,
    this.edition,
    this.publisher,
    this.year,
    this.language,
    this.isbn,
    this.parts = const [],
    this.notes,
  });

  /// Links the book to its [CanonicalSource] registry entry.
  final String sourceId;
  final String title;
  final String? author;
  final String? edition;
  final String? publisher;
  final int? year;
  final String? language;
  final String? isbn;
  final List<CanonBookPart> parts;
  final String? notes;

  Iterable<CanonBookSection> get allSections sync* {
    for (final p in parts) {
      for (final c in p.chapters) {
        yield* c.sections;
      }
    }
  }

  CanonBookExtractionReport extractionReport() {
    final sections = allSections.toList();
    return CanonBookExtractionReport(
      totalSections: sections.length,
      extractedSections: sections.where((s) => s.isExtracted).length,
      totalNodes: sections.fold(0, (sum, s) => sum + s.nodeIds.length),
    );
  }

  static CanonBookManifest fromJson(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Book manifest root must be an object.');
    }
    return fromMap(decoded);
  }

  static CanonBookManifest fromMap(Map<String, dynamic> m) {
    return CanonBookManifest(
      sourceId: (m['sourceId'] as String?)?.trim() ?? '',
      title: (m['title'] as String?)?.trim() ?? '',
      author: (m['author'] as String?)?.trim(),
      edition: (m['edition'] as String?)?.trim(),
      publisher: (m['publisher'] as String?)?.trim(),
      year: m['year'] is int ? m['year'] as int : null,
      language: (m['language'] as String?)?.trim(),
      isbn: (m['isbn'] as String?)?.trim(),
      notes: (m['notes'] as String?)?.trim(),
      parts: _parts(m['parts']),
    );
  }

  static Future<CanonBookManifest> loadFromAsset({
    String asset = kCanonBookManifestAsset,
  }) async {
    final json = await rootBundle.loadString(asset);
    return fromJson(json);
  }

  static List<CanonBookPart> _parts(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((p) {
      return CanonBookPart(
        id: (p['id'] as String?)?.trim() ?? '',
        title: (p['title'] as String?)?.trim() ?? '',
        chapters: _chapters(p['chapters']),
      );
    }).toList();
  }

  static List<CanonBookChapter> _chapters(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((c) {
      return CanonBookChapter(
        id: (c['id'] as String?)?.trim() ?? '',
        title: (c['title'] as String?)?.trim() ?? '',
        number: c['number'] is int ? c['number'] as int : null,
        sections: _sections(c['sections']),
      );
    }).toList();
  }

  static List<CanonBookSection> _sections(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((s) {
      final statusName = (s['status'] as String?)?.trim();
      final status = CanonExtractionStatus.values.firstWhere(
        (v) => v.name == statusName,
        orElse: () => CanonExtractionStatus.notStarted,
      );
      final nodeIds = (s['nodeIds'] is List)
          ? (s['nodeIds'] as List)
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : <String>[];
      return CanonBookSection(
        id: (s['id'] as String?)?.trim() ?? '',
        title: (s['title'] as String?)?.trim() ?? '',
        topic: (s['topic'] as String?)?.trim(),
        pageStart: (s['pageStart'] as String?)?.trim(),
        pageEnd: (s['pageEnd'] as String?)?.trim(),
        status: status,
        nodeIds: nodeIds,
      );
    }).toList();
  }
}
