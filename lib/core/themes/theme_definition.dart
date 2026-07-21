import 'theme_category.dart';

/// Canonical theme entry for cross-lens Mirror and Fusion layers.
class ThemeDefinition {
  const ThemeDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  /// Stable snake_case identifier (e.g. `independent`).
  final String id;

  /// Short canonical label (e.g. `Independent`).
  final String name;

  final ThemeCategory category;

  /// Neutral human-meaning description for synthesis layers.
  final String description;

  factory ThemeDefinition.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    if (id is! String || id.trim().isEmpty) {
      throw FormatException('Invalid theme id: $id');
    }

    final name = map['name'];
    if (name is! String || name.trim().isEmpty) {
      throw FormatException('Invalid theme name: $name');
    }

    final categoryRaw = map['category'];
    ThemeCategory? category;
    if (categoryRaw is String) {
      category = parseThemeCategory(categoryRaw);
    } else if (categoryRaw is ThemeCategory) {
      category = categoryRaw;
    }
    if (category == null) {
      throw FormatException('Invalid theme category: $categoryRaw');
    }

    final description = map['description'];
    if (description is! String || description.trim().isEmpty) {
      throw FormatException('Invalid theme description: $description');
    }

    return ThemeDefinition(
      id: id.trim().toLowerCase(),
      name: name.trim(),
      category: category,
      description: description.trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.id,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
