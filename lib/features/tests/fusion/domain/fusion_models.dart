import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/data/models/astrology_chart_model.dart';

import 'fusion_constants.dart';

/// Deterministic inputs loaded from `users/{uid}/results/*` (read-only).
class FusionInput {
  const FusionInput({
    this.astrologyResult,
    this.mbtiMiniResult,
    this.cognitiveResult,
  });

  final AstrologyChartModel? astrologyResult;
  final MbtiTraitsResult? mbtiMiniResult;
  final MbtiTraitsResult? cognitiveResult;

  bool get hasAny =>
      astrologyResult != null ||
      mbtiMiniResult != null ||
      cognitiveResult != null;
}

/// MBTI module output as stored by [UniversalTestPage] (`Map` + `createdAt`).
class MbtiTraitsResult {
  const MbtiTraitsResult({
    required this.traits,
    this.createdAt,
  });

  final Map<String, double> traits;
  final DateTime? createdAt;

  factory MbtiTraitsResult.fromFirestore(Map<String, dynamic> data) {
    final traits = <String, double>{};
    DateTime? createdAt;

    for (final entry in data.entries) {
      if (entry.key == 'createdAt') {
        createdAt = _parseTimestamp(entry.value);
        continue;
      }
      final value = entry.value;
      if (value is num) {
        traits[entry.key] = value.toDouble();
      }
    }

    return MbtiTraitsResult(traits: traits, createdAt: createdAt);
  }

  /// E/I/S/N/T/F/J/P letter code when trait keys are present.
  String? get typeCode {
    if (!_hasPair('E', 'I') ||
        !_hasPair('S', 'N') ||
        !_hasPair('T', 'F') ||
        !_hasPair('J', 'P')) {
      return null;
    }
    final ei = traits['E']! >= traits['I']! ? 'E' : 'I';
    final sn = traits['S']! >= traits['N']! ? 'S' : 'N';
    final tf = traits['T']! >= traits['F']! ? 'T' : 'F';
    final jp = traits['J']! >= traits['P']! ? 'J' : 'P';
    return '$ei$sn$tf$jp';
  }

  bool _hasPair(String a, String b) =>
      traits.containsKey(a) && traits.containsKey(b);
}

DateTime? _parseTimestamp(dynamic raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  return null;
}

/// Deterministic strength bucket (no narrative).
enum FusionSignalStrength {
  low,
  medium,
  high,
}

/// Which result layer produced the signal.
enum FusionSignalSource {
  astrology,
  mbti,
  cognitive,
}

/// Normalized insight atom from a single deterministic source.
class FusionSignal {
  const FusionSignal({
    required this.id,
    required this.strength,
    required this.confidence,
    required this.source,
  });

  /// One of [FusionSignalIds].
  final String id;
  final FusionSignalStrength strength;
  final int confidence;
  final FusionSignalSource source;

  static int confidenceForStrength(FusionSignalStrength strength) =>
      switch (strength) {
        FusionSignalStrength.low => FusionSignalConfidence.low,
        FusionSignalStrength.medium => FusionSignalConfidence.medium,
        FusionSignalStrength.high => FusionSignalConfidence.high,
      };
}

/// One signal id after cross-source merge (Phase 3.5).
class MergedFusionSignal {
  const MergedFusionSignal({
    required this.id,
    required this.strength,
    required this.confidence,
    required this.contributors,
  });

  /// One of [FusionSignalIds].
  final String id;
  final FusionSignalStrength strength;
  final int confidence;

  /// Unique [FusionSignalSource]s that contributed this id (deterministic order).
  final List<FusionSignalSource> contributors;
}

/// Core pattern block (Phase 4A).
class FusionPattern {
  const FusionPattern({
    required this.title,
    required this.summary,
    required this.contributors,
    this.themeId,
  });

  final String title;
  final String summary;
  final List<FusionSignalSource> contributors;

  /// One of [FusionThemeIds], when pattern maps to a theme.
  final String? themeId;
}

/// Explainability line tied to merged evidence (Phase 4A).
class FusionWhyItem {
  const FusionWhyItem({
    required this.body,
    required this.contributors,
    this.signalId,
  });

  final String body;
  final List<FusionSignalSource> contributors;

  /// Optional anchor signal for ordering/debug.
  final String? signalId;
}

/// Full deterministic fusion pipeline output.
class FusionOutput {
  const FusionOutput({
    required this.input,
    this.signals = const [],
    this.mergedSignals = const [],
    this.heroSummary = '',
    this.reflectionPrompts = const [],
    this.patterns = const [],
    this.guidanceTips = const [],
    this.whyPersonalized = const [],
  });

  final FusionInput input;
  final List<FusionSignal> signals;
  final List<MergedFusionSignal> mergedSignals;
  final String heroSummary;

  /// 1–2 reflective questions (deterministic, no quiz / no AI).
  final List<String> reflectionPrompts;
  final List<FusionPattern> patterns;

  /// 1–3 suggestive tips (deterministic, not prescriptive).
  final List<String> guidanceTips;
  final List<FusionWhyItem> whyPersonalized;
}
