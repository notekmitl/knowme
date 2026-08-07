/// Thai Beta Narrative Quality V1.1 + V1.2 — curated block composer.
library;

import 'package:knowme/features/astrology/thai/mirror/presentation/copy/thai_mirror_theme_phrases.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/prediction/prediction_section_model.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/timeline/thai_mirror_life_timeline_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_context.dart';
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
      lifeTimeline: _differentiateTimelineDomains(source.lifeTimeline),
      futurePrediction: _polishPrediction(source.futurePrediction),
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
    ThaiMirrorLifeTimelineState? timeline,
  ) {
    if (timeline == null) return null;
    final used = <String>{};
    final periods = timeline.periods
        .map((period) {
          if (period.isCurrent || period.lifeDomains.isEmpty) return period;
          final bucket = period.isPast ? 'past' : 'future';
          final startAge = int.tryParse(period.ageLabel.split('–').first) ?? 0;
          final domains = <ThaiMirrorLifeDomainBlock>[];
          for (final domain in period.lifeDomains) {
            final ageAppropriate = _ageAppropriateDomain(
              period: period,
              domain: domain,
              startAge: startAge,
            );
            final semanticBody = ageAppropriate.body.replaceAll(
              'ใน${period.phaseName}',
              'ในช่วงชีวิตนี้',
            );
            final key =
                '$bucket|${domain.title}|'
                '${ThaiBetaNarrativeFormatting.normalizedKey(semanticBody)}';
            if (used.add(key)) {
              domains.add(ageAppropriate);
              continue;
            }
            domains.add(
              ThaiMirrorLifeDomainBlock(
                title: domain.title,
                body: '${ageAppropriate.body} ${_periodDifference(period)}',
                evidenceKeys: [
                  ...domain.evidenceKeys,
                  'ThaiMirrorLifePeriodState.summary',
                  'ThaiMirrorLifePeriodState.whatChanges',
                ],
              ),
            );
          }
          return ThaiMirrorLifePeriodState(
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
            lifeDomains: List.unmodifiable(domains),
          );
        })
        .toList(growable: false);
    return ThaiMirrorLifeTimelineState(
      sectionTitle: timeline.sectionTitle,
      sectionIntro: timeline.sectionIntro,
      currentStage: _betaCurrentStage(timeline.currentStage),
      segments: timeline.segments,
      periods: periods,
      currentAnalysis: _betaCurrentAnalysis(timeline.currentAnalysis),
      futurePreview: timeline.futurePreview,
      detailedReport: timeline.detailedReport,
    );
  }

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

  static ThaiMirrorLifeDomainBlock _ageAppropriateDomain({
    required ThaiMirrorLifePeriodState period,
    required ThaiMirrorLifeDomainBlock domain,
    required int startAge,
  }) {
    String? body;
    if (startAge < 11) {
      body = switch (domain.title) {
        'การงาน' =>
          'ใน${period.phaseName} เรื่องงานหมายถึงการฝึกทำหน้าที่เล็ก ๆ การเรียนรู้กติกา '
              'และการได้รับกำลังใจเมื่อพยายาม',
        'การเงิน' =>
          'ใน${period.phaseName} เรื่องเงินหมายถึงการเริ่มเข้าใจคุณค่าของสิ่งของ '
              'การรอคอย และการรู้ว่าบางอย่างต้องเก็บไว้ใช้ภายหลัง',
        'ความรัก' || 'ความสัมพันธ์' =>
          'ความสัมพันธ์ใน${period.phaseName}อยู่ที่ความไว้ใจในครอบครัวและคนใกล้ตัว '
              'รวมถึงการเรียนรู้ว่าจะบอกความต้องการของตัวเองอย่างไร',
        'สุขภาพ' =>
          'พลังใน${period.phaseName}ควรอ่านผ่านการกิน นอน เล่น และพักให้เป็นเวลา '
              'ไม่ใช่ความกังวลเรื่องภาระแบบผู้ใหญ่',
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
      body = switch (domain.title) {
        'การงาน' =>
          'ใน${period.phaseName} เรื่องงานหมายถึงการเลือกบทบาทและกิจกรรมที่ยังมีความหมาย '
              'พร้อมจัดแรงให้พอดีกับชีวิตประจำวัน แกน${period.keyword}จึงหมายถึงการทำสิ่งที่เลือกแล้วให้ต่อเนื่อง',
        'การเงิน' =>
          'ใน${period.phaseName} เรื่องเงินเน้นการดูแลสิ่งที่มี '
              'และพิจารณาภาระใหม่ให้สอดคล้องกับความมั่นคงที่ต้องการ โดยใช้${period.keyword}เป็นกรอบทบทวนทางเลือก',
        'ความรัก' || 'ความสัมพันธ์' =>
          'ความสัมพันธ์ใน${period.phaseName}ให้ความสำคัญกับการดูแลกัน '
              'การบอกความต้องการ และการรักษาพื้นที่ที่สบายใจ พร้อมอ่าน${period.keyword}ผ่านการกระทำที่ทำร่วมกันได้จริง',
        'สุขภาพ' =>
          'พลังใน${period.phaseName}เน้นการจัดกิจวัตรและการพักให้เหมาะกับแรงที่มี ไม่ให้แรงผลักจาก${period.keyword}กลายเป็นการฝืนตัวเอง',
        _ => null,
      };
    }
    final baseBody = body ?? domain.body;
    return ThaiMirrorLifeDomainBlock(
      title: domain.title,
      body: baseBody,
      evidenceKeys: domain.evidenceKeys,
    );
  }

  static String _periodDifference(ThaiMirrorLifePeriodState period) {
    final change = period.whatChanges.trim();
    if (change.isNotEmpty) return 'สิ่งที่เปลี่ยนในช่วงนี้คือ$change';
    final summary = period.summary.trim();
    return summary;
  }

  static PredictionSectionModel? _polishPrediction(
    PredictionSectionModel? prediction,
  ) {
    if (prediction == null) return null;
    final windows = <PredictionWindowCardModel>[];
    for (var i = 0; i < prediction.windows.length; i++) {
      final window = prediction.windows[i];
      final domains = window.domains
          .map(
            (domain) => PredictionDomainModel(
              title: domain.title,
              body: _forecastBody(domain.title, domain.body, i),
              caution: _forecastCaution(domain.caution, i),
            ),
          )
          .toList(growable: false);
      windows.add(
        PredictionWindowCardModel(
          windowLabel: window.windowLabel,
          timeframeLabel: window.timeframeLabel,
          summary: window.summary,
          topOpportunity: _dedupeOpportunity(
            window.summary,
            window.topOpportunity,
          ),
          topRisk: window.topRisk,
          confidenceLabel: switch (window.confidenceLevel) {
            _ when i == 0 => 'เทียบคำอ่านช่วงปัจจุบันกับชีวิตจริงของคุณ',
            _ when i == 1 => 'ใช้กรอบ 12 เดือนนี้วางแผนและทบทวนระหว่างทาง',
            _ => 'ใช้ช่วงถัดไปเตรียมตัว โดยไม่ถือว่าเหตุการณ์ถูกกำหนดไว้แล้ว',
          },
          confidenceLevel: window.confidenceLevel,
          why: window.why,
          whyNow: window.whyNow,
          whatToWatch: window.whatToWatch,
          evidenceDetail: window.evidenceDetail
              .replaceAll(
                'ความสัมพันธ์กับ พื้นฐานวันเกิดของคุณ',
                'เมื่อเทียบกับพื้นดวงของคุณ',
              )
              .replaceAll(
                'ความสัมพันธ์กับพื้นฐานวันเกิดของคุณ',
                'เมื่อเทียบกับพื้นดวงของคุณ',
              )
              .replaceAll(
                'จึงปรากฏเป็นแนวโน้มด้าน',
                'จึงทำให้เรื่องที่เด่นในช่วงนี้คือ',
              ),
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
      detailedClosingAdvice: prediction.detailedClosingAdvice,
    );
  }

  static String _forecastBody(String title, String body, int windowIndex) {
    final stripped = body
        .replaceFirst(RegExp(r'^ช่วงนี้\s*'), '')
        .replaceFirst(RegExp(r'^ใน 12 เดือนข้างหน้า\s*'), '')
        .replaceFirst(RegExp(r'^เมื่อเข้าสู่ช่วงชีวิตถัดไป\s*'), '');
    return switch (windowIndex) {
      0 => 'สำหรับตอนนี้ $stripped',
      1 => _nextYearAction(title),
      _ => 'เมื่อเข้าสู่ช่วงชีวิตถัดไป $stripped',
    };
  }

  static String _nextYearAction(String title) => switch (title.trim()) {
    'การงาน' =>
      'ในปีข้างหน้า ใช้ภาพรวมช่วงนี้เป็นฐานเลือกงานที่ควรลงแรงก่อน '
          'แล้วตรวจความคืบหน้าจากผลที่เกิดขึ้นจริง',
    'การเงิน' =>
      'ในปีข้างหน้า แยกเงินที่ต้องรักษาออกจากเงินที่พร้อมใช้ '
          'และทบทวนข้อตกลงก่อนรับภาระเพิ่ม',
    'ความรัก' || 'ความสัมพันธ์' =>
      'ในปีข้างหน้า ให้ความสำคัญกับการคุยความคาดหวังให้ชัด '
          'แล้วดูว่าการกระทำของทั้งสองฝ่ายสอดคล้องกันหรือไม่',
    'สุขภาพ' =>
      'ในปีข้างหน้า จัดเวลาพักและกิจวัตรให้รองรับภาระที่มี '
          'หากมีอาการผิดปกติควรปรึกษาผู้เชี่ยวชาญ ไม่ใช้คำอ่านนี้แทนการแพทย์',
    _ => 'ในปีข้างหน้า ใช้สิ่งที่เกิดขึ้นจริงเป็นจุดทบทวนก่อนตัดสินใจเพิ่ม',
  };

  static String _forecastCaution(String caution, int windowIndex) {
    final base = caution.replaceAll(' โดยเฉพาะเรื่องแรงกดดัน', '');
    final risk = base.replaceFirst('จุดที่ต้องระวังคือ', '');
    return switch (windowIndex) {
      0 => base,
      1 => 'หาก$riskเกิดซ้ำ ควรหยุดทบทวนทางเลือกก่อนเดินหน้าต่อ',
      _ => 'เตรียมรับมือเรื่อง$riskโดยไม่ถือว่าเป็นเหตุการณ์ที่ต้องเกิดแน่นอน',
    };
  }

  static String _dedupeOpportunity(String summary, String opportunity) {
    final summaryKey = ThaiBetaNarrativeFormatting.normalizedKey(summary);
    final opportunityKey = ThaiBetaNarrativeFormatting.normalizedKey(
      opportunity,
    );
    const topics = ['การงาน', 'การเงิน', 'ความรัก', 'สุขภาพ'];
    final sameSupportedTopic = topics.any(
      (topic) => summaryKey.contains(topic) && opportunityKey.contains(topic),
    );
    if (sameSupportedTopic &&
        summaryKey.contains('แรงหนุน') &&
        opportunityKey.contains('แรงหนุน')) {
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
