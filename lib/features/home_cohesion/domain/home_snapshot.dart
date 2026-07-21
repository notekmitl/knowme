import 'package:knowme/features/exploration_overview/domain/discovery_item.dart';
import 'package:knowme/features/exploration_overview/domain/exploration_overview.dart';

import 'home_fusion_summary.dart';
import 'home_mirror_summary.dart';

/// Unified read model for Home / Discovery cohesion (HC-F0 — no UI).
class HomeSnapshot {
  const HomeSnapshot({
    required this.version,
    required this.overview,
    required this.discoveryItems,
    required this.mirrorSummary,
    required this.fusionSummary,
  });

  static const String versionId = 'home_snapshot.v1';

  final String version;
  final ExplorationOverview overview;
  final List<DiscoveryItem> discoveryItems;
  final HomeMirrorSummary mirrorSummary;
  final HomeFusionSummary fusionSummary;
}
