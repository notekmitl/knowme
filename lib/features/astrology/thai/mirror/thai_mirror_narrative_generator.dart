import '../../../../core/themes/theme_registry.dart';
import '../content/models/thai_content_section.dart';
import 'thai_mirror_narrative_variants.dart';
import 'thai_mirror_section_distribution.dart';
import 'models/thai_mirror_profile_context.dart';
import 'models/thai_mirror_result.dart';
import 'models/thai_mirror_section.dart';
import 'models/thai_mirror_section_id.dart';
import 'models/thai_mirror_theme_ref.dart';
import 'models/thai_narrative_metadata.dart';
import 'spec/thai_mirror_narrative_generator_spec.dart';

/// Template-based narrative generator — V1.2.
///
/// Fills section summaries from ThemeRegistry and Thai Content Library only.
/// Does not modify scores, confidence, evidence, or theme rankings.
abstract final class ThaiMirrorNarrativeGenerator {
  static const _maxThemesPerSection = 3;
  static const _maxContentSnippets = 2;

  static ThaiMirrorResult generate(ThaiMirrorResult structural) {
    final metadata = <ThaiNarrativeMetadata>[];
    final updatedSections = <ThaiMirrorSection>[];

    for (final section in structural.sections) {
      final built = _buildSectionNarrative(
        section: section,
        profileContext: structural.profileContext,
      );
      metadata.add(built.metadata);
      updatedSections.add(
        ThaiMirrorSection(
          id: section.id,
          title: section.title,
          titleTh: section.titleTh,
          summary: built.summary,
          supportingThemes: section.supportingThemes,
          evidence: section.evidence,
        ),
      );
    }

    return ThaiMirrorResult(
      contractVersion: structural.contractVersion,
      generatedAt: structural.generatedAt,
      profileContext: structural.profileContext,
      topThemes: structural.topThemes,
      sections: updatedSections,
      disclaimers: structural.disclaimers,
      narrativeStatus: ThaiMirrorNarrativeStatus.complete,
      narrativeMetadata: List<ThaiNarrativeMetadata>.unmodifiable(metadata),
    );
  }

  static _SectionNarrative _buildSectionNarrative({
    required ThaiMirrorSection section,
    required ThaiMirrorProfileContext profileContext,
  }) {
    final themes = section.supportingThemes.take(_maxThemesPerSection).toList();
    final contentSections =
        ThaiMirrorSectionDistribution.mirrorContentSectionsForNarrative(
      sectionId: section.id,
      evidence: section.evidence,
    );

    if (themes.isEmpty && contentSections.isEmpty) {
      return _SectionNarrative(
        summary: _emptySectionSummary(section.id),
        metadata: ThaiNarrativeMetadata(
          sectionId: section.id,
          themeIdsUsed: const [],
          contentKeysUsed: const [],
        ),
      );
    }

    final themeIdsUsed = themes.map((t) => t.themeId).toList(growable: false);
    final contentKeysUsed = contentSections
        .map((s) => s.key)
        .toList(growable: false);

    final summary = switch (section.id) {
      ThaiMirrorSectionId.strengths => _buildStrengthsSummary(
          section.id,
          themes,
          contentSections,
          contentKeysUsed,
        ),
      ThaiMirrorSectionId.growthAreas => _buildGrowthAreasSummary(
          section.id,
          themes,
          contentSections,
          contentKeysUsed,
        ),
      ThaiMirrorSectionId.growthPath => _buildGrowthPathSummary(
          section.id,
          themes,
          contentSections,
          contentKeysUsed,
        ),
      _ => _buildParagraphSummary(
          sectionId: section.id,
          themes: themes,
          contentSections: contentSections,
          profileContext: profileContext,
          narrativeSeed: _narrativeSeed(
            sectionId: section.id,
            themes: themes,
            contentKeys: contentKeysUsed,
          ),
        ),
    };

    return _SectionNarrative(
      summary: _sanitize(summary),
      metadata: ThaiNarrativeMetadata(
        sectionId: section.id,
        themeIdsUsed: themeIdsUsed,
        contentKeysUsed: contentKeysUsed,
      ),
    );
  }

