/// Canon Ontology V3 — validation report types.
///
/// Deterministic issue/report value objects produced by
/// `CanonicalOntology.validate()`. Pure Dart; no Flutter/engine/runtime.
library;

enum OntologyIssueSeverity { error, warning }

class OntologyIssue {
  const OntologyIssue(this.severity, this.code, this.message, {this.ref});

  final OntologyIssueSeverity severity;
  final String code;
  final String message;
  final String? ref;

  bool get isError => severity == OntologyIssueSeverity.error;

  String get signature => '${severity.name}|$code|${ref ?? ''}|$message';

  @override
  String toString() =>
      '[${severity.name}] $code${ref == null ? '' : ' ($ref)'}: $message';
}

class OntologyValidationReport {
  const OntologyValidationReport(this.issues);

  /// Issues sorted deterministically by signature.
  final List<OntologyIssue> issues;

  bool get isValid => issues.where((i) => i.isError).isEmpty;

  List<OntologyIssue> get errors =>
      issues.where((i) => i.isError).toList(growable: false);

  List<OntologyIssue> get warnings => issues
      .where((i) => i.severity == OntologyIssueSeverity.warning)
      .toList(growable: false);

  bool hasCode(String code) => issues.any((i) => i.code == code);

  String get summary {
    final b = StringBuffer()
      ..writeln('Ontology Validation Report')
      ..writeln('errors: ${errors.length}  warnings: ${warnings.length}');
    for (final i in issues) {
      b.writeln('- $i');
    }
    return b.toString().trimRight();
  }
}
