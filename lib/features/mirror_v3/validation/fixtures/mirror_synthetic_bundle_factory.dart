import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';
import 'package:knowme/features/astrology/thai/theme_v2/enums/thai_theme_category.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_contribution.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_score.dart';

import '../../contracts/knowme_mirror_identity_contract.dart';
import '../../engine/adapters/knowme_mirror_astrology_adapter.dart';
import '../../engine/adapters/knowme_mirror_personality_adapter.dart';
import '../../engine/models/knowme_mirror_engine_input.dart';
import '../../engine/models/knowme_mirror_theme_signal.dart';
import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../../models/knowme_mirror_lineage_chain.dart';
import '../../registry/knowme_mirror_registry_v0_1.dart';
import '../../engine/adapters/knowme_mirror_personality_adapter.dart';

/// Deterministic synthetic [KnowMeMirrorEngineInput] factory for population runs.
abstract final class MirrorSyntheticBundleFactory {
  static const _personalityThemes = [
    ('analytical', FusionCategory.thinkingStyle),
    ('structured', FusionCategory.thinkingStyle),
    ('expressive', FusionCategory.coreSelf),
    ('reserved', FusionCategory.coreSelf),
    ('supportive', FusionCategory.relationships),
    ('diplomatic', FusionCategory.relationships),
    ('responsive', FusionCategory.emotionalWorld),
    ('calm', FusionCategory.emotionalWorld),
    ('responsible', FusionCategory.workAndAmbition),
    ('reliable', FusionCategory.strengths),
    ('creative', FusionCategory.strengths),
    ('adaptable', FusionCategory.coreSelf),
  ];

  static const _astrologyCategories = [
    ThaiThemeCategory.coreSelf,
    ThaiThemeCategory.thinkingStyle,
    ThaiThemeCategory.emotionalWorld,
    ThaiThemeCategory.relationships,
    ThaiThemeCategory.workAmbition,
    ThaiThemeCategory.strengths,
    ThaiThemeCategory.growthAreas,
    ThaiThemeCategory.growthPath,
  ];

  static List<KnowMeMirrorEngineInput> buildCases(int count) {
    return List<KnowMeMirrorEngineInput>.generate(
      count,
      (index) => buildCase(index),
      growable: false,
    );
  }

  static KnowMeMirrorEngineInput buildCase(int caseIndex) {
    final profile = _profileForCase(caseIndex);
    final signals = <KnowMeMirrorThemeSignal>[];

    if (profile.includeAstrology) {
      signals.addAll(
        KnowMeMirrorAstrologyAdapter.extract(
          _astrologyBundle(caseIndex, profile),
        ),
      );
    }

    if (profile.includeMbti) {
      signals.addAll(_personalitySignals(caseIndex, profile, 'mbti'));
    }

    if (profile.includeBigFive) {
      signals.addAll(_personalitySignals(caseIndex, profile, 'big_five'));
    }

    if (profile.includeEq) {
      signals.addAll(_personalitySignals(caseIndex, profile, 'eq'));
    }

    final lineage = _lineage(caseIndex, profile);

    return KnowMeMirrorEngineInput(
      lineage: lineage,
      signals: signals,
      generatedAt: DateTime.utc(2026, 1, 1).add(Duration(hours: caseIndex)),
    );
  }

  static _SyntheticProfile _profileForCase(int caseIndex) {
    final mode = caseIndex % 12;
    return switch (mode) {
      0 => const _SyntheticProfile(includeAstrology: true),
      1 => const _SyntheticProfile(includeMbti: true),
      2 => const _SyntheticProfile(includeAstrology: true, includeMbti: true),
      3 => const _SyntheticProfile(
          includeAstrology: true,
          includeMbti: true,
          includeBigFive: true,
        ),
      4 => const _SyntheticProfile(
          includeAstrology: true,
          includeMbti: true,
          includeBigFive: true,
          includeEq: true,
        ),
      5 => const _SyntheticProfile(includeBigFive: true),
      6 => const _SyntheticProfile(includeEq: true),
      7 => const _SyntheticProfile(includeMbti: true, includeBigFive: true),
      8 => const _SyntheticProfile(includeAstrology: true, includeEq: true),
      9 => const _SyntheticProfile(
          includeAstrology: true,
          includeMbti: true,
          themeOffset: 4,
          multiFactEvidence: true,
        ),
      10 => const _SyntheticProfile(
          includeAstrology: true,
          includeMbti: true,
          themeOffset: 8,
          opposingThemes: true,
        ),
      _ => const _SyntheticProfile(
          includeAstrology: true,
          includeMbti: true,
          includeBigFive: true,
          themeOffset: 2,
          multiFactEvidence: true,
        ),
    };
  }

