import 'package:flutter/material.dart';

import 'astrology_flow_state.dart';

/// Shimmer placeholder for Home astrology summary while data loads.
class AstrologySummaryShimmer extends StatelessWidget {
  const AstrologySummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E2F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBar(width: 140, height: 16),
          const SizedBox(height: 10),
          _shimmerBar(width: double.infinity, height: 12),
          const SizedBox(height: 8),
          _shimmerBar(width: 200, height: 12),
          const SizedBox(height: 14),
          _shimmerBar(width: 120, height: 32, radius: 16),
        ],
      ),
    );
  }

  Widget _shimmerBar({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return _ShimmerBox(
      width: width,
      height: height,
      radius: radius,
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
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

/// Full-screen generation / computing state for astrology result entry pages.
class AstrologyGenerationBody extends StatelessWidget {
  const AstrologyGenerationBody({
    super.key,
    required this.title,
    required this.body,
    this.onAction,
    this.actionLabel,
  });

  final String title;
  final String body;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Structured empty / blocked state — never bare "ไม่มีข้อมูล".
class AstrologyFlowStateBody extends StatelessWidget {
  const AstrologyFlowStateBody({
    super.key,
    required this.state,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.onRetry,
  });

  final AstrologyFlowState state;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (title, body, icon) = switch (state) {
      AstrologyFlowState.computing => (
          AstrologyFlowCopy.computingTitle,
          AstrologyFlowCopy.computingBody,
          Icons.hourglass_top_rounded,
        ),
      AstrologyFlowState.firstGeneration => (
          AstrologyFlowCopy.firstGenTitle,
          AstrologyFlowCopy.firstGenBody,
          Icons.auto_awesome_rounded,
        ),
      AstrologyFlowState.incompleteProfile => (
          AstrologyFlowCopy.incompleteProfileTitle,
          AstrologyFlowCopy.incompleteProfileBody,
          Icons.person_outline_rounded,
        ),
      AstrologyFlowState.failed => (
          AstrologyFlowCopy.failedTitle,
          AstrologyFlowCopy.failedBody,
          Icons.error_outline_rounded,
        ),
      AstrologyFlowState.ready => (
          '',
          '',
          Icons.check_circle_outline_rounded,
        ),
    };

    if (state == AstrologyFlowState.ready) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (onPrimaryAction != null && primaryActionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onPrimaryAction,
                child: Text(primaryActionLabel!),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onRetry,
                child: const Text(AstrologyFlowCopy.retryCta),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
