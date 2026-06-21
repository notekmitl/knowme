import '../models/knowme_mirror_agreement.dart';
import '../models/knowme_mirror_blind_spot.dart';
import '../../models/knowme_mirror_chart_bundle.dart';
import '../models/knowme_mirror_reinforcement.dart';
import '../models/knowme_mirror_tension.dart';

/// Full MV1 engine output.
class KnowMeMirrorEngineResult {
  const KnowMeMirrorEngineResult({
    required this.bundle,
    required this.agreements,
    required this.tensions,
    required this.reinforcements,
    required this.blindSpots,
    required this.compositeConfidence,
  });

  final KnowMeMirrorChartBundle bundle;
  final List<KnowMeMirrorAgreement> agreements;
  final List<KnowMeMirrorTension> tensions;
  final List<KnowMeMirrorReinforcement> reinforcements;
  final List<KnowMeMirrorBlindSpot> blindSpots;
  final double compositeConfidence;
}
