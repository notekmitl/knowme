import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/global_fusion/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_coverage.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../domain/exploration_lens_id.dart';
import '../domain/exploration_mirror_id.dart';
import '../domain/exploration_overview.dart';
import '../domain/exploration_profile_input.dart';

/// Builds [ExplorationOverview] from profile + mirror snapshots (EO-F0).
abstract final class ExplorationOverviewBuilder {
  static ExplorationOverview build({
    required ExplorationProfileInput profile,
    AstrologyFusionSnapshot? astrologySnapshot,
    PersonalityMirrorSnapshot? personalitySnapshot,
    GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    final lensStatuses = _buildLensStatuses(
      profile: profile,
      astrologySnapshot: astrologySnapshot,
      personalitySnapshot: personalitySnapshot,
    );

    final mirrorStatuses = _buildMirrorStatuses(
      astrologySnapshot: astrologySnapshot,
      personalitySnapshot: personalitySnapshot,
    );

    final fusionStatus = _buildFusionStatus(
      astrologySnapshot: astrologySnapshot,
      personalitySnapshot: personalitySnapshot,
      globalFusionSnapshot: globalFusionSnapshot,
    );

    final coverage = _buildCoverage(
      lensStatuses: lensStatuses,
      mirrorStatuses: mirrorStatuses,
      fusionStatus: fusionStatus,
    );

    return ExplorationOverview(
      version: ExplorationOverview.versionId,
      profileStatus: _deriveProfileStatus(profile),
      lensStatuses: lensStatuses,
      mirrorStatuses: mirrorStatuses,
      fusionStatus: fusionStatus,
      coverage: coverage,
    );
  }

  static ExplorationProfileStatus _deriveProfileStatus(
    ExplorationProfileInput profile,
  ) {
    if (profile.isBirthProfileComplete) {
      return ExplorationProfileStatus.birthProfileComplete;
    }
    if (profile.hasAnyProfileData) {
      return ExplorationProfileStatus.basicProfile;
    }
    return ExplorationProfileStatus.noBirthProfile;
  }

  static List<ExplorationLensStatusEntry> _buildLensStatuses({
    required ExplorationProfileInput profile,
    required AstrologyFusionSnapshot? astrologySnapshot,
    required PersonalityMirrorSnapshot? personalitySnapshot,
  }) {
    final astrologyCompleted = _completedAstrologyLenses(astrologySnapshot);
    final personalityCoverage = personalitySnapshot?.coverage;

    return [
      for (final lensId in ExplorationLensId.all)
        _lensStatus(
          lensId: lensId,
          profile: profile,
          astrologyCompleted: astrologyCompleted,
          personalityCoverage: personalityCoverage,
        ),
    ];
  }

  static ExplorationLensStatusEntry _lensStatus({
    required ExplorationLensId lensId,
    required ExplorationProfileInput profile,
    required Set<ExplorationLensId> astrologyCompleted,
    required PersonalityCoverage? personalityCoverage,
  }) {
    return switch (lensId) {
      ExplorationLensId.westernNatal ||
      ExplorationLensId.chineseBazi ||
      ExplorationLensId.thaiAstrology =>
        _astrologyLensStatus(
          lensId: lensId,
          profile: profile,
          completed: astrologyCompleted.contains(lensId),
        ),
      ExplorationLensId.mbti => _personalityLensStatus(
          lensId: lensId,
          completed: personalityCoverage?.hasMbti ?? false,
        ),
      ExplorationLensId.bigFive => _personalityLensStatus(
          lensId: lensId,
          completed: personalityCoverage?.hasBigFive ?? false,
        ),
      ExplorationLensId.eq => _eqLensStatus(
          eqModulesCompleted: personalityCoverage?.eqModulesCompleted ?? 0,
          eqModulesExpected: personalityCoverage?.eqModulesExpected ??
              PersonalityLensId.eqLenses.length,
        ),
    };
  }

  static ExplorationLensStatusEntry _astrologyLensStatus({
    required ExplorationLensId lensId,
    required ExplorationProfileInput profile,
    required bool completed,
  }) {
    final available = profile.isBirthProfileComplete;
    return ExplorationLensStatusEntry(
      lensId: lensId,
      available: available,
      completed: completed,
      usable: available && completed,
    );
  }

  static ExplorationLensStatusEntry _personalityLensStatus({
    required ExplorationLensId lensId,
    required bool completed,
  }) {
    return ExplorationLensStatusEntry(
      lensId: lensId,
      available: true,
      completed: completed,
      usable: completed,
    );
  }

  static ExplorationLensStatusEntry _eqLensStatus({
    required int eqModulesCompleted,
    required int eqModulesExpected,
  }) {
    final completed =
        eqModulesExpected > 0 && eqModulesCompleted >= eqModulesExpected;
    final usable = eqModulesCompleted > 0;

    return ExplorationLensStatusEntry(
      lensId: ExplorationLensId.eq,
      available: true,
      completed: completed,
      usable: usable,
    );
  }

  static Set<ExplorationLensId> _completedAstrologyLenses(
    AstrologyFusionSnapshot? snapshot,
  ) {
    if (snapshot == null) return const {};

    final versions = snapshot.sourceLensVersions;
    final completed = <ExplorationLensId>{};

    if (versions.westernVersion != null) {
      completed.add(ExplorationLensId.westernNatal);
    }
    if (versions.baziVersion != null) {
      completed.add(ExplorationLensId.chineseBazi);
    }
    if (versions.thaiVersion != null) {
      completed.add(ExplorationLensId.thaiAstrology);
    }

    return completed;
  }

  static List<ExplorationMirrorStatusEntry> _buildMirrorStatuses({
    required AstrologyFusionSnapshot? astrologySnapshot,
    required PersonalityMirrorSnapshot? personalitySnapshot,
  }) {
    return [
      ExplorationMirrorStatusEntry(
        mirrorId: ExplorationMirrorId.astrologyMirror,
        readiness: _astrologyMirrorReadiness(astrologySnapshot),
      ),
      ExplorationMirrorStatusEntry(
        mirrorId: ExplorationMirrorId.personalityMirror,
        readiness: _personalityMirrorReadiness(personalitySnapshot),
      ),
    ];
  }

  static ExplorationMirrorReadiness _astrologyMirrorReadiness(
    AstrologyFusionSnapshot? snapshot,
  ) {
    final completedCount = _completedAstrologyLenses(snapshot).length;
    if (completedCount == 0) return ExplorationMirrorReadiness.unavailable;
    if (completedCount < ExplorationLensId.astrologyLenses.length) {
      return ExplorationMirrorReadiness.partial;
    }
    return ExplorationMirrorReadiness.ready;
  }

  static ExplorationMirrorReadiness _personalityMirrorReadiness(
    PersonalityMirrorSnapshot? snapshot,
  ) {
    if (snapshot == null) return ExplorationMirrorReadiness.unavailable;

    final completedCount = _completedPersonalityExplorationLenses(snapshot);
    if (completedCount == 0) return ExplorationMirrorReadiness.unavailable;
    if (completedCount < ExplorationLensId.personalityLenses.length) {
      return ExplorationMirrorReadiness.partial;
    }
    return ExplorationMirrorReadiness.ready;
  }

  static int _completedPersonalityExplorationLenses(
    PersonalityMirrorSnapshot snapshot,
  ) {
    var count = 0;
    final coverage = snapshot.coverage;

    if (coverage.hasMbti) count++;
    if (coverage.hasBigFive) count++;

    final eqComplete = coverage.eqModulesExpected > 0 &&
        coverage.eqModulesCompleted >= coverage.eqModulesExpected;
    if (eqComplete) count++;

    return count;
  }

  static ExplorationFusionStatus _buildFusionStatus({
    required AstrologyFusionSnapshot? astrologySnapshot,
    required PersonalityMirrorSnapshot? personalitySnapshot,
    required GlobalFusionSnapshot? globalFusionSnapshot,
  }) {
    final hasAstrology =
        _astrologyMirrorReadiness(astrologySnapshot) !=
            ExplorationMirrorReadiness.unavailable;
    final hasPersonality =
        _personalityMirrorReadiness(personalitySnapshot) !=
            ExplorationMirrorReadiness.unavailable;

    if (globalFusionSnapshot != null) {
      final coverage = globalFusionSnapshot.coverage;
      if (!coverage.hasAnyMirror) {
        return const ExplorationFusionStatus(
          readiness: ExplorationFusionReadiness.unavailable,
        );
      }
      if (!coverage.hasBothMirrors) {
        return const ExplorationFusionStatus(
          readiness: ExplorationFusionReadiness.limited,
        );
      }
      return const ExplorationFusionStatus(
        readiness: ExplorationFusionReadiness.ready,
      );
    }

    if (!hasAstrology && !hasPersonality) {
      return const ExplorationFusionStatus(
        readiness: ExplorationFusionReadiness.unavailable,
      );
    }
    if (hasAstrology && hasPersonality) {
      return const ExplorationFusionStatus(
        readiness: ExplorationFusionReadiness.ready,
      );
    }
    return const ExplorationFusionStatus(
      readiness: ExplorationFusionReadiness.limited,
    );
  }

  static ExplorationCoverageSummary _buildCoverage({
    required List<ExplorationLensStatusEntry> lensStatuses,
    required List<ExplorationMirrorStatusEntry> mirrorStatuses,
    required ExplorationFusionStatus fusionStatus,
  }) {
    final explored = lensStatuses
        .where((entry) => entry.completed)
        .map((entry) => entry.lensId)
        .toList();
    final unexplored = lensStatuses
        .where((entry) => !entry.completed)
        .map((entry) => entry.lensId)
        .toList();

    final availableMirrors = mirrorStatuses
        .where((entry) => entry.readiness != ExplorationMirrorReadiness.unavailable)
        .map((entry) => entry.mirrorId)
        .toList();

    var reflectionCount = 0;
    for (final mirror in mirrorStatuses) {
      if (mirror.readiness != ExplorationMirrorReadiness.unavailable) {
        reflectionCount++;
      }
    }
    if (fusionStatus.readiness == ExplorationFusionReadiness.ready) {
      reflectionCount++;
    }

    return ExplorationCoverageSummary(
      exploredLensCount: explored.length,
      exploredLenses: List.unmodifiable(explored),
      unexploredLensCount: unexplored.length,
      unexploredLenses: List.unmodifiable(unexplored),
      availableMirrorCount: availableMirrors.length,
      availableMirrors: List.unmodifiable(availableMirrors),
      availableReflectionCount: reflectionCount,
    );
  }
}
