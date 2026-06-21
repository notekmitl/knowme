import 'home_section.dart';

/// A named group of related Home sections (HC-F1).
class HomeSectionGroup {
  const HomeSectionGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });

  final HomeSectionGroupId id;
  final String title;
  final String description;
  final List<HomeSection> sections;
}
