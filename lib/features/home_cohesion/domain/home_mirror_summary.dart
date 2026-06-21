/// Read-only summary for one mirror on Home (HC-F0).
class HomeMirrorEntrySummary {
  const HomeMirrorEntrySummary({
    required this.available,
    required this.ready,
    required this.reflectionCount,
  });

  final bool available;
  final bool ready;
  final int reflectionCount;

  static const empty = HomeMirrorEntrySummary(
    available: false,
    ready: false,
    reflectionCount: 0,
  );
}

/// Astrology + Personality mirror summaries for Home (HC-F0).
class HomeMirrorSummary {
  const HomeMirrorSummary({
    required this.astrology,
    required this.personality,
  });

  final HomeMirrorEntrySummary astrology;
  final HomeMirrorEntrySummary personality;

  static const empty = HomeMirrorSummary(
    astrology: HomeMirrorEntrySummary.empty,
    personality: HomeMirrorEntrySummary.empty,
  );
}
