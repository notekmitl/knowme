import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';

import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../mapping/knowme_mirror_theme_mapping_contract.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Maps [ThaiThemeBundle] into MV1 theme signals.
abstract final class KnowMeMirrorAstrologyAdapter {
  static const mappingRulePrefix = 'mv1.astrology.category';

  static List<KnowMeMirrorThemeSignal> extract(ThaiThemeBundle bundle) {
    final signals = <KnowMeMirrorThemeSignal>[];

    for (final theme in bundle.themes) {
      final signal = _fromTheme(bundle, theme);
      if (signal != null) signals.add(signal);
    }

    return signals;
  }

  static KnowMeMirrorThemeSignal? _fromTheme(
    ThaiThemeBundle bundle,
    ThaiThemeScore theme,
  ) {
    final mirrorKey = KnowMeMirrorThemeMappingContract.mirrorKeyForAstrologyTheme(
      themeId: theme.themeId,
      categoryId: theme.category.id,
    );
    if (mirrorKey == null) return null;

    final dimension =
        KnowMeMirrorThemeMappingContract.dimensionForMirrorKey(mirrorKey);
    final patternFamily =
        KnowMeMirrorThemeMappingContract.patternFamilyForMirrorKey(mirrorKey);
    if (dimension == null || patternFamily == null) return null;

    final factIds = theme.contributions
        .map((contribution) => contribution.sourceFactId)
        .toSet();

    return KnowMeMirrorThemeSignal(
      systemId: KnowMeMirrorSystemId.thaiAstrology,
      sourceType: KnowMeMirrorSourceType.astrologyTheme,
      sourceLensKey: KnowMeMirrorSystemId.thaiAstrology.id,
      themeId: theme.themeId,
      mirrorKey: mirrorKey,
      mirrorDimension: dimension,
      patternFamily: patternFamily,
      confidence: _confidenceScore(theme.confidence),
      prominence: theme.score,
      evidenceCount: factIds.length,
      sourceSnapshotId: bundle.bundleId,
      mappingRuleId: '$mappingRulePrefix.${theme.category.id}',
      interpretationIds: [bundle.sourceInterpretationBundleId],
      signalIds: factIds.toList()..sort(),
      meaningIds: theme.contributions.map((c) => c.contentKey).toSet().toList()
        ..sort(),
    );
  }

  static double _confidenceScore(ThaiThemeConfidenceLevel level) {
    return switch (level) {
      ThaiThemeConfidenceLevel.high => 0.85,
      ThaiThemeConfidenceLevel.medium => 0.65,
      ThaiThemeConfidenceLevel.low => 0.45,
    };
  }
}
