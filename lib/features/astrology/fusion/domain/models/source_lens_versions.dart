/// Source lens version fingerprints used to detect stale fusion snapshots.
class SourceLensVersions {
  const SourceLensVersions({
    this.westernVersion,
    this.baziVersion,
    this.thaiVersion,
  });

  final String? westernVersion;
  final String? baziVersion;
  final String? thaiVersion;

  bool get hasAny =>
      westernVersion != null || baziVersion != null || thaiVersion != null;

  bool requiresRegeneration(SourceLensVersions current) {
    return _lensChanged(westernVersion, current.westernVersion) ||
        _lensChanged(baziVersion, current.baziVersion) ||
        _lensChanged(thaiVersion, current.thaiVersion);
  }

  static bool _lensChanged(String? saved, String? current) {
    if (current == null) return false;
    if (saved == null) return true;
    return saved != current;
  }

  Map<String, dynamic> toMap() {
    return {
      if (westernVersion != null) 'westernVersion': westernVersion,
      if (baziVersion != null) 'baziVersion': baziVersion,
      if (thaiVersion != null) 'thaiVersion': thaiVersion,
    };
  }

  factory SourceLensVersions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const SourceLensVersions();

    return SourceLensVersions(
      westernVersion: map['westernVersion'] as String?,
      baziVersion: map['baziVersion'] as String?,
      thaiVersion: map['thaiVersion'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SourceLensVersions &&
        other.westernVersion == westernVersion &&
        other.baziVersion == baziVersion &&
        other.thaiVersion == thaiVersion;
  }

  @override
  int get hashCode => Object.hash(westernVersion, baziVersion, thaiVersion);
}
