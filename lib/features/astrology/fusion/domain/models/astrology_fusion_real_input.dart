import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';

/// Real lens payloads for [AstrologyFusionGenerator.generateFromRealData].
class AstrologyFusionRealInput {
  const AstrologyFusionRealInput({
    this.western,
    this.bazi,
    this.thai,
  });

  final AstrologyChartModel? western;
  final BaziChartModel? bazi;
  final ThaiMirrorResult? thai;

  bool get hasAny => western != null || bazi != null || thai != null;
}
