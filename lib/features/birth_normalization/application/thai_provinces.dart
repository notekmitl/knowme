/// Canonical table of all 77 Thai provinces (76 provinces + Bangkok).
///
/// Single source of truth for Thai province → coordinates resolution. Birth
/// Normalization ([BirthLocationResolver]) and any UI province picker derive
/// from this list, so the set of selectable provinces and the set of resolvable
/// provinces can never drift apart.
///
/// - [key] is the lowercase English romanization used as the resolver lookup key
///   (matches `RawBirthInput.province` after lower-casing).
/// - [nameTh] is the Thai display name.
/// - [latitude]/[longitude] are the provincial capital (อำเภอเมือง) coordinates,
///   WGS84.
/// - [timeZoneId] is `Asia/Bangkok` for every Thai province (ICT, UTC+7).
/// - [source] documents provenance.
class ThaiProvince {
  const ThaiProvince({
    required this.key,
    required this.nameTh,
    required this.latitude,
    required this.longitude,
    this.timeZoneId = thaiTimeZoneId,
    this.source = defaultSource,
  });

  final String key;
  final String nameTh;
  final double latitude;
  final double longitude;
  final String timeZoneId;
  final String source;

  /// Every Thai province uses Indochina Time (UTC+7).
  static const String thaiTimeZoneId = 'Asia/Bangkok';

  static const String defaultSource =
      'Provincial capital (อำเภอเมือง) coordinates, WGS84 — Wikipedia/GeoNames';
}

