import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import '../../domain/personality_agreement_lens_id.dart';
import '../../domain/personality_lens_id.dart';
import '../../domain/personality_lens_theme_output.dart';
import '../personality_lens_load_result.dart';

/// Flattened theme row for cross-lens agreement/tension detection.
class PersonalityMirrorThemeSignal {
  const PersonalityMirrorThemeSignal({
    required this.agreementLens,
    required this.sourceLensId,
    required this.themeId,
    required this.category,
    required this.family,
    required this.confidence,
  });

  final PersonalityAgreementLensId agreementLens;
  final PersonalityLensId sourceLensId;
  final String themeId;
  final FusionCategory category;
  final ThemeFamily family;
  final double confidence;
}

abstract final class PersonalityMirrorThemeSignalExtractor {
  static List<PersonalityMirrorThemeSignal> extract(
    PersonalityLensLoadResult load,
  ) {
    final signals = <PersonalityMirrorThemeSignal>[];

    for (final entry in load.snapshots.entries) {
      final snapshot = entry.value;
      if (!snapshot.available || snapshot.themes.isEmpty) continue;

      final agreementLens =
          PersonalityAgreementLensId.fromPersonalityLensId(entry.key);
      if (agreementLens == null) continue;

      for (final theme in snapshot.themes) {
        signals.add(_fromTheme(entry.key, agreementLens, theme));
      }
    }

    return signals;
  }

  static PersonalityMirrorThemeSignal _fromTheme(
    PersonalityLensId sourceLensId,
    PersonalityAgreementLensId agreementLens,
    PersonalityLensThemeOutput theme,
  ) {
    return PersonalityMirrorThemeSignal(
      agreementLens: agreementLens,
      sourceLensId: sourceLensId,
      themeId: theme.themeId,
      category: theme.category,
      family: theme.family,
      confidence: theme.confidence,
    );
  }
}
