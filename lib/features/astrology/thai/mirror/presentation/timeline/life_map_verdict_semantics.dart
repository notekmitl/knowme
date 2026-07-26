/// V1.2.9 — Structured Life Map verdict semantics (presentation only).
///
/// Separates falsifiable life claims from Thai rendering so tests can assert
/// situation / domain / consequence without keyword-substring loopholes.
library;

/// Time bucket for a Life Map period narrative.
enum LifeMapVerdictTense { past, current, future }

/// Affected life domain (evidence-mapped; not engine LifeDomain enum).
enum LifeMapClaimDomain {
  workRole,
  moneySecurity,
  relationshipBond,
  familyHome,
  healthEnergy,
  identityBelonging,
  learningPath,
  dutyBurden,
  transitionRebuild,
  opportunityExpand,
}

extension LifeMapClaimDomainLabel on LifeMapClaimDomain {
  String get id => name;

  /// Short plain label for evidence/debug — never dump into prophecy tails.
  String get labelTh => switch (this) {
    LifeMapClaimDomain.workRole => 'งาน',
    LifeMapClaimDomain.moneySecurity => 'เงิน',
    LifeMapClaimDomain.relationshipBond => 'ความรัก',
    LifeMapClaimDomain.familyHome => 'บ้าน',
    LifeMapClaimDomain.healthEnergy => 'สุขภาพ',
    LifeMapClaimDomain.identityBelonging => 'คนรอบตัว',
    LifeMapClaimDomain.learningPath => 'การเรียน',
    LifeMapClaimDomain.dutyBurden => 'หน้าที่',
    LifeMapClaimDomain.transitionRebuild => 'การเริ่มใหม่',
    LifeMapClaimDomain.opportunityExpand => 'โอกาส',
  };
}

/// One falsifiable life claim assembled from resolved period evidence.
class LifeMapVerdictClaim {
  const LifeMapVerdictClaim({
    required this.tense,
    required this.situationId,
    required this.domain,
    required this.pressureId,
    required this.consequenceId,
    required this.situationTh,
    required this.pressureTh,
    required this.consequenceTh,
    required this.evidenceKeys,
  });

  final LifeMapVerdictTense tense;

  /// Stable semantic tag for the life situation (not Thai prose).
  final String situationId;
  final LifeMapClaimDomain domain;
  final String pressureId;
  final String consequenceId;

  final String situationTh;
  final String pressureTh;
  final String consequenceTh;

  /// Trace keys e.g. `facet:workPath`, `score:career`, `planet:saturn`.
  final List<String> evidenceKeys;

  String get domainId => domain.id;

  /// Fingerprint for duplicate detection across card slots.
  String get semanticKey => '$situationId|${domain.id}|$consequenceId';
}

/// Ordered story beat for Past depth (and optional Current/Future extras).
class LifeMapNarrativeBeat {
  const LifeMapNarrativeBeat({
    required this.id,
    required this.role,
    required this.textTh,
    required this.evidenceKeys,
  });

  final String id;

  /// One of: context, change, support, pressure, response, lingering.
  final String role;
  final String textTh;
  final List<String> evidenceKeys;
}

/// Structured payload accompanying rendered Thai copy.
class LifeMapVerdictSemantics {
  const LifeMapVerdictSemantics({
    required this.tense,
    required this.primary,
    this.secondary,
    this.pressure,
    this.consequence,
    this.beats = const [],
  });

  final LifeMapVerdictTense tense;
  final LifeMapVerdictClaim primary;
  final LifeMapVerdictClaim? secondary;

  /// Pressure/conflict slot (current/future harder; optional past middle).
  final LifeMapVerdictClaim? pressure;

  /// Consequence slot (advice / closing).
  final LifeMapVerdictClaim? consequence;

  /// Ordered Past story beats (4–6 when evidence supports). Empty for sparse.
  final List<LifeMapNarrativeBeat> beats;

  bool get hasSituationDomainConsequence =>
      primary.situationId.isNotEmpty &&
      primary.domainId.isNotEmpty &&
      primary.consequenceId.isNotEmpty;

  /// True when two rendered slots share the same semantic fingerprint.
  bool slotsDuplicate() {
    final keys = <String>{
      primary.semanticKey,
      if (pressure != null) pressure!.semanticKey,
      if (consequence != null) consequence!.semanticKey,
    };
    final expected =
        1 + (pressure != null ? 1 : 0) + (consequence != null ? 1 : 0);
    return keys.length < expected;
  }
}

/// Copy policy for V1.2.9 product acceptance (meta-language + hedges).
abstract final class LifeMapVerdictCopy {
  static const bannedHedges = <String>[
    'อาจ',
    'น่าจะ',
    'มีแนวโน้ม',
    'เป็นไปได้ว่า',
    'ในบางคน',
    'ถ้าคุณรู้สึกว่า',
    'ลองพิจารณาว่า',
    'ชวนให้ทบทวน',
    'คุณอาจพบว่า',
  ];

