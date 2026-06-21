import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import 'global_fusion_supplemental_findings.dart';

/// FCR4 — V2 recovery output wrapping frozen V1 foundation snapshot.
class GlobalFusionRecoveredSnapshot {
  const GlobalFusionRecoveredSnapshot({
    required this.foundationSnapshot,
    required this.supplementalReinforcements,
    required this.supplementalAgreements,
    required this.supplementalThemeSignals,
    required this.recoveryVersion,
    required this.createdAt,
  });

  final GlobalFusionSnapshot foundationSnapshot;
  final List<GlobalFusionSupplementalReinforcement> supplementalReinforcements;
  final List<GlobalFusionSupplementalAgreement> supplementalAgreements;
  final List<GlobalFusionSupplementalThemeSignal> supplementalThemeSignals;
  final String recoveryVersion;
  final DateTime createdAt;

  int get supplementalFindingCount =>
      supplementalReinforcements.length +
      supplementalAgreements.length +
      supplementalThemeSignals.length;

  int get totalFindingCount =>
      foundationSnapshot.agreements.length +
      foundationSnapshot.tensions.length +
      foundationSnapshot.reinforcements.length +
      foundationSnapshot.blindSpots.length +
      supplementalFindingCount;
}
