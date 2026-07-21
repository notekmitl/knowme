import 'package:flutter/material.dart';

import '../domain/home_screen_contract.dart';
import 'home_screen_v1_models.dart';

/// Journey section — above fold (Home MVP V1).
class HomeJourneySection extends StatelessWidget {
  const HomeJourneySection({
    super.key,
    required this.data,
  });

  final HomeJourneySectionData data;

  @override
  Widget build(BuildContext context) {
    final section = data.section;
    if (!section.visible || section.surfaceState == HomeSectionSurfaceState.hidden) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.headline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.body,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.hint,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
