import 'package:knowme/features/astrology/fusion/domain/entities/fusion_agreement.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/fusion_signal.dart';
import 'package:knowme/features/astrology/fusion/domain/models/astrology_fusion_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_lens_snapshot.dart';
import 'package:knowme/features/personality_mirror/domain/personality_mirror_snapshot.dart';

import '../../domain/global_core_themes.dart';
import '../../domain/global_evidence.dart';
import '../../domain/global_lens_id.dart';
import '../../domain/global_theme_activation.dart';
import 'mirror_theme_mappings.dart';

/// Normalizes mirror outputs into the shared global theme space.
abstract final class GlobalThemeNormalizer {
  static List<GlobalThemeActivation> fromMirrors({
    AstrologyFusionSnapshot? astrology,
    PersonalityMirrorSnapshot? personality,
  }) {
    final activations = <String, List<GlobalEvidence>>{};

    if (astrology != null) {
      _collectAstrology(astrology, activations);
    }
    if (personality != null) {
      _collectPersonality(personality, activations);
    }

    return activations.entries
        .where((entry) => GlobalThemeRegistry.contains(entry.key))
        .map(
          (entry) => GlobalThemeActivation(
            globalThemeId: entry.key,
            evidence: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.globalThemeId.compareTo(b.globalThemeId));
  }

  static void _collectAstrology(
    AstrologyFusionSnapshot snapshot,
    Map<String, List<GlobalEvidence>> activations,
  ) {
    for (final signal in snapshot.signals) {
      _addAstrologySignal(signal, activations);
    }
    for (final agreement in snapshot.agreements) {
      _addAstrologyAgreement(agreement, activations);
    }
  }

  static void _collectPersonality(
    PersonalityMirrorSnapshot snapshot,
    Map<String, List<GlobalEvidence>> activations,
  ) {
    for (final lens in snapshot.lensSnapshots) {
      if (!lens.available) continue;
      for (final theme in lens.themes) {
        final globalId =
            PersonalityMirrorThemeMapping.globalThemeForCoreTheme(theme.themeId);
        if (globalId == null) continue;
        _addEvidence(
          activations,
          globalId,
          GlobalEvidence(
            sourceMirror: GlobalLensId.personalityMirror,
            sourceThemeId: theme.themeId,
            referenceKind: 'lens_theme',
            referenceId: '${lens.lensId.storageKey}:${theme.themeId}',
          ),
        );
      }
    }
  }

  static void _addAstrologySignal(
    FusionSignal signal,
    Map<String, List<GlobalEvidence>> activations,
  ) {
    final globalId =
        AstrologyMirrorThemeMapping.globalThemeForSignalType(signal.type);
    if (globalId == null) return;

    _addEvidence(
      activations,
      globalId,
      GlobalEvidence(
        sourceMirror: GlobalLensId.astrologyMirror,
        sourceThemeId: signal.sourceThemes.isNotEmpty
            ? signal.sourceThemes.first
            : signal.type.name,
        referenceKind: 'signal',
        referenceId: signal.type.name,
      ),
    );

    for (final sourceTheme in signal.sourceThemes) {
      final fromTheme =
          AstrologyMirrorThemeMapping.globalThemeForSourceThemeId(sourceTheme);
      if (fromTheme == null || fromTheme == globalId) continue;
      _addEvidence(
        activations,
        fromTheme,
        GlobalEvidence(
          sourceMirror: GlobalLensId.astrologyMirror,
          sourceThemeId: sourceTheme,
          referenceKind: 'signal_source_theme',
          referenceId: signal.type.name,
          weight: 0.5,
        ),
      );
    }
  }

  static void _addAstrologyAgreement(
    FusionAgreement agreement,
    Map<String, List<GlobalEvidence>> activations,
  ) {
    if (agreement.family != null) {
      final globalId =
          AstrologyMirrorThemeMapping.globalThemeForFamily(agreement.family!);
      if (globalId != null) {
        _addEvidence(
          activations,
          globalId,
          GlobalEvidence(
            sourceMirror: GlobalLensId.astrologyMirror,
            sourceThemeId: agreement.primaryThemeId,
            referenceKind: 'agreement',
            referenceId: agreement.primaryThemeId,
          ),
        );
      }
    }

    for (final themeId in agreement.sourceThemeIds) {
      final globalId =
          AstrologyMirrorThemeMapping.globalThemeForSourceThemeId(themeId);
      if (globalId == null) continue;
      _addEvidence(
        activations,
        globalId,
        GlobalEvidence(
          sourceMirror: GlobalLensId.astrologyMirror,
          sourceThemeId: themeId,
          referenceKind: 'agreement_theme',
          referenceId: themeId,
        ),
      );
    }
  }

  static void _addEvidence(
    Map<String, List<GlobalEvidence>> activations,
    String globalThemeId,
    GlobalEvidence evidence,
  ) {
    activations.putIfAbsent(globalThemeId, () => []).add(evidence);
  }
}
