import '../domain/global_confidence.dart';
import '../domain/global_confidence_band.dart';
import '../domain/global_confidence_band.dart';
import '../domain/global_fusion_snapshot.dart';
import 'global_confidence_golden_scenario.dart';

/// Scenario expectations for Global Confidence v1 golden validation.
abstract final class GlobalConfidenceGoldenExpectations {
  static List<String> verify(
    GlobalConfidenceGoldenScenario scenario,
    GlobalFusionSnapshot snapshot,
  ) {
    final issues = <String>[];

    issues.addAll(_verifyContract(snapshot));
    issues.addAll(switch (scenario) {
      GlobalConfidenceGoldenScenario.noMirrors => _noMirrors(snapshot),
      GlobalConfidenceGoldenScenario.oneMirror => _oneMirror(snapshot),
      GlobalConfidenceGoldenScenario.twoMirrorsNoAgreement =>
        _twoMirrorsNoAgreement(snapshot),
      GlobalConfidenceGoldenScenario.oneStrongAgreement =>
        _oneStrongAgreement(snapshot),
      GlobalConfidenceGoldenScenario.manyAgreements =>
        _manyAgreements(snapshot),
      GlobalConfidenceGoldenScenario.agreementsWithTensions =>
        _agreementsWithTensions(snapshot),
      GlobalConfidenceGoldenScenario.heavyTensions =>
        _heavyTensions(snapshot),
    });

    return issues;
  }

  static List<String> _verifyContract(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.confidence.formulaVersion != GlobalConfidence.v1FormulaVersion) {
      issues.add('confidence must use global_confidence.v1');
    }
    if (snapshot.confidence.composite < 0 || snapshot.confidence.composite > 1) {
      issues.add('composite must be clamped to 0.0–1.0');
    }
    if (GlobalConfidenceBands.bandFor(snapshot.confidence.composite) !=
        snapshot.confidence.band) {
      issues.add('confidence band mismatch with composite score');
    }

    return issues;
  }

  static List<String> _noMirrors(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.confidence.band != GlobalConfidenceBand.low) {
      issues.add('noMirrors: expected low band');
    }
    if (snapshot.confidence.composite != 0.0) {
      issues.add('noMirrors: expected composite 0.0');
    }

    return issues;
  }

  static List<String> _oneMirror(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.confidence.band != GlobalConfidenceBand.medium) {
      issues.add('oneMirror: expected medium band');
    }
    if (snapshot.confidence.coverageScore != 0.5) {
      issues.add('oneMirror: expected coverageScore 0.5');
    }

    return issues;
  }

  static List<String> _twoMirrorsNoAgreement(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (!snapshot.coverage.hasBothMirrors) {
      issues.add('twoMirrorsNoAgreement: both mirrors required');
    }
    if (snapshot.agreements.isNotEmpty) {
      issues.add('twoMirrorsNoAgreement: agreements must be empty');
    }
    if (snapshot.confidence.band != GlobalConfidenceBand.medium) {
      issues.add('twoMirrorsNoAgreement: expected medium band');
    }
    if (snapshot.confidence.coverageContribution != 0.5) {
      issues.add('twoMirrorsNoAgreement: expected coverageContribution 0.5');
    }

    return issues;
  }

  static List<String> _oneStrongAgreement(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.agreements.isEmpty) {
      issues.add('oneStrongAgreement: expected at least one agreement');
    }
    if (snapshot.confidence.band != GlobalConfidenceBand.high) {
      issues.add('oneStrongAgreement: expected high band');
    }
    if (snapshot.confidence.composite < GlobalConfidenceBands.highMin) {
      issues.add('oneStrongAgreement: composite below high threshold');
    }

    return issues;
  }

  static List<String> _manyAgreements(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.agreements.length < 2) {
      issues.add('manyAgreements: expected multiple agreements');
    }
    if (snapshot.confidence.band != GlobalConfidenceBand.high) {
      issues.add('manyAgreements: expected high band');
    }

    return issues;
  }

  static List<String> _agreementsWithTensions(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.agreements.isEmpty || snapshot.tensions.isEmpty) {
      issues.add('agreementsWithTensions: expected both agreements and tensions');
    }
    if (snapshot.confidence.composite >= 0.95) {
      issues.add(
        'agreementsWithTensions: expected reduced composite from tension penalties',
      );
    }

    return issues;
  }

  static List<String> _heavyTensions(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.agreements.isNotEmpty) {
      issues.add('heavyTensions: agreements must be empty');
    }
    if (snapshot.tensions.length < 2) {
      issues.add('heavyTensions: expected multiple tensions');
    }
    if (snapshot.confidence.composite >= 0.5) {
      issues.add('heavyTensions: expected composite below agreement-only baseline');
    }

    return issues;
  }
}

/// Cross-scenario confidence comparisons for GF-F2 validation.
abstract final class GlobalConfidenceGoldenComparisons {
  static List<String> verify(GlobalFusionSnapshot agreementOnly,
      GlobalFusionSnapshot mixed) {
    final issues = <String>[];

    if (mixed.confidence.composite >= agreementOnly.confidence.composite) {
      issues.add('mixed scenario should have lower composite than agreement-only');
    }
    if (mixed.confidence.tensionPenalty <= agreementOnly.confidence.tensionPenalty) {
      issues.add('mixed scenario should carry higher tension penalty');
    }

    return issues;
  }
}
