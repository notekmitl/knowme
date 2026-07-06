import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';

import 'thai_canon_khumsap_runtime_mapping.dart';
import 'thai_mahabhut_khumsap_runtime_key.dart';

/// Feasibility classification for Khumsap runtime mapping.
enum KhumsapRuntimeMappingFeasibilityResult {
  readyToMapExistingKhumsapKey,
  readyToAddInternalKhumsapKey,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension KhumsapRuntimeMappingFeasibilityResultWire
    on KhumsapRuntimeMappingFeasibilityResult {
  String get wire => switch (this) {
        KhumsapRuntimeMappingFeasibilityResult.readyToMapExistingKhumsapKey =>
          'READY_TO_MAP_EXISTING_KHUMSAP_KEY',
        KhumsapRuntimeMappingFeasibilityResult.readyToAddInternalKhumsapKey =>
          'READY_TO_ADD_INTERNAL_KHUMSAP_KEY',
        KhumsapRuntimeMappingFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        KhumsapRuntimeMappingFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Read-only feasibility audit — no Canon mutation, no thaya equivalence.
class ThaiKhumsapRuntimeMetadataFeasibilityAudit {
  const ThaiKhumsapRuntimeMetadataFeasibilityAudit({
    required this.result,
    required this.runtimeExposesKhumsapKey,
    required this.thaiContentKeysHasExactKhumsapKey,
    required this.thaiContentRegistryHasKhumsapSection,
    required this.reportSignalRepresentsKhumsap,
    required this.mahabhutaThayaMeansKhumsapByEvidence,
    required this.mahabhutaThayaRemainsOutOfCanonScope,
  });

  final KhumsapRuntimeMappingFeasibilityResult result;
  final bool runtimeExposesKhumsapKey;
  final bool thaiContentKeysHasExactKhumsapKey;
  final bool thaiContentRegistryHasKhumsapSection;
  final bool reportSignalRepresentsKhumsap;
  final bool mahabhutaThayaMeansKhumsapByEvidence;
  final bool mahabhutaThayaRemainsOutOfCanonScope;

  static ThaiKhumsapRuntimeMetadataFeasibilityAudit audit() {
    const runtimeExposesKhumsapKey = false;
    const thaiContentKeysHasExactKhumsapKey = false;
    const thaiContentRegistryHasKhumsapSection = false;
    const reportSignalRepresentsKhumsap = false;
    const mahabhutaThayaMeansKhumsapByEvidence = false;
    const mahabhutaThayaRemainsOutOfCanonScope = true;

    final result = runtimeExposesKhumsapKey
        ? KhumsapRuntimeMappingFeasibilityResult.readyToMapExistingKhumsapKey
        : KhumsapRuntimeMappingFeasibilityResult.readyToAddInternalKhumsapKey;

    return ThaiKhumsapRuntimeMetadataFeasibilityAudit(
      result: result,
      runtimeExposesKhumsapKey: runtimeExposesKhumsapKey,
      thaiContentKeysHasExactKhumsapKey: thaiContentKeysHasExactKhumsapKey,
      thaiContentRegistryHasKhumsapSection: thaiContentRegistryHasKhumsapSection,
      reportSignalRepresentsKhumsap: reportSignalRepresentsKhumsap,
      mahabhutaThayaMeansKhumsapByEvidence: mahabhutaThayaMeansKhumsapByEvidence,
      mahabhutaThayaRemainsOutOfCanonScope: mahabhutaThayaRemainsOutOfCanonScope,
    );
  }

  /// Confirms [ThaiContentKeys.mahabhutaThaya] is not the Khumsap internal key.
  static bool isMahabhutaThayaKey(String contentKey) =>
      contentKey == ThaiContentKeys.mahabhutaThaya;

  static bool isKhumsapInternalKey(String contentKey) =>
      ThaiCanonKhumsapRuntimeMapping.isInternalKhumsapRuntimeKey(contentKey);
}
