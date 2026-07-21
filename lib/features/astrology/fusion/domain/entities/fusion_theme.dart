import 'fusion_category.dart';
import 'theme_family.dart';

/// Canonical astrology fusion theme entry.
class FusionTheme {
  const FusionTheme({
    required this.id,
    required this.name,
    required this.category,
    required this.family,
    required this.description,
  });

  final String id;
  final String name;
  final FusionCategory category;
  final ThemeFamily family;
  final String description;

  @override
  bool operator ==(Object other) {
    return other is FusionTheme && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
