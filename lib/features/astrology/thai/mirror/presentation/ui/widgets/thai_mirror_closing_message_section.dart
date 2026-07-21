import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

/// Emotional closing message — "สิ่งที่ดวงไทยอยากบอกคุณ".
///
/// One memorable, reflective note placed near the end of the report. Quiet and
/// premium: centred text, generous space, a soft glow. Not a prediction.
class ThaiMirrorClosingMessageSection extends StatelessWidget {
  const ThaiMirrorClosingMessageSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorClosingMessageState state;

  @override
  Widget build(BuildContext context) {
    if (state.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.35),
            scheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
            ),
            child: Text(
              '☽',
              style: TextStyle(fontSize: 26, color: scheme.primary),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            state.eyebrow,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.85,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            state.signature,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontStyle: FontStyle.italic,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
