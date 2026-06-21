import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';

import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../mapping/knowme_mirror_theme_mapping_contract.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Maps personality lens theme outputs into MV1 theme signals.
abstract final class KnowMeMirrorPersonalityAdapter {
  static const mappingRulePrefix = 'mv1.personality.theme';

  static List<KnowMeMirrorThemeSignal> extractThemes({
    required KnowMeMirrorSystemId systemId,
    required KnowMeMirrorSourceType sourceType,
    required String sourceLensKey,
    required String sourceSnapshotId,
    required List<PersonalityThemeInput> themes,
  }) {
    final signals = <KnowMeMirrorThemeSignal>[];

    for (final theme in themes) {
      final signal = _fromTheme(
        systemId: systemId,
        sourceType: sourceType,
        sourceLensKey: sourceLensKey,
        sourceSnapshotId: sourceSnapshotId,
        theme: theme,
      );
      if (signal != null) signals.add(signal);
    }

    return signals;
  }

  static KnowMeMirrorThemeSignal? _fromTheme({
    required KnowMeMirrorSystemId systemId,
    required KnowMeMirrorSourceType sourceType,
    required String sourceLensKey,
    required String sourceSnapshotId,
    required PersonalityThemeInput theme,
  }) {
    final mirrorKey = KnowMeMirrorThemeMappingContract.mirrorKeyForPersonalityTheme(
      themeId: theme.themeId,
      categoryId: theme.category.id,
    );
    if (mirrorKey == null) return null;

    final dimension =
        KnowMeMirrorThemeMappingContract.dimensionForMirrorKey(mirrorKey);
    final patternFamily =
        KnowMeMirrorThemeMappingContract.patternFamilyForMirrorKey(mirrorKey);
    if (dimension == null || patternFamily == null) return null;

    return KnowMeMirrorThemeSignal(
      systemId: systemId,
      sourceType: sourceType,
      sourceLensKey: sourceLensKey,
      themeId: theme.themeId,
      mirrorKey: mirrorKey,
      mirrorDimension: dimension,
      patternFamily: patternFamily,
      confidence: theme.confidence.clamp(0.0, 1.0),
      prominence: theme.prominence,
      evidenceCount: theme.evidenceCount,
      sourceSnapshotId: sourceSnapshotId,
      mappingRuleId: '$mappingRulePrefix.${theme.themeId}',
    );
  }
}

class PersonalityThemeInput {
  const PersonalityThemeInput({
    required this.themeId,
    required this.category,
    required this.confidence,
    required this.prominence,
    required this.evidenceCount,
  });

  final String themeId;
  final FusionCategory category;
  final double confidence;
  final double prominence;
  final int evidenceCount;
}
