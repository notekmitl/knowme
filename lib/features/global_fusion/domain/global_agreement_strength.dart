/// Cross-mirror agreement strength tiers (GF-F1 — evidence-based only).
enum GlobalAgreementStrength {
  weak,
  medium,
  strong,
}

extension GlobalAgreementStrengthIds on GlobalAgreementStrength {
  String get id {
    return switch (this) {
      GlobalAgreementStrength.weak => 'weak',
      GlobalAgreementStrength.medium => 'medium',
      GlobalAgreementStrength.strong => 'strong',
    };
  }
}

abstract final class GlobalAgreementStrengthRules {
  static GlobalAgreementStrength forEvidenceCount(int count) {
    if (count >= 4) return GlobalAgreementStrength.strong;
    if (count >= 2) return GlobalAgreementStrength.medium;
    return GlobalAgreementStrength.weak;
  }
}
