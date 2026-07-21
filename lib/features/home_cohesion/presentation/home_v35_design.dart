import 'package:flutter/material.dart';

/// Home V3.5 design tokens — aligned with target UI reference.
abstract final class HomeV35Design {
  static const background = Color(0xFFF3F0F7);
  static const surface = Color(0xFFFFFFFF);
  static const heroGradientStart = Color(0xFF2D1B4E);
  static const heroGradientMid = Color(0xFF1A1030);
  static const heroGradientEnd = Color(0xFF0D0818);
  static const goldCta = Color(0xFFE8C547);
  static const goldAccent = Color(0xFFE8C547);
  static const goldCtaText = Color(0xFF1A1228);
  static const purpleAccent = Color(0xFF7B5EA7);
  static const purpleSoft = Color(0xFFF0E8F8);
  static const textPrimary = Color(0xFF1E1630);
  static const textSecondary = Color(0xFF6B6578);
  static const textMuted = Color(0xFF9B94A8);

  static const heroRadius = 24.0;
  static const cardRadius = 18.0;
  static const signatureRadius = 22.0;
  static const sectionGap = 28.0;
  static const cardGap = 14.0;

  static const heroMinHeight = 380.0;

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  static BoxShadow heroShadow = BoxShadow(
    color: const Color(0xFF2D1B4E).withValues(alpha: 0.35),
    blurRadius: 32,
    offset: const Offset(0, 14),
  );

  static BoxShadow signatureShadow = BoxShadow(
    color: const Color(0xFF7B5EA7).withValues(alpha: 0.12),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}
