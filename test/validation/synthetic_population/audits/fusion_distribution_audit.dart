import '../pipeline/synthetic_human_run_record.dart';

/// Distribution of global fusion outcomes and finding-level dead zones.
class FusionDistributionAudit {
  const FusionDistributionAudit({
    required this.populationSize,
    required this.uniqueFusionHashes,
    required this.fusionDiversityRatio,
    required this.agreementTypeFrequency,
    required this.tensionTypeFrequency,
    required this.blindSpotFrequency,
    required this.reinforcementFrequency,
    required this.neverSeenAgreementKeys,
    required this.neverSeenTensionKeys,
    required this.neverSeenBlindSpotKeys,
    required this.fusionDeadZones,
  });

  final int populationSize;
  final int uniqueFusionHashes;
  final double fusionDiversityRatio;
  final Map<String, int> agreementTypeFrequency;
  final Map<String, int> tensionTypeFrequency;
  final Map<String, int> blindSpotFrequency;
  final Map<String, int> reinforcementFrequency;
  final List<String> neverSeenAgreementKeys;
  final List<String> neverSeenTensionKeys;
  final List<String> neverSeenBlindSpotKeys;
  final List<String> fusionDeadZones;

  static FusionDistributionAudit analyze(List<SyntheticHumanRunRecord> records) {
    final fusionHashes = records.map((item) => item.fusionFingerprint).toSet();

    final agreementCounts = <String, int>{};
    final tensionCounts = <String, int>{};
    final blindSpotCounts = <String, int>{};
    final reinforcementCounts = <String, int>{};
    final fusionMirrorKeys = <String>{};
    final sourceMirrorKeys = <String>{};

    for (final record in records) {
      for (final signal in [
        ...record.astrologyInput.signals,
        ...record.personalityInput.signals,
      ]) {
        sourceMirrorKeys.add(signal.mirrorKey);
      }

      final fusion = record.globalFusionSnapshot;
      for (final item in fusion.agreements) {
        final key = item.mirrorKey;
        agreementCounts[key] = (agreementCounts[key] ?? 0) + 1;
        fusionMirrorKeys.add(key);
      }
      for (final item in fusion.tensions) {
        final key = item.mirrorKey;
        tensionCounts[key] = (tensionCounts[key] ?? 0) + 1;
        fusionMirrorKeys.add(key);
      }
      for (final item in fusion.blindSpots) {
        final key = item.mirrorKey;
        blindSpotCounts[key] = (blindSpotCounts[key] ?? 0) + 1;
        fusionMirrorKeys.add(key);
      }
      for (final item in fusion.reinforcements) {
        final key = item.mirrorKey;
        reinforcementCounts[key] = (reinforcementCounts[key] ?? 0) + 1;
        fusionMirrorKeys.add(key);
      }
    }

    final deadZones = sourceMirrorKeys
        .where((key) => !fusionMirrorKeys.contains(key))
        .toList()
      ..sort();

    return FusionDistributionAudit(
      populationSize: records.length,
      uniqueFusionHashes: fusionHashes.length,
      fusionDiversityRatio:
          records.isEmpty ? 0 : fusionHashes.length / records.length,
      agreementTypeFrequency: _sorted(agreementCounts),
      tensionTypeFrequency: _sorted(tensionCounts),
      blindSpotFrequency: _sorted(blindSpotCounts),
      reinforcementFrequency: _sorted(reinforcementCounts),
      neverSeenAgreementKeys: agreementCounts.entries
          .where((entry) => entry.value <= 1)
          .map((entry) => entry.key)
          .toList(),
      neverSeenTensionKeys: tensionCounts.entries
          .where((entry) => entry.value <= 1)
          .map((entry) => entry.key)
          .toList(),
      neverSeenBlindSpotKeys: blindSpotCounts.entries
          .where((entry) => entry.value <= 1)
          .map((entry) => entry.key)
          .toList(),
      fusionDeadZones: deadZones,
    );
  }

  static Map<String, int> _sorted(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries);
  }

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'uniqueFusionHashes': uniqueFusionHashes,
      'fusionDiversityRatio': fusionDiversityRatio,
      'agreementTypeFrequency': agreementTypeFrequency,
      'tensionTypeFrequency': tensionTypeFrequency,
      'blindSpotFrequency': blindSpotFrequency,
      'reinforcementFrequency': reinforcementFrequency,
      'fusionDeadZoneCount': fusionDeadZones.length,
    };
  }
}
