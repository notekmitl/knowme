import '../models/thai_content_section.dart';

/// Reserved for non-authored placeholder sections.
/// Lagna, Lagna Lord, and Ramahabhuta live in dedicated content libraries.
abstract final class ThaiPlaceholderContent {
  static List<ThaiContentSection> all() => const [];
}
