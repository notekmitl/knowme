import 'package:knowme/data/models/astrology_chart_model.dart';

import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';
import 'fusion_mbti_type_signals.dart';

/// Maps deterministic `results/*` payloads → [FusionSignal] (V1, no narrative).
abstract final class FusionSignalAdapter {
  static List<FusionSignal> collect(FusionInput input) => [
        ...fromAstrology(input.astrologyResult),
        ...fromMbti(input.mbtiMiniResult),
        ...fromCognitive(input.cognitiveResult),
      ];

  static List<FusionSignal> fromAstrology(AstrologyChartModel? chart) {
    if (chart == null) return [];

    try {
      final placements = _chartPlacements(chart);
      if (placements.isEmpty) return [];

      final out = <FusionSignal>[];

      _addIfPositive(
        out,
        FusionSignalIds.openness,
        _scoreOpenness(placements),
        FusionSignalSource.astrology,
      );
      _addIfPositive(
        out,
        FusionSignalIds.intuition,
        _scoreIntuition(placements, chart),
        FusionSignalSource.astrology,
      );
      _addIfPositive(
        out,
        FusionSignalIds.emotionalSensitivity,
        _scoreEmotionalSensitivity(placements, chart),
        FusionSignalSource.astrology,
      );
      _addIfPositive(
        out,
        FusionSignalIds.reflection,
        _scoreReflection(placements),
        FusionSignalSource.astrology,
      );

      return out;
    } catch (_) {
      return [];
    }
  }

  static List<FusionSignal> fromMbti(MbtiTraitsResult? result) {
    if (result == null || result.traits.isEmpty) return [];

    try {
      final code = result.typeCode;
      if (code != null) {
        final preset = FusionMbtiTypeSignals.byTypeCode[code];
        if (preset != null) {
          return _fromTypePreset(preset, FusionSignalSource.mbti);
        }
      }
      return _fromDichotomies(result.traits, FusionSignalSource.mbti);
    } catch (_) {
      return [];
    }
  }

  static List<FusionSignal> fromCognitive(MbtiTraitsResult? result) {
    if (result == null || result.traits.isEmpty) return [];

    try {
      final out = <FusionSignal>[];
      const cognitiveKeys = ['Ne', 'Ni', 'Se', 'Si', 'Te', 'Ti', 'Fe', 'Fi'];

      for (final key in cognitiveKeys) {
        final raw = result.traits[key];
        if (raw == null) continue;
        _applyCognitiveFunction(key, raw, out);
      }

      return out;
    } catch (_) {
      return [];
    }
  }

  // --- Astrology (conservative, big3-first) ---

  static List<String> _chartPlacements(AstrologyChartModel chart) {
    final out = <String>[];
    for (final raw in [
      chart.big3['sun'],
      chart.big3['moon'],
      chart.big3['rising'],
    ]) {
      final sign = _normalizeSign(raw);
      if (sign != null) out.add(sign);
    }

    if (out.isNotEmpty) return out;

    for (final key in ['sun', 'moon', 'mercury', 'venus', 'mars']) {
      final sign = _planetSign(chart.planets, key);
      if (sign != null) out.add(sign);
    }
    return out;
  }

  static String? _planetSign(Map<String, dynamic> planets, String key) {
    final value = planets[key];
    if (value is Map) return _normalizeSign(value['sign']);
    if (value is String) return _normalizeSign(value);
    return null;
  }

  static int _scoreOpenness(List<String> placements) {
    var score = 0;
    for (final sign in placements) {
      final meta = _signMeta[sign];
      if (meta == null) continue;
      if (meta.$1 == _ZodiacElement.air) score++;
      if (meta.$2 == _ZodiacModality.mutable) score++;
    }
    return score;
  }

