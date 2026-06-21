import 'package:flutter/material.dart';

import '../../../models/thai_mirror_lens_source.dart';

/// Compact lens label for Evidence Explorer rows and summaries.
class ThaiMirrorLensBadge extends StatelessWidget {
  const ThaiMirrorLensBadge({
    super.key,
    required this.lensSource,
    this.compact = false,
  });

  final ThaiMirrorLensSource lensSource;
  final bool compact;

  static const lensOrder = <ThaiMirrorLensSource>[
    ThaiMirrorLensSource.lagna,
    ThaiMirrorLensSource.lagnaLord,
    ThaiMirrorLensSource.myanmarSeven,
    ThaiMirrorLensSource.mahabhutaPosition,
  ];

  static String labelFor(ThaiMirrorLensSource source, {bool compact = false}) {
    if (compact) {
      return switch (source) {
        ThaiMirrorLensSource.lagna => 'ลัคนา',
        ThaiMirrorLensSource.lagnaLord => 'เจ้าเรือน',
        ThaiMirrorLensSource.myanmarSeven => 'เลข 7 ตัว',
        ThaiMirrorLensSource.mahabhutaPosition => 'มหาภูติ',
      };
    }

    return switch (source) {
      ThaiMirrorLensSource.lagna => 'ลัคนา',
      ThaiMirrorLensSource.lagnaLord => 'เจ้าเรือนลัคนา',
      ThaiMirrorLensSource.myanmarSeven => 'เลข 7 ตัว',
      ThaiMirrorLensSource.mahabhutaPosition => 'มหาภูติ',
    };
  }

  Color _background(ColorScheme scheme) {
    return switch (lensSource) {
      ThaiMirrorLensSource.lagna =>
        scheme.primaryContainer.withValues(alpha: 0.55),
      ThaiMirrorLensSource.lagnaLord =>
        scheme.secondaryContainer.withValues(alpha: 0.55),
      ThaiMirrorLensSource.myanmarSeven =>
        scheme.tertiaryContainer.withValues(alpha: 0.55),
      ThaiMirrorLensSource.mahabhutaPosition =>
        scheme.surfaceContainerHighest.withValues(alpha: 0.75),
    };
  }

  Color _foreground(ColorScheme scheme) {
    return switch (lensSource) {
      ThaiMirrorLensSource.lagna => scheme.onPrimaryContainer,
      ThaiMirrorLensSource.lagnaLord => scheme.onSecondaryContainer,
      ThaiMirrorLensSource.myanmarSeven => scheme.onTertiaryContainer,
      ThaiMirrorLensSource.mahabhutaPosition => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _background(scheme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        labelFor(lensSource, compact: compact),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _foreground(scheme),
        ),
      ),
    );
  }
}
