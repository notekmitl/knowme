import 'package:knowme/data/models/astrology_chart_model.dart';

import 'adapter_helpers.dart';
import 'lens_theme_output.dart';
import 'mapping/western_sign_theme_mapping.dart';

/// Maps Western Natal chart data → [LensThemeOutput] via [FusionThemeRegistry] only.
abstract final class WesternRealAdapter {
  static const double _sunConfidence = 0.85;
  static const double _moonConfidence = 0.8;
  static const double _risingConfidence = 0.75;
  static const double _elementSummaryConfidence = 0.7;
  static const double _modalitySummaryConfidence = 0.65;

  static List<LensThemeOutput> adapt(AstrologyChartModel chart) {
    final outputs = <LensThemeOutput>[];

    _addPlacementThemes(
      outputs: outputs,
      placement: 'sun',
      label: 'Sun Sign',
      rawSign: chart.big3['sun'],
      fallback: () => _planetSign(chart.planets, 'sun'),
      confidence: _sunConfidence,
    );
    _addPlacementThemes(
      outputs: outputs,
      placement: 'moon',
      label: 'Moon Sign',
      rawSign: chart.big3['moon'],
      fallback: () => _planetSign(chart.planets, 'moon'),
      confidence: _moonConfidence,
    );
    _addPlacementThemes(
      outputs: outputs,
      placement: 'rising',
      label: 'Rising Sign',
      rawSign: chart.big3['rising'],
      fallback: () => _planetSign(chart.planets, 'rising'),
      confidence: _risingConfidence,
    );

    _addSummaryThemes(
      outputs: outputs,
      placements: _bigThreeSigns(chart),
    );

    return FusionAdapterHelpers.dedupeByTheme(outputs);
  }

  static void _addPlacementThemes({
    required List<LensThemeOutput> outputs,
    required String placement,
    required String label,
    required dynamic rawSign,
    required String? Function() fallback,
    required double confidence,
  }) {
    final sign = _normalizeSign(rawSign) ?? fallback();
    if (sign == null) return;

    for (final themeId in WesternSignThemeMapping.themesForSign(sign)) {
      final output = FusionAdapterHelpers.buildRegistered(
        lensId: FusionAdapterHelpers.westernLensId,
        themeId: themeId,
        confidence: confidence,
        evidence: ['$label: $sign'],
      );
      if (output != null) outputs.add(output);
    }
  }

  static void _addSummaryThemes({
    required List<LensThemeOutput> outputs,
    required List<String> placements,
  }) {
    if (placements.isEmpty) return;

    final elementCounts = <String, int>{
      'fire': 0,
      'earth': 0,
      'air': 0,
      'water': 0,
    };
    final modalityCounts = <String, int>{
      'cardinal': 0,
      'fixed': 0,
      'mutable': 0,
    };

    for (final sign in placements) {
      final meta = _signMeta[sign];
      if (meta == null) continue;
      elementCounts[meta.$1.name] = (elementCounts[meta.$1.name] ?? 0) + 1;
      modalityCounts[meta.$2.name] = (modalityCounts[meta.$2.name] ?? 0) + 1;
    }

    final dominantElement = _dominantKey(elementCounts);
    if (dominantElement != null) {
      for (final themeId
          in WesternSignThemeMapping.dominantElementThemes[dominantElement] ??
              const []) {
        final output = FusionAdapterHelpers.buildRegistered(
          lensId: FusionAdapterHelpers.westernLensId,
          themeId: themeId,
          confidence: _elementSummaryConfidence,
          evidence: ['Element Summary: $dominantElement'],
        );
        if (output != null) outputs.add(output);
      }
    }

    final dominantModality = _dominantKey(modalityCounts);
    if (dominantModality != null) {
      for (final themeId
          in WesternSignThemeMapping.dominantModalityThemes[dominantModality] ??
              const []) {
        final output = FusionAdapterHelpers.buildRegistered(
          lensId: FusionAdapterHelpers.westernLensId,
          themeId: themeId,
          confidence: _modalitySummaryConfidence,
          evidence: ['Modality Summary: $dominantModality'],
        );
        if (output != null) outputs.add(output);
      }
    }
  }

  static List<String> _bigThreeSigns(AstrologyChartModel chart) {
    final out = <String>[];
    for (final raw in [
      chart.big3['sun'],
      chart.big3['moon'],
      chart.big3['rising'],
    ]) {
      final sign = _normalizeSign(raw);
      if (sign != null) out.add(sign);
    }
    return out;
  }

  static String? _planetSign(Map<String, dynamic> planets, String key) {
    final value = planets[key];
    if (value is Map) return _normalizeSign(value['sign']);
    if (value is String) return _normalizeSign(value);
    return null;
  }

  static String? _dominantKey(Map<String, int> counts) {
    String? bestKey;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestKey = entry.key;
      }
    }
    return bestCount > 0 ? bestKey : null;
  }

  static String? _normalizeSign(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    final key = trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
    return _signMeta.containsKey(key) ? key : null;
  }
}

enum _ZodiacElement { fire, earth, air, water }

enum _ZodiacModality { cardinal, fixed, mutable }

const _signMeta = {
  'Aries': (_ZodiacElement.fire, _ZodiacModality.cardinal),
  'Taurus': (_ZodiacElement.earth, _ZodiacModality.fixed),
  'Gemini': (_ZodiacElement.air, _ZodiacModality.mutable),
  'Cancer': (_ZodiacElement.water, _ZodiacModality.cardinal),
  'Leo': (_ZodiacElement.fire, _ZodiacModality.fixed),
  'Virgo': (_ZodiacElement.earth, _ZodiacModality.mutable),
  'Libra': (_ZodiacElement.air, _ZodiacModality.cardinal),
  'Scorpio': (_ZodiacElement.water, _ZodiacModality.fixed),
  'Sagittarius': (_ZodiacElement.fire, _ZodiacModality.mutable),
  'Capricorn': (_ZodiacElement.earth, _ZodiacModality.cardinal),
  'Aquarius': (_ZodiacElement.air, _ZodiacModality.fixed),
  'Pisces': (_ZodiacElement.water, _ZodiacModality.mutable),
};
