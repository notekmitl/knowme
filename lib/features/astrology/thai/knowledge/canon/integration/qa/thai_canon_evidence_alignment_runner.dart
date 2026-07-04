import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline.dart';

import '../thai_canon_evidence_type.dart';
import '../thai_canon_evidence_repository.dart';
import '../thai_report_canon_evidence_enricher.dart';
import '../thai_mirror_canon_evidence_bundle.dart';
import 'thai_canon_evidence_alignment_classification.dart';
import 'thai_canon_evidence_alignment_classifier.dart';
import 'thai_canon_evidence_alignment_fixtures.dart';

/// Per-fixture audit snapshot.
class ThaiCanonEvidenceAlignmentFixtureResult {
  const ThaiCanonEvidenceAlignmentFixtureResult({
    required this.fixture,
    required this.bundle,
    required this.records,
    required this.lagnaKey,
    required this.lagnaLordKey,
    required this.mahabhutaKeys,
    required this.sectionsWithEvidence,
    required this.sectionsWithoutEvidence,
  });

  final ThaiCanonEvidenceAlignmentFixture fixture;
  final ThaiMirrorCanonEvidenceBundle bundle;
  final List<ThaiCanonEvidenceAlignmentRecord> records;
  final String lagnaKey;
  final String lagnaLordKey;
  final List<String> mahabhutaKeys;
  final List<String> sectionsWithEvidence;
  final List<String> sectionsWithoutEvidence;

  int get attachmentCount => bundle.attachmentCount;
  int get evidenceRefCount => bundle.totalEvidenceRefs;

  Iterable<ThaiCanonEvidenceAlignmentRecord> get attachmentRecords =>
      records.where((r) => r.attachmentIndex != null);
}

/// Aggregated alignment audit across all fixtures.
class ThaiCanonEvidenceAlignmentAudit {
  const ThaiCanonEvidenceAlignmentAudit({
    required this.fixtureResults,
    required this.classificationCounts,
    required this.totalReportSections,
    required this.sectionsWithStrongMatch,
    required this.sectionsWithWeakEvidence,
    required this.sectionsWithNoEvidence,
    required this.totalOutOfCanonScopeSignals,
    required this.totalInCanonScopeUnmapped,
    required this.totalTraceOnlyCandidates,
    required this.totalUnmappedSignals,
    required this.totalSkippedRemedyCount,
    required this.totalSkippedTaksaCount,
    required this.totalSkippedLookupTableCount,
    required this.totalSkippedPeriodStatusNotes,
    required this.totalLifePeriodsWithoutRuntimeStatus,
    required this.topOutOfCanonScopeKeys,
    required this.topInCanonScopeUnmappedKeys,
    required this.topUnmappedRuntimeKeys,
    required this.topUnusedCanonDomains,
    required this.falseConfidenceRisks,
    required this.integrationReadiness,
    required this.canonUnitIdsUsed,
  });

  final List<ThaiCanonEvidenceAlignmentFixtureResult> fixtureResults;
  final Map<ThaiCanonEvidenceAlignmentClassification, int> classificationCounts;
  final int totalReportSections;
  final int sectionsWithStrongMatch;
  final int sectionsWithWeakEvidence;
  final int sectionsWithNoEvidence;
  final int totalOutOfCanonScopeSignals;
  final int totalInCanonScopeUnmapped;
  final int totalTraceOnlyCandidates;
  final int totalUnmappedSignals;
  final int totalSkippedRemedyCount;
  final int totalSkippedTaksaCount;
  final int totalSkippedLookupTableCount;
  final int totalSkippedPeriodStatusNotes;
  final int totalLifePeriodsWithoutRuntimeStatus;
  final List<MapEntry<String, int>> topOutOfCanonScopeKeys;
  final List<MapEntry<String, int>> topInCanonScopeUnmappedKeys;
  final List<MapEntry<String, int>> topUnmappedRuntimeKeys;
  final List<MapEntry<String, int>> topUnusedCanonDomains;
  final List<String> falseConfidenceRisks;
  final Map<String, ThaiCanonEvidenceIntegrationReadiness> integrationReadiness;
  final Set<String> canonUnitIdsUsed;
}

/// False-confidence patterns surfaced by the audit.
abstract final class ThaiCanonEvidenceFalseConfidencePatterns {
  static const planetAttributeOnPersonality =
      'Planet attribute evidence attached to lagna-lord personality sections '
      'may look authoritative but only weakly supports broad copy';

