import 'package:knowme/core/i18n/app_text.dart';

import '../domain/eq_models.dart';
import '../domain/eq_test_type.dart';

/// Deterministic result copy (regenerated from test + level + AppText).
abstract final class EqResultContent {
  static String _key(EqTestType testType, String suffix) =>
      '${testType.testId}_$suffix';

  static String heroForLevel(EqTestType testType, String level) =>
      switch (level) {
        EqLevelIds.emerging => AppText.t(_key(testType, 'hero_emerging')),
        EqLevelIds.moderate => AppText.t(_key(testType, 'hero_moderate')),
        EqLevelIds.strong => AppText.t(_key(testType, 'hero_strong')),
        _ => AppText.t(_key(testType, 'hero_moderate')),
      };

  static String tendencyForLevel(EqTestType testType, String level) =>
      switch (level) {
        EqLevelIds.emerging =>
          AppText.t(_key(testType, 'tendency_emerging')),
        EqLevelIds.moderate => AppText.t(_key(testType, 'tendency_moderate')),
        EqLevelIds.strong => AppText.t(_key(testType, 'tendency_strong')),
        _ => AppText.t(_key(testType, 'tendency_moderate')),
      };

  static List<String> guidanceForLevel(EqTestType testType, String level) =>
      switch (level) {
        EqLevelIds.emerging => [
            AppText.t(_key(testType, 'guidance_emerging_1')),
            AppText.t(_key(testType, 'guidance_emerging_2')),
          ],
        EqLevelIds.moderate => [
            AppText.t(_key(testType, 'guidance_moderate_1')),
            AppText.t(_key(testType, 'guidance_moderate_2')),
          ],
        EqLevelIds.strong => [
            AppText.t(_key(testType, 'guidance_strong_1')),
            AppText.t(_key(testType, 'guidance_strong_2')),
          ],
        _ => [AppText.t(_key(testType, 'guidance_moderate_1'))],
      };

  static String disclosureForLevel(
    EqTestType testType,
    String level,
    int scoredCount,
  ) {
    final base = switch (level) {
      EqLevelIds.emerging =>
        AppText.t(_key(testType, 'disclosure_emerging')),
      EqLevelIds.moderate => AppText.t(_key(testType, 'disclosure_moderate')),
      EqLevelIds.strong => AppText.t(_key(testType, 'disclosure_strong')),
      _ => AppText.t(_key(testType, 'disclosure_moderate')),
    };
    final countLine = AppText.t('eq_disclosure_count')
        .replaceAll('{count}', '$scoredCount');
    return '$base\n$countLine';
  }

  static String levelLabel(EqTestType testType, String level) => switch (level) {
        EqLevelIds.emerging => AppText.t(_key(testType, 'level_emerging')),
        EqLevelIds.moderate => AppText.t(_key(testType, 'level_moderate')),
        EqLevelIds.strong => AppText.t(_key(testType, 'level_strong')),
        _ => level,
      };

  static String resultTitle(EqTestType testType) =>
      AppText.t(_key(testType, 'result_title'));
}
