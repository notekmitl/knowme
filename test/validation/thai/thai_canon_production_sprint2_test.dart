import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_extraction_rules.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/production/production.dart';

import 'generated/batch8_planet_library_units.dart';
import 'generated/batch9_direction_units.dart';
import 'generated/phase_c_taksa_units.dart';

/// Canon Knowledge Production — Sprint 2A first batch.
///
/// Real Canon knowledge extracted **from** `หลักมหาภูต` (ส. หยกฟ้า), produced
/// through the unchanged platform after the D-067 Ontology Expansion. Each unit
/// is a single fact stated on a specific page (reference-only provenance, D-057),
/// resolved to the Canonical Ontology, and validated by the real
/// `AtomicExtractionRules` + `KnowledgeProductionReport` (no logic reimplemented).
///
/// Extraction, not generation (D-066): only facts explicitly on the page are
/// recorded; no interpretation, no inference, no external knowledge. `เข้มแข็ง`
/// → strength.high and `อ่อน` → strength.low are direct lexical readings.
void main() {
  const book = 'mahabhut';

  AtomicKnowledgeUnit unit({
    required String id,
    required String subject,
    AtomicEntityKind subjectKind = AtomicEntityKind.planet,
    required AtomicRelation relation,
    required String object,
    AtomicEntityKind objectKind = AtomicEntityKind.other,
    AtomicStrength strength = AtomicStrength.none,
    String? chart,
    AtomicContextType? contextType,
    String? contextValue,
    String? condition,
    required String page,
  }) {
    final AtomicContext? ctx;
    if (contextValue != null && contextType != null) {
      ctx = AtomicContext(type: contextType, value: contextValue);
    } else if (chart != null) {
      ctx = AtomicContext(type: AtomicContextType.archetypeChart, value: chart);
    } else {
      ctx = null;
    }
    return AtomicKnowledgeUnit(
        id: id,
        subject: subject,
        subjectKind: subjectKind,
        relation: relation,
        object: object,
        objectKind: objectKind,
        domain: KnowledgeDomain.planetLibrary,
        strength: strength,
        confidence: KnowledgeConfidence.high,
        condition: condition,
        context: ctx,
        evidence: AtomicEvidenceRef(bookId: book, page: page),
      );
  }

  /// The cumulative production batch (Sprints 2A-2C + 3 + Production Batch 4).
  List<AtomicKnowledgeUnit> batch() => [
        // p.220 ดวงนักวิชาการ — Jupiter as significator of learning / career.
        unit(
          id: 'mahabhut.p220.jupiter_owns_learning',
          subject: 'planet.jupiter',
          relation: AtomicRelation.owns,
          object: 'domain.learning',
          objectKind: AtomicEntityKind.domain,
          page: '220',
        ),
        unit(
          id: 'mahabhut.p220.jupiter_owns_career',
          subject: 'planet.jupiter',
          relation: AtomicRelation.owns,
          object: 'domain.career',
          objectKind: AtomicEntityKind.domain,
          page: '220',
        ),
        // Sprint 2B — p.83: general natural signification (Moon → finance),
        // recurring identically across charts (ดาวจันทร์อันเป็นดาวแห่งการเงิน).
        unit(
          id: 'mahabhut.p83.moon_owns_finance',
          subject: 'planet.moon',
          relation: AtomicRelation.owns,
          object: 'domain.finance',
          objectKind: AtomicEntityKind.domain,
          page: '83',
        ),
        // Sprint 2C — chart-scoped placements carry an archetype_chart context
        // (D-068). p.220 ดวงนักวิชาการ: explicit placements + stated strength.
        unit(
          id: 'mahabhut.p220.jupiter_in_thongchai',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงนักวิชาการ',
          page: '220',
        ),
        unit(
          id: 'mahabhut.p220.jupiter_in_khumsap',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงนักวิชาการ',
          page: '220',
        ),
        unit(
          id: 'mahabhut.p220.mars_in_athibodi',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.athibodi',
          chart: 'ดวงนักวิชาการ',
          page: '220',
        ),
        // p.222 ดวงนักวิชาการ — Moon in marana (new this sprint).
        unit(
          id: 'mahabhut.p222.moon_in_marana',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.marana',
          chart: 'ดวงนักวิชาการ',
          page: '222',
        ),
        // p.150 ดวงมนุษย์เจ้าสำราญ — Jupiter in puti, อ่อน → low.
        unit(
          id: 'mahabhut.p150.jupiter_in_puti',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.puti',
          strength: AtomicStrength.low,
          chart: 'ดวงมนุษย์เจ้าสําราญ',
          page: '150',
        ),
        // p.50 ดวงกำพร้า — Jupiter in athibodi.
        unit(
          id: 'mahabhut.p50.jupiter_in_athibodi',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.athibodi',
          chart: 'ดวงกําพร้า',
          page: '50',
        ),

        // Sprint 3 — ดวงกําพร้า natal assignment (pages 43-50). Strength from
        // stated dignity. Saturn's natal position is not stated → not recorded.
        unit(
          id: 'mahabhut.p43.sun_in_phangkha',
          subject: 'planet.sun',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          strength: AtomicStrength.low,
          chart: 'ดวงกําพร้า',
          page: '43',
        ),
        unit(
          id: 'mahabhut.p43.moon_in_puti',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.puti',
          strength: AtomicStrength.low,
          chart: 'ดวงกําพร้า',
          page: '43',
        ),
        unit(
          id: 'mahabhut.p47.mars_in_khumsap',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงกําพร้า',
          page: '47',
        ),
        unit(
          id: 'mahabhut.p47.mercury_in_marana',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.marana',
          strength: AtomicStrength.low,
          chart: 'ดวงกําพร้า',
          page: '47',
        ),
        unit(
          id: 'mahabhut.p48.venus_in_racha',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงกําพร้า',
          page: '48',
        ),

        // Sprint 3 — ดวงนักภาษา natal assignment (pages 83-88). Sun & Saturn
        // natal positions not stated in natal sections → not recorded.
        unit(
          id: 'mahabhut.p83.moon_in_phangkha',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          strength: AtomicStrength.low,
          chart: 'ดวงนักภาษา',
          page: '83',
        ),
        unit(
          id: 'mahabhut.p83.jupiter_in_marana',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.marana',
          chart: 'ดวงนักภาษา',
          page: '83',
        ),
        unit(
          id: 'mahabhut.p84.mars_in_puti',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.puti',
          strength: AtomicStrength.low,
          chart: 'ดวงนักภาษา',
          page: '84',
        ),
        unit(
          id: 'mahabhut.p85.venus_in_athibodi',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.athibodi',
          strength: AtomicStrength.high,
          chart: 'ดวงนักภาษา',
          page: '85',
        ),
        unit(
          id: 'mahabhut.p87.mercury_in_khumsap',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงนักภาษา',
          page: '87',
        ),

        // Production Batch 4 — ดวงมนุษย์เจ้าสำราญ (pp.153-155). Jupiter→ปูติ
        // already in Canon (p150). Sun/Saturn not stated → not recorded.
        unit(
          id: 'mahabhut.p153.moon_in_racha',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงมนุษย์เจ้าสําราญ',
          page: '153',
        ),
        unit(
          id: 'mahabhut.p153.mars_in_thongchai',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงมนุษย์เจ้าสําราญ',
          page: '153',
        ),
        unit(
          id: 'mahabhut.p155.venus_in_khumsap',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงมนุษย์เจ้าสําราญ',
          page: '155',
        ),
        unit(
          id: 'mahabhut.p155.mercury_in_phangkha',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          chart: 'ดวงมนุษย์เจ้าสําราญ',
          page: '155',
        ),

        // Production Batch 4 — ดวงนักวิชาการ additions (pp.224-225).
        unit(
          id: 'mahabhut.p224.venus_in_phangkha',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          chart: 'ดวงนักวิชาการ',
          page: '224',
        ),
        unit(
          id: 'mahabhut.p225.mercury_in_racha',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงนักวิชาการ',
          page: '225',
        ),

        // Production Batch 4 — ดวงเศรษฐี (pp.181-187). Sun/Saturn not stated.
        unit(
          id: 'mahabhut.p181.moon_in_athibodi',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.athibodi',
          strength: AtomicStrength.high,
          chart: 'ดวงเศรษฐี',
          page: '181',
        ),
        unit(
          id: 'mahabhut.p181.mercury_in_thongchai',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงเศรษฐี',
          page: '181',
        ),
        unit(
          id: 'mahabhut.p182.jupiter_in_phangkha',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          strength: AtomicStrength.low,
          chart: 'ดวงเศรษฐี',
          page: '182',
        ),
        unit(
          id: 'mahabhut.p185.mars_in_racha',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงเศรษฐี',
          page: '185',
        ),
        unit(
          id: 'mahabhut.p186.venus_in_puti',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.puti',
          strength: AtomicStrength.low,
          chart: 'ดวงเศรษฐี',
          page: '186',
        ),

        // Production Batch 5 — ดวงมหาเศรษฐี (pp.254-262). Benefic group
        // จันทร์/พุธ/พฤหัส/ศุกร์ → ขุมทรัพย์/อธิบดี/ราชา/ธงชัย ตามลำดับ (verbatim);
        // mars→มรณะ. Sun/Saturn not stated → not recorded.
        unit(
          id: 'mahabhut.p258.moon_in_khumsap',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          chart: 'ดวงมหาเศรษฐี',
          page: '258',
        ),
        unit(
          id: 'mahabhut.p261.mercury_in_athibodi',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.athibodi',
          strength: AtomicStrength.high,
          chart: 'ดวงมหาเศรษฐี',
          page: '261',
        ),
        unit(
          id: 'mahabhut.p256.jupiter_in_racha',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงมหาเศรษฐี',
          page: '256',
        ),
        unit(
          id: 'mahabhut.p260.venus_in_thongchai',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงมหาเศรษฐี',
          page: '260',
        ),
        unit(
          id: 'mahabhut.p259.mars_in_marana',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.marana',
          strength: AtomicStrength.low,
          chart: 'ดวงมหาเศรษฐี',
          page: '259',
        ),

        // Production Batch 5 — ดวงนักบริหาร (pp.113-119). คู่มิตร group
        // อาทิตย์/พฤหัส → ราชา/ขุมทรัพย์ ตามลำดับ (verbatim p113); others by
        // their own domain sections. Saturn not stated → not recorded.
        unit(
          id: 'mahabhut.p113.sun_in_racha',
          subject: 'planet.sun',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.racha',
          strength: AtomicStrength.high,
          chart: 'ดวงนักบริหาร',
          page: '113',
        ),
        unit(
          id: 'mahabhut.p114.jupiter_in_khumsap',
          subject: 'planet.jupiter',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงนักบริหาร',
          page: '114',
        ),
        unit(
          id: 'mahabhut.p116.moon_in_thongchai',
          subject: 'planet.moon',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงนักบริหาร',
          page: '116',
        ),
        unit(
          id: 'mahabhut.p116.mars_in_phangkha',
          subject: 'planet.mars',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.phangkha',
          strength: AtomicStrength.low,
          chart: 'ดวงนักบริหาร',
          page: '116',
        ),
        unit(
          id: 'mahabhut.p118.venus_in_marana',
          subject: 'planet.venus',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.marana',
          strength: AtomicStrength.low,
          chart: 'ดวงนักบริหาร',
          page: '118',
        ),
        unit(
          id: 'mahabhut.p119.mercury_in_puti',
          subject: 'planet.mercury',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.puti',
          strength: AtomicStrength.low,
          chart: 'ดวงนักบริหาร',
          page: '119',
        ),

        // Production Batch 6 — remaining natal Sun seats. Each is a clean 2:2
        // ตามลำดับ group anchored by an already-recorded Mercury placement.
        // ดวงนักภาษา p77: อาทิตย์/พุธ → ธงชัย/ขุมทรัพย์ (Mercury→ขุมทรัพย์ p87).
        unit(
          id: 'mahabhut.p77.sun_in_thongchai',
          subject: 'planet.sun',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.thongchai',
          strength: AtomicStrength.high,
          chart: 'ดวงนักภาษา',
          page: '77',
        ),
        // ดวงนักวิชาการ p219: อาทิตย์/พุธ → ขุมทรัพย์/ราชา (Mercury→ราชา p225).
        // Co-exists with the prior jupiter_in_khumsap (p220 การงาน) as a faithful
        // source-internal tension; injectivity is NOT asserted for this chart.
        unit(
          id: 'mahabhut.p219.sun_in_khumsap',
          subject: 'planet.sun',
          relation: AtomicRelation.locatedIn,
          object: 'mahabhutPosition.khumsap',
          strength: AtomicStrength.high,
          chart: 'ดวงนักวิชาการ',
          page: '219',
        ),

        // Production Batch 7 — front-matter general significations (pp.1–41).
        // p28 คุรหจินดา family-role table (หมายถึง …).
        unit(
          id: 'mahabhut.p28.sun_owns_family',
          subject: 'planet.sun',
          relation: AtomicRelation.owns,
          object: 'domain.family',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.moon_owns_family',
          subject: 'planet.moon',
          relation: AtomicRelation.owns,
          object: 'domain.family',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.mars_owns_relationship',
          subject: 'planet.mars',
          relation: AtomicRelation.owns,
          object: 'domain.relationship',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.mercury_owns_family',
          subject: 'planet.mercury',
          relation: AtomicRelation.owns,
          object: 'domain.family',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.jupiter_owns_learning',
          subject: 'planet.jupiter',
          relation: AtomicRelation.owns,
          object: 'domain.learning',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.venus_owns_relationship',
          subject: 'planet.venus',
          relation: AtomicRelation.owns,
          object: 'domain.relationship',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        unit(
          id: 'mahabhut.p28.saturn_owns_family',
          subject: 'planet.saturn',
          relation: AtomicRelation.owns,
          object: 'domain.family',
          objectKind: AtomicEntityKind.domain,
          page: '28',
        ),
        // p29 concise lookup (ดู … ให้ดู …).
        unit(
          id: 'mahabhut.p29.moon_owns_personality',
          subject: 'planet.moon',
          relation: AtomicRelation.owns,
          object: 'domain.personality',
          objectKind: AtomicEntityKind.domain,
          page: '29',
        ),
        unit(
          id: 'mahabhut.p29.mars_owns_personality',
          subject: 'planet.mars',
          relation: AtomicRelation.owns,
          object: 'domain.personality',
          objectKind: AtomicEntityKind.domain,
          page: '29',
        ),
        unit(
          id: 'mahabhut.p29.jupiter_owns_learning',
          subject: 'planet.jupiter',
          relation: AtomicRelation.owns,
          object: 'domain.learning',
          objectKind: AtomicEntityKind.domain,
          page: '29',
        ),
        unit(
          id: 'mahabhut.p29.jupiter_owns_career',
          subject: 'planet.jupiter',
          relation: AtomicRelation.owns,
          object: 'domain.career',
          objectKind: AtomicEntityKind.domain,
          page: '29',
        ),
        // p16 gender-conditional spouse significators (condition verbatim from source).
        unit(
          id: 'mahabhut.p16.mars_owns_relationship_female',
          subject: 'planet.mars',
          relation: AtomicRelation.owns,
          object: 'domain.relationship',
          objectKind: AtomicEntityKind.domain,
          condition: 'เจ้าชะตาเป็นผู้หญิง',
          page: '16',
        ),
        unit(
          id: 'mahabhut.p16.venus_owns_relationship_male',
          subject: 'planet.venus',
          relation: AtomicRelation.owns,
          object: 'domain.relationship',
          objectKind: AtomicEntityKind.domain,
          condition: 'เจ้าชะตาเป็นผู้ชาย',
          page: '16',
        ),
        ...batch8PlanetLibraryUnits(unit: unit),
        ...batch9DirectionUnits(unit: unit),
        ...phaseCTaksaUnits(unit: unit),
      ];

  group('Mahabhut production batch (Sprints 2A-2C + 3 + Batch 4-9 + Phase C)', () {
    final ontology = CanonOntologyData.standard();
    final units = batch();

    test('every subject and object resolves to a canonical ontology entity', () {
      for (final u in units) {
        expect(ontology.entity(u.subject), isNotNull,
            reason: 'subject "${u.subject}" (${u.id})');
        expect(ontology.entity(u.object), isNotNull,
            reason: 'object "${u.object}" (${u.id})');
      }
    });

    test('every unit is atomic and traceable (real AtomicExtractionRules)', () {
      final issues = AtomicExtractionRules.validateAll(units);
      expect(issues, isEmpty, reason: issues.map((i) => '$i').join('\n'));
    });

    test('every unit carries page provenance (reference-only, D-057)', () {
      for (final u in units) {
        expect(u.evidence.bookId, 'mahabhut');
        expect(u.evidence.page, isNotNull);
        expect(u.evidence.hasReference, isTrue);
      }
    });

    test('Mahabhut named positions are used as resolved objects', () {
      final positionObjects = units
          .where((u) => u.object.startsWith('mahabhutPosition.'))
          .map((u) => u.object)
          .toSet();
      expect(positionObjects, {
        'mahabhutPosition.thongchai',
        'mahabhutPosition.khumsap',
        'mahabhutPosition.athibodi',
        'mahabhutPosition.puti',
        'mahabhutPosition.marana',
        'mahabhutPosition.phangkha',
        'mahabhutPosition.racha',
      });
    });

    test('mahabhut position placements are archetype-chart scoped (D-068)', () {
      for (final u in units) {
        if (u.relation == AtomicRelation.locatedIn &&
            u.object.startsWith('mahabhutPosition.')) {
          expect(u.context, isNotNull, reason: '${u.id} must carry context');
          expect(u.context!.type, AtomicContextType.archetypeChart);
          expect(u.context!.value.trim(), isNotEmpty);
        }
      }
    });

    test('taksa role assignments are context-scoped (Phase C)', () {
      for (final u in units) {
        if (u.relation == AtomicRelation.locatedIn &&
            u.object.startsWith('taksaRole.')) {
          expect(u.context, isNotNull, reason: '${u.id} must carry context');
          expect(u.context!.value.trim(), isNotEmpty);
          expect(
            u.context!.type,
            isIn([
              AtomicContextType.archetypeChart,
              AtomicContextType.lifePeriod,
              AtomicContextType.other,
            ]),
          );
        }
      }
    });

    test('taksa roles resolve from Thai aliases (D-074)', () {
      const expected = {
        'บริวาร': 'taksaRole.boriwan',
        'อายุ': 'taksaRole.ayu',
        'เดช': 'taksaRole.det',
        'ศรี': 'taksaRole.sri',
        'มูละ': 'taksaRole.mula',
        'อุตสาหะ': 'taksaRole.utsaha',
        'มนตรี': 'taksaRole.montri',
        'กาฬกิณี': 'taksaRole.kalakini',
      };
      for (final entry in expected.entries) {
        expect(ontology.resolveId(entry.key), entry.value,
            reason: 'resolve "${entry.key}"');
      }
    });

    test('planet domain significations stay general; taksa meanings too', () {
      for (final u in units) {
        if (u.relation != AtomicRelation.owns) continue;
        if (u.subject.startsWith('planet.') ||
            u.subject.startsWith('taksaRole.')) {
          expect(u.context, isNull, reason: '${u.id} must stay general');
        }
      }
    });

    test('no inferred taksa assignment without context', () {
      final unscopedTaksa = units.where((u) =>
          u.object.startsWith('taksaRole.') &&
          u.relation == AtomicRelation.locatedIn &&
          u.context == null);
      expect(unscopedTaksa, isEmpty);
    });

    test('the same position is scoped to different charts without collision', () {
      final scopedAthibodi = units
          .where((u) => u.object == 'mahabhutPosition.athibodi')
          .map((u) => '${u.subject}|${u.context!.key}')
          .toSet();
      // athibodi holds different planets in different archetype charts.
      expect(scopedAthibodi, {
        'planet.mars|archetype_chart:ดวงนักวิชาการ',
        'planet.jupiter|archetype_chart:ดวงกําพร้า',
        'planet.venus|archetype_chart:ดวงนักภาษา',
        'planet.moon|archetype_chart:ดวงเศรษฐี',
        'planet.mercury|archetype_chart:ดวงมหาเศรษฐี',
      });
    });

    test('a chart natal assignment maps positions injectively (ดวงเศรษฐี)', () {
      final wealthy = units.where((u) =>
          u.relation == AtomicRelation.locatedIn &&
          u.object.startsWith('mahabhutPosition.') &&
          u.context?.value == 'ดวงเศรษฐี');
      final byPosition = <String, String>{};
      for (final u in wealthy) {
        expect(byPosition.containsKey(u.object), isFalse,
            reason: '${u.object} assigned twice in ดวงเศรษฐี');
        byPosition[u.object] = u.subject;
      }
      expect(byPosition, {
        'mahabhutPosition.athibodi': 'planet.moon',
        'mahabhutPosition.thongchai': 'planet.mercury',
        'mahabhutPosition.phangkha': 'planet.jupiter',
        'mahabhutPosition.racha': 'planet.mars',
        'mahabhutPosition.puti': 'planet.venus',
      });
    });

    test('a chart natal assignment maps positions injectively (ดวงกําพร้า)', () {
      final orphan = units.where((u) =>
          u.relation == AtomicRelation.locatedIn &&
          u.object.startsWith('mahabhutPosition.') &&
          u.context?.value == 'ดวงกําพร้า');
      final byPosition = <String, String>{};
      for (final u in orphan) {
        // No position holds two different planets within one chart.
        expect(byPosition.containsKey(u.object), isFalse,
            reason: '${u.object} assigned twice in ดวงกําพร้า');
        byPosition[u.object] = u.subject;
      }
      expect(byPosition, {
        'mahabhutPosition.phangkha': 'planet.sun',
        'mahabhutPosition.puti': 'planet.moon',
        'mahabhutPosition.khumsap': 'planet.mars',
        'mahabhutPosition.marana': 'planet.mercury',
        'mahabhutPosition.racha': 'planet.venus',
        'mahabhutPosition.athibodi': 'planet.jupiter',
      });
    });

    test('a chart natal assignment maps positions injectively (ดวงมหาเศรษฐี)', () {
      final tycoon = units.where((u) =>
          u.relation == AtomicRelation.locatedIn &&
          u.object.startsWith('mahabhutPosition.') &&
          u.context?.value == 'ดวงมหาเศรษฐี');
      final byPosition = <String, String>{};
      for (final u in tycoon) {
        expect(byPosition.containsKey(u.object), isFalse,
            reason: '${u.object} assigned twice in ดวงมหาเศรษฐี');
        byPosition[u.object] = u.subject;
      }
      expect(byPosition, {
        'mahabhutPosition.khumsap': 'planet.moon',
        'mahabhutPosition.athibodi': 'planet.mercury',
        'mahabhutPosition.racha': 'planet.jupiter',
        'mahabhutPosition.thongchai': 'planet.venus',
        'mahabhutPosition.marana': 'planet.mars',
      });
    });

    test('a chart natal assignment maps positions injectively (ดวงนักบริหาร)', () {
      final exec = units.where((u) =>
          u.relation == AtomicRelation.locatedIn &&
          u.object.startsWith('mahabhutPosition.') &&
          u.context?.value == 'ดวงนักบริหาร');
      final byPosition = <String, String>{};
      for (final u in exec) {
        expect(byPosition.containsKey(u.object), isFalse,
            reason: '${u.object} assigned twice in ดวงนักบริหาร');
        byPosition[u.object] = u.subject;
      }
      expect(byPosition, {
        'mahabhutPosition.racha': 'planet.sun',
        'mahabhutPosition.khumsap': 'planet.jupiter',
        'mahabhutPosition.thongchai': 'planet.moon',
        'mahabhutPosition.phangkha': 'planet.mars',
        'mahabhutPosition.marana': 'planet.venus',
        'mahabhutPosition.puti': 'planet.mercury',
      });
    });

    test('production report shows real coverage increase from zero', () {
      final empty = KnowledgeProductionReport.build(const [], ontology);
      expect(empty.totalUnits, 0);

      final report = KnowledgeProductionReport.build(units, ontology);
      expect(report.totalUnits, units.length);
      expect(report.allAtomic, isTrue, reason: report.render());
      expect(report.provenanceComplete, isTrue);

      // Planet Library counts planet-subject units (taksaRole subjects excluded).
      final planetLib = report.domain(ProductionDomain.planetLibrary)!;
      expect(
        planetLib.produced,
        units.where((u) => u.subjectKind == AtomicEntityKind.planet).length,
      );
      expect(planetLib.subjectsCovered, 8);
      expect(planetLib.status, ProductionStatus.partial);

      // Planet → Domain natural significators (general): Jupiter → learning/
      // career, Moon → finance, plus front-matter family/relationship/personality.
      final planetDomains = report.domain(ProductionDomain.planetDomains)!;
      expect(planetDomains.produced, 16);
      expect(planetDomains.subjectsCovered, 7);

      final planetKeywords = report.domain(ProductionDomain.planetKeywords)!;
      expect(planetKeywords.produced, 301);
      expect(planetKeywords.subjectsCovered, 8);
    });

    test('the batch is deterministic', () {
      final a = KnowledgeProductionReport.build(batch(), ontology).render();
      final b = KnowledgeProductionReport.build(batch(), ontology).render();
      expect(a, b);
    });
  });

  // Production metrics are REPORTING ONLY (Batch 5 request). They are derived
  // from the produced units here; they do not affect Canon knowledge or runtime
  // and add no platform/ontology code. The numbers mirror the Batch 5 report.
  group('Production metrics (reporting only)', () {
    final units = batch();
    final mahabhutPlacements = units
        .where((u) =>
            u.relation == AtomicRelation.locatedIn &&
            u.object.startsWith('mahabhutPosition.'))
        .toList();
    final taksaPlacements = units
        .where((u) =>
            u.relation == AtomicRelation.locatedIn &&
            u.object.startsWith('taksaRole.'))
        .toList();

    Map<String, int> countBy(Iterable<AtomicKnowledgeUnit> source,
        String Function(AtomicKnowledgeUnit) key) {
      final counts = <String, int>{};
      for (final u in source) {
        final k = key(u);
        counts[k] = (counts[k] ?? 0) + 1;
      }
      return counts;
    }

    test('coverage by planet (all units)', () {
      expect(countBy(units, (u) => u.subject), {
        'planet.sun': 60,
        'planet.moon': 71,
        'planet.mars': 68,
        'planet.mercury': 54,
        'planet.jupiter': 58,
        'planet.venus': 62,
        'planet.saturn': 41,
        'planet.rahu': 34,
        'taksaRole.ayu': 1,
        'taksaRole.det': 1,
        'taksaRole.sri': 1,
        'taksaRole.montri': 1,
      });
    });

    test('coverage by archetype (mahabhut placements only)', () {
      final chartPlacements = mahabhutPlacements
          .where((u) => u.context?.type == AtomicContextType.archetypeChart);
      expect(countBy(chartPlacements, (u) => u.context!.value), {
        'ดวงนักวิชาการ': 7,
        'ดวงมนุษย์เจ้าสําราญ': 5,
        'ดวงกําพร้า': 6,
        'ดวงนักภาษา': 6,
        'ดวงเศรษฐี': 5,
        'ดวงมหาเศรษฐี': 5,
        'ดวงนักบริหาร': 6,
      });
    });

    test('coverage by mahabhut position (natal placements only)', () {
      expect(countBy(mahabhutPlacements, (u) => u.object), {
        'mahabhutPosition.thongchai': 6,
        'mahabhutPosition.khumsap': 7,
        'mahabhutPosition.athibodi': 5,
        'mahabhutPosition.racha': 6,
        'mahabhutPosition.puti': 5,
        'mahabhutPosition.marana': 5,
        'mahabhutPosition.phangkha': 6,
      });
    });

    test('coverage by taksa role (Phase C assignments)', () {
      expect(countBy(taksaPlacements, (u) => u.object), {
        'taksaRole.boriwan': 21,
        'taksaRole.ayu': 14,
        'taksaRole.det': 18,
        'taksaRole.sri': 17,
        'taksaRole.mula': 15,
        'taksaRole.utsaha': 4,
        'taksaRole.montri': 1,
        'taksaRole.kalakini': 1,
      });
    });

    test('coverage by context (all units)', () {
      final byContext = <String, int>{};
      for (final u in units) {
        final key = u.context == null ? 'general' : u.context!.type.wire;
        byContext[key] = (byContext[key] ?? 0) + 1;
      }
      expect(byContext, {
        'archetype_chart': 43,
        'general': 321,
        'other': 8,
        'life_period': 80,
      });
    });

    test('metrics totals reconcile with the batch', () {
      expect(units.length, 452);
      expect(mahabhutPlacements.length, 40);
      expect(taksaPlacements.length, 91);
    });
  });
}
