import 'package:flutter/material.dart';

import '../integration/profile_narrative_mapper.dart';

/// Profile narrative section — identity + growth from pattern runtime.
class ProfileNarrativeSection extends StatelessWidget {
  const ProfileNarrativeSection({
    super.key,
    required this.data,
  });

  final ProfileNarrativeData data;

  @override
  Widget build(BuildContext context) {
    if (!data.isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ภาพรวมตัวตนจาก KnowMe',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (data.identityParagraphs.isNotEmpty)
          _ModeBlock(
            title: 'ตัวตน',
            paragraphs: data.identityParagraphs,
          ),
        if (data.growthParagraphs.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ModeBlock(
            title: 'การเติบโต',
            paragraphs: data.growthParagraphs,
          ),
        ],
        if (data.relationshipParagraphs.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ModeBlock(
            title: 'ความสัมพันธ์',
            paragraphs: data.relationshipParagraphs,
          ),
        ],
        if (data.decisionParagraphs.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ModeBlock(
            title: 'การตัดสินใจ',
            paragraphs: data.decisionParagraphs,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'ความมั่นใจ: ${_confidenceLabel(data.confidenceBand)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  static String _confidenceLabel(String band) {
    return switch (band) {
      'high' => 'สูง',
      'medium' => 'ปานกลาง',
      _ => 'เริ่มต้น',
    };
  }
}

class _ModeBlock extends StatelessWidget {
  const _ModeBlock({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<ProfileNarrativeParagraph> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final paragraph in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paragraph.text,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 4),
                Text(
                  paragraph.patternLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade300,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
