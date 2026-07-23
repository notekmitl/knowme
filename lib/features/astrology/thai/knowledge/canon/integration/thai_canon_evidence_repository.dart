import 'package:flutter/foundation.dart';

import 'thai_canon_evidence_index.dart';
import 'thai_canon_evidence_mapper.dart';
import 'thai_canon_ontology_runtime_mapping.dart';
import 'thai_canon_production_loader.dart';

/// Read-only facade: load frozen Canon once, query evidence deterministically.
///
/// Does not touch Thai engines, Mirror, or user-facing layers.
class ThaiCanonEvidenceRepository {
  ThaiCanonEvidenceRepository._({
    required this.loadResult,
    required this.index,
    required this.mapper,
  });

  final ThaiCanonProductionLoadResult loadResult;
  final ThaiCanonEvidenceIndex index;
  final ThaiCanonEvidenceMapper mapper;

  static ThaiCanonEvidenceRepository? _cached;
  static Future<ThaiCanonEvidenceRepository>? _inFlight;

  /// Last successfully loaded repository, if any (sync consumers / presenters).
  static ThaiCanonEvidenceRepository? get cachedOrNull => _cached;

  /// Sync accessor for [cachedOrNull.index].
  static ThaiCanonEvidenceIndex? get cachedIndexOrNull => _cached?.index;

  static Future<ThaiCanonEvidenceRepository> loadFromAsset() async {
    if (_cached != null) return _cached!;
    return _inFlight ??= () async {
      try {
        final load = await ThaiCanonProductionLoader.loadFromAsset();
        final repo = fromLoadResult(load);
        _cached = repo;
        return repo;
      } finally {
        _inFlight = null;
      }
    }();
  }

  static ThaiCanonEvidenceRepository fromLoadResult(
    ThaiCanonProductionLoadResult load,
  ) {
    final index = ThaiCanonEvidenceIndex.fromLoadResult(load);
    return ThaiCanonEvidenceRepository._(
      loadResult: load,
      index: index,
      mapper: ThaiCanonEvidenceMapper(index),
    );
  }

  /// Test-only: bind a repository as the process-wide cache.
  @visibleForTesting
  static void bindCachedForTest(ThaiCanonEvidenceRepository repository) {
    _cached = repository;
    _inFlight = null;
  }

  /// Test-only: clear the process-wide cache.
  @visibleForTesting
  static void clearCachedForTest() {
    _cached = null;
    _inFlight = null;
  }

  int get atomicCount => index.atomicCount;
  int get referenceCellCount => index.referenceCellCount;

  List<String> get unmappedCanonEntityIds =>
      ThaiCanonOntologyRuntimeMapping.unmappedCanonEntityIds();

  List<ThaiCanonRuntimeMappingEntry> get planetMappings =>
      ThaiCanonOntologyRuntimeMapping.planetMappings();

  List<ThaiCanonRuntimeMappingEntry> get mahabhutPositionMappings =>
      ThaiCanonOntologyRuntimeMapping.mahabhutPositionMappings();
}
