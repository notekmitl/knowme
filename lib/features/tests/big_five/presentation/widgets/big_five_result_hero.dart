import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

class BigFiveResultHero extends StatelessWidget {
  const BigFiveResultHero({
    super.key,
    required this.paragraphs,
  });

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.t('big_five_result_hero_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < paragraphs.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Text(
                paragraphs[i],
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
