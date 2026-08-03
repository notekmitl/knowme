import 'package:flutter/material.dart';

import 'package:knowme/features/thai_beta/application/thai_evidence_badge_beta_telemetry.dart';

import 'thai_public_evidence_badge_beta_view_model.dart';

/// Compact reader-facing evidence summary for Thai Beta only.
class ThaiBetaEvidenceBadgePanel extends StatelessWidget {
  const ThaiBetaEvidenceBadgePanel({super.key, required this.badges});

  final List<ThaiPublicEvidenceBadgeBetaViewModel> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final uniquePublicSummaries =
        <String, ThaiPublicEvidenceBadgeBetaViewModel>{};
    for (final badge in badges) {
      ThaiEvidenceBadgeBetaTelemetry.badgeRendered(sectionId: badge.sectionId);
      uniquePublicSummaries.putIfAbsent(
        '${badge.badgeLabel}\u0000${badge.cautionCopy}',
        () => badge,
      );
    }
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ที่มาของคำวิเคราะห์',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'รายงานนี้มีข้อมูลอ้างอิงจากตำรา รายละเอียดนี้ช่วยบอกที่มา '
              'แต่ไม่ใช่การรับรองความแม่นยำ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            ExpansionTile(
              key: const Key('thai_beta_evidence_details'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              title: const Text('ดูรายละเอียดหลักฐาน'),
              children: uniquePublicSummaries.values
                  .map((badge) => _BadgeRow(badge: badge))
                  .toList(growable: false),
            ),
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
        Chip(
          label: Text(badge.badgeLabel),
          backgroundColor: theme.colorScheme.primaryContainer,
        ),
        const SizedBox(height: 4),
        Text(badge.cautionCopy, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
