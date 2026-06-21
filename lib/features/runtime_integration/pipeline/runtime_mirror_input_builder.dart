import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_astrology_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_bazi_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_personality_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_source_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/personality_mirror/application/personality_lens_load_result.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_id.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';

import '../adapters/runtime_astrology_mirror_signal_merger.dart';
import '../adapters/runtime_bazi_chart_loader.dart';
import '../adapters/runtime_personality_lens_loader.dart';
import '../adapters/runtime_thai_theme_loader.dart';

/// RT1/RT2 — builds MV1 engine inputs from real theme snapshots.
abstract final class RuntimeMirrorInputBuilder {
  /// When false, astrology input uses Thai themes only (validation baseline).
  static bool includeBaziInAstrologyMirror = true;

  static KnowMeMirrorEngineInput buildAstrologyInput({DateTime? generatedAt}) {
    final themeBundle = RuntimeThaiThemeLoader.loadQaProfile();
    final thaiSignals = KnowMeMirrorAstrologyAdapter.extract(themeBundle);

    final baziChart = includeBaziInAstrologyMirror
        ? RuntimeBaziChartLoader.loadQaProfile()
        : null;
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
      generatedAt: generatedAt ?? themeBundle.generatedAt,
    );
  }

  static KnowMeMirrorEngineInput buildPersonalityInput({
    PersonalityLensLoadResult? lensLoad,
    DateTime? generatedAt,
  }) {
    final load = lensLoad ?? RuntimePersonalityLensLoader.loadQaProfile();
    final signals = <KnowMeMirrorThemeSignal>[];

    for (final entry in load.snapshots.entries) {
      if (!entry.value.available) continue;
      signals.addAll(_personalitySignals(entry.key, entry.value));
    }

    final mbtiId = load.snapshots[PersonalityLensId.mbti]?.available == true
        ? _snapshotId(load.snapshots[PersonalityLensId.mbti]!)
        : null;
    final bigFiveId =
        load.snapshots[PersonalityLensId.bigFive]?.available == true
            ? _snapshotId(load.snapshots[PersonalityLensId.bigFive]!)
            : null;
    final eqId = _firstAvailableEqSnapshotId(load);

    final lineage = KnowMeMirrorLineageChain(
      mirrorScopeId: KnowMeMirrorIdentityContract.mirrorScopeId(
        mbtiLensSnapshotId: mbtiId,
        bigFiveLensSnapshotId: bigFiveId,
        eqLensSnapshotId: eqId,
      ),
      mbtiLensSnapshotId: mbtiId,
      bigFiveLensSnapshotId: bigFiveId,
      eqLensSnapshotId: eqId,
      personalityOnly: true,
      sourceSnapshotVersions: _sourceVersions(load),
    );

    return KnowMeMirrorEngineInput(
      lineage: lineage,
      signals: signals,
      generatedAt: generatedAt ?? DateTime.now().toUtc(),
    );
  }

  static List<KnowMeMirrorThemeSignal> _personalitySignals(
    PersonalityLensId lensId,
    PersonalityLensSnapshot snapshot,
  ) {
    final systemId = _systemId(lensId);
    final sourceType = _sourceType(lensId);
    final sourceLensKey = lensId.storageKey;

    final themes = snapshot.themes
        .map(
          (theme) => PersonalityThemeInput(
            themeId: theme.themeId,
            category: theme.category,
            confidence: theme.confidence,
            prominence: theme.confidence.clamp(0.0, 1.0),
            evidenceCount: theme.evidence.length,
          ),
        )
        .toList(growable: false);

    return KnowMeMirrorPersonalityAdapter.extractThemes(
      systemId: systemId,
      sourceType: sourceType,
      sourceLensKey: sourceLensKey,
      sourceSnapshotId: _snapshotId(snapshot),
      themes: themes,
    );
  }

  static KnowMeMirrorSystemId _systemId(PersonalityLensId lensId) {
    return switch (lensId) {
      PersonalityLensId.mbti => KnowMeMirrorSystemId.mbti,
      PersonalityLensId.bigFive => KnowMeMirrorSystemId.bigFive,
      _ => KnowMeMirrorSystemId.eq,
    };
  }

  static KnowMeMirrorSourceType _sourceType(PersonalityLensId lensId) {
    return switch (lensId) {
      PersonalityLensId.mbti => KnowMeMirrorSourceType.mbtiTheme,
      PersonalityLensId.bigFive => KnowMeMirrorSourceType.bigFiveTheme,
      _ => KnowMeMirrorSourceType.eqTheme,
    };
  }

  static String _snapshotId(PersonalityLensSnapshot snapshot) {
    return '${snapshot.lensId.storageKey}|${snapshot.sourceVersion.scoringVersion}|${snapshot.themes.length}';
  }

  static String? _firstAvailableEqSnapshotId(PersonalityLensLoadResult load) {
    for (final lensId in PersonalityLensId.eqLenses) {
      final snapshot = load.snapshots[lensId];
      if (snapshot != null && snapshot.available) {
        return _snapshotId(snapshot);
      }
    }
    return null;
  }

  static Map<String, String> _sourceVersions(PersonalityLensLoadResult load) {
    final versions = <String, String>{};
    for (final entry in load.snapshots.entries) {
      if (!entry.value.available) continue;
      versions[entry.key.storageKey] =
          'v${entry.value.sourceVersion.scoringVersion}';
    }
    return versions;
  }
}
