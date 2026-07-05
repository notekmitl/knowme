import '../../content/models/thai_content_key.dart';
import '../../foundation/models/thai_astrology_profile.dart';
import '../../foundation/models/thai_birth_data.dart';
import '../../knowledge/canon/atomic/atomic_relation.dart';
import '../../knowledge/canon/canonical_knowledge_node.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/ontology/canon_ontology_data.dart';
import 'thai_remainder_runtime_metadata.dart';

/// Feasibility outcome for archetype chart context metadata.
enum ArchetypeContextMetadataFeasibilityResult {
  readyToExposeMetadata,
  needsRemainderMetadata,
  needsCanonArchetypeMapping,
}

extension ArchetypeContextMetadataFeasibilityResultWire
    on ArchetypeContextMetadataFeasibilityResult {
  String get wire => switch (this) {
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata =>
          'READY_TO_EXPOSE_METADATA',
        ArchetypeContextMetadataFeasibilityResult.needsRemainderMetadata =>
          'NEEDS_REMAINDER_METADATA',
        ArchetypeContextMetadataFeasibilityResult.needsCanonArchetypeMapping =>
          'NEEDS_CANON_ARCHETYPE_MAPPING',
      };
}

/// Canon remainder→archetype mapping audit classification.
enum ArchetypeContextMappingFeasibilityResult {
  readyToExposeArchetypeContext,
  needsPostFreezeCanonPatch,
  blockedBySourceGap,
  blockedByOntologyGap,
  blockedByModelingGap,
}

