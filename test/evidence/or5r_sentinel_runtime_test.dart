import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/export/thai_beta_browser_print.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/thai_chart_engine.dart';
import 'package:knowme/features/birth_normalization/application/adapters/thai_birth_adapter.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/application/sunrise_calculator.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/providers/thai_lunar_calendar_provider.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/repository/thai_lunar_repository.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/models/thai_lunar_lookup_key.dart';
import 'package:knowme/features/astrology/thai/foundation/lunar/models/thai_lunar_record.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';
import 'package:knowme/features/astrology/thai/foundation/chart/seven_number_chart.dart';

class ObservedRepository extends InMemoryThaiLunarRepository {
  int lookups = 0;
  @override
  ThaiLunarRecord? lookup(ThaiLunarLookupKey key) {
    lookups++;
    return super.lookup(key);
  }
}

void main() {
  test('OR5R omission metadata is explicit without a duplicate banner', () {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Civil',
        lastName: 'Only',
        birthDate: DateTime(1990, 6, 15),
        birthTimeUnknown: true,
        province: 'กรุงเทพมหานคร',
        provinceKey: 'bangkok',
      ),
      startedAt: DateTime(2026, 8, 29),
      asOf: DateTime(2026, 8, 29),
    );
    final view = analysis.consumerViewState!;
    expect(view.birthDataConfidence.isComplete, isFalse);
    expect(view.birthDataConfidence.title, isEmpty);
    expect(view.birthDataConfidence.body, isEmpty);
    expect(
      view.hero.identitySubtitle,
      'ไม่มีเวลาเกิด — ภาพรวมข้อมูลวันเกิดตามปฏิทินและข้อจำกัด',
    );
    expect(view.lifeTimeline, isNull);
    expect(view.futurePrediction, isNull);
    final document = ThaiBetaReportExportDocument.candidate(analysis);
    expect(view.hero.summary.allMatches(document.fullPlainText), hasLength(1));
    expect(document.sections.map((s) => s.title), const [
      'ส่วนที่ 1 · พื้นดวงของคุณ',
      'ส่วนที่ 2 · จังหวะชีวิตที่ผ่านมาและปัจจุบัน',
      'ส่วนที่ 3 · แนวโน้มข้างหน้า',
      'ส่วนที่ 4 · ที่มาและข้อจำกัด',
    ]);
    expect(
      document.sections.map((s) => s.kind).toList(),
      List.filled(4, ThaiBetaReportExportSectionKind.chapter),
    );
    expect(
      'class="report-section chapter"'.allMatches(browserPrintMarkup(document)),
      hasLength(4),
    );
  });
  test('OR5R Known sunrise and Unknown sentinel have different authority', () {
    final n = BirthNormalizer.normalize(
      RawBirthInput(birthDate: DateTime(1990, 6, 15), birthHour: null),
    ).birth!;
    for (final known in [true, false]) {
      for (final hm in [(0, 0), (12, 0), (23, 59)]) {
        final c = ThaiBirthAdapter.build(
          localDateTime: DateTime(1990, 6, 15, hm.$1, hm.$2),
          sunrise: SunriseCalculation(
            localSunrise: n.sunrise,
            available: n.sunriseAvailable,
          ),
          location: n.location,
          timeZone: n.timeZone,
          hasBirthTime: known,
        );
        expect(c.hasBirthTime, known);
        expect(c.bornBeforeSunrise, known && hm.$1 == 0);
        expect(
          c.astrologicalDate,
          known && hm.$1 == 0 ? DateTime(1990, 6, 14) : DateTime(1990, 6, 15),
        );
        expect(
          c.localDateTime.hour,
          hm.$1,
          reason: 'Never coerce every placeholder back to noon',
        );
      }
    }
    final reasons = n.reasons.map((r) => r.name).toList();
    expect(reasons, contains('unknownTimeSentinelNonAuthoritative'));
    expect(reasons, isNot(contains('bornBeforeLocalSunrise')));
    expect(reasons, isNot(contains('bornAfterLocalSunrise')));
    expect(reasons, isNot(contains('westernUsesExactInstant')));
  });
  test(
    'OR5R Unknown never reaches exact-time lunar repository or seven-number chart',
    () {
      final repo = ObservedRepository();
      final provider = ThaiLunarCalendarProvider(repository: repo);
      for (final hm in [(0, 0), (12, 0), (23, 59)]) {
        final b = ThaiBirthData(
          localDateTime: DateTime(1982, 6, 6, hm.$1, hm.$2),
          timeZoneOffset: const Duration(hours: 7),
          latitude: 18.7883,
          longitude: 98.9853,
          hasBirthTime: false,
        );
        expect(provider.resolve(b).lunarDate, isNull);
        expect(provider.resolve(b).sourceId, isNull);
        expect(SevenNumberChart.calculate(b).chart, isNull);
        final chart = ThaiChartEngine.generate(b);
        expect(chart.metadata.hasBirthTime, isFalse);
        expect(chart.lagna, isNull);
        expect(chart.houses, isEmpty);
        expect(chart.placements, isEmpty);
      }
      expect(repo.lookups, 0);
      provider.resolve(
        ThaiBirthData(
          localDateTime: DateTime(1982, 6, 6, 0, 35),
          timeZoneOffset: const Duration(hours: 7),
          latitude: 18.7883,
          longitude: 98.9853,
          hasBirthTime: true,
        ),
      );
      expect(repo.lookups, 1);
    },
  );
}
