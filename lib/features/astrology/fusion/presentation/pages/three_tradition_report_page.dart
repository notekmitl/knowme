import 'package:flutter/material.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_report_view.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';

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
    this.thaiAnalysis,
    this.baziChart,
    this.westernChart,
  });

  final ThreeTraditionReading reading;
  final ThreeTraditionLifeReading lifeReading;
  /// Prepared for the anonymous trial; never load a saved profile or chart.
  final ThaiBetaAnalysis? thaiAnalysis;
  final BaziChartModel? baziChart;
  final AstrologyChartModel? westernChart;

  bool get _hasTrialLenses =>
      thaiAnalysis != null && baziChart != null && westernChart != null;

  void _openLens(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

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
                if (_hasTrialLenses) ...[
                  const SizedBox(height: 18),
                  Text('ดูดวงเฉพาะศาสตร์', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('overall-open-thai'),
                        icon: const Icon(Icons.temple_buddhist_outlined),
                        label: const Text('ไทย'),
                        onPressed: () => _openLens(
                          context,
                          ThaiBetaReportPage(
                            analysis: thaiAnalysis!,
                            audienceOverride:
                                const ThaiBetaEvidenceBadgeAudience.anonymous(),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const Key('overall-open-bazi'),
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('จีน'),
                        onPressed: () => _openLens(
                          context,
                          Scaffold(
                            backgroundColor: const Color(0xFFFFF8F3),
                            appBar: AppBar(title: const Text('ดวงจีน · ปาจื้อ')),
                            body: BaziCompatibilityReportView(
                              report: BaziCompatibilityReportBuilder.build(
                                baziChart!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const Key('overall-open-western'),
                        icon: const Icon(Icons.public_outlined),
                        label: const Text('ตะวันตก'),
                        onPressed: () => _openLens(
                          context,
                          Scaffold(
                            backgroundColor: const Color(0xFF09101F),
                            appBar: AppBar(
                              backgroundColor: const Color(0xFF09101F),
                              foregroundColor: Colors.white,
                              title: const Text('ดวงตะวันตก'),
                            ),
                            body: WesternReaderBody(chart: westernChart!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (lifeReading.topics.isEmpty &&
                    lifeReading.conflicts.isEmpty) ...[
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
                for (final conflict in lifeReading.conflicts)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'ยังไม่แสดงคำทำนายรวมของ${conflict.title} '
                      'เพราะหลักฐานให้มุมที่ขัดกันชัดเจน',
                    ),
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
