/// Deterministic invited-beta allow-list (uid-based).
///
/// Production source of truth is Firestore `invited_beta_testers/{uid}`
/// (see `firestore.rules` + [FirebaseThaiInvitedBetaTesterAccess]).
/// This in-memory set remains for unit/widget tests and local injection only.
abstract final class ThaiBetaInvitedTesterRegistry {
  static final Set<String> invitedUserIds = <String>{};

  /// Returns true only when [userId] is non-null and on the allow-list.
  static bool isInvited(String? userId) =>
      userId != null && invitedUserIds.contains(userId);

  static void invite(String userId) => invitedUserIds.add(userId);

  static void revoke(String userId) => invitedUserIds.remove(userId);

  static void reset() => invitedUserIds.clear();
}
