import '../application/global_fusion_builder.dart';
import '../application/global_fusion_input_loader.dart';
import '../application/narrative/global_narrative_builder.dart';
import '../domain/global_reflection_unit.dart';
import 'global_confidence_golden_fixtures.dart';
import 'global_confidence_golden_scenario.dart';
import 'global_fusion_golden_fixtures.dart';
import 'global_narrative_golden_scenario.dart';

/// Scenario expectations for Global Narrative golden validation.
abstract final class GlobalNarrativeGoldenExpectations {
  static List<String> verify(
    GlobalNarrativeGoldenScenario scenario,
    List<GlobalReflectionUnit> reflections,
  ) {
    return switch (scenario) {
      GlobalNarrativeGoldenScenario.emptyState => _emptyState(reflections),
      GlobalNarrativeGoldenScenario.themeOnly => _themeOnly(reflections),
      GlobalNarrativeGoldenScenario.agreementOnly => _agreementOnly(reflections),
      GlobalNarrativeGoldenScenario.tensionOnly => _tensionOnly(reflections),
      GlobalNarrativeGoldenScenario.mixedState => _mixedState(reflections),
    };
  }

  static List<String> _verifyCopyQuality(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];
    const forbidden = [
      'You are',
      'You always',
      'You must',
      'คุณเป็น',
      'คุณต้อง',
      'คุณจะ',
      'โชคชะตา',
    ];

    for (final unit in reflections) {
      if (unit.reflection.trim().isEmpty) {
        issues.add('reflection must not be empty for ${unit.themeId}');
      }
      if (unit.evidenceSummary.trim().isEmpty) {
        issues.add('evidenceSummary must not be empty for ${unit.themeId}');
      }
      for (final phrase in forbidden) {
        if (unit.reflection.contains(phrase)) {
          issues.add('forbidden phrase in reflection: $phrase');
        }
      }
    }

    return issues;
  }

  static List<String> _emptyState(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];
    if (reflections.isNotEmpty) {
      issues.add('emptyState: expected no reflection units');
    }
    return issues;
  }

  static List<String> _themeOnly(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];

    if (reflections.isEmpty) {
      issues.add('themeOnly: expected theme reflections');
    }
    if (!_anyEvidenceSummaryContains(reflections, 'ธีม')) {
      issues.add('themeOnly: expected theme evidence summaries');
    }
    issues.addAll(_verifyCopyQuality(reflections));

    return issues;
  }

  static List<String> _agreementOnly(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];

    if (reflections.isEmpty) {
      issues.add('agreementOnly: expected reflections');
    }
    if (!_anyReflectionContains(reflections, 'หลายมุมสะท้อน')) {
      issues.add('agreementOnly: expected agreement-style reflections');
    }
    if (!_anyEvidenceSummaryContains(reflections, 'ข้อตกลงข้ามมิเรอร์')) {
      issues.add('agreementOnly: expected agreement evidence summaries');
    }
    issues.addAll(_verifyCopyQuality(reflections));

    return issues;
  }

  static List<String> _tensionOnly(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];

    if (reflections.isEmpty) {
      issues.add('tensionOnly: expected reflections');
    }
    if (!_anyReflectionContains(reflections, 'บางมุมสะท้อน')) {
      issues.add('tensionOnly: expected tension-style reflections');
    }
    if (!_anyEvidenceSummaryContains(reflections, 'ความต่างระหว่าง')) {
      issues.add('tensionOnly: expected tension evidence summaries');
    }
    issues.addAll(_verifyCopyQuality(reflections));

    return issues;
  }

  static List<String> _mixedState(List<GlobalReflectionUnit> reflections) {
    final issues = <String>[];

    if (reflections.length < 3) {
      issues.add('mixedState: expected multiple reflection units');
    }
    if (!_anyEvidenceSummaryContains(reflections, 'ข้อตกลงข้ามมิเรอร์')) {
      issues.add('mixedState: expected agreement reflections');
    }
    if (!_anyEvidenceSummaryContains(reflections, 'ความต่างระหว่าง')) {
      issues.add('mixedState: expected tension reflections');
    }
    issues.addAll(_verifyCopyQuality(reflections));

    return issues;
  }

  static bool _anyReflectionContains(
    List<GlobalReflectionUnit> reflections,
    String phrase,
  ) {
    return reflections.any((unit) => unit.reflection.contains(phrase));
  }

  static bool _anyEvidenceSummaryContains(
    List<GlobalReflectionUnit> reflections,
    String phrase,
  ) {
    return reflections.any((unit) => unit.evidenceSummary.contains(phrase));
  }
}

/// Runs Global Narrative golden scenarios.
abstract final class GlobalNarrativeValidationHarness {
  static const _loader = GlobalFusionInputLoader();

  static List<GlobalReflectionUnit> run(GlobalNarrativeGoldenScenario scenario) {
    final pair = switch (scenario) {
      GlobalNarrativeGoldenScenario.emptyState =>
        GlobalFusionGoldenFixtures.scenarioF(),
      GlobalNarrativeGoldenScenario.themeOnly =>
        GlobalFusionGoldenFixtures.scenarioA(),
      GlobalNarrativeGoldenScenario.agreementOnly =>
        GlobalFusionGoldenFixtures.scenarioC(),
      GlobalNarrativeGoldenScenario.tensionOnly =>
        GlobalFusionGoldenFixtures.scenarioD(),
      GlobalNarrativeGoldenScenario.mixedState =>
        GlobalConfidenceGoldenFixtures.load(
          GlobalConfidenceGoldenScenario.agreementsWithTensions,
        ),
    };

    final input = _loader.load(
      astrologySnapshot: pair.astrology,
      personalitySnapshot: pair.personality,
    );
    final snapshot = GlobalFusionBuilder.build(input);
    return GlobalNarrativeBuilder.fromSnapshot(snapshot);
  }

  static bool verifyScenario(GlobalNarrativeGoldenScenario scenario) {
    final reflections = run(scenario);
    return GlobalNarrativeGoldenExpectations.verify(scenario, reflections)
        .isEmpty;
  }

  static bool runAllPassing() {
    return GlobalNarrativeGoldenScenario.values.every(verifyScenario);
  }
}