  static int _scoreIntuition(
    List<String> placements,
    AstrologyChartModel chart,
  ) {
    var score = 0;
    for (final sign in placements) {
      final meta = _signMeta[sign];
      if (meta == null) continue;
      if (meta.$1 == _ZodiacElement.water) score++;
      if (meta.$2 == _ZodiacModality.mutable) score++;
    }
    final moon = _normalizeSign(chart.big3['moon']) ??
        _planetSign(chart.planets, 'moon');
    if (moon != null && _signMeta[moon]?.$1 == _ZodiacElement.water) {
      score++;
    }
    return score;
  }

  static int _scoreEmotionalSensitivity(
    List<String> placements,
    AstrologyChartModel chart,
  ) {
    var score = 0;
    final moon = _normalizeSign(chart.big3['moon']) ??
        _planetSign(chart.planets, 'moon');

    for (final sign in placements) {
      if (_signMeta[sign]?.$1 == _ZodiacElement.water) score++;
    }
    if (moon != null && _signMeta[moon]?.$1 == _ZodiacElement.water) {
      score += 2;
    }
    return score;
  }

  static int _scoreReflection(List<String> placements) {
    var score = 0;
    for (final sign in placements) {
      final meta = _signMeta[sign];
      if (meta == null) continue;
      if (meta.$1 == _ZodiacElement.earth ||
          meta.$1 == _ZodiacElement.water) {
        score++;
      }
      if (meta.$2 == _ZodiacModality.fixed) score++;
    }
    return score;
  }

  // --- MBTI ---

  static List<FusionSignal> _fromTypePreset(
    List<MbtiTypeSignalSpec> preset,
    FusionSignalSource source,
  ) {
    return preset
        .map(
          (spec) => FusionSignal(
            id: spec.$1,
            strength: spec.$2,
            confidence: FusionSignal.confidenceForStrength(spec.$2),
            source: source,
          ),
        )
        .toList();
  }

  static List<FusionSignal> _fromDichotomies(
    Map<String, double> traits,
    FusionSignalSource source,
  ) {
    final out = <FusionSignal>[];

    void add(String id, FusionSignalStrength strength) {
      out.add(
        FusionSignal(
          id: id,
          strength: strength,
          confidence: FusionSignal.confidenceForStrength(strength),
          source: source,
        ),
      );
    }

    final e = traits['E'];
    final i = traits['I'];
    if (e != null && i != null) {
      if (e >= i) {
        add(FusionSignalIds.socialExpression, FusionSignalStrength.medium);
      } else {
        add(FusionSignalIds.reflection, FusionSignalStrength.medium);
      }
    }

    final s = traits['S'];
    final n = traits['N'];
    if (s != null && n != null) {
      if (n >= s) {
        add(FusionSignalIds.exploration, FusionSignalStrength.medium);
        add(FusionSignalIds.intuition, FusionSignalStrength.medium);
        add(FusionSignalIds.curiosity, FusionSignalStrength.medium);
      } else {
        add(FusionSignalIds.structure, FusionSignalStrength.medium);
      }
    }

    final t = traits['T'];
    final f = traits['F'];
    if (t != null && f != null) {
      if (t >= f) {
        add(FusionSignalIds.logicOrientation, FusionSignalStrength.medium);
      } else {
        add(FusionSignalIds.emotionalProcessing, FusionSignalStrength.medium);
      }
    }

    final j = traits['J'];
    final p = traits['P'];
    if (j != null && p != null) {
      if (j >= p) {
        add(FusionSignalIds.structure, FusionSignalStrength.medium);
      } else {
        add(FusionSignalIds.exploration, FusionSignalStrength.low);
        add(FusionSignalIds.openness, FusionSignalStrength.medium);
      }
    }

    return out;
  }

  // --- Cognitive functions ---

  static const _cognitiveMinScore = 40.0;

