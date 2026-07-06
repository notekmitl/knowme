import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/integration/integration.dart';

/// Post-Freeze Patch 002 — Monday Taksa rotation Canon import guards.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiCanonEvidenceRepository repository;

  setUpAll(() async {
    repository = await ThaiCanonEvidenceRepository.loadFromAsset();
  });

  const expectedMonday = {
    'planet.sun': 'taksaRole.kalakini',
    'planet.moon': 'taksaRole.boriwan',
    'planet.mars': 'taksaRole.ayu',
    'planet.mercury': 'taksaRole.det',
    'planet.jupiter': 'taksaRole.mula',
    'planet.venus': 'taksaRole.montri',
    'planet.saturn': 'taksaRole.sri',
    'planet.rahu': 'taksaRole.utsaha',
  };

  group('Patch 002 Canon import', () {
    test('atomic unit count is 834 after Patch 002', () {
      expect(repository.atomicCount, 834);
    });

    test('adds exactly 8 Monday recovered assignments', () {
      final mondayUnits = repository.index.units
          .where((u) => u.id.startsWith('taksa.p38.monday.'))
          .toList();
      expect(mondayUnits.length, 8);
      final byPlanet = {
        for (final u in mondayUnits) u.subject: u.object,
      };
      expect(byPlanet, expectedMonday);
    });

    test('every Monday unit has provenance', () {
      final mondayUnits = repository.index.units
          .where((u) => u.id.startsWith('taksa.p38.monday.'));
      for (final u in mondayUnits) {
        expect(u.evidence.bookId, 'mahabhut');
        expect(u.evidence.page, '38');
        expect(u.evidence.locator, isNotEmpty);
        expect(u.context?.type.name, 'taksaChart');
        expect(u.context?.value, 'คนเกิดวันจันทร์');
        expect(u.relation, AtomicRelation.locatedIn);
      }
    });

    test('no Sunday partial unit is imported', () {
      final sundayRotation = repository.index.units.where(
        (u) =>
            u.relation == AtomicRelation.locatedIn &&
            u.object.startsWith('taksaRole.') &&
            (u.context?.value == 'คนเกิดวันอาทิตย์'),
      );
      expect(sundayRotation, isEmpty);
    });

    test('no Wednesday daytime unit is imported', () {
      expect(
        repository.index.units.any(
          (u) => u.context?.value == 'คนเกิดวันพุธกลางวัน',
        ),
        isFalse,
      );
    });

    test('no Wednesday night / Rahu unit is imported', () {
      expect(
        repository.index.units.any(
          (u) =>
              (u.context?.value ?? '').contains('พุธกลางคืน') ||
              (u.context?.value ?? '').contains('ราหู'),
        ),
        isFalse,
      );
    });

    test('no Thursday–Saturday rotation unit is imported', () {
      final rotation = repository.index.units.where(
        (u) =>
            u.relation == AtomicRelation.locatedIn &&
            u.subject.startsWith('planet.') &&
            u.object.startsWith('taksaRole.'),
      );
      for (final label in ['พฤหัส', 'ศุกร์', 'เสาร์']) {
        expect(
          rotation.any((u) => u.context?.value == 'คนเกิดวัน$label'),
          isFalse,
        );
      }
    });

    test('Tuesday assignments remain unchanged', () {
      final tuesdayUnits = repository.index.units
          .where((u) => u.id.startsWith('mahabhut.p38.') && u.id.endsWith('_tuesday_birth'))
          .toList();
      expect(tuesdayUnits.length, 8);
      for (final u in tuesdayUnits) {
        expect(u.context?.type.name, 'other');
        expect(u.context?.value, 'คนเกิดวันอังคาร');
      }
    });

    test('forensics artifact confirms only Monday patchReady', () {
      final raw = File(
        'tool/output/taksa_source_forensics_rotation_candidates.json',
      ).readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final candidates = (json['candidates'] as List).cast<Map<String, dynamic>>();
      final patchReady = candidates.where((c) => c['patchReady'] == true).toList();
      expect(patchReady.length, 1);
      expect(patchReady.single['weekdayCase'], 'คนเกิดวันจันทร์');
    });
  });
}
