import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/features/astrology/thai/mirror/evidence/v135/thai_birthday_year_window.dart';

void main() {
  group('ThaiBirthdayYearWindow', () {
    test('date after birthday uses this year start', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(1982, 6, 6),
        asOfLocal: DateTime(2026, 7, 27),
      );
      expect(w.startInclusive, DateTime(2026, 6, 6));
      expect(w.endInclusive, DateTime(2027, 6, 5));
      expect(w.contains(DateTime(2026, 7, 27)), isTrue);
      expect(w.contains(DateTime(2026, 6, 5)), isFalse);
    });

    test('exact birthday starts new window', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(1982, 6, 6),
        asOfLocal: DateTime(2026, 6, 6),
      );
      expect(w.startInclusive, DateTime(2026, 6, 6));
      expect(w.endInclusive, DateTime(2027, 6, 5));
    });

    test('date before birthday uses previous birthday', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(1982, 6, 6),
        asOfLocal: DateTime(2026, 3, 1),
      );
      expect(w.startInclusive, DateTime(2025, 6, 6));
      expect(w.endInclusive, DateTime(2026, 6, 5));
    });

    test('final day before next birthday is inclusive end', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(1982, 6, 6),
        asOfLocal: DateTime(2027, 6, 5),
      );
      expect(w.startInclusive, DateTime(2026, 6, 6));
      expect(w.endInclusive, DateTime(2027, 6, 5));
      expect(w.contains(DateTime(2027, 6, 5)), isTrue);
      expect(w.contains(DateTime(2027, 6, 6)), isFalse);
    });

    test('leap year birthday 29 Feb in leap year', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(2000, 2, 29),
        asOfLocal: DateTime(2024, 3, 1),
      );
      expect(w.startInclusive, DateTime(2024, 2, 29));
      expect(w.endInclusive, DateTime(2025, 2, 27));
    });

    test('29 Feb birth in non-leap year uses Feb 28', () {
      final w = ThaiBirthdayYearWindow.resolve(
        birthLocalDate: DateTime(2000, 2, 29),
        asOfLocal: DateTime(2025, 3, 1),
      );
      expect(w.startInclusive, DateTime(2025, 2, 28));
      expect(w.endInclusive, DateTime(2026, 2, 27));
    });
  });
}
