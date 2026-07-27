import 'package:knowme/features/astrology/thai/core/life_period/life_period_engine.dart';
import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_birth_data.dart';

import 'thai_detailed_evidence_builder.dart';
import 'thai_detailed_report_model.dart';
import 'thai_detected_event.dart';
import 'thai_evidence_item.dart';
import 'thai_v135_labels.dart';

/// Maps V1.3.5 evidence → Thai prose. Never invents facts without evidence IDs.
abstract final class ThaiDetailedReportComposer {
  static ThaiDetailedReportModel compose({
    required ThaiBirthData birthData,
    required ThaiAstrologyProfile profile,
    required LifeTimeline timeline,
    required DateTime asOfLocal,
    required int profileSeed,
    List<String> orderedThemeIds = const [],
  }) {
    final bundle = ThaiDetailedEvidenceBuilder.build(
      birthData: birthData,
      profile: profile,
      timeline: timeline,
      asOfLocal: asOfLocal,
      profileSeed: profileSeed,
      orderedThemeIds: orderedThemeIds,
    );

    final lifetime = _lifetimeTopics(bundle, profile, timeline);
    final past = <ThaiPeriodReading>[];
    final future = <ThaiPeriodReading>[];
    for (final p in timeline.periods) {
      if (p.isCurrent) continue;
      final reading = _periodReading(p, bundle);
      if (p.isPast) {
        past.add(reading);
      } else {
        future.add(reading);
      }
    }

    final current = _currentReading(timeline, bundle);
    final closing = _closingAdvice(bundle, timeline);

    return ThaiDetailedReportModel(
      lifetimeTopics: lifetime,
      pastPeriods: past,
      currentReading: current,
      futurePeriods: future,
      closingAdvice: closing,
      allEvidence: bundle.items,
      allEvents: bundle.events,
    );
  }

  static ThaiMirrorDetailedReportState toViewState(ThaiDetailedReportModel m) {
    return ThaiMirrorDetailedReportState(
      lifetimeTopics: [
        for (final t in m.lifetimeTopics)
          ThaiMirrorTopicBlockState(
            title: t.title,
            evidenceFound: t.evidenceFound,
            prediction: t.prediction,
          ),
      ],
      pastPeriods: [
        for (final p in m.pastPeriods)
          ThaiMirrorPeriodDetailState(
            ageLabel: p.ageLabel,
            phaseName: p.phaseName,
            planetLine: p.planetLine,
            evidenceFound: p.evidenceFound,
            prediction: p.prediction,
            eventLines: [
              for (final e in p.events)
                e.conflictNote.isEmpty
                    ? e.body
                    : '${e.body}\n${e.conflictNote}',
            ],
          ),
      ],
      currentReading: ThaiMirrorCurrentDetailState(
        evidenceFound: m.currentReading.evidenceFound,
        prediction: m.currentReading.prediction,
        conflictNote: m.currentReading.conflictNote,
      ),
      futurePeriods: [
        for (final p in m.futurePeriods)
          ThaiMirrorPeriodDetailState(
            ageLabel: p.ageLabel,
            phaseName: p.phaseName,
            planetLine: p.planetLine,
            evidenceFound: p.evidenceFound,
            prediction: p.prediction,
            eventLines: [
              for (final e in p.events)
                e.conflictNote.isEmpty
                    ? e.body
                    : '${e.body}\n${e.conflictNote}',
            ],
          ),
      ],
      closingAdvice: ThaiMirrorClosingAdviceState(
        recommendations: m.closingAdvice.recommendations,
        cautions: m.closingAdvice.cautions,
        healthDisclaimer: m.closingAdvice.healthDisclaimer,
      ),
    );
  }

