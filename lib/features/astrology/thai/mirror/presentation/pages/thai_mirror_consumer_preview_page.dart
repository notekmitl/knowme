import 'package:flutter/material.dart';

import 'package:knowme/core/themes/theme_category.dart';
import 'package:knowme/core/themes/theme_registry.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_input.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_result.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/thai_mirror_consumer_presenter.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/ui/pages/thai_mirror_result_page.dart';
import 'package:knowme/features/astrology/thai/mirror/thai_mirror_assembler.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_presented_theme.dart';
import 'package:knowme/features/astrology/thai/theme/models/thai_theme_confidence_level.dart';

/// Web screenshot preview — renders consumer page for validation profiles.
class ThaiMirrorConsumerPreviewPage extends StatelessWidget {
  const ThaiMirrorConsumerPreviewPage({
    super.key,
    this.profileId = 'A',
    this.hasBirthTime = true,
  });

  final String profileId;
  final bool hasBirthTime;

  static const routeName = '/thai-mirror/consumer-preview';

  @override
  Widget build(BuildContext context) {
    final themes = _profiles[profileId.toUpperCase()] ?? _profiles['A']!;
    final consumer = ThaiMirrorConsumerPresenter.present(
      _assemble(themes, hasBirthTime: hasBirthTime),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Consumer Preview — Profile $profileId'),
      ),
      body: ThaiMirrorResultPage(consumerState: consumer),
    );
  }

  static ThaiMirrorResult _assemble(
    List<({String id, ThemeCategory category})> themes, {
    required bool hasBirthTime,
  }) {
    final presented = themes.map((entry) {
      final definition = ThemeRegistry.getById(entry.id)!;
      return ThaiPresentedTheme(
        themeId: entry.id,
        themeName: definition.name,
        category: entry.category.displayName,
        description: definition.description,
        score: 0.85,
        confidence: ThaiThemeConfidenceLevel.high,
        evidence: const [],
      );
    }).toList();

    return ThaiMirrorAssembler.assemble(
      ThaiMirrorInput(
        profile: ThaiAstrologyProfile(hasBirthTime: hasBirthTime),
        presentedThemes: presented,
      ),
    );
  }

  static final Map<String, List<({String id, ThemeCategory category})>> _profiles = {
    'A': [
      (id: 'disciplined', category: ThemeCategory.coreSelf),
      (id: 'analytical', category: ThemeCategory.thinkingStyle),
      (id: 'builder', category: ThemeCategory.workAndAmbition),
      (id: 'reliability', category: ThemeCategory.strengths),
      (id: 'overthinking', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ],
    'NO_TIME': [
      (id: 'disciplined', category: ThemeCategory.coreSelf),
      (id: 'analytical', category: ThemeCategory.thinkingStyle),
      (id: 'loyal', category: ThemeCategory.relationships),
      (id: 'reliability', category: ThemeCategory.strengths),
      (id: 'overthinking', category: ThemeCategory.growthAreas),
      (id: 'develop_patience', category: ThemeCategory.growthPath),
    ],
  };
}
