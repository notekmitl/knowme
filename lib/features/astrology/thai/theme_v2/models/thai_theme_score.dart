import '../../theme/models/thai_theme_confidence_level.dart';
import '../enums/thai_theme_category.dart';
import 'thai_theme_contribution.dart';

/// Aggregated theme score from Theme Layer V2.
///
/// Aggregation only — no text, title, or narrative fields.
class ThaiThemeScore {
  ThaiThemeScore({
    required this.themeId,
    required this.category,
    required this.score,
    required this.confidence,
    required this.rank,
    required this.contributions,
  }) : assert(
          contributions.isNotEmpty,
          'contributions must not be empty',
        );

  final String themeId;
  final ThaiThemeCategory category;
  final double score;
  final ThaiThemeConfidenceLevel confidence;
  final int rank;
  final List<ThaiThemeContribution> contributions;

  factory ThaiThemeScore.fromMap(Map<String, dynamic> map) {
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
      confidence = _parseConfidenceLevel(confidenceRaw);
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
      if (rank is num) {
        // allow num for map round-trip flexibility
      } else {
        throw FormatException('Invalid rank: $rank');
      }
    }

    final contributionsRaw = map['contributions'];
    if (contributionsRaw is! List) {
      throw FormatException('Invalid contributions: $contributionsRaw');
    }

    return ThaiThemeScore(
      themeId: _requiredString(map['themeId'] ?? map['theme_id']),
      category: category,
      score: score.toDouble(),
      confidence: confidence,
      rank: rank is int ? rank : (rank as num).toInt(),
      contributions: List<ThaiThemeContribution>.unmodifiable(
        contributionsRaw
            .whereType<Map>()
            .map(
              (item) => ThaiThemeContribution.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeId': themeId,
      'category': category.id,
      'score': score,
      'confidence': confidence.id,
      'rank': rank,
      'contributions': contributions.map((item) => item.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeScore &&
        other.themeId == themeId &&
        other.category == category &&
        other.score == score &&
        other.confidence == confidence &&
        other.rank == rank &&
        _contributionListEquals(other.contributions, contributions);
  }

  @override
  int get hashCode => Object.hash(
        themeId,
        category,
        score,
        confidence,
        rank,
        Object.hashAll(contributions),
      );

  static String _requiredString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid string field: $raw');
    }
    return raw.trim();
  }

  static ThaiThemeConfidenceLevel? _parseConfidenceLevel(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final level in ThaiThemeConfidenceLevel.values) {
      if (level.id == normalized) {
        return level;
      }
    }
    return null;
  }

  static bool _contributionListEquals(
    List<ThaiThemeContribution> a,
    List<ThaiThemeContribution> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
