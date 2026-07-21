import 'package:flutter/material.dart';

import 'home_screen_v2_models.dart';
import 'home_v3_copy.dart';
import 'home_v35_design.dart';

/// Psychology test cards — UX Conversion Sprint V1.
class HomeV3PsychologyTestsSection extends StatelessWidget {
  const HomeV3PsychologyTestsSection({
    super.key,
    required this.data,
    required this.onTestAction,
    this.showSectionHeader = true,
  });

  final HomePsychologyTestsSectionData data;
  final void Function(HomePsychologyTestItemData test) onTestAction;
  final bool showSectionHeader;

  static const _cardStyles = <String, _PsychologyCardStyle>{
    'mbti': _PsychologyCardStyle(
      tint: Color(0xFFF3EDFC),
      accent: Color(0xFF9B7BD4),
      icon: Icons.psychology_alt_rounded,
    ),
    'eq': _PsychologyCardStyle(
      tint: Color(0xFFE8F7EF),
      accent: Color(0xFF5CB88A),
      icon: Icons.favorite_rounded,
    ),
    'big_five': _PsychologyCardStyle(
      tint: Color(0xFFEEF3F8),
      accent: Color(0xFF7A8B9E),
      icon: Icons.radar_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSectionHeader) ...[
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  HomeV3Copy.psychologyTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: HomeV35Design.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            HomeV3Copy.psychologySubtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: HomeV35Design.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cardWidth = isWide
                ? (constraints.maxWidth - HomeV35Design.cardGap * 2) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: HomeV35Design.cardGap,
              runSpacing: HomeV35Design.cardGap,
              children: [
                for (final test in data.tests)
                  SizedBox(
                    width: cardWidth,
                    child: _PsychologyCard(
                      test: test,
                      style: _cardStyles[test.id]!,
                      onPressed: () => onTestAction(test),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PsychologyCardStyle {
  const _PsychologyCardStyle({
    required this.tint,
    required this.accent,
    required this.icon,
  });

  final Color tint;
  final Color accent;
  final IconData icon;
}

class _PsychologyCard extends StatelessWidget {
  const _PsychologyCard({
    required this.test,
    required this.style,
    required this.onPressed,
  });

  final HomePsychologyTestItemData test;
  final _PsychologyCardStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final completed = test.status == HomePsychologyTestStatus.completed;
    final inProgress = test.status == HomePsychologyTestStatus.inProgress;
    final isNext = test.isNextStep && !completed;

    return Material(
      color: style.tint,
      borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
        child: Container(
          height: 188,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),
            border: isNext
                ? Border.all(color: style.accent, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  style.icon,
                  size: 72,
                  color: style.accent.withValues(alpha: 0.12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: style.accent.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(style.icon, color: style.accent, size: 20),
                      ),
                      const Spacer(),
                      if (completed)
                        Icon(
                          Icons.check_circle_rounded,
                          color: style.accent,
                          size: 22,
                        )
                      else if (inProgress)
                        Icon(
                          Icons.play_circle_outline_rounded,
                          color: style.accent,
                          size: 22,
                        )
                      else
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: style.accent,
                          size: 20,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    test.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HomeV35Design.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    test.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: HomeV35Design.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    HomeV3Copy.psychologyStatusLabel(
                      test.status,
                      isNextStep: test.isNextStep,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: style.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
