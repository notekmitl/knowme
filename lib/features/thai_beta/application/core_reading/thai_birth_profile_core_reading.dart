import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

class ThaiBirthProfileCoreSection {
  const ThaiBirthProfileCoreSection({
    required this.title,
    required this.found,
    required this.reading,
    required this.strength,
    required this.caution,
    required this.action,
    required this.evidenceKeys,
  });

  final String title;
  final List<String> found;
  final List<String> reading;
  final String strength;
  final String caution;
  final String action;

  /// Internal trace only. Never rendered or exported.
  final List<String> evidenceKeys;

  List<String> get publicParagraphs => [
    ...found,
    ...reading,
    if (strength.isNotEmpty) 'จุดแข็ง: $strength',
    if (caution.isNotEmpty) 'สิ่งที่ควรระวัง: $caution',
    if (action.isNotEmpty) 'แนวทางใช้ประโยชน์: $action',
  ].where((paragraph) => paragraph.trim().isNotEmpty).toList(growable: false);
}

class ThaiBirthProfileCoreReading {
  const ThaiBirthProfileCoreReading({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.hasBirthTime,
  });

  static const reportTitle = 'ดวงจากวันเกิดของคุณ';
  static const medicalDisclaimer =
      'หัวข้อนี้เป็นมุมมองตามความเชื่อทางโหราศาสตร์ '
      'ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์';

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
    final coreFallback = themeLabels.isEmpty
        ? ''
        : 'พื้นดวงนี้มีแนวโน้มเด่นด้าน ${themeLabels.take(3).join(' · ')}';

    String cardBody(ThaiMirrorInsightSectionState section, {int index = 0}) {
      if (section.cards.length <= index) return '';
      return _plain(section.cards[index].body);
    }

    final primaryStrength = _lifelong(cardBody(view.strengths));
    final primaryCaution = _lifelong(cardBody(view.cautions));
    final secondaryStrength = _lifelong(cardBody(view.strengths, index: 1));
    final advice = _lifelong(view.advice.body);
    final structure = <String>[];

    if (normalized != null) {
      final thaiDay = _thaiWeekday(
        analysis.pipelineResult?.birthData?.thaiWeekdayNumber,
      );
      structure.add(
        'วันทางโหราศาสตร์ที่ใช้คือวัน$thaiDay '
        '(วันที่ ${normalized.thaiAstrologicalDate})',
      );
      if (normalized.sunriseAvailable) {
        structure.add(
          normalized.usedPreviousDay
              ? 'เวลาเกิดอยู่ก่อนพระอาทิตย์ขึ้นเวลา ${normalized.sunrise} '
                    'จึงใช้วันก่อนหน้ากับกฎที่นับวันใหม่เมื่อพระอาทิตย์ขึ้น '
                    'โดยวันเกิดตามสูติบัตรไม่ได้ถูกเปลี่ยน'
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
        'คำนวณจากเวลาเกิด พิกัดของสถานที่เกิด และเขตเวลา',
      );
    } else {
      structure.add(
        'รายงานนี้ไม่มีเวลาเกิด จึงไม่กล่าวถึงลัคนา ภพ '
        'หรือข้อสรุปที่ต้องพึ่งตำแหน่งตามเวลาเกิด',
      );
    }

    if (themeLabels.isNotEmpty) {
      structure.add(
        'แนวโน้มเด่นจากการคำนวณคือ ${themeLabels.take(3).join(' · ')}',
      );
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
      String prefix = '',
    }) {
      final narrative = domain(marker);
      final dash = dashboard(marker);
      return ThaiBirthProfileCoreSection(
        title: title,
        found: [if (dash != null) _lifelong(dash.whyItAppears)],
        reading: [
          if (narrative != null) _lifelong(narrative.overview),
          if (narrative != null && narrative.tension.trim().isNotEmpty)
            _lifelong(narrative.tension),
          if (narrative == null && dash != null) _lifelong(dash.currentState),
          if (prefix.isNotEmpty) prefix,
        ],
        strength: narrative?.pullQuote.isNotEmpty == true
            ? _lifelong(narrative!.pullQuote)
            : (dash == null ? primaryStrength : _lifelong(dash.currentState)),
        caution: narrative?.whyItAppears.isNotEmpty == true
            ? _lifelong(narrative!.whyItAppears)
            : primaryCaution,
        action: narrative?.advice.isNotEmpty == true
            ? _lifelong(narrative!.advice)
            : (dash == null ? advice : _lifelong(dash.suggestedAction)),
        evidenceKeys: [evidence, ...themeIds.take(3).map((id) => 'theme:$id')],
      );
    }

