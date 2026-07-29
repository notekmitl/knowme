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

class ThaiBirthProfileCoreSection {
  const ThaiBirthProfileCoreSection({
    required this.title,
    required this.paragraphs,
    required this.evidenceKeys,
    this.isMethodology = false,
  });

  final String title;
  final List<String> paragraphs;

  /// Internal trace only. Never rendered or exported.
  final List<String> evidenceKeys;
  final bool isMethodology;

  List<String> get publicParagraphs => paragraphs;
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

    final usedClaims = <String>{};
    List<String> claims(Iterable<String> candidates) {
      final result = <String>[];
      for (final candidate in candidates) {
        final value = _lifelong(candidate);
        final key = _claimKey(value);
        if (value.isEmpty || key.isEmpty || !usedClaims.add(key)) continue;
        result.add(value);
      }
      return result;
    }

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
      String trailing = '',
    }) {
      final narrative = domain(marker);
      final dash = dashboard(marker);
      final paragraphs = claims([
        if (narrative != null) narrative.overview,
        if (narrative != null) narrative.tension,
        if (narrative != null) narrative.pullQuote,
        if (narrative != null) narrative.whyItAppears,
        if (narrative != null) narrative.advice,
        if (narrative == null && dash != null) dash.currentState,
        if (narrative == null && dash != null) dash.whyItAppears,
        if (narrative == null && dash != null) dash.suggestedAction,
        trailing,
      ]);
      return ThaiBirthProfileCoreSection(
        title: title,
        paragraphs: paragraphs,
        evidenceKeys: [evidence, ...themeIds.take(3).map((id) => 'theme:$id')],
      );
    }

    final summary = claims([
      themeSummary,
      view.signatureInsight.body,
      view.hero.summary,
      cardBody(view.strengths),
      cardBody(view.cautions),
      ...view.reflectionSummary.points.take(2),
      view.advice.body,
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
        paragraphs: summary,
        evidenceKeys: [
          'mirror:identity',
          'mirror:top_themes',
          ...themeIds.take(3).map((id) => 'theme:$id'),
        ],
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.workTitle,
        marker: 'งาน',
        evidence: 'mirror:work_and_ambition',
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.moneyTitle,
        marker: 'เงิน',
        evidence: 'mirror:money',
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.relationshipsTitle,
        marker: 'รัก',
        evidence: 'mirror:relationships',
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.wellbeingTitle,
        marker: 'สุขภาพ',
        evidence: 'mirror:wellbeing',
        trailing: medicalDisclaimer,
      ),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.closingTitle,
        paragraphs: claims([
          ...view.reflectionSummary.points.skip(2),
          view.advice.body,
          cardBody(view.strengths, index: 1),
        ]).take(3).toList(growable: false),
        evidenceKeys: [
          'mirror:reflection',
          ...themeIds.take(3).map((id) => 'theme:$id'),
        ],
      ),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.methodologyTitle,
        paragraphs: structure,
        evidenceKeys: const [
          'normalized:astrological_date',
          'normalized:sunrise',
          'profile:lagna',
          'mirror:top_themes',
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

  static String _plain(String value) =>
      value.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _claimKey(String value) => _plain(
    value,
  ).replaceAll(RegExp(r'[\s·•:;,.!?()\-–—]+'), '').toLowerCase();

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
