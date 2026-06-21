import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_v21_copy.dart';

/// Premium astrology illustration for Fusion Result hero — V2.1.
class FusionPremiumArtwork extends StatelessWidget {
  const FusionPremiumArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(
            constraints.maxWidth > 0 ? constraints.maxWidth : 240,
            constraints.maxHeight > 0 ? constraints.maxHeight : 280,
          ),
          painter: const _PremiumAstrologyPainter(),
        );
      },
    );
  }
}

class _PremiumAstrologyPainter extends CustomPainter {
  const _PremiumAstrologyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.46);

    _drawStarField(canvas, size);
    _drawCosmicGlow(canvas, center, size);
    _drawConstellationLines(canvas, size);
    _drawZodiacWheel(canvas, center, size);
    _drawCelestialGeometry(canvas, center, size);
    _drawMoonPhase(canvas, size);
  }

  void _drawStarField(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final starPaint = Paint();
    for (var i = 0; i < 48; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.85;
      final radius = rng.nextDouble() * 1.6 + 0.4;
      starPaint.color = Colors.white.withValues(alpha: 0.12 + rng.nextDouble() * 0.35);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _drawCosmicGlow(Canvas canvas, Offset center, Size size) {
    final glow = RadialGradient(
      colors: [
        FusionResultDesign.gold.withValues(alpha: 0.22),
        FusionResultDesign.purple.withValues(alpha: 0.12),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    canvas.drawCircle(
      center,
      size.width * 0.48,
      Paint()
        ..shader = glow.createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.48),
        ),
    );
  }

  void _drawConstellationLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = FusionResultDesign.goldSoft.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final points = [
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.28, size.height * 0.16),
      Offset(size.width * 0.38, size.height * 0.24),
      Offset(size.width * 0.72, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.28),
      Offset(size.width * 0.76, size.height * 0.36),
    ];

    for (var i = 0; i < points.length - 1; i++) {
      if (i == 2) continue;
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }
    canvas.drawLine(points[2], points[4], linePaint);

    final nodePaint = Paint()..color = FusionResultDesign.gold.withValues(alpha: 0.55);
    for (final point in points) {
      canvas.drawCircle(point, 2.2, nodePaint);
    }
  }

  void _drawZodiacWheel(Canvas canvas, Offset center, Size size) {
    final outerRadius = size.width * 0.36;
    final innerRadius = outerRadius * 0.72;

    final outerRing = Paint()
      ..color = FusionResultDesign.gold.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, outerRadius, outerRing);

    final innerRing = Paint()
      ..color = FusionResultDesign.purpleSoft.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawCircle(center, innerRadius, innerRing);

    final segmentPaint = Paint()
      ..color = FusionResultDesign.gold.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i * math.pi * 2 / 12);
      final x = center.dx + math.cos(angle) * outerRadius;
      final y = center.dy + math.sin(angle) * outerRadius;
      canvas.drawLine(center, Offset(x, y), segmentPaint);
    }

    final symbolPaint = Paint()..color = FusionResultDesign.gold.withValues(alpha: 0.5);
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i * math.pi * 2 / 12);
      final x = center.dx + math.cos(angle) * (outerRadius + innerRadius) / 2;
      final y = center.dy + math.sin(angle) * (outerRadius + innerRadius) / 2;
      canvas.drawCircle(Offset(x, y), 2.4, symbolPaint);
    }

    final coreGlow = RadialGradient(
      colors: [
        FusionResultDesign.goldSoft.withValues(alpha: 0.55),
        FusionResultDesign.gold.withValues(alpha: 0.15),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      center,
      innerRadius * 0.42,
      Paint()
        ..shader = coreGlow.createShader(
          Rect.fromCircle(center: center, radius: innerRadius * 0.42),
        ),
    );
  }

  void _drawCelestialGeometry(Canvas canvas, Offset center, Size size) {
    final hexPaint = Paint()
      ..color = FusionResultDesign.purple.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final radius = size.width * 0.14;
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 3);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, hexPaint);
  }

  void _drawMoonPhase(Canvas canvas, Size size) {
    final moonCenter = Offset(size.width * 0.78, size.height * 0.2);
    final moonRadius = size.width * 0.09;

    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()..color = FusionResultDesign.goldSoft.withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(moonCenter.dx + moonRadius * 0.35, moonCenter.dy - moonRadius * 0.1),
      moonRadius * 0.88,
      Paint()..color = const Color(0xFF1A1035),
    );

    final moonGlow = RadialGradient(
      colors: [
        FusionResultDesign.goldSoft.withValues(alpha: 0.25),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      moonCenter,
      moonRadius * 2.2,
      Paint()
        ..shader = moonGlow.createShader(
          Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.2),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Growth card illustrated backgrounds — V2.1.
class FusionGrowthArtwork extends StatelessWidget {
  const FusionGrowthArtwork({
    super.key,
    required this.style,
  });

  final FusionGrowthVisualStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GrowthArtworkPainter(style: style),
      child: const SizedBox.expand(),
    );
  }
}

