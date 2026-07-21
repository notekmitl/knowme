import '../foundation/models/profile_warning.dart';
import '../foundation/models/thai_birth_data.dart';
import '../foundation/v2/models/thai_chart.dart';
import 'constants/thai_signal_extractor_version.dart';
import 'extractors/house_signal_extractor.dart';
import 'extractors/seven_numbers_signal_adapter.dart';
import 'extractors/sidereal_signal_extractor.dart';
import 'models/thai_signal.dart';
import 'models/thai_signal_bundle.dart';

class ThaiSignalExtractorInput {
  const ThaiSignalExtractorInput({
    required this.chart,
    required this.birthData,
  });

  final ThaiChart chart;
  final ThaiBirthData birthData;
}

class ThaiSignalExtractorResult {
  const ThaiSignalExtractorResult({
    required this.bundle,
    required this.warnings,
  });

  final ThaiSignalBundle bundle;
  final List<ProfileWarning> warnings;
}

/// Extracts structural [ThaiSignal] values from [ThaiChart] and seven-numbers
/// engines.
abstract final class ThaiSignalExtractor {
  static ThaiSignalExtractorResult extract(ThaiSignalExtractorInput input) {
    final chart = input.chart;
    final sevenNumbers = SevenNumbersSignalAdapter.extract(input.birthData);
    final signals = _dedupeById([
      ...SiderealSignalExtractor.extract(chart),
      ...HouseSignalExtractor.extract(chart),
      ...sevenNumbers.signals,
    ])..sort((a, b) => a.signalId.compareTo(b.signalId));

    final warnings = List<ProfileWarning>.unmodifiable([
      ...chart.warnings,
      ...sevenNumbers.warnings,
    ]);

    final bundle = ThaiSignalBundle(
      bundleId: _bundleId(chart, signals),
      extractedAt: DateTime.now().toUtc(),
      extractorVersion: ThaiSignalExtractorContract.extractorVersion,
      hasBirthTime: chart.metadata.hasBirthTime,
      signals: List<ThaiSignal>.unmodifiable(signals),
      warnings: warnings,
    );

    return ThaiSignalExtractorResult(
      bundle: bundle,
      warnings: warnings,
    );
  }

  static List<ThaiSignal> _dedupeById(List<ThaiSignal> signals) {
    final byId = <String, ThaiSignal>{};
    for (final signal in signals) {
      byId[signal.signalId] = signal;
    }
    return byId.values.toList(growable: false);
  }

  static String _bundleId(ThaiChart chart, List<ThaiSignal> signals) {
    final signalIds = signals.map((signal) => signal.signalId).join(',');
    return '${chart.metadata.birthFingerprint}|'
        '${ThaiSignalExtractorContract.extractorVersion}|'
        '$signalIds';
  }
}
