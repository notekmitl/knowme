import 'package:flutter/material.dart';

import '../../application/three_tradition_consensus.dart';
import '../three_tradition_life_reading.dart';

/// The public report leads with supported life-area interpretations. The
/// comparison and source evidence remain in the passed models for regression
/// checks and audit; they are not duplicated as reader-facing evidence lists.
class ThreeTraditionReportPage extends StatelessWidget {
  const ThreeTraditionReportPage({
    super.key,
    required this.reading,
    this.lifeReading = const ThreeTraditionLifeReading(topics: [], gaps: []),
  });

  final ThreeTraditionReading reading;
  final ThreeTraditionLifeReading lifeReading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('โหราศาสตร์โดยรวม')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              children: [
                Text(
                  'ภาพรวมชีวิตจากสามศาสตร์',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'คำอ่านแต่ละด้านเป็นการตีความประกอบกันจากพื้นดวง '
                  'ไม่ได้หมายความว่าทั้งสามศาสตร์เห็นตรงกันทุกเรื่อง',
                ),
                if (lifeReading.topics.isEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'ข้อมูลที่มีอยู่ยังไม่พอสร้างคำทำนายรายด้าน '
                    'จึงไม่เติมคำอ่านแทนหลักฐานที่ขาด',
                  ),
                ],
                for (final topic in lifeReading.topics) ...[
                  const SizedBox(height: 14),
                  _lifeTopicCard(topic, theme),
                ],
                for (final gap in lifeReading.gaps)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_gapLabel(gap)),
                  ),
                const SizedBox(height: 20),
                Text(
                  'คำอ่านนี้เป็นแนวโน้มจากพื้นดวง ไม่ยืนยันเหตุการณ์หรือ'
                  'ช่วงอายุ เพราะข้อมูลของสามศาสตร์ยังไม่มีช่วงเวลา'
                  'ที่เทียบกันได้โดยตรง',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lifeTopicCard(ThreeTraditionLifeTopic topic, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              topic.reading,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  String _gapLabel(String gap) {
    final title = gap.split(':').first.trim();
    const lifeAreas = {
      'การงาน',
      'การเงิน',
      'ความสัมพันธ์',
      'การดูแลพลังและกิจวัตร',
    };
    return lifeAreas.contains(title)
        ? 'ข้อมูลยังไม่พอสำหรับ$title'
        : 'ข้อมูลยังไม่พอสำหรับคำอ่านบางด้าน';
  }
}
