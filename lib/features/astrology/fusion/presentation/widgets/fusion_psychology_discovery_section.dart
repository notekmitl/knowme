import 'package:flutter/material.dart';
import 'package:knowme/features/personality_mirror/personality_mirror_routes.dart';
import 'package:knowme/features/tests/big_five/big_five_routes.dart';
import 'package:knowme/features/tests/eq/eq_routes.dart';
import 'package:knowme/features/tests/mbti/mbti_routes.dart';

import '../fusion_result_design.dart';

/// Section 6 — Psychology discovery cards.
class FusionPsychologyDiscoverySection extends StatelessWidget {
  const FusionPsychologyDiscoverySection({super.key});

  static const _cards = [
    _PsychologyCardData(
      id: 'mbti',
      title: 'MBTI',
      description: 'สำรวจแนวโน้มบุคลิกภาพของคุณ',
      icon: Icons.psychology_alt_rounded,
      accent: Color(0xFF9B7BD4),
    ),
    _PsychologyCardData(
      id: 'eq',
      title: 'EQ',
      description: 'สำรวจความฉลาดทางอารมณ์ของคุณ',
      icon: Icons.favorite_rounded,
      accent: Color(0xFF5CB88A),
    ),
    _PsychologyCardData(
      id: 'big_five',
      title: 'Big Five',
      description: 'สำรวจลักษณะบุคลิกหลักของคุณ',
      icon: Icons.radar_rounded,
      accent: Color(0xFF7A8B9E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Text('🧠', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'อยากรู้จักตัวเองมากขึ้น?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FusionResultDesign.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cardWidth = isWide
                ? (constraints.maxWidth - FusionResultDesign.cardGap * 2) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: FusionResultDesign.cardGap,
              runSpacing: FusionResultDesign.cardGap,
              children: [
                for (final card in _cards)
                  SizedBox(
                    width: cardWidth,
                    child: _PsychologyCard(card: card),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PsychologyCardData {
  const _PsychologyCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}

class _PsychologyCard extends StatefulWidget {
  const _PsychologyCard({required this.card});

  final _PsychologyCardData card;

  @override
  State<_PsychologyCard> createState() => _PsychologyCardState();
}

class _PsychologyCardState extends State<_PsychologyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: FusionResultDesign.cosmicCard(
          fill: _hovered
              ? const Color(0xFF221840)
              : FusionResultDesign.cardFill.withValues(alpha: 0.92),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context, card.id),
            borderRadius: BorderRadius.circular(FusionResultDesign.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: card.accent.withValues(alpha: 0.15),
                    ),
                    child: Icon(card.icon, color: card.accent, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: FusionResultDesign.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: FusionResultDesign.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: card.accent.withValues(alpha: _hovered ? 0.25 : 0.12),
                        border: Border.all(
                          color: card.accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: card.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, String id) {
    switch (id) {
      case 'mbti':
        Navigator.of(context).push(MbtiRoutes.miniTestRoute());
      case 'eq':
        Navigator.of(context).push(EqRoutes.home());
      case 'big_five':
        BigFiveRoutes.openTest(context);
      default:
        PersonalityMirrorRoutes.open(context);
    }
  }
}
