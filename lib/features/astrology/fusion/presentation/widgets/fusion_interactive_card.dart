import 'package:flutter/material.dart';

import '../fusion_result_design.dart';

/// Subtle hover lift + glow for premium cards — V2.1.
class FusionInteractiveCard extends StatefulWidget {
  const FusionInteractiveCard({
    super.key,
    required this.child,
    this.padding,
    this.decoration,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  @override
  State<FusionInteractiveCard> createState() => _FusionInteractiveCardState();
}

class _FusionInteractiveCardState extends State<FusionInteractiveCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.decoration ?? FusionResultDesign.cosmicCard();
    final borderRadius = base.borderRadius is BorderRadius
        ? base.borderRadius! as BorderRadius
        : BorderRadius.circular(FusionResultDesign.cardRadius);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: base.copyWith(
          boxShadow: [
            BoxShadow(
              color: FusionResultDesign.gold.withValues(
                alpha: _hovered ? 0.2 : 0.1,
              ),
              blurRadius: _hovered ? 28 : 20,
              offset: Offset(0, _hovered ? 14 : 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: borderRadius,
            splashColor: FusionResultDesign.gold.withValues(alpha: 0.08),
            highlightColor: FusionResultDesign.purple.withValues(alpha: 0.06),
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
