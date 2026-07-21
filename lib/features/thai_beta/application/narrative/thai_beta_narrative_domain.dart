/// Deterministic life-domain semantic mapping for Thai Beta narrative quality.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_evidence_composer.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_life_hints.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_variants.dart';

/// Consumer life dashboard + narrative domain keys.
enum ThaiBetaLifeDomain {
  work,
  money,
  love,
  health,
  luck,
}

extension ThaiBetaLifeDomainKeys on ThaiBetaLifeDomain {
  String get aspectKey => switch (this) {
        ThaiBetaLifeDomain.work => 'work',
        ThaiBetaLifeDomain.money => 'money',
        ThaiBetaLifeDomain.love => 'love',
        ThaiBetaLifeDomain.health => 'health',
        ThaiBetaLifeDomain.luck => 'luck',
      };

  String get labelTh => switch (this) {
        ThaiBetaLifeDomain.work => 'การงาน',
        ThaiBetaLifeDomain.money => 'การเงิน',
        ThaiBetaLifeDomain.love => 'ความรัก',
        ThaiBetaLifeDomain.health => 'สุขภาพ',
        ThaiBetaLifeDomain.luck => 'โชคและโอกาส',
      };

  String get narrativeSectionLabel => switch (this) {
        ThaiBetaLifeDomain.work => 'ชีวิตด้านการงาน',
        ThaiBetaLifeDomain.money => 'ชีวิตด้านการเงิน',
        ThaiBetaLifeDomain.love => 'ชีวิตด้านความรัก',
        ThaiBetaLifeDomain.health => 'สุขภาพและพลังใจ',
        ThaiBetaLifeDomain.luck => 'จังหวะชีวิตและโอกาส',
      };
}

/// Semantic topic tags per domain — used for compatibility checks (not keyword-only).
abstract final class ThaiBetaDomainSemanticTags {
  static const topics = <ThaiBetaLifeDomain, Set<String>>{
    ThaiBetaLifeDomain.work: {
      'work_method',
      'decision',
      'responsibility',
      'leadership',
      'learning_at_work',
      'goals',
      'collaboration',
      'work_pressure',
    },
    ThaiBetaLifeDomain.money: {
      'stability',
      'spending',
      'saving',
      'risk',
      'short_long_decision',
      'emotion_money',
      'invest_time_money',
    },
    ThaiBetaLifeDomain.love: {
      'show_love',
      'openness',
      'trust',
      'intimacy',
      'feelings_communication',
      'personal_space',
      'unspoken_needs',
    },
    ThaiBetaLifeDomain.health: {
      'rest',
      'energy',
      'stress',
      'self_pressure',
      'body_signals',
      'balance',
      'recovery',
      'physical_mental_pattern',
    },
    ThaiBetaLifeDomain.luck: {
      'see_opportunity',
      'readiness',
      'adapt',
      'timing_people',
      'accept_decline',
      'risk_courage',
      'build_on_existing',
    },
  };

  /// Facet affinity weights per domain (deterministic metadata).
  static const facetAffinity = <ReportFacet, Map<ThaiBetaLifeDomain, int>>{
    ReportFacet.leadership: {
      ThaiBetaLifeDomain.work: 3,
      ThaiBetaLifeDomain.luck: 2,
    },
    ReportFacet.action: {
      ThaiBetaLifeDomain.work: 3,
      ThaiBetaLifeDomain.luck: 2,
    },
    ReportFacet.structure: {
      ThaiBetaLifeDomain.work: 2,
      ThaiBetaLifeDomain.money: 3,
    },
    ReportFacet.thinking: {
      ThaiBetaLifeDomain.work: 2,
      ThaiBetaLifeDomain.money: 2,
    },
    ReportFacet.people: {
      ThaiBetaLifeDomain.love: 3,
      ThaiBetaLifeDomain.work: 1,
    },
    ReportFacet.emotion: {
      ThaiBetaLifeDomain.love: 2,
      ThaiBetaLifeDomain.health: 3,
    },
    ReportFacet.drive: {
      ThaiBetaLifeDomain.work: 2,
      ThaiBetaLifeDomain.luck: 2,
    },
    ReportFacet.novelty: {
      ThaiBetaLifeDomain.luck: 3,
      ThaiBetaLifeDomain.work: 1,
    },
    ReportFacet.independent: {
      ThaiBetaLifeDomain.work: 2,
      ThaiBetaLifeDomain.love: 1,
    },
    ReportFacet.caution: {
      ThaiBetaLifeDomain.money: 2,
      ThaiBetaLifeDomain.health: 2,
    },
  };

