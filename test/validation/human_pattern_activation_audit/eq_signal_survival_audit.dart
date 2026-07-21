import 'package:knowme/features/human_model/builder/human_model_foundation_builder.dart';
import 'package:knowme/features/human_model/contracts/human_model_input.dart';
import 'package:knowme/features/mirror_v3/enums/knowme_mirror_system_id.dart';

import '../synthetic_population/pipeline/synthetic_human_run_record.dart';

/// Audit B — layer-by-layer signal survival for EQ (and reference systems).
class EqSignalSurvivalReport {
  const EqSignalSurvivalReport({
    required this.populationSize,
    required this.eqLayerCounts,
    required this.eqSurvivalRates,
    required this.eqLossRates,
    required this.referenceSystemLayers,
    required this.primaryEqLossLayer,
    required this.profilesWithZeroEqAtNarrative,
  });

  final int populationSize;
  final Map<String, int> eqLayerCounts;
  final Map<String, double> eqSurvivalRates;
  final Map<String, double> eqLossRates;
  final Map<String, Map<String, int>> referenceSystemLayers;
  final String primaryEqLossLayer;
  final int profilesWithZeroEqAtNarrative;

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'eqLayerCounts': eqLayerCounts,
      'eqSurvivalRates': eqSurvivalRates,
      'eqLossRates': eqLossRates,
      'referenceSystemLayers': referenceSystemLayers,
      'primaryEqLossLayer': primaryEqLossLayer,
      'profilesWithZeroEqAtNarrative': profilesWithZeroEqAtNarrative,
    };
  }
}

abstract final class EqSignalSurvivalAudit {
  static const _eqSystemId = 'eq';
  static const _layers = [
    'mirror_input',
    'mirror_snapshot',
    'fusion',
    'human_model',
    'human_pattern',
    'narrative',
  ];

  static EqSignalSurvivalReport analyze(List<SyntheticHumanRunRecord> records) {
    final eqCounts = {for (final layer in _layers) layer: 0};
    final referenceLayers = <String, Map<String, int>>{
      for (final layer in _layers) layer: <String, int>{},
    };
    var zeroEqNarrative = 0;

    for (final record in records) {
      final humanModel = HumanModelFoundationBuilder.build(
        HumanModelInput(fusionSnapshot: record.globalFusionSnapshot),
        createdAt: record.generatedAt,
      );

      final layerCounts = <String, int>{
        'mirror_input': _countEqMirrorInput(record),
        'mirror_snapshot': _countEqMirrorSnapshot(record),
        'fusion': _countBySystem(record.globalFusionSnapshot.evidence, _eqSystemId),
        'human_model': _countBySystem(humanModel.evidence, _eqSystemId),
        'human_pattern':
            _countBySystem(record.humanPatternSnapshot.evidence, _eqSystemId),
        'narrative': _countEqNarrative(record),
      };

      for (final entry in layerCounts.entries) {
        eqCounts[entry.key] = (eqCounts[entry.key] ?? 0) + entry.value;
      }

      if (layerCounts['narrative'] == 0) zeroEqNarrative++;

      _accumulateReference(
        referenceLayers,
        'mirror_input',
        _systemCountsMirrorInput(record),
      );
      _accumulateReference(
        referenceLayers,
        'mirror_snapshot',
        _systemCountsMirrorSnapshot(record),
      );
      _accumulateReference(
        referenceLayers,
        'fusion',
        _countAllSystems(record.globalFusionSnapshot.evidence),
      );
      _accumulateReference(
        referenceLayers,
        'human_model',
        _countAllSystems(humanModel.evidence),
      );
      _accumulateReference(
        referenceLayers,
        'human_pattern',
        _countAllSystems(record.humanPatternSnapshot.evidence),
      );
      _accumulateReference(
        referenceLayers,
        'narrative',
        _systemCountsNarrative(record),
      );
    }

    final baseline = eqCounts['mirror_input'] ?? 0;
    final survival = <String, double>{};
    final loss = <String, double>{};
    for (final layer in _layers) {
      final count = eqCounts[layer] ?? 0;
      survival[layer] = baseline == 0 ? 0 : count / baseline;
      loss[layer] = baseline == 0 ? 0 : 1 - (count / baseline);
    }

    final primaryLoss = _primaryLossLayer(survival);

    return EqSignalSurvivalReport(
      populationSize: records.length,
      eqLayerCounts: eqCounts,
      eqSurvivalRates: survival,
      eqLossRates: loss,
      referenceSystemLayers: referenceLayers,
      primaryEqLossLayer: primaryLoss,
      profilesWithZeroEqAtNarrative: zeroEqNarrative,
    );
  }

