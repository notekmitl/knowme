import '../domain/models/astrology_fusion_lens_catalog.dart';
import '../domain/models/astrology_fusion_readiness.dart';
import 'astrology_fusion_lens_probe.dart';

/// Evaluates how many astrology lenses are ready for fusion entry.
class AstrologyFusionReadinessService {
  AstrologyFusionReadinessService({
    AstrologyFusionLensProbe? lensProbe,
  }) : _lensProbe = lensProbe ?? FirestoreAstrologyFusionLensProbe();

  final AstrologyFusionLensProbe _lensProbe;

  Future<AstrologyFusionReadiness> evaluate(String uid) async {
    final probe = await _lensProbe.probe(uid);
    final total = AstrologyFusionLensCatalog.totalLensCount;
    final completed = probe.completedLensIds.length;

    return AstrologyFusionReadiness(
      completedLensCount: completed,
      totalLensCount: total,
      status: AstrologyFusionReadiness.statusForCount(
        completedLensCount: completed,
        totalLensCount: total,
      ),
      completedLensIds: List.unmodifiable(probe.completedLensIds),
    );
  }
}
