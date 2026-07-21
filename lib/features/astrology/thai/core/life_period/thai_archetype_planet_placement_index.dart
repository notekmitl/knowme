import '../../knowledge/canon/atomic/atomic_knowledge_unit.dart';
import '../../knowledge/canon/atomic/atomic_relation.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/ontology/canon_ontology_data.dart';
import 'thai_life_period_context_metadata.dart';

/// Classification of Canon Mahabhut placement evidence for archetype + planet.
enum ArchetypePlanetPlacementClassification {
  uniquePosition,
  missingPosition,
  ambiguousPosition,
  sourceConflict,
  ocrBlocked,
}

extension ArchetypePlanetPlacementClassificationWire
    on ArchetypePlanetPlacementClassification {
  String get wire => switch (this) {
        ArchetypePlanetPlacementClassification.uniquePosition =>
          'UNIQUE_POSITION',
        ArchetypePlanetPlacementClassification.missingPosition =>
          'MISSING_POSITION',
        ArchetypePlanetPlacementClassification.ambiguousPosition =>
          'AMBIGUOUS_POSITION',
        ArchetypePlanetPlacementClassification.sourceConflict =>
          'SOURCE_CONFLICT',
        ArchetypePlanetPlacementClassification.ocrBlocked => 'OCR_BLOCKED',
      };
}

/// Feasibility outcome for archetype + planet position strategy.
enum ArchetypePlanetPositionStrategyFeasibilityResult {
  readyToResolveByArchetypePlanet,
  partialReadyWithAmbiguities,
  blockedByConflicts,
  blockedByModelingGap,
}

