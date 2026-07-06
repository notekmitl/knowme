import 'life_period_engine.dart';

/// Feasibility outcome for period context normalization.
enum PeriodContextNormalizationFeasibilityResult {
  readyToNormalizePeriodContext,
  needsAgeRangeMetadata,
  needsCanonContextParser,
  blockedBySourceGap,
  blockedByModelingGap,
}

extension PeriodContextNormalizationFeasibilityResultWire
    on PeriodContextNormalizationFeasibilityResult {
  String get wire => switch (this) {
        PeriodContextNormalizationFeasibilityResult
              .readyToNormalizePeriodContext =>
          'READY_TO_NORMALIZE_PERIOD_CONTEXT',
        PeriodContextNormalizationFeasibilityResult.needsAgeRangeMetadata =>
          'NEEDS_AGE_RANGE_METADATA',
        PeriodContextNormalizationFeasibilityResult.needsCanonContextParser =>
          'NEEDS_CANON_CONTEXT_PARSER',
        PeriodContextNormalizationFeasibilityResult.blockedBySourceGap =>
          'BLOCKED_BY_SOURCE_GAP',
        PeriodContextNormalizationFeasibilityResult.blockedByModelingGap =>
          'BLOCKED_BY_MODELING_GAP',
      };
}

/// Blocker when normalization cannot proceed.
abstract final class PeriodContextNormalizationBlocker {
  static const needsPeriodContextMapping = 'NEEDS_PERIOD_CONTEXT_MAPPING';
  static const partialNormalization = 'PARTIAL_PERIOD_CONTEXT_NORMALIZATION';
}

/// Deterministic normalized key for runtime ↔ Canon `life_period` labels.
class ThaiLifePeriodContextNormalizedKey {
  const ThaiLifePeriodContextNormalizedKey({
    required this.rawLabel,
    this.isBirthLabel = false,
    this.pointAge,
    this.ageRangeStart,
    this.ageRangeEnd,
    this.statusMarker,
    this.planetCanonId,
  });

  final String rawLabel;
  final bool isBirthLabel;
  final int? pointAge;
  final int? ageRangeStart;
  final int? ageRangeEnd;

  /// `duengKhuen` | `duengTok` when bracket marker present on Canon label.
  final String? statusMarker;
  final String? planetCanonId;

  bool get hasAgeRange => ageRangeStart != null && ageRangeEnd != null;

  bool get isAmbiguous =>
      !isBirthLabel && pointAge == null && !hasAgeRange && rawLabel.isNotEmpty;
}

/// Normalization audit for period context matching.
class ThaiLifePeriodContextNormalizationAudit {
  const ThaiLifePeriodContextNormalizationAudit({
    required this.result,
    required this.hasStablePeriodIndex,
    required this.hasStructuredRuntimeAgeRange,
    required this.hasGoverningPlanet,
    required this.hasCanonLifePeriodLabels,
    required this.digitFormatMismatchCount,
    required this.punctuationMismatchCount,
    required this.spacingMismatchCount,
    required this.missingRuntimeAgeRangeCount,
    required this.missingCanonAgeRangeCount,
    required this.archetypeMismatchCount,
    required this.ambiguousContextCount,
    required this.sequenceOnlyWouldBeRequiredCount,
    required this.unparseableCanonLabelCount,
  });

  final PeriodContextNormalizationFeasibilityResult result;
  final bool hasStablePeriodIndex;
  final bool hasStructuredRuntimeAgeRange;
  final bool hasGoverningPlanet;
  final bool hasCanonLifePeriodLabels;
  final int digitFormatMismatchCount;
  final int punctuationMismatchCount;
  final int spacingMismatchCount;
  final int missingRuntimeAgeRangeCount;
  final int missingCanonAgeRangeCount;
  final int archetypeMismatchCount;
  final int ambiguousContextCount;
  final int sequenceOnlyWouldBeRequiredCount;
  final int unparseableCanonLabelCount;
}

/// Structural normalizer — representation only, no astrological inference.
abstract final class ThaiLifePeriodContextNormalizer {
  static const birthLabel = 'แรกเกิด';
  static const statusDuengKhuen = 'duengKhuen';
  static const statusDuengTok = 'duengTok';