  static List<ThaiTopicReading> _lifetimeTopics(
    ThaiDetailedEvidenceBundle bundle,
    ThaiAstrologyProfile profile,
    LifeTimeline timeline,
  ) {
    ThaiTopicReading build(
      String id,
      String title,
      ThaiEvidenceTopic topic,
      String predictionFallback,
    ) {
      final related = bundle.items.where((e) => e.topic == topic).toList();
      final natal = bundle.items
          .where(
            (e) =>
                e.category == ThaiEvidenceCategory.natalFoundation ||
                e.category == ThaiEvidenceCategory.houseFrame,
          )
          .toList();
      final ids = <String>{
        for (final e in related) e.evidenceId,
        if (related.isEmpty)
          for (final e in natal.take(2)) e.evidenceId,
      }.toList();
      final facts = <String>[
        for (final e in related) ...e.facts,
        if (related.isEmpty)
          for (final e in natal.take(2)) ...e.facts,
      ];
      final evidenceFound = facts.isEmpty
          ? 'ยังไม่มีหลักฐานโครงสร้างที่เด่นสำหรับหัวข้อนี้จากเครื่องคำนวณปัจจุบัน'
          : facts.take(4).join('\n');
      final prediction = facts.isEmpty
          ? predictionFallback
          : _predictionForTopic(id, facts, profile, timeline);
      return ThaiTopicReading(
        topicId: id,
        title: title,
        evidenceFound: evidenceFound,
        prediction: prediction,
        evidenceIds: ids,
      );
    }

    return [
      build(
        'overview',
        'ภาพรวมชีวิต',
        ThaiEvidenceTopic.overview,
        'เส้นทางชีวิตแบ่งเป็นช่วงตามดาวเสวยอายุจากหลักฐานที่มี',
      ),
      build(
        'personality',
        'บุคลิกและวิธีดำเนินชีวิต',
        ThaiEvidenceTopic.personality,
        'บุคลิกอ่านจากลัคนา/วันโหรเมื่อมีหลักฐาน — ไม่แต่งนิสัยเกินหลักฐาน',
      ),
      build(
        'career',
        'การงาน',
        ThaiEvidenceTopic.career,
        'ทิศทางงานผูกกับเจ้าเรือนที่สิบและคะแนนช่วงอายุเมื่อมีหลักฐาน',
      ),
      build(
        'money',
        'การเงิน',
        ThaiEvidenceTopic.money,
        'แนวโน้มการเงินผูกกับเจ้าเรือนที่สองและคะแนนโครงสร้างเมื่อมีหลักฐาน',
      ),
      build(
        'love',
        'ความรัก',
        ThaiEvidenceTopic.love,
        'แนวโน้มความสัมพันธ์ผูกกับเจ้าเรือนที่เจ็ดและคะแนนโครงสร้างเมื่อมีหลักฐาน',
      ),
      build(
        'health',
        'สุขภาพ',
        ThaiEvidenceTopic.health,
        'แนวโน้มพลังชีวิตเป็นการอ่านจากโครงสร้างดวง ไม่ใช่คำวินิจฉัยทางการแพทย์',
      ),
    ];
  }

  static String _predictionForTopic(
    String id,
    List<String> facts,
    ThaiAstrologyProfile profile,
    LifeTimeline timeline,
  ) {
    final start = LifePlanets.of(timeline.startPlanet);
    return switch (id) {
      'overview' =>
        'จากหลักฐานวันโหรและวงจรดาวเสวยอายุที่เริ่มด้วย${start.thaiName} '
            'ชีวิตเดินเป็นช่วง ๆ ตามความยาวของแต่ละดาว '
            'จังหวะปัจจุบันคือ${LifePlanets.of(timeline.current.planet).phaseName}',
      'personality' => profile.hasBirthTime && profile.lagnaKey != null
          ? 'ลัคนา${ThaiV135Labels.lagna(profile.lagnaKey)}'
              'และเจ้าเรือน${ThaiV135Labels.lord(profile.lagnaLordKey)}'
              'ชี้กรอบบุคลิกและการตั้งรับชีวิต — เป็นแนวโน้มจากดวง ไม่ใช่คำตัดสินนิสัย'
          : 'เมื่อยังไม่มีเวลาเกิดที่ยืนยัน บุคลิกอ่านจากวันโหรและดาวเริ่มต้นวงจรเป็นหลัก',
      'career' =>
        'การงานมีแนวโน้มผูกกับหน้าที่และความรับผิดชอบตามจังหวะดาวเสวยอายุ '
            'โดยเฉพาะเมื่อคะแนนงานในช่วงนั้นเด่น',
      'money' =>
        'การเงินควรแยกรายรับจากงานกับการสะสมระยะยาว '
            'ใช้หลักฐานคะแนนและความยาวช่วงเป็นตัวตั้ง ไม่ชี้นำการเสี่ยงเกินกำลัง',
      'love' =>
        'ความสัมพันธ์มีแนวโน้มขึ้นกับจังหวะดาวและความกลมกลืนกับเจ้าเรือนลัคนา '
            'เมื่อมีหลักฐาน — ไม่แต่งเหตุการณ์เฉพาะบุคคล',
      'health' =>
        'สุขภาพในรายงานนี้หมายถึงพลังชีวิต ภาระ และการพักผ่อนตามจังหวะดวง '
            'ไม่ใช่การวินิจฉัยโรค',
      _ => facts.first,
    };
  }

