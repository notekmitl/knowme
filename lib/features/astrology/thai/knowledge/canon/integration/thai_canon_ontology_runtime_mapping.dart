import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_attribute_values.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_data.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_entity.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';

import 'thai_canon_period_status_runtime_mapping.dart';
import 'thai_canon_khumsap_runtime_mapping.dart';
import 'thai_canon_taksa_role_runtime_mapping.dart';

/// How a Canon ontology entity maps to an existing runtime identifier.
enum ThaiCanonRuntimeKeyKind {
  lifePlanet,
  thaiContentKey,
  internalMahabhutPosition,
  periodStatusLabel,
  taksaRole,
}

/// One Canon entity → runtime key pairing (or explicit absence).
class ThaiCanonRuntimeMappingEntry {
  const ThaiCanonRuntimeMappingEntry({
    required this.canonEntityId,
    required this.runtimeKey,
    required this.kind,
    this.note,
  });

  const ThaiCanonRuntimeMappingEntry.unmapped({
    required this.canonEntityId,
    this.note,
  })  : runtimeKey = null,
        kind = null;

  final String canonEntityId;
  final String? runtimeKey;
  final ThaiCanonRuntimeKeyKind? kind;
  final String? note;

  bool get isMapped => runtimeKey != null;
}

/// Read-only mapping table between frozen Canon ontology ids and runtime keys.
///
/// Does not invent runtime keys — unmapped entities are reported explicitly.
abstract final class ThaiCanonOntologyRuntimeMapping {
  static const _planetToLifePlanet = <String, LifePlanet>{
    'planet.sun': LifePlanet.sun,
    'planet.moon': LifePlanet.moon,
    'planet.mars': LifePlanet.mars,
    'planet.mercury': LifePlanet.mercury,
    'planet.jupiter': LifePlanet.jupiter,
    'planet.venus': LifePlanet.venus,
    'planet.saturn': LifePlanet.saturn,
    'planet.rahu': LifePlanet.rahu,
  };

  static const _mahabhutToContentKey = <String, String>{
    'mahabhutPosition.thongchai': ThaiContentKeys.mahabhutaThongchai,
    'mahabhutPosition.athibodi': ThaiContentKeys.mahabhutaAdhibodi,
    'mahabhutPosition.marana': ThaiContentKeys.mahabhutaMarana,
    'mahabhutPosition.puti': ThaiContentKeys.mahabhutaPuti,
    'mahabhutPosition.racha': ThaiContentKeys.mahabhutaRachiya,
    'mahabhutPosition.phangkha': ThaiContentKeys.mahabhutaPyadhi,
  };

  static const _contentKeyToMahabhut = <String, String>{
    ThaiContentKeys.mahabhutaThongchai: 'mahabhutPosition.thongchai',
    ThaiContentKeys.mahabhutaAdhibodi: 'mahabhutPosition.athibodi',
    ThaiContentKeys.mahabhutaMarana: 'mahabhutPosition.marana',
    ThaiContentKeys.mahabhutaPuti: 'mahabhutPosition.puti',
    ThaiContentKeys.mahabhutaRachiya: 'mahabhutPosition.racha',
    ThaiContentKeys.mahabhutaPyadhi: 'mahabhutPosition.phangkha',
  };

  /// Canon `planet.*` id → [LifePlanet] enum (runtime life-period key).
  static LifePlanet? lifePlanetForCanonPlanet(String canonPlanetId) =>
      _planetToLifePlanet[canonPlanetId];

  /// Canon `planet.*` id → runtime enum name (`sun`, `moon`, …).
  static String? runtimePlanetKey(String canonPlanetId) =>
      lifePlanetForCanonPlanet(canonPlanetId)?.name;

  /// Canon `mahabhutPosition.*` → runtime key (content key or internal).
  static String? contentKeyForMahabhutPosition(String canonPositionId) {
    if (canonPositionId == ThaiCanonKhumsapRuntimeMapping.canonEntityId) {
      return ThaiCanonKhumsapRuntimeMapping.internalRuntimeKey;
    }
    return _mahabhutToContentKey[canonPositionId];
  }

  /// Runtime mahabhuta / internal position key → Canon position id.
  static String? canonMahabhutForContentKey(String contentKey) {
    final khumsapCanon = ThaiCanonKhumsapRuntimeMapping.canonIdForRuntimeKey(
      contentKey,
    );
    if (khumsapCanon != null) return khumsapCanon;
    return _contentKeyToMahabhut[contentKey];
  }

