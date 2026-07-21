import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

/// V7 — "the heart of the report". A single, visually distinct passage that is
/// assembled from this profile's exact evidence combination. Styled as a
/// premium highlighted card so it reads as the emotional centre of the page.
class ThaiMirrorSignatureInsightSection extends StatelessWidget {
  const ThaiMirrorSignatureInsightSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorSignatureInsightState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paragraphs = state.body
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.10),
            scheme.tertiary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.eyebrow,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Text(
              paragraphs[i],
              style: TextStyle(
                fontSize: 16.5,
                height: 1.82,
                color: scheme.onSurface.withValues(alpha: 0.92),
              ),
            ),
          ],
          if (state.signature.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '“${state.signature}”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.5,
                  height: 1.7,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
