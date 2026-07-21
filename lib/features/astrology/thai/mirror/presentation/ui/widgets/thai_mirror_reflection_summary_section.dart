import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

/// Shareable closing summary — "ถ้ามีคนถามว่าคุณเป็นคนแบบไหน".
///
/// Designed to be screenshot-worthy: a self-contained, premium card with a
/// clear question, a short lead-in and five punchy, memorable lines.
class ThaiMirrorReflectionSummarySection extends StatelessWidget {
  const ThaiMirrorReflectionSummarySection({
    super.key,
    required this.state,
  });

  final ThaiMirrorReflectionSummaryState state;

  @override
  Widget build(BuildContext context) {
    if (state.points.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A1B47),
            scheme.primary.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                'สรุปจากดวงไทย',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            state.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.intro,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < state.points.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _SummaryPoint(index: i + 1, text: state.points[i]),
          ],
        ],
      ),
    );
  }
}

class _SummaryPoint extends StatelessWidget {
  const _SummaryPoint({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 34,
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w200,
              height: 1.1,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16.5,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
