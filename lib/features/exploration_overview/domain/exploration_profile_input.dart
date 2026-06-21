/// Read-only profile facts for Exploration Overview — not a Firestore model.
class ExplorationProfileInput {
  const ExplorationProfileInput({
    this.hasName = false,
    this.hasBirthDate = false,
    this.hasBirthTime = false,
    this.hasBirthPlace = false,
    this.hasCoordinates = false,
  });

  final bool hasName;
  final bool hasBirthDate;
  final bool hasBirthTime;
  final bool hasBirthPlace;
  final bool hasCoordinates;

  static const empty = ExplorationProfileInput();

  static const basic = ExplorationProfileInput(hasName: true);

  static const birthComplete = ExplorationProfileInput(
    hasName: true,
    hasBirthDate: true,
    hasBirthTime: true,
    hasBirthPlace: true,
    hasCoordinates: true,
  );

  bool get isBirthProfileComplete =>
      hasBirthDate && hasBirthTime && hasBirthPlace && hasCoordinates;

  bool get hasAnyProfileData =>
      hasName ||
      hasBirthDate ||
      hasBirthTime ||
      hasBirthPlace ||
      hasCoordinates;
}
