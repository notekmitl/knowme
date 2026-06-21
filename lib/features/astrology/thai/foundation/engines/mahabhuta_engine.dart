import '../../content/models/thai_content_key.dart';
import '../chart/seven_number_chart.dart';
import '../models/profile_warning.dart';
import '../models/thai_birth_data.dart';

/// Mahabhuta Position layer — 4-row chart metadata + canonical position keys.
///
/// Position key activation from กาลโยค is TODO — V1.1 emits all 7 canonical
/// keys and stores Row 4 sums as audit metadata.
abstract final class MahabhutaEngine {
  static MahabhutaResult calculate(ThaiBirthData birthData) {
    final resolution = SevenNumberChart.calculate(birthData);
    if (!resolution.hasChart) {
      return MahabhutaResult(
        mahabhutaPositionKeys: const [],
        chartNumbers: const [],
        row4Sum: const [],
        chart: null,
        warnings: resolution.warnings,
      );
    }

    final chart = resolution.chart!;

    return MahabhutaResult(
      mahabhutaPositionKeys:
          List<String>.unmodifiable(ThaiContentKeys.allMahabhutaPosition),
      chartNumbers: chart.row4Sum,
      row4Sum: chart.row4Sum,
      chart: chart,
      warnings: resolution.warnings,
    );
  }
}

class MahabhutaResult {
  const MahabhutaResult({
    required this.mahabhutaPositionKeys,
    required this.chartNumbers,
    required this.chart,
    this.row4Sum = const [],
    this.warnings = const [],
  });

  final List<String> mahabhutaPositionKeys;
  final List<int> chartNumbers;
  final List<int> row4Sum;
  final SevenNumberChartResult? chart;
  final List<ProfileWarning> warnings;
}

/// Open questions for Mahabhuta position activation (V1.1).
abstract final class MahabhutaEngineOpenQuestions {
  static const positionActivation =
      'TODO: Mahabhuta position prominence requires กาลโยค layer — '
      'not derivable from 4-row chart alone';
  static const goldenCases =
      'TODO: No Mahabhuta-specific golden cases in 4-base texts';
}
