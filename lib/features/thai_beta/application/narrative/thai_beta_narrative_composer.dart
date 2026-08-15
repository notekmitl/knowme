/// Thai Beta Narrative Quality V1.1 + V1.2 — curated block composer.
library;

import 'package:knowme/features/astrology/thai/core/life_period/life_planet.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_context.dart';
import 'thai_beta_report_narrative_plan.dart';
import 'thai_beta_narrative_dedupe.dart';
import 'thai_beta_narrative_domain.dart';
import 'thai_beta_narrative_formatting.dart';
import 'thai_beta_narrative_forbidden.dart';
import 'thai_beta_narrative_hero.dart';
import 'thai_beta_holistic_overview_composer.dart';
import 'thai_beta_narrative_specificity.dart';
import 'thai_beta_narrative_stable_hash.dart';
import 'thai_beta_narrative_trace.dart';
import 'thai_beta_narrative_v12.dart';
import 'thai_beta_past_reflection.dart';

class ThaiBetaNarrativeResult {
  const ThaiBetaNarrativeResult({required this.view, required this.trace});

  final ThaiMirrorConsumerViewState view;
  final ThaiBetaNarrativeTrace trace;
}

/// Deterministic narrative quality layer for Thai Beta screen + export parity.
abstract final class ThaiBetaNarrativeComposer {
  static ThaiBetaNarrativeResult compose(ThaiBetaAnalysis analysis) {
    final source = analysis.consumerViewState;
    if (source == null) {
      return ThaiBetaNarrativeResult(
        view: const ThaiMirrorConsumerViewState(
          hero: ThaiMirrorConsumerHeroState(
            headline: ThaiMirrorConsumerHeroState.fallbackHeadline,
            summary: ThaiMirrorConsumerHeroState.fallbackSummary,
            tags: [],
          ),
          strengths: ThaiMirrorInsightSectionState(title: '', cards: []),
          cautions: ThaiMirrorInsightSectionState(title: '', cards: []),
          advice: ThaiMirrorAdviceState(title: '', body: ''),
          lifeDashboard: [],
          narrativeSections: [],
          signatureInsight: ThaiMirrorSignatureInsightState(
            eyebrow: '',
            body: '',
            signature: '',
          ),
          reflectionSummary: ThaiMirrorReflectionSummaryState(
            title: '',
            intro: '',
            points: [],
          ),
          closingMessage: ThaiMirrorClosingMessageState(
            eyebrow: '',
            message: '',
            signature: '',
          ),
          sourceTransparency: ThaiMirrorSourceTransparencyState(
            dataUsed: '',
            calculation: '',
            meaning: '',
          ),
          birthDataConfidence: ThaiMirrorBirthDataConfidenceState(
            isComplete: false,
            title: '',
            body: '',
          ),
          secretTip: '',
          disclaimers: [],
        ),
        trace: const ThaiBetaNarrativeTrace(),
      );
    }

    final ctx = ThaiBetaNarrativeContext.fromAnalysis(analysis);
    final reportPlan = ThaiBetaReportNarrativePlan.fromPrediction(
      prediction: source.futurePrediction,
      context: ctx,
    );
    final globalUsed = <String>{};
    final usedBlockIds = <String>{};
    var trace = const ThaiBetaNarrativeTrace();

    final cautionBody = source.cautions.cards.isNotEmpty
        ? source.cautions.cards.first.body
        : null;

    final heroResult = ThaiBetaNarrativeHero.compose(
      sourceHero: source.hero,
      orderedThemeIds: ctx.orderedThemeIds,
      profileSeed: ctx.profileSeed,
      hasBirthTime: ctx.hasBirthTime,
      cautionBody: cautionBody,
      lifePeriodLabel: ctx.lifePeriodLabel,
      usedBlockIds: usedBlockIds,
      usedTextKeys: globalUsed,
    );
    for (final entry in heroResult.trace) {
      trace = trace.add(entry);
      if (entry.blockId != null) usedBlockIds.add(entry.blockId!);
    }

    // V1.2: select strength blocks first so Personal Core can lead the report.
    final strengthsResult = _polishStrengths(
      source.strengths,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = strengthsResult.trace;
    final strengthBlocks = strengthsResult.blocks;
    final strengthMatchLevels = strengthsResult.matchLevels;

    final coreResult = _composePersonalCore(
      strengthBlocks: strengthBlocks,
      matchLevels: strengthMatchLevels,
      ctx: ctx,
      globalUsed: globalUsed,
      trace: trace,
      fallback: source.signatureInsight,
    );
    trace = coreResult.trace;

    // V1.3.3: holistic executive overview (natal + life trajectory + current).
    // Replaces personality-only merge of hero + personal core.
    final mergedHero = ThaiBetaHolisticOverviewComposer.compose(
      natalHero: heroResult.hero,
      core: coreResult.insight,
      timeline: source.lifeTimeline,
      hasBirthTime: ctx.hasBirthTime,
      reportPlan: reportPlan,
    );

    final strengths = strengthsResult.section;

    // V1.2: cautions linked from the same curated strength blocks (tension).
    final cautionsResult = _polishLinkedCautions(
      sourceTitles: source.strengths.cards.map((c) => c.title).toList(),
      strengthBlocks: strengthBlocks,
      matchLevels: strengthMatchLevels,
      ctx: ctx,
      globalUsed: globalUsed,
      trace: trace,
    );
    trace = cautionsResult.trace;
    final cautions = cautionsResult.section;

    final lifeDashboardResult = _polishLifeDashboard(
      source.lifeDashboard,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = lifeDashboardResult.trace;
    final narrativeSectionsResult = _polishNarrativeSections(
      source.narrativeSections,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
    );
    trace = narrativeSectionsResult.trace;

    final primaryStrength = strengthBlocks.isNotEmpty
        ? strengthBlocks.first
        : null;
    final adviceResult = _polishAdvice(
      source.advice,
      ctx,
      globalUsed,
      usedBlockIds,
      trace,
      primaryStrength: primaryStrength,
      coreBody: coreResult.insight.body,
    );
    trace = adviceResult.trace;

    // Re-select advice if it conflicts with the personal core paragraph.
    var finalAdvice = adviceResult.advice;
    if (ThaiBetaNarrativeV12.adviceConflictsWithCore(
          adviceText: finalAdvice.body,
          coreBody: coreResult.insight.body,
        ) &&
        primaryStrength != null) {
      final retry = _polishAdvice(
        source.advice,
        ctx,
        globalUsed,
        {...usedBlockIds, adviceResult.adviceBlockId ?? ''},
        trace,
        primaryStrength: primaryStrength,
        coreBody: coreResult.insight.body,
      );
      trace = retry.trace;
      finalAdvice = retry.advice;
    }

    final view = ThaiMirrorConsumerViewState(
      hero: mergedHero,
      strengths: strengths,
      cautions: cautions,
      advice: finalAdvice,
      lifeDashboard: lifeDashboardResult.items,
      narrativeSections: narrativeSectionsResult.sections,
      // V1.3.2: core absorbed into hero — no separate card.
      signatureInsight: const ThaiMirrorSignatureInsightState(
        eyebrow: '',
        body: '',
        signature: '',
      ),
      reflectionSummary: _polishReflection(
        source.reflectionSummary,
        globalUsed,
      ),
      closingMessage: _polishClosing(source.closingMessage, globalUsed),
      sourceTransparency: source.sourceTransparency,
      birthDataConfidence: source.birthDataConfidence,
      secretTip: ThaiBetaNarrativeFormatting.normalize(source.secretTip),
      disclaimers: source.disclaimers
          .map(ThaiBetaNarrativeFormatting.normalize)
          .toList(),
      lifeTimeline: _differentiateTimelineDomains(
        source.lifeTimeline,
        isUnknownTime: reportPlan.isUnknownTime,
      ),
      futurePrediction: _polishPrediction(source.futurePrediction, reportPlan),
    );

    return ThaiBetaNarrativeResult(view: view, trace: trace);
  }

  static ThaiMirrorConsumerViewState narrativeView(ThaiBetaAnalysis analysis) {
    return compose(analysis).view;
  }

  static String? _themeIdForStrengthTitle(
    String title,
    List<String> orderedThemeIds,
    int cardIndex,
  ) {
    final normalizedTitle = ThaiBetaNarrativeFormatting.normalizedKey(title);
    for (final id in orderedThemeIds) {
      final tag = ThaiMirrorThemePhrases.phrase(id).tag;
      if (ThaiBetaNarrativeFormatting.normalizedKey(tag) == normalizedTitle) {
        return id;
      }
    }
    if (cardIndex < orderedThemeIds.length) {
      return orderedThemeIds[cardIndex];
    }
    return orderedThemeIds.isNotEmpty ? orderedThemeIds.first : null;
  }

  /// Differentiates repeated past/future domain paragraphs only on the Thai
  /// Beta presentation copy. Later repetitions retain all four V3 domains and
  /// gain the period's computed change statement instead of invented events.
  /// Current-period content and the source Thai Mirror state remain unchanged.
  static ThaiMirrorLifeTimelineState? _differentiateTimelineDomains(
    ThaiMirrorLifeTimelineState? timeline, {
    required bool isUnknownTime,
  }) {
    if (timeline == null) return null;
    final used = <String>{};
    final usedClaims = <String>[];
    final usedPeriodClaims = <String>[];
    final usedPeriodFragments = <String>{};
    final periods = timeline.periods
        .map((period) {
          if (period.isCurrent) {
            return isUnknownTime
                ? _cautiousUnknownCurrentPeriod(period)
                : period;
          }
          if (period.lifeDomains.isEmpty) return period;
          final bucket = period.isPast ? 'past' : 'future';
          final ages = period.ageLabel.split('–');
          final startAge = int.tryParse(ages.first) ?? 0;
          final endAge = int.tryParse(ages.last) ?? startAge;
          final domains = <ThaiMirrorLifeDomainBlock>[];
          for (final domain in period.lifeDomains) {
            final ageAppropriate = _ageAppropriateDomain(
              period: period,
              domain: domain,
              startAge: startAge,
              endAge: endAge,
            );
            if (ageAppropriate == null) continue;
            final consumerBody = _stripRepeatedMedicalDisclaimer(
              ageAppropriate.body,
            );
            final semanticBody = consumerBody.replaceAll(
              'ใน${period.phaseName}',
              'ในช่วงชีวิตนี้',
            );
            final key =
                '$bucket|${domain.title}|'
                '${ThaiBetaNarrativeFormatting.normalizedKey(semanticBody)}';
            final isSemanticallyNew = usedClaims.every(
              (claim) => !_isSemanticallySimilar(claim, semanticBody),
            );
            if (used.add(key) && isSemanticallyNew) {
              usedClaims.add(semanticBody);
              domains.add(
                ThaiMirrorLifeDomainBlock(
                  title: ageAppropriate.title,
                  body: consumerBody,
                  evidenceKeys: ageAppropriate.evidenceKeys,
                ),
              );
              continue;
            }
            // A prefix/suffix does not make a repeated claim new. Omit it
            // rather than moving a horizon summary into a domain paragraph.
          }
          String allocatePeriodClaim(String value) {
            var claim = value.trim();
            if (period.isCurrent || claim.isEmpty) return claim;
            for (final fragment in const [
              'คุณอยากใกล้ชิด แต่ก็ยังต้องการพื้นที่ส่วนตัว',
              'คุณเริ่มเลือกโอกาสที่สำคัญจริง ๆ แทนการรับทุกอย่าง',
            ]) {
              if (!claim.contains(fragment)) continue;
              if (usedPeriodFragments.contains(fragment)) {
                claim = claim
                    .replaceAll(fragment, '')
                    .replaceAll('และบทเรียนนี้ยังติดตัวไปในช่วงถัดไป', '')
                    .replaceAll(RegExp(r'\s+'), ' ')
                    .trim();
              } else {
                usedPeriodFragments.add(fragment);
              }
            }
            if (claim.isEmpty) return '';
            final isNew = usedPeriodClaims.every(
              (existing) => !_isSemanticallySimilar(existing, claim),
            );
            if (!isNew) return '';
            usedPeriodClaims.add(claim);
            return claim;
          }

          final pastSynthesis = period.isPast
              ? _cautiousPastSynthesis(period)
              : null;
          final allocatedSummary = pastSynthesis != null
              ? pastSynthesis.$1
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.summary);
          final allocatedChange = pastSynthesis != null
              ? pastSynthesis.$2
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.whatChanges);
          final allocatedEasier = pastSynthesis != null
              ? ''
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.easier);
          final allocatedHarder = pastSynthesis != null
              ? ''
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.harder);
          final allocatedComparison = pastSynthesis != null
              ? ''
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.comparison);
          final allocatedEvidence = pastSynthesis != null
              ? ''
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.evidenceLine);
          final allocatedAdvice = pastSynthesis != null
              ? ''
              : startAge >= 69
              ? ''
              : allocatePeriodClaim(period.advice);
          return ThaiMirrorLifePeriodState(
            ageLabel: period.ageLabel,
            phaseName: period.phaseName,
            planetLine: period.planetLine,
            keyword: period.keyword,
            isCurrent: period.isCurrent,
            isPast: period.isPast,
            summary: allocatedSummary,
            whatChanges: allocatedChange,
            easier: allocatedEasier,
            harder: allocatedHarder,
            comparison: allocatedComparison,
            evidenceLine: allocatedEvidence,
            scores: period.scores,
            easeIndex: period.easeIndex,
            accentIndex: period.accentIndex,
            advice: allocatedAdvice,
            stageLabel: period.stageLabel,
            timeBucketLabel: period.timeBucketLabel,
            mahabhutPositionLabel: period.mahabhutPositionLabel,
            mahabhutDescription: period.mahabhutDescription,
            mahabhutKnown: period.mahabhutKnown,
            mahabhutUnknownReason: period.mahabhutUnknownReason,
            mahabhutShownOnReport: period.mahabhutShownOnReport,
            subPeriods: period.subPeriods,
            annualTaksaYears: period.annualTaksaYears,
            // Past content is one reflection per life period. A repeated
            // four-domain template made cautious language feel like asserted
            // biography and hid the period-specific question.
            lifeDomains: period.isPast
                ? const <ThaiMirrorLifeDomainBlock>[]
                : List.unmodifiable(domains),
          );
        })
        .where(_hasConsumerTimelineContent)
        .toList(growable: false);
    return ThaiMirrorLifeTimelineState(
      sectionTitle: timeline.sectionTitle,
      sectionIntro:
          'ดูช่วงที่ผ่านมา ช่วงปัจจุบัน และช่วงข้างหน้า เพื่อเข้าใจจังหวะชีวิตในภาพรวม',
      currentStage: _betaCurrentStage(timeline.currentStage),
      segments: timeline.segments,
      periods: periods,
      currentAnalysis: _betaCurrentAnalysis(timeline.currentAnalysis),
      futurePreview: timeline.futurePreview == null
          ? null
          : ThaiMirrorFuturePreviewState(
              title: timeline.futurePreview!.title,
              intro: 'ดูภาพรวมของช่วงถัดไป เพื่อเตรียมสิ่งสำคัญไว้ล่วงหน้า',
              transitionLabel: timeline.futurePreview!.transitionLabel,
              elementShiftLine: timeline.futurePreview!.elementShiftLine,
              opportunitiesLine: _consumerOpportunityLine(
                timeline.futurePreview!.opportunitiesLine,
              ),
              // The upstream preview exposes only a list of labels here. It
              // does not identify a pressure source, affected domain and
              // decision impact, so consumer output must fail closed.
              challengesLine: '',
            ),
      detailedReport: timeline.detailedReport,
    );
  }

  static (String, String) _cautiousPastSynthesis(
    ThaiMirrorLifePeriodState period,
  ) {
    final ages = period.ageLabel.split('–');
    final startAge = int.tryParse(ages.first) ?? 0;
    final endAge = int.tryParse(ages.last) ?? startAge;
    final reflection = ThaiBetaPastReflectionComposer.compose(
      startAge: startAge,
      endAge: endAge,
      ageLabel: period.ageLabel,
      phaseName: period.phaseName,
      keyword: period.keyword,
    );
    return (reflection.theme, reflection.question);
  }

  static ThaiMirrorLifePeriodState _cautiousUnknownCurrentPeriod(
    ThaiMirrorLifePeriodState period,
  ) => ThaiMirrorLifePeriodState(
    ageLabel: period.ageLabel,
    phaseName: period.phaseName,
    planetLine: period.planetLine,
    keyword: period.keyword,
    isCurrent: period.isCurrent,
    isPast: period.isPast,
    summary: period.summary,
    whatChanges: period.whatChanges,
    easier: period.easier,
    harder: period.harder,
    comparison: period.comparison,
    evidenceLine: period.evidenceLine,
    scores: period.scores,
    easeIndex: period.easeIndex,
    accentIndex: period.accentIndex,
    advice: period.advice,
    stageLabel: period.stageLabel,
    timeBucketLabel: period.timeBucketLabel,
    mahabhutPositionLabel: period.mahabhutPositionLabel,
    mahabhutDescription: period.mahabhutDescription,
    mahabhutKnown: period.mahabhutKnown,
    mahabhutUnknownReason: period.mahabhutUnknownReason,
    mahabhutShownOnReport: period.mahabhutShownOnReport,
    subPeriods: period.subPeriods,
    annualTaksaYears: period.annualTaksaYears,
    lifeDomains: period.lifeDomains
        .map(_cautiousUnknownCurrentDomain)
        .toList(growable: false),
  );

  static ThaiMirrorLifeDomainBlock _cautiousUnknownCurrentDomain(
    ThaiMirrorLifeDomainBlock domain,
  ) {
    var body = domain.body.trim();
    if (domain.title == 'การงาน') {
      body = body
          .replaceFirst(
            'ช่วงนี้งานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป '
                'งานเดิมกำลังเปลี่ยนแปลงไปสู่โจทย์ใหม่',
            'หากช่วงนี้คุณสังเกตว่างานเดิมเริ่มเปลี่ยนไปสู่โจทย์ใหม่',
          )
          .replaceFirst(
            'งานเดิมกำลังเปลี่ยนแปลงไปสู่โจทย์ใหม่',
            'หากงานเดิมเริ่มเปลี่ยนไปสู่โจทย์ใหม่',
          );
    }
    if (domain.title == 'การเงิน') {
      body = body.replaceFirst(
        'แม้รายรับดูดีขึ้น ก็ยังควรกันส่วนหนึ่งไว้ก่อนขยายการใช้',
        'หากรายรับดูดีขึ้น ก็ยังควรกันส่วนหนึ่งไว้ก่อนขยายการใช้',
      );
    }
    if (domain.title == 'สุขภาพ') {
      body = body
          .replaceFirst(
            'ด้านพลังชีวิตคุณมีหน้าที่หลายอย่าง จนแทบไม่มีเวลาพัก',
            'หากช่วงนี้คุณสังเกตว่าหน้าที่หลายอย่างเริ่มเบียดเวลาพัก',
          )
          .replaceFirst(
            'คุณฝืนตัวเองจนสะสมความล้า',
            'หากคุณสังเกตว่าความล้าสะสมหลังการฝืนตารางเดิม',
          );
    }
    return ThaiMirrorLifeDomainBlock(
      title: domain.title,
      body: body,
      evidenceKeys: domain.evidenceKeys,
    );
  }

  static bool _hasConsumerTimelineContent(ThaiMirrorLifePeriodState period) =>
      period.lifeDomains.isNotEmpty ||
      [
        period.summary,
        period.whatChanges,
        period.easier,
        period.harder,
        period.comparison,
        period.evidenceLine,
        period.advice,
      ].any((value) => value.trim().isNotEmpty);

  static String _stripRepeatedMedicalDisclaimer(String body) => body
      .replaceAll(
        ' ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ ไม่ใช่คำวินิจฉัยทางการแพทย์',
        '',
      )
      .replaceAll(
        RegExp(
          r' ข้อความนี้เป็นแนวโน้มตามศาสตร์ความเชื่อ ไม่ใช่คำบอกจากแพทย์(?: หากร่างกายส่งสัญญาณผิดปกติควรปรึกษาผู้เชี่ยวชาญ)?',
        ),
        '',
      );

  static String stagePositionForProgress(double progress) => progress < 0.34
      ? 'ช่วงต้น'
      : progress < 0.67
      ? 'ช่วงกลาง'
      : 'ช่วงปลาย';

  static String stageIntroForProgress({
    required int age,
    required String phase,
    required int remaining,
    required double progress,
  }) {
    final position = stagePositionForProgress(progress);
    final remainingLine = remaining > 0
        ? 'เหลือเวลาอีกราว $remaining ปีก่อนเปลี่ยนผ่าน'
        : 'กำลังเข้าสู่จุดเปลี่ยนไปยังช่วงถัดไป';
    return 'ตอนนี้คุณอายุ $age ปี อยู่$positionของ$phase และ$remainingLine';
  }

  static ThaiMirrorCurrentStageState _betaCurrentStage(
    ThaiMirrorCurrentStageState stage,
  ) => ThaiMirrorCurrentStageState(
    eyebrow: stage.eyebrow,
    currentAge: stage.currentAge,
    ageLabel: stage.ageLabel,
    phaseName: stage.phaseName,
    planetLine: stage.planetLine,
    keyword: stage.keyword,
    yearsRemaining: stage.yearsRemaining,
    progress: stage.progress,
    intro: stageIntroForProgress(
      age: stage.currentAge,
      phase: stage.phaseName,
      remaining: stage.yearsRemaining,
      progress: stage.progress,
    ),
    previousLabel: stage.previousLabel,
    nextLabel: stage.nextLabel,
    accentIndex: stage.accentIndex,
  );

  static ThaiMirrorCurrentAnalysisState? _betaCurrentAnalysis(
    ThaiMirrorCurrentAnalysisState? analysis,
  ) {
    if (analysis == null) return null;
    final stage = analysis.stageLabel.contains('ช่วงต้น')
        ? 'ช่วงต้น'
        : analysis.stageLabel.contains('ช่วงกลาง')
        ? 'ช่วงกลาง'
        : 'ช่วงปลาย';
    return ThaiMirrorCurrentAnalysisState(
      title: analysis.title,
      stageLabel: 'ตอนนี้คุณอยู่$stageของจังหวะนี้',
      dominantInfluences: analysis.dominantInfluences,
      reasons: analysis.reasons,
    );
  }

  static ThaiMirrorLifeDomainBlock? _ageAppropriateDomain({
    required ThaiMirrorLifePeriodState period,
    required ThaiMirrorLifeDomainBlock domain,
    required int startAge,
    required int endAge,
  }) {
    String? body;
    if (endAge <= 10) {
      body = switch (domain.title) {
        'การงาน' =>
          'ใน${period.phaseName} เรื่องการงานหมายถึงการเรียนรู้หน้าที่เล็ก ๆ '
              'การฝึกทักษะ และการได้รับกำลังใจเมื่อพยายาม',
        'การเงิน' =>
          'ใน${period.phaseName} เรื่องการเงินหมายถึงการเข้าใจคุณค่าของสิ่งของ '
              'การแบ่งใช้ การเก็บออม และการตัดสินใจจากทรัพยากรที่มีตามวัย',
        'ความรัก' || 'ความสัมพันธ์' =>
          'ความสัมพันธ์ใน${period.phaseName}หมายถึงความไว้ใจในครอบครัว เพื่อน '
              'และคนใกล้ตัว รวมถึงการเรียนรู้ขอบเขตและการบอกความต้องการของตนเอง',
        'สุขภาพ' =>
          'สุขภาพใน${period.phaseName}หมายถึงการเติบโต การกิน นอน เคลื่อนไหว '
              'และพักให้เป็นเวลาอย่างเหมาะกับวัย',
        _ => null,
      };
    } else if (endAge <= 21) {
      body = switch (domain.title) {
        'การงาน' =>
          'ใน${period.phaseName} การงานหมายถึงการเรียนรู้ให้ลึกขึ้น ทดลองทักษะ '
              'และสังเกตว่าสิ่งใดเหมาะกับทางที่กำลังเลือก',
        'การเงิน' =>
          'ใน${period.phaseName} การเงินหมายถึงการฝึกวางแผนค่าใช้จ่าย '
              'แยกสิ่งจำเป็นจากสิ่งที่อยากได้ และเริ่มรับผิดชอบการตัดสินใจของตนเอง',
        'ความรัก' || 'ความสัมพันธ์' =>
          'ความสัมพันธ์ใน${period.phaseName}เน้นการรู้จักตัวเองผ่านมิตรภาพ '
              'ความไว้ใจ ขอบเขต และการสื่อสารเมื่อความรู้สึกเปลี่ยนไป',
        'สุขภาพ' =>
          'สุขภาพใน${period.phaseName}เกี่ยวกับจังหวะการเติบโต การนอน '
              'การเคลื่อนไหว และการรักษากิจวัตรให้สมดุลกับการเรียนรู้',
        _ => null,
      };
    } else if (startAge < 30) {
      body = switch (domain.title) {
        'การงาน' =>
          'ใน${period.phaseName} เรื่องหน้าที่ค่อย ๆ เปลี่ยนจากการเรียนรู้ '
              'และค้นหาทางของตัวเอง ไปสู่การรับผิดชอบมากขึ้นตามวัย',
        'การเงิน' =>
          'ใน${period.phaseName} เรื่องเงินเริ่มจากการรู้จักจัดสรรสิ่งที่มี '
              'ก่อนค่อย ๆ รับผิดชอบรายรับรายจ่ายของตัวเอง',
        'ความรัก' || 'ความสัมพันธ์' =>
          'ความสัมพันธ์ใน${period.phaseName}เน้นการรู้จักขอบเขต ความไว้ใจ '
              'และการสื่อสารที่ชัดขึ้นตามวัย',
        'สุขภาพ' =>
          'พลังใน${period.phaseName}สัมพันธ์กับการเติบโต การพักผ่อน '
              'และการจัดกิจวัตรให้เหมาะกับสิ่งที่ต้องเรียนรู้และรับผิดชอบ',
        _ => null,
      };
    } else if (startAge >= 69) {
      // The source evidence does not distinguish these late-age domains beyond
      // a period/theme label. Omit them rather than manufacture four generic
      // paragraphs that differ only by the label.
      return null;
    }
    final baseBody = body ?? domain.body;
    return ThaiMirrorLifeDomainBlock(
      title: domain.title,
      body: baseBody,
      evidenceKeys: domain.evidenceKeys,
    );
  }

  static PredictionSectionModel? _polishPrediction(
    PredictionSectionModel? prediction,
    ThaiBetaReportNarrativePlan reportPlan,
  ) {
    if (prediction == null) return null;
    final windows = <PredictionWindowCardModel>[];
    for (var i = 0; i < prediction.windows.length; i++) {
      final window = prediction.windows[i];
      final horizon = switch (i) {
        0 => ForecastHorizon.current,
        1 => ForecastHorizon.next12Months,
        _ => ForecastHorizon.nextLifePeriod,
      };
      final domains = window.domains
          .map((domain) {
            return composeForecastForMaterial(
              title: domain.title,
              windowIndex: i,
              sourceBody: domain.body,
              sourceCaution: domain.caution,
              material: domain.material!,
              reportPlan: reportPlan,
            );
          })
          .where(
            (domain) =>
                domain.body.trim().isNotEmpty ||
                domain.caution.trim().isNotEmpty,
          )
          .toList(growable: false);
      windows.add(
        PredictionWindowCardModel(
          windowLabel: window.windowLabel,
          timeframeLabel: window.timeframeLabel,
          summary: reportPlan.summaryFor(horizon),
          topOpportunity: _dedupeOpportunity(
            window.summary,
            window.topOpportunity,
          ),
          topRisk: _specificTopRisk(window.topRisk),
          confidenceLabel: switch (window.confidenceLevel) {
            _ when i == 0 => 'เทียบคำอ่านช่วงปัจจุบันกับชีวิตจริงของคุณ',
            _ when i == 1 => 'ใช้กรอบ 12 เดือนนี้วางแผนและทบทวนระหว่างทาง',
            _ => 'ใช้ช่วงถัดไปเตรียมตัว โดยไม่ถือว่าเหตุการณ์ถูกกำหนดไว้แล้ว',
          },
          confidenceLevel: window.confidenceLevel,
          // Domain paragraphs already contain the consumer-facing meaning.
          // Drop diagnostic/meta explanation instead of exposing confidence
          // mechanics or repeating generic pressure language.
          why: '',
          whyNow: '',
          whatToWatch: '',
          evidenceDetail: '',
          domains: domains,
        ),
      );
    }
    return PredictionSectionModel(
      sectionTitle: prediction.sectionTitle,
      sectionIntro: prediction.sectionIntro,
      windows: List.unmodifiable(windows),
      transitionLine: prediction.transitionLine,
      closingAdvice: prediction.closingAdvice,
      detailedSectionIntro: prediction.detailedSectionIntro,
      detailedClosingAdvice: reportPlan.closing,
    );
  }

  static String _forecastClaim(String sourceBody, ForecastDecisionPlan plan) {
    final known =
        plan.evidenceAvailability == ForecastEvidenceAvailability.full;
    final claim = switch ((plan.horizon, plan.domain)) {
      (ForecastHorizon.current, ForecastDomain.career) =>
        known
            ? switch (plan.band) {
                ForecastBand.strong =>
                  'ตอนนี้งานมีแรงส่งให้ขยับ แต่ควรรับเฉพาะบทบาทที่เพิ่มคุณภาพงานหลัก',
                ForecastBand.active =>
                  'ตอนนี้งานยังขยับได้เมื่อเลือกโจทย์ชัด และไม่เปิดหลายบทบาทพร้อมกัน',
                ForecastBand.quiet =>
                  'ตอนนี้งานควรชะลอการขยาย แล้วแก้จุดที่ทำให้งานหลักสะดุดก่อน',
              }
            : 'ตอนนี้ให้ดูภาระงานที่เกิดขึ้นจริง และรักษาคุณภาพของงานหลักก่อนรับหน้าที่เพิ่ม',
      (ForecastHorizon.current, ForecastDomain.finance) =>
        known
            ? switch (plan.band) {
                ForecastBand.strong =>
                  'ตอนนี้การเงินมีพื้นที่ให้ขยับ แต่เงินพร้อมใช้ต้องมาก่อนภาระระยะยาว',
                ForecastBand.active =>
                  'ตอนนี้การเงินยังเดินหน้าได้เมื่อแยกเงินจำเป็นออกจากงบทดลองให้ชัด',
                ForecastBand.quiet =>
                  'ตอนนี้ควรรักษาเงินพร้อมใช้และชะลอภาระก้อนใหม่จนฐานเดิมนิ่งขึ้น',
              }
            : 'ตอนนี้ให้ใช้รายรับ รายจ่าย และยอดคงเหลือจริงเป็นฐานก่อนเพิ่มภาระการเงิน',
      (ForecastHorizon.current, ForecastDomain.relationship) =>
        known
            ? switch (plan.band) {
                ForecastBand.strong =>
                  'ตอนนี้ความสัมพันธ์มีแรงให้ขยับ เมื่อข้อตกลงชัดและทั้งสองฝ่ายทำได้จริง',
                ForecastBand.active =>
                  'ตอนนี้ความสัมพันธ์ต้องการบทสนทนาที่ชัดกว่าการเดาใจ และใช้การกระทำยืนยันคำพูด',
                ForecastBand.quiet =>
                  'ตอนนี้ควรรอความสม่ำเสมอก่อนเพิ่มข้อผูกพันหรือวางแผนร่วมระยะยาว',
              }
            : 'ตอนนี้ให้ดูความสม่ำเสมอของคำพูด การกระทำ และข้อตกลงที่เกิดขึ้นจริง',
      (ForecastHorizon.current, ForecastDomain.health) =>
        known
            ? switch (plan.band) {
                ForecastBand.strong =>
                  'ตอนนี้พลังของคุณรองรับการขยับได้ ตราบใดที่การพักยังคืนแรงทัน',
                ForecastBand.active =>
                  'ตอนนี้กำลังยังพอใช้ แต่ตารางที่แน่นต่อเนื่องจะทำให้เวลาฟื้นยาวขึ้น',
                ForecastBand.quiet =>
                  'ตอนนี้ควรลดกิจกรรมที่กินเวลานอน และคืนจังหวะพักให้สม่ำเสมอก่อน',
              }
            : 'ตอนนี้ให้ติดตามเวลานอน ความล้า และการฟื้นตัวจริงก่อนเพิ่มกิจกรรม',
      (ForecastHorizon.next12Months, ForecastDomain.career) =>
        known
            ? 'ใน 12 เดือน สัญญาณเปลี่ยนของงานคือขอบเขตหน้าที่ที่กว้างขึ้น หากอำนาจตัดสินใจไม่เพิ่มตาม ภาระใหม่จะลดคุณภาพงานหลัก'
            : 'ใน 12 เดือน งานที่ทำซ้ำจนเกิดความชำนาญอาจเปิดหน้าที่ใหม่ ให้ดูว่าผลงานจริงขยายขอบเขตได้ต่อเนื่องหรือไม่',
      (ForecastHorizon.next12Months, ForecastDomain.finance) =>
        known
            ? 'ใน 12 เดือน สัญญาณสำคัญคือรายรับที่เพิ่มแล้วเหลือเป็นเงินพร้อมใช้ หากรายจ่ายประจำโตตามทันที การขยายแผนควรช้าลง'
            : 'ใน 12 เดือน ให้ดูรายรับที่เกิดซ้ำเทียบกับรายจ่ายจำเป็น และไม่ผูกภาระจากเงินที่ยังมาไม่สม่ำเสมอ',
      (ForecastHorizon.next12Months, ForecastDomain.relationship) =>
        known
            ? 'ใน 12 เดือน ความสัมพันธ์จะชัดจากข้อตกลงที่ถูกทำต่อเนื่อง ไม่ใช่จากบทสนทนาครั้งเดียว'
            : 'ใน 12 เดือน ให้ใช้พฤติกรรมที่เกิดซ้ำเป็นสัญญาณ คนที่พร้อมจะรักษาคำพูดในเรื่องเล็กได้สม่ำเสมอ',
      (ForecastHorizon.next12Months, ForecastDomain.health) =>
        known
            ? 'ใน 12 เดือน ให้ดูเวลาฟื้นตัวหลังสัปดาห์หนัก หากต้องใช้วันพักเพิ่มขึ้นเรื่อย ๆ ตารางเดิมกำลังเกินกำลังที่มี'
            : 'ใน 12 เดือน ให้เทียบเดือนที่ภาระเบากับเดือนที่หน้าที่ชนกัน เพื่อดูว่าการนอนและการฟื้นตัวเปลี่ยนอย่างไร',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.career) =>
        known
            ? 'ช่วงชีวิตถัดไป ทิศทางงานจะเปลี่ยนจากการรับเพิ่มไปสู่การคุมคุณภาพ ผลตามมาคือคุณต้องเลือกงานที่ใช้ประสบการณ์สูงและส่งต่องานที่กระจายแรง'
            : 'ช่วงถัดไปให้ใช้รูปแบบงานที่ทำซ้ำได้จริงช่วยเลือกสิ่งที่จะรักษาหรือส่งต่อ',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.finance) =>
        known
            ? 'ช่วงชีวิตถัดไป การเงินจะทำหน้าที่รองรับการเปลี่ยนผ่าน ผลตามมาคือภาระระยะยาวต้องมีเงินสำรองแยกจากค่าใช้จ่ายปกติ'
            : 'ช่วงถัดไป ฐานการเงินจะเปลี่ยนตามหน้าที่ใหม่ ภาระระยะยาวจึงควรเกิดหลังรายรับจริงเริ่มนิ่ง',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.relationship) =>
        known
            ? 'ช่วงชีวิตถัดไป ความสัมพันธ์ต้องปรับตามภาระชุดใหม่ ผลตามมาจะขึ้นอยู่กับความชัดเรื่องเวลา หน้าที่ และพื้นที่ส่วนตัว'
            : 'ช่วงถัดไป ความสัมพันธ์ที่ไปต่อได้ต้องรองรับจังหวะชีวิตใหม่ของทั้งสองฝ่าย ความชัดเรื่องเวลาและหน้าที่จะสำคัญกว่าคำสัญญา',
      (ForecastHorizon.nextLifePeriod, ForecastDomain.health) =>
        known
            ? 'ช่วงชีวิตถัดไป พลังจะขึ้นลงตามภาระชุดใหม่ ผลตามมาคือกิจวัตรพักต้องเปลี่ยนพร้อมตารางงาน ไม่ใช่รอให้ล้าก่อน'
            : 'ช่วงถัดไป พลังอาจเปลี่ยนตามภาระชุดใหม่ จังหวะวันทำงานและวันพักที่คงเส้นคงวาจะสำคัญขึ้น',
    };
    // The source body remains an input to the typed material pipeline, while
    // reader-facing selection is owned by the evidence allocation above.
    assert(sourceBody.isNotEmpty);
    return claim;
  }

  static String _decisionImpact(ForecastDecisionPlan plan) {
    final decisionCore = switch ((plan.band, plan.intent)) {
      (ForecastBand.strong, ForecastDecisionIntent.protectCoreWork) =>
        'รับบทบาทเพิ่มได้หนึ่งก้าวเมื่อคุณภาพงานหลักยังคงเดิม',
      (ForecastBand.active, ForecastDecisionIntent.protectCoreWork) =>
        'ทดลองขอบเขตงานใหม่ก่อนตัดสินใจรับบทบาทเต็มตัว',
      (ForecastBand.quiet, ForecastDecisionIntent.protectCoreWork) =>
        'หยุดเพิ่มงานและคืนเวลาให้งานหลักก่อน',
      (ForecastBand.strong, ForecastDecisionIntent.preserveLiquidity) =>
        'ขยับภาระได้เมื่อกันเงินพร้อมใช้ไว้ครบแล้ว',
      (ForecastBand.active, ForecastDecisionIntent.preserveLiquidity) =>
        'พิสูจน์กระแสเงินจริงในวงเล็กก่อนเพิ่มภาระ',
      (ForecastBand.quiet, ForecastDecisionIntent.preserveLiquidity) =>
        'ชะลอรายจ่ายก้อนใหม่และรักษาเงินพร้อมใช้',
      (ForecastBand.strong, ForecastDecisionIntent.clarifyCommitment) =>
        'เพิ่มข้อผูกพันได้เมื่อคำพูดและการกระทำสอดคล้องกัน',
      (ForecastBand.active, ForecastDecisionIntent.clarifyCommitment) =>
        'ทดลองข้อตกลงเล็กและดูความสม่ำเสมอก่อนผูกพันเพิ่ม',
      (ForecastBand.quiet, ForecastDecisionIntent.clarifyCommitment) =>
        'รอความชัดของเงื่อนไขก่อนเพิ่มข้อผูกพัน',
      (ForecastBand.strong, ForecastDecisionIntent.preserveRecovery) =>
        'เพิ่มกิจกรรมได้เมื่อเวลาพักและการฟื้นตัวยังคงพอ',
      (ForecastBand.active, ForecastDecisionIntent.preserveRecovery) =>
        'ทดลองกิจกรรมทีละขั้นและใช้การฟื้นตัวจริงเป็นเพดาน',
      (ForecastBand.quiet, ForecastDecisionIntent.preserveRecovery) =>
        'ลดกิจกรรมและคืนเวลาฟื้นตัวก่อนรับภาระใหม่',
    };
    final riskConsequence = switch (plan.consumerRiskDomain) {
      LifeDomain.pressure => ' โดยต้องเหลือพื้นที่ให้ภาระหลัก',
      LifeDomain.money => ' โดยไม่ลดเงินที่ต้องพร้อมใช้',
      LifeDomain.love => ' โดยให้ความคาดหวังของทั้งสองฝ่ายตรงกันก่อน',
      LifeDomain.health => ' โดยให้เวลาพักและการฟื้นตัวจริงเป็นเพดาน',
      LifeDomain.career => ' โดยไม่แลกกับคุณภาพงานหลัก',
      _ => '',
    };
    final evidenceBoundary =
        plan.evidenceAvailability == ForecastEvidenceAvailability.noLagna
        ? ' จึงควรยืนยันจากผลที่เกิดซ้ำก่อนตัดสินใจ'
        : '';
    final transitionBoundary = plan.spansTransition
        ? ' และกันแรงไว้สำหรับรอยต่อของช่วงชีวิต'
        : '';
    return '$decisionCore$riskConsequence$evidenceBoundary$transitionBoundary';
  }

  static String _riskSignal(String caution, {LifeDomain? riskDomain}) {
    final risk = caution
        .replaceAll(' โดยเฉพาะเรื่องแรงกดดัน', '')
        .replaceAll(RegExp(r'\s*ข้อความนี้ไม่ใช่คำวินิจฉัยทางการแพทย์.*$'), '')
        .trim();
    final base = risk.contains('แรงกดดัน') && risk.length < 40 ? '' : risk;
    return switch (riskDomain) {
      LifeDomain.love => 'ความคาดหวังในความสัมพันธ์อาจยังไม่ตรงกัน',
      LifeDomain.money => 'ภาระเงินอาจลดพื้นที่ตัดสินใจในด้านนี้',
      LifeDomain.health => 'การพักไม่พออาจลดกำลังสำหรับด้านนี้',
      LifeDomain.career => 'งานหลักอาจถูกภาระด้านนี้เบียดเวลา',
      _ => base,
    };
  }

  static String _specificTopRisk(String risk) {
    final value = _riskSignal(risk);
    return value.contains('แรงกดดัน') ? '' : value;
  }

  static bool _isSemanticallySimilar(String left, String right) {
    final a = ThaiBetaNarrativeFormatting.normalizedKey(left);
    final b = ThaiBetaNarrativeFormatting.normalizedKey(right);
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b || a.contains(b) || b.contains(a)) return true;
    Set<String> grams(String value) {
      if (value.length < 3) return {value};
      return {
        for (var i = 0; i <= value.length - 3; i++) value.substring(i, i + 3),
      };
    }

    final ag = grams(a);
    final bg = grams(b);
    final overlap = ag.intersection(bg).length;
    final union = ag.union(bg).length;
    return union > 0 && overlap / union >= 0.72;
  }

  /// Production path shared by report composition and controlled mutations.
  static PredictionDomainModel composeForecastForMaterial({
    required String title,
    required int windowIndex,
    required String sourceBody,
    required String sourceCaution,
    required ForecastMaterialFingerprint material,
    ForecastDecisionIntent? decisionIntent,
    ThaiBetaReportNarrativePlan? reportPlan,
  }) {
    final plan = ForecastDecisionPlan.fromMaterial(
      material,
      intent: decisionIntent,
    );
    final claim = _forecastClaim(sourceBody, plan);
    final risk = _riskSignal(
      sourceCaution,
      riskDomain: plan.consumerRiskDomain,
    );
    final decisionImpact = _decisionImpact(plan);
    final action = _naturalActionForPlan(plan);
    final disclosure = reportPlan?.evidenceBoundary ?? '';
    final body = _naturalForecastBody(
      plan,
      claim,
      action,
      reportPlan: reportPlan,
    );
    return PredictionDomainModel(
      title: title,
      body: body,
      caution: '',
      claim: claim,
      risk: risk,
      decisionImpact: decisionImpact,
      preparationAction: action,
      uncertaintyDisclosure: disclosure,
      material: material,
      decisionPlan: plan,
    );
  }

  static String _naturalForecastBody(
    ForecastDecisionPlan plan,
    String claim,
    String action, {
    ThaiBetaReportNarrativePlan? reportPlan,
  }) {
    final role =
        reportPlan?.roleFor(plan.domain) ?? ThaiBetaReportMotifRole.supporting;
    final context = reportPlan?.supportingContext(plan.domain, plan.horizon);
    return switch ((plan.horizon, role)) {
      (ForecastHorizon.current, ThaiBetaReportMotifRole.primary) =>
        '$claim\n$action${context == null ? '' : ' $context'}',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.boundary) =>
        '$claim${context == null ? '' : ' $context'}',
      (ForecastHorizon.current, ThaiBetaReportMotifRole.supporting) =>
        '$claim${context == null ? '' : ' $context'}',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.primary) =>
        '$claim $action${context == null ? '' : ' $context'}',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.boundary) =>
        '$claim${context == null ? '' : ' $context'}',
      (ForecastHorizon.next12Months, ThaiBetaReportMotifRole.supporting) =>
        '$claim${context == null ? '' : ' $context'}',
      // The next-life-period job is direction and consequence. Repeating an
      // action here would turn the horizon into another advice template.
      (ForecastHorizon.nextLifePeriod, _) =>
        '$claim${context == null ? '' : ' $context'}',
    };
  }

  static String _naturalActionForPlan(ForecastDecisionPlan plan) {
    final action = switch ((plan.horizon, plan.intent)) {
      (ForecastHorizon.current, ForecastDecisionIntent.protectCoreWork) =>
        'เลือกงานหลักหนึ่งเรื่อง ตั้งเพดานเวลา และปฏิเสธงานใหม่เมื่อเพดานเต็ม',
      (ForecastHorizon.current, ForecastDecisionIntent.preserveLiquidity) =>
        'กันเงินรายจ่ายจำเป็นก่อน แล้วทดลองภาระใหม่ด้วยวงเงินเล็กที่หยุดได้',
      (ForecastHorizon.current, ForecastDecisionIntent.clarifyCommitment) =>
        'พูดเงื่อนไขที่ค้างอยู่ให้จบหนึ่งเรื่อง แล้วดูการตอบสนองก่อนตกลงเพิ่ม',
      (ForecastHorizon.current, ForecastDecisionIntent.preserveRecovery) =>
        'ลดกิจกรรมหนึ่งอย่างในสัปดาห์นี้และคืนเวลานั้นให้การนอน',
      (ForecastHorizon.next12Months, ForecastDecisionIntent.protectCoreWork) =>
        'กำหนดจุดทบทวนกลางปีเพื่อเลือกว่าจะขยายบทบาทเดิมหรือหยุดรับเพิ่ม',
      (
        ForecastHorizon.next12Months,
        ForecastDecisionIntent.preserveLiquidity,
      ) =>
        'บันทึกเงินคงเหลือทุกไตรมาสและขยายแผนต่อเมื่อเงินสำรองไม่ลดลง',
      (
        ForecastHorizon.next12Months,
        ForecastDecisionIntent.clarifyCommitment,
      ) =>
        'ทบทวนข้อตกลงตามพฤติกรรมที่เกิดซ้ำ ไม่เร่งข้อผูกพันจากช่วงที่ราบรื่นครั้งเดียว',
      (ForecastHorizon.next12Months, ForecastDecisionIntent.preserveRecovery) =>
        'จดคุณภาพการนอนหลังสัปดาห์หนัก และลดตารางเดือนถัดไปเมื่อฟื้นไม่ทัน',
      (
        ForecastHorizon.nextLifePeriod,
        ForecastDecisionIntent.protectCoreWork,
      ) =>
        'ทำรายการงานที่จะรักษา ส่งต่อ และยุติให้เสร็จก่อนรับบทบาทก้อนใหม่',
      (
        ForecastHorizon.nextLifePeriod,
        ForecastDecisionIntent.preserveLiquidity,
      ) =>
        'สร้างเงินสำรองเฉพาะช่วงเปลี่ยนผ่านก่อนผูกค่าใช้จ่ายระยะยาวก้อนใหม่',
      (
        ForecastHorizon.nextLifePeriod,
        ForecastDecisionIntent.clarifyCommitment,
      ) =>
        'ตกลงเวลา หน้าที่ และพื้นที่ส่วนตัวของช่วงถัดไปไว้ก่อนตัดสินใจร่วมกัน',
      (
        ForecastHorizon.nextLifePeriod,
        ForecastDecisionIntent.preserveRecovery,
      ) =>
        'ทดลองกิจวัตรพักแบบใหม่ล่วงหน้าและเก็บเฉพาะแบบที่ทำต่อได้ในวันที่ยุ่ง',
    };
    if (plan.evidenceAvailability == ForecastEvidenceAvailability.noLagna) {
      final observationAction = switch ((plan.horizon, plan.intent)) {
        (ForecastHorizon.current, ForecastDecisionIntent.protectCoreWork) =>
          'จดเวลางานจริงหนึ่งสัปดาห์ แล้วคงไว้เฉพาะบทบาทที่ไม่ทำให้งานหลักตก',
        (ForecastHorizon.current, ForecastDecisionIntent.preserveLiquidity) =>
          'ใช้รายรับรายจ่ายจริงหนึ่งรอบเป็นฐาน และเลื่อนรายการที่ยังไม่มีเงินรองรับ',
        (ForecastHorizon.current, ForecastDecisionIntent.clarifyCommitment) =>
          'สังเกตการรักษาคำพูดในเรื่องเล็กก่อนเปิดบทสนทนาเรื่องผูกพัน',
        (ForecastHorizon.current, ForecastDecisionIntent.preserveRecovery) =>
          'บันทึกเวลานอนกับความล้าหนึ่งสัปดาห์ก่อนเปลี่ยนตารางกิจกรรม',
        (
          ForecastHorizon.next12Months,
          ForecastDecisionIntent.protectCoreWork,
        ) =>
          'เก็บหลักฐานผลงานเป็นรอบและค่อยเลือกบทบาทจากแบบที่ทำซ้ำได้',
        (
          ForecastHorizon.next12Months,
          ForecastDecisionIntent.preserveLiquidity,
        ) =>
          'เทียบยอดคงเหลือรายไตรมาส แล้วค่อยขยายแผนจากเงินที่เกิดขึ้นจริง',
        (
          ForecastHorizon.next12Months,
          ForecastDecisionIntent.clarifyCommitment,
        ) =>
          'ใช้ความต่อเนื่องหลายเดือนยืนยันความพร้อม แทนการกำหนดวันผูกพันล่วงหน้า',
        (
          ForecastHorizon.next12Months,
          ForecastDecisionIntent.preserveRecovery,
        ) =>
          'เก็บรูปแบบการฟื้นตัวในเดือนเบาและเดือนหนักก่อนตั้งเป้าระยะยาว',
        (
          ForecastHorizon.nextLifePeriod,
          ForecastDecisionIntent.protectCoreWork,
        ) =>
          'ทดลองส่งต่องานชิ้นเล็กและดูผลก่อนจัดโครงบทบาทของช่วงใหม่',
        (
          ForecastHorizon.nextLifePeriod,
          ForecastDecisionIntent.preserveLiquidity,
        ) =>
          'จำลองค่าใช้จ่ายช่วงเปลี่ยนผ่านจากตัวเลขจริงก่อนผูกภาระก้อนถัดไป',
        (
          ForecastHorizon.nextLifePeriod,
          ForecastDecisionIntent.clarifyCommitment,
        ) =>
          'ทดลองตารางชีวิตร่วมกันระยะสั้นก่อนกำหนดหน้าที่ของช่วงถัดไป',
        (
          ForecastHorizon.nextLifePeriod,
          ForecastDecisionIntent.preserveRecovery,
        ) =>
          'กันเวลาฟื้นตัวไว้ก่อนรับภาระชุดใหม่ และลดสิ่งที่เบียดเวลานอนเป็นอันดับแรก',
      };
      return observationAction;
    }
    return action;
  }

  // Kept temporarily for compatibility comparison in deterministic audits.
  // ignore: unused_element
  static String _forecastActionForPlan(ForecastDecisionPlan plan) {
    final horizonLead = switch (plan.horizon) {
      ForecastHorizon.current => 'ตอนนี้',
      ForecastHorizon.next12Months => 'ตั้งจุดทบทวนภายใน 12 เดือน',
      ForecastHorizon.nextLifePeriod when plan.spansTransition =>
        'ก่อนเข้าสู่ช่วงชีวิตใหม่ ระหว่างรอยต่อนี้',
      ForecastHorizon.nextLifePeriod => 'ก่อนเข้าสู่ช่วงชีวิตใหม่',
    };
    final posture = switch (plan.band) {
      ForecastBand.strong => 'เลือกทำเรื่องสำคัญหนึ่งเรื่องและกำหนดเพดานไว้',
      ForecastBand.active => 'ลองทีละขั้นแล้วดูผลที่เกิดขึ้นจริง',
      ForecastBand.quiet => 'ชะลอเรื่องใหม่และเก็บข้อมูลให้ชัดก่อน',
    };
    final horizonProtocol = switch (plan.horizon) {
      ForecastHorizon.current => 'ลงมือหนึ่งรอบแล้วตรวจผลทันที',
      ForecastHorizon.next12Months =>
        'จดสิ่งที่เกิดขึ้นทุกครั้งที่ทบทวนก่อนรับภาระเพิ่ม',
      ForecastHorizon.nextLifePeriod => 'ลองปรับในวงเล็กก่อนรับภาระก้อนใหญ่',
    };
    final riskResponse = switch (plan.consumerRiskDomain) {
      LifeDomain.pressure => 'ลดภาระทันทีเมื่อภาระเริ่มเกินกำลัง',
      LifeDomain.money => 'หยุดเพิ่มภาระเงินเมื่อความเสี่ยงเริ่มเกิด',
      LifeDomain.love => 'ชะลอข้อตกลงเมื่อความสัมพันธ์ยังไม่ชัด',
      LifeDomain.health => 'ลดกิจกรรมเมื่อการฟื้นตัวไม่พอ',
      LifeDomain.career => 'หยุดรับงานเพิ่มเมื่องานหลักเริ่มถูกเบียด',
      _ => 'ชะลอและทบทวนเมื่อความเสี่ยงนี้เริ่มเกิด',
    };
    final decisionStep = switch (plan.intent) {
      ForecastDecisionIntent.protectCoreWork =>
        'จัดลำดับงานหลักก่อนรับบทบาทเพิ่ม',
      ForecastDecisionIntent.preserveLiquidity =>
        'กันเงินพร้อมใช้ก่อนเพิ่มภาระ',
      ForecastDecisionIntent.clarifyCommitment =>
        'คุยเงื่อนไขให้ชัดก่อนเพิ่มข้อผูกพัน',
      ForecastDecisionIntent.preserveRecovery =>
        'รักษาเวลาฟื้นตัวก่อนเพิ่มกิจกรรม',
    };
    if (plan.evidenceAvailability == ForecastEvidenceAvailability.noLagna) {
      return '$horizonLead บันทึกผลจริงหนึ่งรอบก่อน แล้วค่อย$decisionStep '
          '$horizonProtocol ถ้าข้อมูลยังไม่ชัด ให้ชะลอไว้ก่อนและ$riskResponse';
    }
    return '$horizonLead $decisionStep แล้ว$posture '
        '$horizonProtocol และ$riskResponse';
  }

  // Legacy fallback retained for callers that still construct unpolished cards.
  // ignore: unused_element
  static String _forecastAction(
    String title,
    int windowIndex,
    ForecastMaterialFingerprint material,
  ) {
    final constrained = material.band == ForecastBand.quiet;
    final strong = material.band == ForecastBand.strong;
    if (windowIndex == 0) {
      return switch (title) {
        'การงาน' =>
          constrained
              ? 'ตอนนี้ตัดงานรองหนึ่งเรื่องและกันเวลาแก้ข้อจำกัดของงานหลัก'
              : strong
              ? 'ตอนนี้เลือกงานที่มีโอกาสเห็นผลชัดหนึ่งเรื่องและกำหนดเพดานบทบาทเพิ่ม'
              : 'ตอนนี้เลือกงานหลักหนึ่งเรื่องและกำหนดเพดานงานเพิ่มไม่ให้เกินเวลาที่มี',
        'การเงิน' =>
          constrained
              ? 'ตอนนี้ชะลอรายจ่ายก้อนใหม่และตรวจเงินพร้อมใช้ก่อนตัดสินใจ'
              : strong
              ? 'ตอนนี้กันรายได้ส่วนเพิ่มเป็นเงินสำรองก่อนขยายค่าใช้จ่าย'
              : 'ตอนนี้กันส่วนหนึ่งของเงินเข้าเป็นสำรองก่อนรับรายจ่ายหรือภาระเพิ่ม',
        'ความรัก' =>
          constrained
              ? 'ตอนนี้ถามความคาดหวังที่ยังไม่ได้พูดให้ชัดก่อนเพิ่มข้อผูกพัน'
              : strong
              ? 'ตอนนี้คุยเรื่องค้างคาให้จบและตกลงการกระทำที่ต้องทำต่อเนื่องร่วมกัน'
              : 'ตอนนี้คุยเรื่องที่ค้างคาและเทียบคำพูดกับการกระทำที่เกิดขึ้นจริง',
        'สุขภาพ' =>
          constrained
              ? 'ตอนนี้ลดกิจกรรมที่ไม่จำเป็นและจัดเวลาพักก่อนความล้าเพิ่ม'
              : strong
              ? 'ตอนนี้รักษาเวลานอนและวันพักไว้ก่อนเพิ่มกิจกรรมใหม่'
              : 'ตอนนี้กำหนดเวลานอนและวันพักให้พอกับกิจกรรมที่ทำจริง',
        _ => 'ตอนนี้ทบทวนสิ่งที่เกิดขึ้นจริงก่อนเพิ่มภาระ',
      };
    }
    if (windowIndex == 1) {
      return switch (title) {
        'การงาน' =>
          constrained
              ? 'ตั้งจุดทบทวนใน 12 เดือนเมื่อข้อจำกัดเดิมยังทำให้งานหลักล่าช้า'
              : strong
              ? 'ตั้งหมุดผลลัพธ์ใน 12 เดือนและทบทวนเมื่อบทบาทใหม่ลดคุณภาพงานหลัก'
              : 'ตั้งจุดทบทวนใน 12 เดือนเมื่อภาระใหม่เริ่มเบียดเวลาของงานหลัก',
        'การเงิน' =>
          constrained
              ? 'ตั้งจุดทบทวนใน 12 เดือนเมื่อเงินพร้อมใช้ลดลงหรือรายจ่ายก้อนใหม่เกิดขึ้น'
              : strong
              ? 'ตั้งเป้าเงินสำรองใน 12 เดือนและทบทวนเมื่อรายจ่ายโตเร็วกว่าส่วนเพิ่ม'
              : 'ตั้งจุดทบทวนใน 12 เดือนเมื่อรายจ่ายประจำหรือภาระผูกพันเพิ่มขึ้น',
        'ความรัก' =>
          constrained
              ? 'ตั้งจุดทบทวนใน 12 เดือนเมื่อความคาดหวังยังไม่ถูกพูดให้ชัด'
              : strong
              ? 'ตั้งจุดทบทวนใน 12 เดือนว่าข้อตกลงใหม่ถูกทำต่อเนื่องจริงหรือไม่'
              : 'ตั้งจุดทบทวนใน 12 เดือนเมื่อคำพูดและการกระทำเริ่มไม่สอดคล้องกัน',
        'สุขภาพ' =>
          constrained
              ? 'ตั้งจุดทบทวนใน 12 เดือนเมื่อความล้ายังเกิดซ้ำแม้ลดภาระแล้ว'
              : strong
              ? 'ตั้งจุดทบทวนใน 12 เดือนเมื่อกิจกรรมเพิ่มแต่เวลาฟื้นตัวยังเท่าเดิม'
              : 'ตั้งจุดทบทวนใน 12 เดือนเมื่อเวลาพักไม่พอกับภาระที่เพิ่มขึ้น',
        _ => 'กำหนดจุดทบทวนในกรอบ 12 เดือนจากผลที่เกิดขึ้นจริง',
      };
    }
    return switch (title) {
      'การงาน' =>
        constrained
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมแก้ข้อจำกัดเดิมและกำหนดขอบเขตบทบาทระยะยาว'
            : strong
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมรักษางานที่ให้ผลชัดและวางเพดานบทบาทระยะยาว'
            : 'ก่อนเปลี่ยนช่วงชีวิต เตรียมทักษะและขอบเขตงานที่รองรับบทบาทระยะยาว',
      'การเงิน' =>
        constrained
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมฐานสภาพคล่องก่อนวางภาระผูกพันระยะยาว'
            : strong
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมรักษาส่วนเพิ่มเป็นทุนสำรองสำหรับภาระระยะยาว'
            : 'ก่อนเปลี่ยนช่วงชีวิต เตรียมเงินสำรองและทบทวนภาระผูกพันระยะยาว',
      'ความรัก' =>
        constrained
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมทำความคาดหวังให้ชัดก่อนวางเป้าหมายร่วมระยะยาว'
            : strong
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมเปลี่ยนความชัดที่มีเป็นข้อตกลงร่วมระยะยาว'
            : 'ก่อนเปลี่ยนช่วงชีวิต เตรียมคุยเป้าหมายและขอบเขตร่วมกันในระยะยาว',
      'สุขภาพ' =>
        constrained
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมลดภาระและวางกิจวัตรพักฟื้นระยะยาว'
            : strong
            ? 'ก่อนเปลี่ยนช่วงชีวิต เตรียมรักษากิจวัตรที่รองรับพลังและการฟื้นตัวระยะยาว'
            : 'ก่อนเปลี่ยนช่วงชีวิต เตรียมกิจวัตรพักฟื้นที่ทำต่อเนื่องได้ในระยะยาว',
      _ => 'ก่อนเปลี่ยนช่วงชีวิต เตรียมฐานที่ต้องใช้ต่อเนื่องในระยะยาว',
    };
  }

  static String _consumerOpportunityLine(String value) {
    const allowed = {'การงาน', 'การเงิน', 'ความรัก', 'สุขภาพ', 'การเติบโต'};
    final domains = allowed.where(value.contains).toList(growable: false);
    if (domains.isEmpty) return '';
    return 'ด้านที่มีแรงสนับสนุนในช่วงถัดไป: ${domains.join(' · ')}';
  }

  static String _dedupeOpportunity(String summary, String opportunity) {
    final summaryKey = ThaiBetaNarrativeFormatting.normalizedKey(summary);
    final opportunityKey = ThaiBetaNarrativeFormatting.normalizedKey(
      opportunity,
    );
    const topics = [
      'การงาน',
      'การเงิน',
      'ความรัก',
      'สุขภาพ',
      'การเติบโต',
      'โอกาส',
    ];
    final sameSupportedTopic = topics.any(
      (topic) => summaryKey.contains(topic) && opportunityKey.contains(topic),
    );
    if (sameSupportedTopic) {
      return '';
    }
    return opportunity;
  }

  static ({
    ThaiMirrorInsightSectionState section,
    ThaiBetaNarrativeTrace trace,
    List<CuratedNarrativeBlock> blocks,
    List<int> matchLevels,
  })
  _polishStrengths(
    ThaiMirrorInsightSectionState section,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final cards = <ThaiMirrorInsightCardState>[];
    final blocks = <CuratedNarrativeBlock>[];
    final matchLevels = <int>[];
    final limit = ThaiBetaNarrativeV12.maxLinkedGuidanceCards;
    final cardCount = section.cards.length < limit
        ? section.cards.length
        : limit;

    for (var i = 0; i < cardCount; i++) {
      final card = section.cards[i];
      final title = ThaiBetaNarrativeFormatting.normalize(card.title);
      var body = ThaiBetaNarrativeFormatting.normalize(card.body);

      final themeId = _themeIdForStrengthTitle(title, ctx.orderedThemeIds, i);
      String? expanded;
      if (themeId != null) {
        final selection = ThaiBetaNarrativeSpecificity.selectStrengthExpanded(
          themeId: themeId,
          seed: ctx.profileSeed + i * 31,
          hasBirthTime: ctx.hasBirthTime,
          usedBlockIds: usedBlockIds,
          usedTextKeys: globalUsed,
        );
        usedBlockIds.add(selection.block.id);
        blocks.add(selection.block);
        matchLevels.add(selection.matchLevel);
        trace = trace.add(
          ThaiBetaNarrativeSpecificity.traceEntry(
            sectionId: 'strength_$i',
            field: 'expandedBody',
            primaryThemeId: themeId,
            lifePeriod: ctx.lifePeriodLabel,
            block: selection.block,
            matchLevel: selection.matchLevel,
            relationship: 'v12_strength',
          ),
        );
        expanded = ThaiBetaNarrativeDedupe.buildStrengthExpanded(
          title: title,
          // V1.2: keep tension out of strength expanded — it becomes linked caution.
          expandedBody: [
            if ((selection.block.observableBehavior ?? '').trim().isNotEmpty)
              ThaiBetaNarrativeFormatting.normalize(
                selection.block.observableBehavior!,
              ),
            if ((selection.block.strengthText ?? '').trim().isNotEmpty)
              ThaiBetaNarrativeFormatting.normalize(
                selection.block.strengthText!,
              ),
          ].join('\n\n'),
          used: globalUsed,
        );
        final observableParts = expanded.split(RegExp(r'\n\n+'));
        if (observableParts.isNotEmpty) {
          body = observableParts.first;
        }
      } else if (card.expandedBody != null) {
        expanded = ThaiBetaNarrativeDedupe.buildStrengthExpanded(
          title: title,
          expandedBody: card.expandedBody!,
          used: globalUsed,
        );
      }

      cards.add(
        ThaiMirrorInsightCardState(
          title: title,
          body: ThaiBetaNarrativeDedupe.resolveUnique(
            text: body,
            used: globalUsed,
          ),
          accent: card.accent,
          icon: card.icon,
          expandedBody: expanded,
        ),
      );
    }
    return (
      section: ThaiMirrorInsightSectionState(
        title: ThaiBetaNarrativeV12.strengthsSectionTitle,
        cards: cards,
        sectionIcon: section.sectionIcon,
      ),
      trace: trace,
      blocks: blocks,
      matchLevels: matchLevels,
    );
  }

  static ({ThaiMirrorInsightSectionState section, ThaiBetaNarrativeTrace trace})
  _polishLinkedCautions({
    required List<String> sourceTitles,
    required List<CuratedNarrativeBlock> strengthBlocks,
    required List<int> matchLevels,
    required ThaiBetaNarrativeContext ctx,
    required Set<String> globalUsed,
    required ThaiBetaNarrativeTrace trace,
  }) {
    final cards = <ThaiMirrorInsightCardState>[];
    for (var i = 0; i < strengthBlocks.length; i++) {
      final block = strengthBlocks[i];
      final tension = ThaiBetaNarrativeFormatting.normalize(
        block.tensionText ?? '',
      );
      if (tension.isEmpty) continue;

      // Skip near-duplicate caution text.
      final key = ThaiBetaNarrativeFormatting.normalizedKey(tension);
      if (key.length > 8 && globalUsed.contains(key)) continue;

      final title = i < sourceTitles.length
          ? ThaiBetaNarrativeFormatting.normalize(sourceTitles[i])
          : ThaiMirrorThemePhrases.phrase(
              block.primaryTraitIds.isNotEmpty
                  ? block.primaryTraitIds.first
                  : 'independent',
            ).tag;

      final themeId = block.primaryTraitIds.isNotEmpty
          ? block.primaryTraitIds.first
          : (ctx.orderedThemeIds.isNotEmpty
                ? ctx.orderedThemeIds.first
                : 'independent');

      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'caution_$i',
          field: 'body',
          primaryThemeId: themeId,
          lifePeriod: ctx.lifePeriodLabel,
          block: block,
          matchLevel: i < matchLevels.length ? matchLevels[i] : 5,
          relationship: 'v12_linked_risk',
        ),
      );

      cards.add(
        ThaiMirrorInsightCardState(
          title: title,
          body: ThaiBetaNarrativeDedupe.resolveUnique(
            text: tension,
            used: globalUsed,
          ),
          accent: ThaiMirrorInsightAccent.caution,
        ),
      );
    }

    return (
      section: ThaiMirrorInsightSectionState(
        title: ThaiBetaNarrativeV12.cautionsSectionTitle,
        cards: cards,
      ),
      trace: trace,
    );
  }

  static ({
    List<ThaiMirrorLifeDashboardItemState> items,
    ThaiBetaNarrativeTrace trace,
  })
  _polishLifeDashboard(
    List<ThaiMirrorLifeDashboardItemState> source,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final usedThemes = <String>{};
    final usedActions = <String>{};
    final out = <ThaiMirrorLifeDashboardItemState>[];

    for (var i = 0; i < source.length; i++) {
      final item = source[i];
      final domain = _domainForDashboardLabel(item.label);
      if (domain == null) {
        out.add(_normalizeDashboardItem(item, globalUsed));
        continue;
      }

      final primaryThemeId = ThaiBetaDomainSemanticTags.selectThemeForDomain(
        orderedThemeIds: ctx.orderedThemeIds,
        domain: domain,
        seed: ctx.profileSeed + i * 19,
        usedThemeIds: usedThemes,
      );
      final secondaryThemeId = ctx.orderedThemeIds.length > 1
          ? ThaiBetaDomainSemanticTags.selectThemeForDomain(
              orderedThemeIds: ctx.orderedThemeIds,
              domain: domain,
              seed: ctx.profileSeed + i * 23 + 1,
              usedThemeIds: {primaryThemeId, ...usedThemes},
            )
          : null;

      final copy = ThaiBetaNarrativeSpecificity.composeDashboardFromBlock(
        domain: domain,
        primaryThemeId: primaryThemeId,
        secondaryThemeId: secondaryThemeId != primaryThemeId
            ? secondaryThemeId
            : null,
        seed: ctx.profileSeed + i,
        hasBirthTime: ctx.hasBirthTime,
        usedBlockIds: usedBlockIds,
        usedTextKeys: globalUsed,
        usedActions: usedActions,
      );

      usedThemes.add(primaryThemeId);
      usedActions.add(copy.suggestedAction);
      usedBlockIds.add(copy.block.id);
      usedBlockIds.add(copy.adviceBlock.id);

      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'currentState',
          primaryThemeId: primaryThemeId,
          secondaryThemeId: secondaryThemeId,
          domain: domain,
          lifePeriod: ctx.lifePeriodLabel,
          block: copy.block,
          matchLevel: copy.matchLevel,
        ),
      );
      trace = trace.add(
        ThaiBetaNarrativeSpecificity.traceEntry(
          sectionId: 'dashboard_${domain.aspectKey}',
          field: 'suggestedAction',
          primaryThemeId: primaryThemeId,
          domain: domain,
          relationship: 'curated_advice',
          lifePeriod: ctx.lifePeriodLabel,
          block: copy.adviceBlock,
          matchLevel: copy.adviceMatchLevel,
        ),
      );

      final currentState = ThaiBetaNarrativeDedupe.resolveUnique(
        text: copy.currentState,
        used: globalUsed,
      );

      out.add(
        ThaiMirrorLifeDashboardItemState(
          label: item.label,
          currentState: ThaiBetaNarrativeFormatting.normalize(currentState),
          whyItAppears: ThaiBetaNarrativeFormatting.normalize(
            copy.whyItAppears,
          ),
          suggestedAction: ThaiBetaNarrativeFormatting.normalize(
            copy.suggestedAction,
          ),
          status: item.status,
        ),
      );
    }
    return (items: out, trace: trace);
  }

  static ThaiBetaLifeDomain? _domainForDashboardLabel(String label) {
    return switch (label.trim()) {
      'การงาน' => ThaiBetaLifeDomain.work,
      'การเงิน' => ThaiBetaLifeDomain.money,
      'ความรัก' => ThaiBetaLifeDomain.love,
      'สุขภาพ' => ThaiBetaLifeDomain.health,
      'โชคและโอกาส' => ThaiBetaLifeDomain.luck,
      _ => null,
    };
  }

  static ThaiMirrorLifeDashboardItemState _normalizeDashboardItem(
    ThaiMirrorLifeDashboardItemState item,
    Set<String> globalUsed,
  ) {
    return ThaiMirrorLifeDashboardItemState(
      label: item.label,
      currentState: ThaiBetaNarrativeFormatting.normalize(
        ThaiBetaNarrativeDedupe.resolveUnique(
          text: item.currentState,
          used: globalUsed,
        ),
      ),
      whyItAppears: ThaiBetaNarrativeFormatting.normalize(item.whyItAppears),
      suggestedAction: ThaiBetaNarrativeFormatting.normalize(
        item.suggestedAction,
      ),
      status: item.status,
    );
  }

  static ({
    List<ThaiMirrorNarrativeSectionState> sections,
    ThaiBetaNarrativeTrace trace,
  })
  _polishNarrativeSections(
    List<ThaiMirrorNarrativeSectionState> sections,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace,
  ) {
    final out = <ThaiMirrorNarrativeSectionState>[];

    for (final section in sections) {
      final domain = ThaiBetaDomainSemanticTags.domainForNarrativeLabel(
        section.label,
      );
      final sectionSeed = ThaiBetaNarrativeStableHash.seedOffset(
        ctx.profileSeed,
        [section.label, domain?.aspectKey ?? 'general'],
      );
      final primaryThemeId = domain != null
          ? ThaiBetaDomainSemanticTags.selectThemeForDomain(
              orderedThemeIds: ctx.orderedThemeIds,
              domain: domain,
              seed: sectionSeed,
            )
          : (ctx.orderedThemeIds.isNotEmpty
                ? ctx.orderedThemeIds.first
                : 'independent');
      final secondaryThemeId = ctx.orderedThemeIds.length > 1
          ? ctx.orderedThemeIds[1]
          : null;

      var overview = domain != null
          ? ThaiBetaNarrativeSpecificity.selectDomainOverview(
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              seed: sectionSeed,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (overview != null) {
        usedBlockIds.add(overview.block.id);
      }

      final transition = section.hasTransition
          ? ThaiBetaNarrativeFormatting.normalize(section.transitionIn)
          : '';
      final pullQuote = section.pullQuote.isNotEmpty
          ? ThaiBetaNarrativeFormatting.normalize(section.pullQuote)
          : '';
      final discovery = section.hasDiscovery
          ? ThaiBetaNarrativeFormatting.normalize(section.discovery)
          : '';
      final tension = section.hasTension
          ? ThaiBetaNarrativeFormatting.normalize(section.tension)
          : '';
      // Prefer complementary why text from the overview block (one curated
      // domain block carries both fields). Only select a second block when
      // the paired why is missing or already used as public text.
      ({String text, CuratedNarrativeBlock block, int matchLevel})? why;
      if (overview != null) {
        final pairedWhy = ThaiBetaNarrativeFormatting.normalize(
          overview.block.domainWhy ?? '',
        );
        final pairedKey = ThaiBetaNarrativeFormatting.normalizedKey(pairedWhy);
        if (pairedWhy.isNotEmpty &&
            (pairedKey.length <= 8 || !globalUsed.contains(pairedKey))) {
          why = (
            text: pairedWhy,
            block: overview.block,
            matchLevel: overview.matchLevel,
          );
        }
      }
      why ??= domain != null
          ? ThaiBetaNarrativeSpecificity.selectDomainWhy(
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              seed: sectionSeed + 2,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (why != null) {
        usedBlockIds.add(why.block.id);
      }
      var adviceSelection = domain != null
          ? ThaiBetaNarrativeSpecificity.selectAdvice(
              primaryThemeId: primaryThemeId,
              domain: domain,
              seed: sectionSeed + 3,
              hasBirthTime: ctx.hasBirthTime,
              usedBlockIds: usedBlockIds,
              usedTextKeys: globalUsed,
            )
          : null;
      if (adviceSelection != null) {
        usedBlockIds.add(adviceSelection.block.id);
      }

      final overviewText =
          overview?.text ??
          ThaiBetaNarrativeFormatting.normalize(section.overview);
      final whyText =
          why?.text ??
          ThaiBetaNarrativeFormatting.normalize(section.whyItAppears);
      final adviceText =
          adviceSelection?.text ??
          ThaiBetaNarrativeFormatting.normalize(section.advice);
      var example = ThaiBetaNarrativeFormatting.normalize(section.example);
      final reflection = section.hasReflectionQuestion
          ? ThaiBetaNarrativeFormatting.normalize(section.reflectionQuestion)
          : '';

      if (domain != null &&
          example.isNotEmpty &&
          !ThaiBetaDomainSemanticTags.isTextDomainCompatible(example, domain)) {
        example = '';
      }

      final deduped = ThaiBetaNarrativeDedupe.dedupeParagraphs(
        sectionId: section.label,
        sectionTitle: section.label,
        paragraphs: [
          if (transition.isNotEmpty) transition,
          if (pullQuote.isNotEmpty) pullQuote,
          if (discovery.isNotEmpty) discovery,
          overviewText,
          if (tension.isNotEmpty) tension,
          if (whyText.isNotEmpty) whyText,
          if (adviceText.isNotEmpty) adviceText,
          if (example.isNotEmpty) example,
          if (reflection.isNotEmpty) reflection,
        ],
        globalUsed: globalUsed,
      );

      final overviewFallback = overviewText;

      if (domain != null && overview != null) {
        trace = trace.add(
          ThaiBetaNarrativeSpecificity.traceEntry(
            sectionId: 'narrative_${domain.aspectKey}',
            field: 'overview',
            primaryThemeId: primaryThemeId,
            secondaryThemeId: secondaryThemeId,
            domain: domain,
            lifePeriod: ctx.lifePeriodLabel,
            block: overview.block,
            matchLevel: overview.matchLevel,
          ),
        );
        if (whyText.isNotEmpty &&
            why != null &&
            why.block.id != overview.block.id) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'whyItAppears',
              primaryThemeId: primaryThemeId,
              secondaryThemeId: secondaryThemeId,
              domain: domain,
              relationship: 'curated_domain',
              lifePeriod: ctx.lifePeriodLabel,
              block: why.block,
              matchLevel: why.matchLevel,
            ),
          );
        }
        if (adviceText.isNotEmpty && adviceSelection != null) {
          trace = trace.add(
            ThaiBetaNarrativeSpecificity.traceEntry(
              sectionId: 'narrative_${domain.aspectKey}',
              field: 'advice',
              primaryThemeId: primaryThemeId,
              domain: domain,
              relationship: 'curated_advice',
              lifePeriod: ctx.lifePeriodLabel,
              block: adviceSelection.block,
              matchLevel: adviceSelection.matchLevel,
            ),
          );
        }
      }

      out.add(
        ThaiMirrorNarrativeSectionState(
          label: ThaiBetaNarrativeFormatting.normalize(section.label),
          icon: section.icon,
          accent: section.accent,
          transitionIn: _fieldAfterSectionDedupe(transition, deduped),
          pullQuote: _fieldAfterSectionDedupe(pullQuote, deduped),
          overview: _fieldAfterSectionDedupe(
            overviewText,
            deduped,
            fallback: overviewFallback,
          ),
          tension: _fieldAfterSectionDedupe(tension, deduped),
          discovery: _fieldAfterSectionDedupe(discovery, deduped),
          reasoningTitle: ThaiBetaNarrativeFormatting.normalize(
            section.reasoningTitle,
          ),
          reasoningSignals: section.reasoningSignals
              .map(ThaiBetaNarrativeFormatting.normalize)
              .toList(),
          whyItAppears: _fieldAfterSectionDedupe(whyText, deduped),
          advice: _fieldAfterSectionDedupe(adviceText, deduped),
          example: _fieldAfterSectionDedupe(example, deduped),
          reflectionQuestion: _fieldAfterSectionDedupe(reflection, deduped),
        ),
      );
    }
    return (sections: out, trace: trace);
  }

  static String _fieldAfterSectionDedupe(
    String value,
    List<String> deduped, {
    String fallback = '',
  }) {
    if (value.isEmpty) return value;
    if (deduped.contains(value)) return value;
    return fallback;
  }

  static ({
    ThaiMirrorAdviceState advice,
    ThaiBetaNarrativeTrace trace,
    String? adviceBlockId,
  })
  _polishAdvice(
    ThaiMirrorAdviceState advice,
    ThaiBetaNarrativeContext ctx,
    Set<String> globalUsed,
    Set<String> usedBlockIds,
    ThaiBetaNarrativeTrace trace, {
    CuratedNarrativeBlock? primaryStrength,
    String coreBody = '',
  }) {
    final primaryThemeId = primaryStrength?.primaryTraitIds.isNotEmpty == true
        ? primaryStrength!.primaryTraitIds.first
        : (ctx.orderedThemeIds.isNotEmpty
              ? ctx.orderedThemeIds.first
              : 'independent');

    var selection = ThaiBetaNarrativeSpecificity.selectAdvice(
      primaryThemeId: primaryThemeId,
      seed: ctx.profileSeed + 99,
      hasBirthTime: ctx.hasBirthTime,
      usedBlockIds: usedBlockIds,
      usedTextKeys: globalUsed,
    );

    // Prefer advice compatible with the primary strength evidence tags.
    if (primaryStrength != null &&
        !ThaiBetaNarrativeV12.adviceCompatibleWithStrength(
          advice: selection.block,
          strength: primaryStrength,
        )) {
      final alt = ThaiBetaNarrativeSpecificity.selectAdvice(
        primaryThemeId: primaryThemeId,
        seed: ctx.profileSeed + 101,
        hasBirthTime: ctx.hasBirthTime,
        usedBlockIds: {...usedBlockIds, selection.block.id},
        usedTextKeys: globalUsed,
      );
      if (ThaiBetaNarrativeV12.adviceCompatibleWithStrength(
            advice: alt.block,
            strength: primaryStrength,
          ) ||
          alt.block.id != selection.block.id) {
        selection = alt;
      }
    }

    var body = selection.text;
    if (body.isEmpty) {
      body = ThaiBetaNarrativeFormatting.normalize(advice.body);
    }
    if (ThaiBetaNarrativeForbidden.findForbidden(body).isNotEmpty ||
        (coreBody.isNotEmpty &&
            ThaiBetaNarrativeV12.adviceConflictsWithCore(
              adviceText: body,
              coreBody: coreBody,
            ))) {
      selection = ThaiBetaNarrativeSpecificity.selectAdvice(
        primaryThemeId: primaryThemeId,
        domain: ThaiBetaLifeDomain.work,
        seed: ctx.profileSeed + 100,
        hasBirthTime: ctx.hasBirthTime,
        usedBlockIds: {...usedBlockIds, selection.block.id},
        usedTextKeys: globalUsed,
      );
      body = selection.text;
    }
    usedBlockIds.add(selection.block.id);
    trace = trace.add(
      ThaiBetaNarrativeSpecificity.traceEntry(
        sectionId: 'advice',
        field: 'body',
        primaryThemeId: primaryThemeId,
        lifePeriod: ctx.lifePeriodLabel,
        block: selection.block,
        matchLevel: selection.matchLevel,
        relationship: 'v12_prioritised_advice',
      ),
    );
    return (
      advice: ThaiMirrorAdviceState(
        title: ThaiBetaNarrativeV12.adviceSectionTitle,
        body: ThaiBetaNarrativeDedupe.resolveUnique(
          text: body,
          used: globalUsed,
        ),
      ),
      trace: trace,
      adviceBlockId: selection.block.id,
    );
  }

  static ({
    ThaiMirrorSignatureInsightState insight,
    ThaiBetaNarrativeTrace trace,
  })
  _composePersonalCore({
    required List<CuratedNarrativeBlock> strengthBlocks,
    required List<int> matchLevels,
    required ThaiBetaNarrativeContext ctx,
    required Set<String> globalUsed,
    required ThaiBetaNarrativeTrace trace,
    required ThaiMirrorSignatureInsightState fallback,
  }) {
    if (strengthBlocks.isEmpty) {
      return (
        insight: _polishSignature(
          fallback,
          globalUsed,
          hasBirthTime: ctx.hasBirthTime,
        ),
        trace: trace,
      );
    }

    final primary = strengthBlocks.first;
    final secondary = strengthBlocks.length > 1 ? strengthBlocks[1] : null;
    final matchLevel = matchLevels.isNotEmpty ? matchLevels.first : 5;
    final band = ThaiBetaNarrativeV12.bandFor(
      hasBirthTime: ctx.hasBirthTime,
      matchLevel: matchLevel,
    );

    final body = ThaiBetaNarrativeV12.composePersonalCoreBody(
      primaryStrength: primary,
      secondaryStrength: secondary,
      band: band,
      hasBirthTime: ctx.hasBirthTime,
    );

    final themeId = primary.primaryTraitIds.isNotEmpty
        ? primary.primaryTraitIds.first
        : (ctx.orderedThemeIds.isNotEmpty
              ? ctx.orderedThemeIds.first
              : 'independent');

    trace = trace.add(
      ThaiBetaNarrativeSpecificity.traceEntry(
        sectionId: 'personal_core',
        field: 'body',
        primaryThemeId: themeId,
        secondaryThemeId: secondary?.primaryTraitIds.isNotEmpty == true
            ? secondary!.primaryTraitIds.first
            : null,
        lifePeriod: ctx.lifePeriodLabel,
        block: primary,
        matchLevel: matchLevel,
        relationship: 'v12_personal_core',
      ),
    );

    return (
      insight: ThaiMirrorSignatureInsightState(
        eyebrow: ThaiBetaNarrativeV12.personalCoreEyebrow(band),
        // Core may intentionally preview strength evidence — do not strip via
        // globalUsed (detail sections keep the same curated source).
        body: ThaiBetaNarrativeFormatting.normalize(body),
        signature: ThaiBetaNarrativeV12.personalCoreSignature(band),
      ),
      trace: trace,
    );
  }

  static ThaiMirrorSignatureInsightState _polishSignature(
    ThaiMirrorSignatureInsightState insight,
    Set<String> globalUsed, {
    required bool hasBirthTime,
  }) {
    var body = ThaiBetaNarrativeFormatting.normalize(insight.body);
    if (!hasBirthTime &&
        (ThaiBetaNarrativeForbidden.findNoBirthTimeViolations(
              body,
            ).isNotEmpty ||
            body.contains('ถ้าจะเข้าใจคุณ แค่เรื่องเดียว'))) {
      body =
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มที่โดดเด่นในบางด้าน '
          '— ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่าอะไรตรงกับชีวิตจริงของคุณ';
    }
    return ThaiMirrorSignatureInsightState(
      eyebrow: ThaiBetaNarrativeFormatting.normalize(insight.eyebrow),
      body: ThaiBetaNarrativeDedupe.resolveUnique(text: body, used: globalUsed),
      signature: ThaiBetaNarrativeFormatting.normalize(insight.signature),
    );
  }

  static ThaiMirrorReflectionSummaryState _polishReflection(
    ThaiMirrorReflectionSummaryState summary,
    Set<String> globalUsed,
  ) {
    final points = ThaiBetaNarrativeDedupe.dedupeParagraphs(
      sectionId: 'reflection',
      paragraphs: summary.points,
      globalUsed: globalUsed,
    );
    return ThaiMirrorReflectionSummaryState(
      title: ThaiBetaNarrativeFormatting.normalize(summary.title),
      intro: ThaiBetaNarrativeFormatting.normalize(summary.intro),
      points: points,
    );
  }

  static ThaiMirrorClosingMessageState _polishClosing(
    ThaiMirrorClosingMessageState closing,
    Set<String> globalUsed,
  ) {
    final message = ThaiBetaNarrativeFormatting.normalize(closing.message);
    return ThaiMirrorClosingMessageState(
      eyebrow: ThaiBetaNarrativeFormatting.normalize(closing.eyebrow),
      message: ThaiBetaNarrativeDedupe.resolveUnique(
        text: message,
        used: globalUsed,
      ),
      signature: ThaiBetaNarrativeFormatting.normalize(closing.signature),
    );
  }
}
