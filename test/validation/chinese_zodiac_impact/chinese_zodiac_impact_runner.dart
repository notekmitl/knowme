import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_bazi_adapter_bridge.dart';
import 'package:knowme/features/astrology/fusion/adapters/bazi_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/adapters/lens_theme_output.dart';
import 'package:knowme/features/astrology/fusion/adapters/western_real_adapter.dart';
import 'package:knowme/features/astrology/fusion/application/astrology_fusion_generator.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/astrology_fusion_result.dart';
import 'package:knowme/features/astrology/fusion/engines/agreement_engine.dart';
import 'package:knowme/features/astrology/fusion/registry/theme_registry.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_real_input.dart';
import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_model/domain/human_model_snapshot.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/human_pattern/domain/human_pattern_snapshot.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_mode.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';

import 'chinese_zodiac_core_only_adapter.dart';
import 'chinese_zodiac_impact_personality_baseline.dart';
import 'chinese_zodiac_impact_profiles.dart';
import 'chinese_zodiac_lens_mirror_bridge.dart';

/// Controlled comparison arm — BaZi core only vs BaZi core + Year Animal.
enum ChineseZodiacImpactArm {
  withoutZodiac('without_zodiac'),
  withZodiac('with_zodiac');

  const ChineseZodiacImpactArm(this.key);
  final String key;
}

/// Quantitative metrics for one profile arm.
class ChineseZodiacImpactMetrics {
  const ChineseZodiacImpactMetrics({
    required this.arm,
    required this.themeCount,
    required this.uniqueThemeIds,
    required this.fusionAgreements,
    required this.fusionTensions,
    required this.fusionSignals,
    required this.fusionGrowthOpportunities,
    required this.globalAgreements,
    required this.globalTensions,
    required this.globalReinforcements,
    required this.globalBlindSpots,
    required this.humanPatternCount,
    required this.humanActivationCount,
    required this.narrativeParagraphCount,
    required this.narrativeEvidenceCount,
    required this.narrativeConfidenceComposite,
    required this.narrativeByMode,
  });

  final ChineseZodiacImpactArm arm;
  final int themeCount;
  final List<String> uniqueThemeIds;
  final int fusionAgreements;
  final int fusionTensions;
  final int fusionSignals;
  final int fusionGrowthOpportunities;
  final int globalAgreements;
  final int globalTensions;
  final int globalReinforcements;
  final int globalBlindSpots;
  final int humanPatternCount;
  final int humanActivationCount;
  final int narrativeParagraphCount;
  final int narrativeEvidenceCount;
  final double narrativeConfidenceComposite;
  final Map<String, int> narrativeByMode;

  Map<String, dynamic> toJson() {
    return {
      'arm': arm.key,
      'themeCount': themeCount,
      'uniqueThemeIds': uniqueThemeIds,
      'fusionAgreements': fusionAgreements,
      'fusionTensions': fusionTensions,
      'fusionSignals': fusionSignals,
      'fusionGrowthOpportunities': fusionGrowthOpportunities,
      'globalAgreements': globalAgreements,
      'globalTensions': globalTensions,
      'globalReinforcements': globalReinforcements,
      'globalBlindSpots': globalBlindSpots,
      'humanPatternCount': humanPatternCount,
      'humanActivationCount': humanActivationCount,
      'narrativeParagraphCount': narrativeParagraphCount,
      'narrativeEvidenceCount': narrativeEvidenceCount,
      'narrativeConfidenceComposite': narrativeConfidenceComposite,
      'narrativeByMode': narrativeByMode,
    };
  }
}

/// Qualitative classification per profile.
enum ChineseZodiacQualitativeTier {
  none('NONE'),
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const ChineseZodiacQualitativeTier(this.label);
  final String label;
}

class ChineseZodiacQualitativeReview {
  const ChineseZodiacQualitativeReview({
    required this.tier,
    required this.newInformationCount,
    required this.duplicatedInformationCount,
    required this.contradictoryInformationCount,
    required this.netNewThemeIds,
    required this.collisionThemeIds,
    required this.notes,
  });

