/// Canon Ontology V3 — the Canonical Ontology registry.
///
/// One controlled vocabulary shared by every Canon package. Holds canonical
/// entities, a deterministic alias index, the registered relationship set and a
/// domain taxonomy. No Canon package may invent entity or relationship names
/// outside this ontology.
///
/// Deterministic and pure Dart; no Flutter/engine/runtime/matrix imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_entity.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_validation.dart';

class CanonicalOntology {
  CanonicalOntology._(this._entities, this._relationships)
      : _aliasIndex = _buildAliasIndex(_entities);

  /// Entities keyed by id (insertion-stable for determinism via sorted views).
  final Map<String, CanonicalEntity> _entities;

  /// Registered relationship wire names (the only legal graph relationships).
  final Set<String> _relationships;

  /// Normalized alias → entity id. Built once; deterministic.
  final Map<String, String> _aliasIndex;

  /// Build an ontology. If the same alias maps to more than one entity it is
  /// left **out** of the resolution index (a collision); `validate()` reports it,
  /// so resolution never guesses.
  static CanonicalOntology build({
    required Iterable<CanonicalEntity> entities,
    required Iterable<String> relationships,
  }) {
    final map = <String, CanonicalEntity>{};
    for (final e in entities) {
      // Last-wins on duplicate id at build time; duplicates surface in validate.
      map[e.id] = e;
    }
    return CanonicalOntology._(map, {...relationships});
  }

  // ---- Reads -------------------------------------------------------------

