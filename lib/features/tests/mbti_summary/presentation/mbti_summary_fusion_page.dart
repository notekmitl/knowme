import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:knowme/core/i18n/app_text.dart';

import '../application/mbti_summary_loader.dart';
import '../domain/mbti_summary_insight_models.dart';
import '../domain/mbti_summary_models.dart';
import 'mbti_summary_gate_page.dart';
import 'widgets/mbti_summary_insight_block.dart';
import 'widgets/mbti_summary_layout.dart';
import 'widgets/mbti_summary_section_card.dart';
import 'widgets/mbti_summary_soft_disclosure.dart';
import 'widgets/mbti_summary_text_format.dart';

class MbtiSummaryFusionPage extends StatefulWidget {
  const MbtiSummaryFusionPage({super.key});

  @override
  State<MbtiSummaryFusionPage> createState() => _MbtiSummaryFusionPageState();
}

class _MbtiSummaryFusionPageState extends State<MbtiSummaryFusionPage> {
  final _loader = MbtiSummaryLoader();

  bool _loading = true;
  MbtiSummaryFusionContent? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const MbtiSummaryGatePage(),
        ),
      );
      return;
    }

    final availability = await _loader.loadAvailability(uid);
    if (!availability.canOpenFusion) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MbtiSummaryGatePage(
            args: MbtiSummaryGateArgs(availability: availability),
          ),
        ),
      );
      return;
    }

    final content = await _loader.loadFusionContent(uid);
    if (!mounted) return;

    setState(() {
      _content = content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_summary_title'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final content = _content;
    if (content == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.t('mbti_summary_title'))),
        body: Center(child: Text(AppText.t('mbti_sum_load_error'))),
      );
    }

    final view = content.view;
    final insights = content.insights;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.t('mbti_summary_title')),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _FusionHero(hero: insights.hero),
            const SizedBox(height: MbtiSummaryLayout.spaceSm),
            Text(
              AppText.t('mbti_sum_disclaimer'),
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: MbtiSummaryLayout.sectionGap),
            _ProfileSection(
              profile: insights.profileInsight,
              accentColor: _subtitleColor(insights.profileInsight.subtitle),
            ),
            const SizedBox(height: MbtiSummaryLayout.sectionGap),
            _ThinkingSection(thinking: insights.thinkingInsight),
            const SizedBox(height: MbtiSummaryLayout.sectionGap),
            _ConfidenceSection(
              view: view,
              extras: insights.confidenceExtras,
            ),
            const SizedBox(height: MbtiSummaryLayout.sectionGap),
            _GrowthSection(growth: insights.growthInsight),
          ],
        ),
      ),
    );
  }

  Color _subtitleColor(String subtitle) {
    final strong = AppText.t('mbti_sum_profile_subtitle_strong');
    final partial = AppText.t('mbti_sum_profile_subtitle_partial');
    if (subtitle == strong) return Colors.green.shade700;
    if (subtitle == partial) return Colors.amber.shade800;
    return Colors.indigo.shade600;
  }
}

class _FusionHero extends StatelessWidget {
  const _FusionHero({required this.hero});

  final MbtiSummaryHeroInsight hero;

