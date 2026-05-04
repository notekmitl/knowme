class MbtiType {
  final String type;

  final Map<String, String> title;

  final Map<String, String> description;

  final List<Map<String, String>> strengths;

  final List<Map<String, String>> weaknesses;

  final List<Map<String, String>> careers;

  final List<Map<String, String>> relationships;

  const MbtiType({
    required this.type,
    required this.title,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.careers,
    required this.relationships,
  });
}
