import '../../knowledge/canon/atomic/atomic_knowledge_unit.dart';
import '../../knowledge/canon/atomic/atomic_relation.dart';
import '../../knowledge/canon/integration/thai_canon_evidence_index.dart';
import '../../knowledge/canon/ontology/canon_ontology_data.dart';
import 'life_period_engine.dart';
import 'life_planet.dart';
import 'thai_archetype_context_metadata.dart';

/// Feasibility outcome for runtime → Canon `life_period` context mapping.
enum PeriodContextMappingFeasibilityResult {
  readyToMapPeriodContext,
  needsAgeRangeMetadata,
  needsCanonContextNormalization,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension PeriodContextMappingFeasibilityResultWire
    on PeriodContextMappingFeasibilityResult {
  String get wire => switch (this) {
        PeriodContextMappingFeasibilityResult.readyToMapPeriodContext =>
          'READY_TO_MAP_PERIOD_CONTEXT',
        PeriodContextMappingFeasibilityResult.needsAgeRangeMetadata =>
          'NEEDS_AGE_RANGE_METADATA',
        PeriodContextMappingFeasibilityResult.needsCanonContextNormalization =>
          'NEEDS_CANON_CONTEXT_NORMALIZATION',
        PeriodContextMappingFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        PeriodContextMappingFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker codes when period context metadata cannot be exposed.
abstract final class PeriodContextMetadataBlocker {
  static const needsArchetypeMetadata = 'NEEDS_ARCHETYPE_METADATA';
  static const needsPeriodContextMapping = 'NEEDS_PERIOD_CONTEXT_MAPPING';
  static const blockedBySourceGap = 'BLOCKED_BY_SOURCE_GAP';
  static const blockedByModelingGap = 'BLOCKED_BY_MODELING_GAP';
  static const noLifeTimeline = 'NO_LIFE_TIMELINE';
}

/// Deterministic match method recorded on internal metadata.
abstract final class PeriodContextMatchMethod {
  static const exactPeriodLabel = 'exact_period_label';
  static const exactAgeRange = 'exact_age_range';
  static const exactAgeRangeAndPlanet = 'exact_age_range_and_planet';
}

/// Internal period context metadata (Canon `life_period` value only).
class ThaiLifePeriodContextMetadata {
  const ThaiLifePeriodContextMetadata({
    required this.periodIndex,
    required this.runtimeAgeStart,
    required this.runtimeAgeEnd,
    required this.runtimePlanet,
    required this.archetypeChartCanonId,
    required this.canonLifePeriodContextValue,
    required this.canonEvidenceUnitIds,
    required this.sourcePages,
    required this.matchMethod,
    this.confidence = 'deterministic',
  });

  final int periodIndex;
  final int runtimeAgeStart;
  final int runtimeAgeEnd;
  final String runtimePlanet;
  final String archetypeChartCanonId;
  final String canonLifePeriodContextValue;
  final List<String> canonEvidenceUnitIds;
  final List<String> sourcePages;
  final String matchMethod;
  final String confidence;
}

/// Parsed Canon `life_period` label (normalizer output).
class ThaiCanonLifePeriodLabelParse {
  const ThaiCanonLifePeriodLabelParse({
    required this.rawValue,
    required this.isBirthLabel,
    this.parsedAge,
    this.parsedAgeRangeStart,
    this.parsedAgeRangeEnd,
  });

  final String rawValue;
  final bool isBirthLabel;
  final int? parsedAge;
  final int? parsedAgeRangeStart;
  final int? parsedAgeRangeEnd;

  bool get isAgeRange =>
      parsedAgeRangeStart != null && parsedAgeRangeEnd != null;
}

/// Deterministic parser for frozen Canon `life_period` context strings.
abstract final class ThaiCanonLifePeriodContextNormalizer {
  static const birthLabel = 'แรกเกิด';

  static ThaiCanonLifePeriodLabelParse parse(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed == birthLabel) {
      return ThaiCanonLifePeriodLabelParse(
        rawValue: trimmed,
        isBirthLabel: true,
      );
    }

    final withoutMarkers = trimmed
        .replaceAll('[ดวงขึ้น]', '')
        .replaceAll('[ดวงตก]', '')
        .trim();

    final ascii = _thaiDigitsToAscii(withoutMarkers);
    final rangeMatch =
        RegExp(r'อาย(?:ุ)?\s*(\d+)\s*ถึง\s*(\d+)').firstMatch(ascii);
    if (rangeMatch != null) {
      final a = int.parse(rangeMatch.group(1)!);
      final b = int.parse(rangeMatch.group(2)!);
      return ThaiCanonLifePeriodLabelParse(
        rawValue: trimmed,
        isBirthLabel: false,
        parsedAgeRangeStart: a < b ? a : b,
        parsedAgeRangeEnd: a < b ? b : a,
      );
    }

    final match = RegExp(r'อาย(?:ุ)?\s*(\d+)').firstMatch(ascii);
    if (match != null) {
      return ThaiCanonLifePeriodLabelParse(
        rawValue: trimmed,
        isBirthLabel: false,
        parsedAge: int.parse(match.group(1)!),
      );
    }

    return ThaiCanonLifePeriodLabelParse(
      rawValue: trimmed,
      isBirthLabel: false,
    );
  }

  static String _thaiDigitsToAscii(String input) {
    const thai = '๐๑๒๓๔๕๖๗๘๙';
    var out = input;
    for (var i = 0; i < thai.length; i++) {
      out = out.replaceAll(thai[i], i.toString());
    }
    return out;
  }
}

/// Frozen Phase D archetype life-period section page ranges (source-backed).
abstract final class ThaiArchetypeChartLifePeriodPageRanges {
  static const byArchetypeChartId = {
    'archetypeChart.kamphra': (52, 75),
    'archetypeChart.naksas': (89, 111),
    'archetypeChart.nakbarihan': (121, 147),
    'archetypeChart.manussachaosamran': (157, 179),
    'archetypeChart.sethi': (188, 217),
    'archetypeChart.nakwichakan': (226, 253),
    'archetypeChart.mahasethi': (263, 292),
  };
}

/// Page index for archetype-scoped Canon units.
abstract final class ThaiArchetypeChartCanonPageIndex {
  static Map<String, Set<int>> build(ThaiCanonEvidenceIndex index) {
    final pagesByArchetype = <String, Set<int>>{};

    for (final entry in ThaiArchetypeChartLifePeriodPageRanges.byArchetypeChartId.entries) {
      pagesByArchetype[entry.key] = {
        for (var p = entry.value.$1; p <= entry.value.$2; p++) p,
      };
    }

    for (final unit in index.units) {
      if (unit.context?.type != AtomicContextType.archetypeChart) continue;
      final page = _pageNumber(unit);
      if (page == null) continue;
      final archetypeId = _archetypeIdForChartLabel(unit.context!.value);
      if (archetypeId == null) continue;
      pagesByArchetype.putIfAbsent(archetypeId, () => {}).add(page);
    }
    return pagesByArchetype;
  }

  static bool pageInArchetypeScope({
    required String archetypeChartCanonId,
    required int page,
    required Map<String, Set<int>> pagesByArchetype,
  }) {
    final pages = pagesByArchetype[archetypeChartCanonId];
    if (pages == null || pages.isEmpty) return false;
    return pages.contains(page);
  }

  static String? _archetypeIdForChartLabel(String chartLabel) {
    final normalized = chartLabel.trim();
    for (final entity in CanonOntologyData.archetypeCharts) {
      if (entity.id == normalized) return entity.id;
      for (final alias in entity.aliases) {
        if (alias == normalized) return entity.id;
      }
    }
    return null;
  }

  static int? _pageNumber(AtomicKnowledgeUnit unit) {
    final page = unit.evidence.page?.trim();
    if (page == null || page.isEmpty) return null;
    return int.tryParse(page);
  }
}

class ThaiLifePeriodContextFeasibilityAudit {
  const ThaiLifePeriodContextFeasibilityAudit({
    required this.result,
    required this.hasStablePeriodIndex,
    required this.hasStructuredAgeRange,
    required this.hasGoverningPlanet,
    required this.hasCanonLifePeriodLabels,
    required this.canonContextDiffersAcrossArchetypes,
    required this.canMatchWithoutSequenceAlone,
    required this.distinctCanonLifePeriodLabelCount,
    required this.unparseableCanonLabelCount,
  });

  final PeriodContextMappingFeasibilityResult result;
  final bool hasStablePeriodIndex;
  final bool hasStructuredAgeRange;
  final bool hasGoverningPlanet;
  final bool hasCanonLifePeriodLabels;
  final bool canonContextDiffersAcrossArchetypes;
  final bool canMatchWithoutSequenceAlone;

  final int distinctCanonLifePeriodLabelCount;
  final int unparseableCanonLabelCount;
}

/// Read-only feasibility audit for period context mapping.
abstract final class ThaiLifePeriodContextFeasibility {
  static ThaiLifePeriodContextFeasibilityAudit audit({
    LifeTimeline? timeline,
    ThaiCanonEvidenceIndex? canonIndex,
  }) {
    const hasIndex = true;
    const hasAgeRange = true;
    const hasPlanet = true;

    var hasCanonLabels = false;
    var differsAcrossArchetypes = false;
    var unparseable = 0;
    var distinctLabels = <String>{};

    if (canonIndex != null) {
      final pageIndex = ThaiArchetypeChartCanonPageIndex.build(canonIndex);
      differsAcrossArchetypes = pageIndex.length > 1;
      for (final unit in canonIndex.units) {
        if (unit.context?.type != AtomicContextType.lifePeriod) continue;
        if (unit.relation != AtomicRelation.locatedIn) continue;
        if (!unit.object.startsWith('mahabhutPosition.')) continue;
        hasCanonLabels = true;
        distinctLabels.add(unit.context!.value);
        final parsed = ThaiCanonLifePeriodContextNormalizer.parse(
          unit.context!.value,
        );
        if (!parsed.isBirthLabel &&
            parsed.parsedAge == null &&
            !parsed.isAgeRange) {
          unparseable++;
        }
      }
    }

    if (timeline != null && timeline.periods.isNotEmpty) {
      for (final period in timeline.periods) {
        if (period.startAge <= 0 || period.endAge < period.startAge) {
          return _audit(
            result: PeriodContextMappingFeasibilityResult.needsAgeRangeMetadata,
            hasIndex: hasIndex,
            hasAgeRange: false,
            hasPlanet: hasPlanet,
            hasCanonLabels: hasCanonLabels,
            differsAcrossArchetypes: differsAcrossArchetypes,
            distinctCount: distinctLabels.length,
            unparseable: unparseable,
          );
        }
      }
    }

    if (!hasCanonLabels) {
      return _audit(
        result: PeriodContextMappingFeasibilityResult.blockedBySourceGap,
        hasIndex: hasIndex,
        hasAgeRange: hasAgeRange,
        hasPlanet: hasPlanet,
        hasCanonLabels: false,
        differsAcrossArchetypes: differsAcrossArchetypes,
        distinctCount: distinctLabels.length,
        unparseable: unparseable,
      );
    }

    if (unparseable > 0) {
      return _audit(
        result: PeriodContextMappingFeasibilityResult
            .needsCanonContextNormalization,
        hasIndex: hasIndex,
        hasAgeRange: hasAgeRange,
        hasPlanet: hasPlanet,
        hasCanonLabels: hasCanonLabels,
        differsAcrossArchetypes: differsAcrossArchetypes,
        distinctCount: distinctLabels.length,
        unparseable: unparseable,
      );
    }

    return _audit(
      result: PeriodContextMappingFeasibilityResult.readyToMapPeriodContext,
      hasIndex: hasIndex,
      hasAgeRange: hasAgeRange,
      hasPlanet: hasPlanet,
      hasCanonLabels: hasCanonLabels,
      differsAcrossArchetypes: differsAcrossArchetypes,
      distinctCount: distinctLabels.length,
      unparseable: unparseable,
    );
  }

  static ThaiLifePeriodContextFeasibilityAudit _audit({
    required PeriodContextMappingFeasibilityResult result,
    required bool hasIndex,
    required bool hasAgeRange,
    required bool hasPlanet,
    required bool hasCanonLabels,
    required bool differsAcrossArchetypes,
    required int distinctCount,
    required int unparseable,
  }) {
    return ThaiLifePeriodContextFeasibilityAudit(
      result: result,
      hasStablePeriodIndex: hasIndex,
      hasStructuredAgeRange: hasAgeRange,
      hasGoverningPlanet: hasPlanet,
      hasCanonLifePeriodLabels: hasCanonLabels,
      canonContextDiffersAcrossArchetypes: differsAcrossArchetypes,
      canMatchWithoutSequenceAlone: hasAgeRange && hasPlanet,
      distinctCanonLifePeriodLabelCount: distinctCount,
      unparseableCanonLabelCount: unparseable,
    );
  }
}

class ThaiLifePeriodContextResolution {
  const ThaiLifePeriodContextResolution({
    this.metadata,
    this.missingReason,
  });

  final ThaiLifePeriodContextMetadata? metadata;
  final String? missingReason;
}

/// Maps runtime [PeriodState] → frozen Canon `life_period` context value.
abstract final class ThaiLifePeriodContextResolver {
  static ThaiLifePeriodContextMetadata? resolve({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    return resolveDetailed(
      period: period,
      archetypeMetadata: archetypeMetadata,
      canonIndex: canonIndex,
    ).metadata;
  }

  static ThaiLifePeriodContextResolution resolveDetailed({
    required PeriodState period,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    if (archetypeMetadata == null) {
      return const ThaiLifePeriodContextResolution(
        missingReason: PeriodContextMetadataBlocker.needsArchetypeMetadata,
      );
    }
    if (canonIndex == null) {
      return const ThaiLifePeriodContextResolution(
        missingReason: PeriodContextMetadataBlocker.blockedBySourceGap,
      );
    }

    final archetypeId = archetypeMetadata.archetypeChartCanonId;
    final pages =
        ThaiArchetypeChartCanonPageIndex.build(canonIndex)[archetypeId];
    if (pages == null || pages.isEmpty) {
      return const ThaiLifePeriodContextResolution(
        missingReason: 'MISSING_ARCHETYPE_PAGE_INDEX',
      );
    }

    final planetId = 'planet.${period.planet.name}';
    final candidates = <String, List<AtomicKnowledgeUnit>>{};

    for (final unit in canonIndex.units) {
      if (unit.context?.type != AtomicContextType.lifePeriod) continue;
      if (unit.relation != AtomicRelation.locatedIn) continue;
      if (!unit.object.startsWith('mahabhutPosition.')) continue;
      final page = int.tryParse(unit.evidence.page ?? '');
      if (page == null || !pages.contains(page)) continue;
      if (unit.subject != planetId) continue;

      final raw = unit.context!.value;
      final parsed = ThaiCanonLifePeriodContextNormalizer.parse(raw);
      final matches = _matchesPeriod(
        period: period,
        parsed: parsed,
      );
      if (!matches) continue;

      candidates.putIfAbsent(raw, () => []).add(unit);
    }

    if (candidates.isEmpty) {
      return const ThaiLifePeriodContextResolution(
        missingReason: 'NO_CANON_CONTEXT_FOR_PERIOD',
      );
    }
    if (candidates.length > 1) {
      return const ThaiLifePeriodContextResolution(
        missingReason: 'AMBIGUOUS_CANON_CONTEXT',
      );
    }

    final entry = candidates.entries.first;
    final units = entry.value;
    final matchMethod = _matchMethodFor(
      period: period,
      parsed: ThaiCanonLifePeriodContextNormalizer.parse(entry.key),
      planetMatched: true,
    );

    return ThaiLifePeriodContextResolution(
      metadata: ThaiLifePeriodContextMetadata(
        periodIndex: period.index,
        runtimeAgeStart: period.startAge,
        runtimeAgeEnd: period.endAge,
        runtimePlanet: period.planet.name,
        archetypeChartCanonId: archetypeId,
        canonLifePeriodContextValue: entry.key,
        canonEvidenceUnitIds: units.map((u) => u.id).toList()..sort(),
        sourcePages: units
            .map((u) => u.evidence.page)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort(),
        matchMethod: matchMethod,
      ),
    );
  }

  static bool _matchesPeriod({
    required PeriodState period,
    required ThaiCanonLifePeriodLabelParse parsed,
  }) {
    if (parsed.isBirthLabel) {
      return period.startAge == 1;
    }
    if (parsed.isAgeRange) {
      return period.startAge == parsed.parsedAgeRangeStart &&
          period.endAge == parsed.parsedAgeRangeEnd;
    }
    final age = parsed.parsedAge;
    if (age == null) return false;
    return age == period.startAge;
  }

  static String _matchMethodFor({
    required PeriodState period,
    required ThaiCanonLifePeriodLabelParse parsed,
    required bool planetMatched,
  }) {
    if (parsed.isBirthLabel) {
      return PeriodContextMatchMethod.exactPeriodLabel;
    }
    if (parsed.isAgeRange) {
      return PeriodContextMatchMethod.exactAgeRange;
    }
    if (planetMatched) {
      return PeriodContextMatchMethod.exactAgeRangeAndPlanet;
    }
    return PeriodContextMatchMethod.exactAgeRange;
  }

  /// Resolves all periods; entries are null when mapping fails.
  static Map<int, ThaiLifePeriodContextMetadata?> resolveAll({
    required LifeTimeline timeline,
    required ThaiArchetypeContextMetadata? archetypeMetadata,
    required ThaiCanonEvidenceIndex? canonIndex,
  }) {
    final out = <int, ThaiLifePeriodContextMetadata?>{};
    for (final period in timeline.periods) {
      out[period.index] = resolve(
        period: period,
        archetypeMetadata: archetypeMetadata,
        canonIndex: canonIndex,
      );
    }
    return out;
  }
}
