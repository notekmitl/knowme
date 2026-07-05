import '../../foundation/models/thai_astrology_profile.dart';

/// Feasibility outcome for remainder / เศษ runtime metadata.
enum RemainderRuntimeMetadataFeasibilityResult {
  readyToExposeRemainderMetadata,
  readyToExposeFromExistingEngineField,
  needsRemainderCalculationModel,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension RemainderRuntimeMetadataFeasibilityResultWire
    on RemainderRuntimeMetadataFeasibilityResult {
  String get wire => switch (this) {
        RemainderRuntimeMetadataFeasibilityResult
              .readyToExposeRemainderMetadata =>
          'READY_TO_EXPOSE_REMAINDER_METADATA',
        RemainderRuntimeMetadataFeasibilityResult
              .readyToExposeFromExistingEngineField =>
          'READY_TO_EXPOSE_FROM_EXISTING_ENGINE_FIELD',
        RemainderRuntimeMetadataFeasibilityResult
              .needsRemainderCalculationModel =>
          'NEEDS_REMAINDER_CALCULATION_MODEL',
        RemainderRuntimeMetadataFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        RemainderRuntimeMetadataFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker codes when remainder metadata cannot be exposed.
abstract final class RemainderRuntimeMetadataBlocker {
  static const needsRemainderCalculationModel =
      'NEEDS_REMAINDER_CALCULATION_MODEL';
  static const blockedBySourceGap = 'BLOCKED_BY_SOURCE_GAP';
  static const blockedByModelingGap = 'BLOCKED_BY_MODELING_GAP';
}

/// Internal remainder metadata (Canon rotationIndex id only).
class ThaiRemainderMetadata {
  const ThaiRemainderMetadata({
    required this.rotationIndexCanonId,
    required this.value,
    required this.source,
    required this.sourceField,
    this.confidence = 'deterministic',
  });

  /// e.g. `rotationIndex.remainder3` (Canon uses remainder0–6; value 0–6).
  final String rotationIndexCanonId;

  /// Allowed internal values when exposed: 0–6 per frozen Canon ontology.
  final int value;

  /// `runtime_structural` or `existing_engine_field`.
  final String source;
  final String sourceField;
  final String confidence;
}

/// Deterministic feasibility audit — read-only, no Canon mutation.
class ThaiRemainderRuntimeMetadataFeasibilityAudit {
  const ThaiRemainderRuntimeMetadataFeasibilityAudit({
    required this.result,
    required this.computesRemainderDirectly,
    required this.hasRotationIndexRemainderField,
    required this.row4DocumentedAsRemainder,
    required this.row4ReducedExposedOnProfile,
    required this.hasMahabhutaChartNumbers,
    required this.exposesDeterministicRemainderKey,
    required this.rejectsRow4AsRemainderProxy,
  });

  final RemainderRuntimeMetadataFeasibilityResult result;
  final bool computesRemainderDirectly;
  final bool hasRotationIndexRemainderField;
  final bool row4DocumentedAsRemainder;
  final bool row4ReducedExposedOnProfile;
  final bool hasMahabhutaChartNumbers;
  final bool exposesDeterministicRemainderKey;
  final bool rejectsRow4AsRemainderProxy;

  String? get metadataBlocker => switch (result) {
        RemainderRuntimeMetadataFeasibilityResult
              .readyToExposeRemainderMetadata ||
        RemainderRuntimeMetadataFeasibilityResult
              .readyToExposeFromExistingEngineField =>
          null,
        RemainderRuntimeMetadataFeasibilityResult
              .needsRemainderCalculationModel =>
          RemainderRuntimeMetadataBlocker.needsRemainderCalculationModel,
        RemainderRuntimeMetadataFeasibilityResult.blockedBySourceGap =>
          RemainderRuntimeMetadataBlocker.blockedBySourceGap,
        RemainderRuntimeMetadataFeasibilityResult.blockedByModelingGap =>
          RemainderRuntimeMetadataBlocker.blockedByModelingGap,
      };
}

/// Deterministic resolver — returns null unless remainder is on runtime output.
abstract final class ThaiRemainderMetadataResolver {
  static const allowedValues = {0, 1, 2, 3, 4, 5, 6};

  static String rotationIndexCanonIdForValue(int value) {
    return 'rotationIndex.remainder$value';
  }

  static ThaiRemainderMetadata? resolve({ThaiAstrologyProfile? profile}) {
    final audit = ThaiRemainderRuntimeMetadataFeasibility.audit(
      profile: profile,
    );
    if (audit.result !=
            RemainderRuntimeMetadataFeasibilityResult
                .readyToExposeRemainderMetadata &&
        audit.result !=
            RemainderRuntimeMetadataFeasibilityResult
                .readyToExposeFromExistingEngineField) {
      return null;
    }
    return null;
  }
}

/// Audits whether runtime already exposes deterministic remainder metadata.
abstract final class ThaiRemainderRuntimeMetadataFeasibility {
  static ThaiRemainderRuntimeMetadataFeasibilityAudit audit({
    ThaiAstrologyProfile? profile,
  }) {
    final computesDirectly = _computesRemainderDirectly();
    final hasRemainderField = _hasRotationIndexRemainderField(profile);
    final row4AsRemainder = _row4DocumentedAsRemainder();
    final row4ReducedOnProfile = _row4ReducedExposedOnProfile(profile);
    final hasChartNumbers = profile?.mahabhutaChartNumbers != null &&
        profile!.mahabhutaChartNumbers!.isNotEmpty;
    final exposesKey = _exposesDeterministicRemainderKey(profile);
    const rejectsRow4Proxy = true;

    final result = _classify(
      computesDirectly: computesDirectly,
      hasRemainderField: hasRemainderField,
      row4ProvenEquivalent: row4AsRemainder && !rejectsRow4Proxy,
      exposesKey: exposesKey,
    );

    return ThaiRemainderRuntimeMetadataFeasibilityAudit(
      result: result,
      computesRemainderDirectly: computesDirectly,
      hasRotationIndexRemainderField: hasRemainderField,
      row4DocumentedAsRemainder: row4AsRemainder,
      row4ReducedExposedOnProfile: row4ReducedOnProfile,
      hasMahabhutaChartNumbers: hasChartNumbers,
      exposesDeterministicRemainderKey: exposesKey,
      rejectsRow4AsRemainderProxy: rejectsRow4Proxy,
    );
  }

  static RemainderRuntimeMetadataFeasibilityResult _classify({
    required bool computesDirectly,
    required bool hasRemainderField,
    required bool row4ProvenEquivalent,
    required bool exposesKey,
  }) {
    if (computesDirectly || exposesKey) {
      return RemainderRuntimeMetadataFeasibilityResult
          .readyToExposeRemainderMetadata;
    }
    if (hasRemainderField || row4ProvenEquivalent) {
      return RemainderRuntimeMetadataFeasibilityResult
          .readyToExposeFromExistingEngineField;
    }
    return RemainderRuntimeMetadataFeasibilityResult
        .needsRemainderCalculationModel;
  }

  static bool _computesRemainderDirectly() {
    // [SevenNumberChart] computes row4Sum / row4Reduced — not เศษ/remainder.
    return false;
  }

  static bool _hasRotationIndexRemainderField(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    return false;
  }

  static bool _row4DocumentedAsRemainder() {
    // THAI_FOUNDATION_ENGINE_V1_1_NOTES: mahabhutaChartNumbers = Row 4 sums (audit).
    // seven_number_chart.dart: row4Reduced = horawej auxiliary — not remainder.
    return false;
  }

  static bool _row4ReducedExposedOnProfile(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    // row4Reduced exists on [SevenNumberChartResult] only — not on profile.
    return false;
  }

  static bool _exposesDeterministicRemainderKey(ThaiAstrologyProfile? profile) {
    if (profile == null) return false;
    return false;
  }
}
