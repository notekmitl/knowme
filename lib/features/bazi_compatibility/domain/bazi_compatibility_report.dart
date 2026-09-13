class BaziCompatibilityReportRow {
  const BaziCompatibilityReportRow({required this.label, required this.value});

  final String label;
  final String value;
}

class BaziCompatibilityReportSection {
  const BaziCompatibilityReportSection({
    required this.title,
    this.intro,
    this.rows = const [],
    this.notes = const [],
  });

  final String title;
  final String? intro;
  final List<BaziCompatibilityReportRow> rows;
  final List<String> notes;
}

class BaziCompatibilityReport {
  const BaziCompatibilityReport({
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final List<BaziCompatibilityReportSection> sections;

  String get plainText {
    final buffer = StringBuffer()
      ..writeln(title)
      ..writeln(subtitle);
    for (final section in sections) {
      buffer.writeln(section.title);
      if (section.intro case final intro?) buffer.writeln(intro);
      for (final row in section.rows) {
        buffer.writeln('${row.label}: ${row.value}');
      }
      for (final note in section.notes) {
        buffer.writeln(note);
      }
    }
    return buffer.toString().trim();
  }
}
