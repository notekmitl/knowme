import 'package:knowme/features/astrology/fusion/domain/entities/fusion_category.dart';
import 'package:knowme/features/astrology/fusion/domain/entities/theme_family.dart';

import '../../domain/personality_agreement.dart';
import '../../domain/personality_agreement_kind.dart';
import '../../domain/personality_confidence.dart';
import 'personality_mirror_theme_signal.dart';
import 'personality_opposing_family.dart';

/// Detects theme, family, and category agreement across personality lenses.
abstract final class PersonalityAgreementEngine {
  static List<PersonalityAgreement> detect(
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    if (signals.isEmpty) return const [];

    final agreements = <PersonalityAgreement>[
      ..._detectThemeAgreement(signals),
      ..._detectFamilyAgreement(signals),
      ..._detectCategoryAgreement(signals),
    ];

    return _dedupe(agreements);
  }

  static List<PersonalityAgreement> _detectThemeAgreement(
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    final byTheme = <String, List<PersonalityMirrorThemeSignal>>{};
    for (final signal in signals) {
      byTheme.putIfAbsent(signal.themeId, () => []).add(signal);
    }

    final agreements = <PersonalityAgreement>[];
    for (final entry in byTheme.entries) {
      final lenses = entry.value.map((s) => s.agreementLens).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      if (lenses.length < 2) continue;

      agreements.add(
        PersonalityAgreement(
          kind: PersonalityAgreementKind.theme,
          themeId: entry.key,
          supportingAgreementLenses: lenses,
          confidence: _averageConfidence(entry.value),
          sourceThemeIds: [entry.key],
        ),
      );
    }
    return agreements;
  }

  static List<PersonalityAgreement> _detectFamilyAgreement(
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    final byFamily = <String, List<PersonalityMirrorThemeSignal>>{};
    for (final signal in signals) {
      final key = '${_categoryId(signal.category)}|${_familyId(signal.family)}';
      byFamily.putIfAbsent(key, () => []).add(signal);
    }

    final agreements = <PersonalityAgreement>[];
    for (final group in byFamily.values) {
      if (group.isEmpty) continue;

      final lenses = group.map((s) => s.agreementLens).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      final themes = group.map((s) => s.themeId).toSet().toList()..sort();

      if (lenses.length < 2) continue;
      if (themes.length < 2) continue;

      final sample = group.first;
      agreements.add(
        PersonalityAgreement(
          kind: PersonalityAgreementKind.family,
          themeId: _familyId(sample.family),
          supportingAgreementLenses: lenses,
          confidence: _averageConfidence(group),
          sourceThemeIds: themes,
          family: sample.family,
          category: sample.category,
          familyLevel: true,
        ),
      );
    }
    return agreements;
  }

  static List<PersonalityAgreement> _detectCategoryAgreement(
    List<PersonalityMirrorThemeSignal> signals,
  ) {
    final byCategory = <FusionCategory, List<PersonalityMirrorThemeSignal>>{};
    for (final signal in signals) {
      byCategory.putIfAbsent(signal.category, () => []).add(signal);
    }

    final agreements = <PersonalityAgreement>[];
    for (final entry in byCategory.entries) {
      final lenses = entry.value.map((s) => s.agreementLens).toSet().toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      if (lenses.length < 2) continue;

      final families = entry.value.map((s) => s.family).toSet();
      if (PersonalityOpposingFamily.hasOpposingPair(families)) continue;

      final themes = entry.value.map((s) => s.themeId).toSet().toList()..sort();
      agreements.add(
        PersonalityAgreement(
          kind: PersonalityAgreementKind.category,
          themeId: _categoryId(entry.key),
          supportingAgreementLenses: lenses,
          confidence: _averageConfidence(entry.value),
          sourceThemeIds: themes,
          category: entry.key,
        ),
      );
    }
    return agreements;
  }

  static double _averageConfidence(List<PersonalityMirrorThemeSignal> signals) {
    if (signals.isEmpty) return 0;
    final sum = signals.fold<double>(0, (total, s) => total + s.confidence);
    return PersonalityConfidenceBands.clamp(sum / signals.length);
  }

  static List<PersonalityAgreement> _dedupe(
    List<PersonalityAgreement> agreements,
  ) {
    final seen = <String>{};
    final out = <PersonalityAgreement>[];

    for (final agreement in agreements) {
      final key = [
        agreement.kind.name,
        agreement.themeId,
        ...agreement.supportingAgreementLenses.map((l) => l.storageKey),
        ...agreement.sourceThemeIds,
      ].join('|');
      if (seen.add(key)) out.add(agreement);
    }

    return out;
  }

  static String _categoryId(FusionCategory category) => category.id;

  static String _familyId(ThemeFamily family) => family.name;
}