  static const lifePeriodOnTimelineOnly =
      'Life-period structural evidence attaches to timeline anchors, not '
      'narrative prediction sections consumers read';

  static const mahabhutWithLegacyCopy =
      'Mahabhut STRONG_MATCH on structural keys while Mirror sections still '
      'render legacy hardcoded prose';

  static const predictionRuleBulkAttach =
      'Bulk periodStatus prediction-rule evidence is internal metadata only '
      'and does not support full prediction prose';
}

/// Domain readiness derived from aggregate alignment metrics.
abstract final class ThaiCanonEvidenceIntegrationReadinessMatrix {
  static Map<String, ThaiCanonEvidenceIntegrationReadiness> evaluate(
    ThaiCanonEvidenceAlignmentAudit audit,
  ) {
    final strong = audit.classificationCounts[
            ThaiCanonEvidenceAlignmentClassification.strongMatch] ??
        0;
    final weak = audit.classificationCounts[
            ThaiCanonEvidenceAlignmentClassification.relatedButWeak] ??
        0;

    return {
      'Mahabhut position evidence': strong > 0
          ? ThaiCanonEvidenceIntegrationReadiness.readyForInternalBadge
          : ThaiCanonEvidenceIntegrationReadiness.needsBetterMapping,
      'planet/domain evidence': weak > strong ~/ 2
          ? ThaiCanonEvidenceIntegrationReadiness.needsBetterMapping
          : ThaiCanonEvidenceIntegrationReadiness.readyForInternalBadge,
      'planet attribute evidence':
          ThaiCanonEvidenceIntegrationReadiness.needsBetterMapping,
      'life-period structural evidence':
          ThaiCanonEvidenceIntegrationReadiness.readyForInternalBadge,
      'prediction rule evidence':
          ThaiCanonEvidenceIntegrationReadiness.internalOnly,
      'Taksa evidence': ThaiCanonEvidenceIntegrationReadiness.doNotDisplay,
      'remedy evidence': ThaiCanonEvidenceIntegrationReadiness.doNotDisplay,
      'lookup table evidence': ThaiCanonEvidenceIntegrationReadiness.internalOnly,
    };
  }
}

/// Runs deterministic alignment QA across [ThaiCanonEvidenceAlignmentFixtures].
abstract final class ThaiCanonEvidenceAlignmentRunner {
  static Future<ThaiCanonEvidenceAlignmentAudit> run({
    ThaiCanonEvidenceRepository? repository,
    List<ThaiCanonEvidenceAlignmentFixture>? fixtures,
  }) async {
    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final fixtureList = fixtures ?? ThaiCanonEvidenceAlignmentFixtures.all;
    final results = <ThaiCanonEvidenceAlignmentFixtureResult>[];

    for (final fixture in fixtureList) {
      results.add(await _auditFixture(fixture, repo));
    }

    return _aggregate(results, repo);
  }

  static Future<ThaiCanonEvidenceAlignmentFixtureResult> _auditFixture(
    ThaiCanonEvidenceAlignmentFixture fixture,
    ThaiCanonEvidenceRepository repo,
  ) async {
    final pipeline = ThaiMirrorPipeline.generate(fixture.birthData);
    final bundle = await ThaiReportCanonEvidenceEnricher.enrich(
      pipeline,
      repository: repo,
    );
    final profile = bundle.pipelineResult.profile!;
    final mirror = bundle.pipelineResult.mirrorResult!;

    final sectionIdsWithEvidence = bundle.attachments
        .map((a) => a.sectionId)
        .whereType<String>()
        .where((id) => !id.startsWith('future') && id != 'lifeTimeline')
        .toSet();
    final mirrorSectionIds = mirror.sections.map((s) => s.id.name).toSet();

    return ThaiCanonEvidenceAlignmentFixtureResult(
      fixture: fixture,
      bundle: bundle,
      records: ThaiCanonEvidenceAlignmentClassifier.classifyFixture(
        fixtureId: fixture.id,
        bundle: bundle,
      ),
      lagnaKey: profile.lagnaKey ?? '—',
      lagnaLordKey: profile.lagnaLordKey ?? '—',
      mahabhutaKeys: profile.mahabhutaPositionKeys,
      sectionsWithEvidence: sectionIdsWithEvidence
          .where(mirrorSectionIds.contains)
          .toList()
        ..sort(),
      sectionsWithoutEvidence: mirrorSectionIds
          .where((id) => !sectionIdsWithEvidence.contains(id))
          .toList()
        ..sort(),
    );
  }