  @override
  Widget build(BuildContext context) {
    final synthesis = _heroSynthesis(hero.paragraphs);

    return LayoutBuilder(
      builder: (context, constraints) {
        final synthesisMaxWidth = MbtiSummaryLayout.heroSynthesisMaxWidth(
          constraints.maxWidth,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            MbtiSummaryLayout.heroPaddingH,
            MbtiSummaryLayout.heroPaddingV,
            MbtiSummaryLayout.heroPaddingH,
            MbtiSummaryLayout.heroPaddingV,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade900,
                Colors.deepPurple.shade700,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.t('mbti_sum_hero_label'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: MbtiSummaryLayout.heroEyebrowGap),
              Text(
                hero.identityLine,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.22,
                  letterSpacing: 0.02,
                ),
              ),
              const SizedBox(height: MbtiSummaryLayout.heroIdentityRoleGap),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.34,
                    ),
                  ),
                  if (hero.roleLabelEnglish != null) ...[
                    const SizedBox(height: MbtiSummaryLayout.heroRoleEnGap),
                    Text(
                      hero.roleLabelEnglish!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
              if (synthesis.isNotEmpty) ...[
                const SizedBox(height: MbtiSummaryLayout.heroSummaryGap),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: synthesisMaxWidth),
                  child: Text(
                    synthesis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 14,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _heroSynthesis(List<String> paragraphs) {
    if (paragraphs.isEmpty) return '';
    return MbtiSummaryTextFormat.singleParagraph(
      paragraphs.take(2).join(' '),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.profile,
    this.accentColor,
  });

  final MbtiSummaryProfileInsight profile;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final blocks = MbtiSummaryTextFormat.profileBlocks(profile.paragraph);

    return MbtiSummarySectionCard(
      title: AppText.t('mbti_sum_section_profile'),
      icon: Icons.hub_outlined,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            profile.subtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accentColor ?? Colors.grey.shade900,
              height: 1.3,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: MbtiSummaryLayout.profileSubtitleGap),
          ...blocks.asMap().entries.map((entry) {
            final isFirst = entry.key == 0;
            final isLead = isFirst && blocks.length > 1;
            return Padding(
              padding: EdgeInsets.only(
                top: entry.key == 0 ? 0 : MbtiSummaryLayout.profileBlockGap,
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: MbtiSummaryLayout.profileBodySize,
                  height: 1.58,
                  fontWeight: isLead ? FontWeight.w600 : FontWeight.w400,
                  color: isLead
                      ? Colors.grey.shade900
                      : Colors.grey.shade800,
                ),
                textAlign: TextAlign.left,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ThinkingSection extends StatelessWidget {
  const _ThinkingSection({required this.thinking});

  final MbtiSummaryThinkingInsight thinking;

  @override
  Widget build(BuildContext context) {
    return MbtiSummarySectionCard(
      title: AppText.t('mbti_sum_section_decide'),
      icon: Icons.psychology_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < thinking.items.length; i++) ...[
            if (i > 0) const SizedBox(height: MbtiSummaryLayout.insightBlockGap),
            MbtiSummaryInsightBlock(
              pair: thinking.items[i],
              blockIndex: i,
              showMicroAnchor: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({required this.growth});

  final MbtiSummaryGrowthInsight growth;

  @override
  Widget build(BuildContext context) {
    return MbtiSummarySectionCard(
      title: AppText.t('mbti_sum_section_growth'),
      icon: Icons.lightbulb_outline,
      accentColor: Colors.amber.shade800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < growth.items.length; i++) ...[
            if (i > 0) const SizedBox(height: MbtiSummaryLayout.insightBlockGap),
            MbtiSummaryInsightBlock(
              pair: growth.items[i],
              blockIndex: i,
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceSection extends StatelessWidget {
  const _ConfidenceSection({
    required this.view,
    required this.extras,
  });

  final MbtiSummaryFusionView view;
  final MbtiSummaryConfidenceExtras extras;

  @override
  Widget build(BuildContext context) {
    final hasExtras = extras.strengthBullets.isNotEmpty ||
        extras.careerSuggestions.isNotEmpty;

    return MbtiSummarySectionCard(
      title: AppText.t('mbti_sum_confidence_title'),
      icon: Icons.layers_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              AppText.t(view.confidenceKey),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple.shade700,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: MbtiSummaryLayout.spaceXs),
          Text(
            AppText.t('mbti_sum_confidence_detail')
                .replaceAll('{mbti}', '${view.mbtiScoredQuestionCount}')
                .replaceAll(
                  '{cognitive}',
                  '${view.cognitiveScoredQuestionCount}',
                ),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.left,
          ),
          if (hasExtras) ...[
            const SizedBox(height: MbtiSummaryLayout.confidenceExtrasTopGap),
            if (extras.strengthBullets.isNotEmpty)
              MbtiSummarySoftDisclosure(
                title: AppText.t('mbti_sum_confidence_strengths_title'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: extras.strengthBullets
                      .map((b) => _BulletLine(text: b))
                      .toList(),
                ),
              ),
            if (extras.strengthBullets.isNotEmpty &&
                extras.careerSuggestions.isNotEmpty)
              const SizedBox(height: MbtiSummaryLayout.disclosureGap),
            if (extras.careerSuggestions.isNotEmpty)
              MbtiSummarySoftDisclosure(
                title: AppText.t('mbti_sum_confidence_careers_title'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: extras.careerSuggestions
                      .map((b) => _BulletLine(text: b))
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: MbtiSummaryLayout.disclosureItemGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              '•',
              style: TextStyle(
                fontSize: 11,
                height: 1.55,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
