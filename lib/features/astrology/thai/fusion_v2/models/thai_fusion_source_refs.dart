/// Cross-layer source references for [ThaiFusionInsight].
class ThaiFusionSourceRefs {
  ThaiFusionSourceRefs({
    this.dimensionIds = const [],
    this.themeIds = const [],
    this.factIds = const [],
  }) : assert(
          dimensionIds.isNotEmpty ||
              themeIds.isNotEmpty ||
              factIds.isNotEmpty,
          'sourceRefs must reference at least one id',
        );

  final List<String> dimensionIds;
  final List<String> themeIds;
  final List<String> factIds;

  factory ThaiFusionSourceRefs.fromMap(Map<String, dynamic> map) {
    return ThaiFusionSourceRefs(
      dimensionIds: _stringList(map['dimensionIds'] ?? map['dimension_ids']),
      themeIds: _stringList(map['themeIds'] ?? map['theme_ids']),
      factIds: _stringList(map['factIds'] ?? map['fact_ids']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dimensionIds': dimensionIds,
      'themeIds': themeIds,
      'factIds': factIds,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiFusionSourceRefs &&
        _listEquals(other.dimensionIds, dimensionIds) &&
        _listEquals(other.themeIds, themeIds) &&
        _listEquals(other.factIds, factIds);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(dimensionIds),
        Object.hashAll(themeIds),
        Object.hashAll(factIds),
      );

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().map((item) => item.trim()).toList();
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