  static int compatibilityScore(String themeId, ThaiBetaLifeDomain domain) {
    final phrase = ThaiMirrorThemePhrases.phrase(themeId);
    final facet = ThaiMirrorEvidenceComposer.facetForThemeId(themeId);
    var score = facetAffinity[facet]?[domain] ?? 0;

    final hasHint = switch (domain) {
      ThaiBetaLifeDomain.work => phrase.workHint != null,
      ThaiBetaLifeDomain.money => phrase.moneyHint != null,
      ThaiBetaLifeDomain.love => phrase.loveHint != null,
      ThaiBetaLifeDomain.health => phrase.healthHint != null,
      ThaiBetaLifeDomain.luck => phrase.luckHint != null,
    };
    if (hasHint) score += 2;

    final lifeHint = _lifeHintText(themeId, domain);
    if (lifeHint.trim().isNotEmpty) score += 1;

    return score;
  }

  static String _lifeHintText(String themeId, ThaiBetaLifeDomain domain) {
    final life = ThaiMirrorThemeLifeHints.forTheme(themeId);
    return switch (domain) {
      ThaiBetaLifeDomain.work => life.work,
      ThaiBetaLifeDomain.money => life.money,
      ThaiBetaLifeDomain.love => life.love,
      ThaiBetaLifeDomain.health => life.health,
      ThaiBetaLifeDomain.luck => life.luck,
    };
  }

  /// Picks a domain-compatible theme deterministically from [orderedThemeIds].
  static String selectThemeForDomain({
    required List<String> orderedThemeIds,
    required ThaiBetaLifeDomain domain,
    required int seed,
    Set<String> usedThemeIds = const {},
  }) {
    if (orderedThemeIds.isEmpty) return 'independent';

    final scored = <({String id, int score})>[];
    for (final id in orderedThemeIds) {
      scored.add((id: id, score: compatibilityScore(id, domain)));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.id.compareTo(b.id);
    });

    final minScore = domain == ThaiBetaLifeDomain.health ||
            domain == ThaiBetaLifeDomain.luck
        ? 1
        : 2;
    final compatible =
        scored.where((e) => e.score >= minScore).map((e) => e.id).toList();
    final pool = compatible.isNotEmpty ? compatible : orderedThemeIds;