  final ChineseZodiacQualitativeTier tier;
  final int newInformationCount;
  final int duplicatedInformationCount;
  final int contradictoryInformationCount;
  final List<String> netNewThemeIds;
  final List<String> collisionThemeIds;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.label,
      'newInformationCount': newInformationCount,
      'duplicatedInformationCount': duplicatedInformationCount,
      'contradictoryInformationCount': contradictoryInformationCount,
      'netNewThemeIds': netNewThemeIds,
      'collisionThemeIds': collisionThemeIds,
      'notes': notes,
    };
  }
}

class ChineseZodiacProfileComparison {
  const ChineseZodiacProfileComparison({
    required this.profile,
    required this.withoutZodiac,
    required this.withZodiac,
    required this.qualitative,
    required this.themeCountDelta,
    required this.fusionAgreementDelta,
    required this.fusionTensionDelta,
    required this.globalAgreementDelta,
    required this.globalTensionDelta,
    required this.globalReinforcementDelta,
    required this.globalBlindSpotDelta,
    required this.patternCountDelta,
    required this.activationCountDelta,
    required this.narrativeParagraphDelta,
    required this.narrativeEvidenceDelta,
    required this.narrativeConfidenceDelta,
  });

  final ChineseZodiacImpactProfile profile;
  final ChineseZodiacImpactMetrics withoutZodiac;
  final ChineseZodiacImpactMetrics withZodiac;
  final ChineseZodiacQualitativeReview qualitative;
  final int themeCountDelta;
  final int fusionAgreementDelta;
  final int fusionTensionDelta;
  final int globalAgreementDelta;
  final int globalTensionDelta;
  final int globalReinforcementDelta;
  final int globalBlindSpotDelta;
  final int patternCountDelta;
  final int activationCountDelta;
  final int narrativeParagraphDelta;
  final int narrativeEvidenceDelta;
  final double narrativeConfidenceDelta;

  Map<String, dynamic> toJson() {
    return {
      'profileId': profile.profileId,
      'animalKey': profile.animalKey,
      'animalEn': profile.animalEn,
      'variant': profile.variant,
      'dayMasterLabel': profile.dayMasterLabel,
      'dominantElement': profile.dominantElement,
      'withoutZodiac': withoutZodiac.toJson(),
      'withZodiac': withZodiac.toJson(),
      'qualitative': qualitative.toJson(),
      'deltas': {
        'themeCount': themeCountDelta,
        'fusionAgreements': fusionAgreementDelta,
        'fusionTensions': fusionTensionDelta,
        'globalAgreements': globalAgreementDelta,
        'globalTensions': globalTensionDelta,
        'globalReinforcements': globalReinforcementDelta,
        'globalBlindSpots': globalBlindSpotDelta,
        'humanPatternCount': patternCountDelta,
        'humanActivationCount': activationCountDelta,
        'narrativeParagraphCount': narrativeParagraphDelta,
        'narrativeEvidenceCount': narrativeEvidenceDelta,
        'narrativeConfidenceComposite': narrativeConfidenceDelta,
      },
    };
  }
}

/// Runs controlled A/B comparisons across all validation profiles.
abstract final class ChineseZodiacImpactRunner {
  static final _generatedAt = DateTime.utc(2026, 6, 21, 12);

  static AstrologyChartModel _westernBaseline() {
    return AstrologyChartModel.fromMap({
      'big3': {
        'sun': 'Aries',
        'moon': 'Cancer',
        'rising': 'Leo',
      },
      'planets': {},
      'insight': {},
      'overall_summary': {},
    });
  }

