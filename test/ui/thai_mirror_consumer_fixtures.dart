import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

ThaiMirrorConsumerViewState sampleConsumerViewState({
  String headline = 'คุณเป็นคนรับผิดชอบสูง ชอบคิดก่อนทำ และซื่อสัตย์ต่อคนใกล้ชิด',
  String summary =
      'คุณมักทำตามสัญญาและไม่ทิ้งงานค้างกลางทาง ชอบแยกปัญหาเป็นส่วน ๆ ก่อนตัดสินใจ และเมื่อไว้ใจใครแล้วจะยืนข้างเขาอย่างจริงจัง',
  List<String> tags = const ['รับผิดชอบ', 'คิดละเอียด', 'ซื่อสัตย์'],
  List<String> disclaimers = const [
    'ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย',
    'สิ่งที่อ่านอาจตรงหรือไม่ตรงกับตัวคุณทั้งหมด — ใช้เป็นจุดเริ่มสังเกตตัวเอง',
  ],
}) {
  return ThaiMirrorConsumerViewState(
    hero: ThaiMirrorConsumerHeroState(
      headline: headline,
      summary: summary,
      tags: tags,
    ),
    strengths: const ThaiMirrorInsightSectionState(
      title: 'จุดเด่นของคุณ',
      sectionIcon: Icons.auto_awesome_rounded,
      cards: [
        ThaiMirrorInsightCardState(
          title: 'ทำจริงจังเมื่อให้คำมั่น',
          body:
              'เวลามอบหมายงานคุณจัดลำดับและทำจนสำเร็จ คนรอบข้างเลยไว้ใจให้ดูแลเรื่องสำคัญ',
          accent: ThaiMirrorInsightAccent.strength,
        ),
        ThaiMirrorInsightCardState(
          title: 'คิดรอบคอบก่อนลงมือ',
          body:
              'เวลาเลือกทาง คุณมักดูข้อดีข้อเสียก่อน ทำให้ตัดสินใจแล้วเสียใจน้อยลง',
          accent: ThaiMirrorInsightAccent.strength,
        ),
        ThaiMirrorInsightCardState(
          title: 'ทำตามที่สัญญา',
          body: 'คนรอบข้างรู้ว่ามอบหมายให้คุณแล้วไม่ต้องกังวล งานจะออกมาตรงเวลา',
          accent: ThaiMirrorInsightAccent.strength,
        ),
      ],
    ),
    cautions: const ThaiMirrorInsightSectionState(
      title: 'สิ่งที่ควรระวัง',
      sectionIcon: Icons.terrain_rounded,
      cards: [
        ThaiMirrorInsightCardState(
          title: 'อย่าคิดวนมากเกินไป',
          body:
              'ตั้งเวลาให้ตัวเอง แล้วลงมือเมื่อข้อมูลพอแล้ว ไม่ต้องรอความแน่นอน 100%',
          accent: ThaiMirrorInsightAccent.caution,
        ),
        ThaiMirrorInsightCardState(
          title: 'อย่ารับภาระมากเกินไป',
          body:
              'บางครั้งคุณรับงานหรือความรับผิดชอบมากกว่าที่ร่างกายและใจพร้อม ลองแบ่งบางส่วนให้คนอื่นช่วย',
          accent: ThaiMirrorInsightAccent.caution,
        ),
        ThaiMirrorInsightCardState(
          title: 'อย่าลืมพักผ่อน',
          body:
              'แม้ทำงานเก่ง คุณก็ยังต้องการเวลาพักเพื่อฟื้นพลัง ไม่งั้นจะเหนื่อยล้าโดยไม่รู้ตัว',
          accent: ThaiMirrorInsightAccent.caution,
        ),
      ],
    ),
    advice: const ThaiMirrorAdviceState(
      title: 'คำแนะนำสำหรับช่วงนี้',
      body:
          'ช่วงนี้ให้เวลากับกระบวนการบ้าง ไม่ต้องรีบให้ทุกอย่างสำเร็จในวันเดียว',
    ),
    lifeDashboard: const [
      ThaiMirrorLifeDashboardItemState(
        label: 'การงาน',
        summary: 'งานที่ต้องสร้างผลลัพธ์ยั่งยืนเหมาะกับคุณที่สุด',
        status: ThaiMirrorLifeStatus.bright,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'การเงิน',
        summary: 'คุณมักเก็บออมและใช้จ่ายอย่างมีแผน',
        status: ThaiMirrorLifeStatus.good,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'ความรัก',
        summary: 'ความไว้วางใจคือหัวใจของความสัมพันธ์ที่คุณสร้าง',
        status: ThaiMirrorLifeStatus.good,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'สุขภาพ',
        summary: 'พักผ่อนพอและฟังสัญญาณจากร่างกายบ้าง',
        status: ThaiMirrorLifeStatus.moderate,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'โชคและโอกาส',
        summary: 'โอกาสดีมักมาเมื่อคุณเปิดใจลองสิ่งใหม่ที่เหมาะกับตัวเอง',
        status: ThaiMirrorLifeStatus.veryGood,
      ),
    ],
    sourceTransparency: const ThaiMirrorSourceTransparencyState(
      dataUsed: 'ใช้วัน เดือน ปีเกิด เวลาเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ',
      calculation:
          'นำข้อมูลวันเกิดของคุณมาประมวลผลตามหลักดวงไทย '
          'แล้วแปลงเป็นภาษาที่อ่านเข้าใจง่าย โดยไม่แสดงรายละเอียดเชิงเทคนิค',
      meaning:
          'เป็นแนวทางดูตัวเอง ไม่ใช่คำฟันธง — ชีวิตเปลี่ยนได้เสมอตามการกระทำของคุณ',
    ),
    birthDataConfidence: const ThaiMirrorBirthDataConfidenceState(
      isComplete: true,
      title: 'ข้อมูลวันเกิดครบถ้วน',
      body: 'ใช้วันเกิดและเวลาเกิดในการวิเคราะห์ ผลลัพธ์ด้านบุคลิกน่าเชื่อถือมากขึ้น',
    ),
    secretTip:
        'เคล็ดลับ: ช่วงนี้ให้เวลากับกระบวนการบ้าง ไม่ต้องรีบให้ทุกอย่างสำเร็จในวันเดียว',
    disclaimers: disclaimers,
  );
}

Widget wrapConsumerResultPage(ThaiMirrorConsumerViewState state) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7E57C2)),
      useMaterial3: true,
    ),
    home: ThaiMirrorResultPage(consumerState: state),
  );
}
