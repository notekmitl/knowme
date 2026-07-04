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

  static Future<ThaiCanonEvidenceRepository> loadFromAsset() async {
    final load = await ThaiCanonProductionLoader.loadFromAsset();
    return fromLoadResult(load);
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

  int get atomicCount => index.atomicCount;
  int get referenceCellCount => index.referenceCellCount;

  List<String> get unmappedCanonEntityIds =>
      ThaiCanonOntologyRuntimeMapping.unmappedCanonEntityIds();

  List<ThaiCanonRuntimeMappingEntry> get planetMappings =>
      ThaiCanonOntologyRuntimeMapping.planetMappings();

  List<ThaiCanonRuntimeMappingEntry> get mahabhutPositionMappings =>
      ThaiCanonOntologyRuntimeMapping.mahabhutPositionMappings();
}
