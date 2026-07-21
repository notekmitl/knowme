import '../domain/global_confidence.dart';
import '../domain/global_core_themes.dart';
import '../domain/global_fusion_snapshot.dart';
import '../domain/global_lens_id.dart';
import 'global_fusion_golden_scenario.dart';

/// Scenario-specific expectations for Global Fusion golden validation.
abstract final class GlobalFusionGoldenExpectations {
  static List<String> verify(
    GlobalFusionGoldenScenario scenario,
    GlobalFusionSnapshot snapshot,
  ) {
    final issues = <String>[];

    issues.addAll(_verifyContract(snapshot));
    issues.addAll(switch (scenario) {
      GlobalFusionGoldenScenario.scenarioA => _scenarioA(snapshot),
      GlobalFusionGoldenScenario.scenarioB => _scenarioB(snapshot),
      GlobalFusionGoldenScenario.scenarioC => _scenarioC(snapshot),
      GlobalFusionGoldenScenario.scenarioD => _scenarioD(snapshot),
      GlobalFusionGoldenScenario.scenarioE => _scenarioE(snapshot),
      GlobalFusionGoldenScenario.scenarioF => _scenarioF(snapshot),
    });

    return issues;
  }

  static List<String> _verifyContract(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.version.isEmpty) {
      issues.add('snapshot.version must not be empty');
    }
    if (snapshot.confidence.formulaVersion.isEmpty) {
      issues.add('confidence.formulaVersion must not be empty');
    }
    if (snapshot.confidence.formulaVersion != GlobalConfidence.v1FormulaVersion) {
      issues.add('confidence must use global_confidence.v1');
    }
    if (snapshot.confidence.composite < 0 || snapshot.confidence.composite > 1) {
      issues.add('composite must be clamped to 0.0–1.0');
    }

    for (final themeId in snapshot.normalizedThemes.map((t) => t.globalThemeId)) {
      if (!GlobalThemeRegistry.contains(themeId)) {
        issues.add('unknown global theme id: $themeId');
      }
    }

    for (final activation in snapshot.normalizedThemes) {
      for (final evidence in activation.evidence) {
        if (evidence.sourceMirror != GlobalLensId.astrologyMirror &&
            evidence.sourceMirror != GlobalLensId.personalityMirror) {
          issues.add('evidence must reference a mirror lens only');
        }
      }
    }

    final agreementIds = snapshot.agreements.map((a) => a.id).toList();
    if (agreementIds.length != agreementIds.toSet().length) {
      issues.add('duplicate agreement ids detected');
    }

    final tensionIds = snapshot.tensions.map((t) => t.id).toList();
    if (tensionIds.length != tensionIds.toSet().length) {
      issues.add('duplicate tension ids detected');
    }

    return issues;
  }

  static List<String> _scenarioA(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (!snapshot.coverage.hasAstrology) {
      issues.add('scenarioA: astrology coverage must be available');
    }
    if (snapshot.coverage.hasPersonality) {
      issues.add('scenarioA: personality coverage must be absent');
    }
    if (snapshot.agreements.isNotEmpty) {
      issues.add('scenarioA: agreements must be empty');
    }
    if (snapshot.tensions.isNotEmpty) {
      issues.add('scenarioA: tensions must be empty');
    }

    return issues;
  }

  static List<String> _scenarioB(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.coverage.hasAstrology) {
      issues.add('scenarioB: astrology coverage must be absent');
    }
    if (!snapshot.coverage.hasPersonality) {
      issues.add('scenarioB: personality coverage must be available');
    }
    if (snapshot.agreements.isNotEmpty) {
      issues.add('scenarioB: agreements must be empty');
    }
    if (snapshot.tensions.isNotEmpty) {
      issues.add('scenarioB: tensions must be empty');
    }

    return issues;
  }

  static List<String> _scenarioC(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (!snapshot.coverage.hasBothMirrors) {
      issues.add('scenarioC: both mirrors must be available');
    }
    if (snapshot.agreements.isEmpty) {
      issues.add('scenarioC: expected at least one agreement');
    }
    if (snapshot.tensions.isNotEmpty) {
      issues.add('scenarioC: tensions must be empty');
    }
    if (!_hasAgreementOn(snapshot, GlobalThemeIds.structure)) {
      issues.add('scenarioC: expected structure agreement');
    }

    return issues;
  }

  static List<String> _scenarioD(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (!snapshot.coverage.hasBothMirrors) {
      issues.add('scenarioD: both mirrors must be available');
    }
    if (snapshot.agreements.isNotEmpty) {
      issues.add('scenarioD: agreements must be empty');
    }
    if (snapshot.tensions.isEmpty) {
      issues.add('scenarioD: expected at least one tension');
    }

    return issues;
  }

  static List<String> _scenarioE(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (!snapshot.coverage.hasBothMirrors) {
      issues.add('scenarioE: both mirrors must be available');
    }
    if (snapshot.agreements.isEmpty) {
      issues.add('scenarioE: expected at least one agreement');
    }
    if (snapshot.tensions.isEmpty) {
      issues.add('scenarioE: expected at least one tension');
    }

    return issues;
  }

  static List<String> _scenarioF(GlobalFusionSnapshot snapshot) {
    final issues = <String>[];

    if (snapshot.coverage.hasAnyMirror) {
      issues.add('scenarioF: no mirror coverage expected');
    }
    if (snapshot.normalizedThemes.isNotEmpty) {
      issues.add('scenarioF: normalized themes must be empty');
    }
    if (snapshot.agreements.isNotEmpty) {
      issues.add('scenarioF: agreements must be empty');
    }
    if (snapshot.tensions.isNotEmpty) {
      issues.add('scenarioF: tensions must be empty');
    }
    if (snapshot.confidence.coverageScore != 0.0) {
      issues.add('scenarioF: coverageScore must be 0');
    }

    return issues;
  }

  static bool _hasAgreementOn(GlobalFusionSnapshot snapshot, String themeId) {
    return snapshot.agreements.any((agreement) => agreement.themeId == themeId);
  }
}
