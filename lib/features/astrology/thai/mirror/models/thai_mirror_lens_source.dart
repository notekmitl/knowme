import '../../content/models/thai_content_type.dart';

/// Traceable astrology lens families for Mirror evidence.
///
/// Mirrors [ThaiAstrologyProfile] keys — Ramahabhuta is excluded per Foundation
/// V1.1 (use [mahabhutaPosition] instead).
enum ThaiMirrorLensSource {
  lagna,
  lagnaLord,
  myanmarSeven,
  mahabhutaPosition,
}

extension ThaiMirrorLensSourceLabels on ThaiMirrorLensSource {
  String get id {
    return switch (this) {
      ThaiMirrorLensSource.lagna => 'lagna',
      ThaiMirrorLensSource.lagnaLord => 'lagna_lord',
      ThaiMirrorLensSource.myanmarSeven => 'myanmar_seven',
      ThaiMirrorLensSource.mahabhutaPosition => 'mahabhuta_position',
    };
  }

  String get labelTh {
    return switch (this) {
      ThaiMirrorLensSource.lagna => 'ลัคนา',
      ThaiMirrorLensSource.lagnaLord => 'เจ้าเรือนลัคนา',
      ThaiMirrorLensSource.myanmarSeven => 'เลข 7 ตัว (พม่า)',
      ThaiMirrorLensSource.mahabhutaPosition => 'มหาภูติ (ตำแหน่ง)',
    };
  }

  String get labelEn {
    return switch (this) {
      ThaiMirrorLensSource.lagna => 'Lagna',
      ThaiMirrorLensSource.lagnaLord => 'Lagna Lord',
      ThaiMirrorLensSource.myanmarSeven => 'Myanmar Seven',
      ThaiMirrorLensSource.mahabhutaPosition => 'Mahabhuta Position',
    };
  }

  static ThaiMirrorLensSource? fromContentType(ThaiContentType type) {
    return switch (type) {
      ThaiContentType.lagna => ThaiMirrorLensSource.lagna,
      ThaiContentType.lagnaLord => ThaiMirrorLensSource.lagnaLord,
      ThaiContentType.myanmarSeven => ThaiMirrorLensSource.myanmarSeven,
      ThaiContentType.mahabhutaPosition =>
        ThaiMirrorLensSource.mahabhutaPosition,
      ThaiContentType.ramahabhuta => null,
    };
  }
}
