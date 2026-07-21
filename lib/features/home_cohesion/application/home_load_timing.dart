/// Lightweight timing helper for Home load performance measurement.
class HomeLoadTiming {
  HomeLoadTiming() : startedAt = DateTime.now();

  final DateTime startedAt;
  int? shellMs;
  int? narrativeMs;
  int? enrichMs;
  int? totalMs;

  void markShell() => shellMs ??= _elapsed();
  void markNarrative() => narrativeMs ??= _elapsed();
  void markEnrich() => enrichMs ??= _elapsed();
  void markTotal() => totalMs ??= _elapsed();

  int _elapsed() => DateTime.now().difference(startedAt).inMilliseconds;

  Map<String, int?> toMap() => {
        'shellMs': shellMs,
        'narrativeMs': narrativeMs,
        'enrichMs': enrichMs,
        'totalMs': totalMs,
      };
}
