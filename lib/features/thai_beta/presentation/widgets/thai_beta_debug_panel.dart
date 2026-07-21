import 'package:flutter/material.dart';

import '../../domain/thai_beta_normalized_snapshot.dart';

/// "ข้อมูลที่ใช้คำนวณ" — collapsed-by-default panel holding the **technical**
/// data behind the report (coordinates, timezone, sunrise, fingerprint, id).
/// Human-readable birth info lives in [ThaiBetaSummaryCard] instead.
class ThaiBetaDebugPanel extends StatelessWidget {
  const ThaiBetaDebugPanel({
    super.key,
    required this.snapshot,
    this.reportHash,
    this.researchId,
  });

  final ThaiBetaNormalizedSnapshot snapshot;

  /// SHA-256 fingerprint of the report snapshot.
  final String? reportHash;

  /// Sequential research id — only known after submission.
  final String? researchId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = <(String, String)>[
      ('Latitude', snapshot.latitude.toStringAsFixed(6)),
      ('Longitude', snapshot.longitude.toStringAsFixed(6)),
      (
        'Coordinates',
        '${snapshot.latitude.toStringAsFixed(4)}, ${snapshot.longitude.toStringAsFixed(4)}'
      ),
      (
        'Timezone',
        '${snapshot.timeZoneId} (UTC${snapshot.utcOffsetHours >= 0 ? '+' : ''}${snapshot.utcOffsetHours.toStringAsFixed(0)})'
      ),
      ('Sunrise', snapshot.sunriseAvailable ? snapshot.sunrise : 'คำนวณไม่ได้'),
      ('Hash (SHA-256)', (reportHash ?? '').isEmpty ? '-' : reportHash!),
      (
        'Research ID',
        (researchId ?? '').isEmpty ? 'จะระบุหลังส่งความคิดเห็น' : researchId!
      ),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: const Icon(Icons.calculate_outlined),
          title: const Text('ข้อมูลที่ใช้คำนวณ'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        label,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: SelectableText(
                        value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
