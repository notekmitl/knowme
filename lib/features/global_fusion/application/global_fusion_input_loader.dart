import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../domain/global_coverage.dart';
import '../domain/global_fusion_input.dart';
import 'theme_normalization/global_theme_normalizer.dart';

/// Loads [GlobalFusionInput] from mirror snapshots only — never raw systems.
class GlobalFusionInputLoader {
  const GlobalFusionInputLoader();

  GlobalFusionInput load({
    AstrologyFusionSnapshot? astrologySnapshot,
    PersonalityMirrorSnapshot? personalitySnapshot,
  }) {
    final coverage = _deriveCoverage(
      astrology: astrologySnapshot,
      personality: personalitySnapshot,
    );

    final normalizedThemes = GlobalThemeNormalizer.fromMirrors(
      astrology: astrologySnapshot,
      personality: personalitySnapshot,
    );

    return GlobalFusionInput(
      astrologySnapshot: astrologySnapshot,
      personalitySnapshot: personalitySnapshot,
      coverage: coverage,
      normalizedThemes: normalizedThemes,
    );
  }

  GlobalCoverage _deriveCoverage({
    AstrologyFusionSnapshot? astrology,
    PersonalityMirrorSnapshot? personality,
  }) {
    return GlobalCoverage(
      astrology: _astrologyCoverage(astrology),
      personality: _personalityCoverage(personality),
    );
  }

  AstrologyMirrorCoverageSlice _astrologyCoverage(
    AstrologyFusionSnapshot? snapshot,
  ) {
    if (snapshot == null) {
      return AstrologyMirrorCoverageSlice.empty;
    }

    const totalLensCount = 3;
    final completedLensIds = <String>[];
    final versions = snapshot.sourceLensVersions;

    if (versions.westernVersion != null) {
      completedLensIds.add('western');
    }
    if (versions.baziVersion != null) {
      completedLensIds.add('bazi');
    }
    if (versions.thaiVersion != null) {
      completedLensIds.add('thai');
    }

    return AstrologyMirrorCoverageSlice(
      available: completedLensIds.isNotEmpty,
      completedLensCount: completedLensIds.length,
      totalLensCount: totalLensCount,
      completedLensIds: completedLensIds,
    );
  }

  PersonalityMirrorCoverageSlice _personalityCoverage(
    PersonalityMirrorSnapshot? snapshot,
  ) {
    if (snapshot == null) {
      return PersonalityMirrorCoverageSlice.empty;
    }

    final coverage = snapshot.coverage;
    return PersonalityMirrorCoverageSlice(
      available: coverage.availableLensIds.isNotEmpty,
      availableLensIds: List.unmodifiable(coverage.availableLensIds),
      missingLensIds: List.unmodifiable(coverage.missingLensIds),
      weightedCoverage: coverage.weightedCoverage,
      eqModulesCompleted: coverage.eqModulesCompleted,
      eqModulesExpected: coverage.eqModulesExpected,
    );
  }
}
