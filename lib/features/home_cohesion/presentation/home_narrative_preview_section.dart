import 'dart:ui';

import 'package:flutter/material.dart';

import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Narrative preview card — UX Conversion Sprint V1.
class HomeNarrativePreviewSection extends StatelessWidget {
  const HomeNarrativePreviewSection({
    super.key,
    required this.data,
    required this.onContinue,
  });

  final HomeNarrativePreviewSectionData data;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (!data.isVisible) return const SizedBox.shrink();

    final title = data.title.isNotEmpty
        ? data.title
        : HomeV3Copy.narrativePreviewTitle(1, data.lockedSectionCount + 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeV35Design.surface,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        boxShadow: [HomeV35Design.cardShadow],
        border: Border.all(
          color: HomeV35Design.goldCta.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HomeV35Design.goldCta.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '🎁 ${HomeV3Copy.narrativePreviewBadge}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: HomeV35Design.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HomeV35Design.textPrimary,
            ),
          ),
          if (data.rewardLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              data.rewardLine,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: HomeV35Design.purpleAccent,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            data.previewText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: HomeV35Design.textPrimary,
            ),
          ),
          if (data.lockedSectionCount > 0) ...[
            const SizedBox(height: 14),
            for (var i = 0; i < data.lockedSectionCount; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BlurredLockedSection(
                  label: i < data.lockedSectionLabels.length
                      ? data.lockedSectionLabels[i]
                      : HomeV3Copy.narrativeLockedSectionLabels[
                          i.clamp(
                            0,
                            HomeV3Copy.narrativeLockedSectionLabels.length - 1,
                          )],
                  hint: HomeV3Copy.narrativePreviewLockedHint,
                ),
              ),
          ],
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContinue,
              style: OutlinedButton.styleFrom(
                foregroundColor: HomeV35Design.purpleAccent,
                side: const BorderSide(color: HomeV35Design.purpleAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(data.ctaLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredLockedSection extends StatelessWidget {
  const _BlurredLockedSection({
    required this.label,
    required this.hint,
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            height: 56,
            width: double.infinity,
            color: HomeV35Design.purpleSoft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: HomeV35Design.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.white.withValues(alpha: 0.35),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: HomeV35Design.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HomeV35Design.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
