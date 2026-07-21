/// Slice kind for a [ThaiContentFragment].
enum ThaiContentFragmentKind {
  title,
  coreNature,
  summary,
  strength,
  challenge,
  growthPath,
}

extension ThaiContentFragmentKindLabels on ThaiContentFragmentKind {
  String get id {
    return switch (this) {
      ThaiContentFragmentKind.title => 'title',
      ThaiContentFragmentKind.coreNature => 'coreNature',
      ThaiContentFragmentKind.summary => 'summary',
      ThaiContentFragmentKind.strength => 'strength',
      ThaiContentFragmentKind.challenge => 'challenge',
      ThaiContentFragmentKind.growthPath => 'growthPath',
    };
  }
}

ThaiContentFragmentKind? parseThaiContentFragmentKind(String raw) {
  final normalized = raw.trim();
  for (final kind in ThaiContentFragmentKind.values) {
    if (kind.id == normalized) {
      return kind;
    }
  }
  return null;
}
