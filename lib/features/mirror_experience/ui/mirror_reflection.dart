import 'package:flutter/material.dart';

import '../mirror_view_models.dart';
import 'mirror_cards_common.dart';

/// P3 — the closing reflection. The journey ends gently, on the user, not on the
/// system.
class MirrorReflection extends StatelessWidget {
  const MirrorReflection({
    super.key,
    required this.data,
    this.onStartOver,
  });

  final MirrorReflectionData data;
  final VoidCallback? onStartOver;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return MirrorCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.self_improvement_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(data.headline, style: text.titleLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(data.body, style: text.bodyLarge),
          const SizedBox(height: 16),
          MirrorAreasWrap(areas: data.keyAreas),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              data.prompt,
              style: text.titleMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          if (onStartOver != null) ...[
            const SizedBox(height: 18),
            Center(
              child: TextButton.icon(
                onPressed: onStartOver,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start again'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
