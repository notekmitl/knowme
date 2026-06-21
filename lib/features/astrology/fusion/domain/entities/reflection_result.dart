/// Template-based human reflection (deterministic — no AI).
class ReflectionResult {
  const ReflectionResult({
    required this.summary,
    required this.keyInsights,
  });

  final String summary;
  final List<String> keyInsights;
}
