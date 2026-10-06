import 'package:knowme/features/astrology/fusion/presentation/trial_reader_typography.dart';
import 'package:flutter/material.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/presentation/bazi_compatibility_report_view.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_evidence_badge_audience.dart';
import 'package:knowme/features/thai_beta/presentation/pages/thai_beta_report_page.dart';
import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';
import 'package:knowme/presentation/pages/astrology/western_reader_v2_copy.dart';

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

  static const _ink = Color(0xFF24243E);
  static const _thai = Color(0xFF967245);
  static const _chinese = Color(0xFFA64151);
  static const _western = Color(0xFF5763AC);

  void _openLens(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TrialReaderTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6FA),
        appBar: AppBar(
          title: const Text('โหราศาสตร์โดยรวม'),
          backgroundColor: const Color(0xFFF8F6FA),
          foregroundColor: _ink,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: [
                  _overviewHero(theme),
                  if (_hasTrialLenses) ...[
                    const SizedBox(height: 24),
                    Text(
                      'เปิดอ่านดวงเฉพาะศาสตร์',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _lensButton(
                            key: const Key('overall-open-thai'),
                            label: 'ไทย',
                            icon: Icons.temple_buddhist_outlined,
                            color: _thai,
                            onTap: () => _openLens(
                              context,
                              ThaiBetaReportPage(
                                analysis: thaiAnalysis!,
                                anonymousTrial: true,
                                audienceOverride:
                                    const ThaiBetaEvidenceBadgeAudience.anonymous(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _lensButton(
                            key: const Key('overall-open-bazi'),
                            label: 'จีน',
                            icon: Icons.auto_awesome_outlined,
                            color: _chinese,
                            onTap: () => _openLens(
                              context,
                              Scaffold(
                                backgroundColor: const Color(0xFFFFF8F3),
                                appBar: AppBar(
                                  title: const Text('ดวงจีน · ปาจื้อ'),
                                ),
                                body: BaziCompatibilityReportView(
                                  report: BaziCompatibilityReportBuilder.build(
                                    baziChart!,
                                  ),
                                  trialChart: baziChart,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _lensButton(
                            key: const Key('overall-open-western'),
                            label: 'ตะวันตก',
                            icon: Icons.public_outlined,
                            color: _western,
                            onTap: () => _openLens(
                              context,
                              Scaffold(
                                backgroundColor: const Color(0xFF09101F),
                                appBar: AppBar(
                                  backgroundColor: const Color(0xFF09101F),
                                  foregroundColor: Colors.white,
                                  title: const Text('ดวงตะวันตก'),
                                ),
                                body: WesternReaderBody(
                                  chart: westernChart!,
                                  trialVisual: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (lifeReading.topics.isEmpty &&
                      lifeReading.conflicts.isEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'ข้อมูลที่มีอยู่ยังไม่พอสร้างคำทำนายรายด้าน '
                      'จึงไม่เติมคำอ่านแทนหลักฐานที่ขาด',
                    ),
                  ],
                  if (lifeReading.topics.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 1000;
                        const gap = 24.0;
                        final width = wide
                            ? (constraints.maxWidth - gap) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: gap,
                          runSpacing: 24,
                          children: [
                            for (var i = 0; i < lifeReading.topics.length; i++)
                              SizedBox(
                                width: width,
                                child: _lifeTopicSection(
                                  lifeReading.topics[i],
                                  theme,
                                  number: i + 1,
                                  total: lifeReading.topics.length,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
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
      ),
    );
  }

  Widget _overviewHero(ThemeData theme) {
    final thaiTags = thaiAnalysis?.consumerViewState?.hero.tags;
    final thaiFact = thaiTags == null || thaiTags.isEmpty
        ? null
        : thaiTags.take(3).join(' · ');
    const elementNames = {
      'wood': 'ไม้',
      'fire': 'ไฟ',
      'earth': 'ดิน',
      'metal': 'ทอง',
      'water': 'น้ำ',
    };
    final dayElement = baziChart?.dayMaster.element;
    final chineseFact = dayElement == null || dayElement.isEmpty
        ? null
        : 'ธาตุ${elementNames[dayElement] ?? dayElement}';
    final sunSign = westernChart == null
        ? '—'
        : WesternReaderV2Copy.signLabel(westernChart!.big3['sun']);
    final westernFact = sunSign == '—'
        ? null
        : [
            for (final (key, label) in const [
              ('sun', 'อาทิตย์'),
              ('moon', 'จันทร์'),
              ('rising', 'ลัคนา'),
            ])
              if (WesternReaderV2Copy.signLabel(westernChart!.big3[key]) != '—')
                '$label${WesternReaderV2Copy.signLabel(westernChart!.big3[key])}',
          ].join(' · ');
    return Container(
      key: const Key('trial-overall-infographic'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF463677), Color(0xFF24375C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ภาพรวมชีวิตจากสามศาสตร์',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'พื้นดวงเดียว อ่านผ่านสามมุมมอง',
            style: TextStyle(color: Color(0xFFE8E2F7), fontSize: 16),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _heroLens('ไทย', Icons.temple_buddhist_outlined, _thai, thaiFact),
              const SizedBox(width: 8),
              _heroLens(
                'จีน',
                Icons.auto_awesome_outlined,
                _chinese,
                chineseFact,
              ),
              const SizedBox(width: 8),
              _heroLens(
                'ตะวันตก',
                Icons.public_outlined,
                _western,
                westernFact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'คำอ่านแต่ละด้านเป็นการตีความประกอบกันจากพื้นดวง '
            'ไม่ได้หมายความว่าทั้งสามศาสตร์เห็นตรงกันทุกเรื่อง',
            style: TextStyle(color: Color(0xFFE8E2F7), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _heroLens(String label, IconData icon, Color accent, String? fact) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (fact != null && fact.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                fact,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE8E2F7), fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lensButton({
    required Key key,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.24)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lifeTopicSection(
    ThreeTraditionLifeTopic topic,
    ThemeData theme, {
    required int number,
    required int total,
  }) {
    final (icon, accent) = switch (topic.title) {
      'การงาน' => (Icons.work_outline, const Color(0xFF55749C)),
      'การเงิน' => (Icons.savings_outlined, const Color(0xFF977536)),
      'ความสัมพันธ์' => (Icons.favorite_border, const Color(0xFFAA5979)),
      _ => (Icons.spa_outlined, const Color(0xFF548871)),
    };
    return Container(
      key: Key('overall-topic-card-$number'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${number.toString().padLeft(2, '0')} / '
                      '${total.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 2, 2, 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: accent.withValues(alpha: 0.55),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              topic.reading,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                height: 1.8,
                color: _ink,
              ),
            ),
          ),
          ExpansionTile(
            key: Key('overall-topic-details-$number'),
            tilePadding: EdgeInsets.zero,
            title: Text('อ่านรายละเอียด', style: TextStyle(color: accent)),
            children: [
              Text(
                topic.reading,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _ink,
                  fontSize: 17,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
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
