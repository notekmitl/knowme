import 'package:flutter/material.dart';

import 'home_cosmic_artwork.dart';
import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Premium astrology hero — Home V3.8 identity statement.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.data,
    required this.onViewFullResult,
    required this.onUnlockDeepProfile,
  });

  final HomeHeroSectionData data;
  final void Function() onViewFullResult;
  final void Function() onUnlockDeepProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: HomeV35Design.heroMinHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HomeV35Design.heroRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HomeV35Design.heroGradientStart,
            HomeV35Design.heroGradientMid,
            HomeV35Design.heroGradientEnd,
          ],
        ),
        boxShadow: [HomeV35Design.heroShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _HeroContent(
                    data: data,
                    onAstrologyCta: onViewFullResult,
                    onUnlockCta: onUnlockDeepProfile,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.34,
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Opacity(
                      opacity: 0.95,
                      child: const HomeCosmicArtwork(),
                    ),
                  ),
                ),
              ],
            );
          }

          return Stack(
            children: [
              Positioned(
                right: -20,
                top: 20,
                bottom: 20,
                width: constraints.maxWidth * 0.42,
                child: Opacity(
                  opacity: 0.55,
                  child: const HomeCosmicArtwork(),
                ),
              ),
              _HeroContent(
                data: data,
                onAstrologyCta: onViewFullResult,
                onUnlockCta: onUnlockDeepProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.data,
    required this.onAstrologyCta,
    required this.onUnlockCta,
  });

  final HomeHeroSectionData data;
  final void Function() onAstrologyCta;
  final void Function() onUnlockCta;

  @override
  Widget build(BuildContext context) {
    final heroLabel = data.showUnlockCta
        ? '🔓 Unlock'
        : HomeV3Copy.heroTitle.replaceFirst('🔮 ', '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.showUnlockCta ? '🔓' : '🔮',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                heroLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!data.isAvailable) ...[
            Text(
              data.emptyHint,
              style: TextStyle(
                fontSize: 17,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ] else ...[
            Text(
              data.identity,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.35,
                letterSpacing: -0.2,
              ),
            ),
            if (data.supportingReflection.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                data.supportingReflection,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ],
          ],
          if (data.showUnlockCta) ...[
            const SizedBox(height: 22),
            _UnlockCta(
              title: data.unlockCtaTitle,
              subtitle: data.unlockCtaSubtitle,
              onPressed: onUnlockCta,
            ),
          ] else if (data.canOpenFullResult) ...[
            const SizedBox(height: 22),
            _GoldCta(onPressed: onAstrologyCta),
          ],
        ],
      ),
    );
  }
}

class _UnlockCta extends StatelessWidget {
  const _UnlockCta({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: HomeV35Design.goldCta,
        borderRadius: BorderRadius.circular(999),
        elevation: 4,
        shadowColor: HomeV35Design.goldCta.withValues(alpha: 0.45),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: HomeV35Design.goldCtaText,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HomeV35Design.goldCtaText.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldCta extends StatelessWidget {
  const _GoldCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: HomeV35Design.goldCta,
        borderRadius: BorderRadius.circular(999),
        elevation: 4,
        shadowColor: HomeV35Design.goldCta.withValues(alpha: 0.45),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    HomeV3Copy.viewFullAstrology,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: HomeV35Design.goldCtaText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: HomeV35Design.goldCtaText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
