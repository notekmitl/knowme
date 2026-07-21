import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

const String kCanonLibraryManifestAsset = 'knowledge/canon/library.manifest.json';

/// Extraction lifecycle of a whole book within the library.
enum CanonBookExtractionState { notStarted, inProgress, completed }

/// Validation lifecycle of a whole book.
enum CanonBookValidationState { unvalidated, partial, validated, canonApproved }

CanonBookExtractionState _extractionState(String? s) =>
    CanonBookExtractionState.values.firstWhere(
      (v) => v.name == s,
      orElse: () => CanonBookExtractionState.notStarted,
    );

CanonBookValidationState _validationState(String? s) =>
    CanonBookValidationState.values.firstWhere(
      (v) => v.name == s,
      orElse: () => CanonBookValidationState.unvalidated,
    );

/// Progress counters for a book (tracked, not computed from content here).
class CanonBookProgress {
  const CanonBookProgress({
    this.totalChapters = 0,
    this.extractedChapters = 0,
    this.totalSections = 0,
    this.extractedSections = 0,
    this.totalUnits = 0,
    this.approvedUnits = 0,
  });

  final int totalChapters;
  final int extractedChapters;
  final int totalSections;
  final int extractedSections;
  final int totalUnits;
  final int approvedUnits;

  double get sectionProgress =>
      totalSections == 0 ? 0 : extractedSections / totalSections;
  double get approvalProgress => totalUnits == 0 ? 0 : approvedUnits / totalUnits;

  static CanonBookProgress fromMap(Map<String, dynamic> m) => CanonBookProgress(
        totalChapters: _i(m['totalChapters']),
        extractedChapters: _i(m['extractedChapters']),
        totalSections: _i(m['totalSections']),
        extractedSections: _i(m['extractedSections']),
        totalUnits: _i(m['totalUnits']),
        approvedUnits: _i(m['approvedUnits']),
      );
}

/// One book registered in the library: metadata + status + progress + a pointer
/// to its detailed per-book manifest asset (the chapter/section skeleton).
class CanonLibraryBookEntry {
  const CanonLibraryBookEntry({
    required this.bookId,
    required this.sourceId,
    required this.title,
    this.author,
    this.canonical = false,
    this.manifestAsset,
    this.extraction = CanonBookExtractionState.notStarted,
    this.validation = CanonBookValidationState.unvalidated,
    this.version = 1,
    this.progress = const CanonBookProgress(),
    this.notes,
  });

  final String bookId;
  final String sourceId;
  final String title;
  final String? author;

  /// True for the Tier-1 canonical book(s).
  final bool canonical;

  /// Path to the detailed per-book manifest (e.g. `mahabhut.manifest.json`).
  final String? manifestAsset;

  final CanonBookExtractionState extraction;
  final CanonBookValidationState validation;
  final int version;
  final CanonBookProgress progress;
  final String? notes;

  bool get isStarted => extraction != CanonBookExtractionState.notStarted;

  static CanonLibraryBookEntry? fromMap(Map<String, dynamic> m) {
    final bookId = (m['bookId'] as String?)?.trim();
    final sourceId = (m['sourceId'] as String?)?.trim();
    final title = (m['title'] as String?)?.trim();
    if (bookId == null || sourceId == null || title == null) return null;
    return CanonLibraryBookEntry(
      bookId: bookId,
      sourceId: sourceId,
      title: title,
      author: (m['author'] as String?)?.trim(),
      canonical: m['canonical'] == true,
      manifestAsset: (m['manifestAsset'] as String?)?.trim(),
      extraction: _extractionState(m['extraction'] as String?),
      validation: _validationState(m['validation'] as String?),
      version: m['version'] is int ? m['version'] as int : 1,
      progress: m['progress'] is Map<String, dynamic>
          ? CanonBookProgress.fromMap(m['progress'] as Map<String, dynamic>)
          : const CanonBookProgress(),
      notes: (m['notes'] as String?)?.trim(),
    );
  }
}

/// The Manifest System: a registry of canonical books. Built to hold **many**
/// books (not only `หลักมหาภูต`) so future texts enter the system without an
/// architecture change.
class CanonLibraryManifest {
  const CanonLibraryManifest({
    required this.version,
    this.books = const [],
    this.notes,
  });

  final int version;
  final List<CanonLibraryBookEntry> books;
  final String? notes;

  CanonLibraryBookEntry? book(String bookId) {
    for (final b in books) {
      if (b.bookId == bookId) return b;
    }
    return null;
  }

  List<CanonLibraryBookEntry> get canonicalBooks =>
      books.where((b) => b.canonical).toList();

  /// Library-wide section extraction progress (0–1) across all books.
  double get overallProgress {
    var total = 0;
    var done = 0;
    for (final b in books) {
      total += b.progress.totalSections;
      done += b.progress.extractedSections;
    }
    return total == 0 ? 0 : done / total;
  }

  String get summary => books.isEmpty
      ? 'Empty library (no books registered).'
      : '${books.length} book(s), '
          '${canonicalBooks.length} canonical, '
          '${(overallProgress * 100).toStringAsFixed(1)}% sections extracted.';

  static CanonLibraryManifest fromJson(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Library manifest root must be an object.');
    }
    final list = decoded['books'];
    final books = list is List
        ? list
            .whereType<Map<String, dynamic>>()
            .map(CanonLibraryBookEntry.fromMap)
            .whereType<CanonLibraryBookEntry>()
            .toList()
        : <CanonLibraryBookEntry>[];
    return CanonLibraryManifest(
      version: decoded['version'] is int ? decoded['version'] as int : 1,
      books: books,
      notes: (decoded['notes'] as String?)?.trim(),
    );
  }

  static Future<CanonLibraryManifest> loadFromAsset({
    String asset = kCanonLibraryManifestAsset,
  }) async {
    return fromJson(await rootBundle.loadString(asset));
  }
}

int _i(Object? v) => v is int ? v : 0;
