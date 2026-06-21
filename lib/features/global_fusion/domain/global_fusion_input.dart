import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import 'global_coverage.dart';
import 'global_theme_activation.dart';
class GlobalFusionInput {
  const GlobalFusionInput({
    this.astrologySnapshot,
    this.personalitySnapshot,
    required this.coverage,
    required this.normalizedThemes,
  });

  final AstrologyFusionSnapshot? astrologySnapshot;
  final PersonalityMirrorSnapshot? personalitySnapshot;
  final GlobalCoverage coverage;
  final List<GlobalThemeActivation> normalizedThemes;

  bool get hasAstrology => astrologySnapshot != null;

  bool get hasPersonality => personalitySnapshot != null;
}
