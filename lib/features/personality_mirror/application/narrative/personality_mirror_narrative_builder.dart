import 'package:knowme/core/i18n/app_text.dart';

import '../../domain/personality_agreement.dart';
import '../../domain/personality_agreement_kind.dart';
import '../../domain/personality_agreement_lens_id.dart';
import '../../domain/personality_confidence.dart';
import '../../domain/personality_confidence_breakdown.dart';
import '../../domain/personality_mirror_narrative_view.dart';
import '../../domain/personality_mirror_snapshot.dart';
import '../../domain/personality_tension.dart';

/// Deterministic narrative from [PersonalityMirrorSnapshot] (no AI).
abstract final class PersonalityMirrorNarrativeBuilder {
  static const int maxHeroParagraphs = 3;
  static const int maxPatternCards = 3;
  static const int maxPerspectiveCards = 2;

  static PersonalityMirrorNarrativeView build(
    PersonalityMirrorSnapshot mirror, {
    PersonalityConfidenceBreakdown? confidenceBreakdown,
  }) {
    final composite = confidenceBreakdown?.compositeConfidence ??
        mirror.compositeConfidence;
    final toneKey = _confidenceToneKey(composite);

    return PersonalityMirrorNarrativeView(
      heroParagraphs: _buildHero(mirror, toneKey),
      patternCards: _buildPatternCards(mirror.agreements),
      perspectiveCards: _buildPerspectiveCards(mirror.tensions),
      lensContributionLines: _buildLensContributions(mirror),
      depthHint: _buildDepthHint(mirror),
      disclosure: AppText.t('personality_mirror_disclosure'),
      confidenceToneKey: toneKey,
    );
  }

  static List<String> _buildHero(
    PersonalityMirrorSnapshot mirror,
    String toneKey,
  ) {
    final paragraphs = <String>[];

    if (_needsSoftOpener(mirror.coverage.weightedCoverage)) {
      paragraphs.add(AppText.t(toneKey));
    }

    final strongest = _strongestAgreement(mirror.agreements);
    if (strongest != null) {
      paragraphs.add(_agreementHeroSentence(strongest));
    } else if (paragraphs.isEmpty) {
      paragraphs.add(AppText.t(toneKey));
    }

    if (mirror.tensions.isNotEmpty) {
      paragraphs.add(AppText.t('personality_mirror_hero_nuance_perspective'));
    }

    return paragraphs.take(maxHeroParagraphs).toList(growable: false);
  }

  static List<PersonalityMirrorPatternCard> _buildPatternCards(
    List<PersonalityAgreement> agreements,
  ) {
    final themeOnly = agreements
        .where((a) => a.kind == PersonalityAgreementKind.theme)
        .toList(growable: false);
    final sorted = [...themeOnly]..sort(_agreementSort);

    final cards = <PersonalityMirrorPatternCard>[];
    for (final agreement in sorted) {
      if (cards.length >= maxPatternCards) break;

      final themeId = _displayThemeId(agreement);
      cards.add(
        PersonalityMirrorPatternCard(
          title: _patternTitle(agreement, themeId),
          body: _patternBody(agreement, themeId),
          supportingLensesLabel:
              _supportingLensesLabel(agreement.supportingAgreementLenses),
          themeId: themeId,
          agreementKindKey: agreement.kind.name,
        ),
      );
    }

    return cards;
  }

  static List<PersonalityMirrorPerspectiveCard> _buildPerspectiveCards(
    List<PersonalityTension> tensions,
  ) {
    final cards = <PersonalityMirrorPerspectiveCard>[];
    for (final tension in tensions) {
      if (cards.length >= maxPerspectiveCards) break;

      final reasonKey = _perspectiveReasonKey(tension.reasonCode);
      cards.add(
        PersonalityMirrorPerspectiveCard(
          title: AppText.t('personality_mirror_perspective_title_$reasonKey'),
          body: AppText.t('personality_mirror_perspective_body_$reasonKey'),
          reasonCode: tension.reasonCode,
        ),
      );
    }
    return cards;
  }

  static List<String> _buildLensContributions(
    PersonalityMirrorSnapshot mirror,
  ) {
    final lines = <String>[];
    final coverage = mirror.coverage;

    if (coverage.hasMbti) {
      lines.add(AppText.t('personality_mirror_contribution_mbti'));
    }
    if (coverage.hasBigFive) {
      lines.add(AppText.t('personality_mirror_contribution_big_five'));
    }
    if (coverage.hasAnyEq) {
      if (coverage.eqModulesCompleted >= coverage.eqModulesExpected) {
        lines.add(AppText.t('personality_mirror_contribution_eq_full'));
      } else {
        lines.add(
          AppText.t('personality_mirror_contribution_eq_partial')
              .replaceAll('{completed}', '${coverage.eqModulesCompleted}')
              .replaceAll('{total}', '${coverage.eqModulesExpected}'),
        );
      }
    }

    return lines;
  }

