import '../../models/thai_content_section.dart';
import 'lagna_lord_jupiter.dart';
import 'lagna_lord_mars.dart';
import 'lagna_lord_mercury.dart';
import 'lagna_lord_moon.dart';
import 'lagna_lord_saturn.dart';
import 'lagna_lord_sun.dart';
import 'lagna_lord_venus.dart';

/// Approved Lagna Lord (7 grahas) content for Thai Astrology V1.
abstract final class LagnaLordContent {
  static List<ThaiContentSection> all() => const [
        lagnaLordSunSection,
        lagnaLordMoonSection,
        lagnaLordMarsSection,
        lagnaLordMercurySection,
        lagnaLordJupiterSection,
        lagnaLordVenusSection,
        lagnaLordSaturnSection,
      ];
}
