import '../../theme/models/thai_theme_confidence_level.dart';
import '../../theme_v2/enums/thai_theme_category.dart';

/// Theme-signal trace for a [ThaiMirrorDimension].
///
/// Structural only — no content text or upstream layer fields.
class ThaiMirrorEvidence {
  ThaiMirrorEvidence({
    required this.themeId,
    required this.category,
    required this.score,
    required this.rank,
    required this.confidence,
    required this.distinctSourceFactCount,
  }) : assert(
          distinctSourceFactCount > 0,
          'distinctSourceFactCount must be positive',
        );

  final String themeId;
  final ThaiThemeCategory category;
  final double score;
  final int rank;
  final ThaiThemeConfidenceLevel confidence;
  final int distinctSourceFactCount;

  factory ThaiMirrorEvidence.fromMap(Map<String, dynamic> map) {
    final categoryRaw = map['category'];
    ThaiThemeCategory? category;
    if (categoryRaw is ThaiThemeCategory) {
      category = categoryRaw;
    } else if (categoryRaw is String) {
      category = parseThaiThemeCategory(categoryRaw);
    }
    if (category == null) {
      throw FormatException('Invalid category: $categoryRaw');
    }

    final confidenceRaw = map['confidence'];
    ThaiThemeConfidenceLevel? confidence;
    if (confidenceRaw is ThaiThemeConfidenceLevel) {
      confidence = confidenceRaw;
    } else if (confidenceRaw is String) {
      confidence = _parseThemeConfidence(confidenceRaw);
    }
    if (confidence == null) {
      throw FormatException('Invalid confidence: $confidenceRaw');
    }

    final score = map['score'];
    if (score is! num) {
      throw FormatException('Invalid score: $score');
    }

    final rank = map['rank'];
    if (rank is! int) {
      if (rank is! num) {
        throw FormatException('Invalid rank: $rank');
      }
    }

    final distinctSourceFactCount = map['distinctSourceFactCount'] ??
        map['distinct_source_fact_count'];
    if (distinctSourceFactCount is! int) {
      if (distinctSourceFactCount is num) {
        // allow num for map round-trip flexibility
      } else {
        throw FormatException(
          'Invalid distinctSourceFactCount: $distinctSourceFactCount',
        );
      }
    }

    return ThaiMirrorEvidence(
      themeId: _requiredString(map['themeId'] ?? map['theme_id']),
      category: category,
      score: score.toDouble(),
      rank: rank is int ? rank : (rank as num).toInt(),
      confidence: confidence,
      distinctSourceFactCount: distinctSourceFactCount is int
          ? distinctSourceFactCount
          : (distinctSourceFactCount as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeId': themeId,
      'category': category.id,
      'score': score,
      'rank': rank,
      'confidence': confidence.id,
      'distinctSourceFactCount': distinctSourceFactCount,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiMirrorEvidence &&
        other.themeId == themeId &&
        other.category == category &&
        other.score == score &&
        other.rank == rank &&
        other.confidence == confidence &&
        other.distinctSourceFactCount == distinctSourceFactCount;
  }

  @override
  int get hashCode => Object.hash(
        themeId,
        category,
        score,
        rank,
        confidence,
        distinctSourceFactCount,
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static ThaiThemeConfidenceLevel? _parseThemeConfidence(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final level in ThaiThemeConfidenceLevel.values) {
      if (level.id == normalized) {
        return level;
      }
    }
    return null;
  }
}
