import 'package:flutter/material.dart';

import '../../models/thai_mirror_evidence_explorer_state.dart';
import 'thai_mirror_lens_badge.dart';

/// One evidence row in the Evidence Explorer list.
class ThaiMirrorEvidenceRow extends StatelessWidget {
  const ThaiMirrorEvidenceRow({
    super.key,
    required this.state,
  });

  final ThaiMirrorEvidenceRowState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final themeCount = state.supportedThemeIds.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThaiMirrorLensBadge(lensSource: state.lensSource),
          const SizedBox(height: 10),
          Text(
            state.contentKey,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'สนับสนุน $themeCount ธีม',
            style: TextStyle(
              fontSize: 12.5,
              color: muted.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
