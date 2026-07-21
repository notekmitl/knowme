import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';

import '../synthetic_population/pipeline/synthetic_human_run_record.dart';

/// Audit D — system dominance and survival across pipeline layers.
class SystemDominanceReport {
  const SystemDominanceReport({
    required this.populationSize,
    required this.layerSystemCounts,
    required this.layerSystemShares,
    required this.dominantSystemsByLayer,
    required this.disappearedSystemsByLayer,
    required this.narrativeSurvivors,
  });

  final int populationSize;
  final Map<String, Map<String, int>> layerSystemCounts;
  final Map<String, Map<String, double>> layerSystemShares;
  final Map<String, List<String>> dominantSystemsByLayer;
  final Map<String, List<String>> disappearedSystemsByLayer;
  final Map<String, int> narrativeSurvivors;

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'layerSystemCounts': layerSystemCounts,
      'layerSystemShares': layerSystemShares,
      'dominantSystemsByLayer': dominantSystemsByLayer,
      'disappearedSystemsByLayer': disappearedSystemsByLayer,
      'narrativeSurvivors': narrativeSurvivors,
    };
  }
}

abstract final class SystemDominanceAudit {
  static const _layers = [
    'mirror_input',
    'mirror_snapshot',
    'fusion',
    'human_model',
    'human_pattern',
    'narrative',
  ];

  static SystemDominanceReport analyze(List<SyntheticHumanRunRecord> records) {
    final counts = {
      for (final layer in _layers) layer: <String, int>{},
    };

    for (final record in records) {
      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );

      _merge(counts['mirror_input']!, _mirrorInput(record));
      _merge(counts['mirror_snapshot']!, _mirrorSnapshot(record));
      _merge(counts['fusion']!, _generic(record.globalFusionSnapshot.evidence));
      _merge(counts['human_model']!, _generic(humanModel.evidence));
      _merge(
        counts['human_pattern']!,
        _generic(record.humanPatternSnapshot.evidence),
      );
      _merge(counts['narrative']!, _narrative(record));
    }

    final shares = <String, Map<String, double>>{};
    final dominant = <String, List<String>>{};
    final disappeared = <String, List<String>>{};

    for (final layer in _layers) {
      final layerCounts = counts[layer]!;
      final total = layerCounts.values.fold<int>(0, (sum, value) => sum + value);
      final layerShares = <String, double>{};
      for (final entry in layerCounts.entries) {
        layerShares[entry.key] = total == 0 ? 0 : entry.value / total;
      }
      shares[layer] = layerShares;

      dominant[layer] = layerShares.entries
          .where((entry) => entry.value >= 0.22)
          .map((entry) => entry.key)
          .toList()
        ..sort();

      final inputSystems = counts['mirror_input']!.keys.toSet();
      disappeared[layer] = inputSystems
          .where((system) => (layerCounts[system] ?? 0) == 0)
          .toList()
        ..sort();
    }

    return SystemDominanceReport(
      populationSize: records.length,
      layerSystemCounts: counts,
      layerSystemShares: shares,
      dominantSystemsByLayer: dominant,
      disappearedSystemsByLayer: disappeared,
      narrativeSurvivors: Map<String, int>.from(counts['narrative']!),
    );
  }

  static Map<String, int> _mirrorInput(SyntheticHumanRunRecord record) {
    final counts = <String, int>{};
    for (final signal in [
      ...record.astrologyInput.signals,
      ...record.personalityInput.signals,
    ]) {
      final key = _canonicalSystem(signal.systemId);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _mirrorSnapshot(SyntheticHumanRunRecord record) {
    final counts = <String, int>{};
    for (final row in [
      ...record.astrologyMirrorSnapshot.evidence,
      ...record.personalityMirrorSnapshot.evidence,
    ]) {
      counts[row.systemId] = (counts[row.systemId] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _generic(List<dynamic> rows) {
    final counts = <String, int>{};
    for (final row in rows) {
      counts[row.systemId] = (counts[row.systemId] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _narrative(SyntheticHumanRunRecord record) {
    final counts = <String, int>{};
    for (final section in record.narrativeResult.sections) {
      for (final paragraph in section.paragraphs) {
        for (final row in paragraph.evidence) {
          counts[row.systemId] = (counts[row.systemId] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  static String _canonicalSystem(KnowMeMirrorSystemId systemId) {
    return switch (systemId) {
      KnowMeMirrorSystemId.thaiAstrology => 'thai_astrology',
      KnowMeMirrorSystemId.mbti => 'mbti',
      KnowMeMirrorSystemId.bigFive => 'big_five',
      KnowMeMirrorSystemId.eq => 'eq',
      KnowMeMirrorSystemId.knowMeMirror => 'knowme_mirror',
    };
  }

  static void _merge(Map<String, int> target, Map<String, int> source) {
    for (final entry in source.entries) {
      target[entry.key] = (target[entry.key] ?? 0) + entry.value;
    }
  }
}