  List<CanonicalEntity> get entities {
    final list = _entities.values.toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  List<String> get relationships {
    final list = _relationships.toList()..sort();
    return list;
  }

  CanonicalEntity? entity(String id) => _entities[id];

  List<CanonicalEntity> entitiesOf(OntologyCategory category) =>
      entities.where((e) => e.category == category).toList();

  // ---- Alias resolution --------------------------------------------------

  /// Normalize a surface form deterministically (trim, collapse spaces, lower).
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  /// Resolve a surface form (any language/synonym) to its canonical entity.
  /// Returns null when unknown or ambiguous — never guesses.
  CanonicalEntity? resolve(String surface) {
    final id = _aliasIndex[normalize(surface)];
    return id == null ? null : _entities[id];
  }

  /// Resolve to the canonical id, or null when unresolved.
  String? resolveId(String surface) => resolve(surface)?.id;

  bool canResolve(String surface) => _aliasIndex.containsKey(normalize(surface));

  // ---- Relationships -----------------------------------------------------

  bool isRegisteredRelationship(String wire) => _relationships.contains(wire);

  /// Of the supplied relationship wires, those NOT registered in the ontology.
  /// Used to prove the knowledge graph can only use registered relationships.
  List<String> unregisteredRelationships(Iterable<String> wires) {
    final out = wires.where((w) => !_relationships.contains(w)).toSet().toList()
      ..sort();
    return out;
  }

  // ---- Taxonomy ----------------------------------------------------------

  List<CanonicalEntity> childrenOf(String parentId) =>
      entities.where((e) => e.parentId == parentId).toList();

  /// Ancestor ids from nearest parent to root. Stops on a cycle (defensive).
  List<String> ancestorsOf(String id) {
    final out = <String>[];
    final seen = <String>{id};
    var current = _entities[id]?.parentId;
    while (current != null && _entities.containsKey(current)) {
      if (!seen.add(current)) break; // cycle guard
      out.add(current);
      current = _entities[current]?.parentId;
    }
    return out;
  }

  /// True when no entity is its own ancestor (taxonomy is acyclic).
  bool get taxonomyIsAcyclic {
    for (final e in _entities.values) {
      if (_hasCycleFrom(e.id)) return false;
    }
    return true;
  }

  bool _hasCycleFrom(String id) {
    final seen = <String>{};
    var current = id;
    while (true) {
      if (!seen.add(current)) return true;
      final parent = _entities[current]?.parentId;
      if (parent == null || !_entities.containsKey(parent)) return false;
      current = parent;
    }
  }

  // ---- Validation --------------------------------------------------------

  /// Deterministic validation. Detects duplicate ids, duplicate aliases / alias
  /// collisions, unregistered relationships, category/id-prefix mismatches,
  /// orphan parent references and taxonomy cycles.
  OntologyValidationReport validate({Iterable<CanonicalEntity>? rawEntities}) {
    final issues = <OntologyIssue>[];
    void err(String code, String msg, {String? ref}) =>
        issues.add(OntologyIssue(OntologyIssueSeverity.error, code, msg, ref: ref));
    void warn(String code, String msg, {String? ref}) => issues
        .add(OntologyIssue(OntologyIssueSeverity.warning, code, msg, ref: ref));

    // Duplicate ids (only detectable from the raw list, since the map dedupes).
    final source = (rawEntities ?? _entities.values).toList();
    final idCounts = <String, int>{};
    for (final e in source) {
      idCounts[e.id] = (idCounts[e.id] ?? 0) + 1;
    }
    for (final entry in idCounts.entries) {
      if (entry.value > 1) {
        err('duplicate_id', 'Entity id appears ${entry.value} times.',
            ref: entry.key);
      }
    }

    // Alias collisions / duplicate aliases across entities.
    final aliasOwners = <String, Set<String>>{};
    for (final e in source) {
      for (final surface in e.surfaceForms) {
        final key = normalize(surface);
        if (key.isEmpty) continue;
        aliasOwners.putIfAbsent(key, () => <String>{}).add(e.id);
      }
    }
    for (final entry in aliasOwners.entries) {
      if (entry.value.length > 1) {
        final owners = entry.value.toList()..sort();
        err('alias_collision',
            'Alias "${entry.key}" maps to ${owners.length} entities: ${owners.join(', ')}.',
            ref: entry.key);
      }
    }

    // Per-entity checks.
    for (final e in _entities.values) {
      // Category / id-prefix mismatch.
      if (!e.hasValidPrefix) {
        err('category_mismatch',
            'Id "${e.id}" does not match category "${e.category.wire}" (expected prefix "${e.expectedPrefix}").',
            ref: e.id);
      }
      // Relationship entities must be registered relationships.
      if (e.category == OntologyCategory.relationship) {
        final wire = e.id.startsWith('relationship.')
            ? e.id.substring('relationship.'.length)
            : e.id;
        if (!_relationships.contains(wire)) {
          err('relationship_not_registered',
              'Relationship entity "${e.id}" has no registered wire "$wire".',
              ref: e.id);
        }
      }
      // Orphan parent reference.
      if (e.parentId != null && !_entities.containsKey(e.parentId)) {
        err('orphan_entity',
            'Entity "${e.id}" references missing parent "${e.parentId}".',
            ref: e.id);
      }
      // Deprecated entity still used as a parent.
      if (e.parentId != null) {
        final parent = _entities[e.parentId];
        if (parent != null && !parent.isActive) {
          warn('deprecated_parent',
              'Entity "${e.id}" has deprecated parent "${e.parentId}".',
              ref: e.id);
        }
      }
    }

    // Taxonomy cycles.
    if (!taxonomyIsAcyclic) {
      err('taxonomy_cycle', 'Domain taxonomy contains a cycle.');
    }

    issues.sort((a, b) => a.signature.compareTo(b.signature));
    return OntologyValidationReport(issues);
  }

  // ---- Internals ---------------------------------------------------------

  static Map<String, String> _buildAliasIndex(
      Map<String, CanonicalEntity> entities) {
    // First pass: count owners per normalized surface form.
    final owners = <String, Set<String>>{};
    for (final e in entities.values) {
      for (final surface in e.surfaceForms) {
        final key = normalize(surface);
        if (key.isEmpty) continue;
        owners.putIfAbsent(key, () => <String>{}).add(e.id);
      }
    }
    // Second pass: index only unambiguous aliases (collisions stay unresolved).
    final index = <String, String>{};
    for (final entry in owners.entries) {
      if (entry.value.length == 1) {
        index[entry.key] = entry.value.first;
      }
    }
    return index;
  }
}
