import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/tests/mbti_summary/domain/mbti_summary_models.dart';

import '../domain/fusion_lens_models.dart';

/// Deterministic Fusion v1.1 lens synthesis (high-level only, no AI).
abstract final class FusionBuilder {
  static FusionLensContent? build(FusionLensInput input) {
    if (!input.canSynthesize) return null;

    final agreementTheme = _dominantAgreementTheme(input.lenses);
    final tensionKind = _detectTension(input.lenses, input.mbtiAlignment);
    final synthesisKind = _synthesisKind(agreementTheme, tensionKind);

    return FusionLensContent(
      agreement: AppText.t(
        'fusion_v11_agreement_${agreementTheme ?? 'general'}',
      ),
      tension: AppText.t('fusion_v11_tension_$tensionKind'),
      synthesis: AppText.t('fusion_v11_synthesis_$synthesisKind'),
      disclosure: AppText.t('fusion_v11_disclosure'),
    );
  }

  static String? _dominantAgreementTheme(List<FusionLensSnapshot> lenses) {
    final counts = <String, int>{};
    for (final lens in lenses) {
      for (final theme in lens.themes) {
        counts[theme] = (counts[theme] ?? 0) + 1;
      }
    }

    final shared = counts.entries.where((e) => e.value >= 2).toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return _themePriority(a.key).compareTo(_themePriority(b.key));
      });

    if (shared.isNotEmpty) return shared.first.key;

    if (lenses.length < 2 || counts.isEmpty) return null;

    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return _themePriority(a.key).compareTo(_themePriority(b.key));
      });
    return ranked.first.key;
  }

  static String _detectTension(
    List<FusionLensSnapshot> lenses,
    MbtiSummaryAlignment? alignment,
  ) {
    if (alignment == MbtiSummaryAlignment.mixed) return 'head_heart';

    final themes = lenses.expand((l) => l.themes).toSet();
    final hasLogic = themes.contains(FusionLensThemeIds.logic);
    final hasEmotion = themes.contains(FusionLensThemeIds.emotion);
    if (hasLogic && hasEmotion) return 'logic_emotion';

    final hasReflection = themes.contains(FusionLensThemeIds.reflection);
    final hasExploration = themes.contains(FusionLensThemeIds.exploration);
    if (hasReflection && hasExploration) return 'pace';

    if (_lensPrimaryDiffers(lenses, FusionLensThemeIds.logic) &&
        _lensPrimaryDiffers(lenses, FusionLensThemeIds.emotion)) {
      return 'logic_emotion';
    }

    return 'general';
  }

  static bool _lensPrimaryDiffers(
    List<FusionLensSnapshot> lenses,
    String theme,
  ) {
    var withTheme = 0;
    var withoutTheme = 0;
    for (final lens in lenses) {
      if (lens.themes.contains(theme)) {
        withTheme++;
      } else if (lens.themes.isNotEmpty) {
        withoutTheme++;
      }
    }
    return withTheme > 0 && withoutTheme > 0;
  }

  static String _synthesisKind(String? agreementTheme, String tensionKind) {
    if (tensionKind == 'logic_emotion' || tensionKind == 'head_heart') {
      return 'integrator';
    }
    return switch (agreementTheme) {
      FusionLensThemeIds.relationship => 'connector',
      FusionLensThemeIds.reflection ||
      FusionLensThemeIds.emotion =>
        'heart_mind',
      FusionLensThemeIds.logic => 'thinker',
      FusionLensThemeIds.exploration => 'explorer',
      _ => 'general',
    };
  }

  static int _themePriority(String theme) => switch (theme) {
        FusionLensThemeIds.reflection => 0,
        FusionLensThemeIds.relationship => 1,
        FusionLensThemeIds.emotion => 2,
        FusionLensThemeIds.logic => 3,
        FusionLensThemeIds.exploration => 4,
        _ => 5,
      };
}