  static String _buildParagraphSummary({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiMirrorThemeRef> themes,
    required List<ThaiContentSection> contentSections,
    required ThaiMirrorProfileContext profileContext,
    required String narrativeSeed,
  }) {
    final themePhrase = _themeNamePhrase(themes);
    final leadSnippet = _sectionLeadSnippet(
      sectionId: sectionId,
      themes: themes,
      contentSections: contentSections,
      narrativeSeed: narrativeSeed,
    );
    final lagnaNote = _lagnaLimitationNote(sectionId, profileContext);
    final variant = ThaiMirrorNarrativeVariants.indexFor(
      sectionId: sectionId,
      seed: narrativeSeed,
      variantCount: 4,
    );

    return switch (sectionId) {
      ThaiMirrorSectionId.coreSelf =>
        '${ThaiMirrorNarrativeVariants.coreSelfOpening(variant)}$themePhrase '
            '$leadSnippet '
            '${ThaiMirrorNarrativeVariants.coreSelfClosing(variant)}'
            '$lagnaNote',
      ThaiMirrorSectionId.thinkingStyle =>
        '${ThaiMirrorNarrativeVariants.thinkingOpening(variant)}$themePhrase '
            '$leadSnippet '
            '${ThaiMirrorNarrativeVariants.thinkingClosing(variant)}'
            '$lagnaNote',
      ThaiMirrorSectionId.emotionalWorld =>
        '${ThaiMirrorNarrativeVariants.emotionalOpening(variant)}$themePhrase '
            '$leadSnippet '
            '${ThaiMirrorNarrativeVariants.emotionalClosing(variant)}'
            '$lagnaNote',
      ThaiMirrorSectionId.relationships =>
        '${ThaiMirrorNarrativeVariants.relationshipsOpening(variant)}$themePhrase '
            '$leadSnippet '
            '${ThaiMirrorNarrativeVariants.relationshipsClosing(variant)}'
            '$lagnaNote',
      ThaiMirrorSectionId.workAndAmbition =>
        '${ThaiMirrorNarrativeVariants.workOpening(variant)}$themePhrase '
            '$leadSnippet '
            '${ThaiMirrorNarrativeVariants.workClosing(variant)}'
            '$lagnaNote',
      _ => 'คุณอาจสังเกตแพทเทิร์นที่เกี่ยวข้องกับ$themePhrase $leadSnippet$lagnaNote',
    };
  }

  static String _buildStrengthsSummary(
    ThaiMirrorSectionId sectionId,
    List<ThaiMirrorThemeRef> themes,
    List<ThaiContentSection> contentSections,
    List<String> contentKeysUsed,
  ) {
    final bullets = <String>[];

    for (final content in contentSections.take(_maxContentSnippets)) {
      for (final strength in content.strengths) {
        if (_isMostlyEnglish(strength)) continue;
        bullets.add(strength);
        break;
      }
    }

    for (final theme in themes) {
      final definition = ThemeRegistry.getById(theme.themeId);
      if (definition != null) {
        bullets.add(
          'แนวโน้มด้าน${definition.name}ที่คุณอาจสังเกตได้ในชีวิตประจำวัน',
        );
      }
    }

    if (bullets.isEmpty) {
      return 'หลายครั้งคุณอาจมีจุดแข็งที่ค่อย ๆ ปรากฏเมื่อสังเกตตนเองอย่างต่อเนื่อง';
    }

    final listed = bullets.take(3).map((b) => '• $b').join(' ');
    final variant = ThaiMirrorNarrativeVariants.indexFor(
      sectionId: sectionId,
      seed: _narrativeSeed(
        sectionId: sectionId,
        themes: themes,
        contentKeys: contentKeysUsed,
      ),
      variantCount: 4,
    );
    return '${ThaiMirrorNarrativeVariants.strengthsIntro(variant)} $listed';
  }

