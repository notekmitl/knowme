import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Lightweight more navigation — Home V3.5 Section 5.
class HomeV3MoreSection extends StatelessWidget {
  const HomeV3MoreSection({
    super.key,
    required this.data,
    required this.onItemSelected,
  });

  final HomeMoreSectionData data;
  final void Function(HomeMoreItemData item) onItemSelected;

  static const _icons = <String, (IconData, Color)>{
    'astrology': (Icons.star_rounded, Color(0xFFE8C547)),
    'fusion': (Icons.layers_rounded, Color(0xFF9B7BD4)),
    'profile': (Icons.person_rounded, Color(0xFF5CB88A)),
    'settings': (Icons.settings_rounded, Color(0xFF7A8B9E)),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('⊞', style: TextStyle(fontSize: 16, color: HomeV35Design.textSecondary)),
            const SizedBox(width: 8),
            Text(
              HomeV3Copy.moreTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HomeV35Design.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: HomeV35Design.surface,
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            boxShadow: [HomeV35Design.cardShadow],
          ),
          child: Column(
            children: [
              for (var i = 0; i < data.items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 64,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                _MoreTile(
                  item: data.items[i],
                  icon: _icons[data.items[i].id]?.$1 ?? Icons.chevron_right,
                  color: _icons[data.items[i].id]?.$2 ?? HomeV35Design.purpleAccent,
                  onTap: () => onItemSelected(data.items[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.item,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final HomeMoreItemData item;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: item.enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: item.enabled
              ? HomeV35Design.textPrimary
              : HomeV35Design.textMuted,
        ),
      ),
      subtitle: Text(
        item.description,
        style: const TextStyle(
          fontSize: 12,
          color: HomeV35Design.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: item.enabled ? HomeV35Design.textMuted : Colors.grey.shade300,
      ),
      onTap: item.enabled ? onTap : null,
    );
  }
}
