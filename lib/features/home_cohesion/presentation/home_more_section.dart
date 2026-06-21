import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v2_copy.dart';

class HomeMoreSection extends StatelessWidget {
  const HomeMoreSection({
    super.key,
    required this.data,
    required this.onItemSelected,
  });

  final HomeMoreSectionData data;
  final void Function(HomeMoreItemData item) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          HomeV2Copy.moreTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (var i = 0; i < data.items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  enabled: data.items[i].enabled,
                  title: Text(data.items[i].title),
                  subtitle: Text(data.items[i].description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: data.items[i].enabled
                      ? () => onItemSelected(data.items[i])
                      : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
