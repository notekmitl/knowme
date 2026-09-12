import 'package:knowme/data/models/bazi_chart_model.dart';

enum BaziOwnerCase { known, unknown, lichunUnknown, jieUnknown }

extension BaziOwnerCaseId on BaziOwnerCase {
  String get id => switch (this) {
    BaziOwnerCase.known => 'known',
    BaziOwnerCase.unknown => 'unknown',
    BaziOwnerCase.lichunUnknown => 'lichun-unknown',
    BaziOwnerCase.jieUnknown => 'jie-unknown',
  };

  String get label => switch (this) {
    BaziOwnerCase.known => 'Known time',
    BaziOwnerCase.unknown => 'Unknown time',
    BaziOwnerCase.lichunUnknown => 'Unknown · Li Chun',
    BaziOwnerCase.jieUnknown => 'Unknown · Jie',
  };
}

abstract final class BaziCompatibilityOwnerFixtures {
  static BaziOwnerCase parse(String? value) {
    return BaziOwnerCase.values.firstWhere(
      (item) => item.id == value,
      orElse: () => BaziOwnerCase.known,
    );
  }

  static BaziChartModel chart(BaziOwnerCase ownerCase) {
    final known = ownerCase == BaziOwnerCase.known;
    final lichun = ownerCase == BaziOwnerCase.lichunUnknown;
    final jie = ownerCase == BaziOwnerCase.jieUnknown;
    final date = lichun
        ? '1990-02-04'
        : jie
        ? '1990-03-06'
        : '1990-05-12';
    final day = lichun
        ? _pillar('庚', '子', 'geng', 'zi', 'metal', 'water')
        : jie
        ? _pillar('庚', '午', 'geng', 'wu', 'metal', 'fire')
        : _pillar('丁', '丑', 'ding', 'chou', 'fire', 'earth');
    final year = lichun
        ? null
        : _pillar('庚', '午', 'geng', 'wu', 'metal', 'fire');
    final month = lichun || jie
        ? null
        : _pillar('辛', '巳', 'xin', 'si', 'metal', 'fire');
    final hour = known
        ? _pillar('戊', '申', 'wu', 'shen', 'earth', 'metal')
        : null;
    final slots = lichun ? 2 : (jie ? 4 : (known ? 8 : 6));

    return BaziChartModel.fromMap({
      'version': 'knowme_bazi_compatibility_v1',
      'contract_id': 'knowme_bazi_compatibility_v1',
      'contract_name': 'KnowMe BaZi Compatibility V1',
      'engine_version': 'lunar_python@1.4.8',
      'generated_at': '2026-09-12T00:00:00+00:00',
      'input_hash': _hash(ownerCase),
      'completeness': known
          ? 'four_pillars'
          : (lichun || jie ? 'partial_pillars' : 'three_pillars'),
      'time_known': known,
      'input': {
        'birth_date': date,
        'birth_time': known ? '15:30' : null,
        'timezone': 'Asia/Bangkok',
        'coordinates_used_in_calculation': false,
      },
      'ambiguities': {'year': lichun, 'month': lichun || jie, 'day': false},
      'suppressed_fields': known
          ? <String>[]
          : [
              'pillars.hour',
              'hour_dependent_outputs',
              if (lichun) ...['pillars.year', 'year_animal'],
              if (lichun || jie) 'pillars.month',
            ],
      'day_master': {
        'stem': day['stem'],
        'stem_roman': day['stem_roman'],
        'element': day['stem_element'],
        'polarity': lichun || jie ? 'yang' : 'yin',
        'pillar_label': day['pillar_label'],
      },
      'year_animal': lichun
          ? null
          : {'zh': '马', 'roman': 'horse', 'en': 'Horse'},
      'dominant_element': lichun ? 'metal' : 'fire',
      'element_balance': {
        'wood': 0,
        'fire': lichun ? 0 : (jie ? 2 : 3),
        'earth': known ? 2 : (lichun || jie ? 0 : 1),
        'metal': lichun ? 1 : (jie ? 2 : (known ? 3 : 2)),
        'water': lichun ? 1 : 0,
        'total_slots': slots,
        'method': 'surface_stem_branch_compatibility_v1',
      },
      'pillars': {'year': year, 'month': month, 'day': day, 'hour': hour},
    });
  }

  static Map<String, dynamic> _pillar(
    String stem,
    String branch,
    String stemRoman,
    String branchRoman,
    String stemElement,
    String branchElement,
  ) {
    return {
      'stem': stem,
      'branch': branch,
      'stem_roman': stemRoman,
      'branch_roman': branchRoman,
      'stem_element': stemElement,
      'branch_element': branchElement,
      'pillar_label': '$stem$branch',
    };
  }

  static String _hash(BaziOwnerCase ownerCase) => switch (ownerCase) {
    BaziOwnerCase.known =>
      '7e5deacba21e9abc250024b1448bcf902b6efd41f1c4f4a121be0bdcc1a0154b',
    BaziOwnerCase.unknown =>
      '140f0798ba12b456a449d4adf44cda3d2364d9b0c90af5a68520ca12f8409e37',
    BaziOwnerCase.lichunUnknown =>
      '1e283227a84adc21f91975a981753d15ec9c57d038b18674d1bc41d912615947',
    BaziOwnerCase.jieUnknown =>
      '24a2ab8421661f939a7394183afb2543ec21b0838bcf60ad0db975053d2db55a',
  };
}
