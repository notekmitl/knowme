import 'package:flutter/material.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';

class BaziCompatibilityReportView extends StatelessWidget {
  const BaziCompatibilityReportView({
    super.key,
    required this.report,
    this.onExport,
    this.trialChart,
  });

  final BaziCompatibilityReport report;
  final Future<void> Function()? onExport;

  /// Prepared calculation for the anonymous trial's visual summary.
  /// Standalone readers keep their original presentation.
  final BaziChartModel? trialChart;

  @override
  Widget build(BuildContext context) {
    final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trialChart != null) ...[
            _TrialPillars(chart: trialChart!),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6E1D32), Color(0xFF3D245F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '八字 · FOUR PILLARS',
                  style: TextStyle(
                    color: Color(0xFFFFD88A),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  report.title,
                  key: const Key('bazi-report-title'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  report.subtitle,
                  style: const TextStyle(color: Color(0xFFF4EAF4), height: 1.5),
                ),
                if (onExport != null) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('bazi-export-pdf'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD88A),
                      foregroundColor: const Color(0xFF3D245F),
                    ),
                    onPressed: () => onExport!(),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('เก็บคำทำนายเป็น PDF'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final section in report.sections.where(
            (section) => trialChart == null ||
                section.title != 'ผังปาจื้อของคุณ',
          )) ...[
            const SizedBox(height: 12),
            _SectionCard(
              section: section,
              trialVisual: trialChart != null,
              highlighted:
                  section.title.contains('คำทำนายพื้นดวง') ||
                  section.title.contains('Natal tendencies'),
            ),
          ],
        ],
      );
    return SingleChildScrollView(
      padding: trialChart == null
          ? const EdgeInsets.fromLTRB(20, 12, 20, 32)
          : const EdgeInsets.fromLTRB(16, 16, 16, 36),
      child: trialChart == null
          ? content
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: content,
              ),
            ),
    );
  }
}

class _TrialPillars extends StatelessWidget {
  const _TrialPillars({required this.chart});

  final BaziChartModel chart;

  @override
  Widget build(BuildContext context) {
    final pillars = [
      ('ปี', chart.pillars.year),
      ('เดือน', chart.pillars.month),
      ('วัน', chart.pillars.day),
      ('เวลา', chart.pillars.hour),
    ];
    final balance = chart.elementBalance;
    final elements = [
      ('ไม้', balance.wood, const Color(0xFF527E65)),
      ('ไฟ', balance.fire, const Color(0xFFB35645)),
      ('ดิน', balance.earth, const Color(0xFFAE854B)),
      ('ทอง', balance.metal, const Color(0xFF6B7891)),
      ('น้ำ', balance.water, const Color(0xFF4E7797)),
    ];
    return Container(
      key: const Key('trial-bazi-infographic'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDD9C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('สี่เสาของพื้นดวง', style: TextStyle(
            color: Color(0xFF6E1D32),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          )),
          const SizedBox(height: 4),
          const Text('อ่านตามปี เดือน วัน และเวลาเกิด', style: TextStyle(
            color: Color(0xFF594A50), fontSize: 14,
          )),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, pillar) in pillars) ...[
                if (label != 'ปี') const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: label == 'วัน'
                          ? const Color(0xFFFFE9DB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEADACD)),
                    ),
                    child: Column(children: [
                      Text(label, style: const TextStyle(
                        color: Color(0xFF6E1D32),
                        fontWeight: FontWeight.w700,
                      )),
                      const SizedBox(height: 8),
                      Text(pillar.stem, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 23, height: 1.2)),
                      Text(pillar.branch, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 23, height: 1.2)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
          if (balance.totalSlots > 0) ...[
            const SizedBox(height: 20),
            const Text('สัดส่วนธาตุในผังนี้', style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF533248),
            )),
            const SizedBox(height: 10),
            for (final (label, count, color) in elements) ...[
              Row(children: [
                SizedBox(width: 38, child: Text(label)),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: (count / balance.totalSlots).clamp(0.0, 1.0)
                        .toDouble(),
                    minHeight: 9,
                    backgroundColor: const Color(0xFFF0EAE6),
                    color: color,
                  ),
                )),
                const SizedBox(width: 8),
                SizedBox(width: 22, child: Text('$count',
                  textAlign: TextAlign.end)),
              ]),
              const SizedBox(height: 6),
            ],
            const Text('ตัวเลขคือจำนวนตำแหน่งที่คำนวณได้ ไม่ใช่คะแนนดีหรือร้าย',
              style: TextStyle(fontSize: 14, color: Color(0xFF675F63))),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.highlighted,
    required this.trialVisual,
  });

  final BaziCompatibilityReportSection section;
  final bool highlighted;
  final bool trialVisual;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: highlighted
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.42)
          : null,
      child: Padding(
        padding: EdgeInsets.all(trialVisual ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: trialVisual ? 19 : null,
              ),
            ),
            if (section.intro case final intro?) ...[
              const SizedBox(height: 8),
              Text(intro, style: TextStyle(
                height: trialVisual ? 1.6 : 1.45,
                fontSize: trialVisual ? 16 : null,
              )),
            ],
            for (final paragraph in section.paragraphs) ...[
              const SizedBox(height: 10),
              Text(paragraph, style: TextStyle(
                height: trialVisual ? 1.65 : 1.5,
                fontSize: trialVisual ? 16 : null,
              )),
            ],
            for (final row in section.rows) ...[
              const SizedBox(height: 10),
              Text(
                row.label,
                style: TextStyle(
                  fontSize: trialVisual ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(row.value, style: TextStyle(
                height: trialVisual ? 1.55 : 1.4,
                fontSize: trialVisual ? 16 : null,
              )),
            ],
            for (final note in section.notes) ...[
              const SizedBox(height: 10),
              Text('• $note', style: TextStyle(
                height: trialVisual ? 1.6 : 1.45,
                fontSize: trialVisual ? 15 : null,
              )),
            ],
          ],
        ),
      ),
    );
  }
}
