import 'exploration_lens_id.dart';
import 'exploration_mirror_id.dart';
import 'exploration_profile_input.dart';

/// Profile readiness for reflection — descriptive, not scored (EO-F0).
enum ExplorationProfileStatus {
  noBirthProfile,
  basicProfile,
  birthProfileComplete,
}

/// Mirror readiness derived from snapshot coverage only.
enum ExplorationMirrorReadiness {
  unavailable,
  partial,
  ready,
}

/// Global Fusion readiness derived from mirror presence only.
enum ExplorationFusionReadiness {
  unavailable,
  limited,
  ready,
}

/// Per-lens exploration facts — no recommendation logic.
class ExplorationLensStatusEntry {
  const ExplorationLensStatusEntry({
    required this.lensId,
    required this.available,
    required this.completed,
    required this.usable,
  });

  final ExplorationLensId lensId;
  final bool available;
  final bool completed;
  final bool usable;
}

/// Mirror-level readiness summary.
class ExplorationMirrorStatusEntry {
  const ExplorationMirrorStatusEntry({
    required this.mirrorId,
    required this.readiness,
  });

  final ExplorationMirrorId mirrorId;
  final ExplorationMirrorReadiness readiness;
}

/// Global Fusion readiness summary.
class ExplorationFusionStatus {
  const ExplorationFusionStatus({
    required this.readiness,
  });

  final ExplorationFusionReadiness readiness;
}

/// Human-readable exploration coverage — counts only, no scores.
class ExplorationCoverageSummary {
  const ExplorationCoverageSummary({
    required this.exploredLensCount,
    required this.exploredLenses,
    required this.unexploredLensCount,
    required this.unexploredLenses,
    required this.availableMirrorCount,
    required this.availableMirrors,
    required this.availableReflectionCount,
  });

  final int exploredLensCount;
  final List<ExplorationLensId> exploredLenses;
  final int unexploredLensCount;
  final List<ExplorationLensId> unexploredLenses;
  final int availableMirrorCount;
  final List<ExplorationMirrorId> availableMirrors;
  final int availableReflectionCount;
}

/// Meta view of self-exploration progress (EO-F0 — no UI, no recommendations).
class ExplorationOverview {
  const ExplorationOverview({
    required this.version,
    required this.profileStatus,
    required this.lensStatuses,
    required this.mirrorStatuses,
    required this.fusionStatus,
    required this.coverage,
  });

  static const String versionId = 'exploration_overview.v1';

  final String version;
  final ExplorationProfileStatus profileStatus;
  final List<ExplorationLensStatusEntry> lensStatuses;
  final List<ExplorationMirrorStatusEntry> mirrorStatuses;
  final ExplorationFusionStatus fusionStatus;
  final ExplorationCoverageSummary coverage;

  ExplorationLensStatusEntry lens(ExplorationLensId lensId) {
    return lensStatuses.firstWhere((entry) => entry.lensId == lensId);
  }

  ExplorationMirrorStatusEntry mirror(ExplorationMirrorId mirrorId) {
    return mirrorStatuses.firstWhere((entry) => entry.mirrorId == mirrorId);
  }
}
