import '../../foundation/models/profile_warning.dart';
import 'thai_mirror_dimension.dart';
import 'thai_mirror_insight.dart';

/// Structural self-understanding snapshot from Thai Mirror V2.
///
/// Aggregation of theme signals only — no narrative or content text.
class ThaiMirrorSnapshot {
  const ThaiMirrorSnapshot({
    required this.snapshotId,
    required this.sourceThemeBundleId,
    required this.mirrorVersion,
    required this.generatedAt,
    required this.dimensions,
    required this.insights,
    this.warnings = const [],
  });

  final String snapshotId;
  final String sourceThemeBundleId;
  final String mirrorVersion;
  final DateTime generatedAt;
  final List<ThaiMirrorDimension> dimensions;
  final List<ThaiMirrorInsight> insights;
  final List<ProfileWarning> warnings;

  factory ThaiMirrorSnapshot.fromMap(Map<String, dynamic> map) {
    final generatedAtRaw = map['generatedAt'] ?? map['generated_at'];
    if (generatedAtRaw is! String) {
      throw FormatException('Invalid generatedAt: $generatedAtRaw');
    }

    final dimensionsRaw = map['dimensions'];
    if (dimensionsRaw is! List) {
      throw FormatException('Invalid dimensions: $dimensionsRaw');
    }

    final insightsRaw = map['insights'];
    if (insightsRaw is! List) {
      throw FormatException('Invalid insights: $insightsRaw');
    }

    return ThaiMirrorSnapshot(
      snapshotId: _requiredString(map['snapshotId'] ?? map['snapshot_id']),
      sourceThemeBundleId: _requiredString(
        map['sourceThemeBundleId'] ?? map['source_theme_bundle_id'],
      ),
      mirrorVersion: _requiredString(
        map['mirrorVersion'] ?? map['mirror_version'],
      ),
      generatedAt: DateTime.parse(generatedAtRaw).toUtc(),
      dimensions: List<ThaiMirrorDimension>.unmodifiable(
        dimensionsRaw
            .whereType<Map>()
            .map(
              (item) => ThaiMirrorDimension.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
      insights: List<ThaiMirrorInsight>.unmodifiable(
        insightsRaw
            .whereType<Map>()
            .map(
              (item) => ThaiMirrorInsight.fromMap(
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
      'snapshotId': snapshotId,
      'sourceThemeBundleId': sourceThemeBundleId,
      'mirrorVersion': mirrorVersion,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'dimensions': dimensions.map((item) => item.toMap()).toList(growable: false),
      'insights': insights.map((item) => item.toMap()).toList(growable: false),
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
    return other is ThaiMirrorSnapshot &&
        other.snapshotId == snapshotId &&
        other.sourceThemeBundleId == sourceThemeBundleId &&
        other.mirrorVersion == mirrorVersion &&
        other.generatedAt == generatedAt &&
        _dimensionListEquals(other.dimensions, dimensions) &&
        _insightListEquals(other.insights, insights) &&
        _warningListEquals(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        snapshotId,
        sourceThemeBundleId,
        mirrorVersion,
        generatedAt,
        Object.hashAll(dimensions),
        Object.hashAll(insights),
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

  static bool _dimensionListEquals(
    List<ThaiMirrorDimension> a,
    List<ThaiMirrorDimension> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _insightListEquals(
    List<ThaiMirrorInsight> a,
    List<ThaiMirrorInsight> b,
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