extension ArchetypeContextMappingFeasibilityResultWire
    on ArchetypeContextMappingFeasibilityResult {
  String get wire => switch (this) {
        ArchetypeContextMappingFeasibilityResult
              .readyToExposeArchetypeContext =>
          'READY_TO_EXPOSE_ARCHETYPE_CONTEXT',
        ArchetypeContextMappingFeasibilityResult.needsPostFreezeCanonPatch =>
          'NEEDS_POST_FREEZE_CANON_PATCH',
        ArchetypeContextMappingFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        ArchetypeContextMappingFeasibilityResult.blockedByOntologyGap =>
          'BLOCKED_BY_ONTOLOGY_GAP',
        ArchetypeContextMappingFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker codes when archetype context metadata cannot be exposed.
abstract final class ArchetypeContextMetadataBlocker {
  static const needsRemainderMetadata = 'NEEDS_REMAINDER_METADATA';
  static const needsCanonArchetypeMapping = 'NEEDS_CANON_ARCHETYPE_MAPPING';
}

/// Post-freeze patch unit id for remainder6 → nakwichakan (Source Forensics 5ee43b7).
abstract final class ThaiArchetypeContextPostFreezePatch001 {
  static const remainder6ChartUnitId = 'mahabhut.p19.remainder_6_chart';
  static const sourceForensicsRef = 'p19.map.remainder6';
}

/// Internal archetype chart identity (Canon id only — not user-facing copy).
class ThaiArchetypeContextMetadata {
  const ThaiArchetypeContextMetadata({
    required this.archetypeChartCanonId,
    required this.rotationIndexCanonId,
    required this.remainderValue,
    required this.mappingEvidenceUnitId,
    required this.source,
    this.sourcePage,
    this.confidence = 'deterministic',
  });

  final String archetypeChartCanonId;
  final String rotationIndexCanonId;
  final int remainderValue;
  final String mappingEvidenceUnitId;
  final String source;
  final String? sourcePage;
  final String confidence;
}

/// Legacy alias — prefer [ThaiArchetypeContextMetadata].
typedef ArchetypeChartContextMetadata = ThaiArchetypeContextMetadata;

/// Frozen p19 remainder → archetype chart mappings (0–6).
abstract final class ThaiArchetypeContextP19Rules {
  static const remainderToArchetypeChart = {
    'rotationIndex.remainder0': 'archetypeChart.mahasethi',
    'rotationIndex.remainder1': 'archetypeChart.kamphra',
    'rotationIndex.remainder2': 'archetypeChart.naksas',
    'rotationIndex.remainder3': 'archetypeChart.nakbarihan',
    'rotationIndex.remainder4': 'archetypeChart.manussachaosamran',
    'rotationIndex.remainder5': 'archetypeChart.sethi',
    'rotationIndex.remainder6': 'archetypeChart.nakwichakan',
  };

  static const allArchetypeChartIds = {
    'archetypeChart.kamphra',
    'archetypeChart.naksas',
    'archetypeChart.nakbarihan',
    'archetypeChart.manussachaosamran',
    'archetypeChart.sethi',
    'archetypeChart.nakwichakan',
    'archetypeChart.mahasethi',
  };

  static const allRemainderIds = {
    'rotationIndex.remainder0',
    'rotationIndex.remainder1',
    'rotationIndex.remainder2',
    'rotationIndex.remainder3',
    'rotationIndex.remainder4',
    'rotationIndex.remainder5',
    'rotationIndex.remainder6',
  };
}

class ThaiArchetypeContextMappingAudit {
  const ThaiArchetypeContextMappingAudit({
    required this.result,
    required this.mappedRemainderIds,
    required this.missingRemainderIds,
    required this.missingArchetypeChartIds,
    required this.mappingUnitIdsByRemainder,
  });

  final ArchetypeContextMappingFeasibilityResult result;
  final Set<String> mappedRemainderIds;
  final Set<String> missingRemainderIds;
  final Set<String> missingArchetypeChartIds;
  final Map<String, String> mappingUnitIdsByRemainder;

  bool get isComplete =>
      result == ArchetypeContextMappingFeasibilityResult
          .readyToExposeArchetypeContext;
}

/// Deterministic mapping registry — reads frozen Canon lookup-table units only.
abstract final class ThaiArchetypeContextMappingRegistry {
  static ThaiArchetypeContextMappingAudit audit({
    ThaiCanonEvidenceIndex? index,
  }) {
    final mappingUnitIds = <String, String>{};
    final mappedRemainders = <String>{};
    final mappedArchetypes = <String>{};

    if (index != null) {
      for (final unit in index.units) {
        if (unit.relation != AtomicRelation.relatesTo) continue;
        if (unit.domain != KnowledgeDomain.lookupTables) continue;
        if (!ThaiArchetypeContextP19Rules.allRemainderIds.contains(unit.subject)) {
          continue;
        }
        if (!unit.object.startsWith('archetypeChart.')) continue;
        mappingUnitIds[unit.subject] = unit.id;
        mappedRemainders.add(unit.subject);
        mappedArchetypes.add(unit.object);
      }
    } else {
      for (final entry in ThaiArchetypeContextP19Rules.remainderToArchetypeChart.entries) {
        mappingUnitIds[entry.key] = _staticUnitIdForRemainder(entry.key);
        mappedRemainders.add(entry.key);
        mappedArchetypes.add(entry.value);
      }
    }

    final missingRemainders = ThaiArchetypeContextP19Rules.allRemainderIds
        .where((id) => !mappedRemainders.contains(id))
        .toSet();
    final missingArchetypes = ThaiArchetypeContextP19Rules.allArchetypeChartIds
        .where((id) => !mappedArchetypes.contains(id))
        .toSet();

    for (final remainderId in ThaiArchetypeContextP19Rules.allRemainderIds) {
      final value = remainderId.replaceFirst('rotationIndex.remainder', '');
      final entityId = 'rotationIndex.remainder$value';
      if (!CanonOntologyData.rotationIndices.any((e) => e.id == entityId)) {
        return ThaiArchetypeContextMappingAudit(
          result: ArchetypeContextMappingFeasibilityResult.blockedByOntologyGap,
          mappedRemainderIds: mappedRemainders,
          missingRemainderIds: missingRemainders,
          missingArchetypeChartIds: missingArchetypes,
          mappingUnitIdsByRemainder: mappingUnitIds,
        );
      }
    }
    for (final chartId in ThaiArchetypeContextP19Rules.allArchetypeChartIds) {
      if (!CanonOntologyData.archetypeCharts.any((e) => e.id == chartId)) {
        return ThaiArchetypeContextMappingAudit(
          result: ArchetypeContextMappingFeasibilityResult.blockedByOntologyGap,
          mappedRemainderIds: mappedRemainders,
          missingRemainderIds: missingRemainders,
          missingArchetypeChartIds: missingArchetypes,
          mappingUnitIdsByRemainder: mappingUnitIds,
        );
      }
    }

    if (missingRemainders.isEmpty && missingArchetypes.isEmpty) {
      return ThaiArchetypeContextMappingAudit(
        result: ArchetypeContextMappingFeasibilityResult
            .readyToExposeArchetypeContext,
        mappedRemainderIds: mappedRemainders,
        missingRemainderIds: missingRemainders,
        missingArchetypeChartIds: missingArchetypes,
        mappingUnitIdsByRemainder: mappingUnitIds,
      );
    }

    if (missingRemainders.length == 1 &&
        missingRemainders.contains('rotationIndex.remainder6') &&
        missingArchetypes.length <= 1 &&
        (missingArchetypes.isEmpty ||
            missingArchetypes.contains('archetypeChart.nakwichakan'))) {
      return ThaiArchetypeContextMappingAudit(
        result: ArchetypeContextMappingFeasibilityResult
            .needsPostFreezeCanonPatch,
        mappedRemainderIds: mappedRemainders,
        missingRemainderIds: missingRemainders,
        missingArchetypeChartIds: missingArchetypes,
        mappingUnitIdsByRemainder: mappingUnitIds,
      );
    }

    return ThaiArchetypeContextMappingAudit(
      result: ArchetypeContextMappingFeasibilityResult.blockedBySourceGap,
      mappedRemainderIds: mappedRemainders,
      missingRemainderIds: missingRemainders,
      missingArchetypeChartIds: missingArchetypes,
      mappingUnitIdsByRemainder: mappingUnitIds,
    );
  }

  static String _staticUnitIdForRemainder(String remainderId) {
    return switch (remainderId) {
      'rotationIndex.remainder0' => 'mahabhut.p19.remainder_0_chart',
      'rotationIndex.remainder1' => 'mahabhut.p19.remainder_1_chart',
      'rotationIndex.remainder2' => 'mahabhut.p19.remainder_2_chart',
      'rotationIndex.remainder3' => 'mahabhut.p19.remainder_3_chart',
      'rotationIndex.remainder4' => 'mahabhut.p19.remainder_4_chart',
      'rotationIndex.remainder5' => 'mahabhut.p19.remainder_5_chart',
      'rotationIndex.remainder6' =>
        ThaiArchetypeContextPostFreezePatch001.remainder6ChartUnitId,
      _ => throw ArgumentError('unknown remainder id: $remainderId'),
    };
  }
}

class ThaiArchetypeContextResolution {
  const ThaiArchetypeContextResolution({
    this.metadata,
    this.blocker,
  });

  final ThaiArchetypeContextMetadata? metadata;
  final String? blocker;
}

/// Deterministic resolver — maps [ThaiRemainderMetadata] to archetype chart id.
///
/// Does not infer from [ThaiContentKeys.mahabhutaThaya], section copy, or
/// [mahabhutPosition.khumsap].
abstract final class ThaiArchetypeContextResolver {
  static ThaiArchetypeContextResolution resolve({
    ThaiRemainderMetadata? remainderMetadata,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (remainderMetadata == null) {
      return const ThaiArchetypeContextResolution(
        blocker: ArchetypeContextMetadataBlocker.needsRemainderMetadata,
      );
    }

    final mappingAudit = ThaiArchetypeContextMappingRegistry.audit(
      index: canonIndex,
    );
    if (!mappingAudit.isComplete) {
      return const ThaiArchetypeContextResolution(
        blocker: ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
    }

    final remainderId = remainderMetadata.rotationIndexCanonId;
    final unitId = mappingAudit.mappingUnitIdsByRemainder[remainderId];
    final archetypeId =
        ThaiArchetypeContextP19Rules.remainderToArchetypeChart[remainderId];

    if (unitId == null || archetypeId == null) {
      return const ThaiArchetypeContextResolution(
        blocker: ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      );
    }

    final source = unitId == ThaiArchetypeContextPostFreezePatch001.remainder6ChartUnitId
        ? 'source_forensics_patch'
        : 'canon_structural';

    return ThaiArchetypeContextResolution(
      metadata: ThaiArchetypeContextMetadata(
        archetypeChartCanonId: archetypeId,
        rotationIndexCanonId: remainderId,
        remainderValue: remainderMetadata.value,
        mappingEvidenceUnitId: unitId,
        source: source,
        sourcePage: remainderMetadata.sourcePage,
        confidence: 'deterministic',
      ),
    );
  }
}

/// Deterministic feasibility audit — read-only, no Canon mutation.
class ThaiArchetypeContextMetadataFeasibilityAudit {
  const ThaiArchetypeContextMetadataFeasibilityAudit({
    required this.result,
    required this.hasRotationRemainderOnRuntime,
    required this.hasArchetypeChartCanonIdOnRuntime,
    required this.canonRemainderToArchetypeMappingComplete,
    required this.usesMahabhutaThayaAsProxy,
    required this.remainderFeasibility,
    required this.mappingAudit,
  });

  final ArchetypeContextMetadataFeasibilityResult result;
  final bool hasRotationRemainderOnRuntime;
  final bool hasArchetypeChartCanonIdOnRuntime;
  final bool canonRemainderToArchetypeMappingComplete;
  final bool usesMahabhutaThayaAsProxy;
  final ThaiRemainderRuntimeMetadataFeasibilityAudit remainderFeasibility;
  final ThaiArchetypeContextMappingAudit mappingAudit;

  String? get metadataBlocker => switch (result) {
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata => null,
        ArchetypeContextMetadataFeasibilityResult.needsRemainderMetadata =>
          remainderFeasibility.metadataBlocker ??
              ArchetypeContextMetadataBlocker.needsRemainderMetadata,
        ArchetypeContextMetadataFeasibilityResult.needsCanonArchetypeMapping =>
          ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      };
}

/// Legacy resolver entry point — prefer [ThaiArchetypeContextResolver].
abstract final class ThaiArchetypeContextMetadataResolver {
  static String? archetypeChartCanonIdForRemainder(
    String? rotationIndexRemainderCanonId,
  ) {
    if (rotationIndexRemainderCanonId == null ||
        rotationIndexRemainderCanonId.trim().isEmpty) {
      return null;
    }
    return ThaiArchetypeContextP19Rules
        .remainderToArchetypeChart[rotationIndexRemainderCanonId];
  }
}

/// Audits whether runtime exposes deterministic archetype chart identity.
abstract final class ThaiArchetypeContextMetadataFeasibility {
  static ThaiArchetypeContextMetadataFeasibilityAudit audit({
    ThaiAstrologyProfile? profile,
    ThaiBirthData? birthData,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final remainderFeasibility = ThaiRemainderRuntimeMetadataFeasibility.audit(
      profile: profile,
      birthData: birthData,
    );
    final mappingAudit =
        ThaiArchetypeContextMappingRegistry.audit(index: canonIndex);
    final hasRemainder = _hasRotationRemainderOnRuntime(remainderFeasibility);
    final resolved = ThaiArchetypeContextResolver.resolve(
      remainderMetadata: ThaiRemainderMetadataResolver.resolve(
        profile: profile,
        birthData: birthData,
      ),
      canonIndex: canonIndex,
    );
    final hasArchetypeId = resolved.metadata != null;
    final mappingComplete = mappingAudit.isComplete;
    final usesThaya = _usesMahabhutaThayaAsProxy(profile);

    final result = _classify(
      hasRemainder: hasRemainder,
      hasArchetypeId: hasArchetypeId,
      mappingComplete: mappingComplete,
    );

    return ThaiArchetypeContextMetadataFeasibilityAudit(
      result: result,
      hasRotationRemainderOnRuntime: hasRemainder,
      hasArchetypeChartCanonIdOnRuntime: hasArchetypeId,
      canonRemainderToArchetypeMappingComplete: mappingComplete,
      usesMahabhutaThayaAsProxy: usesThaya,
      remainderFeasibility: remainderFeasibility,
      mappingAudit: mappingAudit,
    );
  }

  static ArchetypeContextMetadataFeasibilityResult _classify({
    required bool hasRemainder,
    required bool hasArchetypeId,
    required bool mappingComplete,
  }) {
    if (!hasRemainder && !hasArchetypeId) {
      return ArchetypeContextMetadataFeasibilityResult.needsRemainderMetadata;
    }
    if (!mappingComplete || !hasArchetypeId) {
      return ArchetypeContextMetadataFeasibilityResult
          .needsCanonArchetypeMapping;
    }
    return ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata;
  }

  static bool _hasRotationRemainderOnRuntime(
    ThaiRemainderRuntimeMetadataFeasibilityAudit remainderFeasibility,
  ) {
    return remainderFeasibility.result ==
            RemainderRuntimeMetadataFeasibilityResult
                .readyToExposeRemainderMetadata ||
        remainderFeasibility.result ==
            RemainderRuntimeMetadataFeasibilityResult
                .readyToExposeFromExistingEngineField;
  }

  static bool _usesMahabhutaThayaAsProxy(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    return profile.mahabhutaPositionKeys.contains(ThaiContentKeys.mahabhutaThaya);
  }
}
