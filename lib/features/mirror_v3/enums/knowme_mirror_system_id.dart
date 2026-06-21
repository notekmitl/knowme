/// Originating system for mirror evidence.
enum KnowMeMirrorSystemId {
  thaiAstrology,
  mbti,
  bigFive,
  eq,
  knowMeMirror,
}

extension KnowMeMirrorSystemIdLabels on KnowMeMirrorSystemId {
  String get id {
    return switch (this) {
      KnowMeMirrorSystemId.thaiAstrology => 'thai_astrology',
      KnowMeMirrorSystemId.mbti => 'mbti',
      KnowMeMirrorSystemId.bigFive => 'big_five',
      KnowMeMirrorSystemId.eq => 'eq',
      KnowMeMirrorSystemId.knowMeMirror => 'knowme_mirror',
    };
  }
}

KnowMeMirrorSystemId? parseKnowMeMirrorSystemId(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final systemId in KnowMeMirrorSystemId.values) {
    if (systemId.id == normalized) {
      return systemId;
    }
  }
  return null;
}
