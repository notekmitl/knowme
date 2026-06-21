import 'package:flutter/material.dart';



import '../../analytics/fusion_reading_depth.dart';

import '../../analytics/fusion_section_tracker.dart';

import '../../analytics/fusion_validation_session.dart';

import '../../domain/entities/astrology_fusion_entry_status.dart';

import '../../domain/entities/astrology_fusion_result.dart';

import '../../domain/models/astrology_fusion_readiness.dart';

import '../fusion_result_design.dart';

import '../fusion_result_presenter.dart';

import '../widgets/fusion_cosmic_background.dart';

import '../widgets/fusion_direction_section.dart';

import '../widgets/fusion_final_message_section.dart';

import '../widgets/fusion_growth_path_section.dart';

import '../widgets/fusion_knowme_moment_section.dart';

import '../widgets/fusion_lens_agreement_section.dart';

import '../widgets/fusion_life_chapter_section.dart';

import '../widgets/fusion_life_lesson_section.dart';

import '../widgets/fusion_life_pattern_section.dart';

import '../widgets/fusion_peak_potential_section.dart';

import '../widgets/fusion_psychology_discovery_section.dart';

import '../widgets/fusion_result_hero_section.dart';

import '../widgets/fusion_strengths_warnings_section.dart';

import '../widgets/fusion_surprising_insight_section.dart';



class AstrologyFusionResultPage extends StatefulWidget {

  const AstrologyFusionResultPage({

    super.key,

    required this.result,

    this.showAppBar = true,

    this.readiness,

    this.validationSession,

  });



  final AstrologyFusionResult result;

  final bool showAppBar;

  final AstrologyFusionReadiness? readiness;

  final FusionValidationSession? validationSession;



  @override

  State<AstrologyFusionResultPage> createState() =>

      _AstrologyFusionResultPageState();

}



class _AstrologyFusionResultPageState extends State<AstrologyFusionResultPage> {

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _agreementSectionKey = GlobalKey();

  bool _fullyViewedReported = false;



  FusionValidationSession? get _session => widget.validationSession;



  bool get _isEmptyExperience =>
      widget.result.signals.isEmpty &&
      widget.result.tensions.isEmpty &&
      widget.result.lensOrigins.isEmpty &&
      widget.result.growthOpportunities.isEmpty &&
      widget.result.futureTendencies.isEmpty;



  bool get _showPartialBanner =>

      widget.readiness?.status == AstrologyFusionEntryStatus.partiallyAvailable;



  @override

  void initState() {

    super.initState();

    _scrollController.addListener(_onScroll);

  }



  @override

  void dispose() {

    _scrollController.removeListener(_onScroll);

    _scrollController.dispose();

    _session?.complete();

    super.dispose();

  }



