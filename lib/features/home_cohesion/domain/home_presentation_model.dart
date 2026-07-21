import 'home_section.dart';
import 'home_section_group.dart';

/// Presentation structure for Home — IA without UI (HC-F1).
class HomePresentationModel {
  const HomePresentationModel({
    required this.version,
    required this.groups,
    required this.sections,
  });

  static const String versionId = 'home_presentation.v1';

  final String version;
  final List<HomeSectionGroup> groups;
  final List<HomeSection> sections;

  HomeSectionGroup group(HomeSectionGroupId id) {
    return groups.firstWhere((entry) => entry.id == id);
  }

  HomeSection section(String sectionId) {
    return sections.firstWhere((entry) => entry.id == sectionId);
  }
}
