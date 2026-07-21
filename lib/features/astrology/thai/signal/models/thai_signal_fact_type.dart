/// Structural fact type for a [ThaiSignal].
enum ThaiSignalFactType {
  lagnaSign,
  lagnaLord,
  houseSign,
  houseLord,
  myanmarPosition,
  mahabhutaPosition,
}

extension ThaiSignalFactTypeLabels on ThaiSignalFactType {
  String get id {
    return switch (this) {
      ThaiSignalFactType.lagnaSign => 'lagna_sign',
      ThaiSignalFactType.lagnaLord => 'lagna_lord',
      ThaiSignalFactType.houseSign => 'house_sign',
      ThaiSignalFactType.houseLord => 'house_lord',
      ThaiSignalFactType.myanmarPosition => 'myanmar_position',
      ThaiSignalFactType.mahabhutaPosition => 'mahabhuta_position',
    };
  }
}
