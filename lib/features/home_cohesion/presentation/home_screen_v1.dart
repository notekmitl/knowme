import 'package:flutter/material.dart';

import '../domain/home_experience_blueprint.dart';
import 'home_explore_section.dart';
import 'home_journey_section.dart';
import 'home_reflections_section.dart';
import 'home_screen_v1_models.dart';

/// Home MVP V1 — renders from [HomeScreenV1Data.contract] only.
class HomeScreenV1 extends StatelessWidget {
  const HomeScreenV1({
    super.key,
    required this.data,
  });

  final HomeScreenV1Data data;

  @override
  Widget build(BuildContext context) {
    final contract = data.contract;
    final aboveFold = <Widget>[];
    final belowFold = <Widget>[];

    for (final type in contract.aboveFoldSections) {
      final widget = _sectionFor(type);
      if (widget != null) aboveFold.add(widget);
    }

    for (final type in contract.belowFoldSections) {
      final widget = _sectionFor(type);
      if (widget != null) belowFold.add(widget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < aboveFold.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          aboveFold[i],
        ],
        if (belowFold.isNotEmpty) ...[
          const SizedBox(height: 28),
          for (var i = 0; i < belowFold.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            belowFold[i],
          ],
        ],
      ],
    );
  }

  Widget? _sectionFor(HomeExperienceSectionType type) {
    if (!data.contract.visibleSectionTypes.contains(type)) {
      return null;
    }

    return switch (type) {
      HomeExperienceSectionType.journey =>
        HomeJourneySection(data: data.journey),
      HomeExperienceSectionType.reflections =>
        HomeReflectionsSection(data: data.reflections),
      HomeExperienceSectionType.explore => HomeExploreSection(data: data.explore),
    };
  }
}
