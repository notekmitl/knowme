import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

/// Centralized reader-facing copy for the Core Reading surface and PDF.
class ThaiBirthProfileCoreReadingCopy {
  const ThaiBirthProfileCoreReadingCopy._();

  static const reportTitle = 'ดวงจากวันเกิดของคุณ';
  static const summaryTitle = 'สรุปตัวคุณจากพื้นดวง';
  static const workTitle = 'การงาน';
  static const moneyTitle = 'การเงิน';
  static const relationshipsTitle = 'ความรักและความสัมพันธ์';
  static const wellbeingTitle = 'สุขภาพและพลังชีวิตตามตำรา';
  static const closingTitle = 'สิ่งที่ดวงนี้อยากบอกคุณ';
  static const methodologyTitle = 'ดวงนี้วิเคราะห์จากอะไร';
  static const timelineTransitionTitle = 'จากพื้นดวงสู่จังหวะชีวิต';
  static const medicalDisclaimer =
      'เนื้อหาส่วนนี้เป็นมุมมองตามความเชื่อทางโหราศาสตร์ '
      'ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์';
}

enum ThaiBirthProfileCoreDomain {
  summary,
  work,
  money,
  relationships,
  wellbeing,
  closing,
  methodology,
}

enum ThaiBirthProfileCoreClaimRole {
  fact,
  interpretation,
  synthesis,
  disclosure,
}

/// One reader-facing paragraph with deterministic, internal-only ownership.
class ThaiBirthProfileCoreParagraph {
  const ThaiBirthProfileCoreParagraph({
    required this.text,
    required this.domain,
    required this.role,
    required this.semanticKey,
    required this.evidenceKeys,
  });

  final String text;
  final ThaiBirthProfileCoreDomain domain;
  final ThaiBirthProfileCoreClaimRole role;
  final String semanticKey;

  /// Exact fact/source references used for this paragraph. Never rendered.
  final List<String> evidenceKeys;
}

class ThaiBirthProfileCoreSection {
  const ThaiBirthProfileCoreSection({
    required this.title,
    required this.domain,
    required this.claims,
    this.isMethodology = false,
  });

  final String title;
  final ThaiBirthProfileCoreDomain domain;
  final List<ThaiBirthProfileCoreParagraph> claims;
  final bool isMethodology;

  List<String> get paragraphs =>
      claims.map((claim) => claim.text).toList(growable: false);
  List<String> get publicParagraphs => paragraphs;

  /// Compatibility view for internal diagnostics; ownership lives on claims.
  List<String> get evidenceKeys => {
    for (final claim in claims) ...claim.evidenceKeys,
  }.toList(growable: false);
}

/// Deterministic protection against a fact being restated with light edits.
class ThaiBirthProfileCoreClaimDeduplicator {
  ThaiBirthProfileCoreClaimDeduplicator._();

  static bool isNearDuplicate(
    ThaiBirthProfileCoreParagraph candidate,
    ThaiBirthProfileCoreParagraph existing,
  ) {
    if (candidate.semanticKey == existing.semanticKey) return true;
    final left = _normalize(candidate.text);
    final right = _normalize(existing.text);
    if (left == right) return true;
    if (left.isEmpty || right.isEmpty) return false;
    final leftIsShorter = left.length <= right.length;
    final shorter = leftIsShorter ? left : right;
    final longer = leftIsShorter ? right : left;
    if (longer.contains(shorter) && shorter.length / longer.length >= .9) {
      return true;
    }
    final leftGrams = _grams(left);
    final rightGrams = _grams(right);
    final overlap = leftGrams.intersection(rightGrams).length;
    final union = leftGrams.union(rightGrams).length;
    return union > 0 && overlap / union >= .82;
  }

  static Set<String> _grams(String value) {
    if (value.length < 3) return {value};
    return {
      for (var index = 0; index <= value.length - 3; index++)
        value.substring(index, index + 3),
    };
  }

  static String _normalize(String value) => value
      .replaceAll('**', '')
      .replaceAll(RegExp(r'[\s·•:;,.!?()\-–—]+'), '')
      .toLowerCase();
}

class ThaiBirthProfileCoreDomainPolicy {
  const ThaiBirthProfileCoreDomainPolicy._();

