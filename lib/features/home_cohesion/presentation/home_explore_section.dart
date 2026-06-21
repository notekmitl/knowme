import 'package:flutter/material.dart';
import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';

import '../domain/home_screen_contract.dart';
import 'home_mvp_copy.dart';
import 'home_screen_v1_models.dart';

/// Explore section — below fold with HC-F1.5 grouped discovery (Home MVP V1).
class HomeExploreSection extends StatelessWidget {
  const HomeExploreSection({
    super.key,
    required this.data,
  });

  final HomeExploreSectionData data;

  @override
  Widget build(BuildContext context) {
    final section = data.section;
    if (!section.visible || section.surfaceState == HomeSectionSurfaceState.hidden) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'สำรวจเพิ่มเติม',
          subtitle: section.purpose,
        ),
        const SizedBox(height: 12),
        if (data.groups.isEmpty)
          _EmptyExploreHint(state: section.surfaceState)
        else
          ...data.groups.map((group) => _ExploreGroupCard(group: group)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _EmptyExploreHint extends StatelessWidget {
  const _EmptyExploreHint({required this.state});

  final HomeSectionSurfaceState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          HomeMvpCopy.exploreEmptyHint(),
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _ExploreGroupCard extends StatelessWidget {
  const _ExploreGroupCard({required this.group});

  final HomeExploreGroupData group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                group.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ...group.items.map((item) => _ExploreItemRow(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreItemRow extends StatelessWidget {
  const _ExploreItemRow({required this.item});

  final HomeExploreItemData item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AvailabilityChip(
            label: HomeMvpCopy.availabilityLabel(item.availability),
            availability: item.availability,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({
    required this.label,
    required this.availability,
  });

  final String label;
  final DiscoveryAvailability availability;

  @override
  Widget build(BuildContext context) {
    final color = switch (availability) {
      DiscoveryAvailability.completed => const Color(0xFFDCEFE3),
      DiscoveryAvailability.available => const Color(0xFFE8DFF0),
      DiscoveryAvailability.locked => const Color(0xFFEDEEF0),
    };
    final textColor = switch (availability) {
      DiscoveryAvailability.completed => const Color(0xFF2F6B4A),
      DiscoveryAvailability.available => const Color(0xFF5C4A6E),
      DiscoveryAvailability.locked => const Color(0xFF6B7280),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
