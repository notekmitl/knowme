import '../../foundation/models/profile_warning.dart';
import 'thai_content_fragment.dart';

/// Bundle of presentation fragments from Content Lookup Layer.
class ThaiContentResolutionBundle {
  const ThaiContentResolutionBundle({
    required this.resolutionBundleId,
    required this.sourceInterpretationBundleId,
    required this.resolverVersion,
    required this.resolvedAt,
    required this.fragments,
    this.warnings = const [],
  });

  final String resolutionBundleId;
  final String sourceInterpretationBundleId;
  final String resolverVersion;
  final DateTime resolvedAt;
  final List<ThaiContentFragment> fragments;
  final List<ProfileWarning> warnings;

  factory ThaiContentResolutionBundle.fromMap(Map<String, dynamic> map) {
    final fragmentsRaw = map['fragments'];
    if (fragmentsRaw is! List) {
      throw FormatException('Invalid fragments: $fragmentsRaw');
    }

    final resolvedAtRaw = map['resolvedAt'] ?? map['resolved_at'];
    if (resolvedAtRaw is! String) {
      throw FormatException('Invalid resolvedAt: $resolvedAtRaw');
    }

    return ThaiContentResolutionBundle(
      resolutionBundleId: _requiredString(
        map['resolutionBundleId'] ?? map['resolution_bundle_id'],
      ),
      sourceInterpretationBundleId: _requiredString(
        map['sourceInterpretationBundleId'] ??
            map['source_interpretation_bundle_id'],
      ),
      resolverVersion: _requiredString(
        map['resolverVersion'] ?? map['resolver_version'],
      ),
      resolvedAt: DateTime.parse(resolvedAtRaw).toUtc(),
      fragments: List<ThaiContentFragment>.unmodifiable(
        fragmentsRaw
            .whereType<Map>()
            .map(
              (item) => ThaiContentFragment.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
      warnings: List<ProfileWarning>.unmodifiable(
        _warningsFromMapList(map['warnings']),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resolutionBundleId': resolutionBundleId,
      'sourceInterpretationBundleId': sourceInterpretationBundleId,
      'resolverVersion': resolverVersion,
      'resolvedAt': resolvedAt.toUtc().toIso8601String(),
      'fragments': fragments.map((fragment) => fragment.toMap()).toList(growable: false),
      'warnings': warnings
          .map(
            (warning) => {
              'code': warning.code,
              'severity': warning.severity.name,
              'message': warning.message,
              'affectedFields': warning.affectedFields,
            },
          )
          .toList(growable: false),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiContentResolutionBundle &&
        other.resolutionBundleId == resolutionBundleId &&
        other.sourceInterpretationBundleId == sourceInterpretationBundleId &&
        other.resolverVersion == resolverVersion &&
        other.resolvedAt == resolvedAt &&
        _fragmentListEquals(other.fragments, fragments) &&
        _warningListEquals(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        resolutionBundleId,
        sourceInterpretationBundleId,
        resolverVersion,
        resolvedAt,
        Object.hashAll(fragments),
        Object.hashAll(warnings),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static List<ProfileWarning> _warningsFromMapList(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) {
          final code = item['code'];
          final severityRaw = item['severity'];
          final message = item['message'];
          if (code is! String || message is! String) {
            throw FormatException('Invalid warning: $item');
          }

          final severity = ProfileWarningSeverity.values.firstWhere(
            (value) => value.name == severityRaw,
            orElse: () => throw FormatException('Invalid severity: $severityRaw'),
          );

          final affectedFields = item['affectedFields'];
          return ProfileWarning(
            code: code,
            severity: severity,
            message: message,
            affectedFields: affectedFields is List
                ? affectedFields.whereType<String>().toList(growable: false)
                : const [],
          );
        })
        .toList(growable: false);
  }

  static bool _fragmentListEquals(
    List<ThaiContentFragment> a,
    List<ThaiContentFragment> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _warningListEquals(
    List<ProfileWarning> a,
    List<ProfileWarning> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.code != right.code ||
          left.severity != right.severity ||
          left.message != right.message ||
          left.affectedFields.length != right.affectedFields.length) {
        return false;
      }
      for (var j = 0; j < left.affectedFields.length; j++) {
        if (left.affectedFields[j] != right.affectedFields[j]) {
          return false;
        }
      }
    }
    return true;
  }
}
