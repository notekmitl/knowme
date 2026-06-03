import 'package:flutter/material.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/data/mbti/mbti_types.dart';

import '../domain/mbti_models.dart';

/// Frozen — no callers; use [MbtiResultPage] after mini finish.
@Deprecated('Use MbtiResultPage. Kept for reference until cleanup.')
class MbtiMiniResultPage extends StatelessWidget {
  final MbtiResultSummary summary;

  const MbtiMiniResultPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final lang = AppText.lang;
    final type = summary.type;
    final mbti = mbtiTypes[type];

    return Scaffold(
      appBar: AppBar(title: Text(AppText.t('your_type'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mbti?.title[lang] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppText.t('traits'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _traitBar('E', 'I'),
            _traitBar('S', 'N'),
            _traitBar('T', 'F'),
            _traitBar('J', 'P'),
            if (mbti != null) ...[
              const SizedBox(height: 24),
              Text(
                mbti.description[lang] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Text(
                'Strengths',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...mbti.strengths.map((s) => Text('• ${s[lang]}')),
              const SizedBox(height: 24),
              Text(
                'Weaknesses',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...mbti.weaknesses.map((s) => Text('• ${s[lang]}')),
              const SizedBox(height: 24),
              Text(
                'Careers',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...mbti.careers.map((s) => Text('• ${s[lang]}')),
              const SizedBox(height: 24),
              Text(
                'Relationships',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...mbti.relationships.map((s) => Text('• ${s[lang]}')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _traitBar(String a, String b) {
    final aValue = summary.dimension(a);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$a / $b'),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: aValue, minHeight: 8),
        ],
      ),
    );
  }
}