  /// All explicit planet mappings (mapped + documented unmapped planets).
  static List<ThaiCanonRuntimeMappingEntry> planetMappings() {
    const canonPlanets = [
      'planet.sun',
      'planet.moon',
      'planet.mars',
      'planet.mercury',
      'planet.jupiter',
      'planet.venus',
      'planet.saturn',
      'planet.rahu',
      'planet.ketu',
    ];
    return [
      for (final id in canonPlanets)
        if (_planetToLifePlanet.containsKey(id))
          ThaiCanonRuntimeMappingEntry(
            canonEntityId: id,
            runtimeKey: _planetToLifePlanet[id]!.name,
            kind: ThaiCanonRuntimeKeyKind.lifePlanet,
          )
        else
          ThaiCanonRuntimeMappingEntry.unmapped(
            canonEntityId: id,
            note: 'No LifePlanet runtime key (Canon silent or not in engine)',
          ),
    ];
  }

  /// Mahabhut position mappings — six public content keys + internal Khumsap.
  static List<ThaiCanonRuntimeMappingEntry> mahabhutPositionMappings() {
    final entries = <ThaiCanonRuntimeMappingEntry>[];
    for (final entity in CanonOntologyData.mahabhutPositions) {
      if (entity.id == ThaiCanonKhumsapRuntimeMapping.canonEntityId) {
        entries.addAll(ThaiCanonKhumsapRuntimeMapping.runtimeMappings());
        continue;
      }
      final key = _mahabhutToContentKey[entity.id];
      if (key != null) {
        entries.add(ThaiCanonRuntimeMappingEntry(
          canonEntityId: entity.id,
          runtimeKey: key,
          kind: ThaiCanonRuntimeKeyKind.thaiContentKey,
          note: entity.id == 'mahabhutPosition.phangkha'
              ? 'Canon ภังคะ maps to legacy content key mahabhuta_pyadhi'
              : null,
        ));
      } else {
        entries.add(ThaiCanonRuntimeMappingEntry.unmapped(
          canonEntityId: entity.id,
          note: 'No runtime key',
        ));
      }
    }
    entries.sort((a, b) => a.canonEntityId.compareTo(b.canonEntityId));
    return entries;
  }

  /// Taksa roles — internal metadata keys only (not report copy).
  static List<ThaiCanonRuntimeMappingEntry> taksaRoleMappings() =>
      ThaiCanonTaksaRoleRuntimeMapping.runtimeMappings();

  /// Period rise/fall — exact Thai report labels only.
  static List<ThaiCanonRuntimeMappingEntry> periodStatusMappings() =>
      ThaiCanonPeriodStatusRuntimeMapping.runtimeMappings();

  /// Entities in selected ontology categories with no runtime mapping entry.
  static List<String> unmappedCanonEntityIds({
    Iterable<OntologyCategory>? categories,
  }) {
    final cats = categories ??
        {
          OntologyCategory.taksaRole,
          OntologyCategory.periodStatus,
          OntologyCategory.predictionEffect,
          OntologyCategory.remedy,
          OntologyCategory.remedyItem,
          OntologyCategory.ritualTarget,
          OntologyCategory.rotationIndex,
          OntologyCategory.archetypeChart,
          OntologyCategory.placementDigit,
          OntologyCategory.lookupTable,
          OntologyCategory.attribute,
          OntologyCategory.attributeCategory,
        };

    final unmapped = <String>[];
    for (final entity in _allOntologyEntities()) {
      if (!cats.contains(entity.category)) continue;
      if (_hasRuntimeMapping(entity.id)) continue;
      unmapped.add(entity.id);
    }
    unmapped.sort();
    return unmapped;
  }

  static bool _hasRuntimeMapping(String canonEntityId) {
    if (_planetToLifePlanet.containsKey(canonEntityId)) return true;
    if (_mahabhutToContentKey.containsKey(canonEntityId)) return true;
    if (ThaiCanonPeriodStatusRuntimeMapping.runtimeLabelForCanonId(
          canonEntityId,
        ) !=
        null) {
      return true;
    }
    if (ThaiCanonKhumsapRuntimeMapping.runtimeKeyForCanonId(canonEntityId) !=
        null) {
      return true;
    }
    if (ThaiCanonTaksaRoleRuntimeMapping.runtimeKeyForCanonId(canonEntityId) !=
        null) {
      return true;
    }
    return false;
  }

  static List<CanonicalEntity> _allOntologyEntities() {
    return [
      ...CanonOntologyData.planets,
      ...CanonOntologyData.mahabhutPositions,
      ...CanonOntologyData.taksaRoles,
      ...CanonOntologyData.periodStatuses,
      ...CanonOntologyData.predictionEffects,
      ...CanonOntologyData.remedies,
      ...CanonOntologyData.remedyItems,
      ...CanonOntologyData.ritualTargets,
      ...CanonOntologyData.rotationIndices,
      ...CanonOntologyData.archetypeCharts,
      ...CanonOntologyData.placementDigits,
      ...CanonOntologyData.lookupTables,
      ...CanonOntologyData.attributeCategories,
      ...CanonOntologyAttributeValues.all,
    ];
  }
}
