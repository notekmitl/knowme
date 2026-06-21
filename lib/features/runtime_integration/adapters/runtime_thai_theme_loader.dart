import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/astrology/thai/interpretation/thai_interpretation_engine.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';
import 'package:knowme/features/astrology/thai/signal/thai_signal_extractor.dart';
import 'package:knowme/features/astrology/thai/theme_v2/models/thai_theme_bundle.dart';
import 'package:knowme/features/astrology/thai/theme_v2/thai_theme_engine.dart';

/// RT2 — loads real Thai theme snapshot via foundation → signal → interpretation → theme.
abstract final class RuntimeThaiThemeLoader {
  static ThaiThemeBundle loadFromBirthData(ThaiBirthData birthData) {
    final chart = ThaiChartEngine.generate(birthData);
    final signalResult = ThaiSignalExtractor.extract(
      ThaiSignalExtractorInput(chart: chart, birthData: birthData),
    );
    final interpretationResult =
        ThaiInterpretationEngine.interpret(signalResult.bundle);
    final themeResult = ThaiThemeEngine.aggregate(interpretationResult.bundle);
    return themeResult.bundle;
  }

  static ThaiThemeBundle loadQaProfile() {
    return loadFromBirthData(ThaiMirrorPipeline.sampleQaBirthData());
  }
}
