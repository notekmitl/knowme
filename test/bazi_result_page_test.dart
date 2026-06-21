import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/presentation/pages/bazi/bazi_result_page.dart';
import 'package:knowme/presentation/providers/bazi_provider.dart';
import 'package:knowme/presentation/providers/locale_provider.dart';
import 'package:provider/provider.dart';

BaziChartModel _sampleChart() {
  return BaziChartModel.fromMap({
    'version': 'bazi_v1',
    'engine_version': 'lunar_python@1.4.8',
    'generated_at': '2026-06-07T07:22:13.583812+00:00',
    'input_hash': 'abc',
    'completeness': 'four_pillars',
    'dominant_element': 'fire',
    'day_master': {
      'stem': '丁',
      'stem_roman': 'ding',
      'element': 'fire',
      'polarity': 'yin',
      'pillar_label': '丁丑',
    },
    'year_animal': {'zh': '马', 'roman': 'horse', 'en': 'Horse'},
    'element_balance': {
      'wood': 0,
      'fire': 3,
      'earth': 2,
      'metal': 3,
      'water': 0,
      'total_slots': 8,
      'method': 'surface_stem_branch_v1',
    },
    'pillars': {
      'year': {
        'stem': '庚',
        'branch': '午',
        'stem_roman': 'geng',
        'branch_roman': 'wu',
        'stem_element': 'metal',
        'branch_element': 'fire',
        'pillar_label': '庚午',
      },
      'month': {
        'stem': '辛',
        'branch': '巳',
        'stem_roman': 'xin',
        'branch_roman': 'si',
        'stem_element': 'metal',
        'branch_element': 'fire',
        'pillar_label': '辛巳',
      },
      'day': {
        'stem': '丁',
        'branch': '丑',
        'stem_roman': 'ding',
        'branch_roman': 'chou',
        'stem_element': 'fire',
        'branch_element': 'earth',
        'pillar_label': '丁丑',
      },
      'hour': {
        'stem': '戊',
        'branch': '申',
        'stem_roman': 'wu',
        'branch_roman': 'shen',
        'stem_element': 'earth',
        'branch_element': 'metal',
        'pillar_label': '戊申',
      },
    },
  });
}

Widget _wrap(Widget child, BaziProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<BaziProvider>.value(value: provider),
      ChangeNotifierProvider(
        create: (_) => LocaleProvider()..setLocale('en'),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('shows empty state when chart is null', (tester) async {
    final provider = BaziProvider(loadChartFn: (_) async => null);

    await tester.pumpWidget(
      _wrap(const BaziResultPage(userId: 'test-uid'), provider),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No BaZi chart saved'), findsOneWidget);
  });

  testWidgets('renders insight-first sections when chart loaded', (tester) async {
    final provider = BaziProvider(loadChartFn: (_) async => _sampleChart());

    await tester.pumpWidget(
      _wrap(const BaziResultPage(userId: 'test-uid'), provider),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yin Fire'), findsOneWidget);
    expect(find.text('Through the Chinese chart lens'), findsOneWidget);
    expect(find.text('Core Self'), findsOneWidget);
    expect(find.text('Chart emphasis'), findsOneWidget);
    expect(find.text('Prominent Fire'), findsOneWidget);
    expect(find.text('Strengths'), findsWidgets);
    expect(find.text('Growth Areas'), findsOneWidget);
    expect(find.text('Year Zodiac Personality'), findsOneWidget);
    expect(find.text('Horse'), findsWidgets);
    expect(find.text('Core Traits'), findsOneWidget);
    expect(find.text('Work Style'), findsOneWidget);
    expect(find.text('Overall Chinese Lens Summary'), findsOneWidget);
    expect(find.text('In-depth data'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('In-depth data'),
      120,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('In-depth data'));
    await tester.pumpAndSettle();

    expect(find.text('Four Pillars'), findsOneWidget);
    expect(find.textContaining('Pillar code:'), findsWidgets);
    expect(find.textContaining('Heavenly Stem:'), findsWidgets);
    expect(find.textContaining('Earthly Branch:'), findsWidgets);
    expect(find.textContaining('Day (core self)'), findsOneWidget);
    expect(
      find.textContaining('Core starting points in Chinese chart reading'),
      findsOneWidget,
    );
    expect(
      find.textContaining('This is the structural basis'),
      findsOneWidget,
    );
    expect(find.text('What the elements mean'), findsOneWidget);
    expect(find.textContaining('⚔️ Metal / 🔥 Fire'), findsWidgets);
    expect(find.text('Data Version'), findsOneWidget);
  });
}
