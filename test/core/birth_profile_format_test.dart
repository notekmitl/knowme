import 'package:flutter_test/flutter_test.dart';
import 'package:knowme/core/profile/birth_profile_format.dart';

void main() {
  group('BirthProfileFormat', () {
    test('storageDate uses YYYY-MM-DD without time', () {
      expect(
        BirthProfileFormat.storageDate(DateTime(1982, 6, 6)),
        '1982-06-06',
      );
    });

    test('parseStoredDate handles canonical and legacy ISO', () {
      final canonical = BirthProfileFormat.parseStoredDate('1982-06-06');
      expect(canonical?.year, 1982);
      expect(canonical?.month, 6);
      expect(canonical?.day, 6);
      expect(canonical?.hour, 0);

      final legacy = BirthProfileFormat.parseStoredDate('1982-06-06T00:00:00.000');
      expect(legacy?.year, 1982);
      expect(legacy?.month, 6);
      expect(legacy?.day, 6);
    });

    test('displayTime preserves minutes from birthTime field', () {
      expect(BirthProfileFormat.displayTime('00:35'), '00:35');
      expect(BirthProfileFormat.displayTime('9:5'), '09:05');
    });

    test('profileDateTimeLine combines formatted date and time', () {
      expect(
        BirthProfileFormat.profileDateTimeLine('1982-06-06', '00:35'),
        '6/6/1982 • 00:35',
      );
      expect(
        BirthProfileFormat.profileDateTimeLine(
          '1982-06-06T00:00:00.000',
          '00:35',
        ),
        '6/6/1982 • 00:35',
      );
    });
  });
}