  static ThaiPeriodReading _periodReading(
    PeriodState p,
    ThaiDetailedEvidenceBundle bundle,
  ) {
    final data = LifePlanets.of(p.planet);
    final ageLabel = '${p.startAge}–${p.endAge}';
    final related = bundle.items
        .where(
          (e) =>
              e.ageOrDateRange == ageLabel ||
              e.evidenceId.contains('.${p.planet.name}.') ||
              e.evidenceId.endsWith('.p${p.index}'),
        )
        .toList();
    final ids = related.map((e) => e.evidenceId).toList();
    final facts = <String>[
      for (final e in related.take(3)) ...e.facts.take(2),
    ];
    final periodEvents = bundle.events.where((e) {
      return e.evidenceIds.any(ids.contains) ||
          e.eventKey.contains('p${p.index}');
    }).toList();

    final eventReadings = <ThaiEventReading>[
      for (final e in periodEvents)
        ThaiEventReading(
          body: _eventBody(e),
          evidenceIds: e.evidenceIds,
          conflictNote: e.conflictGroupId == null
              ? ''
              : _conflictNote(bundle, e.conflictGroupId!),
        ),
    ];

    final evidenceFound = facts.isEmpty
        ? 'ช่วง${data.phaseName} อายุ $ageLabel ภายใต้อิทธิพล${data.thaiName}'
        : facts.take(5).join('\n');

    final prediction = p.isPast
        ? 'ในช่วงนี้จังหวะหลักคือ${data.phaseEssence} '
            'ผลที่สะสมมีแนวโน้มส่งต่อไปยังช่วงถัดไปตามหลักฐานโครงสร้าง'
        : 'ในช่วงที่จะถึง จังหวะ${data.phaseName}มีแนวโน้มเน้น${data.keyword} '
            'แต่ยังเป็นแนวโน้ม ไม่ใช่เหตุการณ์ที่รับประกัน';

    return ThaiPeriodReading(
      periodIndex: p.index,
      ageLabel: ageLabel,
      phaseName: data.phaseName,
      planetLine: 'อิทธิพล${data.thaiName} • ${data.keyword}',
      evidenceFound: evidenceFound,
      prediction: prediction,
      events: eventReadings,
      evidenceIds: ids.isEmpty
          ? ['ev.period.${p.planet.name}.ages']
          : ids,
      isPast: p.isPast,
      isFuture: p.isFuture,
    );
  }

  static String _eventBody(ThaiDetectedEvent e) {
    return switch (e.tense) {
      ThaiEventTense.pastLikely =>
        e.weight >= 70
            ? 'มีเกณฑ์ว่าเคยเผชิญ${e.summaryFact}'
            : 'น่าจะเคยเผชิญ${e.summaryFact}',
      ThaiEventTense.futureLikely =>
        'มีแนวโน้มว่าอาจเจอ${e.summaryFact} แต่ยังไม่ใช่สิ่งที่รับประกัน',
      ThaiEventTense.present => e.summaryFact,
    };
  }

  static String _conflictNote(
    ThaiDetailedEvidenceBundle bundle,
    String groupId,
  ) {
    final items =
        bundle.items.where((e) => e.conflictGroupId == groupId).toList();
    if (items.isEmpty) return '';
    return 'สัญญาณขัดกัน: ${items.first.facts.join(' / ')}';
  }

