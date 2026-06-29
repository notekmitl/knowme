import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/golden/golden.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/workspace/knowledge_diff.dart';

/// Canon Golden Dataset V1 — the QA regression suite for the Canon Platform.
/// Pure knowledge/QA layer; no engine/runtime/matrix/mirror/fusion.

void main() {
  final datasets = GoldenDatasets.all();

  test('catalog is non-empty and covers the required dataset types', () {
    final ids = datasets.map((d) => d.id).toSet();
    expect(ids, containsAll(<String>{
      'golden.minimal',
      'golden.single_planet',
      'golden.single_house',
      'golden.planet_house',
      'golden.conflict',
      'golden.duplicate',
      'golden.ontology_failure',
      'golden.relationship_failure',
      'golden.coverage_increase',
      'golden.deprecated',
    }));
  });

  group('Every dataset reproduces its expected outcome exactly', () {
    for (final d in datasets) {
      test(d.id, () {
        final v = GoldenVerifier.verify(d);
        expect(v.passed, isTrue,
            reason: v.mismatches.map((m) => m.toString()).join('\n'));
      });
    }
    test('catalog passes as a whole', () {
      expect(GoldenReport.catalogPasses(datasets), isTrue,
          reason: GoldenReport.forCatalog(datasets));
    });
  });

  group('Determinism', () {
    test('verification (actual + reports) is byte-for-byte deterministic', () {
      for (final d in datasets) {
        final a1 = GoldenVerifier.run(d);
        final a2 = GoldenVerifier.run(d);
        expect(a1.review.render(), a2.review.render());
        expect(GoldenReport.forDataset(d), GoldenReport.forDataset(d));
      }
      // The same catalog rebuilt twice yields the same catalog report.
      expect(GoldenReport.forCatalog(GoldenDatasets.all()),
          GoldenReport.forCatalog(GoldenDatasets.all()));
    });

    test('dataset versioning + fingerprint are deterministic', () {
      for (final a in datasets) {
        final b = GoldenDatasets.byId(a.id)!;
        expect(b.versionTag, a.versionTag);
        expect(b.fingerprint, a.fingerprint);
        expect(b.versionTag, '${a.id}@v${a.version}');
      }
      // Distinct datasets have distinct fingerprints.
      final prints = datasets.map((d) => d.fingerprint).toSet();
      expect(prints.length, datasets.length);
    });
  });

  group('Regression detection', () {
    test('a tampered expectation is detected as a mismatch', () {
      final good = GoldenDatasets.singlePlanet();
      final tampered = GoldenDataset(
        id: good.id,
        description: good.description,
        version: good.version,
        sourceType: good.sourceType,
        source: good.source,
        units: good.units,
        baseline: good.baseline,
        // Wrong expectation: claim 99 units / not ready / wrong diff.
        expected: const GoldenExpectation(
          unitCount: 99,
          allResolved: true,
          graphNodes: 4,
          graphEdges: 3,
          valid: false,
          errorCodes: {'bogus_code'},
          diff: {DiffKind.added: 1},
          readyForImport: false,
          totalUnitsDelta: 0,
          verifiedRelationshipsDelta: 0,
        ),
      );
      final v = GoldenVerifier.verify(tampered);
      expect(v.passed, isFalse);
      final fields = v.mismatches.map((m) => m.field).toSet();
      expect(fields, containsAll(<String>{
        'unitCount',
        'valid',
        'errorCodes',
        'diff.added',
        'readyForImport',
        'totalUnitsDelta',
      }));
    });

    test('a fingerprint changes when content changes (version bump)', () {
      final a = GoldenDatasets.minimal();
      final bumped = GoldenDataset(
        id: a.id,
        description: a.description,
        version: a.version + 1,
        sourceType: a.sourceType,
        source: a.source,
        units: a.units,
        baseline: a.baseline,
        expected: a.expected,
      );
      expect(bumped.fingerprint, isNot(a.fingerprint));
      expect(bumped.versionTag, isNot(a.versionTag));
    });
  });

  group('Reports', () {
    test('per-dataset report shows PASS and the import verdict', () {
      final report = GoldenReport.forDataset(GoldenDatasets.coverageIncrease());
      expect(report, contains('PASS'));
      expect(report, contains('Ready for import'));
      expect(GoldenReport.importReport(GoldenDatasets.conflict()),
          contains('readyForImport: false'));
    });
  });

  group('Decoupling — no runtime dependency', () {
    test('golden imports no engine/runtime/matrix/mirror/fusion/flutter', () {
      final dir =
          Directory('lib/features/astrology/thai/knowledge/canon/golden');
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
