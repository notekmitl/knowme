import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import '../../domain/personality_confidence.dart';
import '../../domain/personality_core_themes.dart';
import '../../domain/personality_lens_evidence.dart';
import '../../domain/personality_lens_id.dart';
import '../../domain/personality_lens_snapshot.dart';
import '../../domain/personality_lens_theme_output.dart';
import '../../domain/personality_mirror_constants.dart';
import '../../domain/personality_theme_activation.dart';
import '../personality_theme_output_builder.dart';

/// Maps [MbtiResultSummary] → [PersonalityLensSnapshot].
abstract final class MbtiPersonalityLensAdapter {
  static PersonalityLensSnapshot map(MbtiResultSummary? result) {
    if (result == null) {
      return PersonalityLensSnapshot.unavailable(PersonalityLensId.mbti);
    }

    final sourceVersion = PersonalitySourceVersionMeta(
      scoredQuestionCount: result.scoredQuestionCount,
      scoringVersion: result.scoringVersion,
      depthTier: _depthTierLabel(result.scoredQuestionCount),
      resultScoredAt: result.scoredAt,
    );

    final lensConfidence = _lensConfidence(result.scoredQuestionCount);
    final themes = <PersonalityLensThemeOutput>[];

    void addAxisThemes({
      required String poleA,
      required String poleB,
      required String themeIfA,
      required String themeIfB,
      required String rulePrefix,
    }) {
      final ratio = _dominanceRatio(result.dimensions, poleA, poleB);
      if (ratio >= PersonalityMirrorThresholds.mbtiAxisDominanceMin) {
        final output = PersonalityThemeOutputBuilder.build(
          lensId: PersonalityLensId.mbti,
          themeId: themeIfA,
          activation: PersonalityThemeActivation.supportive,
          confidence: lensConfidence * _axisClarity(ratio),
          evidence: [
            PersonalityLensEvidence(
              sourceField: 'dimensions.$poleA',
              sourceValue: 'dominant',
              ruleId: '$rulePrefix.$themeIfA',
              weight: 1.0,
            ),
          ],
          sourceVersion: sourceVersion,
        );
        if (output != null) themes.add(output);
        return;
      }

      final inverse = 1 - ratio;
      if (inverse >= PersonalityMirrorThresholds.mbtiAxisDominanceMin) {
        final output = PersonalityThemeOutputBuilder.build(
          lensId: PersonalityLensId.mbti,
          themeId: themeIfB,
          activation: PersonalityThemeActivation.supportive,
          confidence: lensConfidence * _axisClarity(inverse),
          evidence: [
            PersonalityLensEvidence(
              sourceField: 'dimensions.$poleB',
              sourceValue: 'dominant',
              ruleId: '$rulePrefix.$themeIfB',
              weight: 1.0,
            ),
          ],
          sourceVersion: sourceVersion,
        );
        if (output != null) themes.add(output);
      }
    }

    addAxisThemes(
      poleA: 'E',
      poleB: 'I',
      themeIfA: PersonalityCoreThemeIds.expressive,
      themeIfB: PersonalityCoreThemeIds.reserved,
      rulePrefix: 'mbti.ei',
    );
    addAxisThemes(
      poleA: 'S',
      poleB: 'N',
      themeIfA: PersonalityCoreThemeIds.structured,
      themeIfB: PersonalityCoreThemeIds.intuitive,
      rulePrefix: 'mbti.sn',
    );
    addAxisThemes(
      poleA: 'T',
      poleB: 'F',
      themeIfA: PersonalityCoreThemeIds.analytical,
      themeIfB: PersonalityCoreThemeIds.supportive,
      rulePrefix: 'mbti.tf',
    );
    addAxisThemes(
      poleA: 'J',
      poleB: 'P',
      themeIfA: PersonalityCoreThemeIds.structured,
      themeIfB: PersonalityCoreThemeIds.flexible,
      rulePrefix: 'mbti.jp',
    );

    _addTypeOverlay(
      type: result.type,
      themes: themes,
      sourceVersion: sourceVersion,
      lensConfidence: lensConfidence,
    );

    return PersonalityLensSnapshot(
      lensId: PersonalityLensId.mbti,
      themes: themes,
      lensConfidence: lensConfidence,
      sourceVersion: sourceVersion,
      available: true,
    );
  }

  static void _addTypeOverlay({
    required String type,
    required List<PersonalityLensThemeOutput> themes,
    required PersonalitySourceVersionMeta sourceVersion,
    required PersonalityConfidence lensConfidence,
  }) {
    final upper = type.toUpperCase();
    if (upper.length < 4) return;

    final overlayRules = <String, String>{
      if (upper.contains('N') && upper.contains('T'))
        PersonalityCoreThemeIds.analytical: 'mbti.type.nt',
      if (upper.contains('N')) PersonalityCoreThemeIds.intuitive: 'mbti.type.n',
      if (upper.contains('S') && upper.contains('F'))
        PersonalityCoreThemeIds.supportive: 'mbti.type.sf',
      if (upper.contains('S')) PersonalityCoreThemeIds.grounded: 'mbti.type.s',
      if (upper.contains('J')) PersonalityCoreThemeIds.responsible: 'mbti.type.j',
      if (upper.contains('P')) PersonalityCoreThemeIds.adaptable: 'mbti.type.p',
    };

    for (final entry in overlayRules.entries) {
      if (themes.any((theme) => theme.themeId == entry.key)) continue;

      final output = PersonalityThemeOutputBuilder.build(
        lensId: PersonalityLensId.mbti,
        themeId: entry.key,
        activation: PersonalityThemeActivation.supportive,
        confidence: lensConfidence * 0.45,
        evidence: [
          PersonalityLensEvidence(
            sourceField: 'type',
            sourceValue: upper,
            ruleId: entry.value,
            weight: 0.45,
          ),
        ],
        sourceVersion: sourceVersion,
        ruleWeight: 0.45,
      );
      if (output != null) themes.add(output);
    }
  }

  static double _dominanceRatio(
    Map<String, double> dimensions,
    String poleA,
    String poleB,
  ) {
    final a = dimensions[poleA] ?? 0;
    final b = dimensions[poleB] ?? 0;
    final total = a + b;
    if (total <= 0) return 0.5;
    return a / total;
  }

  static double _axisClarity(double dominanceRatio) {
    return ((dominanceRatio - 0.5) * 2).clamp(0.35, 1.0);
  }

  static PersonalityConfidence _lensConfidence(int scoredQuestionCount) {
    if (scoredQuestionCount >= mbtiAccurateCheckpoint) return 0.85;
    if (scoredQuestionCount >= mbtiStandardCheckpoint) return 0.65;
    return 0.45;
  }

  static String _depthTierLabel(int scoredQuestionCount) {
    if (scoredQuestionCount >= mbtiAccurateCheckpoint) return 'accurate';
    if (scoredQuestionCount >= mbtiStandardCheckpoint) return 'standard';
    return 'mini';
  }
}
