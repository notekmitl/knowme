import 'package:flutter/material.dart';

import '../../adapters/lens_theme_output.dart';
import '../../application/three_tradition_consensus.dart';
import '../../domain/entities/astrology_lens.dart';
import '../reading_evidence_text.dart';
import '../three_tradition_reading_copy.dart';

/// Evidence-first comparison; unmatched observations remain visible as such.
class ThreeTraditionReportPage extends StatelessWidget {
  const ThreeTraditionReportPage({super.key, required this.reading});

  final ThreeTraditionReading reading;

  static final Map<String, String> _lensNames = {
    AstrologyLens.thaiAstrology.lensId: 'ไทย',
    AstrologyLens.chineseBazi.lensId: 'จีน',
    AstrologyLens.westernNatal.lensId: 'ตะวันตก',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final three = reading.agreements.where((item) => item.sourceCount == 3);
    final two = reading.agreements.where((item) => item.sourceCount == 2);
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
                  'อ่านภาพรวมจากสามศาสตร์',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('สามศาสตร์ให้มุมมองต่างกันจากข้อมูลเกิดชุดเดียวกัน'),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ภาพรวมจากหลักฐานที่มี',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          ThreeTraditionReadingCopy.overview(reading),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'จุดร่วมที่หลักฐานรองรับ',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (reading.agreements.isEmpty)
                  const Text(
                    'ยังไม่มีเรื่องเดียวกันที่อย่างน้อยสองศาสตร์ให้หลักฐาน'
                    'ถึงเกณฑ์ จึงไม่ตีความมุมที่ต่างกันเป็นจุดร่วม',
                  )
                else ...[
                  if (three.isNotEmpty) ...[
                    Text(
                      'สอดคล้องกันทั้ง 3 ศาสตร์',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...three.map(_card),
                  ],
                  if (two.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'สอดคล้องกัน 2 ศาสตร์',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...two.map(_card),
                  ],
                ],
                const SizedBox(height: 16),
                Card(
                  child: ExpansionTile(
                    title: const Text('ดูหลักฐานของแต่ละศาสตร์'),
                    subtitle: const Text(
                      'ข้อสังเกตเหล่านี้ไม่ถูกนับเป็นจุดร่วมโดยอัตโนมัติ',
                    ),
                    children: [
                      for (final lens in ThreeTraditionConsensus.lensOrder)
                        _lensCard(lens, reading.byLens[lens] ?? const []),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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

  Widget _card(ThreeTraditionAgreement item) {
    final participating = item.sources.keys
        .map((lens) => _lensNames[lens]!)
        .join('และ');
    final missing = ThreeTraditionConsensus.lensOrder
        .where((lens) => !item.sources.containsKey(lens))
        .toList();
    final common = item.exact
        ? ReadingEvidenceText.theme(item.sources.values.first.themeId)
        : 'การกำหนดทิศทางด้วยตนเอง';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              common,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('$participatingให้หลักฐานสอดคล้องกันในเรื่องนี้'),
            const SizedBox(height: 10),
            for (final source in item.sources.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '${_lensNames[source.key]}อ้างอิง'
                  '${ReadingEvidenceText.evidencePhrase(source.value, prose: true)}',
                ),
              ),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: 5),
              for (final lens in missing)
                Text(
                  '${_lensNames[lens]}ยังไม่มีหลักฐานหนักพอให้นับร่วมในเรื่องนี้',
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lensCard(String lens, List<LensThemeOutput> observations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _lensNames[lens] ?? lens,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          if (observations.isEmpty)
            const Text('ไม่มีหลักฐานเพียงพอให้แสดงข้อสังเกต')
          else
            for (final source in observations.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'มุมเรื่อง${ReadingEvidenceText.theme(source.themeId)} '
                  'จาก${ReadingEvidenceText.evidencePhrase(source, prose: true)}',
                ),
              ),
        ],
      ),
    );
  }
}
