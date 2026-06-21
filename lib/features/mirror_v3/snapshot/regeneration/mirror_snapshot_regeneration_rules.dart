import '../models/knowme_mirror_snapshot_lineage.dart';

/// Reasons a mirror snapshot must be regenerated or rejected.
enum MirrorSnapshotRegenerationReason {
  themeChange,
  engineVersionChange,
  structuralHashChange,
  validationFailure,
  noChange,
}

/// MV3.7 regeneration decision.
class MirrorSnapshotRegenerationDecision {
  const MirrorSnapshotRegenerationDecision({
    required this.shouldRegenerate,
    required this.shouldReject,
    required this.reason,
  });

  final bool shouldRegenerate;
  final bool shouldReject;
  final MirrorSnapshotRegenerationReason reason;
}

/// Source theme snapshot ids used to detect theme changes.
class MirrorSnapshotSourceFingerprint {
  const MirrorSnapshotSourceFingerprint({
    this.astrologyThemeSnapshotId,
    this.mbtiLensSnapshotId,
    this.bigFiveLensSnapshotId,
    this.eqLensSnapshotId,
  });

  final String? astrologyThemeSnapshotId;
  final String? mbtiLensSnapshotId;
  final String? bigFiveLensSnapshotId;
  final String? eqLensSnapshotId;
}

/// MV3.7 snapshot regeneration rules — no scheduler.
abstract final class MirrorSnapshotRegenerationRules {
  static MirrorSnapshotRegenerationDecision evaluate({
    required MirrorSnapshotSourceFingerprint currentSources,
    required MirrorSnapshotSourceFingerprint? existingSources,
    required String currentEngineVersion,
    required String? existingEngineVersion,
    required String currentStructuralHash,
    required String? existingStructuralHash,
    required bool validationPassed,
  }) {
    if (!validationPassed) {
      return const MirrorSnapshotRegenerationDecision(
        shouldRegenerate: false,
        shouldReject: true,
        reason: MirrorSnapshotRegenerationReason.validationFailure,
      );
    }

    if (existingEngineVersion != null &&
        existingEngineVersion != currentEngineVersion) {
      return const MirrorSnapshotRegenerationDecision(
        shouldRegenerate: true,
        shouldReject: false,
        reason: MirrorSnapshotRegenerationReason.engineVersionChange,
      );
    }

    if (existingSources != null &&
        _sourcesChanged(currentSources, existingSources)) {
      return const MirrorSnapshotRegenerationDecision(
        shouldRegenerate: true,
        shouldReject: false,
        reason: MirrorSnapshotRegenerationReason.themeChange,
      );
    }

    if (existingStructuralHash != null &&
        existingStructuralHash != currentStructuralHash) {
      return const MirrorSnapshotRegenerationDecision(
        shouldRegenerate: true,
        shouldReject: false,
        reason: MirrorSnapshotRegenerationReason.structuralHashChange,
      );
    }

    return const MirrorSnapshotRegenerationDecision(
      shouldRegenerate: false,
      shouldReject: false,
      reason: MirrorSnapshotRegenerationReason.noChange,
    );
  }

  static bool _sourcesChanged(
    MirrorSnapshotSourceFingerprint current,
    MirrorSnapshotSourceFingerprint existing,
  ) {
    return current.astrologyThemeSnapshotId !=
            existing.astrologyThemeSnapshotId ||
        current.mbtiLensSnapshotId != existing.mbtiLensSnapshotId ||
        current.bigFiveLensSnapshotId != existing.bigFiveLensSnapshotId ||
        current.eqLensSnapshotId != existing.eqLensSnapshotId;
  }

  static MirrorSnapshotSourceFingerprint fromLineage(
    KnowMeMirrorSnapshotLineage lineage,
  ) {
    return MirrorSnapshotSourceFingerprint(
      astrologyThemeSnapshotId: lineage.astrologyThemeSnapshotId,
      mbtiLensSnapshotId: lineage.mbtiLensSnapshotId,
      bigFiveLensSnapshotId: lineage.bigFiveLensSnapshotId,
      eqLensSnapshotId: lineage.eqLensSnapshotId,
    );
  }
}