  static ThaiCurrentReading _currentReading(
    LifeTimeline timeline,
    ThaiDetailedEvidenceBundle bundle,
  ) {
    final cur = timeline.current;
    final data = LifePlanets.of(cur.planet);
    final ageLabel = '${cur.startAge}–${cur.endAge}';
    final periodEv = bundle.items
        .where(
          (e) =>
              e.topic == ThaiEvidenceTopic.periodCurrent ||
              e.evidenceId == 'ev.period.${cur.planet.name}.ages',
        )
        .toList();
    final yearEv = bundle.items
        .where(
          (e) =>
              e.topic == ThaiEvidenceTopic.birthdayYear ||
              e.category == ThaiEvidenceCategory.annualTaksa ||
              e.category == ThaiEvidenceCategory.birthdayYear,
        )
        .toList();
    final conflict = bundle.items
        .where((e) => e.category == ThaiEvidenceCategory.conflict)
        .toList();

    final facts = <String>[
      'ชั้นช่วงอายุ: ${data.phaseName} อายุ $ageLabel '
          '(เหลือประมาณ ${cur.remainingYears} ปี)',
      for (final e in periodEv.take(2)) ...e.facts.take(2),
      'ชั้นปีเกิด: ${bundle.birthdayYear.labelTh}',
      for (final e in yearEv.take(2)) ...e.facts.take(2),
    ];

    final ids = <String>{
      for (final e in [...periodEv, ...yearEv, ...conflict]) e.evidenceId,
    }.toList();

    var conflictNote = '';
    if (conflict.isNotEmpty) {
      conflictNote =
          'เมื่อสัญญาณช่วงอายุกับปีเกิดต่างกัน: ${conflict.first.facts.join(' ')}';
    }

    final prediction = StringBuffer()
      ..writeln(
        'โดยรวมในช่วง${data.phaseName} ชีวิตมีแนวโน้มหมุนรอบ${data.keyword} '
        'ตามดาว${data.thaiName}',
      )
      ..writeln(
        'ในปีเกิดล่าสุด (${bundle.birthdayYear.labelTh}) '
        'ให้อ่านร่วมกับทักษาจรอายุโหร ${timeline.currentAge} '
        'เป็นจังหวะรายปีซ้อนบนช่วงอายุ',
      );
    if (bundle.taksaForCurrentAge != null &&
        !bundle.taksaForCurrentAge!.isTagklang) {
      prediction.writeln(
        'บริวารจรปีนี้คือ${bundle.taksaForCurrentAge!.boriwanLabel} '
        'ซึ่งอาจเน้นเรื่องที่เกี่ยวข้องกับดาวดวงนี้มากกว่าเดือนอื่น '
        'โดยไม่ระบุวันย่อยเกินหลักฐาน',
      );
    }

    return ThaiCurrentReading(
      evidenceFound: facts.join('\n'),
      prediction: prediction.toString().trim(),
      evidenceIds: ids,
      birthdayYearLabel: bundle.birthdayYear.labelTh,
      periodAgeLabel: ageLabel,
      conflictNote: conflictNote,
    );
  }

  static ThaiClosingAdvice _closingAdvice(
    ThaiDetailedEvidenceBundle bundle,
    LifeTimeline timeline,
  ) {
    final cur = LifePlanets.of(timeline.current.planet);
    final ids = bundle.items
        .where(
          (e) =>
              e.topic == ThaiEvidenceTopic.periodCurrent ||
              e.category == ThaiEvidenceCategory.birthdayYear,
        )
        .map((e) => e.evidenceId)
        .take(5)
        .toList();
    return ThaiClosingAdvice(
      recommendations:
          'ใช้จังหวะ${cur.phaseName}จัดลำดับงาน ความสัมพันธ์ และการพัก '
          'ให้สอดคล้องกับหลักฐานช่วงอายุและปีเกิดด้านบน '
          'เลือกทำสิ่งที่วัดผลได้แทนการตัดสินใจจากความกังวลอย่างเดียว',
      cautions:
          'อย่าตีความรายงานนี้เป็นการรับประกันเหตุการณ์เฉพาะ '
          'อย่าใช้เป็นเหตุผลเสี่ยงพนันหรือลงทุนเกินกำลัง '
          'และอย่าละเลยสัญญาณร่างกายเพื่อรอ “จังหวะดวง”',
      healthDisclaimer:
          'ข้อความด้านสุขภาพในรายงานเป็นแนวโน้มตามศาสตร์ความเชื่อ '
          'ไม่ใช่คำบอกจากแพทย์ หากร่างกายส่งสัญญาณผิดปกติควรปรึกษาผู้เชี่ยวชาญ',
      evidenceIds: ids.isEmpty ? ['ev.birthday_year.window'] : ids,
    );
  }
}
