import '../constants/knowme_mirror_version_contract.dart';
import '../registry/knowme_mirror_registry_v0_1.dart';

/// Frozen registry contract rules.
abstract final class KnowMeMirrorRegistryContract {
  static const registryVersion = KnowMeMirrorVersionContract.registryVersion;
  static const mirrorKeyPrefix = 'MIRROR_';
  static const frozenKeyCount = 15;

  static bool isValidMirrorKey(String mirrorKey) =>
      KnowMeMirrorRegistryV01.contains(mirrorKey);
}
