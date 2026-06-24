import 'package:flutter/material.dart';

import '../../models/thai_mirror_consumer_view_state.dart';

class ThaiMirrorAdviceSection extends StatelessWidget {
  const ThaiMirrorAdviceSection({
    super.key,
    required this.state,
  });

  final ThaiMirrorAdviceState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  state.body,
                  style: TextStyle(
                    fontSize: 15.5,
                    height: 1.65,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement_rounded,
                  size: 36,
                  color: scheme.primary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
