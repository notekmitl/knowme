/// Typed single-source plan for Predictive Narrative V2.
///
/// Web, infographic, dedicated PDF, browser print and text extraction project
/// from this model. The plan owns ordering, semantic ownership, evidence,
/// period/domain scope and Known/Unknown eligibility before prose reaches a
/// presentation surface.
library;

import 'package:knowme/features/astrology/thai/core/life_period/thai_remainder_runtime_metadata.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';

import '../thai_beta_analysis.dart';

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

/// Stable, auditable input to the deterministic reader-copy realizer.
///
/// A spec owns meaning before it becomes a presentation atom. Context and
/// period selectors are data, never fixture/date branches.
class PredictiveClaimSpec {
  const PredictiveClaimSpec({
    required this.claimId,
    required this.semanticOwnerId,
    required this.meaningKey,
    required this.evidenceRefs,
    required this.contextSelector,
    required this.periodSelector,
    required this.domain,
    required this.role,
    required this.readerCopy,
    required this.compactCopy,
    required this.eligibility,
  });

  factory PredictiveClaimSpec.fromAtom(
    NarrativeAtom atom, {
    required String contextSelector,
  }) => PredictiveClaimSpec(
    claimId: atom.id,
    semanticOwnerId: atom.owner.id,
    meaningKey: atom.owner.meaningKey,
    evidenceRefs: atom.evidence.refs,
    contextSelector: contextSelector,
    periodSelector: atom.period.id,
    domain: atom.domain,
    role: atom.role,
    readerCopy: atom.readerText,
    compactCopy: atom.compactText,
    eligibility: atom.eligibility,
  );

  final String claimId;
  final String semanticOwnerId;
  final String meaningKey;
  final List<String> evidenceRefs;
  final String contextSelector;
  final String periodSelector;
  final DomainScope domain;
  final NarrativeAtomRole role;
  final String readerCopy;
  final String compactCopy;
  final KnownUnknownEligibility eligibility;

  Map<String, Object?> toMap() => {
    'claimId': claimId,
    'semanticOwnerId': semanticOwnerId,
    'meaningKey': meaningKey,
    'evidenceRefs': evidenceRefs,
    'contextSelector': contextSelector,
    'periodSelector': periodSelector,
    'domain': domain.name,
    'role': role.name,
    'readerCopy': readerCopy,
    'compactCopy': compactCopy,
    'eligibility': eligibility.name,
  };
}

abstract final class PredictiveEvidenceRegistry {
  static const promotedCorpusRefs = <String>{
    'placement.mahabhut2537.rem0.saturday.saturn.0_10',
    'placement.mahabhut2537.rem0.saturday.jupiter.11_29',
    'placement.mahabhut2537.rem0.saturday.rahu.30_41',
    'placement.mahabhut2537.rem0.saturday.venus.42_62',
    'placement.mahabhut2537.rem0.saturday.mercury.63_79',
    'GRA-R0-SAT-30_41-DET-RISE',
    'PIC-R0-SAT-30_41-WORK',
    'SDC-R0-SAT-42_62-WORK',
    'SDC-R0-SAT-42_62-FLOW',
    'SDC-R0-SAT-42_62-FINANCE',
    'GRA-R0-SAT-42_62-SRI-RISE',
    'SDC-R0-SAT-42_62-SUPPORT',
    'PIC-R0-SAT-HORIZON-WORK',
    'PIC-R0-SAT-HORIZON-SUPPORT',
    'GRA-R0-SAT-63_79-MULA-RISE',
    'PIC-R0-SAT-63_79-FOUNDATION',
    'prediction.career.current.strong',
    'prediction.finance.current.strong',
    'prediction.relationship.current.strong',
    'prediction.health.current.strong',
    'prediction.career.next12Months.strong',
    'prediction.finance.next12Months.strong',
    'prediction.relationship.next12Months.strong',
    'prediction.career.nextLifePeriod.strong',
    'ADVICE-K-CURRENT-01',
    'DISCLOSURE-K-01',
    'DISCLOSURE-U-01',
    'OMISSION-U-01',
  };

  static bool resolvesPromotedCorpusRef(String ref) =>
      promotedCorpusRefs.contains(ref);
}

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

