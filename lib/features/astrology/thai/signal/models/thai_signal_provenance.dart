/// Engine trace for a [ThaiSignal].
class ThaiSignalProvenance {
  const ThaiSignalProvenance({
    required this.engineVersion,
    required this.extractorVersion,
    required this.enginePath,
    required this.requiresBirthTime,
  });

  final String engineVersion;
  final String extractorVersion;
  final List<String> enginePath;
  final bool requiresBirthTime;
}