  static bool accepts(
    ThaiBirthProfileCoreDomain domain,
    Iterable<String> evidenceKeys,
  ) {
    final keys = evidenceKeys.toList(growable: false);
    final owners = switch (domain) {
      ThaiBirthProfileCoreDomain.summary => const [
        'mirror:identity',
        'mirror:top_themes',
        'mirror:signature',
        'mirror:hero',
        'mirror:strengths',
        'mirror:cautions',
        'mirror:advice',
        'mirror:reflection',
      ],
      ThaiBirthProfileCoreDomain.work => const ['mirror:work_and_ambition'],
      ThaiBirthProfileCoreDomain.money => const ['mirror:money'],
      ThaiBirthProfileCoreDomain.relationships => const [
        'mirror:relationships',
      ],
      ThaiBirthProfileCoreDomain.wellbeing => const ['mirror:wellbeing'],
      ThaiBirthProfileCoreDomain.closing => const [
        'mirror:reflection',
        'mirror:strengths',
        'mirror:advice',
      ],
      ThaiBirthProfileCoreDomain.methodology => const [
        'normalized:',
        'profile:lagna',
        'mirror:top_themes',
      ],
    };
    return keys.any(
      (key) => owners.any((owner) => key == owner || key.startsWith('$owner:')),
    );
  }
}

class ThaiBirthProfileCoreReading {
  const ThaiBirthProfileCoreReading({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.hasBirthTime,
  });

  static const reportTitle = ThaiBirthProfileCoreReadingCopy.reportTitle;
  static const medicalDisclaimer =
      ThaiBirthProfileCoreReadingCopy.medicalDisclaimer;

  final String title;
  final String subtitle;
  final List<ThaiBirthProfileCoreSection> sections;
  final bool hasBirthTime;

