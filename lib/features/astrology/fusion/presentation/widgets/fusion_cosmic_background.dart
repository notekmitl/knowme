import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fusion_result_design.dart';

/// Layered cosmic depth — V2.2 (static star/nebula/moon layers).
class FusionCosmicBackground extends StatelessWidget {
  const FusionCosmicBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: FusionResultDesign.pageBackground),
        ),
        const _ParallaxLayer(
          offset: 0,
          opacity: 0.35,
          seed: 11,
          starCount: 40,
          color: Colors.white,
        ),
        const _ParallaxLayer(
          offset: 18,
          opacity: 0.22,
          seed: 29,
          starCount: 24,
          color: FusionResultDesign.goldSoft,
        ),
        const _NebulaGlow(),
        const _MoonLight(),
        child,
      ],
    );
  }
}

class _ParallaxLayer extends StatelessWidget {
  const _ParallaxLayer({
    required this.offset,
    required this.opacity,
    required this.seed,
    required this.starCount,
    required this.color,
  });

  final double offset;
  final double opacity;
  final int seed;
  final int starCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -offset),
      child: CustomPaint(
        painter: _StarLayerPainter(
          seed: seed,
          starCount: starCount,
          color: color,
          opacity: opacity,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NebulaGlow extends StatelessWidget {
  const _NebulaGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.2, -0.55),
            radius: 1.1,
            colors: [
              FusionResultDesign.purple.withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MoonLight extends StatelessWidget {
  const _MoonLight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0.85, -0.75),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                FusionResultDesign.goldSoft.withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarLayerPainter extends CustomPainter {
  _StarLayerPainter({
    required this.seed,
    required this.starCount,
    required this.color,
    required this.opacity,
  });

  final int seed;
  final int starCount;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint();
    for (var i = 0; i < starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 1.4 + 0.3;
      paint.color = color.withValues(alpha: opacity * (0.4 + rng.nextDouble()));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarLayerPainter oldDelegate) => false;
}
