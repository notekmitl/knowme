import '../foundation/models/thai_birth_data.dart';
import 'thai_mirror_qa_profile.dart';

/// Curated QA dataset for Thai Mirror internal validation.
abstract final class ThaiMirrorQaProfiles {
  static const _bangkokOffset = Duration(hours: 7);
  static const _bangkokLat = 13.75;
  static const _bangkokLng = 100.50;

  static final List<ThaiMirrorQaProfile> all = [
    ThaiMirrorQaProfile(
      id: 'QA-01',
      label: 'ชาย · เช้า · มีเวลาเกิด',
      notes: 'Morning birth, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1985, 3, 15, 7, 30),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-02',
      label: 'หญิง · กลางวัน · มีเวลาเกิด',
      notes: 'Noon birth, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1992, 8, 20, 12, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-03',
      label: 'ชาย · เย็น · มีเวลาเกิด',
      notes: 'Evening birth, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1978, 11, 5, 18, 45),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-04',
      label: 'หญิง · ดึก · มีเวลาเกิด',
      notes: 'Late night birth, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2000, 1, 1, 23, 30),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-05',
      label: 'ชาย · ไม่มีเวลาเกิด',
      notes: 'Date only, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1965, 6, 10),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
        hasBirthTime: false,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-06',
      label: 'หญิง · ไม่มีเวลาเกิด',
      notes: 'Date only, Bangkok',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1988, 12, 25),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
        hasBirthTime: false,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-07',
      label: 'Golden · ดึก · มีเวลาเกิด',
      notes: 'Assembler golden case 1972-04-04 02:00',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1972, 4, 4, 2, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-08',
      label: 'ชาย · รุ่นเก่า · เช้า',
      notes: 'Birth year 1950',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1950, 2, 14, 6, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-09',
      label: 'หญิง · รุ่นใหม่ · บ่าย',
      notes: 'Birth year 2010',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2010, 7, 7, 15, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-10',
      label: 'ชาย · สาย · มีเวลาเกิด',
      notes: 'Late morning birth',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1995, 5, 5, 9, 15),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-11',
      label: 'หญิง · ค่ำ · มีเวลาเกิด',
      notes: 'Gen Z evening birth',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2005, 10, 10, 20, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-12',
      label: 'ชาย · รุ่งอรุณ · มีเวลาเกิด',
      notes: 'Dawn birth',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1970, 4, 1, 5, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-13',
      label: 'หญิง · บ่าย · เชียงใหม่',
      notes: 'Afternoon birth, Chiang Mai coords',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1982, 9, 9, 14, 30),
        timeZoneOffset: _bangkokOffset,
        latitude: 18.78,
        longitude: 98.98,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-14',
      label: 'ชาย · เที่ยงคืน · มีเวลาเกิด',
      notes: 'Just after midnight',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1999, 12, 31, 0, 15),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-15',
      label: 'หญิง · ไม่มีเวลาเกิด · รุ่นใหม่',
      notes: 'Young profile without birth time',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2015, 3, 3),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
        hasBirthTime: false,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-16',
      label: 'ชาย · ไม่มีเวลาเกิด · รุ่นเก่า',
      notes: 'Older profile without birth time',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1948, 8, 8),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
        hasBirthTime: false,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-17',
      label: 'หญิง · เช้า · ภูเก็ต',
      notes: 'Morning birth, Phuket coords',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1990, 4, 12, 8, 20),
        timeZoneOffset: _bangkokOffset,
        latitude: 7.88,
        longitude: 98.39,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-18',
      label: 'ชาย · ปีอธิกสุรทิน · กลางวัน',
      notes: 'Leap year 2000-02-29',
      birthData: ThaiBirthData(
        localDateTime: DateTime(2000, 2, 29, 11, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-19',
      label: 'หญิง · ฤดูหนาว · เย็น',
      notes: 'Winter solstice date',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1990, 12, 21, 16, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-20',
      label: 'ชาย · ฤดูร้อน · เช้า',
      notes: 'Summer solstice date',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1987, 6, 21, 6, 30),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-21',
      label: 'หญิง · ฤดูฝน · บ่าย',
      notes: 'Rainy season afternoon',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1975, 9, 15, 13, 0),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
    ThaiMirrorQaProfile(
      id: 'QA-22',
      label: 'ชาย · ค่ำมาก · มีเวลาเกิด',
      notes: 'Very late evening edge case',
      birthData: ThaiBirthData(
        localDateTime: DateTime(1983, 1, 27, 22, 55),
        timeZoneOffset: _bangkokOffset,
        latitude: _bangkokLat,
        longitude: _bangkokLng,
      ),
    ),
  ];

  static ThaiMirrorQaProfile get defaultProfile => all.first;

  static ThaiMirrorQaProfile byId(String id) {
    return all.firstWhere((profile) => profile.id == id);
  }

  static int nextIndex(int currentIndex) {
    if (all.isEmpty) return 0;
    return (currentIndex + 1) % all.length;
  }

  static int previousIndex(int currentIndex) {
    if (all.isEmpty) return 0;
    return (currentIndex - 1 + all.length) % all.length;
  }

  static int indexOfId(String id) {
    return all.indexWhere((profile) => profile.id == id);
  }
}
