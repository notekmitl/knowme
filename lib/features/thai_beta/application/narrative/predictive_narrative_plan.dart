/// Typed single-source plan for Predictive Narrative V2.
///
/// Web, infographic, dedicated PDF, browser print and text extraction project
/// from this model. The plan owns ordering, semantic ownership, evidence,
/// period/domain scope and Known/Unknown eligibility before prose reaches a
/// presentation surface.
library;

import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';

import '../thai_beta_analysis.dart';
import 'thai_beta_narrative_composer.dart';

enum NarrativeSectionRole {
  overview,
  past,
  current,
  work,
  finance,
  relationship,
  health,
  support,
  horizon,
  nextLifePeriod,
  summary,
  advice,
  disclaimer,
  omission,
}

enum NarrativeAtomRole { prediction, summary, advice, disclosure, omission }

enum DomainScope {
  lifePath,
  supportAndFamily,
  educationAndSocial,
  work,
  workAndCommitment,
  finance,
  relationship,
  health,
  support,
  luck,
  financeAndRelationship,
  foundation,
  advice,
  disclosure,
  omission,
}

enum KnownUnknownEligibility { knownOnly, unknownOnly, both }

class PeriodScope {
  const PeriodScope(this.id, {this.start, this.end});

  final String id;
  final DateTime? start;
  final DateTime? end;

  Map<String, Object?> toMap() => {
    'id': id,
    if (start != null) 'start': _isoDate(start!),
    if (end != null) 'end': _isoDate(end!),
  };
}

class EvidenceTrace {
  const EvidenceTrace(this.refs);

  final List<String> refs;

  Map<String, Object?> toMap() => {'refs': refs};
}

class SemanticOwner {
  const SemanticOwner({required this.id, required this.meaningKey});

  final String id;
  final String meaningKey;

  Map<String, Object?> toMap() => {'id': id, 'meaningKey': meaningKey};
}

abstract class NarrativeAtom {
  const NarrativeAtom({
    required this.id,
    required this.role,
    required this.readerText,
    required this.compactText,
    required this.owner,
    required this.evidence,
    required this.period,
    required this.domain,
    required this.eligibility,
  });

  final String id;
  final NarrativeAtomRole role;
  final String readerText;
  final String compactText;
  final SemanticOwner owner;
  final EvidenceTrace evidence;
  final PeriodScope period;
  final DomainScope domain;
  final KnownUnknownEligibility eligibility;

  Map<String, Object?> toMap() => {
    'id': id,
    'role': role.name,
    'readerText': readerText,
    'compactText': compactText,
    'semanticOwner': owner.toMap(),
    'evidence': evidence.toMap(),
    'period': period.toMap(),
    'domain': domain.name,
    'eligibility': eligibility.name,
  };
}

class PredictionAtom extends NarrativeAtom {
  const PredictionAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.prediction);
}

class SummaryAtom extends NarrativeAtom {
  const SummaryAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.summary);
}

class AdviceAtom extends NarrativeAtom {
  const AdviceAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    super.eligibility = KnownUnknownEligibility.knownOnly,
  }) : super(role: NarrativeAtomRole.advice);
}

class DisclosureAtom extends NarrativeAtom {
  const DisclosureAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
    required super.eligibility,
  }) : super(role: NarrativeAtomRole.disclosure);
}

class OmissionAtom extends NarrativeAtom {
  const OmissionAtom({
    required super.id,
    required super.readerText,
    required super.compactText,
    required super.owner,
    required super.evidence,
    required super.period,
    required super.domain,
  }) : super(
         role: NarrativeAtomRole.omission,
         eligibility: KnownUnknownEligibility.unknownOnly,
       );
}

class NarrativeBlock {
  const NarrativeBlock({this.heading, required this.atoms});

  final String? heading;
  final List<NarrativeAtom> atoms;

  Map<String, Object?> toMap() => {
    if (heading != null) 'heading': heading,
    'atoms': atoms.map((atom) => atom.toMap()).toList(growable: false),
  };
}

class NarrativeSection {
  const NarrativeSection({
    required this.id,
    required this.role,
    required this.title,
    required this.blocks,
  });

  final String id;
  final NarrativeSectionRole role;
  final String title;
  final List<NarrativeBlock> blocks;

  List<NarrativeAtom> get atoms =>
      blocks.expand((block) => block.atoms).toList(growable: false);

  Map<String, Object?> toMap() => {
    'id': id,
    'role': role.name,
    'title': title,
    'blocks': blocks.map((block) => block.toMap()).toList(growable: false),
  };
}

class PredictiveNarrativePlan {
  const PredictiveNarrativePlan({
    required this.contextId,
    required this.isKnownTime,
    required this.title,
    required this.subtitle,
    required this.sections,
    this.monthlyTimelineAvailable = false,
  });

  factory PredictiveNarrativePlan.fromAnalysis(ThaiBetaAnalysis analysis) {
    if (!analysis.input.hasBirthTime) return _unknownPlan(analysis);

    final birthData = analysis.pipelineResult?.birthData;
    final remainder = ThaiRemainderMetadataResolver.resolve(
      profile: analysis.profile,
      birthData: birthData,
    );
    final weekday = birthData?.thaiWeekdayNumber;
    final contextId = remainder == null || weekday == null
        ? 'mahabhut2537.unresolved'
        : 'mahabhut2537.rem${remainder.value}.${_weekdayKey(weekday)}';
    final timeline = analysis.pipelineResult?.lifePeriods;
    final acceptedContext =
        contextId == 'mahabhut2537.rem0.saturday' &&
        timeline?.currentAge == 44 &&
        timeline?.current.startAge == 42 &&
        timeline?.current.endAge == 62;
    if (acceptedContext) {
      return _acceptedKnownPlan(analysis, contextId: contextId);
    }
    return _contextualKnownPlan(analysis, contextId: contextId);
  }