  static ThaiCanonEvidenceAlignmentAudit _aggregate(
    List<ThaiCanonEvidenceAlignmentFixtureResult> results,
    ThaiCanonEvidenceRepository repo,
  ) {
    final classificationCounts = {
      for (final c in ThaiCanonEvidenceAlignmentClassification.values) c: 0,
    };
    final unmappedKeyCounts = <String, int>{};
    final outOfCanonKeyCounts = <String, int>{};
    final canonUnitIdsUsed = <String>{};
    var totalSections = 0;
    var sectionsStrong = 0;
    var sectionsWeak = 0;
    var sectionsNone = 0;
    var totalOutOfCanon = 0;
    var totalInCanonUnmapped = 0;
    var totalTraceOnly = 0;
    var totalUnmapped = 0;
    var totalRemedy = 0;
    var totalTaksa = 0;
    var totalLookup = 0;
    var totalPeriodStatus = 0;
    var totalNoRuntimeStatus = 0;
    final risks = <String>{};

    for (final result in results) {
      final mirror = result.bundle.pipelineResult.mirrorResult!;
      totalSections += mirror.sections.length;

      final strongSections = <String>{};
      final weakSections = <String>{};
      for (final record in result.records) {
        classificationCounts[record.classification] =
            (classificationCounts[record.classification] ?? 0) + 1;

        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.outOfCanonScope) {
          totalOutOfCanon++;
          outOfCanonKeyCounts[record.signalId] =
              (outOfCanonKeyCounts[record.signalId] ?? 0) + 1;
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.unmappedSignal) {
          totalInCanonUnmapped++;
          totalUnmapped++;
          unmappedKeyCounts[record.signalId] =
              (unmappedKeyCounts[record.signalId] ?? 0) + 1;
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.relatedButWeak &&
            record.attachmentIndex == null &&
            record.signalId.startsWith('prediction:')) {
          risks.add(
            ThaiCanonEvidenceFalseConfidencePatterns.predictionRuleBulkAttach,
          );
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.internalOnly &&
            record.signalId.startsWith('trace:skipped_lookup')) {
          totalLookup += result.bundle.trace.skippedLookupTableEvidenceCount;
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.skippedRemedy) {
          totalRemedy += result.bundle.trace.skippedRemedyEvidenceCount;
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.skippedTaksa) {
          totalTaksa += result.bundle.trace.skippedTaksaEvidenceCount;
        }
        if (record.classification ==
            ThaiCanonEvidenceAlignmentClassification.skippedPeriodStatus) {
          totalPeriodStatus++;
        }

        if (record.attachmentIndex != null && record.sectionId != null) {
          if (record.classification ==
              ThaiCanonEvidenceAlignmentClassification.strongMatch) {
            strongSections.add(record.sectionId!);
          }
          if (record.classification ==
              ThaiCanonEvidenceAlignmentClassification.relatedButWeak) {
            weakSections.add(record.sectionId!);
          }
        }

        if (record.classification ==
                ThaiCanonEvidenceAlignmentClassification.relatedButWeak &&
            record.evidenceType == ThaiCanonEvidenceType.planetSignification) {
          risks.add(
            ThaiCanonEvidenceFalseConfidencePatterns.planetAttributeOnPersonality,
          );
        }
        if (record.classification ==
                ThaiCanonEvidenceAlignmentClassification.strongMatch &&
            record.evidenceType == ThaiCanonEvidenceType.mahabhutPosition &&
            record.sectionId != null) {
          risks.add(
            ThaiCanonEvidenceFalseConfidencePatterns.mahabhutWithLegacyCopy,
          );
        }
        if (record.evidenceType == ThaiCanonEvidenceType.lifePeriodStructural) {
          risks.add(
            ThaiCanonEvidenceFalseConfidencePatterns.lifePeriodOnTimelineOnly,
          );
        }
      }

      totalTraceOnly += result.bundle.trace.traceOnlyEvidenceCandidates.length;
      totalNoRuntimeStatus +=
          result.bundle.trace.lifePeriodsWithoutRuntimeStatus.length;

      sectionsStrong += strongSections.length;
      sectionsWeak += weakSections.where((s) => !strongSections.contains(s)).length;
      sectionsNone += result.sectionsWithoutEvidence.length;

      for (final attachment in result.bundle.attachments) {
        for (final ref in attachment.evidenceRefs) {
          canonUnitIdsUsed.add(ref.unitId);
        }
      }
    }

