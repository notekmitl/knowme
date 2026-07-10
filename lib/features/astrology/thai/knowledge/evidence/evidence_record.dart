/// Thai Astrology — **Evidence** layer (V4).
///
/// An [EvidenceRecord] is a single, citable source of truth (a book, manuscript,
/// article, website, …). Research records no longer own bibliographic fields;
/// they reference evidence by id (`evidenceIds`). This removes duplication: one
/// evidence record can back many research records, and one research record can
/// reference many evidence records.
///
/// Like the rest of the knowledge layer, this has **no dependency on the engine
/// or the PlanetRelationshipMatrix**.
library;

/// Editorial review state of an evidence record.
enum EvidenceReviewStatus { draft, reviewed, verified, disputed, deprecated }

/// A single citable source.
class EvidenceRecord {
  const EvidenceRecord({
    required this.id,
    required this.sourceType,
    required this.school,
    required this.author,
    required this.book,
    required this.language,
    required this.reviewStatus,
    this.edition,
    this.publisher,
    this.year,
    this.page,
    this.quote,
    this.summary,
    this.url,
    this.license,
    this.reviewer,
    this.createdAt,
    this.updatedAt,
    this.notes,
  });

  final String id;

  /// e.g. `book`, `manuscript`, `article`, `website`, `oral`.
  final String sourceType;
  final String school;
  final String author;
  final String book;
  final String? edition;
  final String? publisher;
  final int? year;
  final String? page;
  final String language;
  final String? quote;

  /// A short paraphrase of what the source says.
  final String? summary;
  final String? url;
  final String? license;
  final EvidenceReviewStatus reviewStatus;
  final String? reviewer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;

  bool get isVerified => reviewStatus == EvidenceReviewStatus.verified;

  /// A human label for the source (book + edition).
  String get sourceLabel {
    final parts = [
      book.trim(),
      if (edition != null && edition!.trim().isNotEmpty) edition!.trim(),
    ];
    return parts.join(' · ');
  }
}
