class PersonalityQuestion {
  final String id;
  final String text;
  final String trait;
  final bool reverseScored;

  const PersonalityQuestion({
    required this.id,
    required this.text,
    required this.trait,
    this.reverseScored = false,
  });
}