    final start = (seed.abs() + domain.index * 17) % pool.length;
    for (var k = 0; k < pool.length; k++) {
      final cand = pool[(start + k) % pool.length];
      if (!usedThemeIds.contains(cand)) return cand;
    }
    return pool[start];
  }

  /// Domain-specific dashboard copy from existing theme life hints.
  static ({
    String currentState,
    String whyItAppears,
    String suggestedAction,
    String primaryThemeId,
    String? secondaryThemeId,
  }) composeDashboardCopy({
    required ThaiBetaLifeDomain domain,
    required String primaryThemeId,
    String? secondaryThemeId,
    required int seed,
    Set<String> usedActions = const {},
  }) {
    final primary = ThaiMirrorThemePhrases.phrase(primaryThemeId);
    final life = ThaiMirrorThemeLifeHints.forTheme(primaryThemeId);
    final domainHint = _lifeHintText(primaryThemeId, domain);

    final secondaryFacet = secondaryThemeId != null
        ? ThaiMirrorEvidenceComposer.facetForThemeId(secondaryThemeId)
        : null;
    final secondaryPhrase = secondaryThemeId != null
        ? ThaiMirrorThemePhrases.phrase(secondaryThemeId)
        : null;

    final currentVariants = <String>[
      domainHint,
      ThaiMirrorThemePhrases.aspectHint(primaryThemeId, domain.aspectKey),
    ].where((s) => s.trim().isNotEmpty).toList();

    final currentIdx =
        (seed.abs() + domain.index * 3) % currentVariants.length;
    var currentState = currentVariants[currentIdx];

    var whyItAppears = switch (domain) {
      ThaiBetaLifeDomain.work =>
        'ในงาน คุณมัก${primary.headlinePart} — ${life.work}',
      ThaiBetaLifeDomain.money =>
        'เรื่องเงิน คุณมัก${primary.headlinePart} — ${life.money}',
      ThaiBetaLifeDomain.love =>
        'ในความสัมพันธ์ คุณมัก${primary.headlinePart} — ${life.love}',
      ThaiBetaLifeDomain.health =>
        'ด้านพลังใจ คุณมัก${primary.headlinePart} — ${life.health}',
      ThaiBetaLifeDomain.luck =>
        'เรื่องโอกาส คุณมัก${primary.headlinePart} — ${life.luck}',
    };

    if (secondaryPhrase != null && secondaryFacet != null) {
      whyItAppears =
          '$whyItAppears แต่เมื่อต้องตัดสินใจ คุณยัง${secondaryPhrase.headlinePart}ด้วย';
    }

    final advicePool = ThaiMirrorThemeVariants.adviceVariants(primaryThemeId)
        .where((a) => isTextDomainCompatible(a, domain))
        .toList();

    var suggestedAction = domainAdviceFallback(domain, primaryThemeId);
    if (advicePool.isNotEmpty) {
      final actionStart = (seed.abs() + domain.index * 5) % advicePool.length;
      for (var k = 0; k < advicePool.length; k++) {
        final cand = advicePool[(actionStart + k) % advicePool.length];
        if (usedActions.contains(cand)) continue;
        if (!isTextDomainCompatible(cand, domain)) continue;
        suggestedAction = cand;
        break;
      }
    }

    return (
      currentState: currentState,
      whyItAppears: whyItAppears,
      suggestedAction: suggestedAction,
      primaryThemeId: primaryThemeId,
      secondaryThemeId: secondaryThemeId,
    );
  }

  /// Domain-safe advice when no compatible theme variant exists.
  static String domainAdviceFallback(
    ThaiBetaLifeDomain domain,
    String primaryThemeId,
  ) {
    final hint = _lifeHintText(primaryThemeId, domain).trim();
    if (hint.length > 8) {
      return 'ลอง$hint';
    }
    return 'ลองปรับทีละขั้นในด้าน${domain.labelTh}';
  }

  /// Domain-safe why copy from existing life hints.
  static String domainWhyFallback({
    required ThaiBetaLifeDomain domain,
    required String primaryThemeId,
    String? secondaryThemeId,
  }) {
    final primary = ThaiMirrorThemePhrases.phrase(primaryThemeId);
    final life = ThaiMirrorThemeLifeHints.forTheme(primaryThemeId);
    var why = switch (domain) {
      ThaiBetaLifeDomain.work =>
        'ในงาน คุณมัก${primary.headlinePart} — ${life.work}',
      ThaiBetaLifeDomain.money =>
        'เรื่องเงิน คุณมัก${primary.headlinePart} — ${life.money}',
      ThaiBetaLifeDomain.love =>
        'ในความสัมพันธ์ คุณมัก${primary.headlinePart} — ${life.love}',
      ThaiBetaLifeDomain.health =>
        'ด้านพลังใจ คุณมัก${primary.headlinePart} — ${life.health}',
      ThaiBetaLifeDomain.luck =>
        'เรื่องโอกาส คุณมัก${primary.headlinePart} — ${life.luck}',
    };
    if (secondaryThemeId != null && secondaryThemeId != primaryThemeId) {
      final secondary = ThaiMirrorThemePhrases.phrase(secondaryThemeId);
      why =
          '$why แต่เมื่อต้องตัดสินใจ คุณยัง${secondary.headlinePart}ด้วย';
    }
    return why;
  }

  /// Checks whether [text] aligns with domain semantic topics.
  static bool isTextDomainCompatible(String text, ThaiBetaLifeDomain domain) {
    final stripped = _stripPresentationPrefixes(text);
    if (stripped.length < 6) return false;

    // Life-hint overlap from theme metadata (not label prefixes).
    for (final themeId in ThaiMirrorThemeLifeHints.hints.keys) {
      final hint = _lifeHintText(themeId, domain).trim();
      if (hint.length > 12 &&
          _containsMeaningfulOverlap(stripped, hint, minChars: 10)) {
        return true;
      }
      final aspectHint =
          ThaiMirrorThemePhrases.aspectHint(themeId, domain.aspectKey).trim();
      if (aspectHint.length > 12 &&
          _containsMeaningfulOverlap(stripped, aspectHint, minChars: 10)) {
        return true;
      }
    }

    final normalized = stripped.toLowerCase();
    final markers = _domainTextMarkers[domain] ?? const {};
    return markers.any((marker) {
      final markerNorm = marker.toLowerCase();
      // Ignore markers that only appear inside stripped presentation labels.
      return normalized.contains(markerNorm) &&
          !_markerOnlyFromPrefix(text, markerNorm, domain);
    });
  }

  static bool isThemeDomainCompatible(String themeId, ThaiBetaLifeDomain domain) {
    final minScore = domain == ThaiBetaLifeDomain.health ||
            domain == ThaiBetaLifeDomain.luck
        ? 1
        : 2;
    return compatibilityScore(themeId, domain) >= minScore;
  }

  static String _stripPresentationPrefixes(String text) {
    var stripped = text.trim();
    for (final domain in ThaiBetaLifeDomain.values) {
      for (final prefix in _presentationPrefixes(domain)) {
        if (stripped.startsWith(prefix)) {
          stripped = stripped.substring(prefix.length).trim();
          if (stripped.startsWith('—')) {
            stripped = stripped.substring(1).trim();
          }
        }
        stripped = stripped.replaceAll(prefix, '');
      }
    }
    stripped = stripped.replaceAll(
      RegExp(r'^(ในงาน|เรื่องเงิน|ในความสัมพันธ์|ด้านพลังใจ|เรื่องโอกาส)\s*'),
      '',
    );
    stripped = stripped.replaceAll(
      RegExp(r'^คุณมัก[^—\n]*—\s*'),
      '',
    );
    return stripped.trim();
  }

  static List<String> _presentationPrefixes(ThaiBetaLifeDomain domain) {
    return [
      domain.narrativeSectionLabel,
      'ชีวิตด้าน${domain.labelTh}',
      'ด้าน${domain.labelTh}',
      'ในด้าน${domain.labelTh}',
    ];
  }

  static bool _containsMeaningfulOverlap(
    String text,
    String reference, {
    required int minChars,
  }) {
    final sample = reference.length >= minChars
        ? reference.substring(0, minChars)
        : reference;
    return text.contains(sample);
  }

  static bool _markerOnlyFromPrefix(
    String original,
    String marker,
    ThaiBetaLifeDomain domain,
  ) {
    final originalNorm = original.toLowerCase();
    if (!originalNorm.contains(marker)) return false;
    final strippedNorm = _stripPresentationPrefixes(original).toLowerCase();
    return !strippedNorm.contains(marker);
  }

  static ThaiBetaLifeDomain? domainForNarrativeLabel(String label) {
    final trimmed = label.trim();
    for (final domain in ThaiBetaLifeDomain.values) {
      if (trimmed == domain.narrativeSectionLabel) return domain;
    }
    if (trimmed.contains('การงาน')) return ThaiBetaLifeDomain.work;
    if (trimmed.contains('การเงิน')) return ThaiBetaLifeDomain.money;
    if (trimmed.contains('ความรัก')) return ThaiBetaLifeDomain.love;
    if (trimmed.contains('สุขภาพ') || trimmed.contains('พลังใจ')) {
      return ThaiBetaLifeDomain.health;
    }
    if (trimmed.contains('โอกาส') || trimmed.contains('จังหวะ')) {
      return ThaiBetaLifeDomain.luck;
    }
    return null;
  }

  static const _domainTextMarkers = <ThaiBetaLifeDomain, Set<String>>{
    ThaiBetaLifeDomain.work: {
      'งาน',
      'ทำงาน',
      'ทีม',
      'เป้าหมาย',
      'ลงมือ',
      'นำ',
      'ความรับผิดชอบ',
      'แรงกดดัน',
    },
    ThaiBetaLifeDomain.money: {
      'เงิน',
      'ใช้จ่าย',
      'ออม',
      'ลงทุน',
      'ความมั่นคง',
      'ความเสี่ยง',
      'คุ้มค่า',
    },
    ThaiBetaLifeDomain.love: {
      'ความรัก',
      'ความสัมพันธ์',
      'คู่',
      'ใกล้ชิด',
      'ไว้ใจ',
      'เปิดใจ',
      'พื้นที่ส่วนตัว',
    },
    ThaiBetaLifeDomain.health: {
      'สุขภาพ',
      'พลัง',
      'พัก',
      'เครียด',
      'ร่างกาย',
      'ฟื้น',
      'สมดุล',
      'เหนื่อย',
    },
    ThaiBetaLifeDomain.luck: {
      'โอกาส',
      'จังหวะ',
      'ลงมือ',
      'ปรับตัว',
      'เสี่ยง',
      'ลอง',
      'ต่อยอด',
    },
  };
}
