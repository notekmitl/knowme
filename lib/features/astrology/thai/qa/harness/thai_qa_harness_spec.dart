import 'package:flutter/material.dart';

/// Viewport presets the QA Harness can frame the production report inside, so a
/// single URL can reproduce desktop / tablet / mobile layouts deterministically.
enum ThaiQaViewport { full, desktop, tablet, mobile }

extension ThaiQaViewportInfo on ThaiQaViewport {
  /// Logical width to constrain the framed report to (null = fill available).
  double? get width => switch (this) {
        ThaiQaViewport.full => null,
        ThaiQaViewport.desktop => 1440,
        ThaiQaViewport.tablet => 768,
        ThaiQaViewport.mobile => 390,
      };

  String get id => name;

  static ThaiQaViewport parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'desktop':
        return ThaiQaViewport.desktop;
      case 'tablet':
        return ThaiQaViewport.tablet;
      case 'mobile':
        return ThaiQaViewport.mobile;
      case 'full':
      case '':
      case null:
        return ThaiQaViewport.full;
      default:
        return ThaiQaViewport.full;
    }
  }
}

/// Declarative description of a single QA Harness render.
///
/// Everything the harness needs is captured here so a render is fully described
/// by its query string — making URLs shareable and screenshots deterministic.
/// The harness reuses the *production* pipeline + page; this spec only chooses
/// the inputs and the surrounding frame (viewport, theme, locale, scenario).
@immutable
class ThaiQaHarnessSpec {
  const ThaiQaHarnessSpec({
    this.profileId = 'A',
    this.ageOverride,
    this.futureYears,
    this.viewport = ThaiQaViewport.full,
    this.brightness = Brightness.light,
    this.locale = const Locale('th'),
    this.forceNoBirthTime = false,
  });

  /// QA profile selector — A … H (case-insensitive).
  final String profileId;

  /// Explicit current age for the Life Timeline ("คุณอยู่ช่วงไหนของชีวิต").
  final int? ageOverride;

  /// Simulate aging N years from today (future scenario). Ignored when
  /// [ageOverride] is set.
  final int? futureYears;

  final ThaiQaViewport viewport;
  final Brightness brightness;
  final Locale locale;

  /// Render the "no birth time" product state (confidence banner copy etc.).
  final bool forceNoBirthTime;

  bool get isDark => brightness == Brightness.dark;

  /// Stable token used for deterministic screenshot filenames.
  String get screenshotToken {
    final parts = <String>[
      'profile_${profileId.toLowerCase()}',
      viewport.id,
      isDark ? 'dark' : 'light',
      locale.languageCode,
      if (ageOverride != null) 'age$ageOverride',
      if (futureYears != null) 'future$futureYears',
      if (forceNoBirthTime) 'notime',
    ];
    return parts.join('_');
  }

  static ThaiQaHarnessSpec fromQueryParameters(Map<String, String> q) {
    int? parseInt(String? raw) {
      if (raw == null) return null;
      return int.tryParse(raw.trim());
    }

    final scenario = q['scenario']?.toLowerCase().trim();
    final forceNoBirthTime = scenario == 'no_time' ||
        scenario == 'notime' ||
        q['birthtime']?.toLowerCase().trim() == 'false';

    final brightness = (q['theme']?.toLowerCase().trim() == 'dark')
        ? Brightness.dark
        : Brightness.light;

    final localeCode = q['locale']?.toLowerCase().trim();
    final locale =
        localeCode == 'en' ? const Locale('en') : const Locale('th');

    return ThaiQaHarnessSpec(
      profileId: (q['profile'] ?? 'A').toUpperCase(),
      ageOverride: parseInt(q['age']),
      futureYears: parseInt(q['future']),
      viewport: ThaiQaViewportInfo.parse(q['viewport']),
      brightness: brightness,
      locale: locale,
      forceNoBirthTime: forceNoBirthTime,
    );
  }
}
