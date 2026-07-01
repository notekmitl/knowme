import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/ontology/ontology.dart';

/// Canon Ontology V3 — the Canonical Ontology Layer is the mandatory controlled
/// vocabulary for all Canon extraction. Pure knowledge layer; no engine/runtime/
/// matrix/mirror/fusion dependency.

void main() {
  group('Alias resolution', () {
    final ont = CanonOntologyData.standard();

    test('resolves multilingual aliases to one canonical entity', () {
      for (final surface in ['Jupiter', 'Guru', 'ดาวพฤหัส', 'พฤหัสบดี']) {
        expect(ont.resolveId(surface), 'planet.jupiter',
            reason: 'resolve "$surface"');
      }
      for (final surface in ['Finance', 'Money', 'Wealth', 'การเงิน']) {
        expect(ont.resolveId(surface), 'domain.finance');
      }
    });

    test('is deterministic and case/whitespace-insensitive', () {
      expect(ont.resolveId('  jUPiTer '), 'planet.jupiter');
      expect(ont.resolveId('Jupiter'), ont.resolveId('jupiter'));
    });

    test('unknown aliases remain unresolved — never guesses', () {
      expect(ont.resolve('Nibiru'), isNull);
      expect(ont.canResolve('totally unknown term'), isFalse);
    });
  });

  group('Mahabhut Named Positions (D-067 Ontology Expansion)', () {
    final ont = CanonOntologyData.standard();

    test('the seven Canon positions resolve from both surface forms', () {
      const expected = {
        'ธงชัย': 'mahabhutPosition.thongchai',
        'เรือนธงชัย': 'mahabhutPosition.thongchai',
        'อธิบดี': 'mahabhutPosition.athibodi',
        'เรือนอธิบดี': 'mahabhutPosition.athibodi',
        'ขุมทรัพย์': 'mahabhutPosition.khumsap',
        'เรือนขุมทรัพย์': 'mahabhutPosition.khumsap',
        'ราชา': 'mahabhutPosition.racha',
        'เรือนราชา': 'mahabhutPosition.racha',
        'ปูติ': 'mahabhutPosition.puti',
        'เรือนปูติ': 'mahabhutPosition.puti',
        'มรณะ': 'mahabhutPosition.marana',
        'เรือนมรณะ': 'mahabhutPosition.marana',
        'ภังคะ': 'mahabhutPosition.phangkha',
        'เรือนภังคะ': 'mahabhutPosition.phangkha',
      };
      expected.forEach((surface, id) {
        expect(ont.resolveId(surface), id, reason: 'resolve "$surface"');
      });
    });

    test('exactly seven positions are seeded, all with valid prefix', () {
      final positions = ont.entitiesOf(OntologyCategory.mahabhutPosition);
      expect(positions.length, 7);
      expect(positions.every((e) => e.hasValidPrefix), isTrue);
    });

    test('positions add no meaning/relationship and do not collide', () {
      // Adding the positions keeps the whole ontology valid (no alias collision
      // with planets/houses/domains; no relationships or parents introduced).
      expect(ont.validate().isValid, isTrue);
      for (final e in ont.entitiesOf(OntologyCategory.mahabhutPosition)) {
        expect(e.parentId, isNull);
        expect(e.description, isNull);
      }
    });

    test('existing identifiers are preserved', () {
      expect(ont.resolveId('ดาวพฤหัส'), 'planet.jupiter');
      expect(ont.resolveId('เรือนที่ 5'), 'house.5');
      expect(ont.resolveId('การศึกษา'), 'domain.learning');
    });
  });

  group('Planet Library attribute categories (D-072 Ontology Expansion)', () {
    final ont = CanonOntologyData.standard();

    test('eleven attribute categories are seeded with valid prefix', () {
      final cats = ont.entitiesOf(OntologyCategory.attributeCategory);
      expect(cats.length, 11);
      expect(cats.every((e) => e.hasValidPrefix), isTrue);
      expect(cats.every((e) => e.parentId == null), isTrue);
      expect(cats.every((e) => e.description == null), isTrue);
    });

    test('section headings resolve to attribute categories', () {
      expect(ont.resolveId('แสดงถึงสี'), 'attributeCategory.color');
      expect(ont.resolveId('เกี่ยวกับบุคคล'), 'attributeCategory.profession');
      expect(ont.resolveId('เกี่ยวกับสถานที่'), 'attributeCategory.place');
      expect(ont.resolveId('แสดงถึงแร่ธาตุ'), 'attributeCategory.metal');
    });

    test('adding categories keeps the ontology valid', () {
      expect(ont.validate().isValid, isTrue, reason: ont.validate().summary);
    });
  });

  group('Validation', () {
    test('the standard ontology is valid', () {
      final report = CanonOntologyData.standard().validate();
      expect(report.isValid, isTrue, reason: report.summary);
    });

    test('duplicate ids are rejected', () {
      final dupes = [
        const CanonicalEntity(
            id: 'planet.sun', canonicalName: 'Sun', category: OntologyCategory.planet),
        const CanonicalEntity(
            id: 'planet.sun', canonicalName: 'Surya', category: OntologyCategory.planet),
      ];
      final ont = CanonicalOntology.build(
          entities: dupes, relationships: CanonOntologyData.relationships);
      final report = ont.validate(rawEntities: dupes);
      expect(report.hasCode('duplicate_id'), isTrue);
      expect(report.isValid, isFalse);
    });

    test('duplicate aliases / alias collisions are rejected', () {
      final colliding = [
        const CanonicalEntity(
            id: 'planet.mars',
            canonicalName: 'Mars',
            category: OntologyCategory.planet,
            aliases: ['Red']),
        const CanonicalEntity(
            id: 'planet.ketu',
            canonicalName: 'Ketu',
            category: OntologyCategory.planet,
            aliases: ['Red']),
      ];
      final ont = CanonicalOntology.build(
          entities: colliding, relationships: CanonOntologyData.relationships);
      final report = ont.validate();
      expect(report.hasCode('alias_collision'), isTrue);
      // Colliding alias must NOT resolve (no guessing).
      expect(ont.resolve('Red'), isNull);
    });

    test('category / id-prefix mismatch is rejected', () {
      final bad = [
        const CanonicalEntity(
            id: 'planet.finance',
            canonicalName: 'Finance',
            category: OntologyCategory.domain),
      ];
      final ont = CanonicalOntology.build(
          entities: bad, relationships: CanonOntologyData.relationships);
      expect(ont.validate().hasCode('category_mismatch'), isTrue);
    });

    test('orphan parent references are rejected', () {
      final orphan = [
        const CanonicalEntity(
            id: 'domain.career',
            canonicalName: 'Career',
            category: OntologyCategory.domain,
            parentId: 'domain.missing'),
      ];
      final ont = CanonicalOntology.build(
          entities: orphan, relationships: CanonOntologyData.relationships);
      expect(ont.validate().hasCode('orphan_entity'), isTrue);
    });

    test('unregistered relationship entity is rejected', () {
      final bad = [
        const CanonicalEntity(
            id: 'relationship.teleports',
            canonicalName: 'Teleports',
            category: OntologyCategory.relationship),
      ];
      final ont = CanonicalOntology.build(
          entities: bad, relationships: CanonOntologyData.relationships);
      expect(ont.validate().hasCode('relationship_not_registered'), isTrue);
    });

    test('validation report is deterministic', () {
      final a = CanonOntologyData.standard().validate();
      final b = CanonOntologyData.standard().validate();
      expect(a.summary, b.summary);
      expect(a.issues.map((i) => i.signature).toList(),
          b.issues.map((i) => i.signature).toList());
    });
  });

  group('Taxonomy', () {
    final ont = CanonOntologyData.standard();

    test('is acyclic', () {
      expect(ont.taxonomyIsAcyclic, isTrue);
    });

    test('children and ancestors resolve through the tree', () {
      final children = ont.childrenOf('domain.life').map((e) => e.id).toList();
      expect(children, contains('domain.finance'));
      expect(ont.ancestorsOf('domain.finance'), ['domain.life']);
    });

    test('a cycle is detected as invalid', () {
      final cyclic = [
        const CanonicalEntity(
            id: 'domain.a',
            canonicalName: 'A',
            category: OntologyCategory.domain,
            parentId: 'domain.b'),
        const CanonicalEntity(
            id: 'domain.b',
            canonicalName: 'B',
            category: OntologyCategory.domain,
            parentId: 'domain.a'),
      ];
      final ont = CanonicalOntology.build(
          entities: cyclic, relationships: CanonOntologyData.relationships);
      expect(ont.taxonomyIsAcyclic, isFalse);
      expect(ont.validate().hasCode('taxonomy_cycle'), isTrue);
    });
  });

  group('Relationship registry', () {
    final ont = CanonOntologyData.standard();

    test('graph can only use registered relationships (V2 AtomicRelation)', () {
      final wires = AtomicRelation.values.map((r) => r.wire);
      expect(ont.unregisteredRelationships(wires), isEmpty,
          reason: 'every AtomicRelation wire must be in the ontology');
    });

    test('an invented relationship string is flagged as unregistered', () {
      expect(ont.isRegisteredRelationship('teleports'), isFalse);
      expect(ont.unregisteredRelationships(['owns', 'teleports']), ['teleports']);
    });
  });

  group('Serialization round-trip', () {
    test('entity JSON round-trips', () {
      const e = CanonicalEntity(
        id: 'domain.finance',
        canonicalName: 'Finance',
        category: OntologyCategory.domain,
        parentId: 'domain.life',
        aliases: ['Money', 'Wealth'],
      );
      final back = CanonicalEntity.fromJson(e.toJson());
      expect(back, isNotNull);
      expect(back!.id, 'domain.finance');
      expect(back.category, OntologyCategory.domain);
      expect(back.parentId, 'domain.life');
      expect(back.aliases, ['Money', 'Wealth']);
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('ontology layer imports no engine/runtime/matrix/mirror/fusion/flutter',
        () {
      final dir = Directory(
          'lib/features/astrology/thai/knowledge/canon/ontology');
      for (final f in dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final imports = f
            .readAsLinesSync()
            .where((l) => l.trimLeft().startsWith('import '))
            .join('\n');
        for (final forbidden in const [
          'package:flutter/',
          'planet_relationship_matrix',
          'core/life_period',
          '/runtime/',
          '/mirror/',
          '/fusion/',
          '/narrative',
        ]) {
          expect(imports.contains(forbidden), isFalse,
              reason: '${f.path} must not import $forbidden');
        }
      }
    });
  });
}
