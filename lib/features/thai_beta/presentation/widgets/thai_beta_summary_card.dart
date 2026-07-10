import 'package:flutter/material.dart';

import '../../domain/thai_beta_input.dart';
import '../../domain/thai_beta_normalized_snapshot.dart';
import '../thai_beta_thai_date_format.dart';

/// "ข้อมูลที่ใช้วิเคราะห์" — human-readable summary shown immediately before the
/// report to reassure the user about exactly what was used to analyze them.
class ThaiBetaSummaryCard extends StatelessWidget {
  const ThaiBetaSummaryCard({
    super.key,
    required this.input,
    required this.snapshot,
  });

  final ThaiBetaInput input;
  final ThaiBetaNormalizedSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final birthDateTh = ThaiBetaDateFormat.formatDate(input.birthDate);
    final thaiAstroTh =
        ThaiBetaDateFormat.formatIsoDate(snapshot.thaiAstrologicalDate);
    final birthTime = snapshot.birthTime.isEmpty ? 'ไม่ระบุ' : snapshot.birthTime;
    final province = (input.province ?? '').trim().isEmpty
        ? '-'
        : input.province!.trim();
    final gender = (input.gender ?? '').trim().isEmpty ? '-' : input.gender!.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text('ข้อมูลที่ใช้วิเคราะห์',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 14),
            _row(theme, 'ชื่อ', input.firstName.isEmpty ? '-' : input.firstName),
            _row(theme, 'นามสกุล', input.lastName.isEmpty ? '-' : input.lastName),
            _row(theme, 'วันเกิด', birthDateTh),
            _row(theme, 'เวลาเกิด', birthTime),
            _row(theme, 'จังหวัดเกิด', province),
            _row(theme, 'เพศ', gender),
            const Divider(height: 26),
            _row(theme, 'พระอาทิตย์ขึ้น',
                snapshot.sunriseAvailable ? snapshot.sunrise : 'คำนวณไม่ได้'),
            _row(theme, 'วันโหราศาสตร์ไทย', thaiAstroTh, emphasize: true),
            _row(theme, 'Timezone', snapshot.timeZoneId),
            if (snapshot.usedPreviousDay) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.wb_twilight_rounded,
                        size: 18, color: scheme.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'หมายเหตุ: เกิดก่อนพระอาทิตย์ขึ้น '
                        'ระบบใช้วันก่อนหน้าในการคำนวณโหราศาสตร์ไทย',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
                color: emphasize ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
