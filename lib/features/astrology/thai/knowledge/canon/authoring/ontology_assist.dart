/// Canon Knowledge Authoring Studio V1 — ontology assistance.
///
/// While authoring, every subject/object is classified against the Canonical
/// Ontology as Resolved, Unknown or MissingOntology. The studio **never**
/// auto-creates ontology entries — the reviewer must resolve every unknown
/// before validation. Deterministic; pure Dart.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/authoring/draft_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';

enum EntityResolution {
  /// Resolves to a canonical entity (by id or alias).
  resolved,

  /// Looks like a canonical id (`<knownCategory>.<slug>`) but the entity is not
  /// in the ontology yet — a missing ontology entry to add first.
  missingOntology,

  /// Does not resolve and is not a recognizable canonical id — the reviewer must
  /// map or rename it.
  unknown,
}

class FieldAssist {
  const FieldAssist(this.field, this.token, this.resolution, {this.entityId});

  final String field; // 'subject' | 'object'
  final String token;
  final EntityResolution resolution;
  final String? entityId;

  bool get isResolved => resolution == EntityResolution.resolved;
}

class DraftAssist {
  const DraftAssist(this.draftId, this.subject, this.object);

  final String draftId;
  final FieldAssist subject;
  final FieldAssist object;

  bool get isResolved => subject.isResolved && object.isResolved;

  List<FieldAssist> get unresolved =>
      [subject, object].where((f) => !f.isResolved).toList();
}

abstract final class OntologyAssist {
  /// Classify a single token against the ontology. Deterministic.
  static FieldAssist classify(
    CanonicalOntology ontology,
    String field,
    String token,
  ) {
    final trimmed = token.trim();
    final byId = ontology.entity(trimmed);
    if (byId != null) {
      return FieldAssist(field, trimmed, EntityResolution.resolved,
          entityId: byId.id);
    }
    final resolved = ontology.resolve(trimmed);
    if (resolved != null) {
      return FieldAssist(field, trimmed, EntityResolution.resolved,
          entityId: resolved.id);
    }
    if (_looksLikeCanonicalId(trimmed)) {
      return FieldAssist(field, trimmed, EntityResolution.missingOntology);
    }
    return FieldAssist(field, trimmed, EntityResolution.unknown);
  }

  /// Assist for one draft (subject + object).
  static DraftAssist forDraft(
          CanonicalOntology ontology, DraftKnowledgeUnit d) =>
      DraftAssist(
        d.id,
        classify(ontology, 'subject', d.subject),
        classify(ontology, 'object', d.object),
      );

  /// Assist for every draft, in order.
  static List<DraftAssist> forDrafts(
          CanonicalOntology ontology, Iterable<DraftKnowledgeUnit> drafts) =>
      [for (final d in drafts) forDraft(ontology, d)];

  /// True when every subject/object across [drafts] resolves to the ontology.
  static bool allResolved(
          CanonicalOntology ontology, Iterable<DraftKnowledgeUnit> drafts) =>
      forDrafts(ontology, drafts).every((a) => a.isResolved);

  /// `<knownCategory>.<slug>` — used to flag a missing ontology entry vs. a
  /// genuinely unknown free-text token.
  static bool _looksLikeCanonicalId(String token) {
    final dot = token.indexOf('.');
    if (dot <= 0 || dot >= token.length - 1) return false;
    final prefix = token.substring(0, dot);
    for (final c in OntologyCategory.values) {
      if (c != OntologyCategory.other && c.wire == prefix) return true;
    }
    return false;
  }
}
