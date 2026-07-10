import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/birth_normalization/application/birth_normalizer.dart';
import 'package:knowme/features/birth_normalization/domain/raw_birth_input.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';
import 'package:knowme/features/thai_beta/domain/thai_beta_input.dart';
import 'package:knowme/features/thai_beta/presentation/thai_beta_thai_date_format.dart';

void main() {
  group('ThaiBetaDateFormat', () {
    test('formats Thai dates in the Buddhist era', () {
      expect(
        ThaiBetaDateFormat.formatDate(DateTime(1982, 6, 8)),
        '8 มิถุนายน 2525',
      );
      expect(
        ThaiBetaDateFormat.formatDate(DateTime(1982, 6, 7)),
        '7 มิถุนายน 2525',
      );
    });

    test('weekday maps Sunday/Saturday correctly', () {
      // 1982-06-06 is a Sunday; 1982-06-05 is a Saturday.
      expect(ThaiBetaDateFormat.weekday(DateTime(1982, 6, 6)), 'วันอาทิตย์');
      expect(ThaiBetaDateFormat.weekday(DateTime(1982, 6, 5)), 'วันเสาร์');
    });

    test('formatIsoDate round-trips a yyyy-MM-dd string', () {
      expect(ThaiBetaDateFormat.formatIsoDate('1982-06-07'), '7 มิถุนายน 2525');
      expect(ThaiBetaDateFormat.parseIso('1982-06-07'), DateTime(1982, 6, 7));
    });
  });

  group('Displayed Thai astrological date matches Birth Normalization', () {
    // Boundary times around Bangkok sunrise (~05:4x for this date).
    const times = <(int, int)>[
      (0, 0),
      (3, 0),
      (5, 47),
      (5, 48),
      (12, 0),
      (23, 59),
    ];

    for (final (hour, minute) in times) {
      final label = '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
      test('birth time $label → display equals normalization', () {
        final date = DateTime(1982, 6, 8);

        // Source of truth: Birth Normalization directly.
        final normalization = BirthNormalizer.normalize(
          RawBirthInput(
            birthDate: date,
            birthHour: hour,
            birthMinute: minute,
            province: 'bangkok',
            placeLabel: 'กรุงเทพมหานคร',
            timeZoneId: 'Asia/Bangkok',
          ),
        );
        expect(normalization.isValid, isTrue);
        final expected = normalization.birth!.thai.astrologicalDate;

        // What the Research UI runs + displays.
        final analysis = ThaiBetaAnalysisRunner.run(
          ThaiBetaInput(
            firstName: 'A',
            lastName: 'B',
            birthDate: date,
            birthHour: hour,
            birthMinute: minute,
            province: 'กรุงเทพมหานคร',
            provinceKey: 'bangkok',
          ),
        );
        expect(analysis.isSuccess, isTrue);

        final snapshot = analysis.normalizedSnapshot!;
        final displayed =
            ThaiBetaDateFormat.parseIso(snapshot.thaiAstrologicalDate);

        // The displayed astrological date must equal normalization, exactly.
        expect(displayed, DateTime(expected.year, expected.month, expected.day));
        expect(snapshot.usedPreviousDay,
            normalization.birth!.thai.bornBeforeSunrise);
      });
    }
  });
}