  static const bannedCoaching = <String>[
    'ลองนึกย้อน',
    'ลองทบทวน',
    'ลองสังเกต',
    'คุณอาจลองนึก',
    'ลองนึกถึง',
    'ลองพิจารณาว่า',
    'ชวนให้ทบทวน',
    'ถ้าคุณรู้สึกว่า',
  ];

  static const bannedCatastrophic = <String>[
    'เสียชีวิต',
    'หย่าร้าง',
    'อุบัติเหตุ',
    'โรคร้าย',
    'ตั้งครรภ์',
    'ถูกจับ',
    'ถูกโกง',
    'ได้เงินก้อน',
    'ย้ายประเทศ',
    'ตกงาน',
    'ได้เลื่อนตำแหน่ง',
  ];

  /// Meta / engine language banned as primary prophecy body.
  static const bannedMeta = <String>[
    'แกนของชีวิต',
    'มีน้ำหนัก',
    'บรรยากาศหลัก',
    'มากกว่าเรื่องอื่นในช่วงใกล้เคียง',
    'เด่นกว่าช่วงอื่น',
    'แรงหลัก',
    'ธีมของช่วง',
    'สะท้อนพลัง',
    'โยงกับเรื่อง',
    'ภายใต้อิทธิพล',
    'จังหวะชีวิต',
    'production evidence',
    'structured evidence',
    'Canon index',
    'affinity',
    // V1.3.0 — system / abstract report language
    'ผลกระทบหลักอยู่ที่',
    'ควบคู่กับด้าน',
    'โดยกระทบ',
    'ด้านที่ได้รับผลชัดคือ',
    'เป้าหมายเปลี่ยนไปสู่',
    'โครงสร้างชีวิต',
    'ขอบเขตงาน',
    'ขยายบทบาท',
    'โอกาสและการขยายบทบาท',
    'งานและบทบาท',
    'บ้านและครอบครัว',
    'ความมั่นคงทางใจผูกกับ',
    'บทบาทถูกจัดใหม่',
    'รับผิดชอบผลเอง',
    'แย่งกันอยู่',
    'แย่งกัน',
  ];

  /// Soft abstract stems that fail when they are the whole claim.
  static const bannedAbstractAlone = <String>[
    'การเติบโตกลายเป็น',
    'การเรียนรู้กลายเป็น',
    'การปรับตัวกลายเป็น',
    'การเปลี่ยนแปลงกลายเป็น',
    'ความมั่นคงกลายเป็น',
  ];

  static bool containsBannedHedge(String text) =>
      bannedHedges.any(text.contains);

  static bool containsBannedCoaching(String text) =>
      bannedCoaching.any(text.contains);

  static bool containsCatastrophicClaim(String text) =>
      bannedCatastrophic.any(text.contains);

  static bool containsBannedMeta(String text) => bannedMeta.any(text.contains);

  static bool containsAbstractAlone(String text) =>
      bannedAbstractAlone.any(text.contains);

  static bool violatesPrimaryBody(String text) {
    if (text.trim().isEmpty) return false;
    return containsBannedHedge(text) ||
        containsBannedCoaching(text) ||
        containsCatastrophicClaim(text) ||
        containsBannedMeta(text) ||
        containsAbstractAlone(text);
  }

  /// Product gate: prose must not collapse to abstract-only prophecy.
  static bool looksLikeAbstractOnly(String text) {
    final t = text.replaceAll(RegExp(r'\s+'), '');
    if (t.isEmpty) return true;
    const markers = [
      'ต้องตัด',
      'ต้องจัด',
      'ต้องแยก',
      'ต้องรับ',
      'ต้องสร้าง',
      'ต้องลงมือ',
      'ต้องคุย',
      'ต้องคืน',
      'ต้องเลือก',
      'ต้องหยุด',
      'ต้องเริ่ม',
      'ต้องทำตาม',
      'ต้องพึ่ง',
      'ต้องแบก',
      'ต้องลด',
      'ต้องคิด',
      'ต้องหา',
      'มีโอกาส',
      'มีคนช่วย',
      'มีทางเลือก',
      'งาน',
      'เงิน',
      'บ้าน',
      'ครอบครัว',
      'ความรัก',
      'สุขภาพ',
      'หน้าที่',
      'คนรอบตัว',
      'ผู้ใหญ่',
      'เรียน',
      'ตัดสินใจ',
      'ใกล้ชิด',
      'เปลี่ยน',
      'เริ่มใหม่',
      'ชีวิตไม่เหมือนเดิม',
      'ร่างกาย',
      'ใจ',
      'สุดแรง',
      'ถูกใช้',
      'พัก',
      'ล้า',
      'ทางเลือก',
      'โอกาส',
      'โฟกัส',
      'แย่ง',
      'อนาคต',
      'มอง',
      'ต่างจากเดิม',
      'ทักษะ',
      'ฝึก',
      'ใช้ต่อ',
      'สมดุล',
      'คุย',
      'ปล่อย',
      'ยึด',
      'เลือก',
      'ถนัด',
      'ชัดขึ้น',
    ];
    return !markers.any(t.contains);
  }
}
