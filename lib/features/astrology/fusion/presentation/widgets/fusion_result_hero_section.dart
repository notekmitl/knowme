import 'package:flutter/material.dart';

import '../fusion_result_view_model.dart';
import 'fusion_story_hero.dart';

/// Section 1 — Story hero wrapper — V2.2.
class FusionResultHeroSection extends StatelessWidget {
  const FusionResultHeroSection({
    super.key,
    required this.data,
    this.lensTitles = const [],
    this.alignedCount = 0,
    this.totalLenses = 3,
    this.onExploreDetails,
  });

  final FusionHeroViewModel data;
  final List<String> lensTitles;
  final int alignedCount;
  final int totalLenses;
  final VoidCallback? onExploreDetails;

  @override
  Widget build(BuildContext context) {
    return FusionStoryHero(
      data: data,
      lensTitles: lensTitles,
      alignedCount: alignedCount,
      totalLenses: totalLenses,
      onExploreDetails: onExploreDetails,
    );
  }
}
