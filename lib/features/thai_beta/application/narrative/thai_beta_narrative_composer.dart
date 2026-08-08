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
    final usedClaims = <String>[];
    final periods = timeline.periods
        .map((period) {
          if (period.isCurrent || period.lifeDomains.isEmpty) return period;
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
          return ThaiMirrorLifePeriodState(
            ageLabel: period.ageLabel,
            phaseName: period.phaseName,
            planetLine: period.planetLine,
            keyword: period.keyword,
            isCurrent: period.isCurrent,
            isPast: period.isPast,
            summary: startAge >= 69 ? '' : period.summary,
            whatChanges: startAge >= 69 ? '' : period.whatChanges,
            easier: startAge >= 69 ? '' : period.easier,
            harder: startAge >= 69 ? '' : period.harder,
            comparison: startAge >= 69 ? '' : period.comparison,
            evidenceLine: startAge >= 69 ? '' : period.evidenceLine,
            scores: period.scores,
            easeIndex: period.easeIndex,
            accentIndex: period.accentIndex,
            advice: startAge >= 69 ? '' : period.advice,
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
  ) {
    if (prediction == null) return null;
    final windows = <PredictionWindowCardModel>[];
    for (var i = 0; i < prediction.windows.length; i++) {
      final window = prediction.windows[i];
      final domains = window.domains
          .map((domain) {
            final claim = _forecastClaim(domain.body, i);
            final material = domain.material!;
            final risk = _riskSignal(
              domain.caution,
              riskDomain: material.riskDomain,
            );
            final decisionImpact = _decisionImpact(
              domain.title,
              claim,
              risk,
              material,
            );
            final action = forecastActionForMaterial(
              title: domain.title,
              windowIndex: i,
              claim: claim,
              risk: risk,
              decisionImpact: decisionImpact,
              material: material,
            );
            final uncertaintyDisclosure =
                material.evidenceAvailability ==
                    ForecastEvidenceAvailability.noLagna
                ? 'คำอ่านนี้ไม่มีหลักฐานลัคนา จึงใช้เป็นกรอบสังเกตและไม่ฟันธง'
                : '';
            final body = [
              'แนวโน้ม: $claim',
              'ผลต่อการตัดสินใจ: $decisionImpact',
            ].join('\n');
            final caution = [
              if (risk.isNotEmpty) 'ความเสี่ยง: $risk',
              'แนวทางเตรียมตัว: $action',
            ].join('\n');
            return PredictionDomainModel(
              title: domain.title,
              body: body,
              caution: caution,
              claim: claim,
              risk: risk,
              decisionImpact: decisionImpact,
              preparationAction: action,
              uncertaintyDisclosure: uncertaintyDisclosure,
              material: material,
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
          summary: window.summary,
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
      detailedClosingAdvice: prediction.detailedClosingAdvice,
    );
  }

  static String _forecastClaim(String body, int windowIndex) {
    final stripped = body
        .replaceFirst(RegExp(r'^ช่วงนี้\s*'), '')
        .replaceFirst(RegExp(r'^ใน 12 เดือนข้างหน้า\s*'), '')
        .replaceFirst(RegExp(r'^เมื่อเข้าสู่ช่วงชีวิตถัดไป\s*'), '');
    return switch (windowIndex) {
      0 => 'สำหรับตอนนี้ $stripped',
      1 => 'ใน 12 เดือนข้างหน้า $stripped',
      _ => 'เมื่อเข้าสู่ช่วงชีวิตถัดไป $stripped',
    };
  }

  static String _decisionImpact(
    String title,
    String claim,
    String risk,
    ForecastMaterialFingerprint material,
  ) {
    final evidenceRiskDecision = switch (material.riskDomain) {
      LifeDomain.love => switch (title.trim()) {
        'การงาน' =>
          'แยกข้อตกลงเรื่องงานออกจากความคาดหวังในความสัมพันธ์ก่อนรับบทบาทเพิ่ม',
        'การเงิน' => 'ตกลงขอบเขตเงินร่วมให้ชัดก่อนรับรายจ่ายหรือภาระก้อนใหม่',
        'ความรัก' ||
        'ความสัมพันธ์' => 'รอให้คำพูดและการกระทำสอดคล้องกันก่อนเพิ่มข้อผูกพัน',
        'สุขภาพ' => 'กันเวลาพักออกจากภาระความสัมพันธ์ก่อนเพิ่มกิจกรรม',
        _ => '',
      },
      LifeDomain.pressure =>
        'กำหนดเพดานภาระและจุดหยุดก่อนขยายการตัดสินใจในด้านนี้',
      LifeDomain.money => 'รักษาเงินพร้อมใช้ก่อนขยายภาระในด้านนี้',
      LifeDomain.health => 'รักษาเวลาพักและการฟื้นตัวก่อนขยายภาระในด้านนี้',
      LifeDomain.career => 'กันเวลางานหลักไว้ก่อนเพิ่มภาระในด้านนี้',
      _ => '',
    };
    if (evidenceRiskDecision.isNotEmpty) {
      final bandDecision = switch (material.band) {
        ForecastBand.strong => 'มีพื้นที่เดินหน้าได้หนึ่งก้าว แต่',
        ForecastBand.active => 'ควรทดลองในขอบเขตเล็กและ',
        ForecastBand.quiet => 'ควรชะลอการขยายและ',
      };
      return '$bandDecision$evidenceRiskDecision';
    }
    final constrained =
        material.band == ForecastBand.quiet ||
        claim.contains('ช้า') ||
        claim.contains('ตึง') ||
        claim.contains('ล้าง่าย') ||
        claim.contains('ไม่ใช่ด้านที่เดินง่าย');
    final strong = material.band == ForecastBand.strong;
    return switch (title.trim()) {
      'การงาน' =>
        constrained
            ? 'ภาระที่เพิ่มจะเบียดงานหลักได้ จึงควรจำกัดงานใหม่ก่อนขยายบทบาท'
            : strong
            ? 'โอกาสขยับงานมีน้ำหนัก แต่ต้องกันกำลังไว้ไม่ให้บทบาทใหม่ลดคุณภาพงานหลัก'
            : risk.contains('รับงานเกิน')
            ? 'งานมีพื้นที่ขยับทีละขั้น จึงควรทดลองขอบเขตใหม่ก่อนรับบทบาทเพิ่มเต็มตัว'
            : 'ใช้แนวโน้มนี้เลือกลำดับงานและขอบเขตบทบาทที่รับเพิ่ม',
      'การเงิน' =>
        constrained
            ? 'สภาพคล่องอาจลดลง จึงควรรักษาเงินพร้อมใช้ก่อนรับภาระหรือใช้เงินก้อน'
            : strong
            ? 'โอกาสเพิ่มความมั่นคงมีน้ำหนัก จึงควรล็อกส่วนเพิ่มเป็นเงินสำรองก่อนขยายภาระ'
            : risk.contains('รายจ่ายเพิ่ม')
            ? 'การเงินมีพื้นที่นิ่งขึ้นทีละขั้น จึงควรพิสูจน์กระแสเงินก่อนเพิ่มภาระ'
            : 'ใช้แนวโน้มนี้กำหนดเงินสำรองก่อนตัดสินใจเพิ่มภาระ',
      'ความรัก' || 'ความสัมพันธ์' =>
        constrained
            ? 'ความคาดหวังที่ยังไม่ตรงกันเพิ่มความเสี่ยงต่อข้อผูกพัน จึงควรรอความชัดก่อนตัดสินใจ'
            : strong
            ? 'ความสัมพันธ์มีแรงเดินหน้า แต่เรื่องค้างคายังเป็นเงื่อนไขก่อนเพิ่มข้อผูกพัน'
            : risk.contains('ไม่พอใจสะสม')
            ? 'ความสัมพันธ์ค่อย ๆ พัฒนา จึงควรใช้ความสม่ำเสมอจริงพิสูจน์ทิศทางก่อนตัดสินใจ'
            : 'ใช้ความสม่ำเสมอและบทสนทนาจริงเป็นฐานตัดสินใจความสัมพันธ์',
      'สุขภาพ' =>
        constrained
            ? 'ความล้าที่เพิ่มขึ้นลดพื้นที่รับภาระใหม่ จึงควรลดกิจกรรมและไม่ใช้คำอ่านแทนคำแนะนำทางการแพทย์'
            : strong
            ? 'พลังโดยรวมรองรับกิจกรรมได้ แต่ต้องรักษาเวลาพักไม่ให้ข้อได้เปรียบกลายเป็นความล้า'
            : risk.contains('ความล้าสะสม')
            ? 'พลังขึ้นลงตามภาระ จึงควรเพิ่มกิจกรรมทีละขั้นและใช้การฟื้นตัวจริงกำหนดเพดาน'
            : 'ใช้ระดับพลังที่เกิดขึ้นจริงกำหนดภาระและเวลาพัก',
      _ => 'ใช้สิ่งที่เกิดขึ้นจริงเป็นฐานทบทวนก่อนตัดสินใจ',
    };
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

  /// Composes a concise action from the block's predictive meaning.
  ///
  /// Public for deterministic acceptance mutation tests; this does not run an
  /// engine or create a prediction.
  static String forecastActionForMaterial({
    required String title,
    required int windowIndex,
    required String claim,
    required String risk,
    required String decisionImpact,
    required ForecastMaterialFingerprint material,
  }) {
    if (claim.isEmpty || risk.isEmpty || decisionImpact.isEmpty) {
      return _forecastAction(title, windowIndex, material);
    }

    final horizonLead = switch (material.horizon) {
      ForecastHorizon.current => 'ตอนนี้',
      ForecastHorizon.next12Months => 'ตั้งจุดทบทวนภายใน 12 เดือน',
      ForecastHorizon.nextLifePeriod when material.spansTransition =>
        'ก่อนเปลี่ยนช่วงชีวิต เตรียมรับรอยต่อระยะยาวโดย',
      ForecastHorizon.nextLifePeriod =>
        'ก่อนเปลี่ยนช่วงชีวิต เตรียมฐานระยะยาวโดย',
    };
    final claimIsConstrained =
        material.band == ForecastBand.quiet ||
        claim.contains('ช้า') ||
        claim.contains('ตึง') ||
        claim.contains('ล้าง่าย') ||
        claim.contains('ขึ้นลง');
    final claimResponse = switch ((material.band, claimIsConstrained)) {
      (_, true) => 'ชะลอก้าวใหม่และเก็บข้อมูลจริงก่อนตัดสินใจ',
      (ForecastBand.strong, _) => 'เลือกหนึ่งก้าวที่เห็นผลชัดและกำหนดเพดานไว้',
      (ForecastBand.active, _) => 'ทดลองทีละขั้นแล้วทบทวนจากผลที่เกิดขึ้นจริง',
      (ForecastBand.quiet, _) => 'ชะลอก้าวใหม่และเก็บข้อมูลจริงก่อนตัดสินใจ',
    };
    final riskResponse = switch (material.riskDomain) {
      LifeDomain.pressure => 'ลดภาระทันทีเมื่อภาระเริ่มเกินกำลัง',
      LifeDomain.money => 'หยุดเพิ่มภาระเงินเมื่อความเสี่ยงเริ่มเกิด',
      LifeDomain.love => 'ชะลอข้อตกลงเมื่อความสัมพันธ์ยังไม่ชัด',
      LifeDomain.health => 'ลดกิจกรรมเมื่อการฟื้นตัวไม่พอ',
      _ => 'ชะลอและทบทวนเมื่อความเสี่ยงนี้เริ่มเกิด',
    };
    final decisionStep = switch (title.trim()) {
      'การงาน' => 'จัดลำดับงานหลักก่อนรับบทบาทเพิ่ม',
      'การเงิน' => 'กันเงินพร้อมใช้ก่อนเพิ่มภาระ',
      'ความรัก' || 'ความสัมพันธ์' =>
        'คุยเงื่อนไขให้ชัดก่อนเพิ่มข้อผูกพัน',
      'สุขภาพ' => 'รักษาเวลาฟื้นตัวก่อนเพิ่มกิจกรรม',
      _ => 'กำหนดเกณฑ์หยุดไว้ก่อนเริ่ม',
    };
    if (material.evidenceAvailability == ForecastEvidenceAvailability.noLagna) {
      return '$horizonLead บันทึกผลจริงหนึ่งรอบก่อน แล้วค่อย$decisionStep; '
          'หากข้อมูลยังไม่ชัดให้ชะลอไว้และ$riskResponse';
    }
    return '$horizonLead $decisionStep โดย$claimResponse; $riskResponse';
  }

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
