import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_extraction_rules.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/canonical_knowledge_node.dart'
    show KnowledgeConfidence;
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/production/production.dart';

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
    required String page,
  }) =>
      AtomicKnowledgeUnit(
        id: id,
        subject: subject,
        subjectKind: subjectKind,
        relation: relation,
        object: object,
        objectKind: objectKind,
        domain: KnowledgeDomain.planetLibrary,
        strength: strength,
        confidence: KnowledgeConfidence.high,
        context: chart == null
            ? null
            : AtomicContext(
                type: AtomicContextType.archetypeChart, value: chart),
        evidence: AtomicEvidenceRef(bookId: book, page: page),
      );

  /// The cumulative production batch (Sprints 2A-2C + 3), produced page-by-page.
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
      ];

  group('Mahabhut production batch (Sprint 2A–2C)', () {
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

    test('placements are chart-scoped; significations stay general (D-068)', () {
      for (final u in units) {
        final isPlacement = u.relation == AtomicRelation.locatedIn;
        if (isPlacement) {
          // Every named-position placement is scoped to an archetype chart.
          expect(u.context, isNotNull, reason: '${u.id} must carry context');
          expect(u.context!.type, AtomicContextType.archetypeChart);
          expect(u.context!.value.trim(), isNotEmpty);
        } else {
          // Natural significations (planet --owns--> domain) are general facts.
          expect(u.context, isNull, reason: '${u.id} must stay general');
        }
      }
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
      });
    });

    test('a chart natal assignment maps positions injectively (ดวงกําพร้า)', () {
      final orphan = units.where((u) =>
          u.relation == AtomicRelation.locatedIn &&
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

    test('production report shows real coverage increase from zero', () {
      final empty = KnowledgeProductionReport.build(const [], ontology);
      expect(empty.totalUnits, 0);

      final report = KnowledgeProductionReport.build(units, ontology);
      expect(report.totalUnits, units.length);
      expect(report.allAtomic, isTrue, reason: report.render());
      expect(report.provenanceComplete, isTrue);

      // Planet Library now covers 6 of 9 planets (Sun, Moon, Mars, Mercury,
      // Jupiter, Venus) after Sprint 3; was 0.
      final planetLib = report.domain(ProductionDomain.planetLibrary)!;
      expect(planetLib.produced, units.length);
      expect(planetLib.subjectsCovered, 6);
      expect(planetLib.status, ProductionStatus.partial);

      // Planet → Domain natural significators (general): Jupiter → learning/
      // career, Moon → finance. Placements are not domain facts.
      final planetDomains = report.domain(ProductionDomain.planetDomains)!;
      expect(planetDomains.produced, 3);
      expect(planetDomains.subjectsCovered, 2);
    });

    test('the batch is deterministic', () {
      final a = KnowledgeProductionReport.build(batch(), ontology).render();
      final b = KnowledgeProductionReport.build(batch(), ontology).render();
      expect(a, b);
    });
  });
}
