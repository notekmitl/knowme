import '../domain/personality_agreement_kind.dart';
import '../domain/personality_confidence_breakdown.dart';
import '../domain/personality_core_themes.dart';
import '../domain/personality_mirror_constants.dart';
import '../domain/personality_mirror_snapshot.dart';
import 'personality_mirror_golden_scenario.dart';

/// Scenario-level assertions for golden validation.
abstract final class PersonalityMirrorGoldenExpectations {
  static List<String> verify(
    PersonalityMirrorGoldenScenario scenario,
    PersonalityMirrorSnapshot mirror,
    PersonalityConfidenceBreakdown confidence,
  ) {
    return switch (scenario) {
      PersonalityMirrorGoldenScenario.scenarioA => _scenarioA(mirror, confidence),
      PersonalityMirrorGoldenScenario.scenarioB => _scenarioB(mirror, confidence),
      PersonalityMirrorGoldenScenario.scenarioC => _scenarioC(mirror, confidence),
      PersonalityMirrorGoldenScenario.scenarioD => _scenarioD(mirror, confidence),
    };
  }

  static List<String> _scenarioA(
    PersonalityMirrorSnapshot mirror,
    PersonalityConfidenceBreakdown confidence,
  ) {
    final issues = <String>[];

    if (mirror.tensions.isNotEmpty) {
      issues.add('scenarioA: expected no tensions');
    }

    final themeAgreements = mirror.agreements
        .where((a) => a.kind == PersonalityAgreementKind.theme)
        .map((a) => a.themeId)
        .toSet();

    if (!themeAgreements.contains(PersonalityCoreThemeIds.structured)) {
      issues.add('scenarioA: missing structured theme agreement');
    }
    if (!themeAgreements.contains(PersonalityCoreThemeIds.responsible)) {
      issues.add('scenarioA: missing responsible theme agreement');
    }

    if (mirror.agreements.length < 2) {
      issues.add('scenarioA: expected multiple agreements');
    }

    if (confidence.agreementBoost <= 0) {
      issues.add('scenarioA: expected positive agreement boost');
    }

    if (confidence.compositeBand == 'low') {
      issues.add('scenarioA: expected confidence above low band');
    }

    if (mirror.coverage.weightedCoverage < 0.8) {
      issues.add('scenarioA: expected high coverage (mbti+bigFive)');
    }

    return issues;
  }

  static List<String> _scenarioB(
    PersonalityMirrorSnapshot mirror,
    PersonalityConfidenceBreakdown confidence,
  ) {
    final issues = <String>[];

    if (mirror.tensions.isEmpty) {
      issues.add('scenarioB: expected at least one tension');
    }

    final hasOpposing = mirror.tensions.any(
      (t) => t.reasonCode.contains('opposing_families'),
    );
    if (!hasOpposing) {
      issues.add('scenarioB: expected opposing_families tension');
    }

    final hasReservedExpressive = mirror.tensions.any(
      (t) =>
          t.themeIds.contains(PersonalityCoreThemeIds.reserved) &&
          t.themeIds.contains(PersonalityCoreThemeIds.expressive),
    );
    if (!hasReservedExpressive) {
      issues.add('scenarioB: expected reserved vs expressive tension');
    }

    if (confidence.contradictionPenalty <= 0) {
      issues.add('scenarioB: expected contradiction penalty');
    }

    return issues;
  }

  static List<String> _scenarioC(
    PersonalityMirrorSnapshot mirror,
    PersonalityConfidenceBreakdown confidence,
  ) {
    final issues = <String>[];

    if (mirror.coverage.hasBigFive || mirror.coverage.hasAnyEq) {
      issues.add('scenarioC: expected MBTI-only coverage');
    }

    if ((mirror.coverage.weightedCoverage - PersonalityMirrorWeights.mbti)
            .abs() >
        0.001) {
      issues.add('scenarioC: weighted coverage should equal MBTI weight only');
    }

    final crossLensThemeAgreements = mirror.agreements.where(
      (a) =>
          a.kind == PersonalityAgreementKind.theme &&
          a.supportingAgreementLenses.length >= 2,
    );
    if (crossLensThemeAgreements.isNotEmpty) {
      issues.add('scenarioC: no cross-lens theme agreement expected');
    }

    if (confidence.compositeBand != 'low') {
      issues.add(
        'scenarioC: expected low confidence band, got ${confidence.compositeBand}',
      );
    }

    if (confidence.compositeConfidence > 0.39) {
      issues.add('scenarioC: expected composite confidence <= 0.39');
    }

    return issues;
  }

  static List<String> _scenarioD(
    PersonalityMirrorSnapshot mirror,
    PersonalityConfidenceBreakdown confidence,
  ) {
    final issues = <String>[];

    if (!mirror.coverage.hasMbti ||
        !mirror.coverage.hasBigFive ||
        !mirror.coverage.hasAnyEq) {
      issues.add('scenarioD: expected mbti + bigFive + eq coverage');
    }

    if ((mirror.coverage.weightedCoverage - 1.0).abs() > 0.001) {
      issues.add('scenarioD: expected full weighted coverage');
    }

    final supportiveAgreement = mirror.agreements.any(
      (a) =>
          a.kind == PersonalityAgreementKind.theme &&
          a.themeId == PersonalityCoreThemeIds.supportive &&
          a.supportingAgreementLenses.length >= 3,
    );
    if (!supportiveAgreement) {
      issues.add('scenarioD: expected supportive theme across 3 lenses');
    }

    if (confidence.compositeBand != 'very_high') {
      issues.add(
        'scenarioD: expected very_high band, got ${confidence.compositeBand}',
      );
    }

    if (confidence.compositeConfidence < 0.85) {
      issues.add('scenarioD: expected composite >= 0.85');
    }

    if (confidence.agreementBoost < 0.2) {
      issues.add('scenarioD: expected substantial agreement boost');
    }

    return issues;
  }
}
