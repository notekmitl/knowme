import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_reader_v2.dart';

/// Reader V3 keeps the accepted practical Thai interpretation layer while the
/// calculation contract moves to historical-zone apparent solar time.
///
/// The returned sections cover overview, identity, work, money, relationships,
/// cautions, the current ten-year cycle, and the current year. Missing timing
/// facts remain explicit instead of being filled with a prediction.
abstract final class BaziReaderV3 {
  static const interpretationContractId = 'knowme_bazi_reader_th_v3';

  static BaziReaderV2Reading build(BaziChartModel chart, {DateTime? asOf}) {
    return BaziReaderV2.build(chart, asOf: asOf);
  }
}
