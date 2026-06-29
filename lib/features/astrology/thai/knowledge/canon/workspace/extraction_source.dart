/// Canon Knowledge Extraction Workspace V4 — source page tracking.
///
/// Provenance only. The workspace records *where* knowledge came from (book /
/// edition / chapter / page range / reviewer / date / progress). It never stores
/// copyrighted paragraphs as Canon (D-057).
///
/// Pure Dart leaf — no Flutter/engine/runtime/matrix imports.
library;

class ExtractionSource {
  const ExtractionSource({
    required this.bookId,
    this.edition,
    this.chapter,
    this.pageStart,
    this.pageEnd,
    this.reviewer,
    this.extractionDate,
    this.pagesPlanned,
    this.pagesDone,
  });

  final String bookId;
  final String? edition;
  final String? chapter;
  final int? pageStart;
  final int? pageEnd;
  final String? reviewer;

  /// ISO-8601 date string (date only). Provenance metadata, deterministic.
  final String? extractionDate;

  /// Optional progress tracking (pages planned vs done for this session scope).
  final int? pagesPlanned;
  final int? pagesDone;

  /// Deterministic progress fraction in [0, 1]; 0 when unknown.
  double get progress {
    final planned = pagesPlanned ?? 0;
    final done = pagesDone ?? 0;
    if (planned <= 0) return 0;
    final p = done / planned;
    return p < 0 ? 0 : (p > 1 ? 1 : p);
  }

  /// A book *reference* is present (page range or chapter), per the provenance
  /// policy — never a stored quote.
  bool get hasReference =>
      pageStart != null ||
      pageEnd != null ||
      (chapter != null && chapter!.trim().isNotEmpty);

  String get pageRangeLabel {
    if (pageStart == null && pageEnd == null) return '';
    if (pageEnd == null || pageEnd == pageStart) return 'p.$pageStart';
    return 'pp.$pageStart-$pageEnd';
  }

  ExtractionSource copyWith({int? pagesDone}) => ExtractionSource(
        bookId: bookId,
        edition: edition,
        chapter: chapter,
        pageStart: pageStart,
        pageEnd: pageEnd,
        reviewer: reviewer,
        extractionDate: extractionDate,
        pagesPlanned: pagesPlanned,
        pagesDone: pagesDone ?? this.pagesDone,
      );

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        if (edition != null) 'edition': edition,
        if (chapter != null) 'chapter': chapter,
        if (pageStart != null) 'pageStart': pageStart,
        if (pageEnd != null) 'pageEnd': pageEnd,
        if (reviewer != null) 'reviewer': reviewer,
        if (extractionDate != null) 'extractionDate': extractionDate,
        if (pagesPlanned != null) 'pagesPlanned': pagesPlanned,
        if (pagesDone != null) 'pagesDone': pagesDone,
      };

  static ExtractionSource? fromJson(Map<String, dynamic> m) {
    final bookId = (m['bookId'] as String?)?.trim();
    if (bookId == null || bookId.isEmpty) return null;
    return ExtractionSource(
      bookId: bookId,
      edition: (m['edition'] as String?)?.trim(),
      chapter: (m['chapter'] as String?)?.trim(),
      pageStart: m['pageStart'] as int?,
      pageEnd: m['pageEnd'] as int?,
      reviewer: (m['reviewer'] as String?)?.trim(),
      extractionDate: (m['extractionDate'] as String?)?.trim(),
      pagesPlanned: m['pagesPlanned'] as int?,
      pagesDone: m['pagesDone'] as int?,
    );
  }
}
