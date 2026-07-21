import 'package:flutter/material.dart';

import '../../domain/thai_beta_input.dart';
import '../../domain/thai_beta_normalized_snapshot.dart';
import '../thai_beta_thai_date_format.dart';

/// Explains *why* the Thai astrological date may differ from the calendar date.
///
/// When the birth was before local sunrise, Thai astrology starts the new day at
/// sunrise, so the previous weekday is used — this banner makes that explicit.
class ThaiBetaTransparencyBanner extends StatelessWidget {
  const ThaiBetaTransparencyBanner({
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

    if (!snapshot.usedPreviousDay) {
      return _Banner(
        icon: Icons.event_available_outlined,
        background: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        foreground: scheme.onSurface,
        child: Text(
          'ระบบใช้วันเกิดตามปฏิทิน',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }

    final civilWeekday = ThaiBetaDateFormat.weekday(input.birthDate);
    final astroDate = ThaiBetaDateFormat.parseIso(snapshot.thaiAstrologicalDate);
    final usedWeekday =
        astroDate == null ? '' : ThaiBetaDateFormat.weekday(astroDate);

    return _Banner(
      icon: Icons.wb_twilight_rounded,
      background: scheme.tertiaryContainer.withValues(alpha: 0.45),
      foreground: scheme.onTertiaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('คุณเกิดก่อนพระอาทิตย์ขึ้น',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onTertiaryContainer,
              )),
          const SizedBox(height: 6),
          Text(
            'ตามหลักโหราศาสตร์ไทย วันใหม่จะเริ่มเมื่อพระอาทิตย์ขึ้น',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onTertiaryContainer, height: 1.45),
          ),
          if (usedWeekday.isNotEmpty && civilWeekday.isNotEmpty) ...[
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: scheme.onTertiaryContainer, height: 1.45),
                children: [
                  const TextSpan(text: 'ดังนั้นระบบจึงใช้ '),
                  TextSpan(
                    text: usedWeekday,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' แทน '),
                  TextSpan(
                    text: civilWeekday,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' ในการคำนวณ'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.child,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}
