import 'package:flutter/material.dart';

/// The four steps of the Research flow, in order.
enum ThaiBetaStep {
  fillIn(1, 'กรอกข้อมูล'),
  review(2, 'ตรวจสอบข้อมูล'),
  read(3, 'อ่านผล'),
  feedback(4, 'ส่งความคิดเห็น');

  const ThaiBetaStep(this.number, this.label);

  final int number;
  final String label;
}

/// Compact 4-step progress indicator shown at the top of each flow page so the
/// user always knows where they are and how much is left.
class ThaiBetaProgressBar extends StatelessWidget {
  const ThaiBetaProgressBar({super.key, required this.current});

  final ThaiBetaStep current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (final step in ThaiBetaStep.values) ...[
            if (step.number > 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: step.number <= current.number
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
            _StepDot(
              step: step,
              done: step.number < current.number,
              active: step.number == current.number,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.done,
    required this.active,
  });

  final ThaiBetaStep step;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reached = done || active;

    final Color bg;
    final Color fg;
    if (active) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
    } else if (done) {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check_rounded, size: 16, color: fg)
              : Text(
                  '${step.number}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            step.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: reached ? scheme.onSurface : scheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
