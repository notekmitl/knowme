import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative cosmic visual for Home hero (right side).
class HomeCosmicArtwork extends StatelessWidget {
  const HomeCosmicArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(
            constraints.maxWidth > 0 ? constraints.maxWidth : 160,
            constraints.maxHeight > 0 ? constraints.maxHeight : 200,
          ),
          painter: const _CosmicPainter(),
        );
      },
    );
  }
}

class _CosmicPainter extends CustomPainter {
  const _CosmicPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.42);

    // Zodiac ring
    final ringPaint = Paint()
      ..color = const Color(0xFFE8C547).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, size.width * 0.38, ringPaint);

    final dotPaint = Paint()..color = const Color(0xFFE8C547).withValues(alpha: 0.45);
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i * math.pi * 2 / 12);
      final x = center.dx + math.cos(angle) * size.width * 0.38;
      final y = center.dy + math.sin(angle) * size.width * 0.38;
      canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
    }

    // Sun glow
    final sunCenter = Offset(size.width * 0.62, size.height * 0.52);
    final sunGradient = RadialGradient(
      colors: [
        const Color(0xFFFFE9A8).withValues(alpha: 0.9),
        const Color(0xFFE8C547).withValues(alpha: 0.35),
        Colors.transparent,
      ],
    );
    canvas.drawCircle(
      sunCenter,
      size.width * 0.22,
      Paint()..shader = sunGradient.createShader(
        Rect.fromCircle(center: sunCenter, radius: size.width * 0.22),
      ),
    );

    // Mountains
    final mountainPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.18, size.height * 0.58)
      ..lineTo(size.width * 0.35, size.height * 0.7)
      ..lineTo(size.width * 0.52, size.height * 0.5)
      ..lineTo(size.width * 0.72, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      mountainPath,
      Paint()..color = const Color(0xFF0A0612).withValues(alpha: 0.55),
    );

    // Golden path
    final pathCurve = Path()
      ..moveTo(size.width * 0.08, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.72,
        size.width * 0.55,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.48,
        sunCenter.dx,
        sunCenter.dy,
      );
    canvas.drawPath(
      pathCurve,
      Paint()
        ..color = const Color(0xFFE8C547).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 1.5, starPaint);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.12), 1.2, starPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.28), 1.8, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
