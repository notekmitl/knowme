import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_bazi_adapter_bridge.dart';

import 'adapter_helpers.dart';
import 'lens_theme_output.dart';
import 'mapping/bazi_fusion_theme_mapping.dart';

/// Maps BaZi chart data → [LensThemeOutput] via [FusionThemeRegistry] only.
abstract final class BaziRealAdapter {
  static const double _dayMasterConfidence = 0.85;
  static const double _dominantElementConfidence = 0.75;
  static const double _elementBalanceConfidence = 0.7;
  static const int _balanceStrengthThreshold = 2;

  static List<LensThemeOutput> adapt(BaziChartModel chart) {
    final outputs = <LensThemeOutput>[];

    _addDayMasterThemes(outputs, chart.dayMaster);
    _addDominantElementTheme(outputs, chart);
    _addBalanceThemes(outputs, chart.elementBalance);
    outputs.addAll(ZodiacBaziAdapterBridge.adapt(chart.yearAnimal));

    return FusionAdapterHelpers.dedupeByTheme(outputs);
  }

  static void _addDayMasterThemes(
    List<LensThemeOutput> outputs,
    BaziDayMaster dayMaster,
  ) {
    if (dayMaster.element.isEmpty || dayMaster.polarity.isEmpty) return;

    final evidenceLabel =
        'Day Master: ${dayMaster.polarity} ${dayMaster.element}';

    for (final themeId in BaziFusionThemeMapping.themesForDayMaster(
      polarity: dayMaster.polarity,
      element: dayMaster.element,
    )) {
      final output = FusionAdapterHelpers.buildRegistered(
        lensId: FusionAdapterHelpers.baziLensId,
        themeId: themeId,
        confidence: _dayMasterConfidence,
        evidence: [evidenceLabel],
      );
      if (output != null) outputs.add(output);
    }
  }

  static void _addDominantElementTheme(
    List<LensThemeOutput> outputs,
    BaziChartModel chart,
  ) {
    final element = chart.dominantElement?.trim().toLowerCase();
    if (element == null || element.isEmpty) return;

    final themeId = BaziFusionThemeMapping.dominantElementTheme[element];
    if (themeId == null) return;

    final output = FusionAdapterHelpers.buildRegistered(
      lensId: FusionAdapterHelpers.baziLensId,
      themeId: themeId,
      confidence: _dominantElementConfidence,
      evidence: ['Dominant Element: $element'],
    );
    if (output != null) outputs.add(output);
  }

  static void _addBalanceThemes(
    List<LensThemeOutput> outputs,
    BaziElementBalance balance,
  ) {
    final counts = {
      'wood': balance.wood,
      'fire': balance.fire,
      'earth': balance.earth,
      'metal': balance.metal,
      'water': balance.water,
    };

    for (final entry in counts.entries) {
      if (entry.value < _balanceStrengthThreshold) continue;

      final themeId = BaziFusionThemeMapping.balanceStrengthTheme[entry.key];
      if (themeId == null) continue;

      final output = FusionAdapterHelpers.buildRegistered(
        lensId: FusionAdapterHelpers.baziLensId,
        themeId: themeId,
        confidence: _elementBalanceConfidence,
        evidence: ['Element Balance: ${entry.key}=${entry.value}'],
      );
      if (output != null) outputs.add(output);
    }
  }
}
