class ProfileModel {
  final String name;
  final String gender;

  final String birthDate;
  final String birthTime;

  final String birthPlace;

  final double latitude;
  final double longitude;

  final String timezone;

  const ProfileModel({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map["name"] ?? "",
      gender: map["gender"] ?? "",

      birthDate: map["birthDate"] ?? "",
      birthTime: map["birthTime"] ?? "",

      birthPlace: map["birthPlace"] ?? "",

      latitude: (map["latitude"] ?? 0).toDouble(),
      longitude: (map["longitude"] ?? 0).toDouble(),

      timezone: map["timezone"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "gender": gender,

      "birthDate": birthDate,
      "birthTime": birthTime,

      "birthPlace": birthPlace,

      "latitude": latitude,
      "longitude": longitude,

      "timezone": timezone,
    };
  }
}
