/// Warning emitted when birth data is incomplete or calculation is partial.
class ProfileWarning {
  const ProfileWarning({
    required this.code,
    required this.severity,
    required this.message,
    this.affectedFields = const [],
  });

  final String code;
  final ProfileWarningSeverity severity;
  final String message;
  final List<String> affectedFields;
}

enum ProfileWarningSeverity {
  low,
  medium,
  high,
}
