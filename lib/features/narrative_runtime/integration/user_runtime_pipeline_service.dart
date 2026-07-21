import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/global_fusion/foundation/builder/global_fusion_foundation_builder.dart';
import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/v2/builder/global_fusion_runtime_builder.dart';
import 'package:knowme/features/global_fusion/v2/config/global_fusion_recovery_config.dart';
import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/human_pattern/builder/human_pattern_snapshot_builder.dart';
import 'package:knowme/features/human_pattern/contracts/human_pattern_input.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/narrative_runtime/domain/narrative_result.dart';
import 'package:knowme/features/narrative_runtime/service/narrative_runtime_service.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_loader.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_astrology_mirror_signal_merger.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_thai_theme_loader.dart';
import 'package:knowme/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart';
import 'package:knowme/services/bazi_firestore_service.dart';

import 'user_profile_birth_loader.dart';

/// Runs production narrative pipeline from a signed-in user's Firestore data.
abstract final class UserRuntimePipelineService {
  static Future<NarrativeResult?> loadNarrativeForUser(
    String uid, {
    DateTime? generatedAt,
  }) async {
    if (uid.isEmpty) return null;

    final now = (generatedAt ?? DateTime.now()).toUtc();
    final birthData = await UserProfileBirthLoader.load(uid);
    if (birthData == null) return null;

    final personalityLoad = await PersonalityLensLoader().loadAll(uid);
    if (personalityLoad.availableSnapshots.isEmpty) return null;

    final astrologyInput = await _buildAstrologyInput(
      birthData: birthData,
      uid: uid,
      generatedAt: now,
    );
    final personalityInput = RuntimeMirrorInputBuilder.buildPersonalityInput(
      lensLoad: personalityLoad,
      generatedAt: now,
    );

    if (astrologyInput == null) return null;

    final previousEnabled = GlobalFusionRecoveryConfig.enabled;
    final previousPromotion = GlobalFusionRecoveryConfig.promotionEnabled;
    final previousSupplemental = GlobalFusionRecoveryConfig.supplementalEnabled;
    GlobalFusionRecoveryConfig.enabled = true;
    GlobalFusionRecoveryConfig.promotionEnabled = true;
    GlobalFusionRecoveryConfig.supplementalEnabled = true;

    try {
      final astrologyMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
        astrologyInput,
        createdAt: now,
        applyPromotion: true,
      );
      final personalityMirror = KnowMeMirrorSnapshotBuilder.fromReflectInput(
        personalityInput,
        createdAt: now,
        applyPromotion: true,
      );

      final fusionInput = GlobalFusionInput(
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
      );

      final foundation = GlobalFusionFoundationBuilder.build(
        fusionInput,
        createdAt: now,
      );

      final composed = GlobalFusionRuntimeBuilder.composeRecovery(
        input: fusionInput,
        foundationSnapshot: foundation,
        createdAt: now,
      );

      final fusionSnapshot = composed?.fusionSnapshot ?? foundation;
      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: fusionSnapshot),
        createdAt: now,
      );
      final humanPattern = HumanPatternSnapshotBuilder.build(
        HumanPatternInput(humanModelSnapshot: humanModel),
        createdAt: now,
      );

      if (humanPattern.activations.isEmpty) return null;

      return NarrativeRuntimeService.generate(
        patternSnapshot: humanPattern,
        createdAt: now,
      );
    } finally {
      GlobalFusionRecoveryConfig.enabled = previousEnabled;
      GlobalFusionRecoveryConfig.promotionEnabled = previousPromotion;
      GlobalFusionRecoveryConfig.supplementalEnabled = previousSupplemental;
    }
  }

  static Future<KnowMeMirrorEngineInput?> _buildAstrologyInput({
    required ThaiBirthData birthData,
    required String uid,
    required DateTime generatedAt,
  }) async {
    final themeBundle = RuntimeThaiThemeLoader.loadFromBirthData(birthData);
    final thaiSignals = KnowMeMirrorAstrologyAdapter.extract(themeBundle);

    BaziChartModel? baziChart;
    try {
      baziChart = await BaziFirestoreService().getChineseBaziChart(uid);
    } catch (_) {
      baziChart = null;
    }

    final baziSignals = baziChart == null
        ? const <KnowMeMirrorThemeSignal>[]
        : KnowMeMirrorBaziAdapter.extract(baziChart);

    final signals = baziSignals.isEmpty
        ? thaiSignals
        : RuntimeAstrologyMirrorSignalMerger.merge(thaiSignals, baziSignals);

    final lineage = KnowMeMirrorLineageChain(
      mirrorScopeId: KnowMeMirrorIdentityContract.mirrorScopeId(
        astrologyThemeSnapshotId: themeBundle.bundleId,
      ),
      astrologyThemeSnapshotId: themeBundle.bundleId,
      astrologyThemeBundleId: themeBundle.bundleId,
      astrologyMeaningSnapshotId: themeBundle.sourceInterpretationBundleId,
      personalityOnly: false,
      sourceSnapshotVersions: {
        'thai_astrology': 'thai_theme_v2',
        if (baziChart != null) 'chinese_bazi': baziChart.version,
      },
    );

    return KnowMeMirrorEngineInput(
      lineage: lineage,
      signals: signals,
      generatedAt: generatedAt,
    );
  }
}
