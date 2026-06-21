import '../../models/thai_content_section.dart';
import 'myanmar_seven_1.dart';
import 'myanmar_seven_2.dart';
import 'myanmar_seven_3.dart';
import 'myanmar_seven_4.dart';
import 'myanmar_seven_5.dart';
import 'myanmar_seven_6.dart';
import 'myanmar_seven_7.dart';

/// Approved Myanmar Seven Numbers content for Thai Astrology V1.
abstract final class MyanmarSevenContent {
  static List<ThaiContentSection> all() => const [
        myanmarSeven1Section,
        myanmarSeven2Section,
        myanmarSeven3Section,
        myanmarSeven4Section,
        myanmarSeven5Section,
        myanmarSeven6Section,
        myanmarSeven7Section,
      ];
}