  static List<ChineseZodiacProfileComparison> runAll() {
    final western = _westernBaseline();
    final personalityMirror = ChineseZodiacImpactPersonalityBaseline.mirror(
      generatedAt: _generatedAt,
    );

    return ChineseZodiacImpactProfiles.all().map((profile) {
      final without = _measureArm(
        profile: profile,
        arm: ChineseZodiacImpactArm.withoutZodiac,
        western: western,
        personalityMirror: personalityMirror,
      );
      final withZodiacMetrics = _measureArm(
        profile: profile,
        arm: ChineseZodiacImpactArm.withZodiac,
        western: western,
        personalityMirror: personalityMirror,
      );
      final qualitative = _qualitativeReview(
        profile: profile,
        without: without,
        withArm: withZodiacMetrics,
      );

      return ChineseZodiacProfileComparison(
        profile: profile,
        withoutZodiac: without,
        withZodiac: withZodiacMetrics,
        qualitative: qualitative,
        themeCountDelta: withZodiacMetrics.themeCount - without.themeCount,
        fusionAgreementDelta:
            withZodiacMetrics.fusionAgreements - without.fusionAgreements,
        fusionTensionDelta:
            withZodiacMetrics.fusionTensions - without.fusionTensions,
        globalAgreementDelta:
            withZodiacMetrics.globalAgreements - without.globalAgreements,
        globalTensionDelta:
            withZodiacMetrics.globalTensions - without.globalTensions,
        globalReinforcementDelta: withZodiacMetrics.globalReinforcements -
            without.globalReinforcements,
        globalBlindSpotDelta:
            withZodiacMetrics.globalBlindSpots - without.globalBlindSpots,
        patternCountDelta:
            withZodiacMetrics.humanPatternCount - without.humanPatternCount,
        activationCountDelta: withZodiacMetrics.humanActivationCount -
            without.humanActivationCount,
        narrativeParagraphDelta: withZodiacMetrics.narrativeParagraphCount -
            without.narrativeParagraphCount,
        narrativeEvidenceDelta: withZodiacMetrics.narrativeEvidenceCount -
            without.narrativeEvidenceCount,
        narrativeConfidenceDelta: withZodiacMetrics.narrativeConfidenceComposite -
            without.narrativeConfidenceComposite,
      );
    }).toList();
  }

  static ChineseZodiacImpactMetrics _measureArm({
    required ChineseZodiacImpactProfile profile,
    required ChineseZodiacImpactArm arm,
    required AstrologyChartModel western,
    required KnowMeMirrorSnapshot personalityMirror,
  }) {
    final baziOutputs = _baziOutputs(profile.chart, arm);
    final lensOutputs = [
      ...WesternRealAdapter.adapt(western),
      ...baziOutputs,
    ];

    final fusionResult = AstrologyFusionGenerator.generateFromRealData(
      AstrologyFusionRealInput(
        western: western,
        bazi: profile.chart,
        thai: null,
      ),
      generatedAt: _generatedAt,
    );

    if (arm == ChineseZodiacImpactArm.withoutZodiac) {
      // Re-generate fusion from controlled lens set (core bazi only).
      final controlledFusion = AstrologyFusionGenerator.generate(
        lensOutputs,
        generatedAt: _generatedAt,
      );
      return _metricsFromPipeline(
        arm: arm,
        profile: profile,
        lensOutputs: lensOutputs,
        fusionResult: controlledFusion,
        personalityMirror: personalityMirror,
      );
    }

    return _metricsFromPipeline(
      arm: arm,
      profile: profile,
      lensOutputs: lensOutputs,
      fusionResult: fusionResult,
      personalityMirror: personalityMirror,
    );
  }

  static List<LensThemeOutput> _baziOutputs(
    BaziChartModel chart,
    ChineseZodiacImpactArm arm,
  ) {
    return switch (arm) {
      ChineseZodiacImpactArm.withoutZodiac =>
        ChineseZodiacCoreOnlyAdapter.adapt(chart),
      ChineseZodiacImpactArm.withZodiac => BaziRealAdapter.adapt(chart),
    };
  }

