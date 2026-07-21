import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/mirror_v3/contracts/knowme_mirror_identity_contract.dart';
import 'package:knowme/features/mirror_v3/engine/adapters/knowme_mirror_personality_adapter.dart';
import 'package:knowme/features/mirror_v3/engine/knowme_mirror_engine.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_engine_input.dart';
import 'package:knowme/features/mirror_v3/engine/models/knowme_mirror_theme_signal.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_source_type.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';
import 'package:knowme/features/mirror_v3/models/knowme_mirror_lineage_chain.dart';
import 'package:knowme/features/mirror_v3/snapshot/builder/knowme_mirror_snapshot_builder.dart';
import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';

/// Fixed personality mirror for impact validation — themes overlap BaZi/Zodiac keys.
abstract final class ChineseZodiacImpactPersonalityBaseline {
  static const _snapshotId = 'validation-personality-zodiac-impact-v1';

  static KnowMeMirrorSnapshot mirror({required DateTime generatedAt}) {
    final signals = <KnowMeMirrorThemeSignal>[
      ...KnowMeMirrorPersonalityAdapter.extractThemes(
        systemId: KnowMeMirrorSystemId.mbti,
        sourceType: KnowMeMirrorSourceType.mbtiTheme,
        sourceLensKey: 'mbti',
        sourceSnapshotId: _snapshotId,
        themes: const [
          PersonalityThemeInput(
            themeId: 'expressive',
            category: FusionCategory.coreSelf,
            confidence: 0.72,
            prominence: 0.72,
            evidenceCount: 2,
          ),
          PersonalityThemeInput(
            themeId: 'supportive',
            category: FusionCategory.relationships,
            confidence: 0.68,
            prominence: 0.68,
            evidenceCount: 2,
          ),
          PersonalityThemeInput(
            themeId: 'driven',
            category: FusionCategory.workAndAmbition,
            confidence: 0.7,
            prominence: 0.7,
            evidenceCount: 2,
          ),
        ],
      ),
      ...KnowMeMirrorPersonalityAdapter.extractThemes(
        systemId: KnowMeMirrorSystemId.bigFive,
        sourceType: KnowMeMirrorSourceType.bigFiveTheme,
        sourceLensKey: 'big_five',
        sourceSnapshotId: _snapshotId,
        themes: const [
          PersonalityThemeInput(
            themeId: 'reliable',
            category: FusionCategory.strengths,
            confidence: 0.66,
            prominence: 0.66,
            evidenceCount: 2,
          ),
          PersonalityThemeInput(
            themeId: 'analytical',
            category: FusionCategory.thinkingStyle,
            confidence: 0.64,
            prominence: 0.64,
            evidenceCount: 2,
          ),
          PersonalityThemeInput(
            themeId: 'responsive',
            category: FusionCategory.emotionalWorld,
            confidence: 0.67,
            prominence: 0.67,
            evidenceCount: 2,
          ),
        ],
      ),
    ];

    final input = KnowMeMirrorEngineInput(
      lineage: KnowMeMirrorLineageChain(
        mirrorScopeId: KnowMeMirrorIdentityContract.mirrorScopeId(
          mbtiLensSnapshotId: _snapshotId,
          bigFiveLensSnapshotId: _snapshotId,
        ),
        mbtiLensSnapshotId: _snapshotId,
        bigFiveLensSnapshotId: _snapshotId,
        personalityOnly: true,
        sourceSnapshotVersions: const {
          'mbti': 'validation_v1',
          'big_five': 'validation_v1',
        },
      ),
      signals: signals,
      generatedAt: generatedAt,
    );

    return KnowMeMirrorSnapshotBuilder.fromEngineResult(
      KnowMeMirrorEngine.reflect(input),
      createdAt: generatedAt,
    );
  }
}
