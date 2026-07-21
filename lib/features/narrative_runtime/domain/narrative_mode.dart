/// Production narrative modes — one section per mode in [NarrativeResult].
enum NarrativeMode {
  identity,
  relationship,
  decision,
  growth,
}

extension NarrativeModeLabels on NarrativeMode {
  String get key {
    return switch (this) {
      NarrativeMode.identity => 'identity',
      NarrativeMode.relationship => 'relationship',
      NarrativeMode.decision => 'decision',
      NarrativeMode.growth => 'growth',
    };
  }

  String get sectionTitle {
    return switch (this) {
      NarrativeMode.identity => 'ตัวตนของคุณ',
      NarrativeMode.relationship => 'ความสัมพันธ์',
      NarrativeMode.decision => 'การตัดสินใจ',
      NarrativeMode.growth => 'การเติบโต',
    };
  }

  static NarrativeMode? parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final mode in NarrativeMode.values) {
      if (mode.key == normalized) return mode;
    }
    return null;
  }
}