  final String contextId;
  final bool isKnownTime;
  final String title;
  final String subtitle;
  final List<NarrativeSection> sections;
  final bool monthlyTimelineAvailable;

  List<NarrativeAtom> get atoms =>
      sections.expand((section) => section.atoms).toList(growable: false);

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'isKnownTime': isKnownTime,
    'title': title,
    'subtitle': subtitle,
    'monthlyTimelineAvailable': monthlyTimelineAvailable,
    'sections': sections
        .map((section) => section.toMap())
        .toList(growable: false),
  };
}

PredictiveNarrativePlan _unknownPlan(ThaiBetaAnalysis analysis) {
  const omissionText =
      'ไม่มีเวลาเกิด — รายงานจึงเว้นคำทำนายช่วงชีวิตที่ต้องใช้เวลาเกิด แทนการเดาข้อมูลที่ไม่มี';
  const disclosureText =
      'คำทำนายเป็นมุมมองตามความเชื่อ และควรเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ';
  return PredictiveNarrativePlan(
    contextId: 'unknown-time',
    isKnownTime: false,
    title: 'รายงานฉบับย่อ',
    subtitle: _unknownSubtitle(analysis),
    sections: const [
      NarrativeSection(
        id: 'report-short',
        role: NarrativeSectionRole.omission,
        title: '',
        blocks: [
          NarrativeBlock(
            atoms: [
              OmissionAtom(
                id: 'RC11-U-OMISSION-01',
                readerText: omissionText,
                compactText: 'เว้นหัวข้อที่ต้องใช้เวลาเกิด แทนการเดาข้อมูล',
                owner: SemanticOwner(
                  id: 'OMISSION-U-01',
                  meaningKey: 'unknown-time-fail-closed',
                ),
                evidence: EvidenceTrace(['OMISSION-U-01']),
                period: PeriodScope('UNAVAILABLE'),
                domain: DomainScope.omission,
              ),
              DisclosureAtom(
                id: 'RC11-U-DISCLOSURE-01',
                readerText: disclosureText,
                compactText: 'เทียบคำอ่านกับข้อเท็จจริงก่อนตัดสินใจ',
                owner: SemanticOwner(
                  id: 'DISCLOSURE-U-01',
                  meaningKey: 'belief-disclosure',
                ),
                evidence: EvidenceTrace(['DISCLOSURE-U-01']),
                period: PeriodScope('REPORT'),
                domain: DomainScope.disclosure,
                eligibility: KnownUnknownEligibility.unknownOnly,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

PredictiveNarrativePlan _acceptedKnownPlan(
  ThaiBetaAnalysis analysis, {
  required String contextId,
}) {
  final age = analysis.pipelineResult!.lifePeriods!.currentAge;
  final range = _longHorizonRange(analysis.asOf);
  PredictionAtom prediction({
    required String id,
    required String owner,
    required String meaning,
    required String text,
    required String compact,
    required String period,
    required DomainScope domain,
    required List<String> refs,
  }) => PredictionAtom(
    id: id,
    readerText: text,
    compactText: compact,
    owner: SemanticOwner(id: owner, meaningKey: meaning),
    evidence: EvidenceTrace(refs),
    period: PeriodScope(period),
    domain: domain,
  );

  final overview = prediction(
    id: 'RC11-K-OVERVIEW-01',
    owner: 'OAS-01',
    meaning: 'life-arc-major-periods',
    period: '0-62',
    domain: DomainScope.lifePath,
    refs: const [
      'placement.mahabhut2537.rem0.saturday.saturn.0_10',
      'placement.mahabhut2537.rem0.saturday.jupiter.11_29',
      'placement.mahabhut2537.rem0.saturday.rahu.30_41',
      'placement.mahabhut2537.rem0.saturday.venus.42_62',
    ],
    text:
        'ชีวิตเดินเป็นช่วงชัดเจน วัยเด็กอยู่ใต้เงื่อนไขของบ้าน ช่วงอายุ 11–29 ได้ออกไปพบโลกที่กว้างขึ้น ช่วงอายุ 30–41 เจอการเปลี่ยนครั้งใหญ่ และหลังอายุ 42 ประสบการณ์ที่สั่งสมมาเริ่มให้ผลกับชีวิต',
    compact: 'ประสบการณ์ที่สั่งสมมาเริ่มให้ผลกับชีวิต',
  );
  final past1 = prediction(
    id: 'RC11-K-PAST-01',
    owner: 'OAS-03',
    meaning: 'past-family-constraint',
    period: '1-10',
    domain: DomainScope.supportAndFamily,
    refs: const ['placement.mahabhut2537.rem0.saturday.saturn.0_10'],
    text:
        'วัย 1–10 ปีมีเงื่อนไขจากครอบครัวและผู้ใหญ่เข้ามากำหนดชีวิตมากกว่าวัยอื่น บางช่วงต้องเปลี่ยนความเคยชินหรือช่วยรับภาระในบ้านเร็วกว่าวัย ความสบายในวัยเด็กจึงถูกแบ่งด้วยหน้าที่ที่หลีกเลี่ยงไม่ได้',
    compact: 'วัยเด็กอยู่ใต้เงื่อนไขของบ้านและหน้าที่',
  );
  final past2 = prediction(
    id: 'RC11-K-PAST-02',
    owner: 'OAS-04',
    meaning: 'past-world-expansion',
    period: '11-29',
    domain: DomainScope.educationAndSocial,
    refs: const ['placement.mahabhut2537.rem0.saturday.jupiter.11_29'],
    text:
        'ช่วงอายุ 11–29 ชีวิตเปิดกว้างขึ้นผ่านการเรียน งาน และสังคมใหม่ เส้นทางเดิมขยายออกเพราะได้พบคนที่มีประสบการณ์กว่า พร้อมกับการเปลี่ยนแวดวงหรือเปลี่ยนวิธีมองหาโอกาสจากเดิม',
    compact: 'การเรียน งาน และสังคมใหม่เปิดโลกให้กว้างขึ้น',
  );
  final past3 = prediction(
    id: 'RC11-K-PAST-03',
    owner: 'OAS-05',
    meaning: 'past-responsibility-agreement',
    period: '11-29',
    domain: DomainScope.relationship,
    refs: const ['placement.mahabhut2537.rem0.saturday.jupiter.11_29'],
    text:
        'ช่วงปลายของรอบนี้เริ่มรับผิดชอบเรื่องงานและเงินจริงจังขึ้น ความสัมพันธ์บางส่วนเปลี่ยนจากการคบหาตามสถานการณ์มาเป็นการตกลงว่าใครจะอยู่ต่อ ใครจะห่างออก และเรื่องใดต้องจัดการด้วยตัวเอง',
    compact: 'หน้าที่และข้อตกลงในความสัมพันธ์ชัดขึ้น',
  );
  final past4 = prediction(
    id: 'RC11-K-PAST-04',
    owner: 'OAS-06',
    meaning: 'past-role-expansion',
    period: '30-41',
    domain: DomainScope.work,
    refs: const ['GRA-R0-SAT-30_41-DET-RISE', 'PIC-R0-SAT-30_41-WORK'],
    text:
        'ช่วงอายุ 30–41 งานเปลี่ยนทิศอย่างชัดเจน หน้าที่ชุดใหม่เข้ามาแทนวิธีทำงานเดิม และผลงานที่ทำต่อเนื่องพาไปสู่ขอบเขตงานที่กว้างขึ้น',
    compact: 'ผลงานต่อเนื่องพางานไปสู่ขอบเขตที่กว้างขึ้น',
  );
  final past5 = prediction(
    id: 'RC11-K-PAST-05',
    owner: 'OAS-07',
    meaning: 'past-ending-new-base',
    period: '30-41',
    domain: DomainScope.workAndCommitment,
    refs: const [
      'placement.mahabhut2537.rem0.saturday.rahu.30_41',
      'GRA-R0-SAT-30_41-DET-RISE',
    ],
    text:
        'ในช่วงเดียวกัน งานหรือข้อตกลงสำคัญเปลี่ยนรูปแบบ ทางที่เดินต่อได้กลายเป็นฐานของรอบปัจจุบัน ส่วนภาระที่กินแรงแต่ไม่พาชีวิตไปข้างหน้าค่อย ๆ จบลงหรือมีคนอื่นรับช่วงต่อ',
    compact: 'ทางที่เดินต่อได้กลายเป็นฐานของรอบปัจจุบัน',
  );
  final current = prediction(
    id: 'RC11-K-CURRENT-01',
    owner: 'OAS-09',
    meaning: 'current-close-and-open',
    period: 'age$age',
    domain: DomainScope.work,
    refs: const [
      'placement.mahabhut2537.rem0.saturday.venus.42_62',
      'prediction.career.current.strong',
    ],
    text:
        'อายุ $age เป็นปีเปลี่ยนผ่าน ภาระเก่าต้องได้ข้อสรุป ขอบเขตที่เคยปล่อยค้างจะถูกจัดใหม่ และชีวิตเริ่มกันพื้นที่ไว้ให้เรื่องที่สำคัญกว่าเดิม',
    compact: 'ปิดภาระเก่าและกันพื้นที่ให้เรื่องสำคัญกว่าเดิม',
  );
  final work1 = prediction(
    id: 'RC11-K-WORK-01',
    owner: 'OAS-10',
    meaning: 'work-decision-authority',
    period: '42-62|age$age',
    domain: DomainScope.work,
    refs: const [
      'SDC-R0-SAT-42_62-WORK',
      'SDC-R0-SAT-42_62-FLOW',
      'prediction.career.current.strong',
    ],
    text:
        'หน้าที่การงานขยับจากการทำตามโจทย์ไปสู่การกำหนดทางเดินของงาน คุณจะรับผิดชอบผลลัพธ์มากขึ้น ได้ตัดสินใจเรื่องที่กระทบคนอื่น และถูกเรียกใช้ในงานที่ต้องอาศัยประสบการณ์มากกว่าการลงแรงอย่างเดียว',
    compact: 'รับผิดชอบผลลัพธ์และตัดสินใจด้วยประสบการณ์มากขึ้น',
  );
  final work2 = prediction(
    id: 'RC11-K-WORK-02',
    owner: 'OAS-11',
    meaning: 'work-new-from-output',
    period: '42-62|age$age',
    domain: DomainScope.work,
    refs: const ['SDC-R0-SAT-42_62-WORK', 'prediction.career.current.strong'],
    text:
        'โอกาสงานใหม่จะมาจากผลงานที่คนเคยเห็นและเชื่อมือ ส่วนงานเดิมที่ซ้ำ เสียเวลา หรือให้ภาระมากกว่าผลตอบแทนจะลดบทบาทลง สุดท้ายงานจะเหลือน้อยประเภทแต่แต่ละเรื่องมีน้ำหนักมากขึ้น',
    compact: 'โอกาสใหม่มาจากผลงานที่คนเคยเห็นและเชื่อมือ',
  );
  final finance1 = prediction(
    id: 'RC11-K-FINANCE-01',
    owner: 'OAS-12',
    meaning: 'finance-work-linked-income',
    period: '42-62|age$age',
    domain: DomainScope.finance,
    refs: const [
      'SDC-R0-SAT-42_62-FINANCE',
      'GRA-R0-SAT-42_62-SRI-RISE',
      'prediction.finance.current.strong',
    ],
    text:
        'รายได้ขยับตามบทบาทและผลงาน เงินหลักมาจากงานที่ทำสำเร็จและทักษะที่ใช้ได้จริง ไม่ใช่การเสี่ยงโดยไม่มีข้อมูลรองรับ',
    compact: 'รายได้ขยับตามบทบาทและผลงานที่ทำสำเร็จ',
  );
  final finance2 = prediction(
    id: 'RC11-K-FINANCE-02',
    owner: 'OAS-13',
    meaning: 'finance-flow-and-expense',
    period: '42-62|age$age',
    domain: DomainScope.finance,
    refs: const [
      'SDC-R0-SAT-42_62-FINANCE',
      'prediction.finance.current.strong',
    ],
    text:
        'เงินหมุนคล่องขึ้น แต่รายจ่ายก้อนสำคัญเกี่ยวกับงาน บ้าน หรือภาระที่ต้องจัดการให้จบจะเข้ามาพร้อมกัน ฐานการเงินจะค่อย ๆ นิ่งเมื่อเงินไม่ต้องไหลไปเลี้ยงภาระที่ไม่สร้างผลต่อเนื่อง',
    compact: 'เงินคล่องขึ้นพร้อมรายจ่ายก้อนสำคัญที่ต้องจัดการ',
  );
  final relationship1 = prediction(
    id: 'RC11-K-RELATIONSHIP-01',
    owner: 'OAS-14',
    meaning: 'relationship-clarity-actions',
    period: '42-62|age$age',
    domain: DomainScope.relationship,
    refs: const [
      'prediction.relationship.current.strong',
      'SDC-R0-SAT-42_62-FLOW',
    ],
    text:
        'ความสัมพันธ์ที่คลุมเครือจะชัดขึ้นจากการกระทำและข้อตกลง คนที่พร้อมเดินต่อจะแสดงความรับผิดชอบให้เห็น ส่วนคนที่มีแต่คำพูดจะเว้นระยะหรือหลุดออกจากชีวิตเอง',
    compact: 'ความสัมพันธ์ชัดขึ้นจากการกระทำและข้อตกลง',
  );
  final relationship2 = prediction(
    id: 'RC11-K-RELATIONSHIP-02',
    owner: 'OAS-15',
    meaning: 'relationship-agreement-distance',
    period: '42-62|age$age',
    domain: DomainScope.relationship,
    refs: const ['prediction.relationship.current.strong'],
    text:
        'บทสนทนาเรื่องเวลา หน้าที่ เงิน และพื้นที่ส่วนตัวจะตรงไปตรงมาขึ้น บางความสัมพันธ์จึงแน่นแฟ้นกว่าเดิม ขณะที่บางความสัมพันธ์เปลี่ยนระยะเพื่อให้แต่ละฝ่ายกลับไปจัดการชีวิตของตัวเอง',
    compact: 'แบ่งเวลา หน้าที่ และพื้นที่ส่วนตัวให้ชัด',
  );
  final health1 = prediction(
    id: 'RC11-K-HEALTH-01',
    owner: 'OAS-16',
    meaning: 'health-load-recovery',
    period: '42-62|age$age',
    domain: DomainScope.health,
    refs: const [
      'prediction.health.current.strong',
      'prediction.career.current.strong',
    ],
    text:
        'ภาระงานที่เพิ่มขึ้นทำให้ความเครียดและการพักไม่พอแสดงผลชัด ร่างกายใช้เวลาฟื้นจากวันที่ทำงานต่อเนื่องนานกว่าเดิม และแรงจะหมดเร็วเมื่อรับหลายเรื่องพร้อมกัน',
    compact: 'ภาระงานทำให้ต้องกันเวลาพักและฟื้นตัวให้พอ',
  );
  final health2 = prediction(
    id: 'RC11-K-HEALTH-02',
    owner: 'OAS-17',
    meaning: 'health-rest-restoration',
    period: '42-62|age$age',
    domain: DomainScope.health,
    refs: const ['prediction.health.current.strong'],
    text:
        'พอภาระเบาลงและเรื่องค้างลดลง กำลังจะค่อย ๆ กลับมา วันที่ได้นอนและพักต่อเนื่องจะฟื้นตัวได้ดีกว่าการหยุดสั้น ๆ แล้วกลับไปเร่งงานเหมือนเดิม',
    compact: 'การนอนและพักต่อเนื่องช่วยให้กำลังกลับมา',
  );
  final support1 = prediction(
    id: 'RC11-K-SUPPORT-01',
    owner: 'OAS-18',
    meaning: 'support-existing-network',
    period: '42-62|age$age',
    domain: DomainScope.support,
    refs: const ['SDC-R0-SAT-42_62-SUPPORT'],
    text:
        'แรงหนุนมาจากผู้ใหญ่ ครู เพื่อน และคนที่เคยทำงานร่วมกัน คนเหล่านี้จะช่วยเปิดทาง แนะนำโอกาส หรือพาเรื่องที่ติดขัดกลับมาเดินได้อีกครั้ง',
    compact: 'ผู้ใหญ่ ครู เพื่อน และคนร่วมงานเดิมช่วยเปิดทาง',
  );
  final support2 = prediction(
    id: 'RC11-K-SUPPORT-02',
    owner: 'OAS-19',
    meaning: 'luck-from-work-reputation',
    period: '42-62|age$age',
    domain: DomainScope.luck,
    refs: const [
      'SDC-R0-SAT-42_62-FINANCE',
      'SDC-R0-SAT-42_62-SUPPORT',
      'prediction.career.current.strong',
    ],
    text:
        'โอกาสเด่นจะมาจากงานเก่า คนรู้จักเดิม หรือเรื่องที่เคยทำสำเร็จ ชื่อเสียงจากผลงานจะพาโอกาสกลับมา มากกว่าการได้สิ่งใหญ่จากการเสี่ยงโดยไม่มีฐานรองรับ',
    compact: 'ผลงานและคนรู้จักเดิมพาโอกาสกลับมา',
  );
  final horizon1 = prediction(
    id: 'RC11-K-HORIZON-01',
    owner: 'OAS-20',
    meaning: 'horizon-work-status-change',
    period: '${_isoDate(range.$1)}/${_isoDate(range.$2)}|age$age-${age + 1}',
    domain: DomainScope.work,
    refs: const [
      'PIC-R0-SAT-HORIZON-WORK',
      'prediction.career.next12Months.strong',
    ],
    text:
        'ระหว่างวันที่ ${_thaiLongDate(range.$1)} ถึง ${_thaiLongDate(range.$2)} งานที่ค้างจะได้ข้อสรุป และหน้าที่ชุดใหม่จะเริ่มเข้าที่ ภายในรอบนี้คุณจะรู้ชัดว่างานใดอยู่ต่อและงานใดต้องส่งต่อ',
    compact: 'งานค้างได้ข้อสรุป และหน้าที่ชุดใหม่เริ่มเข้าที่',
  );
  final horizon2 = prediction(
    id: 'RC11-K-HORIZON-02',
    owner: 'OAS-21',
    meaning: 'horizon-finance-relationship-agreements',
    period: '${_isoDate(range.$1)}/${_isoDate(range.$2)}|age$age-${age + 1}',
    domain: DomainScope.financeAndRelationship,
    refs: const [
      'prediction.finance.next12Months.strong',
      'prediction.relationship.next12Months.strong',
    ],
    text:
        'ในช่วงเดียวกัน รายรับและภาระทางเงินจะขยับขึ้นพร้อมกัน ส่วนข้อตกลงสำคัญในความสัมพันธ์จะได้คำตอบจากการแบ่งเวลาและหน้าที่ให้ชัด',
    compact: 'รายรับ ภาระทางเงิน และข้อตกลงขยับพร้อมกัน',
  );
  final horizon3 = prediction(
    id: 'RC11-K-HORIZON-03',
    owner: 'OAS-22',
    meaning: 'horizon-support-closes-blockers',
    period: '${_isoDate(range.$1)}/${_isoDate(range.$2)}|age$age-${age + 1}',
    domain: DomainScope.support,
    refs: const ['PIC-R0-SAT-HORIZON-SUPPORT', 'SDC-R0-SAT-42_62-SUPPORT'],
    text:
        'แรงหนุนที่มีอยู่จะช่วยให้การเจรจาและการปิดเรื่องค้างเดินเร็วขึ้น อุปสรรคที่เคยทำให้งานชะงักจะลดลงภายในรอบนี้',
    compact: 'แรงหนุนช่วยให้การเจรจาและเรื่องค้างเดินเร็วขึ้น',
  );
  final next1 = prediction(
    id: 'RC11-K-NEXT-01',
    owner: 'OAS-23',
    meaning: 'next-foundation-assets',
    period: '63-79',
    domain: DomainScope.foundation,
    refs: const [
      'placement.mahabhut2537.rem0.saturday.mercury.63_79',
      'GRA-R0-SAT-63_79-MULA-RISE',
      'PIC-R0-SAT-63_79-FOUNDATION',
    ],
    text:
        'เมื่ออายุ 63 ปี ชีวิตเข้าสู่ช่วงสร้างฐานระยะยาว สิ่งที่สะสมจากงานจะกลายเป็นบ้าน ทรัพย์ หรือฐานการเงินที่มั่นคงขึ้น',
    compact: 'สิ่งที่สะสมจากงานกลายเป็นฐานระยะยาว',
  );
  final next2 = prediction(
    id: 'RC11-K-NEXT-02',
    owner: 'OAS-24',
    meaning: 'next-work-direction-transfer',
    period: '63-79',
    domain: DomainScope.work,
    refs: const [
      'placement.mahabhut2537.rem0.saturday.mercury.63_79',
      'prediction.career.nextLifePeriod.strong',
    ],
    text:
        'บทบาทงานจะขยับไปทางวางระบบ ให้ทิศทาง และถ่ายทอดประสบการณ์ งานที่ใช้ความคิด การเจรจา หรือการจัดการข้อมูลจะมีน้ำหนักกว่างานที่ต้องลงแรงทุกขั้นด้วยตัวเอง',
    compact: 'วางระบบ ให้ทิศทาง และถ่ายทอดประสบการณ์',
  );
  final summary = SummaryAtom(
    id: 'RC11-K-SUMMARY-01',
    readerText:
        'ชีวิตกำลังเปลี่ยนจากรอบที่ต้องรับมือหลายอย่างพร้อมกัน ไปสู่รอบที่เลือกได้ชัดขึ้นว่าอะไรควรอยู่ต่อ เมื่อจัดภาระลงตัวแล้ว เส้นทางข้างหน้าจะนิ่งและต่อยอดเป็นฐานระยะยาวได้',
    compactText: 'จัดภาระให้ลงตัว แล้วต่อยอดสิ่งที่ควรอยู่ต่อ',
    owner: const SemanticOwner(
      id: 'SUMMARY-K-01',
      meaningKey: 'compressed-life-arc-summary',
    ),
    evidence: EvidenceTrace([
      overview.owner.id,
      current.owner.id,
      next1.owner.id,
    ]),
    period: const PeriodScope('REPORT'),
    domain: DomainScope.lifePath,
  );
  const advice = AdviceAtom(
    id: 'RC11-K-ADVICE-01',
    readerText:
        'รับงานใหม่เมื่อขอบเขตและอำนาจตัดสินใจชัด เก็บเงินส่วนหนึ่งไว้รองรับรายจ่ายก้อนสำคัญ พูดข้อตกลงกับคนใกล้ตัวให้ตรง และจัดวันพักจริงก่อนที่ความล้าจะสะสมจนกระทบงาน',
    compactText: 'รับงานเมื่อขอบเขตชัด กันเงินสำรอง และจัดวันพักจริง',
    owner: SemanticOwner(
      id: 'ADVICE-K-CURRENT-01',
      meaningKey: 'accepted-current-advice',
    ),
    evidence: EvidenceTrace(['ADVICE-K-CURRENT-01']),
    period: PeriodScope('REPORT'),
    domain: DomainScope.advice,
  );
  const disclosure = DisclosureAtom(
    id: 'RC11-K-DISCLOSURE-01',
    readerText:
        'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ',
    compactText: 'ใช้ประกอบการทบทวนและเทียบกับข้อเท็จจริง',
    owner: SemanticOwner(
      id: 'DISCLOSURE-K-01',
      meaningKey: 'belief-disclosure',
    ),
    evidence: EvidenceTrace(['DISCLOSURE-K-01']),
    period: PeriodScope('REPORT'),
    domain: DomainScope.disclosure,
    eligibility: KnownUnknownEligibility.knownOnly,
  );

  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: [
      _section(
        'overview',
        NarrativeSectionRole.overview,
        'ภาพรวมเส้นทางชีวิต',
        [overview],
      ),
      NarrativeSection(
        id: 'past',
        role: NarrativeSectionRole.past,
        title: 'คำทำนายอดีต',
        blocks: [
          NarrativeBlock(heading: 'อายุ 1–10 ปี', atoms: [past1]),
          NarrativeBlock(heading: 'อายุ 11–29 ปี', atoms: [past2, past3]),
          NarrativeBlock(heading: 'อายุ 30–41 ปี', atoms: [past4, past5]),
        ],
      ),
      _section(
        'current',
        NarrativeSectionRole.current,
        'คำทำนายปัจจุบัน — อายุ $age ปี',
        [current],
      ),
      _section('work', NarrativeSectionRole.work, 'การงาน', [work1, work2]),
      _section('finance', NarrativeSectionRole.finance, 'การเงิน', [
        finance1,
        finance2,
      ]),
      _section(
        'relationship',
        NarrativeSectionRole.relationship,
        'ความรักและความสัมพันธ์',
        [relationship1, relationship2],
      ),
      _section('health', NarrativeSectionRole.health, 'สุขภาพ', [
        health1,
        health2,
      ]),
      _section(
        'support',
        NarrativeSectionRole.support,
        'โชคลาภและแรงสนับสนุน',
        [support1, support2],
      ),
      _section(
        'horizon',
        NarrativeSectionRole.horizon,
        'คำทำนาย 12 เดือนข้างหน้า',
        [horizon1, horizon2, horizon3],
      ),
      _section(
        'next',
        NarrativeSectionRole.nextLifePeriod,
        'ช่วงชีวิตถัดไป — อายุ 63–79 ปี',
        [next1, next2],
      ),
      _section('summary', NarrativeSectionRole.summary, 'สรุปคำทำนาย', [
        summary,
      ]),
      NarrativeSection(
        id: 'advice',
        role: NarrativeSectionRole.advice,
        title: 'คำแนะนำสั้น ๆ',
        blocks: const [
          NarrativeBlock(atoms: [advice, disclosure]),
        ],
      ),
    ],
  );
}

PredictiveNarrativePlan _contextualKnownPlan(
  ThaiBetaAnalysis analysis, {
  required String contextId,
}) {
  final view = ThaiBetaNarrativeComposer.narrativeView(analysis);
  final timeline = view.lifeTimeline;
  final prediction = view.futurePrediction;
  final age =
      timeline?.currentStage.currentAge ??
      analysis.pipelineResult?.lifePeriods?.currentAge ??
      0;
  final sections = <NarrativeSection>[];
  var sequence = 0;
  PredictionAtom atom({
    required NarrativeSectionRole section,
    required String text,
    required String period,
    required DomainScope domain,
    List<String> refs = const [],
  }) {
    sequence++;
    return PredictionAtom(
      id: 'CTX-${sequence.toString().padLeft(2, '0')}',
      readerText: _directCopy(text),
      compactText: _compact(_directCopy(text)),
      owner: SemanticOwner(
        id: '$contextId.${section.name}.${sequence.toString().padLeft(2, '0')}',
        meaningKey: '${section.name}-${domain.name}-$sequence',
      ),
      evidence: EvidenceTrace(
        refs.isEmpty ? ['runtime.$contextId.${section.name}'] : refs,
      ),
      period: PeriodScope(period),
      domain: domain,
    );
  }

  final overviewText = view.hero.summary
      .split('\n\n')
      .map(_directCopy)
      .firstWhere((text) => text.isNotEmpty, orElse: () => view.hero.headline);
  sections.add(
    _section('overview', NarrativeSectionRole.overview, 'ภาพรวมเส้นทางชีวิต', [
      atom(
        section: NarrativeSectionRole.overview,
        text: overviewText,
        period: 'LIFE',
        domain: DomainScope.lifePath,
      ),
    ]),
  );

  final pastBlocks = <NarrativeBlock>[];
  for (final period
      in timeline?.periods.where((item) => item.isPast) ??
          const <ThaiMirrorLifePeriodState>[]) {
    final text = _directCopy(
      period.summary.trim().isNotEmpty ? period.summary : period.whatChanges,
    );
    if (text.isEmpty) continue;
    pastBlocks.add(
      NarrativeBlock(
        heading: 'อายุ ${period.ageLabel} ปี',
        atoms: [
          atom(
            section: NarrativeSectionRole.past,
            text: text,
            period: period.ageLabel,
            domain: DomainScope.lifePath,
            refs: [
              if (period.mahabhutKnown) period.mahabhutPositionLabel,
              period.planetLine,
            ],
          ),
        ],
      ),
    );
  }
  if (pastBlocks.isNotEmpty) {
    sections.add(
      NarrativeSection(
        id: 'past',
        role: NarrativeSectionRole.past,
        title: 'คำทำนายอดีต',
        blocks: pastBlocks,
      ),
    );
  }

  final currentPeriod = timeline?.periods
      .where((item) => item.isCurrent)
      .firstOrNull;
  final currentText = currentPeriod == null
      ? timeline?.currentStage.intro ?? ''
      : currentPeriod.summary.trim().isNotEmpty
      ? currentPeriod.summary
      : currentPeriod.whatChanges;
  if (_directCopy(currentText).isNotEmpty) {
    sections.add(
      _section(
        'current',
        NarrativeSectionRole.current,
        'คำทำนายปัจจุบัน — อายุ $age ปี',
        [
          atom(
            section: NarrativeSectionRole.current,
            text: currentText,
            period: 'age$age',
            domain: DomainScope.lifePath,
            refs: [if (currentPeriod != null) currentPeriod.planetLine],
          ),
        ],
      ),
    );
  }

  final currentWindow = prediction?.windows.firstOrNull;
  for (final binding in const [
    (
      ForecastDomain.career,
      NarrativeSectionRole.work,
      DomainScope.work,
      'การงาน',
    ),
    (
      ForecastDomain.finance,
      NarrativeSectionRole.finance,
      DomainScope.finance,
      'การเงิน',
    ),
    (
      ForecastDomain.relationship,
      NarrativeSectionRole.relationship,
      DomainScope.relationship,
      'ความรักและความสัมพันธ์',
    ),
    (
      ForecastDomain.health,
      NarrativeSectionRole.health,
      DomainScope.health,
      'สุขภาพ',
    ),
  ]) {
    final domainModel = currentWindow?.domains
        .where((item) => item.material?.domain == binding.$1)
        .firstOrNull;
    if (domainModel == null) continue;
    final material = domainModel.material;
    sections.add(
      _section(binding.$2.name, binding.$2, binding.$4, [
        atom(
          section: binding.$2,
          text: domainModel.body,
          period: 'CURRENT',
          domain: binding.$3,
          refs: _materialRefs(material),
        ),
      ]),
    );
  }
  final supportText = _directCopy(currentWindow?.topOpportunity ?? '');
  if (supportText.isNotEmpty) {
    sections.add(
      _section(
        'support',
        NarrativeSectionRole.support,
        'โชคลาภและแรงสนับสนุน',
        [
          atom(
            section: NarrativeSectionRole.support,
            text: supportText,
            period: 'CURRENT',
            domain: DomainScope.support,
          ),
        ],
      ),
    );
  }

  final horizon = prediction != null && prediction.windows.length > 1
      ? prediction.windows[1]
      : null;
  if (horizon != null) {
    final range = _longHorizonRange(analysis.asOf);
    final text =
        'ระหว่างวันที่ ${_thaiLongDate(range.$1)} ถึง ${_thaiLongDate(range.$2)} ${_directCopy(horizon.summary)}';
    sections.add(
      _section(
        'horizon',
        NarrativeSectionRole.horizon,
        'คำทำนาย 12 เดือนข้างหน้า',
        [
          atom(
            section: NarrativeSectionRole.horizon,
            text: text,
            period: '${_isoDate(range.$1)}/${_isoDate(range.$2)}',
            domain: DomainScope.lifePath,
            refs: horizon.domains
                .expand((item) => _materialRefs(item.material))
                .toSet()
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  final nextWindow = prediction != null && prediction.windows.length > 2
      ? prediction.windows[2]
      : null;
  final nextPeriod = timeline?.periods
      .where((item) => !item.isPast && !item.isCurrent)
      .firstOrNull;
  final nextText = _directCopy(
    nextWindow?.summary ?? nextPeriod?.summary ?? '',
  );
  if (nextText.isNotEmpty) {
    final label = nextPeriod?.ageLabel ?? 'ถัดไป';
    sections.add(
      _section(
        'next',
        NarrativeSectionRole.nextLifePeriod,
        'ช่วงชีวิตถัดไป — อายุ $label ปี',
        [
          atom(
            section: NarrativeSectionRole.nextLifePeriod,
            text: nextText,
            period: label,
            domain: DomainScope.foundation,
            refs: [
              if (nextPeriod != null) nextPeriod.planetLine,
              if (nextPeriod?.mahabhutKnown == true)
                nextPeriod!.mahabhutPositionLabel,
            ],
          ),
        ],
      ),
    );
  }

  final summaryText = _directCopy(view.closingMessage.message);
  if (summaryText.isNotEmpty) {
    sections.add(
      NarrativeSection(
        id: 'summary',
        role: NarrativeSectionRole.summary,
        title: 'สรุปคำทำนาย',
        blocks: [
          NarrativeBlock(
            atoms: [
              SummaryAtom(
                id: 'CTX-SUMMARY',
                readerText: summaryText,
                compactText: _compact(summaryText),
                owner: SemanticOwner(
                  id: '$contextId.summary',
                  meaningKey: 'compressed-context-summary',
                ),
                evidence: EvidenceTrace(
                  sections
                      .expand((section) => section.atoms)
                      .map((item) => item.owner.id)
                      .toList(growable: false),
                ),
                period: const PeriodScope('REPORT'),
                domain: DomainScope.lifePath,
              ),
            ],
          ),
        ],
      ),
    );
  }

  final adviceText = _directCopy(
    prediction?.detailedClosingAdvice.trim().isNotEmpty == true
        ? prediction!.detailedClosingAdvice
        : prediction?.closingAdvice ?? '',
  );
  final adviceAtoms = <NarrativeAtom>[
    if (adviceText.isNotEmpty)
      AdviceAtom(
        id: 'CTX-ADVICE',
        readerText: adviceText,
        compactText: _compact(adviceText),
        owner: SemanticOwner(
          id: '$contextId.advice',
          meaningKey: 'contextual-advice',
        ),
        evidence: const EvidenceTrace(['runtime.prediction.closingAdvice']),
        period: const PeriodScope('REPORT'),
        domain: DomainScope.advice,
      ),
    const DisclosureAtom(
      id: 'CTX-DISCLOSURE',
      readerText:
          'คำทำนายนี้เป็นมุมมองตามความเชื่อ ใช้ประกอบการทบทวนชีวิตและเทียบกับข้อเท็จจริงก่อนตัดสินใจเรื่องสำคัญ',
      compactText: 'ใช้ประกอบการทบทวนและเทียบกับข้อเท็จจริง',
      owner: SemanticOwner(
        id: 'DISCLOSURE-K-01',
        meaningKey: 'belief-disclosure',
      ),
      evidence: EvidenceTrace(['DISCLOSURE-K-01']),
      period: PeriodScope('REPORT'),
      domain: DomainScope.disclosure,
      eligibility: KnownUnknownEligibility.knownOnly,
    ),
  ];
  sections.add(
    NarrativeSection(
      id: 'advice',
      role: NarrativeSectionRole.advice,
      title: 'คำแนะนำสั้น ๆ',
      blocks: [NarrativeBlock(atoms: adviceAtoms)],
    ),
  );

  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: List.unmodifiable(sections),
  );
}

NarrativeSection _section(
  String id,
  NarrativeSectionRole role,
  String title,
  List<NarrativeAtom> atoms,
) => NarrativeSection(
  id: id,
  role: role,
  title: title,
  blocks: [NarrativeBlock(atoms: atoms)],
);

List<String> _materialRefs(ForecastMaterialFingerprint? material) => [
  if (material != null) material.serialize(),
  if (material != null && material.evidenceKey.isNotEmpty) material.evidenceKey,
];

String _directCopy(String value) {
  var text = value.trim();
  const forbidden = [
    'ลองนึกย้อน',
    'ลองทบทวน',
    'มีแนวโน้มว่าอาจ',
    'มีแนวโน้มว่า',
  ];
  for (final phrase in forbidden) {
    text = text.replaceAll(phrase, '');
  }
  text = text.replaceAll('อาจ', '');
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _compact(String value) {
  final normalized = value.trim();
  if (normalized.length <= 92) return normalized;
  final sentenceEnd = normalized.indexOf(RegExp(r'[.!?。]|[\u0E2F]'));
  if (sentenceEnd > 0 && sentenceEnd < 92) {
    return normalized.substring(0, sentenceEnd + 1);
  }
  final cut = normalized.lastIndexOf(' ', 92);
  return normalized.substring(0, cut > 48 ? cut : 92).trim();
}

String _knownSubtitle(ThaiBetaAnalysis analysis) {
  final input = analysis.input;
  final birthData = analysis.pipelineResult?.birthData;
  final profile = analysis.profile;
  final time =
      '${input.birthHour!.toString().padLeft(2, '0')}:${input.birthMinute.toString().padLeft(2, '0')}';
  final province = input.province?.trim() ?? '';
  final identity = [
    'เกิดวันที่ ${_thaiLongDate(input.birthDate)} เวลา $time น.${province.isEmpty ? '' : ' จังหวัด$province'}',
    [
      if ((input.gender ?? '').trim().isNotEmpty) 'เพศ${input.gender!.trim()}',
      if (birthData != null)
        'วันทางโหราศาสตร์เป็นวัน${_weekdayThai(birthData.thaiWeekdayNumber)}',
    ].join(' · '),
    if (profile?.lagnaKey != null && profile?.siderealAscendantDeg != null)
      'ลัคนา${_lagnaLabel(profile!.lagnaKey!)} ${_degreeWithinSign(profile.siderealAscendantDeg!)}',
  ].where((line) => line.trim().isNotEmpty).toList(growable: false);
  return identity.join('\n');
}

String _unknownSubtitle(ThaiBetaAnalysis analysis) {
  final province = analysis.input.province?.trim() ?? '';
  return 'เกิดวันที่ ${_thaiLongDate(analysis.input.birthDate)}${province.isEmpty ? '' : ' จังหวัด$province'} โดยไม่ทราบเวลาเกิด';
}

(DateTime, DateTime) _longHorizonRange(DateTime asOf) {
  final nextYear = asOf.year + 1;
  final lastDay = DateTime(nextYear, asOf.month + 1, 0).day;
  final anniversary = DateTime(
    nextYear,
    asOf.month,
    asOf.day > lastDay ? lastDay : asOf.day,
  );
  return (asOf, anniversary.subtract(const Duration(days: 1)));
}

String _thaiLongDate(DateTime date) {
  const months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}

String _isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _weekdayKey(int weekday) => switch (weekday) {
  1 => 'sunday',
  2 => 'monday',
  3 => 'tuesday',
  4 => 'wednesday',
  5 => 'thursday',
  6 => 'friday',
  7 => 'saturday',
  _ => 'unknown',
};

String _weekdayThai(int weekday) => switch (weekday) {
  1 => 'อาทิตย์',
  2 => 'จันทร์',
  3 => 'อังคาร',
  4 => 'พุธ',
  5 => 'พฤหัสบดี',
  6 => 'ศุกร์',
  7 => 'เสาร์',
  _ => 'ไม่ทราบ',
};

String _degreeWithinSign(double siderealDegree) {
  final normalized = ((siderealDegree % 30) + 30) % 30;
  var totalMinutes = (normalized * 60).round();
  if (totalMinutes >= 30 * 60) totalMinutes = (30 * 60) - 1;
  final degrees = totalMinutes ~/ 60;
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$degrees°$minutes′';
}

String _lagnaLabel(String key) => switch (key) {
  'lagna_aries' => 'ราศีเมษ',
  'lagna_taurus' => 'ราศีพฤษภ',
  'lagna_gemini' => 'ราศีเมถุน',
  'lagna_cancer' => 'ราศีกรกฎ',
  'lagna_leo' => 'ราศีสิงห์',
  'lagna_virgo' => 'ราศีกันย์',
  'lagna_libra' => 'ราศีตุลย์',
  'lagna_scorpio' => 'ราศีพิจิก',
  'lagna_sagittarius' => 'ราศีธนู',
  'lagna_capricorn' => 'ราศีมกร',
  'lagna_aquarius' => 'ราศีกุมภ์',
  'lagna_pisces' => 'ราศีมีน',
  _ => 'ราศีที่ระบบคำนวณได้',
};
