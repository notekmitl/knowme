class MbtiTypeProfile {
  final Map<String, String> name;
  final Map<String, String> nickname;

  final Map<String, String> description;
  final Map<String, String> strengths;
  final Map<String, String> weaknesses;

  final Map<String, String> careers;
  final Map<String, String> relationships;

  MbtiTypeProfile({
    required this.name,
    required this.nickname,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.careers,
    required this.relationships,
  });
}
