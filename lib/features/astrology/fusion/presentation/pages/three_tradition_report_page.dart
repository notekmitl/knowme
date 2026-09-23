import 'package:flutter/material.dart';

import '../../application/three_tradition_consensus.dart';
import '../../domain/entities/astrology_lens.dart';

/// Reader for overlapping birth-chart themes; no invented event dates.
class ThreeTraditionReportPage extends StatelessWidget {
  const ThreeTraditionReportPage({super.key, required this.agreements});

  final List<ThreeTraditionAgreement> agreements;

  static final Map<String, String> _lensNames = {
    AstrologyLens.thaiAstrology.lensId: 'ไทย',
    AstrologyLens.chineseBazi.lensId: 'จีน',
    AstrologyLens.westernNatal.lensId: 'ตะวันตก',
  };

  static const _themes = <String, String>{
    'independent': 'ชอบตัดสินใจด้วยตัวเอง',
    'adaptable': 'ปรับตัวเก่ง',
    'grounded': 'ให้ความสำคัญกับความมั่นคง',
    'expressive': 'สื่อสารความรู้สึกตรงไปตรงมา',
    'reserved': 'เปิดใจเมื่อรู้สึกไว้ใจ',
    'analytical': 'คิดวิเคราะห์ก่อนตัดสินใจ',
    'structured': 'ชอบจัดระบบความคิด',
    'intuitive': 'มองเห็นรูปแบบจากความรู้สึก',
    'flexible': 'ปรับวิธีคิดตามข้อมูลใหม่',
    'responsive': 'ไวต่อความรู้สึกของคนรอบตัว',
    'calm': 'รักษาความนิ่งเมื่อมีแรงกดดัน',
    'passionate': 'ทุ่มเทกับสิ่งที่รู้สึกสำคัญ',
    'supportive': 'ใส่ใจและช่วยเหลือคนใกล้ตัว',
    'diplomatic': 'ประนีประนอมเมื่อเห็นต่าง',
    'loyal': 'จริงจังกับความสัมพันธ์ที่ไว้ใจ',
    'independent_connection': 'ต้องการพื้นที่ส่วนตัวในความสัมพันธ์',
    'driven': 'มุ่งหน้าไปหาเป้าหมาย',
    'responsible': 'รับผิดชอบต่อสิ่งที่รับปาก',
    'leadership': 'ชอบกำหนดทิศทาง',
    'growth_focused': 'ให้ความสำคัญกับการเรียนรู้',
    'reliable': 'ทำสิ่งที่รับปากอย่างสม่ำเสมอ',
    'persistent': 'ทำต่อแม้เจออุปสรรค',
    'creative': 'คิดวิธีใหม่ในการแก้ปัญหา',
    'overthinking': 'อาจคิดวนก่อนลงมือ',
    'rigidity': 'อาจยึดกับแผนมากเกินไป',
    'impatience': 'อาจตัดสินใจเร็วเกินไป',
    'balance': 'มองหาจุดสมดุล',
    'reflection': 'เว้นจังหวะเพื่อทบทวน',
    'openness': 'เปิดรับมุมมองใหม่',
  };

  static const _sharedMeaning = <String, String>{
    'autonomy': 'คุณอาจทำงานได้ดีเมื่อมีพื้นที่ตัดสินใจและเห็นเป้าหมายของตัวเองชัด',
    'structure': 'คุณอาจถนัดงานที่ได้วางแผนและค่อย ๆ ทำจนสำเร็จ',
    'growth': 'คุณอาจเติบโตได้ดีเมื่อมีเรื่องใหม่ให้เรียนรู้และได้ลองปรับวิธีทำ',
    'connection': 'ความสัมพันธ์อาจเดินหน้าได้ดีเมื่อให้ความสำคัญกับความไว้ใจและการดูแลกัน',
    'expression': 'คุณอาจแสดงความรู้สึกและพลังของตัวเองได้ชัดเมื่ออยู่กับเรื่องที่ใส่ใจ',
    'reflection': 'คุณอาจตัดสินใจได้ดีขึ้นเมื่อมีเวลาคิดและทบทวนข้อมูล',
    'creativity': 'คุณอาจถนัดคิดหาวิธีใหม่เมื่อวิธีเดิมไม่ตอบโจทย์',
    'adaptation': 'คุณอาจรับมือกับการเปลี่ยนแปลงได้ด้วยการปรับวิธีคิดตามสถานการณ์',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final three = agreements.where((item) => item.sourceCount == 3).toList();
    final two = agreements.where((item) => item.sourceCount == 2).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('โหราศาสตร์โดยรวม')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              children: [
                Text('อ่านภาพรวมจากสามศาสตร์',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                const Text('คัดเฉพาะประเด็นจากดวงไทย จีน และตะวันตกที่สอดคล้องกัน'
                    'ตั้งแต่สองศาสตร์ขึ้นไปจากข้อมูลเกิดชุดเดียวกัน'),
                const SizedBox(height: 20),
                if (agreements.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('ยังไม่พบประเด็นที่ผลทั้งสามศาสตร์สอดคล้องกัน'
                          'มากพอ จึงไม่มีคำอ่านรวมสำหรับข้อมูลเกิดชุดนี้'),
                    ),
                  )
                else ...[
                  if (three.isNotEmpty) ...[
                    Text('ตรงกันทั้ง 3 ศาสตร์', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...three.map(_card),
                  ],
                  if (two.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('สอดคล้องกัน 2 ศาสตร์',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...two.map(_card),
                  ],
                ],
                const SizedBox(height: 16),
                Text(
                  'เป็นการอ่านแนวโน้มจากพื้นดวง ไม่ใช่คำยืนยันเหตุการณ์ '
                  'หัวข้อที่ไม่พบจุดร่วมชัดเจนหรือมีข้อมูลไม่พอถูกตัดออก '
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
    final firstTheme = item.sources.values.first.themeId;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.exact ? (_themes[firstTheme] ?? firstTheme) :
                (_sharedMeaning[item.key] ?? 'ภาพรวมที่สอดคล้องกัน'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (item.exact)
              Text('ทั้ง ${item.sourceCount} ศาสตร์ให้ประเด็นนี้ตรงกัน')
            else
              const Text('ทั้งสองหรือสามศาสตร์ชี้ไปในทิศทางใกล้กัน'),
            const SizedBox(height: 12),
            for (final source in item.sources.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('${_lensNames[source.key] ?? source.key}: '
                    '${_themes[source.value.themeId] ?? source.value.themeId}'),
              ),
          ],
        ),
      ),
    );
  }
}