  static ThaiLifePeriodContextNormalizedKey fromCanonLabel(String rawValue) {
    final trimmed = _collapseWhitespace(rawValue.trim());
    final statusMarker = _extractStatusMarker(trimmed);
    final withoutMarkers = trimmed
        .replaceAll('[ดวงขึ้น]', '')
        .replaceAll('[ดวงตก]', '')
        .trim();

    if (withoutMarkers == birthLabel) {
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: trimmed,
        isBirthLabel: true,
        statusMarker: statusMarker,
      );
    }

    final ascii = _thaiDigitsToAscii(withoutMarkers);
    final collapsed = _collapseWhitespace(ascii);

    final rangeToMatch =
        RegExp(r'อาย(?:ุ)?\s*(\d+)\s*ถึง\s*(\d+)').firstMatch(collapsed);
    if (rangeToMatch != null) {
      final a = int.parse(rangeToMatch.group(1)!);
      final b = int.parse(rangeToMatch.group(2)!);
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: trimmed,
        ageRangeStart: a < b ? a : b,
        ageRangeEnd: a < b ? b : a,
        statusMarker: statusMarker,
      );
    }

    final hyphenMatch =
        RegExp(r'อาย(?:ุ)?\s*(\d+)\s*[-–]\s*(\d+)').firstMatch(collapsed);
    if (hyphenMatch != null) {
      final a = int.parse(hyphenMatch.group(1)!);
      final b = int.parse(hyphenMatch.group(2)!);
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: trimmed,
        ageRangeStart: a < b ? a : b,
        ageRangeEnd: a < b ? b : a,
        statusMarker: statusMarker,
      );
    }

    final pointMatch = RegExp(r'อาย(?:ุ)?\s*(\d+)').firstMatch(collapsed);
    if (pointMatch != null) {
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: trimmed,
        pointAge: int.parse(pointMatch.group(1)!),
        statusMarker: statusMarker,
      );
    }

    return ThaiLifePeriodContextNormalizedKey(
      rawLabel: trimmed,
      statusMarker: statusMarker,
    );
  }

  static ThaiLifePeriodContextNormalizedKey fromRuntimePeriod(PeriodState period) {
    if (period.startAge == 1) {
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: 'runtime:${period.index}',
        isBirthLabel: true,
      );
    }
    if (period.startAge == period.endAge) {
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: 'runtime:${period.index}',
        pointAge: period.startAge,
      );
    }
    if (period.startAge > 0 && period.endAge >= period.startAge) {
      return ThaiLifePeriodContextNormalizedKey(
        rawLabel: 'runtime:${period.index}',
        ageRangeStart: period.startAge,
        ageRangeEnd: period.endAge,
      );
    }
    return ThaiLifePeriodContextNormalizedKey(
      rawLabel: 'runtime:${period.index}',
    );
  }

  /// Canonical wire key for deterministic grouping.
  static String? wireKey(ThaiLifePeriodContextNormalizedKey key) {
    if (key.isBirthLabel) return 'birth:1';
    if (key.hasAgeRange) {
      final status = key.statusMarker == null ? '' : '|status:${key.statusMarker}';
      return 'ageRange:${key.ageRangeStart}-${key.ageRangeEnd}$status';
    }
    final age = key.pointAge;
    if (age != null) {
      final status = key.statusMarker == null ? '' : '|status:${key.statusMarker}';
      return 'pointAge:$age$status';
    }
    return null;
  }

  static bool matchesRuntimeToCanon({
    required ThaiLifePeriodContextNormalizedKey runtime,
    required ThaiLifePeriodContextNormalizedKey canon,
  }) {
    final runtimeWire = wireKey(runtime);
    final canonWire = wireKey(canon);
    if (runtimeWire == null || canonWire == null) return false;

    final runtimeBase = _baseWire(runtimeWire);
    final canonBase = _baseWire(canonWire);
    return runtimeBase == canonBase;
  }

  static String _baseWire(String wire) {
    final idx = wire.indexOf('|status:');
    if (idx < 0) return wire;
    return wire.substring(0, idx);
  }

  static String? _extractStatusMarker(String value) {
    if (value.contains('[ดวงขึ้น]')) return statusDuengKhuen;
    if (value.contains('[ดวงตก]')) return statusDuengTok;
    return null;
  }

  static String _collapseWhitespace(String input) =>
      input.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _thaiDigitsToAscii(String input) {
    const thai = '๐๑๒๓๔๕๖๗๘๙';
    var out = input;
    for (var i = 0; i < thai.length; i++) {
      out = out.replaceAll(thai[i], i.toString());
    }
    return out;
  }
}

