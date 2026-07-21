import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';
import 'thai_mirror_rich_text.dart';

class ThaiMirrorConsumerHeroSection extends StatelessWidget {
  const ThaiMirrorConsumerHeroSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorConsumerHeroState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, isMobile ? 26 : 34, 24, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.62),
            scheme.secondaryContainer.withValues(alpha: 0.38),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.22),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '☉',
                  style: TextStyle(
                    fontSize: 22,
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.identityBadge,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.identitySubtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            state.headline,
            style: TextStyle(
              fontSize: isMobile ? 27 : 32,
              fontWeight: FontWeight.w800,
              height: 1.32,
              letterSpacing: -0.5,
              color: scheme.primary,
            ),
          ),
          if (state.summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final paragraph in _paragraphs(state.summary)) ...[
              if (paragraph != _paragraphs(state.summary).first)
                const SizedBox(height: 12),
              ThaiMirrorRichText(
                paragraph,
                emphasisColor: scheme.primary,
                baseStyle: TextStyle(
                  fontSize: 15.5,
                  height: 1.7,
                  color: scheme.onSurface.withValues(alpha: 0.92),
                ),
              ),
            ],
          ],
          if (state.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                Text(
                  'อ่านต่อ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: scheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: scheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _paragraphs(String text) => text
      .split('\n\n')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();
}
