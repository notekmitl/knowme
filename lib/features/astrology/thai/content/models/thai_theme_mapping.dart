import 'thai_content_defaults.dart';
import 'thai_fusion_theme_category.dart';

/// Maps Thai astrology content to a Fusion-ready human theme.
class ThaiThemeMapping {
  const ThaiThemeMapping({
    required this.category,
    required this.theme,
    this.weight = kDefaultThaiThemeMappingWeight,
  });

  final ThaiFusionThemeCategory category;
  final String theme;

  /// Relative influence for future theme aggregation (0.0–1.0).
  final double weight;

  factory ThaiThemeMapping.fromMap(Map<String, dynamic> map) {
    final categoryRaw = map['category'];
    ThaiFusionThemeCategory? category;

    if (categoryRaw is String) {
      category = parseThaiFusionThemeCategory(categoryRaw);
    } else if (categoryRaw is ThaiFusionThemeCategory) {
      category = categoryRaw;
    }

    if (category == null) {
      throw FormatException('Invalid theme mapping category: $categoryRaw');
    }

    final theme = map['theme'];
    if (theme is! String || theme.trim().isEmpty) {
      throw FormatException('Invalid theme mapping theme: $theme');
    }

    return ThaiThemeMapping(
      category: category,
      theme: theme.trim(),
      weight: _parseWeight(map['weight']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.id,
      'theme': theme,
      'weight': weight,
    };
  }

  static double _parseWeight(dynamic raw) {
    if (raw == null) return kDefaultThaiThemeMappingWeight;

    if (raw is num) {
      final value = raw.toDouble();
      if (value >= 0.0 && value <= 1.0) return value;
      throw FormatException('Invalid theme mapping weight: $raw');
    }

    if (raw is String) {
      final parsed = double.tryParse(raw.trim());
      if (parsed != null && parsed >= 0.0 && parsed <= 1.0) return parsed;
    }

    throw FormatException('Invalid theme mapping weight: $raw');
  }

  @override
  bool operator ==(Object other) {
    return other is ThaiThemeMapping &&
        other.category == category &&
        other.theme == theme &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(category, theme, weight);
}
