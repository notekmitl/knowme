/// Deterministic invited-beta allow-list (uid-based).
///
/// Production Firestore-backed registry is future wiring. Until then, ops can
/// seed uids at startup or via test injection. Revoke by removing uid.
abstract final class ThaiBetaInvitedTesterRegistry {
  static final Set<String> invitedUserIds = <String>{};

  /// Returns true only when [userId] is non-null and on the allow-list.
  static bool isInvited(String? userId) =>
      userId != null && invitedUserIds.contains(userId);

  static void invite(String userId) => invitedUserIds.add(userId);

  static void revoke(String userId) => invitedUserIds.remove(userId);

  static void reset() => invitedUserIds.clear();
}
