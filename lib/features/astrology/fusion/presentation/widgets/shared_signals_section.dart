import 'package:flutter/material.dart';

import '../../domain/entities/fusion_signal.dart';
import '../../domain/entities/fusion_support_level.dart';
import '../fusion_presentation_copy.dart';

class SharedSignalsSection extends StatelessWidget {
  const SharedSignalsSection({
    super.key,
    required this.signals,
  });

  final List<FusionSignal> signals;

  static List<FusionSignal> visibleSignals(List<FusionSignal> signals) {
    return signals
        .where(
          (signal) =>
              signal.supportLevel != FusionSupportLevel.low &&
              signal.type != FusionSignalType.transformation,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = visibleSignals(signals);
    if (visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'สัญญาณที่หลายศาสตร์สนับสนุน'),
        const SizedBox(height: 12),
        for (final signal in visible) ...[
          _SignalCard(signal: signal),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final FusionSignal signal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
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
              FusionPresentationCopy.signalTitle(signal.type),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              FusionPresentationCopy.supportLevelLabel(signal.supportLevel),
              style: TextStyle(
                fontSize: 14,
                color: scheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'สนับสนุนโดย:',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            for (final lensId in signal.supportingLenses)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  FusionPresentationCopy.lensTitle(lensId),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
