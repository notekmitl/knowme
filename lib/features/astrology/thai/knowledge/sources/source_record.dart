/// Thai Astrology — **Source Collection** layer (V7).
///
/// One [SourceRecord] models a single real astrology source (book / manuscript /
/// article) and the relationship **assertions** it makes. The output is
/// knowledge, not software: every assertion keeps the original `quote` and
/// `page` and points back to exactly one source.
///
/// Boundary (enforced by design): this layer has **no dependency on the engine
/// or the `PlanetRelationshipMatrix`**. Planets and relations are plain strings.
library;

/// A single relationship assertion made by a source, e.g. "Venus → Saturn =
/// friend (page 128, '…quote…')".
class SourceAssertion {
  const SourceAssertion({
    required this.from,
    required this.to,
    required this.relation,
    this.page,
    this.quote,
    this.note,
  });

  final String from;
  final String to;

  /// `friend` | `neutral` | `enemy` (recorded exactly as the source states).
  final String relation;

  /// The page / folio the assertion is found on. Required for a citable
  /// assertion — a missing page is a validation issue.
  final String? page;

  /// The original verbatim quote. Never summarize without keeping this — a
  /// missing quote is a validation issue.
  final String? quote;
  final String? note;

  /// Directed pair key, e.g. `venus->saturn`.
  String get pairKey => '$from->$to';
}

/// One real astrology source and its assertions.
class SourceRecord {
  const SourceRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.school,
    required this.language,
    required this.assertions,
    this.edition,
    this.publisher,
    this.year,
    this.isbn,
    this.url,
    this.license,
    this.notes,
  });

  final String id;
  final String title;
  final String author;
  final String? edition;
  final String? publisher;
  final int? year;
  final String language;
  final String school;
  final String? isbn;
  final String? url;
  final String? license;
  final String? notes;
  final List<SourceAssertion> assertions;

  /// A human label for the book (title + edition).
  String get bookLabel {
    final parts = [
      title.trim(),
      if (edition != null && edition!.trim().isNotEmpty) edition!.trim(),
    ];
    return parts.join(' · ');
  }
}