    final domainCounts = <KnowledgeDomain, int>{};
    for (final unit in repo.index.units) {
      domainCounts[unit.domain] = (domainCounts[unit.domain] ?? 0) + 1;
    }
    final usedDomains = repo.index.units
        .where((u) => canonUnitIdsUsed.contains(u.id))
        .map((u) => u.domain)
        .toSet();
    final unusedDomainCounts = <KnowledgeDomain, int>{};
    for (final entry in domainCounts.entries) {
      if (!usedDomains.contains(entry.key)) {
        unusedDomainCounts[entry.key] = entry.value;
      }
    }

    final partial = ThaiCanonEvidenceAlignmentAudit(
      fixtureResults: results,
      classificationCounts: classificationCounts,
      totalReportSections: totalSections,
      sectionsWithStrongMatch: sectionsStrong,
      sectionsWithWeakEvidence: sectionsWeak,
      sectionsWithNoEvidence: sectionsNone,
      totalOutOfCanonScopeSignals: totalOutOfCanon,
      totalInCanonScopeUnmapped: totalInCanonUnmapped,
      totalTraceOnlyCandidates: totalTraceOnly,
      totalUnmappedSignals: totalUnmapped,
      totalSkippedRemedyCount: totalRemedy,
      totalSkippedTaksaCount: totalTaksa,
      totalSkippedLookupTableCount: totalLookup,
      totalSkippedPeriodStatusNotes: totalPeriodStatus,
      totalLifePeriodsWithoutRuntimeStatus: totalNoRuntimeStatus,
      topOutOfCanonScopeKeys: _topEntries(outOfCanonKeyCounts, 10),
      topInCanonScopeUnmappedKeys: _topEntries(unmappedKeyCounts, 10),
      topUnmappedRuntimeKeys: _topEntries(unmappedKeyCounts, 10),
      topUnusedCanonDomains: unusedDomainCounts.entries
          .map((e) => MapEntry(e.key.label, e.value))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      falseConfidenceRisks: risks.toList()..sort(),
      integrationReadiness: const {},
      canonUnitIdsUsed: canonUnitIdsUsed,
    );

    return ThaiCanonEvidenceAlignmentAudit(
      fixtureResults: partial.fixtureResults,
      classificationCounts: partial.classificationCounts,
      totalReportSections: partial.totalReportSections,
      sectionsWithStrongMatch: partial.sectionsWithStrongMatch,
      sectionsWithWeakEvidence: partial.sectionsWithWeakEvidence,
      sectionsWithNoEvidence: partial.sectionsWithNoEvidence,
      totalOutOfCanonScopeSignals: partial.totalOutOfCanonScopeSignals,
      totalInCanonScopeUnmapped: partial.totalInCanonScopeUnmapped,
      totalTraceOnlyCandidates: partial.totalTraceOnlyCandidates,
      totalUnmappedSignals: partial.totalUnmappedSignals,
      totalSkippedRemedyCount: partial.totalSkippedRemedyCount,
      totalSkippedTaksaCount: partial.totalSkippedTaksaCount,
      totalSkippedLookupTableCount: partial.totalSkippedLookupTableCount,
      totalSkippedPeriodStatusNotes: partial.totalSkippedPeriodStatusNotes,
      totalLifePeriodsWithoutRuntimeStatus:
          partial.totalLifePeriodsWithoutRuntimeStatus,
      topOutOfCanonScopeKeys: partial.topOutOfCanonScopeKeys,
      topInCanonScopeUnmappedKeys: partial.topInCanonScopeUnmappedKeys,
      topUnmappedRuntimeKeys: partial.topUnmappedRuntimeKeys,
      topUnusedCanonDomains: partial.topUnusedCanonDomains.take(10).toList(),
      falseConfidenceRisks: partial.falseConfidenceRisks,
      integrationReadiness:
          ThaiCanonEvidenceIntegrationReadinessMatrix.evaluate(partial),
      canonUnitIdsUsed: partial.canonUnitIdsUsed,
    );
  }

  static List<MapEntry<String, int>> _topEntries(
    Map<String, int> counts,
    int limit,
  ) {
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    return entries.take(limit).toList();
  }
}