  static String _buildGrowthAreasSummary(
    ThaiMirrorSectionId sectionId,
    List<ThaiMirrorThemeRef> themes,
    List<ThaiContentSection> contentSections,
    List<String> contentKeysUsed,
  ) {
    final softPoints = <String>[];

    for (final content in contentSections.take(_maxContentSnippets)) {
      for (final challenge in content.challenges.take(2)) {
        if (_isMostlyEnglish(challenge)) continue;
        softPoints.add(_softenChallenge(challenge));
      }
    }

    if (softPoints.isEmpty && themes.isNotEmpty) {
      final definition = ThemeRegistry.getById(themes.first.themeId);
      if (definition != null) {
        softPoints.add(
          'บางครั้งการปรับสมดุลด้าน${definition.name}อาจเป็นพื้นที่ที่คุณอยากสำรวจเพิ่ม',
        );
      }
    }

    if (softPoints.isEmpty) {
      final variant = ThaiMirrorNarrativeVariants.indexFor(
        sectionId: sectionId,
        seed: _narrativeSeed(
          sectionId: sectionId,
          themes: themes,
          contentKeys: contentKeysUsed,
        ),
        variantCount: 4,
      );
      return ThaiMirrorNarrativeVariants.growthAreasFallback(variant);
    }

    final joined = softPoints.take(2).join(' ');
    final variant = ThaiMirrorNarrativeVariants.indexFor(
      sectionId: sectionId,
      seed: _narrativeSeed(
        sectionId: sectionId,
        themes: themes,
        contentKeys: contentKeysUsed,
      ),
      variantCount: 4,
    );
    return '${ThaiMirrorNarrativeVariants.growthAreasIntro(variant)} $joined '
        'ซึ่งเป็นโอกาสในการเรียนรู้ตนเองมากกว่าข้อสรุปถาวร';
  }

  static String _buildGrowthPathSummary(
    ThaiMirrorSectionId sectionId,
    List<ThaiMirrorThemeRef> themes,
    List<ThaiContentSection> contentSections,
    List<String> contentKeysUsed,
  ) {
    final paths = <String>[];

    for (final content in contentSections.take(_maxContentSnippets)) {
      if (content.growthPath.trim().isEmpty) continue;
      final clause = _firstClause(content.growthPath);
      if (_isMostlyEnglish(clause)) continue;
      paths.add(clause);
    }

    if (paths.isEmpty && themes.isNotEmpty) {
      final definition = ThemeRegistry.getById(themes.first.themeId);
      if (definition != null) {
        paths.add(
          'การสำรวจด้าน${definition.name}อย่างต่อเนื่องอาจช่วยให้คุณเติบโตอย่างมีสติ',
        );
      }
    }

    if (paths.isEmpty) {
      final variant = ThaiMirrorNarrativeVariants.indexFor(
        sectionId: sectionId,
        seed: _narrativeSeed(
          sectionId: sectionId,
          themes: themes,
          contentKeys: contentKeysUsed,
        ),
        variantCount: 4,
      );
      return ThaiMirrorNarrativeVariants.growthPathFallback(variant);
    }

    final joined = paths.take(2).join(' ');
    final variant = ThaiMirrorNarrativeVariants.indexFor(
      sectionId: sectionId,
      seed: _narrativeSeed(
        sectionId: sectionId,
        themes: themes,
        contentKeys: contentKeysUsed,
      ),
      variantCount: 4,
    );
    return '${ThaiMirrorNarrativeVariants.growthPathIntro(variant)} $joined '
        'การลงมือปรับเล็กน้อยอย่างสม่ำเสมออาจสร้างความเปลี่ยนแปลงที่ยั่งยืน';
  }

  static String _emptySectionSummary(ThaiMirrorSectionId sectionId) {
    return 'หลายครั้งคุณอาจยังสังเกตแพทเทิร์นใน${sectionId.titleTh}ไม่ชัดเจนนัก '
        'ซึ่งเป็นเรื่องปกติเมื่อข้อมูลยังไม่เพียงพอสำหรับการสะท้อนในส่วนนี้';
  }

  static String _themeNamePhrase(List<ThaiMirrorThemeRef> themes) {
    if (themes.isEmpty) return 'แพทเทิร์นที่หลากหลาย';

    final names = themes.map((t) => t.themeName).toList();
    if (names.length == 1) return 'ธีม ${names.first}';
    if (names.length == 2) return 'ธีม ${names[0]} และ ${names[1]}';

    return 'ธีม ${names[0]} ${names[1]} และ ${names[2]}';
  }

