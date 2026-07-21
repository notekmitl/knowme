/// Raw user input collected by the Thai Astrology Beta form.
///
/// This is a plain data object. It is converted to `RawBirthInput` (Birth
/// Normalization) by the analysis runner — the beta never builds another
/// astrology pipeline. [gender] is collected for research only; it is not used
/// by normalization or the engine.
class ThaiBetaInput {
  const ThaiBetaInput({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.birthHour,
    this.birthMinute = 0,
    this.birthTimeUnknown = false,
    this.province,
    this.provinceKey,
    this.gender,
  });

  final String firstName;
  final String lastName;

  /// Date-only (year/month/day).
  final DateTime birthDate;

  /// 0–23, or null when unknown.
  final int? birthHour;
  final int birthMinute;

  /// True when the user ticked "I don't know my birth time".
  final bool birthTimeUnknown;

  /// Thai display label for the province (e.g. `เชียงใหม่`).
  final String? province;

  /// Resolver key for the province (e.g. `chiang mai`), used by Birth
  /// Normalization's location table.
  final String? provinceKey;

  final String? gender;

  bool get hasBirthTime => !birthTimeUnknown && birthHour != null;

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate':
          '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
      'birthHour': hasBirthTime ? birthHour : null,
      'birthMinute': hasBirthTime ? birthMinute : null,
      'birthTimeUnknown': birthTimeUnknown,
      'province': province,
      'provinceKey': provinceKey,
      'gender': gender,
    };
  }

  factory ThaiBetaInput.fromMap(Map<String, dynamic> map) {
    final rawDate = (map['birthDate'] ?? '').toString();
    final parts = rawDate.split('-');
    final date = parts.length == 3
        ? DateTime(
            int.tryParse(parts[0]) ?? 1900,
            int.tryParse(parts[1]) ?? 1,
            int.tryParse(parts[2]) ?? 1,
          )
        : DateTime(1900);
    return ThaiBetaInput(
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      birthDate: date,
      birthHour: (map['birthHour'] as num?)?.toInt(),
      birthMinute: (map['birthMinute'] as num?)?.toInt() ?? 0,
      birthTimeUnknown: map['birthTimeUnknown'] == true,
      province: map['province']?.toString(),
      provinceKey: map['provinceKey']?.toString(),
      gender: map['gender']?.toString(),
    );
  }
}
