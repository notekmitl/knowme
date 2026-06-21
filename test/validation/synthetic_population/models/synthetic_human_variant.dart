/// Variant axis for synthetic population diversity (A–D per archetype).
enum SyntheticHumanVariant {
  a('A'),
  b('B'),
  c('C'),
  d('D');

  const SyntheticHumanVariant(this.label);
  final String label;

  static SyntheticHumanVariant fromLabel(String label) {
    return values.firstWhere(
      (item) => item.label.toUpperCase() == label.toUpperCase(),
      orElse: () => a,
    );
  }
}