  static ThaiThemeBundle _astrologyBundle(int caseIndex, _SyntheticProfile profile) {
    final themeCount = 1 + (caseIndex % 4);
    final themes = <ThaiThemeScore>[];

    for (var i = 0; i < themeCount; i++) {
      final category = _astrologyCategories[(caseIndex + i) % _astrologyCategories.length];
      final factCount = profile.multiFactEvidence ? 2 + (i % 2) : 1;
      final contributions = List<ThaiThemeContribution>.generate(
        factCount,
        (factIndex) => ThaiThemeContribution(
          sourceFactId: 'fact-$caseIndex-$i-$factIndex',
          contentKey: 'thai.${category.id}.$factIndex',
          contribution: 0.4 + (factIndex * 0.1),
        ),
        growable: false,
      );

      themes.add(
        ThaiThemeScore(
          themeId: 'theme_${category.id}_$i',
          category: category,
          score: 0.55 + ((caseIndex + i) % 5) * 0.08,
          confidence: ThaiThemeConfidenceLevel.values[(caseIndex + i) % 3],
          rank: i + 1,
          contributions: contributions,
        ),
      );
    }

    return ThaiThemeBundle(
      bundleId: 'synthetic-theme-$caseIndex',
      sourceInterpretationBundleId: 'synthetic-interp-$caseIndex',
      generatedAt: DateTime.utc(2026, 1, 1).add(Duration(hours: caseIndex)),
      themes: themes,
    );
  }

  static List<KnowMeMirrorThemeSignal> _personalitySignals(
    int caseIndex,
    _SyntheticProfile profile,
    String lensKey,
  ) {
    final systemId = switch (lensKey) {
      'mbti' => KnowMeMirrorSystemId.mbti,
      'big_five' => KnowMeMirrorSystemId.bigFive,
      _ => KnowMeMirrorSystemId.eq,
    };
    final sourceType = switch (lensKey) {
      'mbti' => KnowMeMirrorSourceType.mbtiTheme,
      'big_five' => KnowMeMirrorSourceType.bigFiveTheme,
      _ => KnowMeMirrorSourceType.eqTheme,
    };

    final themeCount = profile.opposingThemes ? 2 : 1 + (caseIndex % 3);
    final themes = <PersonalityThemeInput>[];

    for (var i = 0; i < themeCount; i++) {
      final pick = _personalityThemes[
          (profile.themeOffset + caseIndex + i) % _personalityThemes.length];
      themes.add(
        PersonalityThemeInput(
          themeId: pick.$1,
          category: pick.$2,
          confidence: 0.5 + ((caseIndex + i) % 4) * 0.1,
          prominence: 0.6 + ((caseIndex + i) % 3) * 0.1,
          evidenceCount: profile.multiFactEvidence ? 2 + (i % 2) : 1,
        ),
      );
    }

    return KnowMeMirrorPersonalityAdapter.extractThemes(
      systemId: systemId,
      sourceType: sourceType,
      sourceLensKey: lensKey,
      sourceSnapshotId: 'synthetic-$lensKey-$caseIndex',
      themes: themes,
    );
  }

  static KnowMeMirrorLineageChain _lineage(int caseIndex, _SyntheticProfile profile) {
    final astrologyId =
        profile.includeAstrology ? 'synthetic-theme-$caseIndex' : null;
    final mbtiId = profile.includeMbti ? 'synthetic-mbti-$caseIndex' : null;
    final bigFiveId =
        profile.includeBigFive ? 'synthetic-big_five-$caseIndex' : null;
    final eqId = profile.includeEq ? 'synthetic-eq-$caseIndex' : null;

    final scopeId = KnowMeMirrorIdentityContract.mirrorScopeId(
      astrologyThemeSnapshotId: astrologyId,
      mbtiLensSnapshotId: mbtiId,
      bigFiveLensSnapshotId: bigFiveId,
      eqLensSnapshotId: eqId,
    );

    return KnowMeMirrorLineageChain(
      mirrorScopeId: scopeId,
      astrologyThemeSnapshotId: astrologyId,
      astrologyThemeBundleId: astrologyId,
      mbtiLensSnapshotId: mbtiId,
      bigFiveLensSnapshotId: bigFiveId,
      eqLensSnapshotId: eqId,
      personalityOnly: !profile.includeAstrology,
      sourceSnapshotVersions: {
        if (profile.includeAstrology) 'thai_astrology': 'synthetic_v1',
        if (profile.includeMbti) 'mbti': 'synthetic_v1',
        if (profile.includeBigFive) 'big_five': 'synthetic_v1',
        if (profile.includeEq) 'eq': 'synthetic_v1',
      },
    );
  }

  /// Cases designed for confidence monotonicity checks.
  static KnowMeMirrorEngineInput confidenceCaseOneLens(int seed) {
    return buildCase(seed * 12);
  }

  static KnowMeMirrorEngineInput confidenceCaseTwoLens(int seed) {
    return buildCase(seed * 12 + 2);
  }

  static KnowMeMirrorEngineInput confidenceCaseThreeLens(int seed) {
    return buildCase(seed * 12 + 3);
  }

  static Iterable<String> allRegistryKeys() =>
      KnowMeMirrorRegistryV01.entries.map((entry) => entry.mirrorKey);
}

class _SyntheticProfile {
  const _SyntheticProfile({
    this.includeAstrology = false,
    this.includeMbti = false,
    this.includeBigFive = false,
    this.includeEq = false,
    this.themeOffset = 0,
    this.multiFactEvidence = false,
    this.opposingThemes = false,
  });

  final bool includeAstrology;
  final bool includeMbti;
  final bool includeBigFive;
  final bool includeEq;
  final int themeOffset;
  final bool multiFactEvidence;
  final bool opposingThemes;
}
