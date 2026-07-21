import 'package:flutter/material.dart';

import 'home_screen_v3_models.dart';
import 'home_v35_design.dart';

/// Shared theme icon + accent colors for Home V3.5.
abstract final class HomeV35ThemeVisuals {
  static IconData iconFor(HomeThemeVisualKind kind) {
    return switch (kind) {
      HomeThemeVisualKind.autonomy => Icons.flight_rounded,
      HomeThemeVisualKind.growth => Icons.spa_rounded,
      HomeThemeVisualKind.adaptability => Icons.waves_rounded,
      HomeThemeVisualKind.reflection => Icons.auto_awesome_rounded,
      HomeThemeVisualKind.structure => Icons.grid_view_rounded,
      HomeThemeVisualKind.relationships => Icons.favorite_rounded,
      HomeThemeVisualKind.expression => Icons.record_voice_over_rounded,
      HomeThemeVisualKind.generic => Icons.star_rounded,
    };
  }

  static Color accentFor(HomeThemeVisualKind kind) {
    return switch (kind) {
      HomeThemeVisualKind.autonomy => const Color(0xFF9B7BD4),
      HomeThemeVisualKind.growth => const Color(0xFF5CB88A),
      HomeThemeVisualKind.adaptability => const Color(0xFF5B9FD4),
      HomeThemeVisualKind.reflection => const Color(0xFF8B7BD8),
      HomeThemeVisualKind.structure => const Color(0xFF7A8B9E),
      HomeThemeVisualKind.relationships => const Color(0xFFE07A9A),
      HomeThemeVisualKind.expression => const Color(0xFFD4A85B),
      HomeThemeVisualKind.generic => HomeV35Design.purpleAccent,
    };
  }

  static Color softBackgroundFor(HomeThemeVisualKind kind) {
    return accentFor(kind).withValues(alpha: 0.12);
  }
}
