import '../../constants/knowme_mirror_version_contract.dart';
import '../../engine/knowme_mirror_engine.dart';
import '../../engine/models/knowme_mirror_agreement.dart';
import '../../engine/models/knowme_mirror_engine_input.dart';
import '../../engine/models/knowme_mirror_engine_result.dart';
import '../../engine/models/knowme_mirror_blind_spot.dart';
import '../../engine/models/knowme_mirror_reinforcement.dart';
import '../../engine/models/knowme_mirror_tension.dart';
import '../../promotion/constants/mirror_promotion_version.dart';
import '../../promotion/domain/knowme_mirror_promoted_finding.dart';
import '../../promotion/engines/mirror_promotion_engine.dart';
import '../../../global_fusion/v2/config/global_fusion_recovery_config.dart';
import '../../enums/knowme_mirror_dimension_id.dart';
import '../../enums/knowme_mirror_pattern_type.dart';
import '../../enums/knowme_mirror_source_type.dart';
import '../../enums/knowme_mirror_system_id.dart';
import '../../models/knowme_mirror_lineage_chain.dart';
import '../../models/knowme_mirror_object.dart';
import '../constants/knowme_mirror_snapshot_version_contract.dart';
import '../contracts/knowme_mirror_snapshot_identity_contract.dart';
import '../models/knowme_mirror_snapshot.dart';
import '../models/knowme_mirror_snapshot_confidence.dart';
import '../models/knowme_mirror_snapshot_coverage.dart';
import '../models/knowme_mirror_snapshot_evidence.dart';
import '../models/knowme_mirror_snapshot_findings.dart';
import '../models/knowme_mirror_snapshot_identity.dart';
import '../models/knowme_mirror_snapshot_lineage.dart';
import '../models/knowme_mirror_snapshot_metadata.dart';

/// Builds immutable [KnowMeMirrorSnapshot] from frozen MV1 engine output.
abstract final class KnowMeMirrorSnapshotBuilder {
  static KnowMeMirrorSnapshot fromReflectInput(
    KnowMeMirrorEngineInput input, {
    DateTime? createdAt,
    bool applyPromotion = true,
  }) {
    final engineResult = KnowMeMirrorEngine.reflect(input);
    final promotedFindings = applyPromotion &&
            GlobalFusionRecoveryConfig.enabled &&
            GlobalFusionRecoveryConfig.promotionEnabled
        ? MirrorPromotionEngine.apply(
            engineResult: engineResult,
            input: input,
          )
        : const <KnowMeMirrorPromotedFinding>[];

    return fromEngineResult(
      engineResult,
      promotedFindings: promotedFindings,
      createdAt: createdAt,
    );
  }

  static KnowMeMirrorSnapshot fromEngineResult(
    KnowMeMirrorEngineResult result, {
    List<KnowMeMirrorPromotedFinding> promotedFindings = const [],
    DateTime? createdAt,
  }) {
    final bundle = result.bundle;
    final lineage = bundle.lineage;
    final mirrorObjectIds = bundle.mirrors.map((mirror) => mirror.mirrorId).toList()
      ..sort();

    final snapshotId = KnowMeMirrorSnapshotIdentityContract.snapshotId(
      mirrorScopeId: bundle.mirrorScopeId,
      mirrorBundleId: bundle.mirrorBundleId,
      structuralHash: bundle.structuralHash,
    );

    final identity = KnowMeMirrorSnapshotIdentity(
      snapshotId: snapshotId,
      mirrorId: bundle.mirrorBundleId,
      mirrorBundleId: bundle.mirrorBundleId,
      mirrorScopeId: bundle.mirrorScopeId,
      mirrorObjectIds: mirrorObjectIds,
      snapshotVersion: KnowMeMirrorSnapshotVersionContract.snapshotVersion,
    );

    final systems = <String>{};
    final dimensions = <String>{};
    final themeIds = <String>{};
    var signalCount = 0;

    for (final mirror in bundle.mirrors) {
      dimensions.add(mirror.mirrorDimension.id);
      themeIds.addAll(mirror.sourceThemeIds);
      for (final system in mirror.sourceSystems) {
        systems.add(system.id);
      }
      signalCount += mirror.evidenceRefs.signalIds.length;
    }

    final coverage = KnowMeMirrorSnapshotCoverage(
      availableSystems: systems.toList()..sort(),
      coveredDimensions: dimensions.toList()..sort(),
      signalCount: signalCount,
      weightedCoverage: _weightedCoverage(systems.length, dimensions.length),
    );

    final confidence = KnowMeMirrorSnapshotConfidence(
      composite: result.compositeConfidence,
      agreementBoostEligible: result.agreements.isNotEmpty,
      tensionPenaltyApplied: result.tensions.isNotEmpty,
      reinforcementBoostEligible: result.reinforcements.isNotEmpty,
    );

    final metadata = KnowMeMirrorSnapshotMetadata(
      mirrorCount: bundle.mirrors.length,
      findingCount: result.agreements.length +
          result.tensions.length +
          result.reinforcements.length +
          result.blindSpots.length,
      sourceSystemCount: systems.length,
      sourceThemeCount: themeIds.length,
      engineVersion: KnowMeMirrorVersionContract.mirrorEngineVersion,
      domainVersion: bundle.mirrorDomainVersion,
    );

    return KnowMeMirrorSnapshot(
      identity: identity,
      metadata: metadata,
      coverage: coverage,
      confidence: confidence,
      agreements: result.agreements.map(_agreement).toList(growable: false),
      tensions: result.tensions.map(_tension).toList(growable: false),
      reinforcements:
          result.reinforcements.map(_reinforcement).toList(growable: false),
      blindSpots: result.blindSpots.map(_blindSpot).toList(growable: false),
      evidence: _evidenceRows(bundle.mirrors),
      promotedFindings: List.unmodifiable(promotedFindings),
      lineage: _lineage(lineage, promotedFindings),
      structuralHash: bundle.structuralHash,
      createdAt: (createdAt ?? bundle.generatedAt).toUtc(),
      engineVersion: KnowMeMirrorVersionContract.mirrorEngineVersion,
    );
  }

