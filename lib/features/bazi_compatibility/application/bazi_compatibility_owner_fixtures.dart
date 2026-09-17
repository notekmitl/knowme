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
        'gender': known ? 'male' : null,
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

  /// Reader V3 reference case using the existing synthetic 1990 fixture.
  ///
  /// The fixture intentionally keeps only the active decade and annual year;
  /// production responses include the complete deterministic cycle list.
  static BaziChartModel readerV3Chart() {
    return BaziChartModel.fromMap({
      'version': 'knowme_bazi_reader_v3',
      'contract_id': 'knowme_bazi_reader_v3',
      'contract_name': 'KnowMe BaZi Reader V3',
      'engine_version': 'lunar_python@1.4.8+tzdata@2025.2+noaa_eot_v1',
      'generated_at': '2026-09-16T00:00:00+00:00',
      'input_hash':
          'a30a41564cbfccc72891e75bb463c7157622f8c5832a4625dd4bc81d072bd287',
      'completeness': 'four_pillars',
      'time_known': true,
      'input': {
        'birth_date': '1990-05-12',
        'birth_time': '15:30',
        'timezone': 'Asia/Bangkok',
        'latitude': 13.7563,
        'longitude': 100.5018,
        'gender': 'male',
        'coordinates_used_in_calculation': true,
      },
      'solar_time': {
        'status': 'computed',
        'method': 'noaa_fractional_year_eot_v1',
        'local_civil_datetime': '1990-05-12T15:30:00+07:00',
        'timezone': 'Asia/Bangkok',
        'historical_utc_offset_minutes': 420.0,
        'standard_meridian_degrees': 105.0,
        'latitude_degrees': 13.7563,
        'longitude_degrees': 100.5018,
        'longitude_correction_minutes': -17.9928,
        'equation_of_time_minutes': 3.897586,
        'total_correction_minutes': -14.095214,
        'apparent_solar_datetime': '1990-05-12T15:15:54',
        'rounding': 'nearest_second_half_up',
      },
      'ambiguities': {'year': false, 'month': false, 'day': false},
      'suppressed_fields': <String>[],
      'day_master': {
        'stem': '丁',
        'stem_roman': 'ding',
        'element': 'fire',
        'polarity': 'yin',
        'pillar_label': '丁丑',
      },
      'year_animal': {'zh': '马', 'roman': 'horse', 'en': 'Horse'},
      'dominant_element': 'fire',
      'element_balance': {
        'wood': 0,
        'fire': 3,
        'earth': 2,
        'metal': 3,
        'water': 0,
        'total_slots': 8,
        'method': 'surface_stem_branch_compatibility_v1',
      },
      'pillars': {
        'year': _readerPillar(
          '庚',
          '午',
          'geng',
          'wu',
          'metal',
          'fire',
          ['丁', '己'],
          '正财',
          ['比肩', '食神'],
        ),
        'month': _readerPillar(
          '辛',
          '巳',
          'xin',
          'si',
          'metal',
          'fire',
          ['丙', '庚', '戊'],
          '偏财',
          ['劫财', '正财', '伤官'],
        ),
        'day': _readerPillar(
          '丁',
          '丑',
          'ding',
          'chou',
          'fire',
          'earth',
          ['己', '癸', '辛'],
          '日主',
          ['食神', '七杀', '偏财'],
        ),
        'hour': _readerPillar(
          '戊',
          '申',
          'wu',
          'shen',
          'earth',
          'metal',
          ['庚', '壬', '戊'],
          '伤官',
          ['正财', '正官', '伤官'],
        ),
      },
      'ten_god_balance': {
        'visible': {'伤官': 1, '正财': 1, '偏财': 1},
        'hidden': {
          '比肩': 1,
          '劫财': 1,
          '食神': 2,
          '伤官': 2,
          '正财': 2,
          '偏财': 1,
          '正官': 1,
          '七杀': 1,
        },
        'family_weight': {
          'resource': 0,
          'peer': 2,
          'output': 6,
          'wealth': 7,
          'authority': 2,
        },
        'top_families': ['wealth'],
        'method': 'visible_stem_2_hidden_stem_1_v2',
      },
      'day_master_support': {
        'score': 4,
        'max_score': 9,
        'band': 'balanced',
        'season_score': 3,
        'ground_score': 1,
        'visible_support_score': 0,
        'resource_element': 'wood',
        'method': 'three_gains_primary_qi_v2',
      },
      'natal_relations': [
        {
          'kind': 'branch_harm',
          'roles': ['year', 'day'],
          'symbols': ['午', '丑'],
        },
        {
          'kind': 'branch_combine',
          'roles': ['month', 'hour'],
          'symbols': ['巳', '申'],
          'target_element': 'water',
        },
      ],
      'luck': {
        'gender': 'male',
        'direction': 'forward',
        'onset': {'years': 8, 'months': 2, 'days': 10, 'date': '1998-07-22'},
        'method': 'lunar_python_yun_traditional_sect_1_v2',
        'cycles': [
          {
            'start_year': 2018,
            'end_year': 2027,
            'start_age': 29,
            'end_age': 38,
            'pillar_label': '甲申',
            'stem': '甲',
            'branch': '申',
            'stem_ten_god': '正印',
            'natal_relations': [
              {
                'kind': 'stem_clash',
                'roles': ['decade', 'year'],
                'symbols': ['甲', '庚'],
              },
              {
                'kind': 'branch_combine',
                'roles': ['decade', 'month'],
                'symbols': ['申', '巳'],
                'target_element': 'water',
              },
            ],
            'annual': [
              {
                'year': 2026,
                'age': 37,
                'pillar_label': '丙午',
                'stem': '丙',
                'branch': '午',
                'stem_ten_god': '劫财',
                'natal_relations': [
                  {
                    'kind': 'branch_self_punishment',
                    'roles': ['annual', 'year'],
                    'symbols': ['午', '午'],
                  },
                  {
                    'kind': 'stem_combine',
                    'roles': ['annual', 'month'],
                    'symbols': ['丙', '辛'],
                    'target_element': 'water',
                  },
                  {
                    'kind': 'branch_harm',
                    'roles': ['annual', 'day'],
                    'symbols': ['午', '丑'],
                  },
                ],
              },
            ],
          },
        ],
      },
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

  static Map<String, dynamic> _readerPillar(
    String stem,
    String branch,
    String stemRoman,
    String branchRoman,
    String stemElement,
    String branchElement,
    List<String> hiddenStems,
    String stemTenGod,
    List<String> hiddenTenGods,
  ) {
    return {
      ..._pillar(
        stem,
        branch,
        stemRoman,
        branchRoman,
        stemElement,
        branchElement,
      ),
      'hidden_stems': hiddenStems,
      'stem_ten_god': stemTenGod,
      'hidden_ten_gods': hiddenTenGods,
    };
  }

  static String _hash(BaziOwnerCase ownerCase) => switch (ownerCase) {
    BaziOwnerCase.known =>
      '3b37f200a97686ab552395d92bc237d40aa63d73fcb9785dcfd9a492c8d2a221',
    BaziOwnerCase.unknown =>
      '31398fcc4237ba2d008ccd62c3259f5391176959bfa09c57fd2a98655e656e77',
    BaziOwnerCase.lichunUnknown =>
      '41fdb6267689f89f469f086753e874819810463323340671a0c9631a8f305834',
    BaziOwnerCase.jieUnknown =>
      '65ac946d5765a0f430dcf968d6cce651d579ebc9dfccf472b0767ece992a1116',
  };
}
