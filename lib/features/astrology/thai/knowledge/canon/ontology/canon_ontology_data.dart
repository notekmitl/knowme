/// Canon Ontology V3 — the standard (seeded) ontology.
///
/// Controlled **vocabulary** only: stable identifiers, aliases (incl. Thai and
/// Sanskrit), the relationship registry and the domain taxonomy. This is NOT
/// astrological knowledge — no claims, meanings, predictions or interpretations
/// live here. The relationship set is a superset of every V2 `AtomicRelation`
/// wire, so the knowledge graph can only use registered relationships.
///
/// Pure Dart; no Flutter/engine/runtime/matrix imports.
library;

import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_entity.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canon_ontology_attribute_values.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/canonical_ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology_category.dart';

abstract final class CanonOntologyData {
  /// The registered relationship vocabulary. The only legal graph relationships.
  /// Superset of the V2 `AtomicRelation` wires + the V3 additions.
  static const List<String> relationships = [
    'owns',
    'supports',
    'opposes',
    'requires',
    'belongs_to',
    'located_in',
    'governs',
    'influences',
    'produces',
    'strengthens',
    'weakens',
    'exception_to',
    'relates_to',
  ];

  static const List<CanonicalEntity> planets = [
    CanonicalEntity(
      id: 'planet.sun',
      canonicalName: 'Sun',
      category: OntologyCategory.planet,
      aliases: ['Surya', 'อาทิตย์', 'ดาวอาทิตย์'],
    ),
    CanonicalEntity(
      id: 'planet.moon',
      canonicalName: 'Moon',
      category: OntologyCategory.planet,
      aliases: ['Chandra', 'จันทร์', 'ดาวจันทร์'],
    ),
    CanonicalEntity(
      id: 'planet.mars',
      canonicalName: 'Mars',
      category: OntologyCategory.planet,
      aliases: ['Mangala', 'อังคาร', 'ดาวอังคาร'],
    ),
    CanonicalEntity(
      id: 'planet.mercury',
      canonicalName: 'Mercury',
      category: OntologyCategory.planet,
      aliases: ['Budha', 'พุธ', 'ดาวพุธ'],
    ),
    CanonicalEntity(
      id: 'planet.jupiter',
      canonicalName: 'Jupiter',
      category: OntologyCategory.planet,
      aliases: ['Guru', 'Brihaspati', 'พฤหัส', 'พฤหัสบดี', 'ดาวพฤหัส'],
    ),
    CanonicalEntity(
      id: 'planet.venus',
      canonicalName: 'Venus',
      category: OntologyCategory.planet,
      aliases: ['Shukra', 'ศุกร์', 'ดาวศุกร์'],
    ),
    CanonicalEntity(
      id: 'planet.saturn',
      canonicalName: 'Saturn',
      category: OntologyCategory.planet,
      aliases: ['Shani', 'เสาร์', 'ดาวเสาร์'],
    ),
    CanonicalEntity(
      id: 'planet.rahu',
      canonicalName: 'Rahu',
      category: OntologyCategory.planet,
      aliases: ['ราหู'],
    ),
    CanonicalEntity(
      id: 'planet.ketu',
      canonicalName: 'Ketu',
      category: OntologyCategory.planet,
      aliases: ['เกตุ'],
    ),
  ];

  /// The twelve houses (bhāva). Structural enumeration only — the *meaning* of
  /// each house is Canon knowledge and is NOT encoded here (it comes from the
  /// book via the extraction workspace). Labels are positional, not claims.
  static List<CanonicalEntity> houses() => [
        for (var n = 1; n <= 12; n++)
          CanonicalEntity(
            id: 'house.$n',
            canonicalName: 'House $n',
            category: OntologyCategory.house,
            aliases: ['Bhava $n', 'ภพที่ $n', 'เรือนที่ $n'],
          ),
      ];

