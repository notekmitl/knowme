import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import '../../domain/personality_agreement_lens_id.dart';
import '../../domain/personality_tension.dart';
import 'personality_mirror_theme_signal.dart';
import 'personality_opposing_family.dart';

/// Detects opposing-family tensions within the same category across lenses.
abstract final class PersonalityTensionEngine {
  static List<PersonalityTension> detect(
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    if (signals.isEmpty) return const [];

    final byCategory = <FusionCategory, List<PersonalityMirrorThemeSignal>>{};
    for (final signal in signals) {
      byCategory.putIfAbsent(signal.category, () => []).add(signal);
    }

    final tensions = <PersonalityTension>[];
    for (final entry in byCategory.entries) {
      tensions.addAll(_detectInCategory(entry.key, entry.value));
    }

    return _dedupe(tensions);
  }

  static List<PersonalityTension> _detectInCategory(
    FusionCategory category,
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    final tensions = <PersonalityTension>[];
    final seen = <String>{};

    for (var i = 0; i < signals.length; i++) {
      for (var j = i + 1; j < signals.length; j++) {
        final a = signals[i];
        final b = signals[j];

        if (a.agreementLens == b.agreementLens) continue;
        if (!PersonalityOpposingFamily.areOpposing(a.family, b.family)) {
          continue;
        }

        final reason = PersonalityOpposingFamily.reasonCodeFor(a.family, b.family);
        if (reason == null) continue;

        final lenses = <PersonalityAgreementLensId>{
          a.agreementLens,
          b.agreementLens,
        }.toList()
          ..sort((x, y) => x.index.compareTo(y.index));
        final themes = <String>{a.themeId, b.themeId}.toList()..sort();
        final families = <ThemeFamily>{a.family, b.family}.toList()
          ..sort((x, y) => x.index.compareTo(y.index));

        final key = '${category.name}|${themes.join(',')}|${lenses.map((l) => l.storageKey).join(',')}';
        if (!seen.add(key)) continue;

        tensions.add(
          PersonalityTension(
            category: category,
            themeIds: themes,
            agreementLensIds: lenses,
            families: families,
            reasonCode: reason,
          ),
        );
      }
    }

    return tensions;
  }

  static List<PersonalityTension> _dedupe(List<PersonalityTension> tensions) {
    final seen = <String>{};
    final out = <PersonalityTension>[];

    for (final tension in tensions) {
      final key = [
        tension.category.name,
        tension.reasonCode,
        ...tension.themeIds,
        ...tension.agreementLensIds.map((l) => l.storageKey),
      ].join('|');
      if (seen.add(key)) out.add(tension);
    }

    return out;
  }
}
