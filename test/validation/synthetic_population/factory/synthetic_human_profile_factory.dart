import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_models.dart';
import 'package:knowme/features/tests/big_five/domain/big_five_trait_id.dart';
import 'package:knowme/features/tests/mbti/domain/mbti_models.dart';

import '../data/synthetic_human_archetype_catalog.dart';
import '../factory/synthetic_human_bazi_chart_factory.dart';
import '../models/synthetic_human_archetype_spec.dart';
import '../models/synthetic_human_profile.dart';
import '../models/synthetic_human_variant.dart';

/// Deterministic factory — 50 archetypes × 4 variants = 200 profiles.
abstract final class SyntheticHumanProfileFactory {
  static List<SyntheticHumanProfile> buildAll() {
    final profiles = <SyntheticHumanProfile>[];
    for (final spec in SyntheticHumanArchetypeCatalog.all()) {
      for (final variant in SyntheticHumanVariant.values) {
        profiles.add(build(spec: spec, variant: variant));
      }
    }
    return profiles;
  }

  static SyntheticHumanProfile build({
    required SyntheticHumanArchetypeSpec spec,
    required SyntheticHumanVariant variant,
  }) {
    final profileId = '${spec.id}_variant${variant.label.toLowerCase()}';
    final mbtiType = _mbtiForVariant(spec.mbtiType, variant);
    final bigFive = _bigFiveForVariant(spec, variant);
    final eq = _eqForVariant(spec, variant);
    final birth = _birthData(spec, variant);
    final animalShift = variant == SyntheticHumanVariant.d ? 6 : 0;
    final dayMasterIndex = variant == SyntheticHumanVariant.d
        ? (spec.dayMasterSpecIndex + 2) % 4
        : spec.dayMasterSpecIndex;

    final baziChart = SyntheticHumanBaziChartFactory.build(
      profileId: profileId,
      animalIndex: spec.yearAnimalIndex,
      dayMasterSpecIndex: dayMasterIndex,
      animalShift: animalShift,
    );

    return SyntheticHumanProfile(
      profileId: profileId,
      archetypeId: spec.id,
      archetypeName: spec.name,
      variant: variant,
      mbtiType: mbtiType,
      mbtiDimensions: _mbtiDimensions(mbtiType),
      bigFiveScores: bigFive.scores,
      bigFiveBands: bigFive.bands,
      eqAwarenessLevel: eq.awareness,
      eqRegulationLevel: eq.regulation,
      attachmentStyle: spec.attachmentStyle,
      thaiBirthData: birth,
      baziChart: baziChart,
      yearAnimalKey: SyntheticHumanBaziChartFactory.animalKey(
        spec.yearAnimalIndex,
        shift: animalShift,
      ),
      dayMasterLabel:
          SyntheticHumanBaziChartFactory.dayMasterLabel(dayMasterIndex),
      dominantElement:
          SyntheticHumanBaziChartFactory.dominantElement(dayMasterIndex),
    );
  }

  static String _mbtiForVariant(String base, SyntheticHumanVariant variant) {
    if (variant == SyntheticHumanVariant.b) {
      return _flipJp(base);
    }
    return base;
  }

  static String _flipJp(String type) {
    if (type.length != 4) return type;
    final last = type[3];
    final flipped = last == 'J' ? 'P' : 'J';
    return '${type.substring(0, 3)}$flipped';
  }

  static _BigFiveBundle _bigFiveForVariant(
    SyntheticHumanArchetypeSpec spec,
    SyntheticHumanVariant variant,
  ) {
    var o = spec.openness;
    var c = spec.conscientiousness;
    var e = spec.extraversion;
    var a = spec.agreeableness;
    var n = spec.neuroticism;

    if (variant == SyntheticHumanVariant.c) {
      e = _clampScore(e + 14);
      n = _clampScore(n + 12);
    }

    final scores = {
      BigFiveTraitId.openness: o,
      BigFiveTraitId.conscientiousness: c,
      BigFiveTraitId.extraversion: e,
      BigFiveTraitId.agreeableness: a,
      BigFiveTraitId.neuroticism: n,
    };

    return _BigFiveBundle(
      scores: {
        for (final entry in scores.entries)
          entry.key: entry.value,
      },
      bands: {
        for (final entry in scores.entries)
          entry.key: _scoreToBand(entry.value),
      },
    );
  }

  static _EqBundle _eqForVariant(
    SyntheticHumanArchetypeSpec spec,
    SyntheticHumanVariant variant,
  ) {
    var awareness = spec.eqAwarenessLevel;
    var regulation = spec.eqRegulationLevel;

    if (variant == SyntheticHumanVariant.c) {
      awareness = _shiftEqLevel(awareness, -1);
      regulation = _shiftEqLevel(regulation, -1);
    }

    return _EqBundle(awareness: awareness, regulation: regulation);
  }

  static ThaiBirthData _birthData(
    SyntheticHumanArchetypeSpec spec,
    SyntheticHumanVariant variant,
  ) {
    final hour = switch (variant) {
      SyntheticHumanVariant.a => 9,
      SyntheticHumanVariant.b => 14,
      SyntheticHumanVariant.c => 6,
      SyntheticHumanVariant.d => 21,
    };

    final month = (spec.birthYearOffset % 12) + 1;
    final day = (spec.birthYearOffset % 27) + 2;
    final year = 1970 + (spec.birthYearOffset % 35);

    return ThaiBirthData(
      localDateTime: DateTime(year, month, day, hour, 30),
      timeZoneOffset: const Duration(hours: 7),
      latitude: 13.7563 + (spec.birthYearOffset % 5) * 0.01,
      longitude: 100.5018 + (spec.birthYearOffset % 5) * 0.01,
    );
  }

  static Map<String, int> _mbtiDimensions(String type) {
    const intensity = 68;
    int pref(String letter, String opposite) {
      return type.contains(letter) ? intensity : 100 - intensity;
    }

    return {
      'E': pref('E', 'I'),
      'I': pref('I', 'E'),
      'S': pref('S', 'N'),
      'N': pref('N', 'S'),
      'T': pref('T', 'F'),
      'F': pref('F', 'T'),
      'J': pref('J', 'P'),
      'P': pref('P', 'J'),
    };
  }

  static String _scoreToBand(int score) {
    if (score < 45) return BigFiveBandId.emerging;
    if (score <= 65) return BigFiveBandId.moderate;
    return BigFiveBandId.strong;
  }

  static int _clampScore(int value) => value.clamp(20, 95);

  static String _shiftEqLevel(String level, int delta) {
    const order = ['emerging', 'moderate', 'strong'];
    final index = order.indexOf(level);
    if (index < 0) return level;
    return order[(index + delta).clamp(0, order.length - 1)];
  }
}

class _BigFiveBundle {
  const _BigFiveBundle({required this.scores, required this.bands});

  final Map<String, int> scores;
  final Map<String, String> bands;
}

class _EqBundle {
  const _EqBundle({required this.awareness, required this.regulation});

  final String awareness;
  final String regulation;
}
