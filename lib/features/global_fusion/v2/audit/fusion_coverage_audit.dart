import 'package:knowme/features/global_fusion/foundation/contracts/global_fusion_input.dart';
import 'package:knowme/features/global_fusion/foundation/domain/global_fusion_snapshot.dart';

import '../domain/fusion_recovery_enums.dart';

/// FCR1 — tracks each mirror finding through V1 fusion pipeline.
class MirrorFindingCoverageEntry {
  const MirrorFindingCoverageEntry({
    required this.findingId,
    required this.findingType,
    required this.mirrorRoleId,
    required this.mirrorKey,
    required this.themeIds,
    required this.disposition,
    required this.filterRule,
  });

  final String findingId;
  final String findingType;
  final String mirrorRoleId;
  final String mirrorKey;
  final List<String> themeIds;
  final MirrorFindingDisposition disposition;
  final FusionCompressionRule? filterRule;
}

class FusionCoverageAuditReport {
  const FusionCoverageAuditReport({
    required this.totalMirrorFindings,
    required this.fusedCount,
    required this.filteredCount,
    required this.missingCount,
    required this.entries,
    required this.fusedFindingIds,
    required this.filteredFindingIds,
  });

  final int totalMirrorFindings;
  final int fusedCount;
  final int filteredCount;
  final int missingCount;
  final List<MirrorFindingCoverageEntry> entries;
  final List<String> fusedFindingIds;
  final List<String> filteredFindingIds;
}

abstract final class FusionCoverageAudit {
  static FusionCoverageAuditReport analyze({
    required GlobalFusionInput input,
    required GlobalFusionSnapshot foundationSnapshot,
  }) {
    final fusedIds = _fusedMirrorFindingIds(foundationSnapshot);
    final entries = <MirrorFindingCoverageEntry>[];

    for (final ref in input.mirrors) {
      final snapshot = ref.snapshot;

      for (final finding in snapshot.agreements) {
        entries.add(
          _entry(
            findingId: finding.id,
            findingType: 'agreement',
            mirrorRoleId: ref.mirrorRoleId,
            mirrorKey: finding.mirrorKey,
            themeIds: finding.themeIds,
            fusedIds: fusedIds,
            filterRule: FusionCompressionRule.crossMirrorAgreementRequiresTwoRoles,
          ),
        );
      }

      for (final finding in snapshot.tensions) {
        entries.add(
          _entry(
            findingId: finding.id,
            findingType: 'tension',
            mirrorRoleId: ref.mirrorRoleId,
            mirrorKey: '',
            themeIds: finding.themeIds,
            fusedIds: fusedIds,
            filterRule: FusionCompressionRule.tensionRequiresCrossRolePolarity,
          ),
        );
      }

      for (final finding in snapshot.reinforcements) {
        entries.add(
          _entry(
            findingId: finding.id,
            findingType: 'reinforcement',
            mirrorRoleId: ref.mirrorRoleId,
            mirrorKey: finding.mirrorKey,
            themeIds: finding.themeIds,
            fusedIds: fusedIds,
            filterRule: FusionCompressionRule.reinforcementRequiresCrossMirrorAgreement,
          ),
        );
      }

      for (final finding in snapshot.blindSpots) {
        entries.add(
          _entry(
            findingId: finding.id,
            findingType: 'blind_spot',
            mirrorRoleId: ref.mirrorRoleId,
            mirrorKey: finding.mirrorKey ?? '',
            themeIds: const [],
            fusedIds: fusedIds,
            filterRule: FusionCompressionRule.blindSpotRequiresCrossMirrorReflection,
          ),
        );
      }
    }

    entries.sort((a, b) => a.findingId.compareTo(b.findingId));

    final fused = entries.where((e) => e.disposition == MirrorFindingDisposition.fused).length;
    final filtered =
        entries.where((e) => e.disposition == MirrorFindingDisposition.filtered).length;

    return FusionCoverageAuditReport(
      totalMirrorFindings: entries.length,
      fusedCount: fused,
      filteredCount: filtered,
      missingCount: entries.length - fused - filtered,
      entries: entries,
      fusedFindingIds: entries
          .where((e) => e.disposition == MirrorFindingDisposition.fused)
          .map((e) => e.findingId)
          .toList(),
      filteredFindingIds: entries
          .where((e) => e.disposition == MirrorFindingDisposition.filtered)
          .map((e) => e.findingId)
          .toList(),
    );
  }

  static MirrorFindingCoverageEntry _entry({
    required String findingId,
    required String findingType,
    required String mirrorRoleId,
    required String mirrorKey,
    required List<String> themeIds,
    required Set<String> fusedIds,
    required FusionCompressionRule filterRule,
  }) {
    final disposition = fusedIds.contains(findingId)
        ? MirrorFindingDisposition.fused
        : MirrorFindingDisposition.filtered;

    return MirrorFindingCoverageEntry(
      findingId: findingId,
      findingType: findingType,
      mirrorRoleId: mirrorRoleId,
      mirrorKey: mirrorKey,
      themeIds: themeIds,
      disposition: disposition,
      filterRule: disposition == MirrorFindingDisposition.filtered ? filterRule : null,
    );
  }

  static Set<String> _fusedMirrorFindingIds(GlobalFusionSnapshot snapshot) {
    final ids = <String>{};
    for (final finding in snapshot.agreements) {
      ids.addAll(finding.mirrorFindingIds);
    }
    for (final finding in snapshot.tensions) {
      ids.add(finding.positiveMirrorFindingId);
      ids.add(finding.tensionMirrorFindingId);
    }
    for (final finding in snapshot.reinforcements) {
      ids.addAll(finding.mirrorFindingIds);
    }
    for (final finding in snapshot.blindSpots) {
      ids.add(finding.reflectingMirrorFindingId);
      ids.add(finding.blindMirrorFindingId);
    }
    return ids;
  }
}
