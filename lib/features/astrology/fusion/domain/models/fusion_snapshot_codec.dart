import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/fusion_agreement.dart';
import '../entities/fusion_category.dart';
import '../entities/fusion_insight.dart';
import '../entities/fusion_signal.dart';
import '../entities/fusion_support_level.dart';
import '../entities/fusion_tension.dart';
import '../entities/future_tendency.dart';
import '../entities/growth_opportunity.dart';
import '../entities/reflection_result.dart';
import '../entities/theme_family.dart';
import 'astrology_fusion_snapshot.dart';
import 'source_lens_versions.dart';

/// Firestore serialization for [AstrologyFusionSnapshot].
abstract final class FusionSnapshotCodec {
  static Map<String, dynamic> toMap(AstrologyFusionSnapshot snapshot) {
    return {
      'version': snapshot.version,
      'generatedAt': Timestamp.fromDate(snapshot.generatedAt.toUtc()),
      'signals': snapshot.signals.map(_signalToMap).toList(),
      'agreements': snapshot.agreements.map(_agreementToMap).toList(),
      'tensions': snapshot.tensions.map(_tensionToMap).toList(),
      'reflection': _reflectionToMap(snapshot.reflection),
      'fusionInsight': _fusionInsightToMap(snapshot.fusionInsight),
      'growthOpportunities':
          snapshot.growthOpportunities.map(_growthOpportunityToMap).toList(),
      'futureTendencies':
          snapshot.futureTendencies.map(_futureTendencyToMap).toList(),
      'sourceLensVersions': snapshot.sourceLensVersions.toMap(),
    };
  }

  static AstrologyFusionSnapshot fromMap(Map<String, dynamic> map) {
    return AstrologyFusionSnapshot(
      version: map['version'] as String? ?? '',
      generatedAt: _readDate(map['generatedAt']),
      signals: _readList(map['signals'], _signalFromMap),
      agreements: _readList(map['agreements'], _agreementFromMap),
      tensions: _readList(map['tensions'], _tensionFromMap),
      reflection: _reflectionFromMap(
        Map<String, dynamic>.from(map['reflection'] as Map? ?? {}),
      ),
      fusionInsight: _fusionInsightFromMap(
        Map<String, dynamic>.from(map['fusionInsight'] as Map? ?? {}),
      ),
      growthOpportunities:
          _readList(map['growthOpportunities'], _growthOpportunityFromMap),
      futureTendencies:
          _readList(map['futureTendencies'], _futureTendencyFromMap),
      sourceLensVersions: SourceLensVersions.fromMap(
        Map<String, dynamic>.from(map['sourceLensVersions'] as Map? ?? {}),
      ),
    );
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static List<T> _readList<T>(
    dynamic raw,
    T Function(Map<String, dynamic> map) parse,
  ) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Map<String, dynamic> _signalToMap(FusionSignal signal) {
    return {
      'type': signal.type.name,
      'sourceThemes': signal.sourceThemes,
      'supportingLenses': signal.supportingLenses,
      'supportLevel': signal.supportLevel.name,
    };
  }

  static FusionSignal _signalFromMap(Map<String, dynamic> map) {
    return FusionSignal(
      type: FusionSignalType.values.byName(map['type'] as String),
      sourceThemes: _readStringList(map['sourceThemes']),
      supportingLenses: _readStringList(map['supportingLenses']),
      supportLevel: FusionSupportLevel.values.byName(
        map['supportLevel'] as String,
      ),
    );
  }

  static Map<String, dynamic> _agreementToMap(FusionAgreement agreement) {
    return {
      'sourceThemeIds': agreement.sourceThemeIds,
      'supportingLenses': agreement.supportingLenses,
      'supportLevel': agreement.supportLevel.name,
      if (agreement.family != null) 'family': agreement.family!.id,
      'familyLevel': agreement.familyLevel,
    };
  }

  static FusionAgreement _agreementFromMap(Map<String, dynamic> map) {
    return FusionAgreement(
      sourceThemeIds: _readStringList(map['sourceThemeIds']),
      supportingLenses: _readStringList(map['supportingLenses']),
      supportLevel: FusionSupportLevel.values.byName(
        map['supportLevel'] as String,
      ),
      family: _themeFamilyFromId(map['family'] as String?),
      familyLevel: map['familyLevel'] == true,
    );
  }

  static Map<String, dynamic> _tensionToMap(FusionTension tension) {
    return {
      'category': tension.category.id,
      'perspectives': tension.perspectives
          .map(
            (perspective) => {
              'lensId': perspective.lensId,
              'themeId': perspective.themeId,
            },
          )
          .toList(),
    };
  }

  static FusionTension _tensionFromMap(Map<String, dynamic> map) {
    final perspectives = _readList(
      map['perspectives'],
      (item) => FusionTensionPerspective(
        lensId: item['lensId'] as String,
        themeId: item['themeId'] as String,
      ),
    );

    return FusionTension(
      category: _fusionCategoryFromId(map['category'] as String) ??
          FusionCategory.coreSelf,
      perspectives: perspectives,
    );
  }

  static Map<String, dynamic> _reflectionToMap(ReflectionResult reflection) {
    return {
      'summary': reflection.summary,
      'keyInsights': reflection.keyInsights,
    };
  }

  static ReflectionResult _reflectionFromMap(Map<String, dynamic> map) {
    return ReflectionResult(
      summary: map['summary'] as String? ?? '',
      keyInsights: _readStringList(map['keyInsights']),
    );
  }

  static Map<String, dynamic> _fusionInsightToMap(
    FusionInsightResult insight,
  ) {
    return {
      if (insight.primary != null) 'primary': _insightToMap(insight.primary!),
      if (insight.secondary != null)
        'secondary': _insightToMap(insight.secondary!),
    };
  }

  static FusionInsightResult _fusionInsightFromMap(Map<String, dynamic> map) {
    return FusionInsightResult(
      primary: _insightFromMap(map['primary'] as Map<String, dynamic>?),
      secondary: _insightFromMap(map['secondary'] as Map<String, dynamic>?),
    );
  }

  static Map<String, dynamic> _insightToMap(FusionInsight insight) {
    return {
      'title': insight.title,
      'description': insight.description,
    };
  }

  static FusionInsight? _insightFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return FusionInsight(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _growthOpportunityToMap(
    GrowthOpportunity opportunity,
  ) {
    return {
      'title': opportunity.title,
      'description': opportunity.description,
    };
  }

  static GrowthOpportunity _growthOpportunityFromMap(
    Map<String, dynamic> map,
  ) {
    return GrowthOpportunity(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _futureTendencyToMap(FutureTendency tendency) {
    return {
      'title': tendency.title,
      'description': tendency.description,
    };
  }

  static FutureTendency _futureTendencyFromMap(Map<String, dynamic> map) {
    return FutureTendency(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  static List<String> _readStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<String>().toList();
  }

  static ThemeFamily? _themeFamilyFromId(String? id) {
    if (id == null) return null;
    for (final family in ThemeFamily.values) {
      if (family.id == id) return family;
    }
    return null;
  }

  static FusionCategory? _fusionCategoryFromId(String? id) {
    if (id == null) return null;
    for (final category in FusionCategory.values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
