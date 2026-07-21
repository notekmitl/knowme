import 'package:firebase_auth/firebase_auth.dart';

import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/astrology_fusion_status.dart';
import '../domain/models/astrology_fusion_real_input.dart';
import '../analytics/astrology_fusion_validation_events.dart';
import '../analytics/fusion_analytics.dart';
import 'astrology_fusion_lens_probe.dart';
import 'astrology_fusion_regeneration_service.dart';

class AstrologyFusionLoadOutput {
  const AstrologyFusionLoadOutput({
    required this.result,
    required this.status,
    required this.usedSnapshot,
    required this.lensCount,
    required this.input,
  });

  final AstrologyFusionResult result;
  final AstrologyFusionStatus status;
  final bool usedSnapshot;
  final int lensCount;
  final AstrologyFusionRealInput input;
}

/// Production loader — snapshot-first, no mock fallback.
class AstrologyFusionLoader {
  AstrologyFusionLoader({
    AstrologyFusionLensProbe? lensProbe,
    AstrologyFusionRegenerationService? regenerationService,
  })  : _lensProbe = lensProbe ?? FirestoreAstrologyFusionLensProbe(),
        _regenerationService =
            regenerationService ?? AstrologyFusionRegenerationService();

  final AstrologyFusionLensProbe _lensProbe;
  final AstrologyFusionRegenerationService _regenerationService;

  Future<AstrologyFusionLoadOutput> load({
    String? uid,
  }) async {
    final resolvedUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.isEmpty) {
      throw StateError('Astrology Fusion requires a signed-in user.');
    }

    final probe = await _lensProbe.probe(resolvedUid);
    if (!probe.input.hasAny) {
      throw StateError('No astrology lens data available for fusion.');
    }

    final loadResult = await _regenerationService.loadOrGenerate(
      uid: resolvedUid,
      input: probe.input,
    );

    final lensCount = probe.completedLensIds.length;
    FusionAnalytics.tracker.trackFusionOpened(
      FusionOpenedPayload(
        lensCount: lensCount,
        status: loadResult.status.name,
        snapshotUsed: loadResult.usedSnapshot,
      ),
    );

    return AstrologyFusionLoadOutput(
      result: loadResult.snapshot.toResult(),
      status: loadResult.status,
      usedSnapshot: loadResult.usedSnapshot,
      lensCount: lensCount,
      input: probe.input,
    );
  }
}
