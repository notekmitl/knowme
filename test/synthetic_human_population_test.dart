import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'validation/synthetic_population/data/synthetic_human_archetype_catalog.dart';
import 'validation/synthetic_population/factory/synthetic_human_profile_factory.dart';
import 'validation/synthetic_population/models/synthetic_human_variant.dart';
import 'validation/synthetic_population/synthetic_population_report.dart';
import 'validation/synthetic_population/synthetic_population_runner.dart';

@Timeout(Duration(minutes: 5))
void main() {
  group('Synthetic Human Population V1', () {
    late SyntheticPopulationAudit audit;

    setUpAll(() {
      audit = SyntheticPopulationRunner.runAll();
      SyntheticPopulationReport.writeArtifacts(
        audit: audit,
        jsonPath:
            'test/validation/synthetic_population/output/results.json',
        markdownPath: 'docs/SYNTHETIC_HUMAN_POPULATION_V1.md',
      );
    });

    test('builds 50 archetypes × 4 variants = 200 profiles', () {
      final profiles = SyntheticHumanProfileFactory.buildAll();
      expect(profiles.length, 200);
      expect(SyntheticHumanArchetypeCatalog.all().length, 50);

      final archetypes = profiles.map((item) => item.archetypeId).toSet();
      expect(archetypes.length, 50);

      final variants = profiles.map((item) => item.variant).toSet();
      expect(variants.length, SyntheticHumanVariant.values.length);
    });

    test('runs full pipeline for entire population', () {
      expect(audit.records.length, 200);
      var fusionOutputCount = 0;
      for (final record in audit.records) {
        expect(record.astrologyMirrorSnapshot.evidence.isNotEmpty, isTrue);
        expect(record.personalityMirrorSnapshot.evidence.isNotEmpty, isTrue);
        expect(record.humanPatternSnapshot.activations.isNotEmpty, isTrue);
        expect(record.narrativeResult.paragraphCount, greaterThan(0));

        final fusion = record.globalFusionSnapshot;
        final hasFusionOutput = fusion.evidence.isNotEmpty ||
            fusion.agreements.isNotEmpty ||
            fusion.tensions.isNotEmpty ||
            fusion.reinforcements.isNotEmpty ||
            fusion.blindSpots.isNotEmpty;
        if (hasFusionOutput) fusionOutputCount++;
      }
      expect(fusionOutputCount, greaterThan(150));
    });

    test('produces diversity metrics across layers', () {
      expect(audit.diversity.populationSize, 200);
      expect(audit.diversity.uniqueMirrorOutcomes, greaterThan(1));
      expect(audit.diversity.uniqueFusionOutcomes, greaterThan(1));
      expect(audit.diversity.uniquePatternSets, greaterThan(1));
      expect(audit.diversity.uniqueNarrativeFingerprints, greaterThan(1));
    });

    test('writes validation artifacts', () {
      expect(
        File('test/validation/synthetic_population/output/results.json')
            .existsSync(),
        isTrue,
      );
      expect(
        File('docs/SYNTHETIC_HUMAN_POPULATION_V1.md').existsSync(),
        isTrue,
      );
    });

    test('audits identify coverage and dead zones', () {
      expect(audit.coverage.totalMirrorSignals, greaterThan(0));
      expect(audit.patternDistribution.registryPatternCount, greaterThan(0));
      expect(audit.recommendations, isNotEmpty);
    });
  });
}
