class PersonalityCoreResult {
  final double openness;
  final double conscientiousness;
  final double extraversion;
  final double agreeableness;
  final double neuroticism;

  PersonalityCoreResult({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  Map<String, dynamic> toMap() {
    return {
      "openness": openness,
      "conscientiousness": conscientiousness,
      "extraversion": extraversion,
      "agreeableness": agreeableness,
      "neuroticism": neuroticism,
      "completedAt": DateTime.now(),
    };
  }

  factory PersonalityCoreResult.fromMap(Map<String, dynamic> map) {
    return PersonalityCoreResult(
      openness: (map["openness"] ?? 0).toDouble(),
      conscientiousness: (map["conscientiousness"] ?? 0).toDouble(),
      extraversion: (map["extraversion"] ?? 0).toDouble(),
      agreeableness: (map["agreeableness"] ?? 0).toDouble(),
      neuroticism: (map["neuroticism"] ?? 0).toDouble(),
    );
  }
}
