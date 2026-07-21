import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../../domain/big_five_depth_tier.dart';

class BigFiveCrossTraitPattern extends StatelessWidget {
  const BigFiveCrossTraitPattern({
    super.key,
    required this.depthTier,
    required this.patternText,
  });

  final BigFiveDepthTier depthTier;
  final String patternText;

  String get _titleKey => switch (depthTier) {
        BigFiveDepthTier.quick => 'big_five_pattern_title_quick',
        BigFiveDepthTier.standard => 'big_five_pattern_title_standard',
        BigFiveDepthTier.deep => 'big_five_pattern_title_deep',
      };

  @override
  Widget build(BuildContext context) {
  if (patternText.trim().isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.t(_titleKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              patternText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
