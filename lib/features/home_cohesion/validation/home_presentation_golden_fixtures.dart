import '../application/home_presentation_builder.dart';
import '../domain/home_presentation_model.dart';
import '../domain/home_section.dart';
import '../domain/home_snapshot.dart';
import 'home_cohesion_golden_fixtures.dart';
import 'home_cohesion_golden_scenario.dart';
import 'home_presentation_golden_scenario.dart';

/// Golden fixtures for Home Presentation IA (HC-F1).
abstract final class HomePresentationGoldenFixtures {
  static HomePresentationModel build(HomePresentationGoldenScenario scenario) {
    final snapshot = _snapshotFor(scenario);
    return HomePresentationBuilder.build(snapshot);
  }

  static HomeCohesionGoldenScenario _cohesionScenario(
    HomePresentationGoldenScenario scenario,
  ) {
    return switch (scenario) {
      HomePresentationGoldenScenario.emptyHome =>
        HomeCohesionGoldenScenario.emptyUser,
      HomePresentationGoldenScenario.overviewOnly =>
        HomeCohesionGoldenScenario.overviewOnly,
      HomePresentationGoldenScenario.discoveryOnly =>
        HomeCohesionGoldenScenario.discoveryOnly,
      HomePresentationGoldenScenario.fusionReady =>
        HomeCohesionGoldenScenario.fusionReady,
      HomePresentationGoldenScenario.everythingReady =>
        HomeCohesionGoldenScenario.everythingReady,
    };
  }

  static HomeSnapshot _snapshotFor(HomePresentationGoldenScenario scenario) {
    return HomeCohesionGoldenFixtures.build(_cohesionScenario(scenario));
  }
}

/// Expected invariants per Home IA golden scenario.
abstract final class HomePresentationGoldenExpectations {
  static List<String> verify(
    HomePresentationGoldenScenario scenario,
    HomePresentationModel model,
  ) {
    final issues = <String>[];

    if (model.version != HomePresentationModel.versionId) {
      issues.add('expected version ${HomePresentationModel.versionId}');
    }

    if (model.groups.length != HomeSectionGroupOrder.ids.length) {
      issues.add('expected ${HomeSectionGroupOrder.ids.length} groups');
    }

    for (var i = 0; i < HomeSectionGroupOrder.ids.length; i++) {
      if (i >= model.groups.length) break;
      if (model.groups[i].id != HomeSectionGroupOrder.ids[i]) {
        issues.add(
          'group order mismatch at $i: expected '
          '${HomeSectionGroupOrder.ids[i]} got ${model.groups[i].id}',
        );
      }
    }

    if (model.sections.length != 10) {
      issues.add('expected 10 sections got ${model.sections.length}');
    }

    _expectGroupContainsType(
      model,
      HomeSectionGroupId.yourJourney,
      HomeSectionType.overview,
      count: 1,
      issues: issues,
    );
    _expectGroupContainsType(
      model,
      HomeSectionGroupId.yourReflections,
      HomeSectionType.mirror,
      count: 2,
      issues: issues,
    );
    _expectGroupContainsType(
      model,
      HomeSectionGroupId.yourReflections,
      HomeSectionType.fusion,
      count: 1,
      issues: issues,
    );
    _expectGroupContainsType(
      model,
      HomeSectionGroupId.exploreMore,
      HomeSectionType.discovery,
      count: 6,
      issues: issues,
    );

    _assertNoRecommendationCopy(model, issues);

    switch (scenario) {
      case HomePresentationGoldenScenario.emptyHome:
        _expectVisibleCount(
          model,
          count: 0,
          issues: issues,
          groupId: HomeSectionGroupId.yourReflections,
        );
        _expectVisibleCount(
          model,
          greaterThan: 0,
          issues: issues,
          groupId: HomeSectionGroupId.exploreMore,
        );
      case HomePresentationGoldenScenario.overviewOnly:
        _expectSectionVisible(model, HomeSectionIds.overview, true, issues);
        _expectVisibleCount(
          model,
          count: 0,
          issues: issues,
          groupId: HomeSectionGroupId.yourReflections,
        );
      case HomePresentationGoldenScenario.discoveryOnly:
        _expectVisibleCount(model, greaterThan: 2, issues: issues, groupId: HomeSectionGroupId.exploreMore);
        _expectSectionVisible(model, HomeSectionIds.globalFusion, false, issues);
      case HomePresentationGoldenScenario.fusionReady:
        _expectSectionVisible(model, HomeSectionIds.globalFusion, true, issues);
        _expectSection(model, HomeSectionIds.globalFusion, HomeSectionType.fusion, issues);
      case HomePresentationGoldenScenario.everythingReady:
        _expectSectionVisible(model, HomeSectionIds.astrologyMirror, true, issues);
        _expectSectionVisible(model, HomeSectionIds.personalityMirror, true, issues);
        _expectSectionVisible(model, HomeSectionIds.globalFusion, true, issues);
        _expectVisibleCount(model, greaterThan: 5, issues: issues);
    }

    return issues;
  }

  static void _assertNoRecommendationCopy(
    HomePresentationModel model,
    List<String> issues,
  ) {
    for (final group in model.groups) {
      for (final phrase in const ['คุณควร', 'แนะนำให้', 'Next Best Action']) {
        if (group.title.contains(phrase) ||
            group.description.contains(phrase)) {
          issues.add('forbidden recommendation copy in group ${group.id}');
        }
      }
    }
    for (final section in model.sections) {
      for (final phrase in const ['คุณควร', 'แนะนำให้', 'Next Best Action']) {
        if (section.title.contains(phrase) ||
            section.description.contains(phrase)) {
          issues.add('forbidden recommendation copy in ${section.id}');
        }
      }
    }
  }

  static void _expectGroupContainsType(
    HomePresentationModel model,
    HomeSectionGroupId groupId,
    HomeSectionType type, {
    required int count,
    required List<String> issues,
  }) {
    final group = model.group(groupId);
    final actual = group.sections.where((section) => section.type == type).length;
    if (actual != count) {
      issues.add('group $groupId expected $count $type sections got $actual');
    }
  }

  static void _expectSection(
    HomePresentationModel model,
    String sectionId,
    HomeSectionType type,
    List<String> issues,
  ) {
    final section = model.section(sectionId);
    if (section.type != type) {
      issues.add('section $sectionId expected type $type got ${section.type}');
    }
  }

  static void _expectSectionVisible(
    HomePresentationModel model,
    String sectionId,
    bool visible,
    List<String> issues,
  ) {
    final section = model.section(sectionId);
    if (section.visible != visible) {
      issues.add('section $sectionId visible expected $visible got ${section.visible}');
    }
  }

  static void _expectVisibleCount(
    HomePresentationModel model, {
    int? count,
    int? greaterThan,
    HomeSectionGroupId? groupId,
    required List<String> issues,
  }) {
    Iterable<HomeSection> sections = model.sections;
    if (groupId != null) {
      sections = model.group(groupId).sections;
    }
    final visibleCount = sections.where((section) => section.visible).length;

    if (count != null && visibleCount != count) {
      issues.add('visible section count expected $count got $visibleCount');
    }
    if (greaterThan != null && visibleCount <= greaterThan) {
      issues.add(
        'visible section count expected > $greaterThan got $visibleCount',
      );
    }
  }
}
