import '../contracts/global_fusion_input.dart';
import '../domain/global_fusion_findings.dart';
import 'cross_mirror_agreement_engine.dart';

/// GF4 — detects cross-mirror polarity divergence on shared dimensions.
abstract final class CrossMirrorTensionEngine {
  static List<GlobalFusionCrossMirrorTension> detect(
    GlobalFusionInput input,
  ) {
    final positiveByRole = _positiveSignals(input);
    final tensionsByRole = _tensionSignals(input);
    final results = <GlobalFusionCrossMirrorTension>[];

    for (final positiveEntry in positiveByRole.entries) {
      final positiveRole = positiveEntry.key;
      for (final positive in positiveEntry.value) {
        for (final tensionEntry in tensionsByRole.entries) {
          if (tensionEntry.key == positiveRole) continue;

          for (final tension in tensionEntry.value) {
            if (!_isCrossMirrorTension(positive, tension)) continue;

            results.add(
              GlobalFusionCrossMirrorTension(
                id: _tensionId(
                  positiveRole: positiveRole,
                  tensionRole: tensionEntry.key,
                  mirrorKey: positive.mirrorKey,
                ),
                mirrorKey: positive.mirrorKey,
                mirrorDimension: positive.mirrorDimension,
                positiveMirrorRoleId: positiveRole,
                tensionMirrorRoleId: tensionEntry.key,
                positiveMirrorFindingId: positive.findingId,
                tensionMirrorFindingId: tension.findingId,
                themeIds: _mergedThemes(positive.themeIds, tension.themeIds),
                reasonCode: 'cross_mirror_polarity_divergence',
              ),
            );
          }
        }
      }
    }

    results.sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  static bool _isCrossMirrorTension(_PositiveSignal positive, _TensionSignal tension) {
    if (positive.mirrorDimension == tension.mirrorDimension) return true;

    final positiveThemes = positive.themeIds.toSet();
    return tension.themeIds.any(positiveThemes.contains);
  }

  static Map<String, List<_PositiveSignal>> _positiveSignals(
    GlobalFusionInput input,
  ) {
    final map = <String, List<_PositiveSignal>>{};

    for (final ref in input.mirrors) {
      final signals = <_PositiveSignal>[];
      for (final agreement in ref.snapshot.agreements) {
        signals.add(
          _PositiveSignal(
            findingId: agreement.id,
            mirrorKey: agreement.mirrorKey,
            mirrorDimension: agreement.mirrorDimension,
            themeIds: agreement.themeIds,
          ),
        );
      }
      for (final reinforcement in ref.snapshot.reinforcements) {
        signals.add(
          _PositiveSignal(
            findingId: reinforcement.id,
            mirrorKey: reinforcement.mirrorKey,
            mirrorDimension: reinforcement.mirrorDimension,
            themeIds: reinforcement.themeIds,
          ),
        );
      }
      map[ref.mirrorRoleId] = signals;
    }

    return map;
  }

  static Map<String, List<_TensionSignal>> _tensionSignals(
    GlobalFusionInput input,
  ) {
    final map = <String, List<_TensionSignal>>{};

    for (final ref in input.mirrors) {
      final signals = ref.snapshot.tensions
          .map(
            (tension) => _TensionSignal(
              findingId: tension.id,
              mirrorDimension: tension.mirrorDimension,
              themeIds: tension.themeIds,
            ),
          )
          .toList(growable: false);
      map[ref.mirrorRoleId] = signals;
    }

    return map;
  }

  static List<String> _mergedThemes(List<String> a, List<String> b) {
    return {...a, ...b}.toList()..sort();
  }

  static String _tensionId({
    required String positiveRole,
    required String tensionRole,
    required String mirrorKey,
  }) {
    final payload = 'gf_tension|$positiveRole|$tensionRole|$mirrorKey';
    return 'gf_tension_${CrossMirrorAgreementEngine.sha256Hex(payload)}';
  }
}

class _PositiveSignal {
  const _PositiveSignal({
    required this.findingId,
    required this.mirrorKey,
    required this.mirrorDimension,
    required this.themeIds,
  });

  final String findingId;
  final String mirrorKey;
  final String mirrorDimension;
  final List<String> themeIds;
}

class _TensionSignal {
  const _TensionSignal({
    required this.findingId,
    required this.mirrorDimension,
    required this.themeIds,
  });

  final String findingId;
  final String mirrorDimension;
  final List<String> themeIds;
}
