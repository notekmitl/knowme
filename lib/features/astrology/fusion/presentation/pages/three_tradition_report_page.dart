import 'package:knowme/features/astrology/fusion/presentation/trial_reader_typography.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_visual_design.dart';
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

  void _openTrialLens(
    BuildContext context,
    TrialReaderTab tab, {
    bool replace = false,
  }) {
    if (tab == TrialReaderTab.overall) return;
    final route = MaterialPageRoute<void>(
      builder: (_) => Builder(
        builder: (lensContext) {
          final page = switch (tab) {
            TrialReaderTab.thai => ThaiBetaReportPage(
              analysis: thaiAnalysis!,
              anonymousTrial: true,
              audienceOverride: const ThaiBetaEvidenceBadgeAudience.anonymous(),
            ),
            TrialReaderTab.chinese => Scaffold(
              backgroundColor: TrialVisualDesign.chinese,
              appBar: AppBar(
                title: const Text('ดวงจีน · ปาจื้อ'),
                backgroundColor: TrialVisualDesign.chinese,
                foregroundColor: TrialVisualDesign.text,
              ),
              body: BaziCompatibilityReportView(
                report: BaziCompatibilityReportBuilder.build(baziChart!),
                trialChart: baziChart,
              ),
            ),
            TrialReaderTab.western => Scaffold(
              backgroundColor: TrialVisualDesign.western,
              appBar: AppBar(
                backgroundColor: TrialVisualDesign.western,
                foregroundColor: TrialVisualDesign.text,
                title: const Text('ดวงตะวันตก'),
              ),
              body: WesternReaderBody(chart: westernChart!, trialVisual: true),
            ),
            TrialReaderTab.overall => const SizedBox.shrink(),
          };
          return _TrialLensFrame(
            selected: tab,
            onSelect: (target) {
              if (target == TrialReaderTab.overall) {
                Navigator.of(lensContext).pop();
              } else {
                _openTrialLens(lensContext, target, replace: true);
              }
            },
            child: page,
          );
        },
      ),
    );
    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final desktop = MediaQuery.sizeOf(context).width >= 800;
    final compact = MediaQuery.sizeOf(context).width < 360;
    return TrialReaderTypography(
      child: Scaffold(
        backgroundColor: _hasTrialLenses
            ? TrialVisualDesign.overall
            : const Color(0xFFF8F6FA),
        appBar: AppBar(
          title: Text(
            _hasTrialLenses && compact ? 'ดวงรวม' : 'โหราศาสตร์โดยรวม',
          ),
          backgroundColor: _hasTrialLenses
              ? TrialVisualDesign.overall
              : const Color(0xFFF8F6FA),
          foregroundColor: _hasTrialLenses ? TrialVisualDesign.text : _ink,
          actions: _hasTrialLenses
              ? [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.edit_outlined, size: 19),
                    label: const Text('แก้ไขข้อมูล'),
                    style: TextButton.styleFrom(
                      foregroundColor: TrialVisualDesign.text,
                    ),
                  ),
                ]
              : null,
          bottom: _hasTrialLenses && desktop
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TrialReaderNavigation(
                    selected: TrialReaderTab.overall,
                    onSelect: (tab) => _openTrialLens(context, tab),
                    background: TrialVisualDesign.overall,
                    desktop: true,
                  ),
                )
              : null,
        ),
        bottomNavigationBar: _hasTrialLenses && !desktop
            ? TrialReaderNavigation(
                selected: TrialReaderTab.overall,
                onSelect: (tab) => _openTrialLens(context, tab),
                background: TrialVisualDesign.overall,
              )
            : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
                children: [
                  if (_hasTrialLenses &&
                      desktop &&
                      lifeReading.topics.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _overviewHero(context, theme)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (
                                var i = 0;
                                i < lifeReading.topics.length;
                                i++
                              ) ...[
                                if (i > 0) const SizedBox(height: 16),
                                _lifeTopicSection(
                                  lifeReading.topics[i],
                                  theme,
                                  number: i + 1,
                                  total: lifeReading.topics.length,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _overviewHero(context, theme),
                    const SizedBox(height: 12),
                    if (lifeReading.topics.isEmpty &&
                        lifeReading.conflicts.isEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'ข้อมูลที่มีอยู่ยังไม่พอสร้างคำทำนายรายด้าน '
                        'จึงไม่เติมคำอ่านแทนหลักฐานที่ขาด',
                        style: TextStyle(
                          color: _hasTrialLenses
                              ? TrialVisualDesign.text
                              : _ink,
                        ),
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
                              for (
                                var i = 0;
                                i < lifeReading.topics.length;
                                i++
                              )
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
                  ],
                  for (final gap in lifeReading.gaps)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _gapLabel(gap),
                        style: TextStyle(
                          color: _hasTrialLenses
                              ? TrialVisualDesign.muted
                              : _ink,
                        ),
                      ),
                    ),
                  for (final conflict in lifeReading.conflicts)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'ยังไม่แสดงคำทำนายรวมของ${conflict.title} '
                        'เพราะหลักฐานให้มุมที่ขัดกันชัดเจน',
                        style: TextStyle(
                          color: _hasTrialLenses
                              ? TrialVisualDesign.muted
                              : _ink,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'คำอ่านนี้เป็นแนวโน้มจากพื้นดวง ไม่ยืนยันเหตุการณ์หรือ'
                    'ช่วงอายุ เพราะข้อมูลของสามศาสตร์ยังไม่มีช่วงเวลา'
                    'ที่เทียบกันได้โดยตรง',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _hasTrialLenses
                          ? TrialVisualDesign.muted
                          : theme.colorScheme.onSurfaceVariant,
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

  Widget _overviewHero(BuildContext context, ThemeData theme) {
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF251632), Color(0xFF15162B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x665D4C71)),
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
            style: TextStyle(color: TrialVisualDesign.muted, fontSize: 16),
          ),
          const SizedBox(height: 16),
          TrialArtworkBanner(
            asset: TrialVisualDesign.overallArt,
            height: MediaQuery.sizeOf(context).width >= 800 ? 270 : 165,
            alignment: const Alignment(0, -0.25),
          ),
          const SizedBox(height: 16),
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
            style: TextStyle(color: TrialVisualDesign.muted, height: 1.5),
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
          color: const Color(0xFF252138),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TrialVisualDesign.gold.withValues(alpha: 0.30),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFF171423),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: TrialVisualDesign.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (fact != null && fact.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                fact,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TrialVisualDesign.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
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
    final trial = _hasTrialLenses;
    final (icon, accent) = switch (topic.title) {
      'การงาน' => (Icons.terrain_outlined, TrialVisualDesign.gold),
      'การเงิน' => (Icons.savings_outlined, TrialVisualDesign.gold),
      'ความสัมพันธ์' => (Icons.favorite_border, TrialVisualDesign.gold),
      _ => (Icons.spa_outlined, TrialVisualDesign.gold),
    };
    return Container(
      key: Key('overall-topic-card-$number'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: trial ? const Color(0xFF1D1A2D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: trial ? 0.28 : 0.25),
        ),
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
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: accent.withValues(alpha: 0.7)),
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
                        color: trial ? TrialVisualDesign.text : _ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _OverallTopicDetails(
            reading: topic.reading,
            theme: theme,
            accent: accent,
            number: number,
            trial: trial,
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

class _OverallTopicDetails extends StatefulWidget {
  const _OverallTopicDetails({
    required this.reading,
    required this.theme,
    required this.accent,
    required this.number,
    required this.trial,
  });

  final String reading;
  final ThemeData theme;
  final Color accent;
  final int number;
  final bool trial;

  @override
  State<_OverallTopicDetails> createState() => _OverallTopicDetailsState();
}

class _OverallTopicDetailsState extends State<_OverallTopicDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_expanded)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 2, 2, 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: widget.accent.withValues(alpha: 0.55),
                  width: 3,
                ),
              ),
            ),
            child: Text(
              widget.reading,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: widget.theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                height: 1.8,
                color: widget.trial
                    ? TrialVisualDesign.text
                    : ThreeTraditionReportPage._ink,
              ),
            ),
          ),
        ExpansionTile(
          key: Key('overall-topic-details-${widget.number}'),
          tilePadding: EdgeInsets.zero,
          onExpansionChanged: (expanded) =>
              setState(() => _expanded = expanded),
          iconColor: widget.accent,
          collapsedIconColor: widget.accent,
          title: Text('อ่านรายละเอียด', style: TextStyle(color: widget.accent)),
          children: [
            Text(
              widget.reading,
              style: widget.theme.textTheme.bodyLarge?.copyWith(
                color: widget.trial
                    ? TrialVisualDesign.text
                    : ThreeTraditionReportPage._ink,
                fontSize: 17,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }
}

class _TrialLensFrame extends StatelessWidget {
  const _TrialLensFrame({
    required this.selected,
    required this.onSelect,
    required this.child,
  });

  final TrialReaderTab selected;
  final ValueChanged<TrialReaderTab> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 800;
    final background = switch (selected) {
      TrialReaderTab.thai => TrialVisualDesign.thai,
      TrialReaderTab.chinese => TrialVisualDesign.chinese,
      TrialReaderTab.western => TrialVisualDesign.western,
      TrialReaderTab.overall => TrialVisualDesign.overall,
    };
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          if (desktop)
            SafeArea(
              bottom: false,
              child: TrialReaderNavigation(
                selected: selected,
                onSelect: onSelect,
                background: background,
                desktop: true,
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : TrialReaderNavigation(
              selected: selected,
              onSelect: onSelect,
              background: background,
            ),
    );
  }
}
