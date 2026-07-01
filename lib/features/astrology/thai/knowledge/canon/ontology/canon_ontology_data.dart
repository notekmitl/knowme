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
