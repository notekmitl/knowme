import 'package:flutter/material.dart';

class FusionHeroCard extends StatelessWidget {
  const FusionHeroCard({
    super.key,
    required this.summary,
  });

  final String summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          summary,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
