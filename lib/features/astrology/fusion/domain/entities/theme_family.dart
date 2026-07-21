/// Cross-theme semantic families for agreement/tension logic (later sprints).
enum ThemeFamily {
  autonomy,
  structure,
  adaptation,
  reflection,
  connection,
  expression,
}

extension ThemeFamilyIds on ThemeFamily {
  String get id {
    return switch (this) {
      ThemeFamily.autonomy => 'autonomy',
      ThemeFamily.structure => 'structure',
      ThemeFamily.adaptation => 'adaptation',
      ThemeFamily.reflection => 'reflection',
      ThemeFamily.connection => 'connection',
      ThemeFamily.expression => 'expression',
    };
  }
}
