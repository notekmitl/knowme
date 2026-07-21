import '../../content/models/thai_content_key.dart';
import '../chart/seven_number_chart.dart';
import '../models/profile_warning.dart';
import '../models/thai_birth_data.dart';

/// Myanmar Seven layer — validated 4-row chart, 7 life-position keys.
///
/// [myanmarKeys] map from Row 1 (ฐานวัน) per Validation V1 recommendation.
abstract final class MyanmarSevenEngine {
  static const _numberToKey = <String>[
    ThaiContentKeys.myanmarSeven1,
    ThaiContentKeys.myanmarSeven2,
    ThaiContentKeys.myanmarSeven3,
    ThaiContentKeys.myanmarSeven4,
    ThaiContentKeys.myanmarSeven5,
    ThaiContentKeys.myanmarSeven6,
    ThaiContentKeys.myanmarSeven7,
  ];

  static MyanmarSevenResult calculate(ThaiBirthData birthData) {
    final resolution = SevenNumberChart.calculate(birthData);
    if (!resolution.hasChart) {
      return MyanmarSevenResult(
        myanmarKeys: const [],
        dominantMyanmarKey: null,
        chartNumbers: const [],
        chart: null,
        warnings: resolution.warnings,
      );
    }

    final chart = resolution.chart!;
    final keys = chart.row1Day
        .map((number) => _numberToKey[number - 1])
        .toList(growable: false);

    return MyanmarSevenResult(
      myanmarKeys: List<String>.unmodifiable(keys),
      dominantMyanmarKey: keys.first,
      chartNumbers: chart.row1Day,
      row4Sum: chart.row4Sum,
      chart: chart,
      warnings: resolution.warnings,
    );
  }
}

class MyanmarSevenResult {
  const MyanmarSevenResult({
    required this.myanmarKeys,
    required this.dominantMyanmarKey,
    required this.chartNumbers,
    required this.chart,
    this.row4Sum = const [],
    this.warnings = const [],
  });

  final List<String> myanmarKeys;
  final String? dominantMyanmarKey;
  final List<int> chartNumbers;
  final List<int> row4Sum;
  final SevenNumberChartResult? chart;
  final List<ProfileWarning> warnings;
}
