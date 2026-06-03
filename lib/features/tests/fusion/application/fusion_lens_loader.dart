import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/features/tests/eq/application/eq_summary_loader.dart';
import 'package:knowme/features/tests/eq/domain/eq_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_summary_models.dart';
import 'package:knowme/features/tests/eq/domain/eq_test_type.dart';
import 'package:knowme/features/tests/mbti_summary/application/mbti_summary_loader.dart';
import 'package:knowme/features/tests/mbti_summary/domain/mbti_summary_models.dart';

import '../domain/fusion_lens_models.dart';
import '../domain/fusion_models.dart';
import 'fusion_loader.dart';

/// Loads high-level lens tags from `results/*` summaries (read-only).
class FusionLensLoader {
  FusionLensLoader({
    FusionLoader? fusionLoader,
    MbtiSummaryLoader? mbtiSummaryLoader,
    EqSummaryLoader? eqSummaryLoader,
  })  : _fusionLoader = fusionLoader ?? FusionLoader(),
        _mbtiSummaryLoader = mbtiSummaryLoader ?? MbtiSummaryLoader(),
        _eqSummaryLoader = eqSummaryLoader ?? EqSummaryLoader();

  final FusionLoader _fusionLoader;
  final MbtiSummaryLoader _mbtiSummaryLoader;
  final EqSummaryLoader _eqSummaryLoader;

  Future<FusionLensInput> load({String? uid}) async {
    try {
      final effectiveUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
      final fusionInput = await _fusionLoader.load(uid: effectiveUid);
      final lenses = <FusionLensSnapshot>[];
      MbtiSummaryAlignment? alignment;

      final astroThemes = _themesFromAstrology(fusionInput.astrologyResult);
      if (astroThemes.isNotEmpty) {
        lenses.add(
          FusionLensSnapshot(
            kind: FusionLensKind.astrology,
            themes: astroThemes,
          ),
        );
      }

      if (effectiveUid != null) {
        final summary = await _mbtiSummaryLoader.loadFusionContent(effectiveUid);
        if (summary != null) {
          alignment = summary.view.alignment;
          final personalityThemes = _themesFromPersonalitySummary(
            typeCode: summary.view.typeCode,
            topFunctionsLabel: summary.view.topFunctionsLabel,
          );
          if (personalityThemes.isNotEmpty) {
            lenses.add(
              FusionLensSnapshot(
                kind: FusionLensKind.personality,
                themes: personalityThemes,
              ),
            );
          }
        } else {
          final fallback = _themesFromLegacyMbti(fusionInput);
          if (fallback.isNotEmpty) {
            lenses.add(
              FusionLensSnapshot(
                kind: FusionLensKind.personality,
                themes: fallback,
              ),
            );
          }
        }

        final eqInput = await _eqSummaryLoader.loadInput(effectiveUid);
        if (eqInput.hasAllSix) {
          final eqThemes = _themesFromEq(eqInput);
          if (eqThemes.isNotEmpty) {
            lenses.add(
              FusionLensSnapshot(
                kind: FusionLensKind.eq,
                themes: eqThemes,
              ),
            );
          }
        }
      }

      return FusionLensInput(lenses: lenses, mbtiAlignment: alignment);
    } catch (_) {
      return const FusionLensInput();
    }
  }

  static Set<String> _themesFromLegacyMbti(FusionInput input) {
    final themes = <String>{};
    final type = input.mbtiMiniResult?.typeCode;
    if (type != null) themes.addAll(_themesFromMbtiType(type));

    final topFn = _topCognitiveFunctions(input.cognitiveResult?.traits ?? {});
    if (topFn.isNotEmpty) themes.addAll(_themesFromTopFunction(topFn.first));

    return _capThemes(themes);
  }

  static Set<String> _themesFromPersonalitySummary({
    required String typeCode,
    required String topFunctionsLabel,
  }) {
    final themes = <String>{..._themesFromMbtiType(typeCode)};
    final topFn = topFunctionsLabel.split('/').first.trim();
    if (topFn.isNotEmpty) themes.addAll(_themesFromTopFunction(topFn));
    return _capThemes(themes);
  }

