import '../pipeline/synthetic_human_run_record.dart';

/// Tracks which input systems contribute mirror signals across the population.
class PopulationCoverageAudit {
  const PopulationCoverageAudit({
    required this.populationSize,
    required this.totalMirrorSignals,
    required this.signalCountsBySystem,
    required this.signalShareBySystem,
    required this.dominantSystems,
    required this.weakSystems,
    required this.attachmentStyleDistribution,
  });

  final int populationSize;
  final int totalMirrorSignals;
  final Map<String, int> signalCountsBySystem;
  final Map<String, double> signalShareBySystem;
  final List<String> dominantSystems;
  final List<String> weakSystems;
  final Map<String, int> attachmentStyleDistribution;

  static PopulationCoverageAudit analyze(List<SyntheticHumanRunRecord> records) {
    final counts = <String, int>{
      'mbti': 0,
      'big_five': 0,
      'eq': 0,
      'thai': 0,
      'bazi_zodiac': 0,
      'attachment_style': records.length,
    };

    for (final record in records) {
      for (final entry in record.mirrorSignalCountsBySystem().entries) {
        counts[entry.key] = (counts[entry.key] ?? 0) + entry.value;
      }
    }

    final total = counts.entries
        .where((entry) => entry.key != 'attachment_style')
        .fold<int>(0, (sum, entry) => sum + entry.value);

    final shares = <String, double>{};
    for (final entry in counts.entries) {
      if (entry.key == 'attachment_style') continue;
      shares[entry.key] = total == 0 ? 0 : entry.value / total;
    }

    final sorted = shares.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final dominant = sorted
        .where((entry) => entry.value >= 0.22)
        .map((entry) => entry.key)
        .toList();
    final weak = sorted
        .where((entry) => entry.value <= 0.08)
        .map((entry) => entry.key)
        .toList();

    final attachmentCounts = <String, int>{};
    for (final record in records) {
      final key = record.profile.attachmentStyle.key;
      attachmentCounts[key] = (attachmentCounts[key] ?? 0) + 1;
    }

    return PopulationCoverageAudit(
      populationSize: records.length,
      totalMirrorSignals: total,
      signalCountsBySystem: counts,
      signalShareBySystem: shares,
      dominantSystems: dominant,
      weakSystems: weak,
      attachmentStyleDistribution: attachmentCounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'populationSize': populationSize,
      'totalMirrorSignals': totalMirrorSignals,
      'signalCountsBySystem': signalCountsBySystem,
      'signalShareBySystem': signalShareBySystem,
      'dominantSystems': dominantSystems,
      'weakSystems': weakSystems,
      'attachmentStyleDistribution': attachmentStyleDistribution,
    };
  }
}