  static double _weightedCoverage(int systemCount, int dimensionCount) {
    if (systemCount <= 0 || dimensionCount <= 0) return 0;
    if (systemCount >= 2 && dimensionCount >= 4) return 1.0;
    if (systemCount >= 2) return 0.85;
    return 0.6;
  }

  static KnowMeMirrorSnapshotAgreement _agreement(
    KnowMeMirrorAgreement agreement,
  ) {
    return KnowMeMirrorSnapshotAgreement(
      id: agreement.id,
      patternType: agreement.patternType.id,
      mirrorKey: agreement.mirrorKey,
      mirrorDimension: agreement.mirrorDimension.id,
      themeIds: List<String>.from(agreement.themeIds),
      supportingSystems:
          agreement.supportingSystems.map((system) => system.id).toList(),
      supportingLensKeys: List<String>.from(agreement.supportingLensKeys),
      confidence: agreement.confidence,
    );
  }

  static KnowMeMirrorSnapshotTension _tension(KnowMeMirrorTension tension) {
    return KnowMeMirrorSnapshotTension(
      id: tension.id,
      patternType: tension.patternType.id,
      mirrorDimension: tension.mirrorDimension.id,
      themeIds: List<String>.from(tension.themeIds),
      patternFamilies: List<String>.from(tension.patternFamilies),
      supportingSystems:
          tension.supportingSystems.map((system) => system.id).toList(),
      supportingLensKeys: List<String>.from(tension.supportingLensKeys),
      reasonCode: tension.reasonCode,
    );
  }

  static KnowMeMirrorSnapshotReinforcement _reinforcement(
    KnowMeMirrorReinforcement reinforcement,
  ) {
    return KnowMeMirrorSnapshotReinforcement(
      id: reinforcement.id,
      patternType: reinforcement.patternType.id,
      mirrorKey: reinforcement.mirrorKey,
      mirrorDimension: reinforcement.mirrorDimension.id,
      themeIds: List<String>.from(reinforcement.themeIds),
      supportingSystem: reinforcement.supportingSystem.id,
      supportingLensKey: reinforcement.supportingLensKey,
      evidenceCount: reinforcement.evidenceCount,
      structuralWeight: reinforcement.structuralWeight,
    );
  }

  static KnowMeMirrorSnapshotBlindSpot _blindSpot(
    KnowMeMirrorBlindSpot blindSpot,
  ) {
    return KnowMeMirrorSnapshotBlindSpot(
      id: blindSpot.id,
      patternType: blindSpot.patternType.id,
      mirrorDimension: blindSpot.mirrorDimension.id,
      mirrorKey: blindSpot.mirrorKey,
      reasonCode: blindSpot.reasonCode,
      availableSystems: List<String>.from(blindSpot.availableSystems),
    );
  }

  static KnowMeMirrorSnapshotLineage _lineage(
    KnowMeMirrorLineageChain lineage,
    List<KnowMeMirrorPromotedFinding> promotedFindings,
  ) {
    return KnowMeMirrorSnapshotLineage(
      mirrorScopeId: lineage.mirrorScopeId,
      astrologyThemeSnapshotId: lineage.astrologyThemeSnapshotId,
      astrologyThemeBundleId: lineage.astrologyThemeBundleId,
      astrologyMeaningSnapshotId: lineage.astrologyMeaningSnapshotId,
      mbtiLensSnapshotId: lineage.mbtiLensSnapshotId,
      bigFiveLensSnapshotId: lineage.bigFiveLensSnapshotId,
      eqLensSnapshotId: lineage.eqLensSnapshotId,
      personalityOnly: lineage.personalityOnly,
      sourceSnapshotVersions:
          Map<String, String>.from(lineage.sourceSnapshotVersions),
      promotionVersion: promotedFindings.isEmpty
          ? null
          : MirrorPromotionVersion.promotionVersion,
      promotionRuleIds: promotedFindings
          .map((item) => item.promotionRuleId)
          .toSet()
          .toList()
        ..sort(),
    );
  }

  static List<KnowMeMirrorSnapshotEvidenceRow> _evidenceRows(
    List<KnowMeMirrorObject> mirrors,
  ) {
    final rows = <KnowMeMirrorSnapshotEvidenceRow>[];

    for (final mirror in mirrors) {
      final refs = mirror.evidenceRefs;
      for (final evidenceRef in refs.evidenceRefs) {
        rows.add(
          KnowMeMirrorSnapshotEvidenceRow(
            mirrorObjectId: mirror.mirrorId,
            mirrorKey: mirror.mirrorKey,
            systemId: evidenceRef.systemId.id,
            sourceType: evidenceRef.sourceType.id,
            sourceThemeId: evidenceRef.sourceThemeId,
            sourceSnapshotId: evidenceRef.sourceSnapshotId,
            ruleId: evidenceRef.ruleId,
            weight: evidenceRef.weight,
            themeIds: List<String>.from(refs.themeIds),
            interpretationIds: List<String>.from(refs.interpretationIds),
            signalIds: List<String>.from(refs.signalIds),
            meaningIds: List<String>.from(refs.meaningIds),
          ),
        );
      }
    }

    rows.sort((a, b) {
      final objectCompare = a.mirrorObjectId.compareTo(b.mirrorObjectId);
      if (objectCompare != 0) return objectCompare;
      return a.sourceThemeId.compareTo(b.sourceThemeId);
    });

    return rows;
  }
}
