/// Structural source family for a [ThaiSignal].
enum ThaiSignalSource {
  sidereal,
  house,
  sevenNumbers,
  legacyV1,
}

extension ThaiSignalSourceLabels on ThaiSignalSource {
  String get id {
    return switch (this) {
      ThaiSignalSource.sidereal => 'sidereal',
      ThaiSignalSource.house => 'house',
      ThaiSignalSource.sevenNumbers => 'seven_numbers',
      ThaiSignalSource.legacyV1 => 'legacy_v1',
    };
  }
}
