import '../../models/thai_content_section.dart';
import 'lagna_aquarius.dart';
import 'lagna_aries.dart';
import 'lagna_cancer.dart';
import 'lagna_capricorn.dart';
import 'lagna_gemini.dart';
import 'lagna_leo.dart';
import 'lagna_libra.dart';
import 'lagna_pisces.dart';
import 'lagna_sagittarius.dart';
import 'lagna_scorpio.dart';
import 'lagna_taurus.dart';
import 'lagna_virgo.dart';

/// Approved Lagna (12 rashi) content for Thai Astrology V1.
abstract final class LagnaContent {
  static List<ThaiContentSection> all() => const [
        lagnaAriesSection,
        lagnaTaurusSection,
        lagnaGeminiSection,
        lagnaCancerSection,
        lagnaLeoSection,
        lagnaVirgoSection,
        lagnaLibraSection,
        lagnaScorpioSection,
        lagnaSagittariusSection,
        lagnaCapricornSection,
        lagnaAquariusSection,
        lagnaPiscesSection,
      ];
}
