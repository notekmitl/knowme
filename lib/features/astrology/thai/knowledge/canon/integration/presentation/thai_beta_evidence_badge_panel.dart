import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/application/thai_evidence_badge_beta_telemetry.dart';

import 'thai_public_evidence_badge_beta_view_model.dart';

/// LEVEL 1 Canon traceability badges — Thai Beta Research Result only.
class ThaiBetaEvidenceBadgePanel extends StatelessWidget {
  const ThaiBetaEvidenceBadgePanel({
    super.key,
    required this.badges,
  });

  final List<ThaiPublicEvidenceBadgeBetaViewModel> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Canon traceability (beta)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Controlled beta — traceability only, not a guarantee.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            ...badges.map((badge) {
              ThaiEvidenceBadgeBetaTelemetry.badgeRendered(
                sectionId: badge.sectionId,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _BadgeRow(badge: badge),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badge});

  final ThaiPublicEvidenceBadgeBetaViewModel badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          badge.sectionId,
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(badge.badgeLabel),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
        const SizedBox(height: 4),
        Text(
          badge.cautionCopy,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
