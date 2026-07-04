import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_knowledge_unit.dart';
import 'package:knowme/features/astrology/thai/knowledge/canon/atomic/atomic_relation.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_lens_source.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/runtime/thai_mirror_pipeline_result.dart';

import 'thai_canon_evidence_attachment.dart';
import 'thai_canon_evidence_mapper.dart';
import 'thai_canon_evidence_ref.dart';
import 'thai_canon_evidence_repository.dart';
import 'thai_canon_evidence_trace.dart';
import 'thai_canon_evidence_type.dart';
import 'thai_canon_ontology_runtime_mapping.dart';
import 'thai_mirror_canon_evidence_bundle.dart';

/// Attaches frozen Canon evidence to Thai Mirror pipeline output without
/// mutating user-facing report structures.
abstract final class ThaiReportCanonEvidenceEnricher {
  /// Structural fingerprint of user-visible pipeline fields (QA regression).
  static String userFacingFingerprint(ThaiMirrorPipelineResult result) {
    if (!result.isSuccess) return 'failure:${result.errorMessage}';
    final mirror = result.mirrorResult!;
    final view = result.viewState!;
    return [
      mirror.contractVersion,
      mirror.topThemes.map((t) => t.themeId).join(','),
      mirror.sections
          .map((s) => '${s.id.name}:${s.evidence.length}:${s.summary}')
          .join('|'),
      view.topThemes.map((t) => t.themeId).join(','),
      view.hero.reflectionSummary,
      view.hero.titleTh,
      view.sections.map((s) => '${s.id.name}:${s.titleTh}').join('|'),
      result.profile!.mahabhutaPositionKeys.join(','),
    ].join('::');
  }

