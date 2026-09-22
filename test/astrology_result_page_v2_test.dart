import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';
import 'package:knowme/presentation/pages/astrology/astrology_result_page.dart';
import 'package:knowme/presentation/providers/astrology_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'fallback uses API chart directly without post-response Firestore reload',
    (tester) async {
      var loadCalls = 0;
      var generateCalls = 0;
      final chart = _chart();
      final provider = AstrologyProvider(
        loadChartFn: (_) async {
          loadCalls++;
          return null;
        },
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: AstrologyResultPage(
              userId: 'western-fallback-test',
              generateChartForUser: (uid) async {
                generateCalls++;
                expect(uid, 'western-fallback-test');
                return chart;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(generateCalls, 1);
      expect(
        loadCalls,
        1,
        reason: 'only the pre-generation cache read remains',
      );
      expect(provider.chart, same(chart));
      expect(find.byKey(const Key('western-reader-v2-hero')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('stale V2 reader cache regenerates exactly once', (tester) async {
    var loadCalls = 0;
    var generateCalls = 0;
    final provider = AstrologyProvider(
      loadChartFn: (_) async {
        loadCalls++;
        return _chart(readerRevision: 'western_reader_th_v2');
      },
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: AstrologyResultPage(
            userId: 'stale-reader-cache',
            generateChartForUser: (_) async {
              generateCalls++;
              return _chart();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);
    expect(generateCalls, 1);
    expect(provider.chart?.reader['version'], 'western_reader_th_v2_r2');
    expect(find.byKey(const Key('western-reader-v2-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('current reader revision remains a cache hit with no POST', (
    tester,
  ) async {
    var loadCalls = 0;
    var generateCalls = 0;
    final current = _chart();
    final provider = AstrologyProvider(
      loadChartFn: (_) async {
        loadCalls++;
        return current;
      },
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: AstrologyResultPage(
            userId: 'current-reader-cache',
            generateChartForUser: (_) async {
              generateCalls++;
              return _chart();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);
    expect(generateCalls, 0);
    expect(provider.chart, same(current));
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('renders Western Reader V2 at ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = AstrologyProvider(loadChartFn: (_) async => null);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: AstrologyResultPage(
              userId: 'western-ui-test',
              preparedChart: _chart(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('western-reader-v2-hero')), findsOneWidget);
      expect(find.text('แผนที่ชีวิตแบบตะวันตก'), findsOneWidget);
      expect(
        find.text('ดวงอาทิตย์ราศีเมถุน · ดวงจันทร์ราศีธนู · ลัคนาราศีมีน'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('western-reader-v2-chart-structure')),
        findsOneWidget,
      );
      expect(
        find.text('ข้อมูลทางโหราศาสตร์ที่ใช้ประกอบคำอ่าน'),
        findsOneWidget,
      );
      expect(find.text('สมดุลพลังหลัก'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.byKey(const Key('western-reader-v2-method')),
        500,
        scrollable: find.descendant(
          of: find.byKey(const Key('western-reader-v2-scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('วิธีคำนวณ'), findsOneWidget);
      expect(find.text('ข้อจำกัดของคำอ่าน'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

AstrologyChartModel _chart({
  String readerRevision = 'western_reader_th_v2_r2',
}) => AstrologyChartModel(
  version: 'western_natal_v2',
  contractId: 'knowme_western_reader_v2',
  engineVersion: 'swiss_ephemeris_tropical_placidus_v2',
  inputHash: 'fixture-hash',
  big3: const {'sun': 'Gemini', 'moon': 'Sagittarius', 'rising': 'Pisces'},
  planets: const {
    'sun': {'sign': 'Gemini', 'degree': 14.7, 'house': 4, 'retrograde': false},
    'moon': {
      'sign': 'Sagittarius',
      'degree': 19.1,
      'house': 10,
      'retrograde': false,
    },
  },
  insight: const {},
  overallSummary: const {},
  aspects: const [
    {'planet1': 'sun', 'planet2': 'moon', 'aspect': 'opposition', 'orb': 4.4},
  ],
  analysis: const {
    'elements': {
      'percentages': {'fire': 28, 'earth': 12, 'air': 42, 'water': 18},
      'dominant': 'air',
    },
    'modalities': {
      'percentages': {'cardinal': 20, 'fixed': 25, 'mutable': 55},
      'dominant': 'mutable',
    },
    'polarities': {
      'percentages': {'positive': 64, 'negative': 36},
      'dominant': 'positive',
    },
    'dominant_planets': [
      {'planet': 'sun', 'sign': 'Gemini', 'score': 8},
      {'planet': 'moon', 'sign': 'Sagittarius', 'score': 7},
    ],
    'house_emphasis': [
      {'house': 4, 'count': 3},
      {'house': 10, 'count': 2},
    ],
  },
  reader: {
    'version': readerRevision,
    'overview': {
      'th':
          'คุณคิดไวแบบเมถุน ต้องการอิสระทางใจแบบธนู และเข้าหาโลกด้วยความละเอียดอ่อนแบบมีน',
    },
    'sections': [
      {
        'id': 'identity',
        'title': 'ตัวตนและแรงขับ',
        'body': 'ตัวตนหลักชอบเรียนรู้และเชื่อมโยงข้อมูลหลายด้าน',
        'basis': 'ดวงอาทิตย์ราศีเมถุน · ดวงจันทร์ราศีธนู · ลัคนาราศีมีน',
      },
      {
        'id': 'work',
        'title': 'งานและบทบาท',
        'body': 'งานที่เปิดพื้นที่ให้สื่อสารและทดลองจะส่งพลังให้คุณ',
      },
    ],
    'method': 'คำนวณจักรราศี tropical และเรือน Placidus จากเวลาเกิดท้องถิ่น',
    'disclaimer':
        'ใช้เป็นเครื่องมือสะท้อนตนเอง ไม่ใช่คำตัดสินหรือคำแนะนำวิชาชีพ',
  },
);