/// Read-only normalization feasibility audit.
abstract final class ThaiLifePeriodContextNormalizationFeasibility {
  static ThaiLifePeriodContextNormalizationAudit audit({
    LifeTimeline? timeline,
    Iterable<String> canonLifePeriodLabels = const [],
  }) {
    const hasIndex = true;
    const hasPlanet = true;
    var hasRuntimeAge = true;
    var hasCanonLabels = false;
    var unparseable = 0;
    var digitMismatch = 0;
    var punctuationMismatch = 0;
    var spacingMismatch = 0;
    var missingCanonAge = 0;

    for (final label in canonLifePeriodLabels) {
      hasCanonLabels = true;
      final key = ThaiLifePeriodContextNormalizer.fromCanonLabel(label);
      if (key.isAmbiguous) {
        unparseable++;
        missingCanonAge++;
      }
      if (label.contains('๐') ||
          label.contains('๑') ||
          label.contains('๒')) {
        final ascii = ThaiLifePeriodContextNormalizer.fromCanonLabel(
          label.replaceAll('๒', '2'),
        );
        if (!ascii.isAmbiguous && key.isAmbiguous) digitMismatch++;
      }
      if (label.contains('-') || label.contains('–')) {
        punctuationMismatch++;
      }
      if (label.contains(RegExp(r'\s{2,}'))) {
        spacingMismatch++;
      }
    }

    if (timeline != null) {
      for (final period in timeline.periods) {
        if (period.startAge <= 0 || period.endAge < period.startAge) {
          hasRuntimeAge = false;
        }
      }
    }

    if (!hasCanonLabels) {
      return ThaiLifePeriodContextNormalizationAudit(
        result: PeriodContextNormalizationFeasibilityResult.blockedBySourceGap,
        hasStablePeriodIndex: hasIndex,
        hasStructuredRuntimeAgeRange: hasRuntimeAge,
        hasGoverningPlanet: hasPlanet,
        hasCanonLifePeriodLabels: false,
        digitFormatMismatchCount: digitMismatch,
        punctuationMismatchCount: punctuationMismatch,
        spacingMismatchCount: spacingMismatch,
        missingRuntimeAgeRangeCount: hasRuntimeAge ? 0 : 1,
        missingCanonAgeRangeCount: missingCanonAge,
        archetypeMismatchCount: 0,
        ambiguousContextCount: 0,
        sequenceOnlyWouldBeRequiredCount: 0,
        unparseableCanonLabelCount: unparseable,
      );
    }

    if (!hasRuntimeAge) {
      return ThaiLifePeriodContextNormalizationAudit(
        result: PeriodContextNormalizationFeasibilityResult.needsAgeRangeMetadata,
        hasStablePeriodIndex: hasIndex,
        hasStructuredRuntimeAgeRange: false,
        hasGoverningPlanet: hasPlanet,
        hasCanonLifePeriodLabels: hasCanonLabels,
        digitFormatMismatchCount: digitMismatch,
        punctuationMismatchCount: punctuationMismatch,
        spacingMismatchCount: spacingMismatch,
        missingRuntimeAgeRangeCount: 1,
        missingCanonAgeRangeCount: missingCanonAge,
        archetypeMismatchCount: 0,
        ambiguousContextCount: 0,
        sequenceOnlyWouldBeRequiredCount: 0,
        unparseableCanonLabelCount: unparseable,
      );
    }

    return ThaiLifePeriodContextNormalizationAudit(
      result: PeriodContextNormalizationFeasibilityResult
          .readyToNormalizePeriodContext,
      hasStablePeriodIndex: hasIndex,
      hasStructuredRuntimeAgeRange: hasRuntimeAge,
      hasGoverningPlanet: hasPlanet,
      hasCanonLifePeriodLabels: hasCanonLabels,
      digitFormatMismatchCount: digitMismatch,
      punctuationMismatchCount: punctuationMismatch,
      spacingMismatchCount: spacingMismatch,
      missingRuntimeAgeRangeCount: 0,
      missingCanonAgeRangeCount: missingCanonAge,
      archetypeMismatchCount: 0,
      ambiguousContextCount: 0,
      sequenceOnlyWouldBeRequiredCount: 0,
      unparseableCanonLabelCount: unparseable,
    );
  }
}
