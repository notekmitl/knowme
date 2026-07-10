import '../../foundation/models/thai_birth_data.dart';

/// One QA Harness profile: a stable id (A…H), a human label and the birth data
/// fed into the *production* pipeline.
class ThaiQaHarnessProfile {
  const ThaiQaHarnessProfile({
    required this.id,
    required this.label,
    required this.birthData,
  });

  final String id;
  final String label;
  final ThaiBirthData birthData;
}

/// The canonical A…H QA Harness dataset.
///
/// Birth dates are chosen to land on *distinct weekdays* so each profile starts
/// its Life Timeline on a different planet, and to span eras/ages so the current
/// life stage differs. These feed `ThaiMirrorPipeline.generate`, i.e. the exact
/// production path (foundation engine → assembler → narrative → life periods).
abstract final class ThaiQaHarnessProfiles {
  static const _tz = Duration(hours: 7);
  static const _bkkLat = 13.75;
  static const _bkkLng = 100.50;

  static final Map<String, ThaiQaHarnessProfile> _byId = {
    for (final p in all) p.id: p,
  };

  static final List<ThaiQaHarnessProfile> all = [
    ThaiQaHarnessProfile(
      id: 'A',
      label: 'เสาร์ · เช้า (Saturn start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1989, 4, 15, 7, 30), // Saturday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'B',
      label: 'อังคาร · บ่าย (Mars start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1995, 9, 26, 14, 10), // Tuesday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'C',
      label: 'ศุกร์ · เย็น (Venus start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1978, 11, 3, 18, 45), // Friday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'D',
      label: 'จันทร์ · กลางวัน (Moon start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2001, 7, 9, 12, 0), // Monday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'E',
      label: 'พุธ · สาย (Mercury start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1972, 4, 5, 9, 15), // Wednesday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'F',
      label: 'พฤหัส · ค่ำ (Jupiter start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1965, 6, 10, 20, 30), // Thursday
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'G',
      label: 'อาทิตย์ · เที่ยงคืน (Sun start)',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2010, 8, 8, 0, 20), // Sunday
        timeZoneOffset: _tz,
        latitude: 18.78, // Chiang Mai
        longitude: 98.98,
      ),
    ),
    ThaiQaHarnessProfile(
      id: 'H',
      label: 'เสาร์ · รุ่นเก่า · ไม่มีเวลาเกิด',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1948, 8, 14), // Saturday, no time
        timeZoneOffset: _tz,
        latitude: _bkkLat,
        longitude: _bkkLng,
        hasBirthTime: false,
      ),
    ),
  ];

  static ThaiQaHarnessProfile byId(String id) {
    return _byId[id.toUpperCase()] ?? all.first;
  }

  static List<String> get ids => all.map((p) => p.id).toList(growable: false);
}
