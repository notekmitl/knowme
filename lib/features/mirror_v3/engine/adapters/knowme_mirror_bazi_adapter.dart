import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/adapters/bazi_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';

import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../mapping/knowme_mirror_theme_mapping_contract.dart';
import '../models/knowme_mirror_theme_signal.dart';

/// Maps BaZi fusion lens outputs (Day Master, Element, Zodiac) into MV1 signals.
abstract final class KnowMeMirrorBaziAdapter {
  static const mappingRulePrefix = 'mv1.bazi.fusion';
  static const sourceLensKey = 'chinese_bazi';

  static List<KnowMeMirrorThemeSignal> extract(BaziChartModel chart) {
    final outputs = BaziRealAdapter.adapt(chart);
    final snapshotId = _snapshotId(chart);

    return outputs
        .map((output) => _fromOutput(output, snapshotId: snapshotId))
        .whereType<KnowMeMirrorThemeSignal>()
        .toList(growable: false);
  }

  static KnowMeMirrorThemeSignal? _fromOutput(
    LensThemeOutput output, {
    required String snapshotId,
  }) {
    final mirrorKey = KnowMeMirrorThemeMappingContract.mirrorKeyForAstrologyTheme(
      themeId: output.themeId,
      categoryId: output.category.id,
    );
    if (mirrorKey == null) return null;

    final dimension =
        KnowMeMirrorThemeMappingContract.dimensionForMirrorKey(mirrorKey);
    final patternFamily =
        KnowMeMirrorThemeMappingContract.patternFamilyForMirrorKey(mirrorKey);
    if (dimension == null || patternFamily == null) return null;

    return KnowMeMirrorThemeSignal(
      systemId: KnowMeMirrorSystemId.knowMeMirror,
      sourceType: KnowMeMirrorSourceType.astrologyTheme,
      sourceLensKey: sourceLensKey,
      themeId: output.themeId,
      mirrorKey: mirrorKey,
      mirrorDimension: dimension,
      patternFamily: patternFamily,
      confidence: output.confidence.clamp(0.0, 1.0),
      prominence: output.confidence.clamp(0.0, 1.0),
      evidenceCount: output.evidence.length,
      sourceSnapshotId: snapshotId,
      mappingRuleId: '$mappingRulePrefix.${output.category.id}',
      signalIds: output.evidence,
    );
  }

  static String _snapshotId(BaziChartModel chart) {
    final animal = chart.yearAnimal.en.trim().toLowerCase();
    final dm = chart.dayMaster.polarity.trim().toLowerCase();
    final element = chart.dayMaster.element.trim().toLowerCase();
    return 'bazi|$animal|${dm}_$element|${chart.inputHash}';
  }
}
