import 'package:flutter/material.dart';

import '../../models/thai_mirror_theme_card_state.dart';
import 'thai_mirror_theme_card.dart';

/// Top themes list for Thai Mirror Result Page (P0).
class ThaiMirrorTopThemesSection extends StatelessWidget {
  const ThaiMirrorTopThemesSection({
    super.key,
    required this.themes,
  });

  final List<ThaiMirrorThemeCardState> themes;

  static const _emptyMessage = 'ยังไม่มีธีมเด่นในขณะนี้';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ธีมเด่น',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.35,
            letterSpacing: -0.15,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        if (themes.isEmpty)
          Text(
            _emptyMessage,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          )
        else
          ...themes.map(
            (theme) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ThaiMirrorThemeCard(state: theme),
            ),
          ),
      ],
    );
  }
}