  static ChineseZodiacImpactMetrics _metricsFromPipeline({
    required ChineseZodiacImpactArm arm,
    required ChineseZodiacImpactProfile profile,
    required List<LensThemeOutput> lensOutputs,
    required AstrologyFusionResult fusionResult,
    required KnowMeMirrorSnapshot personalityMirror,
  }) {
    final themeIds = lensOutputs.map((output) => output.themeId).toSet().toList()
      ..sort();

    final astrologyMirror = _astrologyMirror(
      profile: profile,
      arm: arm,
      lensOutputs: lensOutputs,
    );

    final globalFusion = GlobalFusionFoundationBuilder.build(
      GlobalFusionInput(
        mirrors: [
          GlobalFusionMirrorRef(
            mirrorRoleId: GlobalFusionMirrorRoles.astrology,
            snapshot: astrologyMirror,
          ),
          GlobalFusionMirrorRef(
            mirrorRoleId: GlobalFusionMirrorRoles.personality,
            snapshot: personalityMirror,
          ),
        ],
      ),
      createdAt: _generatedAt,
    );

    final humanModel = HumanModelFoundationBuilder.build(
      HumanModelInput(fusionSnapshot: globalFusion),
      createdAt: _generatedAt,
    );

    final humanPattern = HumanPatternSnapshotBuilder.build(
      HumanPatternInput(humanModelSnapshot: humanModel),
      createdAt: _generatedAt,
    );

    final narrative = NarrativeRuntimeService.generate(
      patternSnapshot: humanPattern,
      createdAt: _generatedAt,
    );

    return ChineseZodiacImpactMetrics(
      arm: arm,
      themeCount: themeIds.length,
      uniqueThemeIds: themeIds,
      fusionAgreements: AgreementEngine.detect(
        lensOutputs
            .where((output) => FusionThemeRegistry.contains(output.themeId))
            .toList(),
      ).length,
      fusionTensions: fusionResult.tensions.length,
      fusionSignals: fusionResult.signals.length,
      fusionGrowthOpportunities: fusionResult.growthOpportunities.length,
      globalAgreements: globalFusion.agreements.length,
      globalTensions: globalFusion.tensions.length,
      globalReinforcements: globalFusion.reinforcements.length,
      globalBlindSpots: globalFusion.blindSpots.length,
      humanPatternCount: humanModel.patterns.length,
      humanActivationCount: humanPattern.activations.length,
      narrativeParagraphCount: narrative.paragraphCount,
      narrativeEvidenceCount: _narrativeEvidenceCount(narrative),
      narrativeConfidenceComposite: narrative.confidence.composite,
      narrativeByMode: _narrativeByMode(narrative),
    );
  }

  static KnowMeMirrorSnapshot _astrologyMirror({
    required ChineseZodiacImpactProfile profile,
    required ChineseZodiacImpactArm arm,
    required List<LensThemeOutput> lensOutputs,
  }) {
    final snapshotId = 'validation-astro-${profile.profileId}-${arm.key}';
    final signals = ChineseZodiacImpactLensMirrorBridge.fromLensOutputs(
      lensOutputs,
      sourceSnapshotId: snapshotId,
    );

    final input = KnowMeMirrorEngineInput(
      lineage: KnowMeMirrorLineageChain(
        mirrorScopeId: KnowMeMirrorIdentityContract.mirrorScopeId(
          astrologyThemeSnapshotId: snapshotId,
        ),
        astrologyThemeSnapshotId: snapshotId,
        astrologyThemeBundleId: snapshotId,
        personalityOnly: false,
        sourceSnapshotVersions: const {
          'bazi_validation': 'zodiac_impact_v1',
        },
      ),
      signals: signals,
      generatedAt: _generatedAt,
    );

    return KnowMeMirrorSnapshotBuilder.fromEngineResult(
      KnowMeMirrorEngine.reflect(input),
      createdAt: _generatedAt,
    );
  }

  static int _narrativeEvidenceCount(NarrativeResult narrative) {
    var count = 0;
    for (final section in narrative.sections) {
      for (final paragraph in section.paragraphs) {
        count += paragraph.evidence.length;
      }
    }
    return count;
  }

  static Map<String, int> _narrativeByMode(NarrativeResult narrative) {
    return {
      for (final mode in NarrativeMode.values)
        mode.key: narrative.sectionFor(mode)?.paragraphs.length ?? 0,
    };
  }