/// Converts an auditable semantic spec into its typed presentation atom.
///
/// Copy is already authored on the spec. This layer never deletes words or
/// rewrites certainty after realization.
NarrativeAtom _realizeClaimSpec(PredictiveClaimSpec spec) {
  final shared = (
    id: spec.claimId,
    readerText: spec.readerCopy,
    compactText: spec.compactCopy,
    owner: SemanticOwner(id: spec.semanticOwnerId, meaningKey: spec.meaningKey),
    evidence: EvidenceTrace(spec.evidenceRefs),
    period: PeriodScope(spec.periodSelector),
    domain: spec.domain,
  );
  return switch (spec.role) {
    NarrativeAtomRole.prediction => PredictionAtom(
      id: shared.id,
      readerText: shared.readerText,
      compactText: shared.compactText,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
      eligibility: spec.eligibility,
    ),
    NarrativeAtomRole.summary => SummaryAtom(
      id: shared.id,
      readerText: shared.readerText,
      compactText: shared.compactText,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
      eligibility: spec.eligibility,
    ),
    NarrativeAtomRole.advice => AdviceAtom(
      id: shared.id,
      readerText: shared.readerText,
      compactText: shared.compactText,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
      eligibility: spec.eligibility,
    ),
    NarrativeAtomRole.disclosure => DisclosureAtom(
      id: shared.id,
      readerText: shared.readerText,
      compactText: shared.compactText,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
      eligibility: spec.eligibility,
    ),
    NarrativeAtomRole.omission => OmissionAtom(
      id: shared.id,
      readerText: shared.readerText,
      compactText: shared.compactText,
      owner: shared.owner,
      evidence: shared.evidence,
      period: shared.period,
      domain: shared.domain,
    ),
  };
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
    this.generationPath = 'generic-v2',
    this.legacyFallbackInvocations = 0,
    this.fixtureSpecialInvocations = 0,
    this.monthlyTimelineAvailable = false,
    this.resolvedEvidenceRefs = const [],
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
    return _genericKnownPlan(analysis, contextId: contextId);
  }

  final String contextId;
  final bool isKnownTime;
  final String title;
  final String subtitle;
  final List<NarrativeSection> sections;
  final String generationPath;
  final int legacyFallbackInvocations;
  final int fixtureSpecialInvocations;
  final bool monthlyTimelineAvailable;
  final List<String> resolvedEvidenceRefs;

  List<NarrativeAtom> get atoms =>
      sections.expand((section) => section.atoms).toList(growable: false);

  List<PredictiveClaimSpec> get claimSpecs => atoms
      .map(
        (atom) =>
            PredictiveClaimSpec.fromAtom(atom, contextSelector: contextId),
      )
      .toList(growable: false);

  List<String> get unresolvedEvidenceRefs => atoms
      .expand((atom) => atom.evidence.refs)
      .where((ref) => !resolvesEvidenceRef(ref))
      .toSet()
      .toList(growable: false);

  bool resolvesEvidenceRef(String ref) => resolvedEvidenceRefs.contains(ref);

  Map<String, Object?> toMap() => {
    'contextId': contextId,
    'isKnownTime': isKnownTime,
    'generationPath': generationPath,
    'legacyFallbackInvocations': legacyFallbackInvocations,
    'fixtureSpecialInvocations': fixtureSpecialInvocations,
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
    resolvedEvidenceRefs: const ['OMISSION-U-01', 'DISCLOSURE-U-01'],
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
            ],
          ),
        ],
      ),
      NarrativeSection(
        id: 'disclaimer',
        role: NarrativeSectionRole.disclaimer,
        title: '',
        blocks: [
          NarrativeBlock(
            atoms: [
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

const _acceptedCorpusPromotionByContext = <String, String>{
  'mahabhut2537.rem0.saturday': 'candidate-0011',
};

PredictiveNarrativePlan _genericKnownPlan(
  ThaiBetaAnalysis analysis, {
  required String contextId,
}) {
  final promotedCorpus = _acceptedCorpusPromotionByContext[contextId];
  return promotedCorpus == 'candidate-0011'
      ? _realizePromotedCorpusClaims(analysis, contextId: contextId)
      : _realizeGenericContextClaimSet(analysis, contextId: contextId);
}

PredictiveNarrativePlan _realizePromotedCorpusClaims(
  ThaiBetaAnalysis analysis, {
  required String contextId,
}) {
  final age = analysis.pipelineResult!.lifePeriods!.currentAge;
  final range = _longHorizonRange(analysis.asOf);
  NarrativeAtom prediction({
    required String id,
    required String owner,
    required String meaning,
    required String text,
    required String compact,
    required String period,
    required DomainScope domain,
    required List<String> refs,
  }) => _realizeClaimSpec(
    PredictiveClaimSpec(
      claimId: id,
      semanticOwnerId: owner,
      meaningKey: meaning,
      evidenceRefs: refs,
      contextSelector: contextId,
      periodSelector: period,
      domain: domain,
      role: NarrativeAtomRole.prediction,
      readerCopy: text,
      compactCopy: compact,
      eligibility: KnownUnknownEligibility.knownOnly,
    ),
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

  final sections = <NarrativeSection>[
    _section('overview', NarrativeSectionRole.overview, 'ภาพรวมเส้นทางชีวิต', [
      overview,
    ]),
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
    _section('support', NarrativeSectionRole.support, 'โชคลาภและแรงสนับสนุน', [
      support1,
      support2,
    ]),
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
    _section('summary', NarrativeSectionRole.summary, 'สรุปคำทำนาย', [summary]),
    NarrativeSection(
      id: 'advice',
      role: NarrativeSectionRole.advice,
      title: 'คำแนะนำสั้น ๆ',
      blocks: const [
        NarrativeBlock(atoms: [advice]),
      ],
    ),
    NarrativeSection(
      id: 'disclaimer',
      role: NarrativeSectionRole.disclaimer,
      title: '',
      blocks: const [
        NarrativeBlock(atoms: [disclosure]),
      ],
    ),
  ];
  final resolvedRefs = <String>{
    ...PredictiveEvidenceRegistry.promotedCorpusRefs,
    ...sections.expand((section) => section.atoms).map((atom) => atom.owner.id),
  }.toList(growable: false);
  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: sections,
    resolvedEvidenceRefs: resolvedRefs,
  );
}

PredictiveNarrativePlan _realizeGenericContextClaimSet(
  ThaiBetaAnalysis analysis, {
  required String contextId,
}) {
  final timeline = analysis.pipelineResult?.lifePeriods;
  if (timeline == null) {
    throw StateError('Known-time narrative requires a computed life timeline.');
  }
  final prediction = analysis.consumerViewState?.futurePrediction;
  final age = timeline.currentAge;
  final sections = <NarrativeSection>[];

  NarrativeAtom claim({
    required String claimId,
    required String ownerId,
    required String meaning,
    required String text,
    required String period,
    required DomainScope domain,
    required List<String> refs,
  }) => _realizeClaimSpec(
    PredictiveClaimSpec(
      claimId: claimId,
      semanticOwnerId: ownerId,
      meaningKey: meaning,
      evidenceRefs: List.unmodifiable(refs),
      contextSelector: contextId,
      periodSelector: period,
      domain: domain,
      role: NarrativeAtomRole.prediction,
      readerCopy: text,
      compactCopy: _compact(text),
      eligibility: KnownUnknownEligibility.knownOnly,
    ),
  );

  final overviewRefs = timeline.periods
      .take(4)
      .map((period) => _placementRef(contextId, period))
      .toList(growable: false);
  sections.add(
    _section('overview', NarrativeSectionRole.overview, 'ภาพรวมเส้นทางชีวิต', [
      claim(
        claimId: 'GEN-LIFE-OVERVIEW',
        ownerId: 'LIFE-ARC-${timeline.startPlanet.name.toUpperCase()}',
        meaning: 'chronological-life-period-arc',
        text: _genericOverviewCopy(timeline),
        period: 'LIFE',
        domain: DomainScope.lifePath,
        refs: overviewRefs,
      ),
    ]),
  );

  final pastBlocks = <NarrativeBlock>[];
  for (final period in timeline.periods.where((item) => item.isPast)) {
    final range = '${period.startAge}-${period.endAge}';
    pastBlocks.add(
      NarrativeBlock(
        heading: 'อายุ ${period.startAge}–${period.endAge} ปี',
        atoms: [
          claim(
            claimId: 'GEN-PAST-${period.planet.name.toUpperCase()}-$range',
            ownerId: 'LIFE-PERIOD-${period.planet.name.toUpperCase()}-$range',
            meaning: 'past-period-${period.planet.name}',
            text: _pastPeriodCopy(period),
            period: range,
            domain: DomainScope.lifePath,
            refs: [_placementRef(contextId, period)],
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

  final current = timeline.current;
  sections.add(
    _section(
      'current',
      NarrativeSectionRole.current,
      'คำทำนายปัจจุบัน — อายุ $age ปี',
      [
        claim(
          claimId: 'GEN-CURRENT-${current.planet.name.toUpperCase()}',
          ownerId: 'LIFE-CURRENT-${current.planet.name.toUpperCase()}',
          meaning: 'current-period-${current.planet.name}',
          text: _currentPeriodCopy(current, age),
          period: '${current.startAge}-${current.endAge}|age$age',
          domain: DomainScope.lifePath,
          refs: [_placementRef(contextId, current)],
        ),
      ],
    ),
  );

  final materials =
      prediction?.windows
          .expand((window) => window.domains)
          .map((domain) => domain.material)
          .whereType<ForecastMaterialFingerprint>()
          .where(
            (material) =>
                material.evidenceAvailability ==
                    ForecastEvidenceAvailability.full &&
                material.timeDependent &&
                material.evidenceKey.isNotEmpty,
          )
          .toList(growable: false) ??
      const <ForecastMaterialFingerprint>[];

  final currentMaterials = _oneMaterialPerDomain(
    materials.where((material) => material.horizon == ForecastHorizon.current),
  );
  for (final material in currentMaterials) {
    final binding = _domainBinding(material.domain);
    sections.add(
      _section(binding.$1.name, binding.$1, binding.$3, [
        claim(
          claimId:
              'GEN-CURRENT-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          ownerId:
              'FORECAST-CURRENT-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          meaning: 'current-${material.domain.name}-${material.band.name}',
          text: _forecastReaderCopy(material),
          period: '${current.startAge}-${current.endAge}|age$age',
          domain: binding.$2,
          refs: [material.evidenceKey],
        ),
      ]),
    );
  }

  sections.add(
    _section('support', NarrativeSectionRole.support, 'โชคลาภและแรงสนับสนุน', [
      claim(
        claimId: 'GEN-SUPPORT-${current.planet.name.toUpperCase()}',
        ownerId: 'LIFE-SUPPORT-${current.planet.name.toUpperCase()}',
        meaning: 'support-from-current-life-period',
        text: _supportCopy(current.planet),
        period: '${current.startAge}-${current.endAge}|age$age',
        domain: DomainScope.support,
        refs: [_placementRef(contextId, current)],
      ),
    ]),
  );

  final horizonMaterials = _oneMaterialPerDomain(
    materials.where(
      (material) => material.horizon == ForecastHorizon.next12Months,
    ),
  );
  if (horizonMaterials.isNotEmpty) {
    final range = _longHorizonRange(analysis.asOf);
    final atoms = <NarrativeAtom>[];
    for (var index = 0; index < horizonMaterials.length; index++) {
      final material = horizonMaterials[index];
      final lead = index == 0
          ? 'ระหว่างวันที่ ${_thaiLongDate(range.$1)} ถึง ${_thaiLongDate(range.$2)} '
          : 'ในช่วงเดียวกัน ';
      atoms.add(
        claim(
          claimId:
              'GEN-HORIZON-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          ownerId:
              'FORECAST-NEXT12MONTHS-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          meaning: 'horizon-${material.domain.name}-${material.band.name}',
          text:
              '$lead${_forecastReaderCopy(material, includeHorizonLead: false)}',
          period: '${_isoDate(range.$1)}/${_isoDate(range.$2)}',
          domain: _domainBinding(material.domain).$2,
          refs: [material.evidenceKey],
        ),
      );
    }
    sections.add(
      _section(
        'horizon',
        NarrativeSectionRole.horizon,
        'คำทำนาย 12 เดือนข้างหน้า',
        atoms,
      ),
    );
  }

  final next = timeline.next;
  if (next != null) {
    final nextAtoms = <NarrativeAtom>[
      claim(
        claimId: 'GEN-NEXT-${next.planet.name.toUpperCase()}',
        ownerId: 'LIFE-NEXT-${next.planet.name.toUpperCase()}',
        meaning: 'next-life-period-${next.planet.name}',
        text: _nextPeriodCopy(next),
        period: '${next.startAge}-${next.endAge}',
        domain: DomainScope.foundation,
        refs: [_placementRef(contextId, next)],
      ),
    ];
    for (final material in _oneMaterialPerDomain(
      materials.where((item) => item.horizon == ForecastHorizon.nextLifePeriod),
    )) {
      nextAtoms.add(
        claim(
          claimId:
              'GEN-NEXT-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          ownerId:
              'FORECAST-NEXTLIFEPERIOD-${material.domain.name.toUpperCase()}-${material.band.name.toUpperCase()}',
          meaning: 'next-life-${material.domain.name}-${material.band.name}',
          text: _forecastReaderCopy(material),
          period: '${next.startAge}-${next.endAge}',
          domain: _domainBinding(material.domain).$2,
          refs: [material.evidenceKey],
        ),
      );
    }
    sections.add(
      _section(
        'next',
        NarrativeSectionRole.nextLifePeriod,
        'ช่วงชีวิตถัดไป — อายุ ${next.startAge}–${next.endAge} ปี',
        nextAtoms,
      ),
    );
  }

  final predictiveOwners = sections
      .expand((section) => section.atoms)
      .map((atom) => atom.owner.id)
      .toList(growable: false);
  final primaryDomain = currentMaterials.isEmpty
      ? ForecastDomain.career
      : currentMaterials.first.domain;
  final summaryText = _genericSummaryCopy(
    current: current,
    primaryDomain: primaryDomain,
  );
  sections.add(
    _section('summary', NarrativeSectionRole.summary, 'สรุปคำทำนาย', [
      SummaryAtom(
        id: 'GEN-SUMMARY-${current.planet.name.toUpperCase()}',
        readerText: summaryText,
        compactText: _compact(summaryText),
        owner: SemanticOwner(
          id: 'SUMMARY-${current.planet.name.toUpperCase()}-${primaryDomain.name.toUpperCase()}',
          meaningKey: 'compressed-generic-summary',
        ),
        evidence: EvidenceTrace(predictiveOwners),
        period: const PeriodScope('REPORT'),
        domain: DomainScope.lifePath,
      ),
    ]),
  );

  final adviceText = _genericAdviceCopy(primaryDomain);
  sections.add(
    _section('advice', NarrativeSectionRole.advice, 'คำแนะนำสั้น ๆ', [
      AdviceAtom(
        id: 'GEN-ADVICE-${primaryDomain.name.toUpperCase()}',
        readerText: adviceText,
        compactText: _compact(adviceText),
        owner: SemanticOwner(
          id: 'ADVICE-${primaryDomain.name.toUpperCase()}-BOUNDARY',
          meaningKey: 'generic-decision-boundary',
        ),
        evidence: EvidenceTrace([
          if (currentMaterials.isNotEmpty)
            currentMaterials.first.evidenceKey
          else
            _placementRef(contextId, current),
        ]),
        period: const PeriodScope('REPORT'),
        domain: DomainScope.advice,
      ),
    ]),
  );
  sections.add(
    const NarrativeSection(
      id: 'disclaimer',
      role: NarrativeSectionRole.disclaimer,
      title: '',
      blocks: [
        NarrativeBlock(
          atoms: [
            DisclosureAtom(
              id: 'GEN-DISCLOSURE-KNOWN',
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
          ],
        ),
      ],
    ),
  );

  final resolvedRefs = <String>{
    for (final period in timeline.periods) _placementRef(contextId, period),
    for (final material in materials) material.evidenceKey,
    for (final atom in sections.expand((section) => section.atoms))
      atom.owner.id,
    'DISCLOSURE-K-01',
  }.toList(growable: false);
  return PredictiveNarrativePlan(
    contextId: contextId,
    isKnownTime: true,
    title: 'คำทำนายดวงชะตา',
    subtitle: _knownSubtitle(analysis),
    sections: List.unmodifiable(sections),
    resolvedEvidenceRefs: resolvedRefs,
  );
}

List<ForecastMaterialFingerprint> _oneMaterialPerDomain(
  Iterable<ForecastMaterialFingerprint> materials,
) {
  final byDomain = <ForecastDomain, ForecastMaterialFingerprint>{};
  for (final material in materials) {
    byDomain.putIfAbsent(material.domain, () => material);
  }
  return [for (final domain in ForecastDomain.values) ?byDomain[domain]];
}

(NarrativeSectionRole, DomainScope, String) _domainBinding(
  ForecastDomain domain,
) => switch (domain) {
  ForecastDomain.career => (
    NarrativeSectionRole.work,
    DomainScope.work,
    'การงาน',
  ),
  ForecastDomain.finance => (
    NarrativeSectionRole.finance,
    DomainScope.finance,
    'การเงิน',
  ),
  ForecastDomain.relationship => (
    NarrativeSectionRole.relationship,
    DomainScope.relationship,
    'ความรักและความสัมพันธ์',
  ),
  ForecastDomain.health => (
    NarrativeSectionRole.health,
    DomainScope.health,
    'สุขภาพ',
  ),
};

String _placementRef(String contextId, PeriodState period) =>
    'placement.$contextId.${period.planet.name}.${period.startAge}_${period.endAge}';

String _genericOverviewCopy(LifeTimeline timeline) {
  final current = timeline.current;
  final next = timeline.next;
  final currentData = LifePlanets.of(current.planet);
  final nextText = next == null
      ? ''
      : ' หลังอายุ ${next.startAge} บทบาทของ${LifePlanets.of(next.planet).keyword}จะเข้ามาแทนที่';
  return 'ชีวิตเดินผ่านช่วงที่มีหน้าที่ต่างกันอย่างชัดเจน '
      'ช่วงอายุ ${current.startAge}–${current.endAge} '
      '${currentData.keyword}เป็นเรื่องนำของชีวิต$nextText';
}

String _pastPeriodCopy(PeriodState period) {
  final label = '${period.startAge}–${period.endAge}';
  return switch (period.planet) {
    LifePlanet.saturn =>
      'ช่วงอายุ $label ชีวิตอยู่ใต้เงื่อนไขของหน้าที่และกติกาที่ชัด หลายเรื่องเดินหน้าได้เมื่อรับผิดชอบสิ่งจำเป็นให้ครบก่อน',
    LifePlanet.jupiter =>
      'ช่วงอายุ $label การเรียน งาน และสังคมเปิดกว้างขึ้น คนที่มีประสบการณ์กว่าพาให้เห็นโอกาสและทางเลือกใหม่',
    LifePlanet.rahu =>
      'ช่วงอายุ $label งานหรือข้อตกลงสำคัญเปลี่ยนรูปแบบ ทางเดิมที่ไปต่อไม่ได้จบลง และทางใหม่เริ่มชัดจากการลงมือจริง',
    LifePlanet.venus =>
      'ช่วงอายุ $label ผลจากงานและความสัมพันธ์ที่สั่งสมไว้เริ่มชัด เรื่องที่ทำต่อเนื่องให้ผลตอบแทนมากกว่าสิ่งที่เพิ่งเริ่ม',
    LifePlanet.sun =>
      'ช่วงอายุ $label ผลงานและบทบาทของคุณถูกมองเห็นชัดขึ้น หน้าที่ที่ต้องตัดสินใจแทนคนอื่นเข้ามาพร้อมการยอมรับ',
    LifePlanet.moon =>
      'ช่วงอายุ $label เรื่องบ้าน ครอบครัว และความมั่นคงทางใจเป็นแกนของการตัดสินใจ ความสัมพันธ์ใกล้ตัวเปลี่ยนตามภาระที่รับไว้',
    LifePlanet.mars =>
      'ช่วงอายุ $label ชีวิตเดินเร็วขึ้นจากการตัดสินใจและลงมือ เรื่องที่ค้างถูกผลักให้จบพร้อมกับการเริ่มทางใหม่',
    LifePlanet.mercury =>
      'ช่วงอายุ $label การเรียนรู้ การสื่อสาร และการเชื่อมคนหลายฝ่ายเปิดทางให้งานและรายได้รูปแบบใหม่',
  };
}

String _currentPeriodCopy(
  PeriodState period,
  int age,
) => switch (period.planet) {
  LifePlanet.saturn =>
    'อายุ $age อยู่ในช่วงจัดฐานชีวิตให้มั่นคง ภาระที่รับไว้ต้องมีขอบเขตชัด และเรื่องที่ไม่สร้างผลต่อเนื่องจะถูกตัดออกก่อนอายุ ${period.endAge}',
  LifePlanet.jupiter =>
    'อายุ $age อยู่ในช่วงขยายความรู้ งาน และเครือข่าย โอกาสใหม่เข้ามาผ่านคนที่เห็นผลงานและพร้อมเปิดทางให้',
  LifePlanet.rahu =>
    'อายุ $age อยู่ในช่วงเปลี่ยนทิศ เรื่องที่ค้างต้องได้ข้อสรุป งานหรือข้อตกลงที่ไปต่อจะเปลี่ยนรูปแบบให้ชัดกว่าเดิม',
  LifePlanet.venus =>
    'อายุ $age อยู่ในช่วงเก็บผลจากสิ่งที่ทำต่อเนื่อง งาน เงิน และความสัมพันธ์จะชัดขึ้นตามคุณภาพของข้อตกลงที่รักษาไว้',
  LifePlanet.sun =>
    'อายุ $age เป็นช่วงที่ผลงานและความรับผิดชอบถูกมองเห็น การตัดสินใจที่ชัดจะกำหนดบทบาทหลักของรอบนี้',
  LifePlanet.moon =>
    'อายุ $age เป็นช่วงจัดบ้าน ความสัมพันธ์ และเวลาพักให้สมดุล เรื่องใกล้ตัวที่ยังค้างจะถูกนำมาจัดการให้จบ',
  LifePlanet.mars =>
    'อายุ $age เป็นช่วงลงมือและตัดสินใจ งานที่หยุดนิ่งจะถูกผลักให้เดินหน้า พร้อมกับการตัดภาระที่ขัดกับเป้าหมายหลัก',
  LifePlanet.mercury =>
    'อายุ $age เป็นช่วงใช้ความคิด การสื่อสาร และข้อมูลสร้างทางเลือกใหม่ งานที่เชื่อมหลายฝ่ายจะมีบทบาทมากขึ้น',
};

String _forecastReaderCopy(
  ForecastMaterialFingerprint material, {
  bool includeHorizonLead = true,
}) {
  final horizon = includeHorizonLead
      ? switch (material.horizon) {
          ForecastHorizon.current => 'ช่วงนี้ ',
          ForecastHorizon.next12Months => 'ในรอบ 12 เดือนนี้ ',
          ForecastHorizon.nextLifePeriod => 'ในช่วงชีวิตถัดไป ',
        }
      : '';
  final strength = switch (material.band) {
    ForecastBand.strong => 'ขยับชัดและให้ผลจากสิ่งที่ทำต่อเนื่อง',
    ForecastBand.active => 'เดินหน้าทีละขั้นจากข้อตกลงที่ทำได้จริง',
    ForecastBand.quiet => 'ชะลอเพื่อจัดฐานเดิมและปิดเรื่องที่กินแรง',
  };
  final body = switch (material.domain) {
    ForecastDomain.career =>
      'งาน$strength บทบาทหลักชัดขึ้นเมื่อผลงานส่งมอบได้ตามขอบเขต',
    ForecastDomain.finance =>
      'การเงิน$strength ฐานเงินนิ่งขึ้นเมื่อกันรายการจำเป็นก่อนรับภาระเพิ่ม',
    ForecastDomain.relationship =>
      'ความสัมพันธ์$strength ระยะของแต่ละคนชัดจากการทำตามข้อตกลง',
    ForecastDomain.health =>
      'การพักและการฟื้นตัว$strength กำลังกลับมาเมื่อเวลานอนทำได้ต่อเนื่อง',
  };
  return '$horizon$body';
}

String _supportCopy(LifePlanet planet) => switch (planet) {
  LifePlanet.saturn =>
    'แรงสนับสนุนมาจากคนที่ไว้ใจความรับผิดชอบและเห็นว่าคุณทำเรื่องยากได้ต่อเนื่อง',
  LifePlanet.jupiter =>
    'แรงสนับสนุนมาจากครู ผู้ใหญ่ และคนที่พร้อมแบ่งความรู้หรือเปิดทางให้โอกาสใหม่',
  LifePlanet.rahu =>
    'แรงสนับสนุนมาจากคนที่เคยผ่านการเปลี่ยนแปลงและช่วยแก้เรื่องติดขัดได้เร็ว',
  LifePlanet.venus =>
    'แรงสนับสนุนมาจากคนที่เคยเห็นผลงานและรักษาความสัมพันธ์กับคุณมาอย่างต่อเนื่อง',
  LifePlanet.sun =>
    'แรงสนับสนุนมาจากคนที่เห็นผลงานชัดและพร้อมมอบบทบาทให้ตัดสินใจ',
  LifePlanet.moon =>
    'แรงสนับสนุนมาจากครอบครัว คนใกล้ตัว และเครือข่ายที่ดูแลกันในชีวิตประจำวัน',
  LifePlanet.mars =>
    'แรงสนับสนุนมาจากคนที่พร้อมลงมือและช่วยพาเรื่องค้างให้เดินหน้า',
  LifePlanet.mercury =>
    'แรงสนับสนุนมาจากคนที่แลกเปลี่ยนข้อมูล เชื่อมเครือข่าย และช่วยให้การเจรจาเดินต่อ',
};

String _nextPeriodCopy(PeriodState period) {
  final data = LifePlanets.of(period.planet);
  final phaseEssence = switch (period.planet) {
    LifePlanet.sun => 'ช่วงสั้น ๆ ที่ผลงานและบทบาทที่รับผิดชอบถูกมองเห็นชัดเจน',
    _ => data.phaseEssence,
  };
  return 'เมื่ออายุ ${period.startAge} ปี ชีวิตเข้าสู่${data.phaseName} '
      '$phaseEssence บทบาทเดิมที่ไปต่อจะถูกจัดให้เป็นฐานของช่วงอายุ '
      '${period.startAge}–${period.endAge}';
}

String _genericSummaryCopy({
  required PeriodState current,
  required ForecastDomain primaryDomain,
}) =>
    'ช่วงปัจจุบันให้${LifePlanets.of(current.planet).keyword}เป็นแกน '
    '${_domainLabel(primaryDomain)}เป็นเรื่องที่ต้องจัดให้ชัดก่อนขยายแผน '
    'เมื่อภาระหลักลงตัว เส้นทางถัดไปจะต่อยอดจากสิ่งที่ทำได้จริง';

String _genericAdviceCopy(
  ForecastDomain primaryDomain,
) => switch (primaryDomain) {
  ForecastDomain.career =>
    'รับงานใหม่เมื่อขอบเขต ผลลัพธ์ และอำนาจตัดสินใจชัด ปิดงานค้างก่อนเพิ่มบทบาท และกันเวลาพักไว้ในแผน',
  ForecastDomain.finance =>
    'กันเงินสำหรับรายการจำเป็นก่อนรับข้อผูกพันใหม่ ตรวจยอดพร้อมใช้เป็นระยะ และขยายแผนเมื่อฐานเงินรองรับ',
  ForecastDomain.relationship =>
    'พูดข้อตกลงเรื่องเวลา หน้าที่ และพื้นที่ส่วนตัวให้ตรง ใช้พฤติกรรมที่ทำต่อเนื่องเป็นหลักก่อนเพิ่มข้อผูกพัน',
  ForecastDomain.health =>
    'จัดวันพักและเวลานอนให้ทำได้จริง ลดภาระที่เข้ามาพร้อมกัน และเพิ่มงานเมื่อร่างกายฟื้นได้ตามปกติ',
};

String _domainLabel(ForecastDomain domain) => switch (domain) {
  ForecastDomain.career => 'งาน',
  ForecastDomain.finance => 'การเงิน',
  ForecastDomain.relationship => 'ความสัมพันธ์',
  ForecastDomain.health => 'การพักและการฟื้นตัว',
};

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