  static void _applyCognitiveFunction(
    String key,
    double score,
    List<FusionSignal> out,
  ) {
    if (score < _cognitiveMinScore) return;

    final strength = _strengthFromScore(score);
    void emit(String id, FusionSignalStrength s) {
      out.add(
        FusionSignal(
          id: id,
          strength: s,
          confidence: FusionSignal.confidenceForStrength(s),
          source: FusionSignalSource.cognitive,
        ),
      );
    }

    switch (key) {
      case 'Te':
        emit(FusionSignalIds.logicOrientation, strength);
        emit(FusionSignalIds.structure, _downgrade(strength));
      case 'Ti':
        emit(FusionSignalIds.logicOrientation, strength);
        emit(FusionSignalIds.reflection, _downgrade(strength));
      case 'Ne':
        emit(FusionSignalIds.exploration, strength);
        emit(FusionSignalIds.curiosity, _downgrade(strength));
        emit(FusionSignalIds.openness, _downgrade(strength));
      case 'Ni':
        emit(FusionSignalIds.intuition, strength);
        emit(FusionSignalIds.reflection, _downgrade(strength));
      case 'Se':
        emit(FusionSignalIds.exploration, _downgrade(strength));
      case 'Si':
        emit(FusionSignalIds.structure, _downgrade(strength));
      case 'Fe':
        emit(FusionSignalIds.socialExpression, _downgrade(strength));
        emit(FusionSignalIds.emotionalProcessing, _downgrade(strength));
      case 'Fi':
        emit(FusionSignalIds.reflection, _downgrade(strength));
        emit(FusionSignalIds.emotionalProcessing, strength);
    }
  }

  static FusionSignalStrength _strengthFromScore(double score) {
    if (score >= 70) return FusionSignalStrength.high;
    if (score >= 55) return FusionSignalStrength.medium;
    return FusionSignalStrength.low;
  }

  static FusionSignalStrength _downgrade(FusionSignalStrength strength) {
    return switch (strength) {
      FusionSignalStrength.high => FusionSignalStrength.medium,
      FusionSignalStrength.medium => FusionSignalStrength.low,
      FusionSignalStrength.low => FusionSignalStrength.low,
    };
  }

  // --- Shared helpers ---

  static void _addIfPositive(
    List<FusionSignal> out,
    String id,
    int score,
    FusionSignalSource source,
  ) {
    if (score <= 0) return;
    final strength = _strengthFromPlacementScore(score);
    out.add(
      FusionSignal(
        id: id,
        strength: strength,
        confidence: FusionSignal.confidenceForStrength(strength),
        source: source,
      ),
    );
  }

  static FusionSignalStrength _strengthFromPlacementScore(int score) {
    if (score >= 3) return FusionSignalStrength.high;
    if (score >= 2) return FusionSignalStrength.medium;
    return FusionSignalStrength.low;
  }

  static String? _normalizeSign(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return null;
    final s = raw.trim();
    final key = s[0].toUpperCase() + s.substring(1).toLowerCase();
    return _signMeta.containsKey(key) ? key : null;
  }
}

enum _ZodiacElement { fire, earth, air, water }

enum _ZodiacModality { cardinal, fixed, mutable }

const _signMeta = {
  'Aries': (_ZodiacElement.fire, _ZodiacModality.cardinal),
  'Taurus': (_ZodiacElement.earth, _ZodiacModality.fixed),
  'Gemini': (_ZodiacElement.air, _ZodiacModality.mutable),
  'Cancer': (_ZodiacElement.water, _ZodiacModality.cardinal),
  'Leo': (_ZodiacElement.fire, _ZodiacModality.fixed),
  'Virgo': (_ZodiacElement.earth, _ZodiacModality.mutable),
  'Libra': (_ZodiacElement.air, _ZodiacModality.cardinal),
  'Scorpio': (_ZodiacElement.water, _ZodiacModality.fixed),
  'Sagittarius': (_ZodiacElement.fire, _ZodiacModality.mutable),
  'Capricorn': (_ZodiacElement.earth, _ZodiacModality.cardinal),
  'Aquarius': (_ZodiacElement.air, _ZodiacModality.fixed),
  'Pisces': (_ZodiacElement.water, _ZodiacModality.mutable),
};
