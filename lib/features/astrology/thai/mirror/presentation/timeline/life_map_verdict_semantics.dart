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

  String get labelTh => switch (this) {
    LifeMapClaimDomain.workRole => 'งานและบทบาท',
    LifeMapClaimDomain.moneySecurity => 'รายได้และความมั่นคง',
    LifeMapClaimDomain.relationshipBond => 'ความสัมพันธ์ใกล้ชิด',
    LifeMapClaimDomain.familyHome => 'บ้านและครอบครัว',
    LifeMapClaimDomain.healthEnergy => 'สุขภาพและพลังงาน',
    LifeMapClaimDomain.identityBelonging => 'ตัวตนและการยอมรับ',
    LifeMapClaimDomain.learningPath => 'การเรียนและทักษะ',
    LifeMapClaimDomain.dutyBurden => 'หน้าที่และความรับผิดชอบ',
    LifeMapClaimDomain.transitionRebuild => 'การเปลี่ยนโครงสร้างชีวิต',
    LifeMapClaimDomain.opportunityExpand => 'โอกาสและการขยายบทบาท',
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

/// Structured payload accompanying rendered Thai copy.
class LifeMapVerdictSemantics {
  const LifeMapVerdictSemantics({
    required this.tense,
    required this.primary,
    this.secondary,
    this.pressure,
    this.consequence,
  });

  final LifeMapVerdictTense tense;
  final LifeMapVerdictClaim primary;
  final LifeMapVerdictClaim? secondary;

  /// Pressure/conflict slot (current/future harder; optional past middle).
  final LifeMapVerdictClaim? pressure;

  /// Consequence slot (advice / closing).
  final LifeMapVerdictClaim? consequence;

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
    // Pressure/conflict lines are concrete when they name a life tension.
    if (t.contains('แรงกดดัน') || t.contains('ความขัดแย้ง')) {
      return t.length < 24;
    }
    if (t.contains('ผลที่ตามมา') ||
        t.contains('สภาพใหม่') ||
        t.contains('ผลของช่วง') ||
        t.contains('ผลต่อชีวิต') ||
        t.contains('ผลกระทบ')) {
      return t.length < 28;
    }
    const markers = [
      'ต้องตัด',
      'ต้องจัด',
      'ต้องแยก',
      'ต้องรับ',
      'ต้องสร้าง',
      'ต้องลงมือ',
      'ต้องสื่อสาร',
      'ต้องคืน',
      'ถูกบังคับ',
      'ภาระ',
      'บทบาท',
      'รายได้',
      'รายจ่าย',
      'งาน',
      'ครอบครัว',
      'ความสัมพันธ์',
      'สุขภาพ',
      'หน้าที่',
      'เส้นทาง',
      'ตัดสินใจ',
      'สื่อสาร',
      'ระยะห่าง',
      'คาดหวัง',
      'เปรียบเทียบ',
      'ใกล้ชิด',
      'โอกาส',
      'โฟกัส',
      'บ้าน',
      'เรียน',
      'ทักษะ',
      'ขอบเขต',
      'ผลงาน',
      'เปลี่ยน',
      'โครงสร้าง',
      'ให้ความสำคัญ',
    ];
    return !markers.any(t.contains);
  }
}
