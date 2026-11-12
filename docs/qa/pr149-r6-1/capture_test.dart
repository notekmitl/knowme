import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_reading_copy.dart';
import 'package:knowme/features/astrology/fusion/presentation/trial_report_documents.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_owner_fixtures.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_compatibility_report_builder.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

dynamic read(String file) => jsonDecode(File(file).readAsStringSync());
List<dynamic> thai(ThaiBetaReportExportDocument d) => [
  for (final s in d.sections)
    {
      'id': s.id,
      'title': s.title,
      'paragraphs': s.paragraphs,
      'traceIds': s.traceIds,
    },
];
List<dynamic> bazi(BaziCompatibilityReport d) => [
  for (final s in d.sections)
    {
      'title': s.title,
      'intro': s.intro,
      'paragraphs': s.paragraphs,
      'rows': [
        for (final r in s.rows) {'label': r.label, 'value': r.value},
      ],
      'notes': s.notes,
    },
];

BaziChartModel symbolicChart(
  String stem,
  String element,
  String top,
  int wealth,
) {
  final wealthElement = {
    'wood': 'earth',
    'fire': 'metal',
    'earth': 'water',
    'metal': 'wood',
    'water': 'fire',
  }[element]!;
  final balance = <String, int>{
    'wood': 0,
    'fire': 0,
    'earth': 0,
    'metal': 0,
    'water': 0,
  };
  balance[wealthElement] = wealth;
  balance[top] = 6 - wealth;
  return BaziChartModel.fromMap({
    'contract_id': 'knowme_bazi_compatibility_v1',
    'completeness': 'three_pillars',
    'day_master': {'stem': stem, 'element': element},
    'element_balance': {...balance, 'total_slots': 6},
  });
}

void main() {
  test('capture actual authoring branches for manual review', () {
    final asOf = DateTime.parse('2026-11-10T03:00:00Z');
    final thaiCases = <dynamic>[];
    for (var i = 0; i < 24; i++) {
      final timeKnown = i != 23;
      final profile = ThaiBetaInput(
        firstName: 'QA',
        lastName: 'Synthetic',
        birthDate: DateTime(1956 + i * 3, i % 12 + 1, 12),
        birthHour: timeKnown ? i : null,
        birthMinute: 15,
        birthTimeUnknown: !timeKnown,
        province: i % 2 == 0 ? 'กรุงเทพมหานคร' : 'เชียงใหม่',
        provinceKey: i % 2 == 0 ? 'bangkok' : 'chiang mai',
        gender: i % 2 == 0 ? 'ชาย' : 'หญิง',
      );
      final a = ThaiBetaAnalysisRunner.run(
        profile,
        startedAt: asOf,
        asOf: asOf,
      );
      expect(a.isSuccess, isTrue);
      final d = ThaiBetaReportExportDocument.candidate(a);
      final p = TrialReportDocuments.thai(d);
      expect(
        p.sections.map((s) => s.traceIds),
        d.sections.map((s) => s.traceIds),
      );
      final view = a.consumerViewState;
      final hero = view?.hero;
      thaiCases.add({
        'id': i,
        'timeKnown': timeKnown,
        'raw': thai(d),
        'projected': thai(p),
        if (d.infographic != null)
          'annual': {
            'period': d.infographic!.periodLabel,
            'monthlyAvailable': d.infographic!.monthlyTimelineAvailable,
            'monthlyGap': p.infographic!.monthlyGapReason,
            'categories': [
              for (final c in p.infographic!.categories) c.summary,
            ],
          },
        if (hero != null)
          'hero': [
            hero.headline,
            TrialReadingCopy.thaiHeadline(hero.headline),
            TrialReadingCopy.thai(hero.summary),
          ],
        if (view != null)
          'dashboard': [
            for (final t in view.lifeDashboard)
              [t.label, TrialReadingCopy.thaiDashboard(t)],
          ],
      });
    }

    final rawBazi = {
      for (final c in ['a', 'b'])
        c: Map<String, dynamic>.from(
          read('test/fixtures/trial_readability/calculator-$c.json')['bazi'],
        ),
    };
    final charts = <String, BaziChartModel>{
      for (final c in BaziOwnerCase.values)
        c.name: BaziCompatibilityOwnerFixtures.chart(c),
      'v3': BaziCompatibilityOwnerFixtures.readerV3Chart(),
      for (final c in rawBazi.keys) ...{
        c: BaziChartModel.fromMap(rawBazi[c]!),
        'v2-$c': BaziChartModel.fromMap({
          ...rawBazi[c]!,
          'contract_id': 'knowme_bazi_reader_v2',
        }),
      },
      'v2-missing': BaziChartModel.fromMap({
        ...rawBazi['a']!,
        'contract_id': 'knowme_bazi_reader_v2',
        'time_known': false,
        'completeness': 'three_pillars',
        'pillars': {
          ...rawBazi['a']!['pillars'] as Map<String, dynamic>,
          'hour': null,
        },
        'ten_god_balance': <String, dynamic>{},
        'day_master_support': <String, dynamic>{},
        'luck': <String, dynamic>{},
      }),
      for (final (stem, element) in const [
        ('甲', 'wood'),
        ('乙', 'wood'),
        ('丙', 'fire'),
        ('丁', 'fire'),
        ('戊', 'earth'),
        ('己', 'earth'),
        ('庚', 'metal'),
        ('辛', 'metal'),
        ('壬', 'water'),
        ('癸', 'water'),
      ])
        for (final top in ['wood', 'fire', 'earth', 'metal', 'water'].where(
          (e) =>
              e !=
              const {
                'wood': 'earth',
                'fire': 'metal',
                'earth': 'water',
                'metal': 'wood',
                'water': 'fire',
              }[element],
        ))
          for (final wealth in [0, 2, 3, 4])
            'v1-$stem-$top-$wealth': symbolicChart(stem, element, top, wealth),
    };
    final chineseCases = <dynamic>[];
    for (final entry in charts.entries) {
      final years = ['v3', 'a', 'b', 'v2-a', 'v2-b'].contains(entry.key)
          ? [1980, ...List.generate(12, (i) => 2022 + i), 2050, 2100]
          : [2026];
      for (final year in years) {
        final d = BaziCompatibilityReportBuilder.build(
          entry.value,
          asOf: DateTime(year, 11, 10),
        );
        final p = TrialReportDocuments.chinese(d, entry.value);
        expect(p.sections.length, d.sections.length);
        chineseCases.add({
          'case': entry.key,
          'contract': entry.value.contractId,
          'year': year,
          'raw': bazi(d),
          'projected': bazi(p),
        });
      }
    }
    final westernCases = [
      for (final Map<String, dynamic> c in read(
        '.preview-qa/r6-1-western-cases.json',
      ))
        {
          'sign': c['sign'],
          'aspect': c['aspect'],
          'house': c['house'],
          'element': c['element'],
          'modality': c['modality'],
          'overviewRaw': c['reader']['overview']['th'],
          'overview': TrialReadingCopy.western(c['reader']['overview']['th']),
          'sections': [
            for (final Map<String, dynamic> s in c['reader']['sections'])
              {...s, 'after': TrialReadingCopy.western(s['body'])},
          ],
          'method': TrialReadingCopy.western(c['reader']['method']),
          'disclaimer': TrialReadingCopy.western(c['reader']['disclaimer']),
        },
    ];
    File('.preview-qa/r6-1-corpus.json').writeAsStringSync(
      jsonEncode({
        'thai': thaiCases,
        'chinese': chineseCases,
        'western': westernCases,
      }),
    );
  });
}
