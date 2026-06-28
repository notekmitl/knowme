import 'package:flutter/material.dart';

import 'package:knowme/features/product_validation/product_validation.dart';

import '../mirror_copy.dart';
import '../mirror_view_models.dart';
import 'mirror_theme.dart';

/// A wrapped row of tone chips for a list of life areas.
class MirrorAreasWrap extends StatelessWidget {
  const MirrorAreasWrap({super.key, required this.areas});

  final List<MirrorLifeArea> areas;

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final a in areas) MirrorAreaChip(area: a)],
    );
  }
}

/// The expandable "evidence second" detail: per-area strength + clarity value.
/// Emotion stays on the card surface; the numbers live here.
class MirrorWhyTile extends StatelessWidget {
  const MirrorWhyTile({
    super.key,
    required this.areas,
    required this.clarity,
    this.cardId = 'card',
  });

  final List<MirrorLifeArea> areas;
  final MirrorClarity clarity;

  /// Identifies which card's evidence was opened (Phase A measurement).
  final String cardId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        onExpansionChanged: (expanded) {
          if (expanded) ProductValidation.tracker.evidenceExpanded(cardId);
        },
        title: Text(
          MirrorCopy.whyLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: [
          for (final a in areas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(MirrorTheme.toneIcon(a.tone),
                      size: 16, color: MirrorTheme.toneColor(a.tone)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${a.title} · ${MirrorCopy.toneWord(a.tone)}'),
                  ),
                  Text(
                    'signal ${a.strength}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Overall clarity: ${clarity.value}/100 (${clarity.label}).',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared card shell: rounded, soft, generous padding.
class MirrorCardShell extends StatelessWidget {
  const MirrorCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
