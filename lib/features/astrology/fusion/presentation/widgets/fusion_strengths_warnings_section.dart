import 'package:flutter/material.dart';

import '../fusion_result_design.dart';
import '../fusion_result_view_model.dart';
import 'fusion_interactive_card.dart';
import 'fusion_reflection_strip.dart';

/// Strengths + recurring life tests — V6.
class FusionStrengthsWarningsSection extends StatelessWidget {
  const FusionStrengthsWarningsSection({
    super.key,
    required this.strengths,
    this.lifeTest,
  });

  final List<FusionStrengthViewModel> strengths;
  final FusionLifeTestViewModel? lifeTest;

  @override
  Widget build(BuildContext context) {
    if (strengths.isEmpty && lifeTest == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= FusionResultDesign.wideBreakpoint;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StrengthsPanel(strengths: strengths)),
              if (lifeTest != null) ...[
                const SizedBox(width: FusionResultDesign.cardGap),
                Expanded(child: _LifeTestPanel(lifeTest: lifeTest!)),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StrengthsPanel(strengths: strengths),
            if (lifeTest != null) ...[
              const SizedBox(height: FusionResultDesign.sectionGap),
              _LifeTestPanel(lifeTest: lifeTest!),
            ],
          ],
        );
      },
    );
  }
}

class _StrengthsPanel extends StatelessWidget {
  const _StrengthsPanel({required this.strengths});

  final List<FusionStrengthViewModel> strengths;

  @override
  Widget build(BuildContext context) {
    if (strengths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(
          icon: '✨',
          title: 'จุดแข็งของคุณ',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 280;
            final cardWidth = isWide && strengths.length > 1
                ? (constraints.maxWidth - FusionResultDesign.cardGap) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: FusionResultDesign.cardGap,
              runSpacing: FusionResultDesign.cardGap,
              children: [
                for (final strength in strengths)
                  SizedBox(
                    width: strengths.length == 1 ? constraints.maxWidth : cardWidth,
                    child: _StrengthInsightCard(strength: strength),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StrengthInsightCard extends StatelessWidget {
  const _StrengthInsightCard({required this.strength});

  final FusionStrengthViewModel strength;

  @override
  Widget build(BuildContext context) {
    return FusionInteractiveCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: FusionResultDesign.gold.withValues(alpha: 0.45)),
              color: FusionResultDesign.gold.withValues(alpha: 0.1),
            ),
            child: Icon(
              strength.icon,
              color: FusionResultDesign.gold,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strength.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: FusionResultDesign.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            strength.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: FusionResultDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTestPanel extends StatelessWidget {
  const _LifeTestPanel({required this.lifeTest});

  final FusionLifeTestViewModel lifeTest;

  @override
  Widget build(BuildContext context) {
    return FusionReflectionStrip(
      title: lifeTest.title,
      body: lifeTest.body,
      compact: true,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
  });

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: FusionResultDesign.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
