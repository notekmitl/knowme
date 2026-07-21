/// Catalog integrity checks for curated narrative blocks (V1.1.1).
library;

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_curated_narrative_blocks.dart';
import 'thai_beta_narrative_confidence.dart';
import 'thai_beta_narrative_domain.dart';

/// Result of validating the curated block catalog.
class CuratedBlockIntegrityReport {
  const CuratedBlockIntegrityReport({required this.violations});

  final List<String> violations;

  bool get isValid => violations.isEmpty;
}

/// Deterministic integrity rules for the curated block library.
abstract final class ThaiBetaCuratedBlockIntegrity {
  /// Validate all catalog invariants. Pure — never throws.
  static CuratedBlockIntegrityReport validate([
    List<CuratedNarrativeBlock>? blocks,
  ]) {
    final catalog = blocks ?? ThaiBetaCuratedNarrativeBlocks.all;
    final violations = <String>[];

    _checkUniqueIds(catalog, violations);
    _checkSourceSignals(catalog, violations);
    _checkBirthTimeFlags(catalog, violations);
    _checkConfidenceConsistency(catalog, violations);
    _checkRequiredFields(catalog, violations);
    _checkFallbackCoverage(catalog, violations);

    return CuratedBlockIntegrityReport(violations: List.unmodifiable(violations));
  }

  static void _checkUniqueIds(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    final seen = <String>{};
    for (final block in catalog) {
      if (block.id.trim().isEmpty) {
        violations.add('empty block id');
        continue;
      }
      if (!seen.add(block.id)) {
        violations.add('duplicate block id: ${block.id}');
      }
    }
  }

  static void _checkSourceSignals(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    for (final block in catalog) {
      if (block.sourceSignalIds.isEmpty) {
        violations.add('${block.id}: sourceSignalIds must not be empty');
      }
    }
  }

  static void _checkBirthTimeFlags(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    for (final block in catalog) {
      if (block.requiresBirthTime && block.safeWithoutBirthTime) {
        violations.add(
          '${block.id}: requiresBirthTime cannot be true when '
          'safeWithoutBirthTime is true',
        );
      }
    }
  }

  static void _checkConfidenceConsistency(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    for (final block in catalog) {
      final effective = ThaiBetaNarrativeConfidence.effectiveMinimum(
        declaredMinimum: block.minimumConfidence,
        requiresBirthTime: block.requiresBirthTime,
        safeWithoutBirthTime: block.safeWithoutBirthTime,
      );
      if (block.safeWithoutBirthTime &&
          !block.requiresBirthTime &&
          effective > ThaiBetaNarrativeConfidence.withoutBirthTime) {
        violations.add(
          '${block.id}: safeWithoutBirthTime block effective minimum '
          '($effective) exceeds withoutBirthTime '
          '(${ThaiBetaNarrativeConfidence.withoutBirthTime})',
        );
      }
      if ((block.requiresBirthTime || !block.safeWithoutBirthTime) &&
          effective < ThaiBetaNarrativeConfidence.withBirthTime) {
        violations.add(
          '${block.id}: unsafe/requires-time block effective minimum '
          '($effective) below withBirthTime '
          '(${ThaiBetaNarrativeConfidence.withBirthTime})',
        );
      }
    }
  }

  static void _checkRequiredFields(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    for (final block in catalog) {
      switch (block.section) {
        case CuratedNarrativeSection.hero:
          if (block.heroSentences.length < 3) {
            violations.add(
              '${block.id}: hero requires ≥3 heroSentences '
              '(got ${block.heroSentences.length})',
            );
          }
        case CuratedNarrativeSection.strength:
          if (block.observableBehavior == null ||
              block.observableBehavior!.trim().isEmpty) {
            violations.add('${block.id}: strength requires observableBehavior');
          }
          if (block.strengthText == null || block.strengthText!.trim().isEmpty) {
            violations.add('${block.id}: strength requires strengthText');
          }
        case CuratedNarrativeSection.domain:
          if (block.domain == null) {
            violations.add('${block.id}: domain block requires domain');
          }
          if (block.domainOverview == null ||
              block.domainOverview!.trim().isEmpty) {
            violations.add('${block.id}: domain requires domainOverview');
          }
        case CuratedNarrativeSection.dashboard:
          if (block.domain == null) {
            violations.add('${block.id}: dashboard block requires domain');
          }
          if (block.dashboardCurrent == null ||
              block.dashboardCurrent!.trim().isEmpty) {
            violations.add('${block.id}: dashboard requires dashboardCurrent');
          }
        case CuratedNarrativeSection.advice:
          if (block.adviceText == null || block.adviceText!.trim().isEmpty) {
            violations.add('${block.id}: advice requires adviceText');
          }
      }
    }
  }

  static void _checkFallbackCoverage(
    List<CuratedNarrativeBlock> catalog,
    List<String> violations,
  ) {
    bool hasFallback(
      CuratedNarrativeSection section, {
      ThaiBetaLifeDomain? domain,
      bool? safeWithoutBirthTime,
    }) {
      return catalog.any((b) {
        if (b.section != section) return false;
        if (b.relationshipType != CuratedRelationshipType.fallback) return false;
        if (domain != null && b.domain != domain) return false;
        if (safeWithoutBirthTime != null &&
            b.safeWithoutBirthTime != safeWithoutBirthTime) {
          return false;
        }
        return true;
      });
    }

    for (final section in CuratedNarrativeSection.values) {
      if (!hasFallback(section) &&
          section != CuratedNarrativeSection.domain &&
          section != CuratedNarrativeSection.dashboard &&
          section != CuratedNarrativeSection.advice) {
        // hero/strength need at least one fallback (with-time path)
        if (!catalog.any(
          (b) =>
              b.section == section &&
              b.relationshipType == CuratedRelationshipType.fallback,
        )) {
          violations.add('missing fallback for section $section');
        }
      }
    }

    for (final domain in ThaiBetaLifeDomain.values) {
      if (!hasFallback(CuratedNarrativeSection.domain, domain: domain)) {
        violations.add('missing domain fallback for ${domain.name}');
      }
      if (!hasFallback(CuratedNarrativeSection.dashboard, domain: domain)) {
        violations.add('missing dashboard fallback for ${domain.name}');
      }
      if (!hasFallback(CuratedNarrativeSection.advice, domain: domain) &&
          !catalog.any(
            (b) =>
                b.section == CuratedNarrativeSection.advice &&
                b.domain == domain &&
                b.relationshipType == CuratedRelationshipType.fallback,
          )) {
        // advice may use domain-tagged fallback ids
        final adviceOk = catalog.any(
          (b) =>
              b.section == CuratedNarrativeSection.advice &&
              (b.domain == domain || b.id.contains(domain.aspectKey)) &&
              (b.relationshipType == CuratedRelationshipType.fallback ||
                  b.id.contains('fallback')),
        );
        if (!adviceOk) {
          violations.add('missing advice fallback for ${domain.name}');
        }
      }
    }

    // No-time safe hero must exist
    final noTimeHero = catalog.any(
      (b) =>
          b.section == CuratedNarrativeSection.hero &&
          b.safeWithoutBirthTime &&
          !b.requiresBirthTime &&
          b.heroSentences.length >= 3,
    );
    if (!noTimeHero) {
      violations.add('missing safeWithoutBirthTime hero fallback');
    }

    final noTimeStrength = catalog.any(
      (b) =>
          b.section == CuratedNarrativeSection.strength &&
          b.safeWithoutBirthTime &&
          !b.requiresBirthTime,
    );
    if (!noTimeStrength) {
      violations.add('missing safeWithoutBirthTime strength fallback');
    }
  }
}
