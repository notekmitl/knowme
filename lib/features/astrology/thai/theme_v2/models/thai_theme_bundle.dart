import '../../foundation/models/profile_warning.dart';
import 'thai_theme_score.dart';

/// Bundle of aggregated theme scores from Theme Layer V2.
class ThaiThemeBundle {
  const ThaiThemeBundle({
    required this.bundleId,
    required this.sourceInterpretationBundleId,
    required this.generatedAt,
    required this.themes,
    this.warnings = const [],
  });

  final String bundleId;
  final String sourceInterpretationBundleId;
  final DateTime generatedAt;
  final List<ThaiThemeScore> themes;
  final List<ProfileWarning> warnings;

  factory ThaiThemeBundle.fromMap(Map<String, dynamic> map) {
    final themesRaw = map['themes'];
    if (themesRaw is! List) {
      throw FormatException('Invalid themes: $themesRaw');
    }

    final generatedAtRaw = map['generatedAt'] ?? map['generated_at'];
    if (generatedAtRaw is! String) {
      throw FormatException('Invalid generatedAt: $generatedAtRaw');
    }

    return ThaiThemeBundle(
      bundleId: _requiredString(map['bundleId'] ?? map['bundle_id']),
      sourceInterpretationBundleId: _requiredString(
        map['sourceInterpretationBundleId'] ??
            map['source_interpretation_bundle_id'],
      ),
      generatedAt: DateTime.parse(generatedAtRaw).toUtc(),
      themes: List<ThaiThemeScore>.unmodifiable(
        themesRaw
            .whereType<Map>()
            .map(
              (item) => ThaiThemeScore.fromMap(
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
      'bundleId': bundleId,
      'sourceInterpretationBundleId': sourceInterpretationBundleId,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'themes': themes.map((theme) => theme.toMap()).toList(growable: false),
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
    return other is ThaiThemeBundle &&
        other.bundleId == bundleId &&
        other.sourceInterpretationBundleId == sourceInterpretationBundleId &&
        other.generatedAt == generatedAt &&
        _themeListEquals(other.themes, themes) &&
        _warningListEquals(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        bundleId,
        sourceInterpretationBundleId,
        generatedAt,
        Object.hashAll(themes),
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

  static bool _themeListEquals(List<ThaiThemeScore> a, List<ThaiThemeScore> b) {
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
