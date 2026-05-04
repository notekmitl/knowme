class UserProfile {
  final String uid;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String timezone;

  UserProfile({
    required this.uid,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "gender": gender,
      "birthDate": birthDate.toIso8601String(),
      "birthTime": birthTime,
      "birthPlace": birthPlace,
      "latitude": latitude,
      "longitude": longitude,
      "timezone": timezone,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      name: map['name'],
      gender: map['gender'],
      birthDate: DateTime.parse(map['birthDate']),
      birthTime: map['birthTime'],
      birthPlace: map['birthPlace'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timezone: map['timezone'],
    );
  }
}