  static Set<String> _themesFromAstrology(AstrologyChartModel? chart) {
    if (chart == null) return {};

    final counts = <String, int>{
      'fire': 0,
      'earth': 0,
      'air': 0,
      'water': 0,
    };
    for (final raw in [
      chart.big3['sun'],
      chart.big3['moon'],
      chart.big3['rising'],
    ]) {
      final sign = _normalizeSign(raw);
      final element = sign == null ? null : _signElements[sign];
      if (element == null) continue;
      counts[element] = (counts[element] ?? 0) + 1;
    }

    final themes = <String>{};
    if ((counts['water'] ?? 0) > 0) themes.add(FusionLensThemeIds.emotion);
    if ((counts['air'] ?? 0) > 0) themes.add(FusionLensThemeIds.logic);
    if ((counts['air'] ?? 0) + (counts['fire'] ?? 0) > 0) {
      themes.add(FusionLensThemeIds.exploration);
    }
    if ((counts['earth'] ?? 0) + (counts['water'] ?? 0) > 0) {
      themes.add(FusionLensThemeIds.reflection);
    }
    if ((counts['fire'] ?? 0) + (counts['water'] ?? 0) > 0) {
      themes.add(FusionLensThemeIds.relationship);
    }

    return _capThemes(themes);
  }

  static Set<String> _themesFromMbtiType(String type) {
    final code = type.toUpperCase();
    if (code.length < 4) return {};

    final themes = <String>{};
    themes.add(
      code[0] == 'I'
          ? FusionLensThemeIds.reflection
          : FusionLensThemeIds.relationship,
    );
    themes.add(
      code[1] == 'N'
          ? FusionLensThemeIds.exploration
          : FusionLensThemeIds.logic,
    );
    themes.add(
      code[2] == 'F'
          ? FusionLensThemeIds.emotion
          : FusionLensThemeIds.logic,
    );
    return themes;
  }

  static Set<String> _themesFromTopFunction(String fn) {
    return switch (fn.toUpperCase()) {
      'FI' || 'FE' => {
          FusionLensThemeIds.emotion,
          FusionLensThemeIds.relationship,
        },
      'TI' || 'TE' => {
          FusionLensThemeIds.logic,
          FusionLensThemeIds.reflection,
        },
      'NI' || 'NE' => {
          FusionLensThemeIds.exploration,
          FusionLensThemeIds.reflection,
        },
      'SI' || 'SE' => {
          FusionLensThemeIds.logic,
          FusionLensThemeIds.reflection,
        },
      _ => {FusionLensThemeIds.reflection},
    };
  }

  static Set<String> _themesFromEq(EqSummaryInput input) {
    final themeA = _eqThemeBand(
      input.resultFor(EqTestType.stress)!.level,
      input.resultFor(EqTestType.regulation)!.level,
    );
    final themeB = _eqThemeBand(
      input.resultFor(EqTestType.empathy)!.level,
      input.resultFor(EqTestType.social)!.level,
    );
    final themeC = _eqThemeBand(
      input.resultFor(EqTestType.awareness)!.level,
      input.resultFor(EqTestType.decision)!.level,
    );

    final themes = <String>{};
    if (_levelRank(themeB) >= 1) themes.add(FusionLensThemeIds.relationship);
    if (_levelRank(themeC) >= 1) themes.add(FusionLensThemeIds.reflection);
    if (_levelRank(themeA) <= 1 || _levelRank(themeB) <= 1) {
      themes.add(FusionLensThemeIds.emotion);
    }
    if (_levelRank(themeA) >= 1 && _levelRank(themeC) >= 1) {
      themes.add(FusionLensThemeIds.reflection);
    }

    return _capThemes(themes);
  }

  static String _eqThemeBand(String a, String b) =>
      _levelRank(a) <= _levelRank(b) ? a : b;

  static int _levelRank(String level) => switch (level) {
        EqLevelIds.emerging => 0,
        EqLevelIds.moderate => 1,
        EqLevelIds.strong => 2,
        _ => 1,
      };

  static List<String> _topCognitiveFunctions(Map<String, double> traits) {
    const keys = ['Ne', 'Ni', 'Se', 'Si', 'Te', 'Ti', 'Fe', 'Fi'];
    final scored = <String, double>{};
    for (final key in keys) {
      final value = traits[key];
      if (value != null) scored[key] = value;
    }
    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).take(4).toList();
  }

  static Set<String> _capThemes(Set<String> themes) {
    if (themes.length <= 2) return themes;
    final ordered = FusionLensThemeIds.all
        .where(themes.contains)
        .take(2)
        .toSet();
    return ordered.isEmpty ? themes.take(2).toSet() : ordered;
  }

  static String? _normalizeSign(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();
    return _signElements.containsKey(key) ? key : null;
  }

  static const _signElements = <String, String>{
    'Aries': 'fire',
    'Taurus': 'earth',
    'Gemini': 'air',
    'Cancer': 'water',
    'Leo': 'fire',
    'Virgo': 'earth',
    'Libra': 'air',
    'Scorpio': 'water',
    'Sagittarius': 'fire',
    'Capricorn': 'earth',
    'Aquarius': 'air',
    'Pisces': 'water',
  };
}
