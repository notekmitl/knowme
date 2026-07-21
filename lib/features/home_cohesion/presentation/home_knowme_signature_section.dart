import 'package:flutter/material.dart';

import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';
import 'home_v35_theme_visuals.dart';

/// KnowMe Signature — Home V3.8 Section 2 (between Hero and Insight).
class HomeKnowMeSignatureSection extends StatelessWidget {
  const HomeKnowMeSignatureSection({
    super.key,
    required this.data,
  });

  final HomeKnowMeSignatureSectionData data;

  @override
  Widget build(BuildContext context) {
    if (!data.isVisible && data.emptyHint.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                HomeV3Copy.signatureTitle.replaceFirst('✨ ', ''),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: HomeV35Design.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!data.isVisible)
          _EmptySignature(hint: data.emptyHint)
        else
          _SignatureThemes(labels: data.themeLabels),
      ],
    );
  }
}

class _SignatureThemes extends StatelessWidget {
  const _SignatureThemes({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeV35Design.purpleAccent.withValues(alpha: 0.12),
            HomeV35Design.goldAccent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(HomeV35Design.signatureRadius),
        border: Border.all(
          color: HomeV35Design.purpleAccent.withValues(alpha: 0.18),
        ),
        boxShadow: [HomeV35Design.signatureShadow],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < labels.length; i++)
            _SignatureChip(
              label: labels[i],
              accent: HomeV35ThemeVisuals.accentFor(_kindForIndex(i)),
              background: HomeV35ThemeVisuals.softBackgroundFor(_kindForIndex(i)),
            ),
        ],
      ),
    );
  }

  HomeThemeVisualKind _kindForIndex(int index) {
    return switch (index % 3) {
      0 => HomeThemeVisualKind.autonomy,
      1 => HomeThemeVisualKind.growth,
      _ => HomeThemeVisualKind.adaptability,
    };
  }
}

class _SignatureChip extends StatelessWidget {
  const _SignatureChip({
    required this.label,
    required this.accent,
    required this.background,
  });

  final String label;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: accent,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _EmptySignature extends StatelessWidget {
  const _EmptySignature({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeV35Design.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(HomeV35Design.signatureRadius),
      ),
      child: Text(
        hint,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: HomeV35Design.textSecondary,
        ),
      ),
    );
  }
}
