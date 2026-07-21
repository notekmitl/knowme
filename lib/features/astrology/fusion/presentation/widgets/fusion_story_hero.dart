import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import '../fusion_result_v22_copy.dart';
import 'fusion_confidence_badge.dart';
import 'fusion_premium_artwork.dart';

/// Story-driven hero — V2.2 / Global Fusion ready.
class FusionStoryHero extends StatelessWidget {
  const FusionStoryHero({
    super.key,
    required this.data,
    required this.lensTitles,
    required this.alignedCount,
    this.totalLenses = 3,
    this.onExploreDetails,
  });

  final FusionHeroViewModel data;
  final List<String> lensTitles;
  final int alignedCount;
  final int totalLenses;
  final VoidCallback? onExploreDetails;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= FusionResultDesign.wideBreakpoint;

        return Container(
          constraints: const BoxConstraints(
            minHeight: FusionResultDesign.heroMinHeight,
          ),
          decoration: BoxDecoration(
            gradient: FusionResultDesign.heroGradient,
            borderRadius: BorderRadius.circular(FusionResultDesign.heroRadius),
            border: Border.all(color: FusionResultDesign.cardBorder),
            boxShadow: [
              FusionResultDesign.cosmicGlow,
              BoxShadow(
                color: FusionResultDesign.gold.withValues(alpha: 0.08),
                blurRadius: 48,
                spreadRadius: 4,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (isWide)
                const Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: FusionResultDesign.heroArtworkWidth,
                  child: Opacity(
                    opacity: 0.55,
                    child: FusionPremiumArtwork(),
                  ),
                )
              else
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: FusionResultDesign.heroArtworkHeightNarrow,
                  child: Opacity(
                    opacity: 0.35,
                    child: const FusionPremiumArtwork(),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 40, 32, isWide ? 40 : 28),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _StoryContent(hero: this)),
                          const SizedBox(width: 16),
                          const SizedBox(
                            width: FusionResultDesign.heroArtworkWidth * 0.55,
                          ),
                        ],
                      )
                    : _StoryContent(hero: this),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent({required this.hero});

  final FusionStoryHero hero;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GoldGlowHeadline(text: hero.data.headline),
        if (hero.data.supportingReflection.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            hero.data.supportingReflection,
            style: const TextStyle(
              fontSize: 17,
              height: 1.75,
              color: FusionResultDesign.textSecondary,
            ),
          ),
        ],
        if (hero.lensTitles.isNotEmpty) ...[
          const SizedBox(height: 28),
          _FusionEvidence(
            lensTitles: hero.lensTitles,
            alignedCount: hero.alignedCount,
            totalLenses: hero.totalLenses,
          ),
        ],
        if (hero.data.themeChips.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final chip in hero.data.themeChips) _ThemeChip(chip: chip),
            ],
          ),
        ],
        const SizedBox(height: 28),
        _ExploreCta(onTap: hero.onExploreDetails),
      ],
    );
  }
}

class _GoldGlowHeadline extends StatelessWidget {
  const _GoldGlowHeadline({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: FusionResultDesign.heroHeadlineSize,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
        color: FusionResultDesign.gold,
        shadows: [
          Shadow(
            color: FusionResultDesign.gold.withValues(alpha: 0.45),
            blurRadius: 24,
          ),
          Shadow(
            color: FusionResultDesign.gold.withValues(alpha: 0.2),
            blurRadius: 48,
          ),
        ],
      ),
    );
  }
}

class _FusionEvidence extends StatelessWidget {
  const _FusionEvidence({
    required this.lensTitles,
    required this.alignedCount,
    required this.totalLenses,
  });

  final List<String> lensTitles;
  final int alignedCount;
  final int totalLenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FusionResultDesign.purple.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FusionResultV22Copy.fusionEvidenceLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: FusionResultDesign.textMuted.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final title in lensTitles) _LensPill(title: title),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              FusionConfidenceBadge(
                alignedCount: alignedCount,
                totalCount: totalLenses,
                compact: true,
                showLevelLabel: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  FusionResultV22Copy.consensusAlignedLabel(
                    alignedCount,
                    totalLenses,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FusionResultDesign.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LensPill extends StatelessWidget {
  const _LensPill({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: FusionResultDesign.purple.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: FusionResultDesign.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: FusionResultDesign.textPrimary,
        ),
      ),
    );
  }
}

class _ExploreCta extends StatefulWidget {
  const _ExploreCta({this.onTap});

  final VoidCallback? onTap;

  @override
  State<_ExploreCta> createState() => _ExploreCtaState();
}

class _ExploreCtaState extends State<_ExploreCta> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    FusionResultDesign.gold.withValues(alpha: _hovered ? 0.95 : 0.82),
                    FusionResultDesign.goldSoft.withValues(alpha: _hovered ? 0.9 : 0.75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: FusionResultDesign.gold.withValues(
                      alpha: _hovered ? 0.35 : 0.2,
                    ),
                    blurRadius: _hovered ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FusionResultV22Copy.exploreCta,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: FusionResultDesign.backgroundTop.withValues(
                          alpha: 0.92,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: FusionResultDesign.backgroundTop.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatefulWidget {
  const _ThemeChip({required this.chip});

  final FusionThemeChipViewModel chip;

  @override
  State<_ThemeChip> createState() => _ThemeChipState();
}

class _ThemeChipState extends State<_ThemeChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _hovered ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: FusionResultDesign.gold.withValues(
              alpha: _hovered ? 0.45 : 0.2,
            ),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: FusionResultDesign.gold.withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.chip.icon, size: 15, color: FusionResultDesign.goldSoft),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                widget.chip.label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FusionResultDesign.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
