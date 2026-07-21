import '../presentation/thai_internal_evidence_badge.dart';
import '../thai_canon_evidence_repository.dart';
import '../thai_canon_evidence_type.dart';
import '../thai_report_canon_evidence_enricher.dart';
import 'thai_canon_evidence_alignment_fixtures.dart';
import 'thai_canon_evidence_alignment_runner.dart';
import 'thai_internal_evidence_qa_validator.dart';

/// Runs formal internal evidence QA across deterministic fixtures.
abstract final class ThaiInternalEvidenceQaRunner {
  static Future<ThaiInternalEvidenceQaAudit> run({
    ThaiCanonEvidenceRepository? repository,
    List<ThaiCanonEvidenceAlignmentFixture>? fixtures,
  }) async {
    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final fixtureList = fixtures ?? ThaiCanonEvidenceAlignmentFixtures.all;
    final alignment = await ThaiCanonEvidenceAlignmentRunner.run(
      repository: repo,
      fixtures: fixtureList,
    );

    final results = <ThaiInternalEvidenceFixtureQaResult>[];
    for (final alignmentResult in alignment.fixtureResults) {
      results.add(
        ThaiInternalEvidenceQaValidator.auditFixture(
          fixtureId: alignmentResult.fixture.id,
          bundle: alignmentResult.bundle,
        ),
      );
    }

    return _aggregate(results);
  }

  static ThaiInternalEvidenceQaAudit _aggregate(
    List<ThaiInternalEvidenceFixtureQaResult> results,
  ) {
    final aggregateBadges = <String, int>{
      for (final c in ThaiInternalEvidenceBadgeCategory.values) c.wire: 0,
    };
    var totalMismatches = 0;
    var totalWeakPromoted = 0;
    var totalProvenanceGaps = 0;
    final categoriesProduced = <String>{};

    var withRuntime = 0;
    var withoutRuntime = 0;
    var ambiguous = 0;
    var conflict = 0;
    var missingPosition = 0;
    var noP17 = 0;
    var conflictPairs = 0;
    final uniqueConflictPairs = <String>{};
    final perFixtureRuntime = <Map<String, int>>[];

    var remedySkipped = 0;
    var remedyOnReport = 0;
    var remedyUserFacing = 0;
    final perFixtureRemedy = <int>[];

    for (final result in results) {
      totalMismatches += result.badgeMismatches.length;
      totalWeakPromoted += result.weakPromotedToStrong.length;
      totalProvenanceGaps += result.provenanceGaps.length;

      for (final entry in result.badgeCounts.entries) {
        if (entry.value > 0) {
          categoriesProduced.add(entry.key);
          aggregateBadges[entry.key] =
              (aggregateBadges[entry.key] ?? 0) + entry.value;
        }
      }

      final trace = result.bundle.trace;
      withRuntime += trace.lifePeriodsWithRuntimeStatus.length;
      withoutRuntime += trace.lifePeriodsWithoutRuntimeStatus.length;
      ambiguous += trace.runtimeStatusBlockedByAmbiguousPosition.length;
      conflict += trace.runtimeStatusBlockedBySourceConflict.length;
      missingPosition += trace.runtimeStatusBlockedByMissingPosition.length;
      noP17 += trace.runtimeStatusBlockedByNoP17Rule.length;
      uniqueConflictPairs.addAll(trace.conflictedArchetypePlanetPairs);

      perFixtureRuntime.add({
        'withRuntimeStatus': trace.lifePeriodsWithRuntimeStatus.length,
        'withoutRuntimeStatus': trace.lifePeriodsWithoutRuntimeStatus.length,
        'blockedAmbiguous': trace.runtimeStatusBlockedByAmbiguousPosition.length,
        'blockedSourceConflict':
            trace.runtimeStatusBlockedBySourceConflict.length,
        'conflictedPairs': trace.conflictedArchetypePlanetPairs.length,
        'blockedMissingPosition':
            trace.runtimeStatusBlockedByMissingPosition.length,
        'blockedNoP17Rule': trace.runtimeStatusBlockedByNoP17Rule.length,
      });

      remedySkipped += trace.skippedRemedyEvidenceCount;
      perFixtureRemedy.add(trace.skippedRemedyEvidenceCount);

      for (final attachment in result.bundle.attachments) {
        if (attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          remedyOnReport++;
        }
        if (attachment.userFacingAllowed &&
            attachment.evidenceType == ThaiCanonEvidenceType.remedyInternal) {
          remedyUserFacing++;
        }
      }
    }

    conflictPairs = uniqueConflictPairs.length;

    return ThaiInternalEvidenceQaAudit(
      fixtureResults: results,
      aggregateBadgeCounts: aggregateBadges,
      totalBadgeMismatches: totalMismatches,
      totalWeakPromoted: totalWeakPromoted,
      totalProvenanceGaps: totalProvenanceGaps,
      runtimeMetadata: ThaiInternalEvidenceRuntimeMetadataSummary(
        lifePeriodsWithRuntimeStatus: withRuntime,
        lifePeriodsWithoutRuntimeStatus: withoutRuntime,
        blockedAmbiguous: ambiguous,
        blockedSourceConflict: conflict,
        blockedMissingPosition: missingPosition,
        blockedNoP17Rule: noP17,
        conflictedArchetypePlanetPairs: conflictPairs,
        perFixture: perFixtureRuntime,
      ),
      remedySafety: ThaiInternalEvidenceRemedySafetySummary(
        skippedRemedyCountAggregate: remedySkipped,
        remedyAttachmentsOnReport: remedyOnReport,
        remedyUserFacingRows: remedyUserFacing,
        perFixtureSkippedCounts: perFixtureRemedy,
      ),
      allCategoriesProduced: categoriesProduced,
    );
  }
}