  static int _countEqMirrorInput(SyntheticHumanRunRecord record) {
    return record.personalityInput.signals
        .where((signal) => signal.systemId == KnowMeMirrorSystemId.eq)
        .length;
  }

  static int _countEqMirrorSnapshot(SyntheticHumanRunRecord record) {
    return [
      ...record.personalityMirrorSnapshot.evidence,
    ].where((row) => row.systemId == _eqSystemId).length;
  }

  static int _countEqNarrative(SyntheticHumanRunRecord record) {
    var count = 0;
    for (final section in record.narrativeResult.sections) {
      for (final paragraph in section.paragraphs) {
        count += paragraph.evidence
            .where((row) => row.systemId == _eqSystemId)
            .length;
      }
    }
    return count;
  }

  static int _countBySystem(List<dynamic> rows, String systemId) {
    return rows.where((row) => row.systemId == systemId).length;
  }

  static Map<String, int> _systemCountsMirrorInput(
    SyntheticHumanRunRecord record,
  ) {
    final counts = <String, int>{};
    for (final signal in [
      ...record.astrologyInput.signals,
      ...record.personalityInput.signals,
    ]) {
      final key = _systemKey(signal.systemId);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _systemCountsMirrorSnapshot(
    SyntheticHumanRunRecord record,
  ) {
    final counts = <String, int>{};
    for (final row in [
      ...record.astrologyMirrorSnapshot.evidence,
      ...record.personalityMirrorSnapshot.evidence,
    ]) {
      counts[row.systemId] = (counts[row.systemId] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _countAllSystems(List<dynamic> rows) {
    final counts = <String, int>{};
    for (final row in rows) {
      counts[row.systemId] = (counts[row.systemId] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _systemCountsNarrative(
    SyntheticHumanRunRecord record,
  ) {
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

  static String _systemKey(KnowMeMirrorSystemId systemId) {
    return switch (systemId) {
      KnowMeMirrorSystemId.thaiAstrology => 'thai_astrology',
      KnowMeMirrorSystemId.mbti => 'mbti',
      KnowMeMirrorSystemId.bigFive => 'big_five',
      KnowMeMirrorSystemId.eq => 'eq',
      KnowMeMirrorSystemId.knowMeMirror => 'knowme_mirror',
    };
  }

  static void _accumulateReference(
    Map<String, Map<String, int>> referenceLayers,
    String layer,
    Map<String, int> counts,
  ) {
    final bucket = referenceLayers[layer]!;
    for (final entry in counts.entries) {
      bucket[entry.key] = (bucket[entry.key] ?? 0) + entry.value;
    }
  }

  static String _primaryLossLayer(Map<String, double> survival) {
    var maxDrop = 0.0;
    var layer = 'mirror_input';
    for (var i = 1; i < _layers.length; i++) {
      final prev = survival[_layers[i - 1]] ?? 0;
      final curr = survival[_layers[i]] ?? 0;
      final drop = prev - curr;
      if (drop > maxDrop) {
        maxDrop = drop;
        layer = '${_layers[i - 1]}→${_layers[i]}';
      }
    }
    return layer;
  }
}
