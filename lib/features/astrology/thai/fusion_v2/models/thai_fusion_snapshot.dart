import '../../foundation/models/profile_warning.dart';
import 'thai_fusion_agreement.dart';
import 'thai_fusion_category_activation.dart';
import 'thai_fusion_confidence.dart';
import 'thai_fusion_coverage.dart';
import 'thai_fusion_insight.dart';
import 'thai_fusion_tension.dart';

/// Root synthesis output from Thai Fusion V2.
///
/// Cross-layer structural synthesis only — no narrative or content text.
class ThaiFusionSnapshot {
  const ThaiFusionSnapshot({
    required this.fusionSnapshotId,
    required this.sourceMirrorSnapshotId,
    required this.sourceThemeBundleId,
    required this.sourceInterpretationBundleId,
    required this.fusionVersion,
    required this.generatedAt,
    required this.categories,
    required this.insights,
    required this.agreements,
    required this.tensions,
    required this.confidence,
    required this.coverage,
    this.warnings = const [],
  });

  final String fusionSnapshotId;
  final String sourceMirrorSnapshotId;
  final String sourceThemeBundleId;
  final String sourceInterpretationBundleId;
  final String fusionVersion;
  final DateTime generatedAt;
  final List<ThaiFusionCategoryActivation> categories;
  final List<ThaiFusionInsight> insights;
  final List<ThaiFusionAgreement> agreements;
  final List<ThaiFusionTension> tensions;
  final ThaiFusionConfidence confidence;
  final ThaiFusionCoverage coverage;
  final List<ProfileWarning> warnings;

  factory ThaiFusionSnapshot.fromMap(Map<String, dynamic> map) {
    final generatedAtRaw = map['generatedAt'] ?? map['generated_at'];
    if (generatedAtRaw is! String) {
      throw FormatException('Invalid generatedAt: $generatedAtRaw');
    }

    final confidenceRaw = map['confidence'];
    if (confidenceRaw is! Map) {
      throw FormatException('Invalid confidence: $confidenceRaw');
    }

    final coverageRaw = map['coverage'];
    if (coverageRaw is! Map) {
      throw FormatException('Invalid coverage: $coverageRaw');
    }

    return ThaiFusionSnapshot(
      fusionSnapshotId: _requiredString(
        map['fusionSnapshotId'] ?? map['fusion_snapshot_id'],
      ),
      sourceMirrorSnapshotId: _requiredString(
        map['sourceMirrorSnapshotId'] ?? map['source_mirror_snapshot_id'],
      ),
      sourceThemeBundleId: _requiredString(
        map['sourceThemeBundleId'] ?? map['source_theme_bundle_id'],
      ),
      sourceInterpretationBundleId: _requiredString(
        map['sourceInterpretationBundleId'] ??
            map['source_interpretation_bundle_id'],
      ),
      fusionVersion: _requiredString(
        map['fusionVersion'] ?? map['fusion_version'],
      ),
      generatedAt: DateTime.parse(generatedAtRaw).toUtc(),
      categories: _categoryList(map['categories']),
      insights: _insightList(map['insights']),
      agreements: _agreementList(map['agreements']),
      tensions: _tensionList(map['tensions']),
      confidence: ThaiFusionConfidence.fromMap(
        Map<String, dynamic>.from(confidenceRaw),
      ),
      coverage: ThaiFusionCoverage.fromMap(
        Map<String, dynamic>.from(coverageRaw),
      ),
      warnings: List<ProfileWarning>.unmodifiable(
        _warningsFromMapList(map['warnings']),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fusionSnapshotId': fusionSnapshotId,
      'sourceMirrorSnapshotId': sourceMirrorSnapshotId,
      'sourceThemeBundleId': sourceThemeBundleId,
      'sourceInterpretationBundleId': sourceInterpretationBundleId,
      'fusionVersion': fusionVersion,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'categories': categories.map((item) => item.toMap()).toList(growable: false),
      'insights': insights.map((item) => item.toMap()).toList(growable: false),
      'agreements': agreements.map((item) => item.toMap()).toList(growable: false),
      'tensions': tensions.map((item) => item.toMap()).toList(growable: false),
      'confidence': confidence.toMap(),
      'coverage': coverage.toMap(),
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
    return other is ThaiFusionSnapshot &&
        other.fusionSnapshotId == fusionSnapshotId &&
        other.sourceMirrorSnapshotId == sourceMirrorSnapshotId &&
        other.sourceThemeBundleId == sourceThemeBundleId &&
        other.sourceInterpretationBundleId == sourceInterpretationBundleId &&
        other.fusionVersion == fusionVersion &&
        other.generatedAt == generatedAt &&
        other.confidence == confidence &&
        other.coverage == coverage &&
        _categoryListEquals(other.categories, categories) &&
        _insightListEquals(other.insights, insights) &&
        _agreementListEquals(other.agreements, agreements) &&
        _tensionListEquals(other.tensions, tensions) &&
        _warningListEquals(other.warnings, warnings);
  }

  @override
  int get hashCode => Object.hash(
        fusionSnapshotId,
        sourceMirrorSnapshotId,
        sourceThemeBundleId,
        sourceInterpretationBundleId,
        fusionVersion,
        generatedAt,
        confidence,
        coverage,
        Object.hashAll(categories),
        Object.hashAll(insights),
        Object.hashAll(agreements),
        Object.hashAll(tensions),
        Object.hashAll(warnings),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static List<ThaiFusionCategoryActivation> _categoryList(dynamic raw) {
    if (raw is! List) {
      throw FormatException('Invalid categories: $raw');
    }
    return List<ThaiFusionCategoryActivation>.unmodifiable(
      raw
          .whereType<Map>()
          .map(
            (item) => ThaiFusionCategoryActivation.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }

  static List<ThaiFusionInsight> _insightList(dynamic raw) {
    if (raw is! List) {
      throw FormatException('Invalid insights: $raw');
    }
    return List<ThaiFusionInsight>.unmodifiable(
      raw
          .whereType<Map>()
          .map(
            (item) => ThaiFusionInsight.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }

  static List<ThaiFusionAgreement> _agreementList(dynamic raw) {
    if (raw is! List) return const [];
    return List<ThaiFusionAgreement>.unmodifiable(
      raw
          .whereType<Map>()
          .map(
            (item) => ThaiFusionAgreement.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }

  static List<ThaiFusionTension> _tensionList(dynamic raw) {
    if (raw is! List) return const [];
    return List<ThaiFusionTension>.unmodifiable(
      raw
          .whereType<Map>()
          .map(
            (item) => ThaiFusionTension.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
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

  static bool _categoryListEquals(
    List<ThaiFusionCategoryActivation> a,
    List<ThaiFusionCategoryActivation> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _insightListEquals(
    List<ThaiFusionInsight> a,
    List<ThaiFusionInsight> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _agreementListEquals(
    List<ThaiFusionAgreement> a,
    List<ThaiFusionAgreement> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _tensionListEquals(
    List<ThaiFusionTension> a,
    List<ThaiFusionTension> b,
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
