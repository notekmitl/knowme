/// Canon Ontology V3 — the canonical entity.
///
/// Every canonical concept (a planet, a domain, a relationship, …) has a stable
/// [id]. Entities are **never** identified by display text; aliases (including
/// other languages) resolve *to* the id. Pure Dart; no Flutter/engine/runtime.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';

enum OntologyEntityStatus {
  active,
  deprecated;

  static OntologyEntityStatus fromName(String? name) {
    for (final s in OntologyEntityStatus.values) {
      if (s.name == name) return s;
    }
    return OntologyEntityStatus.active;
  }
}

class CanonicalEntity {
  const CanonicalEntity({
    required this.id,
    required this.canonicalName,
    required this.category,
    this.aliases = const [],
    this.description,
    this.parentId,
    this.status = OntologyEntityStatus.active,
  });

  /// Stable identifier, `<category>.<slug>` (e.g. `planet.jupiter`).
  final String id;

  /// Canonical English label for display only — not used for identification.
  final String canonicalName;

  final OntologyCategory category;

  /// Other names that resolve to this entity (languages, synonyms). The
  /// canonical name is implicitly an alias too.
  final List<String> aliases;

  /// Structured description only (a short label/phrase), never narrative.
  final String? description;

  /// Optional taxonomy parent (for hierarchical categories such as `domain`).
  final String? parentId;

  final OntologyEntityStatus status;

  bool get isActive => status == OntologyEntityStatus.active;

  /// The category prefix this id should carry, per the id convention.
  String get expectedPrefix => '${category.wire}.';

  bool get hasValidPrefix => id.startsWith(expectedPrefix);

  /// Every surface form that should resolve to this entity (canonical + aliases).
  List<String> get surfaceForms => [canonicalName, ...aliases];

  Map<String, dynamic> toJson() => {
        'id': id,
        'canonicalName': canonicalName,
        'category': category.wire,
        if (aliases.isNotEmpty) 'aliases': aliases,
        if (description != null) 'description': description,
        if (parentId != null) 'parentId': parentId,
        'status': status.name,
      };

  static CanonicalEntity? fromJson(Map<String, dynamic> m) {
    final id = (m['id'] as String?)?.trim();
    final name = (m['canonicalName'] as String?)?.trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) return null;
    return CanonicalEntity(
      id: id,
      canonicalName: name,
      category: OntologyCategory.fromWire(m['category'] as String?),
      aliases: (m['aliases'] as List?)?.whereType<String>().toList() ?? const [],
      description: (m['description'] as String?)?.trim(),
      parentId: (m['parentId'] as String?)?.trim(),
      status: OntologyEntityStatus.fromName(m['status'] as String?),
    );
  }
}
