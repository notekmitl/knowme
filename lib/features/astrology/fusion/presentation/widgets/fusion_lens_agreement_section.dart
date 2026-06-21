import 'package:flutter/material.dart';

import '../fusion_result_view_model.dart';
import 'fusion_consensus_widget.dart';

/// Section 2 — True fusion convergence visualization — V2.2.
class FusionLensAgreementSection extends StatelessWidget {
  const FusionLensAgreementSection({
    super.key,
    required this.items,
    this.centralThemes = const [],
    this.alignedCount,
    this.totalLenses = 3,
    this.consensusNarrative,
  });

  final List<FusionLensAgreementViewModel> items;
  final List<String> centralThemes;
  final int? alignedCount;
  final int totalLenses;
  final FusionConsensusNarrativeViewModel? consensusNarrative;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return FusionConsensusWidget(
      items: items,
      centralThemes: centralThemes,
      alignedCount: alignedCount,
      totalLenses: totalLenses,
      consensusNarrative: consensusNarrative,
    );
  }
}
