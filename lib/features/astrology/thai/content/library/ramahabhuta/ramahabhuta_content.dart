import '../../models/thai_content_section.dart';
import 'ramahabhuta_earth.dart';
import 'ramahabhuta_fire.dart';
import 'ramahabhuta_water.dart';
import 'ramahabhuta_wind.dart';

/// Approved Ramahabhuta (4 elements) content for Thai Astrology V1.
abstract final class RamahabhutaContent {
  static List<ThaiContentSection> all() => const [
        ramahabhutaEarthSection,
        ramahabhutaWaterSection,
        ramahabhutaWindSection,
        ramahabhutaFireSection,
      ];
}