  void _onScroll() {

    final session = _session;

    if (session == null || _fullyViewedReported || !_scrollController.hasClients) {

      return;

    }



    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 48) {

      _fullyViewedReported = true;

      session.markFullyViewed();

    }

  }



  void _scrollToAgreement() {
    final target = _agreementSectionKey.currentContext;
    if (target == null) return;

    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }



  Widget _trackSection({

    required String sectionId,

    required Widget child,

  }) {

    final session = _session;

    if (session == null) return child;



    return FusionSectionTracker(

      sectionId: sectionId,

      session: session,

      child: child,

    );

  }



  @override

  Widget build(BuildContext context) {

    final viewModel = FusionResultPresenter.fromResult(widget.result);

    final lensTitles =
        viewModel.lensAgreements.map((item) => item.title).toList();
    final centralThemes =
        viewModel.hero.themeChips.map((chip) => chip.label).toList();
    final alignedCount = viewModel.lensAgreements.length;



    final body = _isEmptyExperience

        ? _EmptyBody(summary: widget.result.reflection.summary)

        : ListView(

            controller: _scrollController,

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),

            children: [

              if (_showPartialBanner) ...[

                const _PartialLensBanner(),

                const SizedBox(height: FusionResultDesign.sectionGap),

              ],

              _trackSection(

                sectionId: FusionReadingDepthCalculator.fusionInsight,

                child: FusionResultHeroSection(
                  data: viewModel.hero,
                  lensTitles: lensTitles,
                  alignedCount: alignedCount,
                  onExploreDetails: _scrollToAgreement,
                ),

              ),

              const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.lifeChapter != null)
                FusionLifeChapterSection(data: viewModel.lifeChapter!),

              if (viewModel.lifeChapter != null)
                const SizedBox(height: FusionResultDesign.sectionGap),

              _trackSection(

                sectionId: FusionReadingDepthCalculator.whyThisAppears,

                child: FusionLensAgreementSection(
                  key: _agreementSectionKey,
                  items: viewModel.lensAgreements,
                  centralThemes: centralThemes,
                  alignedCount: alignedCount,
                  consensusNarrative: viewModel.consensusNarrative,
                ),

              ),

              if (viewModel.lensAgreements.isNotEmpty)

                const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.lifePattern != null)
                FusionLifePatternSection(data: viewModel.lifePattern!),

              if (viewModel.lifePattern != null)
                const SizedBox(height: FusionResultDesign.sectionGap),

              _trackSection(

                sectionId: FusionReadingDepthCalculator.sharedSignals,

                child: FusionStrengthsWarningsSection(

                  strengths: viewModel.strengths,

                  lifeTest: viewModel.lifeTest,

                ),

              ),

              if (viewModel.strengths.isNotEmpty ||

                  viewModel.lifeTest != null)

                const SizedBox(height: FusionResultDesign.sectionGap),

              if (!_isEmptyExperience)
                const FusionPeakPotentialSection(),

              if (!_isEmptyExperience)

                const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.lifeLesson != null)
                FusionLifeLessonSection(data: viewModel.lifeLesson!),

              if (viewModel.lifeLesson != null)
                const SizedBox(height: FusionResultDesign.sectionGap),

              _trackSection(

                sectionId: FusionReadingDepthCalculator.growthOpportunities,

                child: FusionGrowthPathSection(paths: viewModel.growthPaths),

              ),

              if (viewModel.growthPaths.isNotEmpty)

                const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.futureDirection != null)
                _trackSection(
                  sectionId: FusionReadingDepthCalculator.futureTendencies,
                  child: FusionDirectionSection(
                    data: viewModel.futureDirection!,
                  ),
                ),

              if (viewModel.futureDirection != null)
                const SizedBox(height: FusionResultDesign.sectionGap),

              const FusionPsychologyDiscoverySection(),

              const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.surprisingInsight != null)
                FusionSurprisingInsightSection(
                  data: viewModel.surprisingInsight!,
                ),

              if (viewModel.surprisingInsight != null)
                const SizedBox(height: FusionResultDesign.sectionGap),

              FusionKnowMeMomentSection(
                data: viewModel.knowMeMoment,
              ),

              const SizedBox(height: FusionResultDesign.sectionGap),

              if (viewModel.finalMessage != null)
                _trackSection(
                  sectionId: FusionReadingDepthCalculator.futureTendencies,
                  child: FusionFinalMessageSection(
                    data: viewModel.finalMessage!,
                  ),
                ),

            ],

          );



    if (!widget.showAppBar) {

      return FusionCosmicBackground(
        child: body,
      );

    }



    return Scaffold(

      extendBodyBehindAppBar: true,

      backgroundColor: FusionResultDesign.backgroundTop,

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        foregroundColor: FusionResultDesign.textPrimary,

        title: const Text(

          'Astrology Fusion',

          style: TextStyle(

            fontWeight: FontWeight.w600,

            color: FusionResultDesign.textPrimary,

          ),

        ),

      ),

      body: FusionCosmicBackground(
        child: SafeArea(child: body),
      ),

    );

  }

}



class _PartialLensBanner extends StatelessWidget {

  const _PartialLensBanner();



  @override

  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: FusionResultDesign.purple.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: FusionResultDesign.purple.withValues(alpha: 0.25),

        ),

      ),

      child: const Text(

        'Fusion เริ่มต้นจากข้อมูลที่มีอยู่\n'

        'ผลลัพธ์จะละเอียดขึ้นเมื่อเพิ่มศาสตร์อื่น',

        style: TextStyle(

          fontSize: 14,

          height: 1.5,

          color: FusionResultDesign.textSecondary,

        ),

      ),

    );

  }

}



class _EmptyBody extends StatelessWidget {

  const _EmptyBody({required this.summary});



  final String summary;



  @override

  Widget build(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.auto_awesome_outlined,

              size: 48,

              color: FusionResultDesign.gold,

            ),

            const SizedBox(height: 16),

            Text(

              summary,

              textAlign: TextAlign.center,

              style: const TextStyle(

                fontSize: 16,

                height: 1.6,

                color: FusionResultDesign.textSecondary,

              ),

            ),

            const SizedBox(height: 24),

            const FusionPsychologyDiscoverySection(),

          ],

        ),

      ),

    );

  }

}


