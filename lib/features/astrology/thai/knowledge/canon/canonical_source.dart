import 'package:knowme/features/astrology/thai/knowledge/canon/knowledge_tier.dart';

/// A registered knowledge source with its [tier]. Every [CanonicalKnowledgeNode]
/// points at one of these by id, so a node's authority is derived from the
/// source registry (single source of truth) rather than self-declared.
///
/// The canonical book `หลักมหาภูต` (ส. หยกฟ้า) is registered at
/// [KnowledgeTier.canon] with [canonical] = true.
class CanonicalSource {
  const CanonicalSource({
    required this.id,
    required this.title,
    required this.tier,
    required this.canonical,
    this.author,
    this.edition,
    this.publisher,
    this.year,
    this.language,
    this.isbn,
    this.url,
    this.notes,
  });

  final String id;
  final String title;
  final KnowledgeTier tier;

  /// `true` only for the Tier-1 canonical source(s). Enforced consistent with
  /// [tier] by the engine (a canonical source must be Tier 1).
  final bool canonical;

  final String? author;
  final String? edition;
  final String? publisher;
  final int? year;
  final String? language;
  final String? isbn;
  final String? url;
  final String? notes;

  bool get isCanon => tier.isCanon && canonical;

  String get label {
    final parts = [
      title.trim(),
      if (author != null && author!.trim().isNotEmpty) '(${author!.trim()})',
    ];
    return parts.join(' ');
  }
}