/// All 77 provinces, ordered by English key (Bangkok first).
const List<ThaiProvince> kThaiProvincesAll = [
  ThaiProvince(key: 'bangkok', nameTh: 'กรุงเทพมหานคร', latitude: 13.7563, longitude: 100.5018),
  ThaiProvince(key: 'amnat charoen', nameTh: 'อำนาจเจริญ', latitude: 15.8657, longitude: 104.6256),
  ThaiProvince(key: 'ang thong', nameTh: 'อ่างทอง', latitude: 14.5896, longitude: 100.4550),
  ThaiProvince(key: 'bueng kan', nameTh: 'บึงกาฬ', latitude: 18.3609, longitude: 103.6466),
  ThaiProvince(key: 'buriram', nameTh: 'บุรีรัมย์', latitude: 14.9930, longitude: 103.1029),
  ThaiProvince(key: 'chachoengsao', nameTh: 'ฉะเชิงเทรา', latitude: 13.6904, longitude: 101.0779),
  ThaiProvince(key: 'chai nat', nameTh: 'ชัยนาท', latitude: 15.1851, longitude: 100.1251),
  ThaiProvince(key: 'chaiyaphum', nameTh: 'ชัยภูมิ', latitude: 15.8068, longitude: 102.0317),
  ThaiProvince(key: 'chanthaburi', nameTh: 'จันทบุรี', latitude: 12.6113, longitude: 102.1039),
  ThaiProvince(key: 'chiang mai', nameTh: 'เชียงใหม่', latitude: 18.7883, longitude: 98.9853),
  ThaiProvince(key: 'chiang rai', nameTh: 'เชียงราย', latitude: 19.9105, longitude: 99.8406),
  ThaiProvince(key: 'chonburi', nameTh: 'ชลบุรี', latitude: 13.3611, longitude: 100.9847),
  ThaiProvince(key: 'chumphon', nameTh: 'ชุมพร', latitude: 10.4930, longitude: 99.1800),
  ThaiProvince(key: 'kalasin', nameTh: 'กาฬสินธุ์', latitude: 16.4314, longitude: 103.5060),
  ThaiProvince(key: 'kamphaeng phet', nameTh: 'กำแพงเพชร', latitude: 16.4827, longitude: 99.5226),
  ThaiProvince(key: 'kanchanaburi', nameTh: 'กาญจนบุรี', latitude: 14.0227, longitude: 99.5328),
  ThaiProvince(key: 'khon kaen', nameTh: 'ขอนแก่น', latitude: 16.4419, longitude: 102.8360),
  ThaiProvince(key: 'krabi', nameTh: 'กระบี่', latitude: 8.0863, longitude: 98.9063),
  ThaiProvince(key: 'lampang', nameTh: 'ลำปาง', latitude: 18.2888, longitude: 99.4909),
  ThaiProvince(key: 'lamphun', nameTh: 'ลำพูน', latitude: 18.5746, longitude: 99.0087),
  ThaiProvince(key: 'loei', nameTh: 'เลย', latitude: 17.4860, longitude: 101.7223),
  ThaiProvince(key: 'lopburi', nameTh: 'ลพบุรี', latitude: 14.7995, longitude: 100.6534),
  ThaiProvince(key: 'mae hong son', nameTh: 'แม่ฮ่องสอน', latitude: 19.3020, longitude: 97.9654),
  ThaiProvince(key: 'maha sarakham', nameTh: 'มหาสารคาม', latitude: 16.1850, longitude: 103.3007),
  ThaiProvince(key: 'mukdahan', nameTh: 'มุกดาหาร', latitude: 16.5453, longitude: 104.7235),
  ThaiProvince(key: 'nakhon nayok', nameTh: 'นครนายก', latitude: 14.2069, longitude: 101.2130),
  ThaiProvince(key: 'nakhon pathom', nameTh: 'นครปฐม', latitude: 13.8196, longitude: 100.0644),
  ThaiProvince(key: 'nakhon phanom', nameTh: 'นครพนม', latitude: 17.3920, longitude: 104.7690),
  ThaiProvince(key: 'nakhon ratchasima', nameTh: 'นครราชสีมา', latitude: 14.9799, longitude: 102.0978),
  ThaiProvince(key: 'nakhon sawan', nameTh: 'นครสวรรค์', latitude: 15.7047, longitude: 100.1372),
  ThaiProvince(key: 'nakhon si thammarat', nameTh: 'นครศรีธรรมราช', latitude: 8.4304, longitude: 99.9631),
  ThaiProvince(key: 'nan', nameTh: 'น่าน', latitude: 18.7756, longitude: 100.7730),
  ThaiProvince(key: 'narathiwat', nameTh: 'นราธิวาส', latitude: 6.4254, longitude: 101.8253),
  ThaiProvince(key: 'nong bua lamphu', nameTh: 'หนองบัวลำภู', latitude: 17.2041, longitude: 102.4260),
  ThaiProvince(key: 'nong khai', nameTh: 'หนองคาย', latitude: 17.8783, longitude: 102.7420),
  ThaiProvince(key: 'nonthaburi', nameTh: 'นนทบุรี', latitude: 13.8591, longitude: 100.5217),
  ThaiProvince(key: 'pathum thani', nameTh: 'ปทุมธานี', latitude: 14.0208, longitude: 100.5250),
  ThaiProvince(key: 'pattani', nameTh: 'ปัตตานี', latitude: 6.8692, longitude: 101.2503),
  ThaiProvince(key: 'phangnga', nameTh: 'พังงา', latitude: 8.4509, longitude: 98.5253),
  ThaiProvince(key: 'phatthalung', nameTh: 'พัทลุง', latitude: 7.6167, longitude: 100.0742),
  ThaiProvince(key: 'phayao', nameTh: 'พะเยา', latitude: 19.1664, longitude: 99.9003),
  ThaiProvince(key: 'phetchabun', nameTh: 'เพชรบูรณ์', latitude: 16.4190, longitude: 101.1591),
  ThaiProvince(key: 'phetchaburi', nameTh: 'เพชรบุรี', latitude: 13.1119, longitude: 99.9399),
  ThaiProvince(key: 'phichit', nameTh: 'พิจิตร', latitude: 16.4429, longitude: 100.3487),
  ThaiProvince(key: 'phitsanulok', nameTh: 'พิษณุโลก', latitude: 16.8211, longitude: 100.2659),
  ThaiProvince(key: 'phra nakhon si ayutthaya', nameTh: 'พระนครศรีอยุธยา', latitude: 14.3692, longitude: 100.5876),
  ThaiProvince(key: 'phrae', nameTh: 'แพร่', latitude: 18.1445, longitude: 100.1405),
  ThaiProvince(key: 'phuket', nameTh: 'ภูเก็ต', latitude: 7.8804, longitude: 98.3923),
  ThaiProvince(key: 'prachinburi', nameTh: 'ปราจีนบุรี', latitude: 14.0509, longitude: 101.3700),
  ThaiProvince(key: 'prachuap khiri khan', nameTh: 'ประจวบคีรีขันธ์', latitude: 11.8126, longitude: 99.7973),
  ThaiProvince(key: 'ranong', nameTh: 'ระนอง', latitude: 9.9529, longitude: 98.6085),
  ThaiProvince(key: 'ratchaburi', nameTh: 'ราชบุรี', latitude: 13.5283, longitude: 99.8134),
  ThaiProvince(key: 'rayong', nameTh: 'ระยอง', latitude: 12.6814, longitude: 101.2780),
  ThaiProvince(key: 'roi et', nameTh: 'ร้อยเอ็ด', latitude: 16.0538, longitude: 103.6520),
  ThaiProvince(key: 'sa kaeo', nameTh: 'สระแก้ว', latitude: 13.8240, longitude: 102.0645),
  ThaiProvince(key: 'sakon nakhon', nameTh: 'สกลนคร', latitude: 17.1545, longitude: 104.1348),
  ThaiProvince(key: 'samut prakan', nameTh: 'สมุทรปราการ', latitude: 13.5991, longitude: 100.5998),
  ThaiProvince(key: 'samut sakhon', nameTh: 'สมุทรสาคร', latitude: 13.5475, longitude: 100.2745),
  ThaiProvince(key: 'samut songkhram', nameTh: 'สมุทรสงคราม', latitude: 13.4098, longitude: 100.0021),
  ThaiProvince(key: 'saraburi', nameTh: 'สระบุรี', latitude: 14.5289, longitude: 100.9108),
  ThaiProvince(key: 'satun', nameTh: 'สตูล', latitude: 6.6238, longitude: 100.0673),
  ThaiProvince(key: 'sing buri', nameTh: 'สิงห์บุรี', latitude: 14.8907, longitude: 100.3967),
  ThaiProvince(key: 'sisaket', nameTh: 'ศรีสะเกษ', latitude: 15.1186, longitude: 104.3220),
  ThaiProvince(key: 'songkhla', nameTh: 'สงขลา', latitude: 7.1898, longitude: 100.5951),
  ThaiProvince(key: 'sukhothai', nameTh: 'สุโขทัย', latitude: 17.0078, longitude: 99.8237),
  ThaiProvince(key: 'suphan buri', nameTh: 'สุพรรณบุรี', latitude: 14.4745, longitude: 100.1217),
  ThaiProvince(key: 'surat thani', nameTh: 'สุราษฎร์ธานี', latitude: 9.1382, longitude: 99.3215),
  ThaiProvince(key: 'surin', nameTh: 'สุรินทร์', latitude: 14.8818, longitude: 103.4960),
  ThaiProvince(key: 'tak', nameTh: 'ตาก', latitude: 16.8839, longitude: 99.1258),
  ThaiProvince(key: 'trang', nameTh: 'ตรัง', latitude: 7.5563, longitude: 99.6114),
  ThaiProvince(key: 'trat', nameTh: 'ตราด', latitude: 12.2436, longitude: 102.5150),
  ThaiProvince(key: 'ubon ratchathani', nameTh: 'อุบลราชธานี', latitude: 15.2448, longitude: 104.8473),
  ThaiProvince(key: 'udon thani', nameTh: 'อุดรธานี', latitude: 17.4138, longitude: 102.7870),
  ThaiProvince(key: 'uthai thani', nameTh: 'อุทัยธานี', latitude: 15.3794, longitude: 100.0246),
  ThaiProvince(key: 'uttaradit', nameTh: 'อุตรดิตถ์', latitude: 17.6200, longitude: 100.0993),
  ThaiProvince(key: 'yala', nameTh: 'ยะลา', latitude: 6.5410, longitude: 101.2800),
  ThaiProvince(key: 'yasothon', nameTh: 'ยโสธร', latitude: 15.7928, longitude: 104.1450),
];

/// Common English aliases that should also resolve to a province's coordinates.
const Map<String, String> kThaiProvinceAliases = {
  'krung thep': 'bangkok',
  'krung thep maha nakhon': 'bangkok',
  'ayutthaya': 'phra nakhon si ayutthaya',
  'korat': 'nakhon ratchasima',
  'hat yai': 'songkhla',
};
