/// Canon Golden Dataset V1 — dataset model.
///
/// A `GoldenDataset` is a **synthetic QA fixture**, never production knowledge and
/// never copyrighted book text. Each dataset declares the exact outcome the Canon
/// pipeline (Workspace validation → diff → review → import → completeness) must
/// reproduce. It is the regression contract for the Canon Platform.
///
/// Pure Dart over the atomic + ontology + workspace layers (read-only). No
/// engine/runtime/matrix/mirror/fusion dependency.
library;

import 'dart:convert';

import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/extraction_source.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_extraction_session.dart';

/// What the fixture is designed to exercise.
enum GoldenSourceType {
  /// A well-formed corpus that must validate and import cleanly.
  syntheticValid,

  /// An intentionally malformed corpus that must be blocked (a negative test).
  syntheticInvalid,
}

/// The expected, deterministic outcome of running [GoldenDataset] through the
/// Canon pipeline. This is the regression contract.
class GoldenExpectation {
  const GoldenExpectation({
    required this.unitCount,
    required this.allResolved,
    required this.graphNodes,
    required this.graphEdges,
    required this.valid,
    required this.errorCodes,
    required this.diff,
    required this.readyForImport,
    required this.totalUnitsDelta,
    required this.verifiedRelationshipsDelta,
  });

  /// Expected knowledge units (the incoming session).
  final int unitCount;

  /// Expected ontology coverage: every subject/object resolves.
  final bool allResolved;

  /// Expected graph shape.
  final int graphNodes;
  final int graphEdges;

  /// Expected validation result.
  final bool valid;
  final Set<String> errorCodes;

  /// Expected import result.
  final Map<DiffKind, int> diff;
  final bool readyForImport;

  /// Expected completeness change.
  final int totalUnitsDelta;
  final int verifiedRelationshipsDelta;

  int diffCount(DiffKind kind) => diff[kind] ?? 0;

  Map<String, dynamic> toJson() => {
        'unitCount': unitCount,
        'allResolved': allResolved,
        'graphNodes': graphNodes,
        'graphEdges': graphEdges,
        'valid': valid,
        'errorCodes': (errorCodes.toList()..sort()),
        'diff': {
          for (final k in DiffKind.values)
            if (diffCount(k) != 0) k.name: diffCount(k),
        },
        'readyForImport': readyForImport,
        'totalUnitsDelta': totalUnitsDelta,
        'verifiedRelationshipsDelta': verifiedRelationshipsDelta,
      };
}

class GoldenDataset {
  GoldenDataset({
    required this.id,
    required this.description,
    required this.version,
    required this.sourceType,
    required this.source,
    required this.units,
    required this.expected,
    this.baseline = const [],
    CanonicalOntology? ontology,
  }) : _ontology = ontology;

  final String id;
  final String description;
  final int version;
  final GoldenSourceType sourceType;
  final ExtractionSource source;

  /// The incoming session units (the page being imported).
  final List<AtomicKnowledgeUnit> units;

  /// The existing Canon baseline this session is diffed against.
  final List<AtomicKnowledgeUnit> baseline;

  final GoldenExpectation expected;

  final CanonicalOntology? _ontology;

  /// The ontology the dataset resolves against. Most use the standard ontology;
  /// negative fixtures may supply a custom one (e.g. missing a relationship) — we
  /// never mutate the shared ontology to create a failure.
  CanonicalOntology ontology() => _ontology ?? CanonOntologyData.standard();

  /// A fresh session (always Draft) built from the dataset units.
  KnowledgeExtractionSession session() => KnowledgeExtractionSession(
        id: id,
        source: source,
        units: [...units],
      );

  /// Deterministic version tag.
  String get versionTag => '$id@v$version';

  /// Deterministic content fingerprint (FNV-1a over canonical JSON). Identical
  /// dataset definitions always produce the identical fingerprint; any change to
  /// units/baseline/expected/version changes it.
  String get fingerprint => _fnv1a(_canonical());

  String _canonical() => jsonEncode({
        'id': id,
        'version': version,
        'sourceType': sourceType.name,
        'source': source.toJson(),
        'baseline': [for (final u in baseline) u.toJson()],
        'units': [for (final u in units) u.toJson()],
        'expected': expected.toJson(),
      });

  static String _fnv1a(String s) {
    const int prime = 0x01000193;
    var hash = 0x811c9dc5;
    for (final c in s.codeUnits) {
      hash ^= c;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
