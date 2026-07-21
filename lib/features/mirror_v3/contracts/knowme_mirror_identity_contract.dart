import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../constants/knowme_mirror_version_contract.dart';
import '../registry/knowme_mirror_registry_v0_1.dart';

/// Deterministic mirror identity formulas (MV0 frozen).
abstract final class KnowMeMirrorIdentityContract {
  static const mirrorScopeDelimiter = '|';
  static const mirrorScopeSuffix = 'mirror_scope';
  static const snapshotIdDelimiter = '|';

  static String mirrorScopeId({
    String? astrologyThemeSnapshotId,
    String? mbtiLensSnapshotId,
    String? bigFiveLensSnapshotId,
    String? eqLensSnapshotId,
  }) {
    final tuple = [
      astrologyThemeSnapshotId ?? 'null',
      mbtiLensSnapshotId ?? 'null',
      bigFiveLensSnapshotId ?? 'null',
      eqLensSnapshotId ?? 'null',
    ].join(mirrorScopeDelimiter);

    final digest = sha256.convert(utf8.encode(tuple)).toString();
    return '$digest$mirrorScopeDelimiter$mirrorScopeSuffix$mirrorScopeDelimiter${KnowMeMirrorVersionContract.mirrorDomainVersion}';
  }

  static String mirrorBundleId(String mirrorScopeId) {
    return '$mirrorScopeId$snapshotIdDelimiter${KnowMeMirrorVersionContract.mirrorDomainVersion}';
  }

  static String mirrorId({
    required String mirrorScopeId,
    required String mirrorKey,
    required List<String> themeIds,
  }) {
    if (!KnowMeMirrorRegistryV01.contains(mirrorKey)) {
      throw ArgumentError.value(mirrorKey, 'mirrorKey', 'Unknown registry key');
    }

    final canonicalThemeIds = {...themeIds}.toList()..sort();
    return [
      mirrorScopeId,
      mirrorKey,
      canonicalThemeIds.join(','),
      KnowMeMirrorVersionContract.mirrorDomainVersion,
    ].join(snapshotIdDelimiter);
  }

  static String canonicalThemeIds(List<String> themeIds) {
    final sorted = {...themeIds}.toList()..sort();
    return sorted.join(',');
  }
}
