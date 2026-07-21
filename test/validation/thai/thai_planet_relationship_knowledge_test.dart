import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/core/life_period/planet_relationship_matrix.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge.dart';
import 'package:knowme/features/astrology/thai/knowledge/planet_relationship_knowledge_importer.dart';

/// Thai Knowledge Importer V2 — Planet Relationship.
///
/// The knowledge base is now **data-driven**: records are loaded from
/// `knowledge/planet_relationships/planet_relationships.knowme.json` by
/// [PlanetRelationshipKnowledgeImporter] — there are no hardcoded records. These
/// tests prove the canonical data imports cleanly and stays consistent with the
/// frozen [PlanetRelationshipMatrix], plus exercise the importer's validation.
String _readKnowme() =>
    File('knowledge/planet_relationships/planet_relationships.knowme.json')
        .readAsStringSync();

void main() {
  group('Canonical knowledge import (planet_relationships.knowme.json)', () {
    late PlanetRelationshipImportResult result;

    setUpAll(() {
      result = PlanetRelationshipKnowledgeImporter.importJson(_readKnowme());
    });

    test('imports without errors or warnings', () {
      expect(result.ok, isTrue, reason: result.errors.join('\n'));
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty, reason: result.warnings.join('\n'));
    });

    test('covers exactly the 56 directed inter-planet pairs', () {
      expect(result.knowledge.records.length, 56);
      final seen = <String>{};
      for (final r in result.knowledge.records) {
        expect(seen.add('${r.from.name}->${r.to.name}'), isTrue);
        expect(r.from == r.to, isFalse);
      }
    });

    test('every record agrees with the frozen matrix (no drift)', () {
      for (final from in LifePlanet.values) {
        for (final to in LifePlanet.values) {
          if (from == to) continue;
          final record = result.knowledge.recordFor(from, to);
          expect(record, isNotNull,
              reason: 'missing ${from.name}->${to.name}');
          expect(record!.relation, PlanetRelationshipMatrix.relation(from, to));
        }
      }
    });

    test('honest seeded state: every record unknown/unverified', () {
      for (final r in result.knowledge.records) {
        expect(r.status, PlanetRelationshipStatus.unknown);
        expect(r.verified, isFalse);
        expect(r.school, PlanetRelationshipSchool.unknown);
        expect(r.confidence, PlanetRelationshipConfidence.none);
        expect(r.sourceName, 'Unknown');
      }
    });

    test('coverage report matches the frozen matrix', () {
      final c = result.coverage;
      expect(c.total, 56);
      expect(c.friend, 22);
      expect(c.enemy, 16);
      expect(c.neutral, 18);
      expect(c.unknown, 56); // status = unknown
      expect(c.verified, 0);
      expect(c.verifiedPercent, 0);
    });
  });

  group('Importer validation', () {
    Map<String, dynamic> rec({
      String from = 'sun',
      String to = 'moon',
      String relation = 'friend',
      String school = 'unknown',
      String confidence = 'none',
      String status = 'unknown',
      Object? verified = false,
    }) =>
        {
          'from': from,
          'to': to,
          'relation': relation,
          'school': school,
          'confidence': confidence,
          'status': status,
          'verified': verified,
        };

    bool hasCode(PlanetRelationshipImportResult r, String code) =>
        r.issues.any((i) => i.code == code);

    test('missing required field is an error', () {
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [
          {'from': 'sun', 'to': 'moon', 'relation': 'friend'},
        ],
      }, checkMatrix: false);
      expect(r.ok, isFalse);
      expect(hasCode(r, 'missing_field'), isTrue);
    });

    test('unknown enum value is an error', () {
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [rec(relation: 'frenemy')],
      }, checkMatrix: false);
      expect(r.ok, isFalse);
      expect(hasCode(r, 'unknown_enum'), isTrue);
    });

    test('duplicate (from,to) is an error', () {
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [rec(), rec()],
      }, checkMatrix: false);
      expect(hasCode(r, 'duplicate'), isTrue);
      expect(r.knowledge.records.length, 1);
    });

    test('self-pair is a broken reference', () {
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [rec(from: 'sun', to: 'sun')],
      }, checkMatrix: false);
      expect(hasCode(r, 'broken_reference'), isTrue);
    });

    test('relation disagreeing with the frozen matrix is a warning', () {
      // sun->venus is enemy in the matrix; assert friend.
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [rec(from: 'sun', to: 'venus', relation: 'friend')],
      });
      expect(hasCode(r, 'matrix_mismatch'), isTrue);
      expect(r.warnings, isNotEmpty);
      expect(r.ok, isTrue); // mismatch is a warning, not an error
    });

    test('incomplete coverage is a warning', () {
      final r = PlanetRelationshipKnowledgeImporter.importMap({
        'relationships': [rec()],
      }, checkMatrix: false);
      expect(hasCode(r, 'missing_coverage'), isTrue);
    });

    test('invalid JSON / shape is a schema error', () {
      final bad = PlanetRelationshipKnowledgeImporter.importJson('not json');
      expect(bad.ok, isFalse);
      expect(hasCode(bad, 'schema'), isTrue);

      final noArray =
          PlanetRelationshipKnowledgeImporter.importMap({'relationships': 42});
      expect(noArray.ok, isFalse);
      expect(hasCode(noArray, 'schema'), isTrue);
    });
  });
}
