import 'package:flutter/material.dart';

import '../../copy/thai_mirror_consumer_copy.dart';
import '../../models/thai_mirror_consumer_view_state.dart';

class ThaiMirrorSourceTransparencySection extends StatelessWidget {
  const ThaiMirrorSourceTransparencySection({
    super.key,
    required this.state,
  });

  static const titleTh = 'แหล่งที่มาของผลลัพธ์';

  final ThaiMirrorSourceTransparencyState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleTh,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final columns = [
                _SourceColumn(
                  title: 'ข้อมูลที่ใช้',
                  body: state.dataUsed,
                ),
                _SourceColumn(
                  title: 'หลักการคำนวณ',
                  body: state.calculation,
                ),
                _SourceColumn(
                  title: 'ความหมายของผลลัพธ์',
                  body: state.meaning,
                ),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < columns.length; index++) ...[
                      if (index > 0) const SizedBox(width: 16),
                      Expanded(child: columns[index]),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (var index = 0; index < columns.length; index++) ...[
                    if (index > 0) const SizedBox(height: 14),
                    columns[index],
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            ThaiMirrorConsumerCopy.footerDisclaimer,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceColumn extends StatelessWidget {
  const _SourceColumn({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
