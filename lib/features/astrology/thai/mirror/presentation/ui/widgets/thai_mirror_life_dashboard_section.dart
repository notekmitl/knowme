import 'package:flutter/material.dart';

import '../../copy/thai_mirror_consumer_copy.dart';
import '../../models/thai_mirror_consumer_view_state.dart';

class ThaiMirrorLifeDashboardSection extends StatelessWidget {
  const ThaiMirrorLifeDashboardSection({
    super.key,
    required this.items,
    required this.secretTip,
  });

  final List<ThaiMirrorLifeDashboardItemState> items;
  final String secretTip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 22, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ThaiMirrorConsumerCopy.dashboardSectionTitle,
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
              for (var index = 0; index < items.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                _LifeCard(item: items[index]),
              ],
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) => SizedBox(
                  width: 280,
                  child: _LifeCard(item: item),
                )).toList(),
          ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: scheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                secretTip,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LifeCard extends StatelessWidget {
  const _LifeCard({required this.item});

  final ThaiMirrorLifeDashboardItemState item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.status.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.status.labelTh,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: item.status.dotColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DashboardRow(
            label: 'สถานะปัจจุบัน',
            value: item.currentState,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          _DashboardRow(
            label: 'ทำไมถึงปรากฏ',
            value: item.whyItAppears,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          _DashboardRow(
            label: 'สิ่งที่ควรทำ',
            value: item.suggestedAction,
            scheme: scheme,
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({
    required this.label,
    required this.value,
    required this.scheme,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final ColorScheme scheme;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
            color: scheme.primary.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: emphasized ? 13 : 12.5,
            height: 1.45,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
            color: emphasized ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
