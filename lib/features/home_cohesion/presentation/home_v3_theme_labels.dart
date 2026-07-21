import 'home_screen_v3_models.dart';
import 'home_v38_human_translation.dart';

/// Legacy alias — delegates to V3.8 Human Translation Layer.
@Deprecated('Use HomeV38HumanTranslation instead')
abstract final class HomeV3ThemeLabels {
  static String forThemeId(String themeId) {
    return HomeV38HumanTranslation.signatureLabel(themeId);
  }

  static HomeInsightCardData cardForThemeId(String themeId) {
    return HomeV38HumanTranslation.insightCard(themeId);
  }

  static HomeThemeVisualKind visualKindForLabel(String label) {
    return HomeV38HumanTranslation.insightCard(label).visualKind;
  }
}
