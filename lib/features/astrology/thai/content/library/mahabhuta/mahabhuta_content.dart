import '../../models/thai_content_section.dart';
import 'mahabhuta_adhibodi.dart';
import 'mahabhuta_marana.dart';
import 'mahabhuta_puti.dart';
import 'mahabhuta_pyadhi.dart';
import 'mahabhuta_rachiya.dart';
import 'mahabhuta_thaya.dart';
import 'mahabhuta_thongchai.dart';

/// Approved Mahabhuta Position content for Thai Astrology V1.
abstract final class MahabhutaContent {
  static List<ThaiContentSection> all() => const [
        mahabhutaPyadhiSection,
        mahabhutaMaranaSection,
        mahabhutaThayaSection,
        mahabhutaPutiSection,
        mahabhutaRachiyaSection,
        mahabhutaThongchaiSection,
        mahabhutaAdhibodiSection,
      ];
}