class _GrowthArtworkPainter extends CustomPainter {
  const _GrowthArtworkPainter({required this.style});

  final FusionGrowthVisualStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case FusionGrowthVisualStyle.nightSky:
        _paintNightSky(canvas, size);
      case FusionGrowthVisualStyle.nebulaFlow:
        _paintNebulaFlow(canvas, size);
      case FusionGrowthVisualStyle.moonReflection:
        _paintMoonReflection(canvas, size);
    }
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A1530),
        const Color(0xFF101828),
        const Color(0xFF0A1020),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = bg.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final rng = math.Random(7);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * 0.7),
        rng.nextDouble() * 1.2 + 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.2 + rng.nextDouble() * 0.3),
      );
    }

    final pathPaint = Paint()
      ..color = FusionResultDesign.gold.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.55,
        size.width * 0.88,
        size.height * 0.35,
      );
    canvas.drawPath(path, pathPaint);
  }

  void _paintNebulaFlow(Canvas canvas, Size size) {
    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF2A1448),
        const Color(0xFF1A2848),
        const Color(0xFF120A28),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = bg.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final nebula = RadialGradient(
      colors: [
        FusionResultDesign.purple.withValues(alpha: 0.35),
        FusionResultDesign.gold.withValues(alpha: 0.12),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.35),
      size.width * 0.45,
      Paint()
        ..shader = nebula.createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.65, size.height * 0.35),
            radius: size.width * 0.45,
          ),
        ),
    );

    final flow = Paint()
      ..shader = LinearGradient(
        colors: [
          FusionResultDesign.goldSoft.withValues(alpha: 0.0),
          FusionResultDesign.goldSoft.withValues(alpha: 0.35),
          FusionResultDesign.goldSoft.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final wave = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.35,
        size.width * 0.6,
        size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.7,
        size.width,
        size.height * 0.45,
      );
    canvas.drawPath(wave, flow);
  }

  void _paintMoonReflection(Canvas canvas, Size size) {
    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0C1428),
        const Color(0xFF141830),
        const Color(0xFF0A0E1A),
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = bg.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final waterY = size.height * 0.62;
    canvas.drawRect(
      Rect.fromLTWH(0, waterY, size.width, size.height - waterY),
      Paint()..color = const Color(0xFF0A1220).withValues(alpha: 0.85),
    );

    final moonX = size.width * 0.5;
    final moonY = size.height * 0.28;
    final moonR = size.width * 0.08;
    canvas.drawCircle(
      Offset(moonX, moonY),
      moonR,
      Paint()..color = FusionResultDesign.goldSoft.withValues(alpha: 0.75),
    );
    canvas.drawCircle(
      Offset(moonX + moonR * 0.3, moonY - moonR * 0.08),
      moonR * 0.9,
      Paint()..color = const Color(0xFF0C1428),
    );

    final reflectionPaint = Paint()
      ..color = FusionResultDesign.goldSoft.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(moonX, waterY + size.height * 0.12),
        width: moonR * 2.4,
        height: moonR * 0.9,
      ),
      reflectionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthArtworkPainter oldDelegate) =>
      oldDelegate.style != style;
}
