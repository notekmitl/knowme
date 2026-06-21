import 'package:flutter/material.dart';

class DifferentPerspectivesSection extends StatelessWidget {
  const DifferentPerspectivesSection({
    super.key,
    required this.narratives,
  });

  final List<String> narratives;

  @override
  Widget build(BuildContext context) {
    if (narratives.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'มุมมองที่แตกต่างกัน',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (final narrative in narratives) ...[
          Card(
            elevation: 0,
            color: scheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                narrative,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
