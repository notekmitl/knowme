import 'package:flutter/foundation.dart';
import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';

import '../../providers/locale_provider.dart';
import 'astrology_planet_interpretation.dart';

/// Astrology result locale: [LocaleProvider] is source of truth; [AppText.lang] stays in sync.
abstract final class AstrologyResultLocale {
  static const supported = {'th', 'en'};

  /// Call from a widget that already [context.watch]es [LocaleProvider].
  static String langFromProvider(LocaleProvider localeProvider) {
    final lang = localeProvider.locale.languageCode == 'th' ? 'th' : 'en';
    if (AppText.lang != lang) {
      AppText.lang = lang;
    }
    return lang;
  }

  static void apply(String languageCode) {
    final lang = languageCode == 'th' ? 'th' : 'en';
    AppText.lang = lang;
  }

  static bool isThai(String lang) => lang == 'th';

  /// Bilingual Firestore field (`th` / `en`) — never crosses locale on this page.
  static String bilingualField(
    Map<String, dynamic> map,
    String lang, {
    required String preparingKey,
  }) {
    final primary = lang == 'th' ? map['th'] : map['en'];
    if (primary is String && primary.trim().isNotEmpty) {
      return primary.trim();
    }
    return AppText.t(preparingKey);
  }

  /// Big7 interpretations with cross-card semantic dedupe.
  static Map<String, String> planetInterpretationsMap(
    AstrologyChartModel chart,
    String lang,
  ) {
    return AstrologyPlanetInterpretation.composedForChart(chart.planets, lang);
  }

  static String planetInterpretation(
    AstrologyChartModel chart,
    String planetKey,
    String lang, {
    Map<String, dynamic>? planetData,
    Map<String, String>? precomputedBig7,
  }) {
    final key = planetKey.toLowerCase();
    final cached = precomputedBig7?[key];
    if (cached != null && cached.isNotEmpty) return cached;

    final local = AstrologyPlanetInterpretation.composed(
      planetKey: planetKey,
      signRaw: planetData?['sign']?.toString(),
      houseRaw: planetData?['house'],
      lang: lang,
    );
    if (local != null && local.isNotEmpty) return local;

    final text = chart.interpretationForPlanet(
      planetKey,
      isThai: lang == 'th',
      allowAlternateLocale: false,
    );
    if (text.isNotEmpty) return text;
    return AppText.t('astro_planet_interpretation_fallback');
  }

  /// Debug-only: log if primary locale text looks like the other language (heuristic).
  static void assertLocaleIntegrity(String lang, String label, String text) {
    if (!kDebugMode || text.isEmpty) return;
    final hasThai = RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);
    if (lang == 'en' && hasThai) {
      debugPrint(
        'AstrologyResultLocale: [$label] EN mode but text contains Thai script',
      );
    }
    if (lang == 'th' && !hasThai && RegExp(r'[A-Za-z]{4,}').hasMatch(text)) {
      // Long Latin runs in TH-only UI chrome are flagged; backend EN body in TH mode is avoided separately.
    }
  }
}
