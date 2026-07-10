import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Premium full-page loading experience for Thai Astrology.
///
/// Replaces the bare centered spinner / blank page. Renders a hero loading card
/// plus animated skeletons that mirror the real result layout (hero, insight
/// cards ×2, advice, dashboard, source) so there is no layout shift when the
/// completed [ThaiMirrorResultPage] fades in.
class ThaiMirrorLoadingView extends StatefulWidget {
  const ThaiMirrorLoadingView({
    super.key,
    this.deepAnalysis = false,
  });

  /// After the load exceeds ~4s the entry page flips this to reassure the user
  /// that deeper analysis is still in progress (not frozen).
  final bool deepAnalysis;

  static const titleTh = 'กำลังเปิดดวงไทยของคุณ...';
  static const subtitleTh =
      'เรากำลังอ่านข้อมูลวันเกิดของคุณ\nและวิเคราะห์ตามหลักโหราศาสตร์ไทย';
  static const deepSubtitleTh =
      'กำลังวิเคราะห์เชิงลึก...\nผลลัพธ์ของคุณกำลังจะมา ขออีกสักครู่';

  @override
  State<ThaiMirrorLoadingView> createState() => _ThaiMirrorLoadingViewState();
}

class _ThaiMirrorLoadingViewState extends State<ThaiMirrorLoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 768;
    final isMobile = width < 600;
    final horizontalPadding = isWide ? 32.0 : 16.0;
    final maxContentWidth = isWide ? 720.0 : double.infinity;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroLoadingCard(context),
              const SizedBox(height: 20),
              _bannerSkeleton(),
              const SizedBox(height: 28),
              _sectionSkeleton(cardCount: isMobile ? 3 : 3, mobile: isMobile),
              const SizedBox(height: 28),
              _sectionSkeleton(cardCount: 3, mobile: isMobile),
              const SizedBox(height: 28),
              _adviceSkeleton(),
              const SizedBox(height: 28),
              _dashboardSkeleton(mobile: isMobile),
              const SizedBox(height: 28),
              _sourceSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroLoadingCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = widget.deepAnalysis
        ? ThaiMirrorLoadingView.deepSubtitleTh
        : ThaiMirrorLoadingView.subtitleTh;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.62),
            scheme.secondaryContainer.withValues(alpha: 0.38),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          _PulsingMoon(animation: _pulse, color: scheme.primary),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              ThaiMirrorLoadingView.titleTh,
              key: ValueKey(widget.deepAnalysis),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.3,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              subtitle,
              key: ValueKey('sub_${widget.deepAnalysis}'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _IndeterminateBar(animation: _shimmer, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            'ใช้เวลาประมาณ 2–5 วินาที',
            style: TextStyle(
              fontSize: 12.5,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bannerSkeleton() {
    return _ShimmerBlock(
      animation: _shimmer,
      height: 56,
      radius: 14,
    );
  }

  Widget _sectionSkeleton({required int cardCount, required bool mobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBlock(animation: _shimmer, width: 200, height: 22, radius: 8),
        const SizedBox(height: 14),
        if (mobile)
          Column(
            children: [
              for (var i = 0; i < cardCount; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _cardSkeleton(),
              ],
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cardCount; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _cardSkeleton()),
              ],
            ],
          ),
      ],
    );
  }

  Widget _cardSkeleton() {
    return _SkeletonContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(animation: _shimmer, width: 36, height: 36, radius: 10),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBlock(
                    animation: _shimmer, width: 120, height: 15, radius: 6),
                const SizedBox(height: 10),
                _ShimmerBlock(
                    animation: _shimmer,
                    width: double.infinity,
                    height: 11,
                    radius: 6),
                const SizedBox(height: 7),
                _ShimmerBlock(
                    animation: _shimmer, width: 160, height: 11, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adviceSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBlock(animation: _shimmer, width: 180, height: 22, radius: 8),
        const SizedBox(height: 14),
        _SkeletonContainer(
          tinted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBlock(
                  animation: _shimmer,
                  width: double.infinity,
                  height: 12,
                  radius: 6),
              const SizedBox(height: 8),
              _ShimmerBlock(
                  animation: _shimmer,
                  width: double.infinity,
                  height: 12,
                  radius: 6),
              const SizedBox(height: 8),
              _ShimmerBlock(
                  animation: _shimmer, width: 220, height: 12, radius: 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dashboardSkeleton({required bool mobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerBlock(animation: _shimmer, width: 210, height: 22, radius: 8),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = mobile ? 1 : 3;
            final cardWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var i = 0; i < 5; i++)
                  SizedBox(width: cardWidth, child: _dashboardCardSkeleton()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _dashboardCardSkeleton() {
    return _SkeletonContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(animation: _shimmer, width: 90, height: 15, radius: 6),
          const SizedBox(height: 12),
          _ShimmerBlock(
              animation: _shimmer,
              width: double.infinity,
              height: 11,
              radius: 6),
          const SizedBox(height: 7),
          _ShimmerBlock(
              animation: _shimmer,
              width: double.infinity,
              height: 11,
              radius: 6),
          const SizedBox(height: 7),
          _ShimmerBlock(
              animation: _shimmer, width: 130, height: 11, radius: 6),
        ],
      ),
    );
  }

  Widget _sourceSkeleton() {
    return _SkeletonContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBlock(animation: _shimmer, width: 160, height: 18, radius: 6),
          const SizedBox(height: 14),
          _ShimmerBlock(
              animation: _shimmer,
              width: double.infinity,
              height: 11,
              radius: 6),
          const SizedBox(height: 7),
          _ShimmerBlock(
              animation: _shimmer,
              width: double.infinity,
              height: 11,
              radius: 6),
          const SizedBox(height: 7),
          _ShimmerBlock(
              animation: _shimmer, width: 200, height: 11, radius: 6),
        ],
      ),
    );
  }
}

class _SkeletonContainer extends StatelessWidget {
  const _SkeletonContainer({required this.child, this.tinted = false});

  final Widget child;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tinted
            ? scheme.primaryContainer.withValues(alpha: 0.18)
            : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

/// Shimmering placeholder block that animates a light sweep across itself.
class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.animation,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + animation.value * 2, 0),
              end: Alignment(1 + animation.value * 2, 0),
              colors: const [
                Color(0xFFECE6F4),
                Color(0xFFF7F3FB),
                Color(0xFFECE6F4),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Soft pulsing moon glyph for the hero loading card.
class _PulsingMoon extends StatelessWidget {
  const _PulsingMoon({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final scale = 0.96 + t * 0.08;
        return Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.10 + t * 0.06),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10 + t * 0.10),
                blurRadius: 18 + t * 10,
                spreadRadius: t * 2,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: Text(
              '☽',
              style: TextStyle(
                fontSize: 32,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Indeterminate progress bar with a moving highlight.
class _IndeterminateBar extends StatelessWidget {
  const _IndeterminateBar({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                const segment = 0.4;
                final start = (animation.value * (1 + segment)) - segment;
                return Stack(
                  children: [
                    Container(color: color.withValues(alpha: 0.14)),
                    Positioned(
                      left: math.max(0, start) * w,
                      width: segment * w,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