  static Future<ThaiMirrorCanonEvidenceBundle> enrich(
    ThaiMirrorPipelineResult pipelineResult, {
    ThaiCanonEvidenceRepository? repository,
  }) async {
    if (!pipelineResult.isSuccess) {
      return ThaiMirrorCanonEvidenceBundle(
        pipelineResult: pipelineResult,
        attachments: const [],
        trace: const ThaiCanonEvidenceTrace(),
      );
    }

    final repo = repository ?? await ThaiCanonEvidenceRepository.loadFromAsset();
    final mapper = repo.mapper;
    final attachments = <ThaiCanonEvidenceAttachment>[];
    final signalsWithout = <String>[];
    final runtimeUnmapped = <String>[];
    final canonCandidates = <String>[];

    final mirror = pipelineResult.mirrorResult!;

    for (final section in mirror.sections) {
      for (final evidence in section.evidence) {
        final signalId = '${section.id.name}:${evidence.contentKey}';
        _attachSectionEvidence(
          sectionId: section.id,
          signalId: signalId,
          lensSource: evidence.lensSource,
          contentKey: evidence.contentKey,
          mapper: mapper,
          attachments: attachments,
          signalsWithout: signalsWithout,
          runtimeUnmapped: runtimeUnmapped,
        );
      }
    }

    for (final contentKey in pipelineResult.profile!.mahabhutaPositionKeys) {
      final signalId = 'profile:mahabhuta_position:$contentKey';
      final refs = mapper.evidenceForRuntimeContentKey(contentKey);
      if (refs.isEmpty) {
        signalsWithout.add(signalId);
        if (ThaiContentKeys.allMahabhutaPosition.contains(contentKey) &&
            ThaiCanonOntologyRuntimeMapping.canonMahabhutForContentKey(
                    contentKey) ==
                null) {
          runtimeUnmapped.add(contentKey);
        }
        continue;
      }
      attachments.add(
        ThaiCanonEvidenceAttachment(
          sectionId: null,
          signalId: signalId,
          evidenceType: ThaiCanonEvidenceType.mahabhutPosition,
          evidenceRefs: refs,
        ),
      );
    }

    final timeline = pipelineResult.lifePeriods;
    if (timeline != null) {
      for (final period in timeline.periods) {
        final planetId = 'planet.${period.planet.name}';
        final units = _lifePeriodStructuralUnits(repo, planetId);
        final signalId = 'life_period:${period.index}:$planetId';
        if (units.isEmpty) {
          signalsWithout.add(signalId);
          continue;
        }
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: 'lifeTimeline',
            signalId: signalId,
            evidenceType: ThaiCanonEvidenceType.lifePeriodStructural,
            evidenceRefs: mapper.refsForUnits(units),
            matchQuality: ThaiCanonEvidenceMatchQuality.structural,
          ),
        );
      }
    }

    final predictionRefs = _predictionRuleRefs(repo);
    if (predictionRefs.isNotEmpty) {
      attachments.add(
        ThaiCanonEvidenceAttachment(
          sectionId: 'futurePredictionInternal',
          signalId: 'prediction:phase_e_rules',
          evidenceType: ThaiCanonEvidenceType.predictionRule,
          evidenceRefs: predictionRefs,
          matchQuality: ThaiCanonEvidenceMatchQuality.structural,
        ),
      );
    }

    for (final entry in ThaiCanonOntologyRuntimeMapping.periodStatusMappings()) {
      if (!entry.isMapped) {
        canonCandidates.add(entry.canonEntityId);
      }
    }
    for (final entry in ThaiCanonOntologyRuntimeMapping.taksaRoleMappings()) {
      if (!entry.isMapped) {
        canonCandidates.add(entry.canonEntityId);
      }
    }
    if (ThaiCanonOntologyRuntimeMapping.runtimePlanetKey('planet.ketu') == null) {
      canonCandidates.add('planet.ketu');
    }

    final trace = ThaiCanonEvidenceTrace(
      signalsWithoutCanonEvidence: _sortedUnique(signalsWithout),
      runtimeKeysWithoutCanonMapping: _sortedUnique(runtimeUnmapped),
      unmappedCanonEvidenceCandidates: _sortedUnique(canonCandidates),
      skippedRemedyEvidenceCount: mapper.evidenceForRemedyDomain().length,
      skippedTaksaEvidenceCount: repo.index.units
          .where((u) => u.object.startsWith('taksaRole.'))
          .length,
      skippedPeriodStatusNotes:
          ThaiCanonOntologyRuntimeMapping.periodStatusMappings()
              .where((m) => !m.isMapped)
              .map((m) => '${m.canonEntityId}: ${m.note ?? 'unmapped'}')
              .toList(growable: false),
    );

    attachments.sort((a, b) => a.signalId.compareTo(b.signalId));

    return ThaiMirrorCanonEvidenceBundle(
      pipelineResult: pipelineResult,
      attachments: List<ThaiCanonEvidenceAttachment>.unmodifiable(attachments),
      trace: trace,
    );
  }

  static void _attachSectionEvidence({
    required ThaiMirrorSectionId sectionId,
    required String signalId,
    required ThaiMirrorLensSource lensSource,
    required String contentKey,
    required ThaiCanonEvidenceMapper mapper,
    required List<ThaiCanonEvidenceAttachment> attachments,
    required List<String> signalsWithout,
    required List<String> runtimeUnmapped,
  }) {
    switch (lensSource) {
      case ThaiMirrorLensSource.mahabhutaPosition:
        final refs = mapper.evidenceForRuntimeContentKey(contentKey);
        if (refs.isEmpty) {
          signalsWithout.add(signalId);
          if (ThaiContentKeys.allMahabhutaPosition.contains(contentKey) &&
              ThaiCanonOntologyRuntimeMapping.canonMahabhutForContentKey(
                      contentKey) ==
                  null) {
            runtimeUnmapped.add(contentKey);
          }
          return;
        }
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: sectionId.name,
            signalId: signalId,
            evidenceType: ThaiCanonEvidenceType.mahabhutPosition,
            evidenceRefs: refs,
          ),
        );
      case ThaiMirrorLensSource.lagnaLord:
        final planetId = _planetIdFromLagnaLordKey(contentKey);
        if (planetId == null) {
          signalsWithout.add(signalId);
          return;
        }
        final refs = _planetSignificationRefs(mapper, planetId);
        if (refs.isEmpty) {
          signalsWithout.add(signalId);
          return;
        }
        attachments.add(
          ThaiCanonEvidenceAttachment(
            sectionId: sectionId.name,
            signalId: signalId,
            evidenceType: ThaiCanonEvidenceType.planetSignification,
            evidenceRefs: refs,
            matchQuality: ThaiCanonEvidenceMatchQuality.structural,
          ),
        );
      case ThaiMirrorLensSource.lagna:
      case ThaiMirrorLensSource.myanmarSeven:
        signalsWithout.add(signalId);
    }
  }

  static String? _planetIdFromLagnaLordKey(String contentKey) {
    const prefix = 'lagna_lord_';
    if (!contentKey.startsWith(prefix)) return null;
    final planet = contentKey.substring(prefix.length).trim();
    if (planet.isEmpty) return null;
    return 'planet.$planet';
  }

  static List<ThaiCanonEvidenceRef> _planetSignificationRefs(
    ThaiCanonEvidenceMapper mapper,
    String planetId,
  ) {
    return mapper.refsForUnits(
      mapper.index.units.where(
        (u) =>
            u.subject == planetId &&
            (u.relation == AtomicRelation.owns ||
                (u.relation == AtomicRelation.relatesTo &&
                    u.object.startsWith('attribute.'))),
      ),
    );
  }

  static Iterable<AtomicKnowledgeUnit> _lifePeriodStructuralUnits(
    ThaiCanonEvidenceRepository repo,
    String planetId,
  ) {
    return repo.index.units.where(
      (u) =>
          u.subject == planetId &&
          u.relation == AtomicRelation.locatedIn &&
          u.context?.type == AtomicContextType.lifePeriod &&
          u.object.startsWith('mahabhutPosition.'),
    );
  }

  static List<ThaiCanonEvidenceRef> _predictionRuleRefs(
    ThaiCanonEvidenceRepository repo,
  ) {
    return repo.mapper.refsForUnits(
      repo.index.units.where(
        (u) =>
            u.subject.startsWith('periodStatus.') &&
            (u.relation == AtomicRelation.produces ||
                u.relation == AtomicRelation.opposes ||
                u.relation == AtomicRelation.relatesTo),
      ),
    );
  }

  static List<String> _sortedUnique(List<String> values) {
    return values.toSet().toList()..sort();
  }
}
