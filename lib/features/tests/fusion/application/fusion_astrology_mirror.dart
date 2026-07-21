import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowme/data/models/astrology_chart_model.dart';

import '../domain/fusion_constants.dart';

/// Mirrors `astrology/western_natal` into `results/astrology` for [FusionLoader].
/// Additive only — does not change astrology read paths.
abstract final class FusionAstrologyMirror {
  static Future<void> mirrorFromChart({
    required String uid,
    required AstrologyChartModel chart,
    FirebaseFirestore? firestore,
  }) async {
    if (uid.isEmpty) return;

    try {
      final db = firestore ?? FirebaseFirestore.instance;
      await db
          .collection('users')
          .doc(uid)
          .collection('results')
          .doc(FusionResultDocIds.astrology)
          .set(_toResultsMap(chart), SetOptions(merge: true));
    } catch (_) {
      // Non-fatal: astrology generate flow must not depend on fusion mirror.
    }
  }

  /// Minimal deterministic snapshot — [AstrologyChartModel.fromMap] compatible.
  static Map<String, dynamic> _toResultsMap(AstrologyChartModel chart) {
    final placements = _bigThreeSigns(chart);

    return {
      'big3': Map<String, dynamic>.from(chart.big3),
      'planets': Map<String, dynamic>.from(chart.planets),
      'insight': const <String, dynamic>{},
      'overall_summary': const <String, dynamic>{},
      'element_summary': _elementSummary(placements),
      'modality_summary': _modalitySummary(placements),
      'mirrored_from': 'astrology/western_natal',
      'mirrored_at': FieldValue.serverTimestamp(),
    };
  }

  static List<String> _bigThreeSigns(AstrologyChartModel chart) {
    final out = <String>[];
    for (final raw in [
      chart.big3['sun'],
      chart.big3['moon'],
      chart.big3['rising'],
    ]) {
      final sign = _normalizeSign(raw);
      if (sign != null) out.add(sign);
    }
    return out;
  }

  static Map<String, int> _elementSummary(List<String> placements) {
    final counts = <String, int>{
      'fire': 0,
      'earth': 0,
      'air': 0,
      'water': 0,
    };
    for (final sign in placements) {
      final element = _signMeta[sign]?.$1;
      if (element == null) continue;
      counts[element.name] = (counts[element.name] ?? 0) + 1;
    }
    return counts;
  }

  static Map<String, int> _modalitySummary(List<String> placements) {
    final counts = <String, int>{
      'cardinal': 0,
      'fixed': 0,
      'mutable': 0,
    };
    for (final sign in placements) {
      final modality = _signMeta[sign]?.$2;
      if (modality == null) continue;
      counts[modality.name] = (counts[modality.name] ?? 0) + 1;
    }
    return counts;
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
