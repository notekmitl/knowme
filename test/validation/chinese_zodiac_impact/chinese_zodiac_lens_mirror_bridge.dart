import 'package:knowme/features/astrology/fusion/adapters/adapter_helpers.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/mirror_v3/engine/mapping/knowme_mirror_theme_mapping_contract.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_source_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';

/// Validation-only bridge — maps BaZi/Western fusion lens outputs into MV1 signals
/// so downstream foundation layers can be measured without modifying Mirror Platform.
abstract final class ChineseZodiacImpactLensMirrorBridge {
  static List<KnowMeMirrorThemeSignal> fromLensOutputs(
    List<LensThemeOutput> outputs, {
    required String sourceSnapshotId,
  }) {
    final signals = <KnowMeMirrorThemeSignal>[];

    for (final output in outputs) {
      final mirrorKey = KnowMeMirrorThemeMappingContract.mirrorKeyForAstrologyTheme(
        themeId: output.themeId,
        categoryId: output.category.id,
      );
      if (mirrorKey == null) continue;

      final dimension =
          KnowMeMirrorThemeMappingContract.dimensionForMirrorKey(mirrorKey);
      final patternFamily =
          KnowMeMirrorThemeMappingContract.patternFamilyForMirrorKey(mirrorKey);
      if (dimension == null || patternFamily == null) continue;

      signals.add(
        KnowMeMirrorThemeSignal(
          systemId: _systemIdForLens(output.lensId),
          sourceType: KnowMeMirrorSourceType.astrologyTheme,
          sourceLensKey: output.lensId,
          themeId: output.themeId,
          mirrorKey: mirrorKey,
          mirrorDimension: dimension,
          patternFamily: patternFamily,
          confidence: output.confidence,
          prominence: output.confidence,
          evidenceCount: output.evidence.length,
          sourceSnapshotId: sourceSnapshotId,
          mappingRuleId: 'validation.zodiac_impact.${output.category.id}',
          signalIds: output.evidence,
        ),
      );
    }

    return signals;
  }

  static KnowMeMirrorSystemId _systemIdForLens(String lensId) {
    if (lensId == FusionAdapterHelpers.westernLensId) {
      return KnowMeMirrorSystemId.thaiAstrology;
    }
    return KnowMeMirrorSystemId.knowMeMirror;
  }
}
