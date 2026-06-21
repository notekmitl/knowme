import '../../foundation/models/profile_warning.dart';
import 'thai_signal.dart';

/// Deterministic bundle of structural [ThaiSignal] values.
class ThaiSignalBundle {
  const ThaiSignalBundle({
    required this.bundleId,
    required this.extractedAt,
    required this.extractorVersion,
    required this.hasBirthTime,
    required this.signals,
    this.warnings = const [],
  });

  final String bundleId;
  final DateTime extractedAt;
  final String extractorVersion;
  final bool hasBirthTime;
  final List<ThaiSignal> signals;
  final List<ProfileWarning> warnings;
}
