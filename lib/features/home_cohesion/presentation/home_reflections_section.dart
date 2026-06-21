import 'package:flutter/material.dart';

import '../domain/home_screen_contract.dart';
import 'home_mvp_copy.dart';
import 'home_screen_v1_models.dart';

/// Reflections section — above fold (Home MVP V1).
class HomeReflectionsSection extends StatelessWidget {
  const HomeReflectionsSection({
    super.key,
    required this.data,
  });

  final HomeReflectionsSectionData data;

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
          title: 'มุมสะท้อนของคุณ',
          subtitle: section.purpose,
        ),
        const SizedBox(height: 12),
        if (data.tiles.isEmpty)
          _EmptyReflectionHint(state: section.surfaceState)
        else
          ...data.tiles.map((tile) => _ReflectionTile(tile: tile)),
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

class _EmptyReflectionHint extends StatelessWidget {
  const _EmptyReflectionHint({required this.state});

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
          HomeMvpCopy.reflectionsEmptyHint(),
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

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.tile});

  final HomeReflectionTileData tile;

  @override
  Widget build(BuildContext context) {
    final stateLabel = HomeMvpCopy.surfaceStateLabel(tile.surfaceState);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tile.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (stateLabel.isNotEmpty)
                    _StateChip(label: stateLabel),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tile.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DFF0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5C4A6E),
        ),
      ),
    );
  }
}
