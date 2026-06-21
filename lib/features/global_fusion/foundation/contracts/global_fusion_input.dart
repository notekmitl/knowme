import 'package:knowme/features/mirror_v3/snapshot/models/knowme_mirror_snapshot.dart';

/// Well-known mirror role ids for current two-mirror setup.
abstract final class GlobalFusionMirrorRoles {
  static const astrology = 'astrology_mirror';
  static const personality = 'personality_mirror';
}

/// Single mirror snapshot contribution to global fusion input.
class GlobalFusionMirrorRef {
  const GlobalFusionMirrorRef({
    required this.mirrorRoleId,
    required this.snapshot,
  });

  final String mirrorRoleId;
  final KnowMeMirrorSnapshot snapshot;
}

/// GF2 input contract — N mirror snapshots, no direct lens reads.
class GlobalFusionInput {
  const GlobalFusionInput({
    required this.mirrors,
  });

  final List<GlobalFusionMirrorRef> mirrors;

  int get mirrorCount => mirrors.length;

  GlobalFusionMirrorRef? mirrorByRole(String mirrorRoleId) {
    for (final mirror in mirrors) {
      if (mirror.mirrorRoleId == mirrorRoleId) return mirror;
    }
    return null;
  }

  List<String> get mirrorRoleIds {
    return mirrors.map((mirror) => mirror.mirrorRoleId).toList()..sort();
  }

  List<String> get sourceMirrorSnapshotIds {
    return mirrors.map((mirror) => mirror.snapshot.snapshotId).toList()..sort();
  }
}
