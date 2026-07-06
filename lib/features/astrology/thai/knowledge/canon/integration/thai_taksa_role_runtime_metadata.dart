import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_taksa_role_runtime_mapping.dart';
import 'thai_taksa_role_runtime_key.dart';

/// Feasibility classification for Taksa runtime mapping.
enum TaksaRuntimeMappingFeasibilityResult {
  readyToMapExistingTaksaKeys,
  readyToAddInternalTaksaRoleKeys,
  needsTaksaRotationModel,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension TaksaRuntimeMappingFeasibilityResultWire
    on TaksaRuntimeMappingFeasibilityResult {
  String get wire => switch (this) {
        TaksaRuntimeMappingFeasibilityResult.readyToMapExistingTaksaKeys =>
          'READY_TO_MAP_EXISTING_TAKSA_KEYS',
        TaksaRuntimeMappingFeasibilityResult.readyToAddInternalTaksaRoleKeys =>
          'READY_TO_ADD_INTERNAL_TAKSA_ROLE_KEYS',
        TaksaRuntimeMappingFeasibilityResult.needsTaksaRotationModel =>
          'NEEDS_TAKSA_ROTATION_MODEL',
        TaksaRuntimeMappingFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        TaksaRuntimeMappingFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Read-only feasibility audit — no Canon mutation, no rotation calculation.
class ThaiTaksaRoleRuntimeMetadataFeasibilityAudit {
  const ThaiTaksaRoleRuntimeMetadataFeasibilityAudit({
    required this.result,
    required this.runtimeExposesTaksaRoleKey,
    required this.runtimeExposesBirthWeekday,
    required this.runtimeExposesPlanetRoleAssignment,
    required this.reportCopyMentionsTaksaRoles,
    required this.canonHasRoleIdentityData,
    required this.mappedRoleCount,
    required this.birthWeekdayNumber,
  });

  final TaksaRuntimeMappingFeasibilityResult result;
  final bool runtimeExposesTaksaRoleKey;
  final bool runtimeExposesBirthWeekday;
  final bool runtimeExposesPlanetRoleAssignment;
  final bool reportCopyMentionsTaksaRoles;
  final bool canonHasRoleIdentityData;
  final int mappedRoleCount;
  final int? birthWeekdayNumber;

  static ThaiTaksaRoleRuntimeMetadataFeasibilityAudit audit({
    ThaiMirrorPipelineResult? pipeline,
  }) {
    final birthData = pipeline?.birthData;
    final weekday = birthData?.thaiWeekdayNumber;
    final mappedRoleCount = ThaiCanonTaksaRoleRuntimeMapping.allowedCanonIds.length;

    final runtimeExposesTaksaRoleKey = false;
    final runtimeExposesBirthWeekday = weekday != null;
    final runtimeExposesPlanetRoleAssignment = false;
    const reportCopyMentionsTaksaRoles = false;
    final canonHasRoleIdentityData = mappedRoleCount == 8;

    final result = runtimeExposesTaksaRoleKey
        ? TaksaRuntimeMappingFeasibilityResult.readyToMapExistingTaksaKeys
        : TaksaRuntimeMappingFeasibilityResult.readyToAddInternalTaksaRoleKeys;

    return ThaiTaksaRoleRuntimeMetadataFeasibilityAudit(
      result: result,
      runtimeExposesTaksaRoleKey: runtimeExposesTaksaRoleKey,
      runtimeExposesBirthWeekday: runtimeExposesBirthWeekday,
      runtimeExposesPlanetRoleAssignment: runtimeExposesPlanetRoleAssignment,
      reportCopyMentionsTaksaRoles: reportCopyMentionsTaksaRoles,
      canonHasRoleIdentityData: canonHasRoleIdentityData,
      mappedRoleCount: mappedRoleCount,
      birthWeekdayNumber: weekday,
    );
  }
}

/// Discover explicit runtime/report Taksa role signals (empty until wired).
abstract final class ThaiTaksaRoleRuntimeSignalDiscovery {
  static List<String> discoverRuntimeTaksaRoleKeys({
    required ThaiMirrorPipelineResult pipeline,
  }) {
    // No report section or profile field exposes Taksa role keys today.
    return const [];
  }
}