  static String _buildDepthHint(PersonalityMirrorSnapshot mirror) {
    final count = mirror.coverage.availableLensIds.length;
    return AppText.t('personality_mirror_depth_hint')
        .replaceAll('{count}', '$count');
  }

  static bool _needsSoftOpener(double weightedCoverage) =>
      weightedCoverage < 0.6;

  static String _confidenceToneKey(PersonalityConfidence value) {
    final band = PersonalityConfidenceBands.bandLabel(value);
    return switch (band) {
      'low' => 'personality_mirror_hero_opener_low',
      'medium' => 'personality_mirror_hero_opener_medium',
      'high' => 'personality_mirror_hero_opener_high',
      _ => 'personality_mirror_hero_opener_very_high',
    };
  }

  static PersonalityAgreement? _strongestAgreement(
    List<PersonalityAgreement> agreements,
  ) {
    if (agreements.isEmpty) return null;
    final sorted = [...agreements]..sort(_agreementSort);
    return sorted.first;
  }

  static int _agreementSort(PersonalityAgreement a, PersonalityAgreement b) {
    final kind = _kindRank(a.kind).compareTo(_kindRank(b.kind));
    if (kind != 0) return kind;
    return b.confidence.compareTo(a.confidence);
  }

  static int _kindRank(PersonalityAgreementKind kind) => switch (kind) {
        PersonalityAgreementKind.theme => 0,
        PersonalityAgreementKind.family => 1,
        PersonalityAgreementKind.category => 2,
      };

  static String _displayThemeId(PersonalityAgreement agreement) {
    if (agreement.kind == PersonalityAgreementKind.theme) {
      return agreement.themeId;
    }
    if (agreement.sourceThemeIds.isNotEmpty) {
      return agreement.sourceThemeIds.first;
    }
    return agreement.themeId;
  }

  static String _agreementHeroSentence(PersonalityAgreement agreement) {
    final themeId = _displayThemeId(agreement);
    final key = 'personality_mirror_hero_agreement_$themeId';
    final text = AppText.t(key);
    if (text != key) return text;
    return AppText.t('personality_mirror_hero_agreement_fallback')
        .replaceAll('{theme}', AppText.t('personality_mirror_theme_$themeId'));
  }

  static String _patternTitle(
    PersonalityAgreement agreement,
    String themeId,
  ) {
    return switch (agreement.kind) {
      PersonalityAgreementKind.theme =>
        _textOrFallback('personality_mirror_pattern_title_$themeId', themeId),
      PersonalityAgreementKind.family => _textOrFallback(
          'personality_mirror_pattern_family_title_${agreement.family?.name}',
          themeId,
        ),
      PersonalityAgreementKind.category => _textOrFallback(
          'personality_mirror_pattern_category_title_${agreement.category?.name}',
          themeId,
        ),
    };
  }

  static String _patternBody(
    PersonalityAgreement agreement,
    String themeId,
  ) {
    return switch (agreement.kind) {
      PersonalityAgreementKind.theme =>
        _textOrFallback('personality_mirror_pattern_body_$themeId', themeId),
      PersonalityAgreementKind.family => _textOrFallback(
          'personality_mirror_pattern_family_body_${agreement.family?.name}',
          themeId,
        ),
      PersonalityAgreementKind.category => _textOrFallback(
          'personality_mirror_pattern_category_body_${agreement.category?.name}',
          themeId,
        ),
    };
  }

  static String _textOrFallback(String key, String themeId) {
    final text = AppText.t(key);
    if (text != key) return text;
    return AppText.t('personality_mirror_pattern_body_fallback')
        .replaceAll('{theme}', AppText.t('personality_mirror_theme_$themeId'));
  }

  static String _supportingLensesLabel(
    List<PersonalityAgreementLensId> lenses,
  ) {
    final keys = lenses.map((l) => l.storageKey).toList()..sort();
    final composite = keys.join('_');
    final key = 'personality_mirror_lenses_$composite';
    final text = AppText.t(key);
    if (text != key) return text;

    final joiner = AppText.lang == 'th' ? ' และ ' : ' & ';
    final parts = lenses
        .map((l) => AppText.t('personality_mirror_lens_${l.storageKey}'))
        .toList();
    return AppText.t('personality_mirror_lenses_joined')
        .replaceAll('{lenses}', parts.join(joiner));
  }

  static String _perspectiveReasonKey(String reasonCode) {
    if (reasonCode.contains('expression_reflection')) {
      return 'expression_reflection';
    }
    if (reasonCode.contains('structure_adaptation')) {
      return 'structure_adaptation';
    }
    return 'general';
  }
}