  static const List<CanonicalEntity> elements = [
    CanonicalEntity(
      id: 'element.fire',
      canonicalName: 'Fire',
      category: OntologyCategory.element,
      aliases: ['ไฟ', 'ธาตุไฟ'],
    ),
    CanonicalEntity(
      id: 'element.earth',
      canonicalName: 'Earth',
      category: OntologyCategory.element,
      aliases: ['ดิน', 'ธาตุดิน'],
    ),
    CanonicalEntity(
      id: 'element.air',
      canonicalName: 'Air',
      category: OntologyCategory.element,
      aliases: ['Wind', 'ลม', 'ธาตุลม'],
    ),
    CanonicalEntity(
      id: 'element.water',
      canonicalName: 'Water',
      category: OntologyCategory.element,
      aliases: ['น้ำ', 'ธาตุน้ำ'],
    ),
  ];

  /// **Mahabhut Named Positions** (D-067 Ontology Expansion).
  ///
  /// The book `หลักมหาภูต` (ส. หยกฟ้า) expresses planetary placement through its
  /// own system of *named positions* (`เรือน…`) rather than the numbered bhāva.
  /// **Creation criterion: required for Canon representation** — these positions
  /// are the placement vocabulary the Canon text uses, so its statements cannot be
  /// represented without them. OCR frequency is *supporting evidence for
  /// prioritization only, never the reason an entity exists* (for reference these
  /// seven also recur often: `มรณะ` 74× · `ภังคะ` 71× · `ขุมทรัพย์` 58× · `ธงชัย`
  /// 55× · `อธิบดี` 51× · `ราชา` 50× · `ปูติ` 48×).
  ///
  /// Controlled **vocabulary only**: a stable id + the Thai surface forms that
  /// appear in the text (`เรือน…` and the bare term). The `canonicalName` is a
  /// phonetic romanisation of the Thai term — **not a translation** — so no
  /// meaning, interpretation, strength polarity, bhāva-number mapping or
  /// relationship is implied here. What each position *means* is Canon knowledge
  /// produced from the book through the extraction pipeline, never encoded here.
  static const List<CanonicalEntity> mahabhutPositions = [
    CanonicalEntity(
      id: 'mahabhutPosition.thongchai',
      canonicalName: 'Thongchai',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['ธงชัย', 'เรือนธงชัย'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.athibodi',
      canonicalName: 'Athibodi',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['อธิบดี', 'เรือนอธิบดี'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.khumsap',
      canonicalName: 'Khumsap',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['ขุมทรัพย์', 'เรือนขุมทรัพย์'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.racha',
      canonicalName: 'Racha',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['ราชา', 'เรือนราชา'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.puti',
      canonicalName: 'Puti',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['ปูติ', 'เรือนปูติ'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.marana',
      canonicalName: 'Marana',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['มรณะ', 'เรือนมรณะ'],
    ),
    CanonicalEntity(
      id: 'mahabhutPosition.phangkha',
      canonicalName: 'Phangkha',
      category: OntologyCategory.mahabhutPosition,
      aliases: ['ภังคะ', 'เรือนภังคะ'],
    ),
  ];

  /// Mahabhut **ทักษา** dignity roles (D-074 Phase C Ontology Expansion).
  ///
  /// The book assigns planets to these named roles per birth-day rotation and
  /// per archetype-chart life-period readings. **Vocabulary only** — no
  /// meanings, polarity, or planet links encoded here.
  static const List<CanonicalEntity> taksaRoles = [
    CanonicalEntity(
      id: 'taksaRole.boriwan',
      canonicalName: 'Boriwan',
      category: OntologyCategory.taksaRole,
      aliases: ['บริวาร'],
    ),
    CanonicalEntity(
      id: 'taksaRole.ayu',
      canonicalName: 'Ayu',
      category: OntologyCategory.taksaRole,
      aliases: ['อายุ', 'อาย'],
    ),
    CanonicalEntity(
      id: 'taksaRole.det',
      canonicalName: 'Det',
      category: OntologyCategory.taksaRole,
      aliases: ['เดช'],
    ),
    CanonicalEntity(
      id: 'taksaRole.sri',
      canonicalName: 'Sri',
      category: OntologyCategory.taksaRole,
      aliases: ['ศรี'],
    ),
    CanonicalEntity(
      id: 'taksaRole.mula',
      canonicalName: 'Mula',
      category: OntologyCategory.taksaRole,
      aliases: ['มูละ'],
    ),
    CanonicalEntity(
      id: 'taksaRole.utsaha',
      canonicalName: 'Utsaha',
      category: OntologyCategory.taksaRole,
      aliases: ['อุตสาหะ', 'อุสสาหะ'],
    ),
    CanonicalEntity(
      id: 'taksaRole.montri',
      canonicalName: 'Montri',
      category: OntologyCategory.taksaRole,
      aliases: ['มนตรี'],
    ),
    CanonicalEntity(
      id: 'taksaRole.kalakini',
      canonicalName: 'Kalakini',
      category: OntologyCategory.taksaRole,
      aliases: ['กาฬกิณี'],
    ),
  ];

  /// Planet **เสวยอายุ** dasha durations stated on p18 (D-075 Phase D).
  /// Vocabulary only — verbatim Thai aliases from recoverable OCR lines.
  static const List<CanonicalEntity> agePeriods = [
    CanonicalEntity(
      id: 'agePeriod.dasha5y',
      canonicalName: 'Dasha 5y',
      category: OntologyCategory.agePeriod,
      aliases: ['เสวยอายุ ๕ ปี'],
    ),
    CanonicalEntity(
      id: 'agePeriod.dasha10y',
      canonicalName: 'Dasha 10y',
      category: OntologyCategory.agePeriod,
      aliases: ['เสวยอายุ ๑๐ ปี', 'เสวยอาย ๑๐ ปี'],
    ),
    CanonicalEntity(
      id: 'agePeriod.dasha12y',
      canonicalName: 'Dasha 12y',
      category: OntologyCategory.agePeriod,
      aliases: ['เสวยอายุ ๑๒ ปี', 'เสวยอาย ๑๒ ปี'],
    ),
    CanonicalEntity(
      id: 'agePeriod.dasha15y',
      canonicalName: 'Dasha 15y',
      category: OntologyCategory.agePeriod,
      aliases: ['เสวยอายุ ๑๕ ปี'],
    ),
  ];

  /// Rise/fall period classification (D-075 Phase D).
  static const List<CanonicalEntity> periodStatuses = [
    CanonicalEntity(
      id: 'periodStatus.duengKhuen',
      canonicalName: 'Dueng Khuen',
      category: OntologyCategory.periodStatus,
      aliases: ['ดวงขึ้น'],
    ),
    CanonicalEntity(
      id: 'periodStatus.duengTok',
      canonicalName: 'Dueng Tok',
      category: OntologyCategory.periodStatus,
      aliases: ['ดวงตก'],
    ),
  ];

  /// Prediction effect tokens from pp.40–41 (D-076 Phase E). Vocabulary only.
  static const List<CanonicalEntity> predictionEffects = [
    CanonicalEntity(
      id: 'predictionEffect.weak',
      canonicalName: 'Weak',
      category: OntologyCategory.predictionEffect,
      aliases: ['อ่อนแอ', 'อ่อนกำลัง'],
    ),
    CanonicalEntity(
      id: 'predictionEffect.strong',
      canonicalName: 'Strong',
      category: OntologyCategory.predictionEffect,
      aliases: ['เข้มแข็ง'],
    ),
  ];

  /// Remedy procedure token (D-077 Phase F). Vocabulary only.
  static const List<CanonicalEntity> remedies = [
    CanonicalEntity(
      id: 'remedy.sadoeKhroh',
      canonicalName: 'Sadoe Khroh',
      category: OntologyCategory.remedy,
      aliases: ['สะเดาะเคราะห์', 'แก้ดวง', 'แก้ตวง'],
    ),
  ];

  /// Remedy material / object tokens (D-077 Phase F). Vocabulary only.
  static const List<CanonicalEntity> remedyItems = [
    CanonicalEntity(
      id: 'remedyItem.buddhaDayImage',
      canonicalName: 'Buddha day image',
      category: OntologyCategory.remedyItem,
      aliases: ['พระประจำวัน', 'พระประธานประจำวัน', 'พระเจดีย์ประจำวัน'],
    ),
    CanonicalEntity(
      id: 'remedyItem.vase3',
      canonicalName: 'Three vases',
      category: OntologyCategory.remedyItem,
      aliases: ['แจกัน ๓ ลูก', 'แจกัน ๓'],
    ),
    CanonicalEntity(
      id: 'remedyItem.flowersPerVase',
      canonicalName: 'Flowers per vase',
      category: OntologyCategory.remedyItem,
      aliases: [
        'ดอกไม้เกินอายุหนึ่งดอก/แจกัน',
        'ดอกไม้เกินอายุดอกหนึ่ง',
      ],
    ),
    CanonicalEntity(
      id: 'remedyItem.incensePerAge',
      canonicalName: 'Incense per age',
      category: OntologyCategory.remedyItem,
      aliases: [
        'เทียนขี้ผึ้งจำนวนเกินอายุหนึ่งเล่ม',
        'เทียนขี้ผึ้งจำนวนเท่าอายุ',
      ],
    ),
    CanonicalEntity(
      id: 'remedyItem.jasmineRose',
      canonicalName: 'Jasmine and rose',
      category: OntologyCategory.remedyItem,
      aliases: ['ดอกมะลิซ้อนและดอกกุหลาบ', 'ดอกมะลิ', 'ดอกกุหลาบ'],
    ),
    CanonicalEntity(
      id: 'remedyItem.tropicaShoot',
      canonicalName: 'Tropica shoot',
      category: OntologyCategory.remedyItem,
      aliases: ['ยอดหน้าว', 'ยอดหว้า', 'ยอดมะพร้าว'],
    ),
  ];

  /// Remedy worship target / symbol tokens (D-077 Phase F). Vocabulary only.
  static const List<CanonicalEntity> ritualTargets = [
    CanonicalEntity(
      id: 'ritualTarget.garuda',
      canonicalName: 'Garuda symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['พญาครุฑ'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.tiger',
      canonicalName: 'Tiger symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['เสือ'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.lion',
      canonicalName: 'Lion symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['สิงห์'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.elephant',
      canonicalName: 'Elephant symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['ช้างฉัทรันต์', 'ช้างฉัททันต์'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.rat',
      canonicalName: 'Rat symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['หนู'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.ratPhao',
      canonicalName: 'Rat phao symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['หนูตะเภา'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.naga',
      canonicalName: 'Naga symbol',
      category: OntologyCategory.ritualTarget,
      aliases: ['พญานาค'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaThawaiNet',
      canonicalName: 'Buddha Thawai Net',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางถวายเนตร'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaHamSamut',
      canonicalName: 'Buddha Ham Samut',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางห้ามสมุทร'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaUmbat',
      canonicalName: 'Buddha Umbat',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางอัมบาตร'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaSamathi',
      canonicalName: 'Buddha Samathi',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางสมาธิ', 'พระปางสมาชธิ'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaRampooeng',
      canonicalName: 'Buddha Rampooeng',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางรำพึง', 'พระปางรําพึง'],
    ),
    CanonicalEntity(
      id: 'ritualTarget.buddhaNakProk',
      canonicalName: 'Buddha Nak Prok',
      category: OntologyCategory.ritualTarget,
      aliases: ['พระปางนาคปรก'],
    ),
  ];

  /// Hierarchical life domains. Root `domain.life`; the rest are its children.
  static const List<CanonicalEntity> domains = [
    CanonicalEntity(
      id: 'domain.life',
      canonicalName: 'Life',
      category: OntologyCategory.domain,
    ),
    CanonicalEntity(
      id: 'domain.career',
      canonicalName: 'Career',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Work', 'Profession', 'การงาน', 'อาชีพ'],
    ),
    CanonicalEntity(
      id: 'domain.finance',
      canonicalName: 'Finance',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Money', 'Wealth', 'การเงิน', 'ทรัพย์'],
    ),
    CanonicalEntity(
      id: 'domain.relationship',
      canonicalName: 'Relationship',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Love', 'Partnership', 'ความรัก', 'คู่ครอง'],
    ),
    CanonicalEntity(
      id: 'domain.health',
      canonicalName: 'Health',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Wellbeing', 'Wellness', 'สุขภาพ'],
    ),
    CanonicalEntity(
      id: 'domain.family',
      canonicalName: 'Family',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Home', 'ครอบครัว'],
    ),
    CanonicalEntity(
      id: 'domain.learning',
      canonicalName: 'Learning',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Education', 'Study', 'การศึกษา'],
    ),
    CanonicalEntity(
      id: 'domain.spiritual',
      canonicalName: 'Spiritual',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Spirituality', 'Faith', 'จิตวิญญาณ'],
    ),
    CanonicalEntity(
      id: 'domain.personality',
      canonicalName: 'Personality',
      category: OntologyCategory.domain,
      parentId: 'domain.life',
      aliases: ['Self', 'Character', 'บุคลิกภาพ', 'ตัวตน'],
    ),
  ];

  /// Planet Library attribute **categories** (D-072 Ontology Expansion).
  ///
  /// Controlled vocabulary only: stable ids + Thai section headings from
  /// `หลักมหาภูต` pp.30–36 (`แสดงถึงสี`, `เกี่ยวกับบุคคล`, …). No meanings,
  /// relationships, or Canon claims. Attribute *values* are separate
  /// [attribute] entities produced during knowledge extraction.
  static const List<CanonicalEntity> attributeCategories = [
    CanonicalEntity(
      id: 'attributeCategory.color',
      canonicalName: 'Color',
      category: OntologyCategory.attributeCategory,
      aliases: ['สี', 'แสดงถึงสี'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.gemstone',
      canonicalName: 'Gemstone',
      category: OntologyCategory.attributeCategory,
      aliases: ['อัญมณี', 'เพชรพลอย'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.metal',
      canonicalName: 'Metal',
      category: OntologyCategory.attributeCategory,
      aliases: ['แร่ธาตุ', 'แสดงถึงแร่ธาตุ', 'ธาตุ'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.taste',
      canonicalName: 'Taste',
      category: OntologyCategory.attributeCategory,
      aliases: ['รส', 'แสดงถึงรส'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.disease',
      canonicalName: 'Disease',
      category: OntologyCategory.attributeCategory,
      aliases: ['โรค', 'เกี่ยวกับโรค', 'โรคที่เกิดจาก'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.bodyPart',
      canonicalName: 'Body part',
      category: OntologyCategory.attributeCategory,
      aliases: ['ส่วนร่างกาย', 'อวัยวะ'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.place',
      canonicalName: 'Place',
      category: OntologyCategory.attributeCategory,
      aliases: ['สถานที่', 'เกี่ยวกับสถานที่'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.profession',
      canonicalName: 'Person type',
      category: OntologyCategory.attributeCategory,
      aliases: ['บุคคล', 'เกี่ยวกับบุคคล'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.direction',
      canonicalName: 'Direction',
      category: OntologyCategory.attributeCategory,
      aliases: ['ทิศ', 'ทิศทาง'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.season',
      canonicalName: 'Season',
      category: OntologyCategory.attributeCategory,
      aliases: ['ฤดู', 'ฤดูกาล'],
    ),
    CanonicalEntity(
      id: 'attributeCategory.gender',
      canonicalName: 'Gender',
      category: OntologyCategory.attributeCategory,
      aliases: ['เพศ', 'แสดงถึงเพศ'],
    ),
  ];

  /// Relationship entities (one per registered relationship wire).
  static List<CanonicalEntity> relationshipEntities() => [
        for (final wire in relationships)
          CanonicalEntity(
            id: 'relationship.$wire',
            canonicalName: _titleCase(wire),
            category: OntologyCategory.relationship,
          ),
      ];

  /// Every seeded entity, deterministically ordered.
  static List<CanonicalEntity> allEntities() => [
        ...planets,
        ...houses(),
        ...mahabhutPositions,
        ...taksaRoles,
        ...agePeriods,
        ...periodStatuses,
        ...predictionEffects,
        ...remedies,
        ...remedyItems,
        ...ritualTargets,
        ...attributeCategories,
        ...CanonOntologyAttributeValues.all,
        ...elements,
        ...domains,
        ...relationshipEntities(),
      ];

  /// The standard ontology used across the Canon Platform.
  static CanonicalOntology standard() => CanonicalOntology.build(
        entities: allEntities(),
        relationships: relationships,
      );

  static String _titleCase(String wire) {
    final words = wire.split('_');
    if (words.isEmpty) return wire;
    final first =
        words.first.isEmpty ? '' : words.first[0].toUpperCase() + words.first.substring(1);
    final rest = words.skip(1).join(' ');
    return rest.isEmpty ? first : '$first $rest';
  }
}
