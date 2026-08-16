import '../../thai_mirror_stable_hash.dart';

/// Inputs for profile-unique consumer copy selection.
class ThaiMirrorContentContext {
  const ThaiMirrorContentContext({
    required this.allThemeIds,
    required this.topThemeIds,
    required this.profileSeed,
    this.lagnaKey,
    this.growthPathIds = const [],
  });

  final List<String> allThemeIds;
  final List<String> topThemeIds;
  final int profileSeed;
  final String? lagnaKey;
  final List<String> growthPathIds;

  List<String> get coreThemeIds => [
        ...topThemeIds,
        ...allThemeIds.where((id) => !topThemeIds.contains(id)),
      ];

  int seedFor({
    required String primaryThemeId,
    required String slot,
    String? partnerThemeId,
    int offset = 0,
  }) {
    var seed = profileSeed ^ (profileSeed * 31);
    seed ^= ThaiMirrorStableHash.string(primaryThemeId) ^
        ThaiMirrorStableHash.string(slot) ^ offset;
    if (partnerThemeId != null) {
      seed ^= ThaiMirrorStableHash.string(partnerThemeId) * 13;
    }
    if (lagnaKey != null && lagnaKey!.isNotEmpty) {
      seed ^= ThaiMirrorStableHash.string(lagnaKey!) * 7;
    }
    for (var i = 0; i < allThemeIds.length; i++) {
      seed ^= ThaiMirrorStableHash.string(allThemeIds[i]) * (i + 3);
    }
    return seed;
  }
}
