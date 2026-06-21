import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_astrology_mirror_signal_merger.dart';
import 'package:knowme/features/runtime_integration/adapters/runtime_thai_theme_loader.dart';
import 'package:knowme/features/runtime_integration/pipeline/runtime_mirror_input_builder.dart';

import '../models/synthetic_human_profile.dart';
import '../factory/synthetic_human_lens_loader.dart';

/// Validation-only mirror input builder — per-profile Thai + BaZi + personality.
abstract final class SyntheticHumanMirrorInputBuilder {
  static KnowMeMirrorEngineInput buildAstrologyInput(
    SyntheticHumanProfile profile, {
    DateTime? generatedAt,
  }) {
    final themeBundle =
        RuntimeThaiThemeLoader.loadFromBirthData(profile.thaiBirthData);
    final thaiSignals = KnowMeMirrorAstrologyAdapter.extract(themeBundle);
    final baziSignals = KnowMeMirrorBaziAdapter.extract(profile.baziChart);
    final signals =
        RuntimeAstrologyMirrorSignalMerger.merge(thaiSignals, baziSignals);

    final now = (generatedAt ?? themeBundle.generatedAt).toUtc();
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
        'chinese_bazi': profile.baziChart.version,
      },
    );

    return KnowMeMirrorEngineInput(
      lineage: lineage,
      signals: signals,
      generatedAt: now,
    );
  }

  static KnowMeMirrorEngineInput buildPersonalityInput(
    SyntheticHumanProfile profile, {
    DateTime? generatedAt,
  }) {
    final lensLoad = SyntheticHumanLensLoader.load(profile);
    return RuntimeMirrorInputBuilder.buildPersonalityInput(
      lensLoad: lensLoad,
      generatedAt: generatedAt,
    );
  }
}