  static String _sectionLeadSnippet({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiMirrorThemeRef> themes,
    required List<ThaiContentSection> contentSections,
    required String narrativeSeed,
  }) {
    if (contentSections.isNotEmpty) {
      final variant = ThaiMirrorNarrativeVariants.indexFor(
        sectionId: sectionId,
        seed: narrativeSeed,
        variantCount: contentSections.length,
      );
      final content = contentSections[variant % contentSections.length];
      final source = switch (sectionId) {
        ThaiMirrorSectionId.coreSelf => content.coreNature,
        ThaiMirrorSectionId.thinkingStyle => content.summary,
        ThaiMirrorSectionId.emotionalWorld => content.coreNature,
        ThaiMirrorSectionId.relationships => content.summary,
        ThaiMirrorSectionId.workAndAmbition => content.coreNature,
        _ => content.summary,
      };
      final clause = _firstClause(source);
      if (!_isMostlyEnglish(clause)) {
        return clause;
      }
    }

    return _themeFallbackClause(themes, narrativeSeed);
  }

  static String _themeFallbackClause(
    List<ThaiMirrorThemeRef> themes,
    String narrativeSeed,
  ) {
    if (themes.isEmpty) return '';

    final variant = narrativeSeed.hashCode.abs() % themes.length;
    final theme = themes[variant % themes.length];
    final definition = ThemeRegistry.getById(theme.themeId);
    if (definition == null) return '';

    return 'คุณอาจสังเกตแพทเทิร์นที่สะท้อนผ่าน${definition.name}';
  }

  static String _narrativeSeed({
    required ThaiMirrorSectionId sectionId,
    required List<ThaiMirrorThemeRef> themes,
    required List<String> contentKeys,
  }) {
    final themeIds = themes.map((theme) => theme.themeId).join('|');
    final keys = contentKeys.join('|');
    return '$sectionId::$themeIds::$keys';
  }

  static String _softenChallenge(String challenge) {
    final trimmed = challenge.trim();
    if (trimmed.startsWith('อาจ')) return trimmed;
    return 'อาจ$trimmed';
  }

  static String _firstClause(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    final periodIndex = trimmed.indexOf('.');
    final thaiStop = trimmed.indexOf('。');
    var cut = trimmed.length;

    if (periodIndex != -1) cut = periodIndex + 1;
    if (thaiStop != -1 && thaiStop < cut) cut = thaiStop + 1;

    final spaceBreak = trimmed.indexOf(' ', 80);
    if (cut > 160 && spaceBreak != -1) {
      cut = spaceBreak;
    }

    if (cut > 200) cut = 200;
    if (cut > trimmed.length) cut = trimmed.length;

    return trimmed.substring(0, cut).trim();
  }

  static String _lagnaLimitationNote(
    ThaiMirrorSectionId sectionId,
    ThaiMirrorProfileContext profileContext,
  ) {
    if (profileContext.hasBirthTime) return '';
    if (profileContext.lagnaKey != null) return '';
    if (sectionId != ThaiMirrorSectionId.coreSelf) return '';

    return ' (เมื่อไม่มีเวลาเกิดที่แม่นยำ ส่วนที่เกี่ยวกับลัคนาอาจสะท้อนได้ไม่ครบถ้วน)';
  }

  static bool _isMostlyEnglish(String text) {
    final latin = RegExp(r'[A-Za-z]').allMatches(text).length;
    if (latin == 0) return false;

    final thai = RegExp(r'[\u0E00-\u0E7F]').allMatches(text).length;
    return latin > thai;
  }

  static String _sanitize(String text) {
    var output = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    for (final banned in ThaiMirrorNarrativeGeneratorSpec.bannedTermsTh) {
      output = output.replaceAll(banned, '');
    }
    for (final banned in ThaiMirrorNarrativeGeneratorSpec.bannedTermsEn) {
      output = output.replaceAll(RegExp(banned, caseSensitive: false), '');
    }

    return output.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

final class _SectionNarrative {
  const _SectionNarrative({
    required this.summary,
    required this.metadata,
  });

  final String summary;
  final ThaiNarrativeMetadata metadata;
}
