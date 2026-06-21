/// Progressive depth tiers for Big Five (10 → 44 → 80).
enum BigFiveDepthTier {
  quick,
  standard,
  deep;

  String get storageKey => switch (this) {
        BigFiveDepthTier.quick => 'quick',
        BigFiveDepthTier.standard => 'standard',
        BigFiveDepthTier.deep => 'deep',
      };

  static BigFiveDepthTier? fromStorageKey(String? raw) => switch (raw) {
        'quick' => BigFiveDepthTier.quick,
        'standard' => BigFiveDepthTier.standard,
        'deep' => BigFiveDepthTier.deep,
        _ => null,
      };

  static BigFiveDepthTier forScoredQuestionCount(int count) {
    if (count >= bigFiveDeepCheckpoint) return BigFiveDepthTier.deep;
    if (count >= bigFiveStandardCheckpoint) {
      return BigFiveDepthTier.standard;
    }
    return BigFiveDepthTier.quick;
  }
}

/// Progressive checkpoint boundaries (question counts, inclusive).
const int bigFiveQuickCheckpoint = 10;
const int bigFiveStandardCheckpoint = 44;
const int bigFiveDeepCheckpoint = 80;

/// Legacy IPIP bank size — product ceiling remains [bigFiveDeepCheckpoint].
const int bigFiveLegacyBankMax = 120;
