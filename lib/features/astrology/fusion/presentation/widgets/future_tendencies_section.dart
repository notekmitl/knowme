import 'package:flutter/material.dart';

import '../../domain/entities/future_tendency.dart';

class FutureTendenciesSection extends StatelessWidget {
  const FutureTendenciesSection({
    super.key,
    required this.tendencies,
  });

  final List<FutureTendency> tendencies;

  @override
  Widget build(BuildContext context) {
    if (tendencies.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'แนวโน้มที่น่าสนใจ',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ไม่ใช่คำทำนาย — เป็นแนวคิดจากรูปแบบที่สะท้อนซ้ำในหลายศาสตร์',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final tendency in tendencies) ...[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tendency.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tendency.description,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
