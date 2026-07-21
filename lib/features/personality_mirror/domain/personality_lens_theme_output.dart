import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import 'personality_confidence.dart';
import 'personality_lens_evidence.dart';
import 'personality_lens_id.dart';
import 'personality_theme_activation.dart';

/// Normalized theme output from one personality lens adapter.
class PersonalityLensThemeOutput {
  const PersonalityLensThemeOutput({
    required this.lensId,
    required this.themeId,
    required this.category,
    required this.family,
    required this.activation,
    required this.confidence,
    required this.evidence,
    required this.sourceVersion,
  });

  final PersonalityLensId lensId;
  final String themeId;
  final FusionCategory category;
  final ThemeFamily family;
  final PersonalityThemeActivation activation;
  final PersonalityConfidence confidence;
  final List<PersonalityLensEvidence> evidence;
  final PersonalitySourceVersionMeta sourceVersion;
}
