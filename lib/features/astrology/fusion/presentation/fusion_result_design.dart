import 'package:flutter/material.dart';

/// Premium cosmic design tokens — Astrology Fusion Result.
abstract final class FusionResultDesign {
  static const backgroundTop = Color(0xFF0B0820);
  static const backgroundMid = Color(0xFF120B2F);
  static const backgroundBottom = Color(0xFF1B1147);

  static const gold = Color(0xFFE8C547);
  static const goldSoft = Color(0xFFFFE9A8);
  static const purple = Color(0xFF9B7BD4);
  static const purpleSoft = Color(0xFF7B5EA7);
  static const textPrimary = Color(0xFFF5F0FF);
  static const textSecondary = Color(0xFFB8AED0);
  static const textMuted = Color(0xFF8A7FA3);
  static const cardFill = Color(0xFF1A1238);
  static const cardBorder = Color(0x33E8C547);
  static const warningAccent = Color(0xFF9B7BD4);

  static const heroRadius = 28.0;
  static const cardRadius = 24.0;
  static const sectionGap = 28.0;
  static const cardGap = 14.0;

  static const heroMinHeight = 620.0;
  static const heroHeadlineSize = 44.0;
  static const heroArtworkWidth = 280.0;
  static const heroArtworkHeightNarrow = 220.0;
  static const wideBreakpoint = 720.0;

  static LinearGradient pageBackground = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundMid, backgroundBottom],
  );

  static LinearGradient heroGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A1A52), Color(0xFF150D30), Color(0xFF0A0618)],
  );

  static BoxShadow cosmicGlow = BoxShadow(
    color: gold.withValues(alpha: 0.12),
    blurRadius: 32,
    spreadRadius: 0,
    offset: const Offset(0, 12),
  );

  static BoxDecoration cosmicCard({Color? fill}) {
    return BoxDecoration(
      color: fill ?? cardFill.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: cardBorder),
      boxShadow: [cosmicGlow],
    );
  }
}
