import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_consumer_copy.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';

ThaiMirrorConsumerViewState sampleConsumerViewState({
  String headline = 'คุณรับผิดชอบสูง คิดก่อนทำ และซื่อสัตย์ต่อคนใกล้ชิด',
  String summary =
      'คุณมักทำตามสัญญาและไม่ทิ้งงานค้างกลางทาง ชอบแยกปัญหาก่อนตัดสินใจ',
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
    strengths: ThaiMirrorInsightSectionState(
      title: ThaiMirrorConsumerCopy.strengthsSectionTitle,
      sectionIcon: Icons.auto_awesome_rounded,
      cards: const [
        ThaiMirrorInsightCardState(
          title: 'ทำจริงจังเมื่อให้คำมั่น',
          body: 'เวลามอบหมายงานคุณจัดลำดับและทำจนสำเร็จ คนรอบข้างไว้ใจ',
          accent: ThaiMirrorInsightAccent.strength,
        ),
        ThaiMirrorInsightCardState(
          title: 'คิดรอบคอบก่อนลงมือ',
          body: 'เวลาเลือกทาง คุณมักดูข้อดีข้อเสียก่อน ตัดสินใจแล้วเสียใจน้อย',
          accent: ThaiMirrorInsightAccent.strength,
        ),
        ThaiMirrorInsightCardState(
          title: 'ทำตามที่สัญญา',
          body: 'คนรอบข้างรู้ว่ามอบหมายให้คุณแล้วไม่ต้องกังวล งานตรงเวลา',
          accent: ThaiMirrorInsightAccent.strength,
        ),
      ],
    ),
    cautions: ThaiMirrorInsightSectionState(
      title: ThaiMirrorConsumerCopy.cautionsSectionTitle,
      sectionIcon: Icons.terrain_rounded,
      cards: const [
        ThaiMirrorInsightCardState(
          title: 'อย่าคิดวนมากเกินไป',
          body: 'ตั้งเวลาให้ตัวเอง แล้วลงมือเมื่อข้อมูลพอแล้ว',
          accent: ThaiMirrorInsightAccent.caution,
        ),
        ThaiMirrorInsightCardState(
          title: 'อย่ารับภาระมากเกินไป',
          body: 'บางครั้งคุณรับงานมากกว่าที่ร่างกายและใจพร้อม',
          accent: ThaiMirrorInsightAccent.caution,
        ),
        ThaiMirrorInsightCardState(
          title: 'อย่าลืมพักผ่อน',
          body: 'แม้ทำงานเก่ง คุณก็ยังต้องการเวลาพักเพื่อฟื้นพลัง',
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
        currentState: 'งานที่ต้องสร้างผลลัพธ์ยั่งยืนเหมาะกับคุณที่สุด',
        whyItAppears: 'ดวงสะท้อนรับผิดชอบ — คุณมักทำตามสัญญาและไม่ทิ้งงานค้าง',
        suggestedAction: 'ลองเลือกโปรเจกต์ที่เห็นผลระยะยาวชัดเจน',
        status: ThaiMirrorLifeStatus.bright,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'การเงิน',
        currentState: 'คุณมักเก็บออมและใช้จ่ายอย่างมีแผน',
        whyItAppears: 'ดวงสะท้อนวินัย — คุณไม่ชอบใช้เงินสุดวัย',
        suggestedAction: 'ตั้งเป้าหมายออมรายเดือนที่ทำได้จริง',
        status: ThaiMirrorLifeStatus.good,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'ความรัก',
        currentState: 'ความไว้วางใจคือหัวใจของความสัมพันธ์ที่คุณสร้าง',
        whyItAppears: 'ดวงสะท้อนซื่อสัตย์ — คุณยืนข้างคนที่ไว้ใจ',
        suggestedAction: 'บอกความต้องการตรง ๆ ก่อนความเข้าใจคลาดเคลื่อน',
        status: ThaiMirrorLifeStatus.good,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'สุขภาพ',
        currentState: 'พักผ่อนพอและฟังสัญญาณจากร่างกายบ้าง',
        whyItAppears: 'ดวงสะท้อนอดทน — คุณมักผลักดันตัวเองจนลืมพัก',
        suggestedAction: 'จองเวลาพักในปฏิทินเหมือนนัดสำคัญ',
        status: ThaiMirrorLifeStatus.moderate,
      ),
      ThaiMirrorLifeDashboardItemState(
        label: 'โชคและโอกาส',
        currentState: 'โอกาสดีมักมาเมื่อคุณเปิดใจลองสิ่งใหม่ที่เหมาะกับตัวเอง',
        whyItAppears: 'ดวงสะท้อนเปิดรับ — คุณเรียนรู้เร็วเมื่อสนใจจริง',
        suggestedAction: 'ลองคุยกับคนนอกวงเดิมสัปดาห์นี้',
        status: ThaiMirrorLifeStatus.veryGood,
      ),
    ],
    narrativeSections: const [
      ThaiMirrorNarrativeSectionState(
        label: 'ชีวิตด้านการงาน',
        icon: Icons.work_outline_rounded,
        accent: Color(0xFF3D5AFE),
        pullQuote: 'คุณทำงานได้ดีที่สุด เมื่อได้เป็นตัวเอง',
        overview: 'หลายคนที่มีดวงแบบคุณมักทำงานได้ดีเมื่อได้ใช้จุดเด่นของตัวเอง',
        tension: 'คุณอยากทำให้ดีที่สุด แต่ก็กลัวว่าจะออกมาไม่สมบูรณ์อย่างที่หวัง',
        whyItAppears: 'สิ่งนี้สะท้อนจากแนวโน้มที่ปรากฏเด่นในดวงของคุณ',
        advice: 'เลือกงานที่ให้คุณได้ใช้จุดแข็งเต็มที่',
        example: 'เช่น เวลาทีมเจอทางตัน คุณมักเป็นคนที่หาทางออกได้',
      ),
    ],
    signatureInsight: const ThaiMirrorSignatureInsightState(
      eyebrow: 'ถ้าจะเข้าใจคุณ แค่เรื่องเดียว',
      body: 'ถ้าตัดทุกอย่างออกไป แล้วเหลือไว้แค่สิ่งเดียวที่เป็นคุณจริง ๆ '
          'มันคือการที่คุณมองหลาย ๆ ด้านให้รอบก่อนจะลงมือ\n\n'
          'แต่พอเป็นเรื่องของคนที่คุณรัก คุณกลับตัดสินใจด้วยใจเร็วกว่าที่ตั้งใจ\n\n'
          'สิ่งที่คุณกำลังเรียนรู้คือ การเชื่อสัญชาตญาณของตัวเองให้มากขึ้นอีกนิด',
      signature: 'การที่คุณคิดเยอะ ไม่ใช่เพราะลังเล แต่เพราะคุณแคร์ผลลัพธ์',
    ),
    reflectionSummary: const ThaiMirrorReflectionSummaryState(
      title: 'ถ้ามีคนถามว่า “คุณเป็นคนแบบไหน”',
      intro: 'ดวงไทยจะตอบประมาณนี้',
      points: [
        'คนที่ดูแลหน้าที่อย่างเต็มที่',
        'คนที่คิดรอบคอบก่อนตัดสินใจ',
        'คนที่ซื่อสัตย์ต่อคนที่ไว้ใจ',
        'คนที่เรียนรู้เร็วเมื่อสนใจจริง',
        'คนที่มองหาความมั่นคงในระยะยาว',
      ],
    ),
    closingMessage: const ThaiMirrorClosingMessageState(
      eyebrow: 'สิ่งที่ดวงไทยอยากบอกคุณ',
      message: 'คุณมีบางอย่างที่เป็นของคุณเองอยู่แล้ว\n'
          'ลองให้พื้นที่กับด้านนั้นของตัวเอง',
      signature: 'จากดวงไทยของคุณ',
    ),
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
