/// Internal Khumsap runtime key — metadata only, never user-facing copy.
///
/// Distinct from [ThaiContentKeys.mahabhutaThaya] (ทายะ / Myanmar-adapted).
/// Maps exactly to Canon `mahabhutPosition.khumsap` (ขุมทรัพย์).
abstract final class ThaiMahabhutKhumsapRuntimeKey {
  static const khumsap = 'mahabhuta_khumsap';

  static const canonEntityId = 'mahabhutPosition.khumsap';

  static bool isKhumsapRuntimeKey(String? key) =>
      key != null && key == khumsap;
}
