import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

class ThaiMirrorInsightCardsSection extends StatelessWidget {
  const ThaiMirrorInsightCardsSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorInsightSectionState state;

  @override
  Widget build(BuildContext context) {
    if (state.cards.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (state.sectionIcon != null) ...[
              Icon(
                state.sectionIcon,
                size: 22,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                state.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isMobile)
          Column(
            children: [
              for (var index = 0; index < state.cards.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                _InsightCard(state: state.cards[index]),
              ],
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _spacedCards(state.cards),
          ),
      ],
    );
  }

  List<Widget> _spacedCards(List<ThaiMirrorInsightCardState> cards) {
    final widgets = <Widget>[];
    for (var index = 0; index < cards.length; index++) {
      if (index > 0) widgets.add(const SizedBox(width: 12));
      widgets.add(
        Expanded(
          child: _InsightCard(state: cards[index]),
        ),
      );
    }
    return widgets;
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.state});

  final ThaiMirrorInsightCardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = state.icon ?? state.accent.defaultIcon;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: state.accent.iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: state.accent.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
