import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import '../fusion_result_v22_copy.dart';
import 'fusion_confidence_badge.dart';
import 'fusion_reflection_strip.dart';

/// Radial fusion diagram — theme at center, lenses converge — V2.3.
class FusionConsensusWidget extends StatefulWidget {
  const FusionConsensusWidget({
    super.key,
    required this.items,
    required this.centralThemes,
    this.alignedCount,
    this.totalLenses = 3,
    this.consensusNarrative,
  });

  final List<FusionLensAgreementViewModel> items;
  final List<String> centralThemes;
  final int? alignedCount;
  final int totalLenses;
  final FusionConsensusNarrativeViewModel? consensusNarrative;

  @override
  State<FusionConsensusWidget> createState() => _FusionConsensusWidgetState();
}

class _FusionConsensusWidgetState extends State<FusionConsensusWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  int get _aligned => widget.alignedCount ?? widget.items.length;

  String get _primaryTheme {
    if (widget.centralThemes.isNotEmpty) return widget.centralThemes.first;
    return 'อิสระ';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                FusionResultV22Copy.consensusSectionTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FusionResultDesign.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FusionConfidenceBadge(
              alignedCount: _aligned,
              totalCount: widget.totalLenses,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return CustomPaint(
              foregroundPainter: _FusionRadialPainter(
                lensCount: widget.items.length,
                glowStrength: 0.4 + _pulse.value * 0.35,
                lensColors: widget.items.map((item) => item.checkColor).toList(),
              ),
              child: child,
            );
          },
          child: _RadialFusionLayout(
            items: widget.items,
            primaryTheme: _primaryTheme,
          ),
        ),
        if (widget.consensusNarrative != null) ...[
          const SizedBox(height: 24),
          _ConsensusWhyNarrative(data: widget.consensusNarrative!),
        ],
      ],
    );
  }
}

class _ConsensusWhyNarrative extends StatelessWidget {
  const _ConsensusWhyNarrative({required this.data});

  final FusionConsensusNarrativeViewModel data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FusionResultDesign.gold.withValues(alpha: 0.12),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                data.sectionLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FusionResultDesign.goldSoft,
                ),
              ),
            ),
            for (var i = 0; i < data.lensNarratives.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: FusionResultDesign.purple.withValues(alpha: 0.15),
                ),
              FusionStoryBlock(
                title: data.lensNarratives[i].lensTitle,
                body: data.lensNarratives[i].narrative,
              ),
            ],
            Divider(
              height: 1,
              color: FusionResultDesign.gold.withValues(alpha: 0.15),
            ),
            FusionStoryBlock(
              title: 'Theme กลาง',
              body: data.themeConclusion,
            ),
          ],
        ),
      ),
    );
  }
}

class _RadialFusionLayout extends StatelessWidget {
  const _RadialFusionLayout({
    required this.items,
    required this.primaryTheme,
  });

  final List<FusionLensAgreementViewModel> items;
  final String primaryTheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            child: _CentralThemeOrb(label: primaryTheme),
          ),
          ..._lensPositions(items.length).asMap().entries.map((entry) {
            final index = entry.key;
            final alignment = entry.value;
            return Align(
              alignment: alignment,
              child: _LensOrb(item: items[index]),
            );
          }),
        ],
      ),
    );
  }

  List<Alignment> _lensPositions(int count) {
    if (count <= 1) return [Alignment.bottomCenter];
    if (count == 2) {
      return const [Alignment(-0.75, 0.95), Alignment(0.75, 0.95)];
    }
    return const [
      Alignment(-0.9, 0.92),
      Alignment.bottomCenter,
      Alignment(0.9, 0.92),
    ];
  }
}

class _CentralThemeOrb extends StatelessWidget {
  const _CentralThemeOrb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              FusionResultDesign.gold.withValues(alpha: 0.28),
              FusionResultDesign.purple.withValues(alpha: 0.18),
              FusionResultDesign.cardFill.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: FusionResultDesign.gold.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: FusionResultDesign.gold.withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✦', style: TextStyle(fontSize: 16, color: FusionResultDesign.gold)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FusionResultDesign.goldSoft,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LensOrb extends StatelessWidget {
  const _LensOrb({required this.item});

  final FusionLensAgreementViewModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FusionResultDesign.cardFill.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.checkColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: item.checkColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: FusionResultDesign.gold, size: 18),
          const SizedBox(height: 6),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FusionResultDesign.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _FusionRadialPainter extends CustomPainter {
  _FusionRadialPainter({
    required this.lensCount,
    required this.glowStrength,
    required this.lensColors,
  });

  final int lensCount;
  final double glowStrength;
  final List<Color> lensColors;

  @override
  void paint(Canvas canvas, Size size) {
    if (lensCount == 0) return;

    final center = Offset(size.width * 0.5, size.height * 0.28);
    final positions = _lensOffsets(size, lensCount);

    for (var i = 0; i < positions.length; i++) {
      final lens = positions[i];
      final color = i < lensColors.length
          ? lensColors[i]
          : FusionResultDesign.purple;

      final path = Path()
        ..moveTo(lens.dx, lens.dy)
        ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.55,
          center.dx,
          center.dy + 40,
        );

      final glow = Paint()
        ..color = FusionResultDesign.gold.withValues(alpha: 0.1 * glowStrength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glow);

      final line = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.5),
            FusionResultDesign.gold.withValues(alpha: 0.7),
          ],
        ).createShader(Rect.fromPoints(lens, center))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, line);
    }
  }

  List<Offset> _lensOffsets(Size size, int count) {
    final y = size.height * 0.88;
    if (count <= 1) return [Offset(size.width * 0.5, y)];
    if (count == 2) {
      return [
        Offset(size.width * 0.22, y),
        Offset(size.width * 0.78, y),
      ];
    }
    return [
      Offset(size.width * 0.14, y),
      Offset(size.width * 0.5, y),
      Offset(size.width * 0.86, y),
    ];
  }

  @override
  bool shouldRepaint(covariant _FusionRadialPainter oldDelegate) {
    return oldDelegate.glowStrength != glowStrength;
  }
}
