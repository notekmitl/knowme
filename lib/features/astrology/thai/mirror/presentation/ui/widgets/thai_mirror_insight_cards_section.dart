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
    final scheme = Theme.of(context).colorScheme;

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
            Text(
              state.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _spacedCards(state.cards, horizontal: true),
              );
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _spacedCards(state.cards, horizontal: true),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _spacedCards(
    List<ThaiMirrorInsightCardState> cards, {
    required bool horizontal,
  }) {
    final widgets = <Widget>[];
    for (var index = 0; index < cards.length; index++) {
      if (index > 0) widgets.add(const SizedBox(width: 12));
      widgets.add(
        SizedBox(
          width: 220,
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
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: state.accent.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: state.accent.iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            state.title,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
