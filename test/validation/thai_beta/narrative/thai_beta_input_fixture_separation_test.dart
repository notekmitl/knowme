import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_report_export_document.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';

void main() {
  ThaiBetaAnalysis runAt(int minute) => ThaiBetaAnalysisRunner.run(
    ThaiBetaInput(
      firstName: 'Fixture',
      lastName: 'ChiangMai',
      birthDate: DateTime(1982, 6, 6),
      birthHour: 0,
      birthMinute: minute,
      province: 'เชียงใหม่',
      provinceKey: 'chiang_mai',
    ),
    startedAt: DateTime(2026, 8, 7),
  );

  test('00:03 stays distinct and is identical across Engine and export', () {
    final analysis = runAt(3);
    final profile = analysis.profile!;
    final snapshot = analysis.normalizedSnapshot!;
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);

    expect(analysis.input.birthHour, 0);
    expect(analysis.input.birthMinute, 3);
    expect(analysis.input.birthTimeUnknown, isFalse);
    expect(snapshot.birthTime, '00:03');
    expect(snapshot.timeZoneId, 'Asia/Bangkok');
    expect(snapshot.latitude, closeTo(18.7883, 0.000001));
    expect(snapshot.longitude, closeTo(98.9853, 0.000001));
    expect(profile.lagnaKey, ThaiContentKeys.lagnaAquarius);
    expect(_display(profile.siderealAscendantDeg!), '9°24′');
    expect(export.fullPlainText, contains('ราศีกุมภ์ 9°24′'));
  });

  test('00:35 retains the accepted Aquarius 19°19′ regression baseline', () {
    final analysis = runAt(35);
    expect(analysis.profile!.lagnaKey, ThaiContentKeys.lagnaAquarius);
    expect(_display(analysis.profile!.siderealAscendantDeg!), '19°19′');
    expect(
      ThaiBetaReportExportDocument.fromAnalysis(analysis).fullPlainText,
      contains('ราศีกุมภ์ 19°19′'),
    );
  });

  test('unknown time remains fail-closed and never substitutes noon', () {
    final analysis = ThaiBetaAnalysisRunner.run(
      ThaiBetaInput(
        firstName: 'Fixture',
        lastName: 'Unknown',
        birthDate: DateTime(1982, 6, 6),
        birthTimeUnknown: true,
        province: 'เชียงใหม่',
        provinceKey: 'chiang_mai',
      ),
      startedAt: DateTime(2026, 8, 7),
    );
    final export = ThaiBetaReportExportDocument.fromAnalysis(analysis);

    expect(analysis.normalizedSnapshot!.birthTime, isEmpty);
    expect(analysis.profile!.siderealAscendantDeg, isNull);
    expect(export.fullPlainText, isNot(contains('12:00')));
    expect(export.fullPlainText, contains('ไม่มีเวลาเกิด'));
    expect(export.fullPlainText, contains('วันอาทิตย์ตามปฏิทิน'));
    expect(
      export.fullPlainText,
      contains('วันทางโหราศาสตร์อาจเป็นวันก่อนหน้า'),
    );
    expect(export.fullPlainText, isNot(contains('พระอาทิตย์ขึ้นเวลา')));
  });

  test('00:03 and 00:35 resolve Saturday while unknown asserts no day', () {
    for (final minute in [3, 35]) {
      final text = ThaiBetaReportExportDocument.fromAnalysis(
        runAt(minute),
      ).fullPlainText;
      expect(text, contains('วันเสาร์'));
      expect(text, isNot(contains('วันอาทิตย์')));
    }
  });
}

String _display(double longitude) {
  final withinSign = ((longitude % 30) + 30) % 30;
  final totalMinutes = (withinSign * 60).round();
  return '${totalMinutes ~/ 60}°${(totalMinutes % 60).toString().padLeft(2, '0')}′';
}
