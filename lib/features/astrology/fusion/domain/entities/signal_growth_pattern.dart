/// Growth depth pattern for a fusion signal type.
class SignalGrowthPattern {
  const SignalGrowthPattern({
    required this.growthPotential,
    required this.maturityPath,
    required this.developmentDirection,
  });

  final String growthPotential;
  final String maturityPath;
  final String developmentDirection;
}