extension ArchetypePlanetPositionStrategyFeasibilityResultWire
    on ArchetypePlanetPositionStrategyFeasibilityResult {
  String get wire => switch (this) {
        ArchetypePlanetPositionStrategyFeasibilityResult
              .readyToResolveByArchetypePlanet =>
          'READY_TO_RESOLVE_BY_ARCHETYPE_PLANET',
        ArchetypePlanetPositionStrategyFeasibilityResult
              .partialReadyWithAmbiguities =>
          'PARTIAL_READY_WITH_AMBIGUITIES',
        ArchetypePlanetPositionStrategyFeasibilityResult.blockedByConflicts =>
          'BLOCKED_BY_CONFLICTS',
        ArchetypePlanetPositionStrategyFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// One archetype + planet pair in the placement index.
class ArchetypePlanetPlacementEntry {
  const ArchetypePlanetPlacementEntry({
    required this.archetypeChartCanonId,
    required this.planetCanonId,
    required this.classification,
    required this.units,
    required this.distinctPositions,
  });

  final String archetypeChartCanonId;
  final String planetCanonId;
  final ArchetypePlanetPlacementClassification classification;
  final List<AtomicKnowledgeUnit> units;
  final Set<String> distinctPositions;

  String get pairKey => '$archetypeChartCanonId:$planetCanonId';

  String? get uniquePositionCanonId =>
      classification == ArchetypePlanetPlacementClassification.uniquePosition &&
              distinctPositions.length == 1
          ? distinctPositions.first
          : null;
}

/// Audit of archetype + planet placement index coverage.
class ArchetypePlanetPlacementIndexAudit {
  const ArchetypePlanetPlacementIndexAudit({
    required this.result,
    required this.uniqueCount,
    required this.missingCount,
    required this.ambiguousCount,
    required this.conflictCount,
    required this.ocrBlockedCount,
    required this.totalPairs,
  });

  final ArchetypePlanetPositionStrategyFeasibilityResult result;
  final int uniqueCount;
  final int missingCount;
  final int ambiguousCount;
  final int conflictCount;
  final int ocrBlockedCount;
  final int totalPairs;
}

/// Deterministic Canon placement index: archetypeChartCanonId + planet.
class ThaiArchetypePlanetPlacementIndex {
  ThaiArchetypePlanetPlacementIndex._(this._entries);

  final Map<String, ArchetypePlanetPlacementEntry> _entries;

  static ThaiArchetypePlanetPlacementIndex build(ThaiCanonEvidenceIndex index) {
    final grouped = <String, List<AtomicKnowledgeUnit>>{};

    for (final unit in index.units) {
      if (unit.relation != AtomicRelation.locatedIn) continue;
      if (!unit.object.startsWith('mahabhutPosition.')) continue;
      if (!unit.subject.startsWith('planet.')) continue;

      final archetypeId = _archetypeForUnit(unit);
      if (archetypeId == null) continue;

      final key = '$archetypeId:${unit.subject}';
      grouped.putIfAbsent(key, () => []).add(unit);
    }

    final entries = <String, ArchetypePlanetPlacementEntry>{};
    for (final entry in grouped.entries) {
      final parts = entry.key.split(':');
      final archetypeId = parts[0];
      final planetId = parts[1];
      entries[entry.key] = _classifyEntry(
        archetypeChartCanonId: archetypeId,
        planetCanonId: planetId,
        units: entry.value,
      );
    }

    return ThaiArchetypePlanetPlacementIndex._(entries);
  }

  ArchetypePlanetPlacementEntry? entryFor({
    required String archetypeChartCanonId,
    required String planetCanonId,
  }) =>
      _entries['$archetypeChartCanonId:$planetCanonId'];

  Iterable<ArchetypePlanetPlacementEntry> get entries => _entries.values;

  ArchetypePlanetPlacementIndexAudit audit() {
    var unique = 0;
    var missing = 0;
    var ambiguous = 0;
    var conflict = 0;
    var ocr = 0;

    for (final entry in _entries.values) {
      switch (entry.classification) {
        case ArchetypePlanetPlacementClassification.uniquePosition:
          unique++;
        case ArchetypePlanetPlacementClassification.missingPosition:
          missing++;
        case ArchetypePlanetPlacementClassification.ambiguousPosition:
          ambiguous++;
        case ArchetypePlanetPlacementClassification.sourceConflict:
          conflict++;
        case ArchetypePlanetPlacementClassification.ocrBlocked:
          ocr++;
      }
    }

    final result = _classifyFeasibility(
      unique: unique,
      ambiguous: ambiguous,
      conflict: conflict,
      total: _entries.length,
    );

    return ArchetypePlanetPlacementIndexAudit(
      result: result,
      uniqueCount: unique,
      missingCount: missing,
      ambiguousCount: ambiguous,
      conflictCount: conflict,
      ocrBlockedCount: ocr,
      totalPairs: _entries.length,
    );
  }

  List<String> pairsWithClassification(
    ArchetypePlanetPlacementClassification classification,
  ) =>
      _entries.values
          .where((e) => e.classification == classification)
          .map((e) => e.pairKey)
          .toList()
        ..sort();

  static ArchetypePlanetPlacementEntry _classifyEntry({
    required String archetypeChartCanonId,
    required String planetCanonId,
    required List<AtomicKnowledgeUnit> units,
  }) {
    final sortedUnits = List<AtomicKnowledgeUnit>.from(units)
      ..sort((a, b) => a.id.compareTo(b.id));
    final positions = sortedUnits.map((u) => u.object).toSet();

    if (positions.isEmpty) {
      return ArchetypePlanetPlacementEntry(
        archetypeChartCanonId: archetypeChartCanonId,
        planetCanonId: planetCanonId,
        classification: ArchetypePlanetPlacementClassification.missingPosition,
        units: const [],
        distinctPositions: const {},
      );
    }

    if (positions.length == 1) {
      return ArchetypePlanetPlacementEntry(
        archetypeChartCanonId: archetypeChartCanonId,
        planetCanonId: planetCanonId,
        classification: ArchetypePlanetPlacementClassification.uniquePosition,
        units: sortedUnits,
        distinctPositions: positions,
      );
    }

    final chartScoped = sortedUnits
        .where(
          (u) => u.context?.type == AtomicContextType.archetypeChart,
        )
        .toList();
    final chartPositions =
        chartScoped.map((u) => u.object).toSet();

    if (chartPositions.length > 1) {
      return ArchetypePlanetPlacementEntry(
        archetypeChartCanonId: archetypeChartCanonId,
        planetCanonId: planetCanonId,
        classification: ArchetypePlanetPlacementClassification.sourceConflict,
        units: sortedUnits,
        distinctPositions: positions,
      );
    }

    return ArchetypePlanetPlacementEntry(
      archetypeChartCanonId: archetypeChartCanonId,
      planetCanonId: planetCanonId,
      classification: ArchetypePlanetPlacementClassification.ambiguousPosition,
      units: sortedUnits,
      distinctPositions: positions,
    );
  }

  static ArchetypePlanetPositionStrategyFeasibilityResult _classifyFeasibility({
    required int unique,
    required int ambiguous,
    required int conflict,
    required int total,
  }) {
    if (total == 0 || unique == 0) {
      return ArchetypePlanetPositionStrategyFeasibilityResult
          .blockedByModelingGap;
    }
    if (unique == total) {
      return ArchetypePlanetPositionStrategyFeasibilityResult
          .readyToResolveByArchetypePlanet;
    }
    if (unique > 0 && (ambiguous > 0 || conflict > 0)) {
      return ArchetypePlanetPositionStrategyFeasibilityResult
          .partialReadyWithAmbiguities;
    }
    if (ambiguous + conflict > unique) {
      return ArchetypePlanetPositionStrategyFeasibilityResult
          .blockedByConflicts;
    }
    return ArchetypePlanetPositionStrategyFeasibilityResult
        .partialReadyWithAmbiguities;
  }

  static String? _archetypeForUnit(AtomicKnowledgeUnit unit) {
    final ctx = unit.context;
    if (ctx == null) return null;

    if (ctx.type == AtomicContextType.archetypeChart) {
      return _archetypeIdForChartLabel(ctx.value);
    }

    if (ctx.type == AtomicContextType.lifePeriod) {
      final page = int.tryParse(unit.evidence.page ?? '');
      if (page == null) return null;
      return _archetypeIdForLifePeriodPage(page);
    }

    return null;
  }

  static String? _archetypeIdForLifePeriodPage(int page) {
    for (final entry
        in ThaiArchetypeChartLifePeriodPageRanges.byArchetypeChartId.entries) {
      final range = entry.value;
      if (page >= range.$1 && page <= range.$2) {
        return entry.key;
      }
    }
    return null;
  }

  static String? _archetypeIdForChartLabel(String chartLabel) {
    final normalized = chartLabel.trim();
    if (normalized.startsWith('archetypeChart.')) return normalized;
    for (final entity in CanonOntologyData.archetypeCharts) {
      if (entity.id == normalized) return entity.id;
      for (final alias in entity.aliases) {
        if (alias == normalized) return entity.id;
      }
    }
    return null;
  }
}
