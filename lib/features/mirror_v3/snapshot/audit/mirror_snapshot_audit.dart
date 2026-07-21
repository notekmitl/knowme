import '../contracts/knowme_mirror_snapshot_identity_contract.dart';
import '../models/knowme_mirror_snapshot.dart';

/// MV3.8 snapshot quality audit report.
class MirrorSnapshotAuditReport {
  const MirrorSnapshotAuditReport({
    required this.passed,
    required this.issues,
    required this.missingLineageFields,
    required this.missingEvidenceCount,
    required this.orphanFindingIds,
    required this.invalidConfidence,
    required this.invalidCoverage,
    required this.invalidIdentity,
  });

  final bool passed;
  final List<String> issues;
  final List<String> missingLineageFields;
  final int missingEvidenceCount;
  final List<String> orphanFindingIds;
  final bool invalidConfidence;
  final bool invalidCoverage;
  final bool invalidIdentity;

  Map<String, dynamic> toMap() {
    return {
      'passed': passed,
      'issues': issues,
      'missingLineageFields': missingLineageFields,
      'missingEvidenceCount': missingEvidenceCount,
      'orphanFindingIds': orphanFindingIds,
      'invalidConfidence': invalidConfidence,
      'invalidCoverage': invalidCoverage,
      'invalidIdentity': invalidIdentity,
    };
  }
}

/// MV3.8 quality audit for persisted mirror snapshots.
abstract final class MirrorSnapshotAudit {
  static MirrorSnapshotAuditReport audit(KnowMeMirrorSnapshot snapshot) {
    final issues = <String>[];
    final missingLineage = _missingLineageFields(snapshot);
    final missingEvidence = _missingEvidenceCount(snapshot);
    final orphanFindings = _orphanFindingIds(snapshot);
    final invalidConfidence = _invalidConfidence(snapshot);
    final invalidCoverage = _invalidCoverage(snapshot);
    final invalidIdentity = _invalidIdentity(snapshot);

    if (missingLineage.isNotEmpty) {
      issues.add('missing lineage fields: ${missingLineage.join(', ')}');
    }
    if (missingEvidence > 0) {
      issues.add('missing evidence rows: $missingEvidence finding(s)');
    }
    if (orphanFindings.isNotEmpty) {
      issues.add('orphan findings: ${orphanFindings.join(', ')}');
    }
    if (invalidConfidence) {
      issues.add('invalid confidence: ${snapshot.confidence.composite}');
    }
    if (invalidCoverage) {
      issues.add('invalid coverage: ${snapshot.coverage.weightedCoverage}');
    }
    if (invalidIdentity) {
      issues.add('invalid identity: ${snapshot.snapshotId}');
    }
    if (snapshot.evidence.isEmpty && snapshot.metadata.mirrorCount > 0) {
      issues.add('mirrors present but evidence list is empty');
    }

    return MirrorSnapshotAuditReport(
      passed: issues.isEmpty,
      issues: issues,
      missingLineageFields: missingLineage,
      missingEvidenceCount: missingEvidence,
      orphanFindingIds: orphanFindings,
      invalidConfidence: invalidConfidence,
      invalidCoverage: invalidCoverage,
      invalidIdentity: invalidIdentity,
    );
  }

  static bool _invalidIdentity(KnowMeMirrorSnapshot snapshot) {
    final identity = snapshot.identity;

    if (identity.snapshotId.trim().isEmpty ||
        identity.mirrorBundleId.trim().isEmpty ||
        identity.mirrorScopeId.trim().isEmpty ||
        identity.snapshotVersion.trim().isEmpty) {
      return true;
    }

    if (identity.mirrorId != identity.mirrorBundleId) {
      return true;
    }

    final expectedSnapshotId = KnowMeMirrorSnapshotIdentityContract.snapshotId(
      mirrorScopeId: identity.mirrorScopeId,
      mirrorBundleId: identity.mirrorBundleId,
      structuralHash: snapshot.structuralHash,
    );

    return identity.snapshotId != expectedSnapshotId;
  }

  static List<String> _missingLineageFields(KnowMeMirrorSnapshot snapshot) {
    final missing = <String>[];
    final lineage = snapshot.lineage;

    if (lineage.mirrorScopeId.trim().isEmpty) {
      missing.add('mirrorScopeId');
    }

    final hasSource = lineage.astrologyThemeSnapshotId != null ||
        lineage.mbtiLensSnapshotId != null ||
        lineage.bigFiveLensSnapshotId != null ||
        lineage.eqLensSnapshotId != null;

    if (!hasSource) {
      missing.add('sourceSnapshotIds');
    }

    if (lineage.sourceSnapshotVersions.isEmpty) {
      missing.add('sourceSnapshotVersions');
    }

    return missing;
  }

  static int _missingEvidenceCount(KnowMeMirrorSnapshot snapshot) {
    var missing = 0;
    final evidenceThemes = snapshot.evidence
        .expand((row) => [row.sourceThemeId, ...row.themeIds])
        .toSet();

    void checkFindingThemes(List<String> themeIds) {
      if (themeIds.isEmpty) {
        missing++;
        return;
      }
      final grounded = themeIds.any(evidenceThemes.contains);
      if (!grounded) missing++;
    }

    for (final agreement in snapshot.agreements) {
      checkFindingThemes(agreement.themeIds);
    }
    for (final tension in snapshot.tensions) {
      checkFindingThemes(tension.themeIds);
    }
    for (final reinforcement in snapshot.reinforcements) {
      checkFindingThemes(reinforcement.themeIds);
    }

    return missing;
  }

  static List<String> _orphanFindingIds(KnowMeMirrorSnapshot snapshot) {
    final mirrorKeys = snapshot.evidence.map((row) => row.mirrorKey).toSet();
    final orphans = <String>[];

    for (final agreement in snapshot.agreements) {
      if (!mirrorKeys.contains(agreement.mirrorKey)) {
        orphans.add(agreement.id);
      }
    }

    return orphans;
  }

  static bool _invalidConfidence(KnowMeMirrorSnapshot snapshot) {
    final value = snapshot.confidence.composite;
    return value.isNaN || value.isInfinite || value < 0 || value > 1;
  }

  static bool _invalidCoverage(KnowMeMirrorSnapshot snapshot) {
    final value = snapshot.coverage.weightedCoverage;
    return value.isNaN || value.isInfinite || value < 0 || value > 1;
  }
}
