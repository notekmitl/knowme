/// EQ mini-test identifiers (one module per type).
enum EqTestType {
  awareness,
  regulation,
  empathy,
  social,
  decision,
  stress;

  String get testId => switch (this) {
        EqTestType.awareness => 'eq_awareness',
        EqTestType.regulation => 'eq_regulation',
        EqTestType.empathy => 'eq_empathy',
        EqTestType.social => 'eq_social',
        EqTestType.decision => 'eq_decision',
        EqTestType.stress => 'eq_stress',
      };
}
