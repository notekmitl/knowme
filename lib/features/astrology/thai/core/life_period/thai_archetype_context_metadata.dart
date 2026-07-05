import '../../content/models/thai_content_key.dart';
import '../../foundation/models/thai_astrology_profile.dart';
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

/// Blocker codes when archetype context metadata cannot be exposed.
abstract final class ArchetypeContextMetadataBlocker {
  static const needsRemainderMetadata = 'NEEDS_REMAINDER_METADATA';
  static const needsCanonArchetypeMapping = 'NEEDS_CANON_ARCHETYPE_MAPPING';
}

/// Internal archetype chart identity (Canon id only — not user-facing copy).
class ArchetypeChartContextMetadata {
  const ArchetypeChartContextMetadata({
    required this.archetypeChartCanonId,
    this.rotationIndexRemainderCanonId,
  });

  final String archetypeChartCanonId;
  final String? rotationIndexRemainderCanonId;
}

/// Frozen Canon p19 remainder → archetype chart mappings (Phase G).
abstract final class ThaiArchetypeContextP19Rules {
  static const remainderToArchetypeChart = {
    'rotationIndex.remainder0': 'archetypeChart.mahasethi',
    'rotationIndex.remainder1': 'archetypeChart.kamphra',
    'rotationIndex.remainder2': 'archetypeChart.naksas',
    'rotationIndex.remainder3': 'archetypeChart.nakbarihan',
    'rotationIndex.remainder4': 'archetypeChart.manussachaosamran',
    'rotationIndex.remainder5': 'archetypeChart.sethi',
  };

  /// All seven frozen [archetypeChart.*] ids.
  static const allArchetypeChartIds = {
    'archetypeChart.kamphra',
    'archetypeChart.naksas',
    'archetypeChart.nakbarihan',
    'archetypeChart.manussachaosamran',
    'archetypeChart.sethi',
    'archetypeChart.nakwichakan',
    'archetypeChart.mahasethi',
  };

  /// p19 prose omits [rotationIndex.remainder6] → chart (Phase G gap).
  static const unmappedRemainderIds = {'rotationIndex.remainder6'};

  /// [archetypeChart.nakwichakan] has no p19 remainder row (Phase G gap).
  static const unmappedArchetypeChartIds = {'archetypeChart.nakwichakan'};
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
  });

  final ArchetypeContextMetadataFeasibilityResult result;
  final bool hasRotationRemainderOnRuntime;
  final bool hasArchetypeChartCanonIdOnRuntime;
  final bool canonRemainderToArchetypeMappingComplete;
  final bool usesMahabhutaThayaAsProxy;
  final ThaiRemainderRuntimeMetadataFeasibilityAudit remainderFeasibility;

  String? get metadataBlocker => switch (result) {
        ArchetypeContextMetadataFeasibilityResult.readyToExposeMetadata => null,
        ArchetypeContextMetadataFeasibilityResult.needsRemainderMetadata =>
          remainderFeasibility.metadataBlocker ??
              ArchetypeContextMetadataBlocker.needsRemainderMetadata,
        ArchetypeContextMetadataFeasibilityResult.needsCanonArchetypeMapping =>
          ArchetypeContextMetadataBlocker.needsCanonArchetypeMapping,
      };
}

/// Deterministic resolver — requires runtime [rotationIndexRemainderCanonId].
///
/// Does not infer from [ThaiContentKeys.mahabhutaThaya], section copy, or
/// [mahabhutPosition.khumsap].
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
  }) {
    final remainderFeasibility = ThaiRemainderRuntimeMetadataFeasibility.audit(
      profile: profile,
    );
    final hasRemainder = _hasRotationRemainderOnRuntime(remainderFeasibility);
    final hasArchetypeId = _hasArchetypeChartCanonIdOnRuntime(profile);
    final mappingComplete = _isCanonRemainderMappingComplete();
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
    if (!mappingComplete) {
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

  static bool _hasArchetypeChartCanonIdOnRuntime(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    return false;
  }

  static bool _isCanonRemainderMappingComplete() {
    if (ThaiArchetypeContextP19Rules.unmappedRemainderIds.isNotEmpty) {
      return false;
    }
    if (ThaiArchetypeContextP19Rules.unmappedArchetypeChartIds.isNotEmpty) {
      return false;
    }
    return ThaiArchetypeContextP19Rules.remainderToArchetypeChart.length ==
        ThaiArchetypeContextP19Rules.allArchetypeChartIds.length;
  }

  static bool _usesMahabhutaThayaAsProxy(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    // Explicit audit flag — thaya may appear on profile but is never used here.
    return profile.mahabhutaPositionKeys.contains(ThaiContentKeys.mahabhutaThaya);
  }
}
