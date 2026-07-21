import '../../foundation/domain/global_fusion_snapshot.dart';
import 'global_fusion_recovered_snapshot.dart';

/// Composed GF1 + GF2 output for downstream HM/HP/Narrative consumers.
class GlobalFusionComposedSnapshot {
  const GlobalFusionComposedSnapshot({
    required this.fusionSnapshot,
    required this.foundationSnapshot,
    required this.recovery,
    required this.supplementalAgreementCount,
    required this.supplementalReinforcementCount,
    required this.composedAt,
  });

  final GlobalFusionSnapshot fusionSnapshot;
  final GlobalFusionSnapshot foundationSnapshot;
  final GlobalFusionRecoveredSnapshot recovery;
  final int supplementalAgreementCount;
  final int supplementalReinforcementCount;
  final DateTime composedAt;
}
