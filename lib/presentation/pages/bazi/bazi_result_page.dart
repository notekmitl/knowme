import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/astrology/chinese_zodiac/application/zodiac_interpretation_resolver.dart';
import 'package:knowme/features/astrology/chinese_zodiac/presentation/widgets/zodiac_personality_section.dart';
import 'package:knowme/features/bazi/application/bazi_evidence_layer.dart';
import 'package:knowme/features/bazi/application/bazi_summary_engine.dart';
import 'package:knowme/features/bazi/application/bazi_theme_engine.dart';
import 'package:knowme/features/bazi/domain/bazi_summary.dart';
import 'package:knowme/features/bazi/domain/bazi_theme.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';
import 'package:provider/provider.dart';

import '../../providers/bazi_provider.dart';
import '../../providers/locale_provider.dart';
import 'bazi_result_copy.dart';

class BaziResultPage extends StatefulWidget {
  const BaziResultPage({super.key, this.userId});

  /// When set (e.g. tests), skips [FirebaseAuth] lookup.
  final String? userId;

  @override
  State<BaziResultPage> createState() => _BaziResultPageState();
}

class _BaziResultPageState extends State<BaziResultPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;
      context.read<BaziProvider>().loadChart(uid);
    });
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilePageV1()),
    ).then((_) {
      if (!mounted) return;
      final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;
      context.read<BaziProvider>().loadChart(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(BaziResultCopy.pageTitle(lang)),
      ),
      body: Consumer<BaziProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return AstrologyGenerationBody(
              title: AstrologyFlowCopy.generationTitle('ดวงปาจื้อ'),
              body: AstrologyFlowCopy.generationBody('ดวงปาจื้อ'),
            );
          }

          if (provider.error != null) {
            return AstrologyFlowStateBody(
              state: AstrologyFlowState.firstGeneration,
              onPrimaryAction: () => provider.loadChart(
                widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              primaryActionLabel: AstrologyFlowCopy.retryCta,
              onRetry: () => provider.loadChart(
                widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
            );
          }

          final chart = provider.chart;
          if (chart == null) {
            return AstrologyFlowStateBody(
              state: AstrologyFlowState.firstGeneration,
              onPrimaryAction: () => _openEditProfile(context),
              primaryActionLabel: AstrologyFlowCopy.generateCta,
            );
          }

          final theme = BaziThemeEngine.build(chart, lang);
          final dominant = BaziThemeEngine.dominantHighlight(chart, lang);
          final summary = BaziSummaryEngine.build(chart, lang);
          final zodiacProfile = ZodiacInterpretationResolver.resolveFromChart(
            chart,
            lang,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _heroSection(chart, lang),
                if (dominant != null) ...[
                  const SizedBox(height: 12),
                  _dominantHighlightSection(dominant, lang),
                ],
                const SizedBox(height: 12),
                _insightSection(
                  title: BaziResultCopy.coreSelfTitle(lang),
                  child: Text(
                    theme.coreSelf,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _insightSection(
                  title: BaziResultCopy.strengthsTitle(lang),
                  child: _bulletList(theme.strengths),
                  compact: true,
                ),
                const SizedBox(height: 12),
                _insightSection(
                  title: BaziResultCopy.growthAreasTitle(lang),
                  child: _bulletList(theme.growthAreas),
                  compact: true,
                ),
                if (zodiacProfile != null) ...[
                  const SizedBox(height: 12),
                  ZodiacPersonalitySection(
                    profile: zodiacProfile,
                    animalDisplayName: ZodiacInterpretationResolver.displayAnimalName(
                      chart.yearAnimal,
                      lang,
                    ),
                    lang: lang,
                  ),
                ],
                const SizedBox(height: 12),
                _summaryCardSection(summary, lang),
                const SizedBox(height: 12),
                _detailedDataSection(chart, lang),
                const SizedBox(height: 16),
                Text(
                  BaziResultCopy.disclosure(lang),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _messageBody({required String title, required String body}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroSection(BaziChartModel chart, String lang) {
    final dm = chart.dayMaster;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            Text(
              BaziThemeEngine.heroHeadline(dm, lang),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              BaziThemeEngine.heroContextLine(lang),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              BaziThemeEngine.heroOwnershipLine(dm, lang),
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              BaziThemeEngine.heroSymbolNarrative(dm, lang),
              style: TextStyle(
                fontSize: 15,
                height: 1.48,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '${dm.pillarLabel} · ${dm.stemRoman}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dominantHighlightSection(BaziDominantHighlight highlight, String lang) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BaziResultCopy.dominantHighlightTitle(lang),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              highlight.headline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              highlight.intro,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              BaziResultCopy.chineseTraditionLabel(lang),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              BaziResultCopy.chineseElementAssociation(lang),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),
            _bulletList(highlight.associations, compact: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryCardSection(BaziSummary summary, String lang) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BaziResultCopy.summaryCardTitle(lang),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < summary.paragraphs.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Text(
                summary.paragraphs[i],
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _insightSection({
    required String title,
    required Widget child,
    bool compact = false,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, compact ? 12 : 14, 14, compact ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: compact ? 17 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _bulletList(List<String> items, {bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: compact ? 5 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: compact ? 14 : 15,
                    height: compact ? 1.38 : 1.45,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _detailedDataSection(BaziChartModel chart, String lang) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            BaziResultCopy.detailedDataTitle(lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          children: [
            _bigThreeSection(chart, lang),
            const SizedBox(height: 12),
            _fourPillarsSection(chart, lang),
            const SizedBox(height: 12),
            _elementBalanceSection(chart, lang),
            const SizedBox(height: 12),
            _metadataSection(chart, lang),
          ],
        ),
      ),
    );
  }

  Widget _evidenceSectionGroup({
    required String title,
    required String intro,
    required List<Widget> evidenceItems,
    String? introSubtitle,
    String? introNote,
    Widget? afterIntro,
    bool showEvidenceDivider = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          if (introSubtitle != null) ...[
            Text(
              introSubtitle,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 3),
          ],
          Text(
            intro,
            style: TextStyle(
              fontSize: 13,
              height: 1.38,
              color: Colors.grey.shade800,
            ),
          ),
          if (introNote != null) ...[
            const SizedBox(height: 3),
            Text(
              introNote,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          if (afterIntro != null) ...[
            const SizedBox(height: 8),
            afterIntro,
          ],
          if (showEvidenceDivider) ...[
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 8),
          ] else if (evidenceItems.isNotEmpty) ...[
            const SizedBox(height: 6),
          ],
          for (var i = 0; i < evidenceItems.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 8),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
            ],
            evidenceItems[i],
          ],
        ],
      ),
    );
  }

  Widget _bigThreeSection(BaziChartModel chart, String lang) {
    final dominant = chart.dominantElement;
    return _evidenceSectionGroup(
      title: BaziResultCopy.bigThreeTitle(lang),
      intro: BaziEvidenceLayer.bigThreeIntro(lang),
      evidenceItems: [
        _evidenceItem(
          label: BaziResultCopy.dayMasterLabel(lang),
          value: BaziEvidenceLayer.dayMasterDisplayValue(chart.dayMaster, lang),
          subValue: chart.dayMaster.pillarLabel,
          description: BaziEvidenceLayer.dayMasterEvidenceDescription(lang),
        ),
        _evidenceItem(
          label: BaziResultCopy.yearAnimalLabel(lang),
          value: BaziEvidenceLayer.yearAnimalDisplayValue(chart.yearAnimal, lang),
          subValue: chart.yearAnimal.zh,
          description: BaziEvidenceLayer.yearAnimalEvidenceDescription(lang),
        ),
        _evidenceItem(
          label: BaziResultCopy.dominantElementLabel(lang),
          value: dominant == null
              ? '—'
              : BaziResultCopy.elementLabel(dominant, lang),
          description: BaziEvidenceLayer.dominantElementEvidenceDescription(lang),
        ),
      ],
    );
  }

  Widget _fourPillarsSection(BaziChartModel chart, String lang) {
    final items = [
      ('year', chart.pillars.year),
      ('month', chart.pillars.month),
      ('day', chart.pillars.day),
      ('hour', chart.pillars.hour),
    ];

    return _evidenceSectionGroup(
      title: BaziResultCopy.fourPillarsTitle(lang),
      intro: BaziEvidenceLayer.fourPillarsIntro(lang),
      afterIntro: _elementLegend(lang),
      evidenceItems: [
        for (final item in items)
          _pillarEvidenceItem(
            item.$1,
            item.$2,
            lang,
          ),
      ],
    );
  }

  Widget _elementBalanceSection(BaziChartModel chart, String lang) {
    return _evidenceSectionGroup(
      title: BaziResultCopy.elementBalanceTitle(lang),
      introSubtitle: BaziEvidenceLayer.elementBalanceOverviewLabel(lang),
      intro: BaziEvidenceLayer.elementBalanceHowToRead(lang),
      afterIntro: _elementBalanceObservations(chart, lang),
      showEvidenceDivider: false,
      evidenceItems: [_elementBalance(chart, lang)],
    );
  }

  Widget _elementBalanceObservations(BaziChartModel chart, String lang) {
    final bullets = BaziEvidenceLayer.elementBalanceObservations(chart, lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BaziEvidenceLayer.elementBalanceObservationsTitle(lang),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        for (final bullet in bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $bullet',
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Colors.grey.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _elementLegend(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BaziEvidenceLayer.elementLegendTitle(lang),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        for (final line in BaziEvidenceLayer.elementLegendLines(lang))
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: Colors.grey.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _subsectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _metadataSection(BaziChartModel chart, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subsectionTitle(BaziResultCopy.metadataTitle(lang)),
        const SizedBox(height: 8),
        _metadata(chart, lang),
      ],
    );
  }

  Widget _evidenceItem({
    required String label,
    required String value,
    required String description,
    String? subValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subValue != null) ...[
          const SizedBox(height: 1),
          Text(
            subValue,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _pillarEvidenceItem(String role, BaziPillar pillar, String lang) {
    final secondaryStyle = TextStyle(
      fontSize: 12,
      height: 1.35,
      color: Colors.grey.shade600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BaziEvidenceLayer.pillarRoleLabel(role, lang),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          BaziEvidenceLayer.formatPillarElements(
            pillar.stemElement,
            pillar.branchElement,
            lang,
          ),
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(BaziEvidenceLayer.formatPillarCode(pillar, lang), style: secondaryStyle),
        Text(
          BaziEvidenceLayer.formatHeavenlyStemLine(pillar, lang),
          style: secondaryStyle,
        ),
        Text(
          BaziEvidenceLayer.formatEarthlyBranchLine(pillar, lang),
          style: secondaryStyle,
        ),
      ],
    );
  }

  Widget _elementBalance(BaziChartModel chart, String lang) {
    final balance = chart.elementBalance;
    final maxCount = [
      balance.wood,
      balance.fire,
      balance.earth,
      balance.metal,
      balance.water,
    ].fold<int>(0, (a, b) => a > b ? a : b);

    final entries = [
      ('wood', balance.wood),
      ('fire', balance.fire),
      ('earth', balance.earth),
      ('metal', balance.metal),
      ('water', balance.water),
    ];

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _elementBar(
            label: BaziResultCopy.elementLabel(entries[i].$1, lang),
            count: entries[i].$2,
            maxCount: maxCount == 0 ? 1 : maxCount,
          ),
        ],
      ],
    );
  }

  Widget _elementBar({
    required String label,
    required int count,
    required int maxCount,
  }) {
    final fraction = count / maxCount;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF7E57C2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _metadata(BaziChartModel chart, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(BaziResultCopy.metadataVersionLabel(lang), chart.version),
        const SizedBox(height: 8),
        _infoRow(BaziResultCopy.metadataEngineLabel(lang), chart.engineVersion),
        const SizedBox(height: 8),
        _infoRow(
          BaziResultCopy.metadataGeneratedAtLabel(lang),
          chart.generatedAt,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
