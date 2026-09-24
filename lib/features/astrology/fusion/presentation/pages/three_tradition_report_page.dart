import 'package:flutter/material.dart';

import '../../adapters/lens_theme_output.dart';
import '../../application/three_tradition_consensus.dart';
import '../../domain/entities/astrology_lens.dart';
import '../reading_evidence_text.dart';

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
                const Text(
                  'เปรียบเทียบเฉพาะข้อสังเกตที่มีหลักฐานจากดวงเกิด'
                  ' แต่ละศาสตร์อาจให้ข้อมูลคนละเรื่องและไม่จำเป็นต้องตรงกัน',
                ),
                const SizedBox(height: 20),
                if (reading.agreements.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'ยังไม่พบประเด็นที่อย่างน้อยสองศาสตร์'
                        'สอดคล้องกัน จึงไม่สรุปจุดร่วมจากข้อมูลชุดนี้',
                      ),
                    ),
                  )
                else ...[
                  if (three.isNotEmpty) ...[
                    Text(
                      'ตรงกันทั้ง 3 ศาสตร์',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...three.map(_card),
                  ],
                  if (two.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'สอดคล้องกัน 2 ศาสตร์',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...two.map(_card),
                  ],
                ],
                const SizedBox(height: 16),
                Text(
                  'ข้อสังเกตเฉพาะแต่ละศาสตร์',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                const Text('ข้อมูลในส่วนนี้ไม่ถูกนับเป็นจุดร่วมโดยอัตโนมัติ'),
                const SizedBox(height: 8),
                for (final lens in ThreeTraditionConsensus.lensOrder)
                  _lensCard(lens, reading.byLens[lens] ?? const []),
                const SizedBox(height: 16),
                Text(
                  'เป็นการอ่านแนวโน้มจากพื้นดวง ไม่ใช่คำยืนยันเหตุการณ์ '
                  'ประเด็นที่ไม่มีหลักฐานร่วมเพียงพอจะไม่ถูกสรุปเป็นจุดร่วม '
                  'ผลนี้ไม่ระบุช่วงอายุ เพราะข้อมูลของสามศาสตร์ยังไม่มีช่วงเวลา'
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
            Text(
              'จุดร่วมที่มีหลักฐานจาก $participating '
              '(${item.sourceCount} ศาสตร์) คือเรื่อง$common '
              'แม้แต่ละศาสตร์ใช้ข้อมูลคนละแบบ '
              '${ReadingEvidenceText.meaning(item.exact ? item.key : "independent")}',
            ),
            const SizedBox(height: 12),
            for (final source in item.sources.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '${_lensNames[source.key]}: '
                  '${ReadingEvidenceText.observation(source.value)}',
                ),
              ),
            if (missing.isNotEmpty) ...[
              const SizedBox(height: 5),
              for (final lens in missing)
                Text(
                  '${_lensNames[lens]}: '
                  'ไม่มีหลักฐานที่หนักพอให้นับร่วมในประเด็นนี้'
                  '${(reading.byLens[lens] ?? const <LensThemeOutput>[]).isEmpty ? "" : " — มีข้อสังเกตอื่นแยกด้านล่าง"}',
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lensCard(String lens, List<LensThemeOutput> observations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: Text('• ${ReadingEvidenceText.observation(source)}'),
                ),
          ],
        ),
      ),
    );
  }
}