  factory ThaiBirthProfileCoreReading.fromAnalysis(
    ThaiBetaAnalysis analysis, {
    ThaiMirrorConsumerViewState? consumerView,
  }) {
    final view =
        consumerView ?? ThaiBetaNarrativeComposer.narrativeView(analysis);
    final profile = analysis.profile;
    final normalized = analysis.normalizedSnapshot;
    final mirror = analysis.pipelineResult?.mirrorResult;
    final themeIds =
        mirror?.topThemes.map((theme) => theme.themeId).toList() ?? const [];
    final themeLabels = view.hero.tags.isNotEmpty
        ? view.hero.tags
        : (mirror?.topThemes.map((theme) => theme.themeName).toList() ??
              const []);
    final themeSummary = themeLabels.isEmpty
        ? ''
        : 'แกนสำคัญของพื้นดวงนี้เชื่อมโยง '
              '${themeLabels.take(3).join(' · ')} เข้าด้วยกัน';

    String cardBody(ThaiMirrorInsightSectionState section, {int index = 0}) {
      if (section.cards.length <= index) return '';
      return _lifelong(section.cards[index].body);
    }

    final acceptedClaims = <ThaiBirthProfileCoreParagraph>[];

    ThaiBirthProfileCoreParagraph? claim({
      required String text,
      required ThaiBirthProfileCoreDomain domain,
      required ThaiBirthProfileCoreClaimRole role,
      required String semanticKey,
      required List<String> evidenceKeys,
      bool allowTemporal = false,
    }) {
      final value = allowTemporal ? _plain(text) : _lifelong(text);
      if (value.isEmpty) return null;
      final candidate = ThaiBirthProfileCoreParagraph(
        text: value,
        domain: domain,
        role: role,
        semanticKey: semanticKey,
        evidenceKeys: List.unmodifiable(evidenceKeys),
      );
      if (!ThaiBirthProfileCoreDomainPolicy.accepts(domain, evidenceKeys)) {
        throw StateError(
          'Evidence does not belong to ${domain.name}: $semanticKey',
        );
      }
      if (acceptedClaims.any(
        (existing) => ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(
          candidate,
          existing,
        ),
      )) {
        return null;
      }
      acceptedClaims.add(candidate);
      return candidate;
    }

    List<ThaiBirthProfileCoreParagraph> compact(
      Iterable<ThaiBirthProfileCoreParagraph?> values,
    ) => values.whereType<ThaiBirthProfileCoreParagraph>().toList();

    final domains = <String, ThaiMirrorNarrativeSectionState>{
      for (final section in view.narrativeSections) section.label: section,
    };

    ThaiMirrorNarrativeSectionState? domain(String marker) {
      for (final entry in domains.entries) {
        if (entry.key.contains(marker)) return entry.value;
      }
      return null;
    }

    ThaiMirrorLifeDashboardItemState? dashboard(String marker) {
      for (final item in view.lifeDashboard) {
        if (item.label.contains(marker)) return item;
      }
      return null;
    }

    ThaiBirthProfileCoreSection lifeDomain({
      required String title,
      required String marker,
      required String evidence,
      required ThaiBirthProfileCoreDomain domainType,
      String trailing = '',
    }) {
      final narrative = domain(marker);
      final dash = dashboard(marker);
      final domainEvidence = [
        evidence,
        ...themeIds.take(3).map((id) => 'theme:$id'),
      ];
      final overview = narrative?.overview ?? dash?.currentState ?? '';
      final strength = narrative?.pullQuote ?? dash?.whyItAppears ?? '';
      final risk = narrative?.tension ?? '';
      final action = narrative?.advice ?? dash?.suggestedAction ?? '';
      final synthesis = _synthesizeStrengthRiskAction(
        strength: strength,
        risk: risk,
        action: action,
      );
      return ThaiBirthProfileCoreSection(
        title: title,
        domain: domainType,
        claims: compact([
          claim(
            text: overview,
            domain: domainType,
            role: ThaiBirthProfileCoreClaimRole.interpretation,
            semanticKey: '$evidence:overview',
            evidenceKeys: [evidence, '$evidence:overview'],
          ),
          claim(
            text: synthesis,
            domain: domainType,
            role: ThaiBirthProfileCoreClaimRole.synthesis,
            semanticKey: '$evidence:strength-risk-action',
            evidenceKeys: [
              ...domainEvidence,
              if (strength.isNotEmpty) '$evidence:strength',
              if (risk.isNotEmpty) '$evidence:risk',
              if (action.isNotEmpty) '$evidence:action',
            ],
          ),
          if (trailing.isNotEmpty)
            claim(
              text: trailing,
              domain: domainType,
              role: ThaiBirthProfileCoreClaimRole.disclosure,
              semanticKey: '$evidence:disclaimer',
              evidenceKeys: ['$evidence:disclaimer'],
            ),
        ]),
      );
    }

    final summaryEvidence = [
      'mirror:identity',
      'mirror:top_themes',
      ...themeIds.take(3).map((id) => 'theme:$id'),
    ];
    final summaryStrength = cardBody(view.strengths).isNotEmpty
        ? cardBody(view.strengths)
        : (view.reflectionSummary.points.isNotEmpty
              ? view.reflectionSummary.points.first
              : view.signatureInsight.body);
    final summary = compact([
      claim(
        text: themeSummary,
        domain: ThaiBirthProfileCoreDomain.summary,
        role: ThaiBirthProfileCoreClaimRole.fact,
        semanticKey: 'mirror:top_themes:summary',
        evidenceKeys: summaryEvidence,
      ),
      claim(
        text: view.signatureInsight.body,
        domain: ThaiBirthProfileCoreDomain.summary,
        role: ThaiBirthProfileCoreClaimRole.interpretation,
        semanticKey: 'mirror:identity:signature',
        evidenceKeys: ['mirror:identity', 'mirror:signature'],
      ),
      claim(
        text: _synthesizeStrengthRiskAction(
          strength: summaryStrength,
          risk: cardBody(view.cautions),
          action: view.advice.body,
        ),
        domain: ThaiBirthProfileCoreDomain.summary,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'mirror:identity:strength-risk-action',
        evidenceKeys: [
          ...summaryEvidence,
          'mirror:strengths:0',
          'mirror:reflection:0',
          'mirror:cautions:0',
          'mirror:advice',
        ],
      ),
      claim(
        text: cardBody(view.strengths, index: 1),
        domain: ThaiBirthProfileCoreDomain.summary,
        role: ThaiBirthProfileCoreClaimRole.interpretation,
        semanticKey: 'mirror:identity:secondary-strength',
        evidenceKeys: ['mirror:identity', 'mirror:strengths:1'],
      ),
      for (final (index, point) in view.reflectionSummary.points.indexed)
        claim(
          text: point,
          domain: ThaiBirthProfileCoreDomain.summary,
          role: ThaiBirthProfileCoreClaimRole.interpretation,
          semanticKey: 'mirror:reflection:$index',
          evidenceKeys: ['mirror:reflection:$index'],
        ),
      claim(
        text: view.hero.summary,
        domain: ThaiBirthProfileCoreDomain.summary,
        role: ThaiBirthProfileCoreClaimRole.interpretation,
        semanticKey: 'mirror:identity:hero',
        evidenceKeys: ['mirror:identity', 'mirror:hero'],
      ),
    ]).take(4).toList(growable: false);

    final structure = <String>[];
    if (normalized != null) {
      final thaiDay = _thaiWeekday(
        analysis.pipelineResult?.birthData?.thaiWeekdayNumber,
      );
      structure.add(
        'ระบบใช้วัน$thaiDayเป็นวันทางโหราศาสตร์ '
        '(วันที่ ${normalized.thaiAstrologicalDate})',
      );
      if (normalized.sunriseAvailable) {
        structure.add(
          normalized.usedPreviousDay
              ? 'เวลาเกิดอยู่ก่อนพระอาทิตย์ขึ้นเวลา ${normalized.sunrise} '
                    'จึงใช้วันก่อนหน้าตามกฎที่นับวันใหม่เมื่อพระอาทิตย์ขึ้น '
                    'โดยไม่เปลี่ยนวันเกิดตามสูติบัตร'
              : 'เวลาเกิดอยู่หลังพระอาทิตย์ขึ้นเวลา ${normalized.sunrise} '
                    'จึงใช้วันเดียวกับวันเกิดตามสูติบัตร',
        );
      }
    }
    if (analysis.input.hasBirthTime &&
        profile?.lagnaKey != null &&
        profile!.lagnaKey!.isNotEmpty) {
      structure.add(
        'ลัคนาอยู่ที่${_lagnaLabel(profile.lagnaKey!)} '
        'จากเวลาเกิด พิกัดสถานที่เกิด และเขตเวลา',
      );
    } else {
      structure.add(
        'รายงานนี้ไม่มีเวลาเกิด จึงไม่กล่าวถึงลัคนา ภพ '
        'หรือข้อสรุปที่ต้องพึ่งตำแหน่งตามเวลาเกิด',
      );
    }
    if (themeLabels.isNotEmpty) {
      structure.add(
        'การอ่านข้างต้นเรียบเรียงจากแนวโน้มเด่น '
        '${themeLabels.take(3).join(' · ')}',
      );
    }

    final sections = <ThaiBirthProfileCoreSection>[
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.summaryTitle,
        domain: ThaiBirthProfileCoreDomain.summary,
        claims: summary,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.workTitle,
        marker: 'งาน',
        evidence: 'mirror:work_and_ambition',
        domainType: ThaiBirthProfileCoreDomain.work,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.moneyTitle,
        marker: 'เงิน',
        evidence: 'mirror:money',
        domainType: ThaiBirthProfileCoreDomain.money,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.relationshipsTitle,
        marker: 'รัก',
        evidence: 'mirror:relationships',
        domainType: ThaiBirthProfileCoreDomain.relationships,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.wellbeingTitle,
        marker: 'สุขภาพ',
        evidence: 'mirror:wellbeing',
        domainType: ThaiBirthProfileCoreDomain.wellbeing,
        trailing: medicalDisclaimer,
      ),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.closingTitle,
        domain: ThaiBirthProfileCoreDomain.closing,
        claims: compact([
          claim(
            text: _synthesizeStrengthRiskAction(
              strength: cardBody(view.strengths, index: 1),
              risk: view.reflectionSummary.points.length > 2
                  ? view.reflectionSummary.points[2]
                  : '',
              action: view.advice.body,
            ),
            domain: ThaiBirthProfileCoreDomain.closing,
            role: ThaiBirthProfileCoreClaimRole.synthesis,
            semanticKey: 'mirror:reflection:closing',
            evidenceKeys: [
              'mirror:reflection',
              'mirror:strengths:1',
              'mirror:advice',
              ...themeIds.take(3).map((id) => 'theme:$id'),
            ],
          ),
        ]),
      ),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.methodologyTitle,
        domain: ThaiBirthProfileCoreDomain.methodology,
        claims: [
          for (final (index, paragraph) in structure.indexed)
            ThaiBirthProfileCoreParagraph(
              text: paragraph,
              domain: ThaiBirthProfileCoreDomain.methodology,
              role: ThaiBirthProfileCoreClaimRole.disclosure,
              semanticKey: 'methodology:$index',
              evidenceKeys: [
                switch (index) {
                  0 => 'normalized:astrological_date',
                  1 when normalized?.sunriseAvailable == true =>
                    'normalized:sunrise',
                  _ when paragraph.contains('ลัคนา') => 'profile:lagna',
                  _ => 'mirror:top_themes',
                },
              ],
            ),
        ],
        isMethodology: true,
      ),
    ];

    return ThaiBirthProfileCoreReading(
      title: reportTitle,
      subtitle: analysis.input.hasBirthTime
          ? 'คำอ่านพื้นดวงตลอดชีวิตจากวัน เวลา และสถานที่เกิด'
          : 'คำอ่านพื้นดวงจากวันและสถานที่เกิด พร้อมระบุข้อจำกัดเมื่อไม่มีเวลาเกิด',
      sections: sections,
      hasBirthTime: analysis.input.hasBirthTime,
    );
  }

  static String _synthesizeStrengthRiskAction({
    required String strength,
    required String risk,
    required String action,
  }) {
    final safeStrength = _asSynthesisClause(strength);
    final safeRisk = _asSynthesisClause(risk);
    final safeAction = _asSynthesisClause(action);
    if (safeStrength.isEmpty && safeRisk.isEmpty && safeAction.isEmpty) {
      return '';
    }
    return [
      if (safeStrength.isNotEmpty) 'พลังที่ควรนำมาเป็นฐานคือ $safeStrength',
      if (safeRisk.isNotEmpty) 'โดยเฝ้าดูไม่ให้ $safeRisk กลายเป็นแรงกดดัน',
      if (safeAction.isNotEmpty)
        'แล้วเปลี่ยนพลังนั้นเป็นการลงมือด้วยการ $safeAction',
    ].join(' ');
  }

  static String _asSynthesisClause(String value) {
    var clause = _lifelong(value)
        .replaceFirst(
          RegExp(r'^(จุดแข็ง|สิ่งที่ควรระวัง|คำแนะนำ)\s*[:：\-–—]?\s*'),
          '',
        )
        .replaceFirst(RegExp(r'^(คุณ|หลายครั้งคุณ|โดยทั่วไปคุณ)\s*'), '')
        .replaceAll(RegExp(r'[.!?。]+$'), '')
        .trim();
    if (clause.startsWith('ควร')) {
      clause = clause.substring('ควร'.length).trim();
    }
    return clause;
  }

  static String _plain(String value) =>
      value.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _lifelong(String value) {
    final plain = _plain(value);
    const metaValidationMarkers = [
      'อย่าใช้ข้อความนี้แทน',
      'แทนการสังเกตพฤติกรรมจริง',
      'ข้อความนี้เป็นเพียง',
      'ผลนี้เป็นเพียง',
    ];
    if (metaValidationMarkers.any(plain.contains)) return '';
    const temporalMarkers = [
      'อายุ ',
      'ช่วงนี้',
      'ตอนนี้',
      'ช่วงปัจจุบัน',
      'ช่วงถัดไป',
      'ช่วงก่อนหน้า',
      'อนาคต',
      'ปีข้างหน้า',
      'กำลังอยู่',
      'จังหวะปัจจุบัน',
      'เส้นทางชีวิตเดินเป็นช่วง',
    ];
    if (temporalMarkers.any(plain.contains)) return '';
    return plain;
  }

  static String _thaiWeekday(int? number) => switch (number) {
    1 => 'อาทิตย์',
    2 => 'จันทร์',
    3 => 'อังคาร',
    4 => 'พุธ',
    5 => 'พฤหัสบดี',
    6 => 'ศุกร์',
    7 => 'เสาร์',
    _ => 'ที่ระบบคำนวณได้',
  };

  static String _lagnaLabel(String key) => switch (key) {
    'lagna_aries' => 'ราศีเมษ',
    'lagna_taurus' => 'ราศีพฤษภ',
    'lagna_gemini' => 'ราศีเมถุน',
    'lagna_cancer' => 'ราศีกรกฎ',
    'lagna_leo' => 'ราศีสิงห์',
    'lagna_virgo' => 'ราศีกันย์',
    'lagna_libra' => 'ราศีตุล',
    'lagna_scorpio' => 'ราศีพิจิก',
    'lagna_sagittarius' => 'ราศีธนู',
    'lagna_capricorn' => 'ราศีมังกร',
    'lagna_aquarius' => 'ราศีกุมภ์',
    'lagna_pisces' => 'ราศีมีน',
    _ => 'ราศีที่ระบบคำนวณได้',
  };
}