  static ChineseZodiacQualitativeReview _qualitativeReview({
    required ChineseZodiacImpactProfile profile,
    required ChineseZodiacImpactMetrics without,
    required ChineseZodiacImpactMetrics withArm,
  }) {
    final coreIds = without.uniqueThemeIds.toSet();
    final integratedIds = withArm.uniqueThemeIds.toSet();
    final zodiacBridgeIds = ZodiacBaziAdapterBridge.adapt(profile.chart.yearAnimal)
        .map((output) => output.themeId)
        .toSet();

    final netNew = zodiacBridgeIds.difference(coreIds).toList()..sort();
    final collisions = zodiacBridgeIds.intersection(coreIds).toList()..sort();

    final contradictory = _contradictoryThemePairs(
      without: without,
      withArm: withArm,
    );

    final tier = _classifyTier(
      netNewCount: netNew.length,
      collisionCount: collisions.length,
      contradictoryCount: contradictory,
      patternDelta: withArm.humanPatternCount - without.humanPatternCount,
      activationDelta: withArm.humanActivationCount - without.humanActivationCount,
      narrativeParagraphDelta:
          withArm.narrativeParagraphCount - without.narrativeParagraphCount,
      globalAgreementDelta: withArm.globalAgreements - without.globalAgreements,
    );

    final notes = _notes(
      netNew: netNew,
      collisions: collisions,
      contradictory: contradictory,
      narrativeParagraphDelta:
          withArm.narrativeParagraphCount - without.narrativeParagraphCount,
      narrativeEvidenceDelta:
          withArm.narrativeEvidenceCount - without.narrativeEvidenceCount,
    );

    return ChineseZodiacQualitativeReview(
      tier: tier,
      newInformationCount: netNew.length,
      duplicatedInformationCount: collisions.length,
      contradictoryInformationCount: contradictory,
      netNewThemeIds: netNew,
      collisionThemeIds: collisions,
      notes: notes,
    );
  }

  static int _contradictoryThemePairs({
    required ChineseZodiacImpactMetrics without,
    required ChineseZodiacImpactMetrics withArm,
  }) {
    final tensionDelta = withArm.fusionTensions - without.fusionTensions;
    final globalTensionDelta = withArm.globalTensions - without.globalTensions;
    return (tensionDelta + globalTensionDelta).clamp(0, 99);
  }

  static ChineseZodiacQualitativeTier _classifyTier({
    required int netNewCount,
    required int collisionCount,
    required int contradictoryCount,
    required int patternDelta,
    required int activationDelta,
    required int narrativeParagraphDelta,
    required int globalAgreementDelta,
  }) {
    final signalScore = netNewCount * 2 +
        patternDelta +
        activationDelta +
        narrativeParagraphDelta +
        globalAgreementDelta;
    final penalty = collisionCount + contradictoryCount * 2;

    if (netNewCount == 0 &&
        patternDelta == 0 &&
        activationDelta == 0 &&
        narrativeParagraphDelta == 0 &&
        globalAgreementDelta == 0) {
      return ChineseZodiacQualitativeTier.none;
    }

    final net = signalScore - penalty;
    if (net <= 0) return ChineseZodiacQualitativeTier.none;
    if (net <= 3) return ChineseZodiacQualitativeTier.low;
    if (net <= 8) return ChineseZodiacQualitativeTier.medium;
    return ChineseZodiacQualitativeTier.high;
  }

  static String _notes({
    required List<String> netNew,
    required List<String> collisions,
    required int contradictory,
    required int narrativeParagraphDelta,
    required int narrativeEvidenceDelta,
  }) {
    final parts = <String>[];
    if (netNew.isNotEmpty) {
      parts.add('Net-new zodiac themes: ${netNew.join(', ')}');
    }
    if (collisions.isNotEmpty) {
      parts.add('Collides with BaZi core themes: ${collisions.join(', ')}');
    }
    if (contradictory > 0) {
      parts.add('Added $contradictory tension signal(s) vs core-only arm');
    }
    if (narrativeParagraphDelta > 0 && narrativeEvidenceDelta == 0) {
      parts.add('Narrative longer without additional evidence anchors');
    } else if (narrativeParagraphDelta > 0) {
      parts.add(
        'Narrative gained $narrativeParagraphDelta paragraph(s) and '
        '$narrativeEvidenceDelta evidence row(s)',
      );
    } else if (narrativeParagraphDelta == 0 && netNew.isNotEmpty) {
      parts.add('Fusion themes added but downstream narrative unchanged');
    }
    return parts.isEmpty ? 'No meaningful zodiac delta detected' : parts.join('; ');
  }
}