    return ThaiBirthProfileCoreReading(
      title: reportTitle,
      subtitle: analysis.input.hasBirthTime
          ? 'พื้นดวงตลอดชีวิตจากวัน เวลา และสถานที่เกิด'
          : 'พื้นดวงจากวันและสถานที่เกิด พร้อมข้อจำกัดเมื่อไม่มีเวลาเกิด',
      hasBirthTime: analysis.input.hasBirthTime,
      sections: [
        ThaiBirthProfileCoreSection(
          title: 'สรุปดวงสำคัญ',
          found: [
            if (themeLabels.isNotEmpty)
              'แกนหลักที่พบ: ${themeLabels.take(3).join(' · ')}',
          ],
          reading: [
            _lifelong(view.signatureInsight.body, fallback: coreFallback),
            if (view.hero.summary.trim().isNotEmpty)
              _lifelong(view.hero.summary),
          ],
          strength: primaryStrength,
          caution: primaryCaution,
          action: advice,
          evidenceKeys: [
            'mirror:top_themes',
            ...themeIds.take(3).map((id) => 'theme:$id'),
          ],
        ),
        ThaiBirthProfileCoreSection(
          title: 'โครงสร้างดวงหลัก',
          found: structure,
          reading: [
            analysis.input.hasBirthTime
                ? 'เวลาและพิกัดมีผลต่อเส้นแบ่งวันทางโหราศาสตร์และลัคนา '
                      'จึงเป็นส่วนหนึ่งของผล ไม่ใช่ข้อมูลประกอบที่ถูกละไว้'
                : 'ส่วนที่แสดงต่อจากนี้ใช้เฉพาะข้อสรุปที่วันเกิดและสถานที่รองรับ',
          ],
          strength: secondaryStrength,
          caution: analysis.input.hasBirthTime
              ? ''
              : 'ความละเอียดของเรื่องภาพภายนอกและเรือนชีวิตมีข้อจำกัด',
          action:
              'ใช้ข้อมูลโครงสร้างนี้เป็นเหตุผลประกอบการอ่าน '
              'ไม่ใช่คำตัดสินว่าชีวิตต้องเป็นแบบเดียว',
          evidenceKeys: const [
            'normalized:astrological_date',
            'normalized:sunrise',
            'profile:lagna',
          ],
        ),
        ThaiBirthProfileCoreSection(
          title: 'ภาพรวมชีวิต',
          found: [
            if (themeLabels.isNotEmpty)
              'รูปแบบชีวิตเชื่อมจากแนวโน้ม ${themeLabels.take(2).join(' และ ')}',
          ],
          reading: [
            _lifelong(view.hero.summary, fallback: coreFallback),
            if (view.reflectionSummary.points.isNotEmpty)
              _lifelong(view.reflectionSummary.points.first),
          ],
          strength: primaryStrength,
          caution: primaryCaution,
          action: advice,
          evidenceKeys: [
            'mirror:top_themes',
            ...themeIds.take(2).map((id) => 'theme:$id'),
          ],
        ),
        ThaiBirthProfileCoreSection(
          title: 'ตัวตนและนิสัยลึก ๆ',
          found: [
            if (view.hero.tags.isNotEmpty)
              'ภาพที่เด่นจากดวง: ${view.hero.tags.take(3).join(' · ')}',
          ],
          reading: [
            _lifelong(view.signatureInsight.body, fallback: coreFallback),
            if (view.hero.summary.trim().isNotEmpty)
              _lifelong(view.hero.summary),
          ],
          strength: primaryStrength,
          caution: primaryCaution,
          action: advice,
          evidenceKeys: [
            'mirror:identity',
            ...themeIds.take(3).map((id) => 'theme:$id'),
          ],
        ),
        lifeDomain(
          title: 'การงาน',
          marker: 'งาน',
          evidence: 'mirror:work_and_ambition',
        ),
        lifeDomain(title: 'การเงิน', marker: 'เงิน', evidence: 'mirror:money'),
        lifeDomain(
          title: 'ความรักและความสัมพันธ์',
          marker: 'รัก',
          evidence: 'mirror:relationships',
        ),
        lifeDomain(
          title: 'สุขภาพและพลังชีวิตตามตำรา',
          marker: 'สุขภาพ',
          evidence: 'mirror:wellbeing',
          prefix: medicalDisclaimer,
        ),
      ],
    );
  }

  static String _plain(String value) =>
      value.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _lifelong(String value, {String fallback = ''}) {
    final plain = _plain(value);
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
    if (temporalMarkers.any(plain.contains)) return _plain(fallback);
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
