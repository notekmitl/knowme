import 'package:flutter/material.dart';

import '../../models/thai_mirror_profile_context_state.dart';

/// Profile context transparency card for Thai Mirror Result Page.
class ThaiMirrorProfileContextCard extends StatelessWidget {
  const ThaiMirrorProfileContextCard({
    super.key,
    required this.state,
  });

  final ThaiMirrorProfileContextState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'บริบทข้อมูลเกิด',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.hasBirthTime ? '✓ มีเวลาเกิด' : '⚠ ไม่พบเวลาเกิด',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: state.hasBirthTime
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant,
              ),
            ),
            if (state.hasWarnings) ...[
              const SizedBox(height: 10),
              ...state.warningMessages.map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '⚠ $message',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: muted,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'มาตรฐานการคำนวณ: ${state.calculationStandardVersion}',
              style: TextStyle(
                fontSize: 12.5,
                color: muted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
