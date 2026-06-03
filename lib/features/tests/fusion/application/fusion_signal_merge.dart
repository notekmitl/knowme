import '../domain/fusion_models.dart';

/// Lightweight merge of raw [FusionSignal]s by id (V1 rules, no weighting).
abstract final class FusionSignalMerge {
  static List<MergedFusionSignal> merge(List<FusionSignal> raw) {
    if (raw.isEmpty) return const [];

    try {
      final byId = <String, List<FusionSignal>>{};
      for (final signal in raw) {
        (byId[signal.id] ??= []).add(signal);
      }

      final merged = byId.entries
          .map((e) => _mergeGroup(e.key, e.value))
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));

      return merged;
    } catch (_) {
      return const [];
    }
  }

  static MergedFusionSignal _mergeGroup(String id, List<FusionSignal> group) {
    var strength = FusionSignalStrength.low;
    var confidence = 0;
    final seen = <FusionSignalSource>{};
    final contributors = <FusionSignalSource>[];

    for (final signal in group) {
      if (_strengthRank(signal.strength) > _strengthRank(strength)) {
        strength = signal.strength;
      }
      if (signal.confidence > confidence) {
        confidence = signal.confidence;
      }
      if (seen.add(signal.source)) {
        contributors.add(signal.source);
      }
    }

    contributors.sort((a, b) => a.index.compareTo(b.index));

    return MergedFusionSignal(
      id: id,
      strength: strength,
      confidence: confidence,
      contributors: List.unmodifiable(contributors),
    );
  }

  static int _strengthRank(FusionSignalStrength strength) => switch (strength) {
        FusionSignalStrength.low => 0,
        FusionSignalStrength.medium => 1,
        FusionSignalStrength.high => 2,
      };
}
