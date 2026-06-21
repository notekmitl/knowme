import 'package:flutter/material.dart';

import 'home_screen_v3_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Compact identity strip — Home V3.5 Section 3.
class HomeCompactProfileSection extends StatelessWidget {
  const HomeCompactProfileSection({
    super.key,
    required this.data,
    required this.onEditProfile,
  });

  final HomeCompactProfileSectionData data;
  final void Function() onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: HomeV35Design.surface,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        boxShadow: [HomeV35Design.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HomeV35Design.purpleSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: HomeV35Design.purpleAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HomeV35Design.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.birthDate} • ${data.birthPlace}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: HomeV35Design.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEditProfile,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '${HomeV3Copy.editProfile} ›',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HomeV35Design.purpleAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
