import 'package:flutter/material.dart';



import 'home_screen_v3_models.dart';

import 'home_v3_copy.dart';

import 'home_v35_design.dart';

import 'home_v35_theme_visuals.dart';



/// KnowMe insight cards — Home V3.8 Section 3 (meaning-first).

class HomeKnowMeInsightSection extends StatelessWidget {

  const HomeKnowMeInsightSection({

    super.key,

    required this.data,

    required this.onViewFullInsight,

  });



  final HomeKnowMeInsightSectionData data;

  final void Function() onViewFullInsight;



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        Row(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Expanded(

              child: Text(

                HomeV3Copy.insightSectionTitle,

                style: const TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.w700,

                  color: HomeV35Design.textPrimary,

                ),

              ),

            ),

            if (data.canOpenFullInsight)

              TextButton(

                onPressed: onViewFullInsight,

                style: TextButton.styleFrom(

                  padding: const EdgeInsets.symmetric(horizontal: 4),

                  minimumSize: Size.zero,

                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                ),

                child: Text(

                  '${HomeV3Copy.viewFullInsight} ›',

                  style: const TextStyle(

                    fontSize: 13,

                    fontWeight: FontWeight.w600,

                    color: HomeV35Design.purpleAccent,

                  ),

                ),

              ),

          ],

        ),

        const SizedBox(height: 16),

        if (data.cards.isEmpty)

          _EmptyInsight(hint: data.emptyHint)

        else

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

                  for (final card in data.cards)

                    SizedBox(

                      width: cardWidth,

                      child: _InsightCard(card: card),

                    ),

                ],

              );

            },

          ),

      ],

    );

  }

}



class _InsightCard extends StatelessWidget {

  const _InsightCard({required this.card});



  final HomeInsightCardData card;



  @override

  Widget build(BuildContext context) {

    final accent = HomeV35ThemeVisuals.accentFor(card.visualKind);



    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: HomeV35Design.surface,

        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),

        boxShadow: [HomeV35Design.cardShadow],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            width: 44,

            height: 44,

            decoration: BoxDecoration(

              color: HomeV35ThemeVisuals.softBackgroundFor(card.visualKind),

              shape: BoxShape.circle,

            ),

            child: Icon(

              HomeV35ThemeVisuals.iconFor(card.visualKind),

              color: accent,

              size: 22,

            ),

          ),

          const SizedBox(height: 14),

          Text(

            card.humanMeaning,

            style: const TextStyle(

              fontSize: 16,

              fontWeight: FontWeight.w700,

              color: HomeV35Design.textPrimary,

              height: 1.4,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            card.supportingExplanation,

            style: const TextStyle(

              fontSize: 14,

              height: 1.5,

              color: HomeV35Design.textSecondary,

            ),

          ),

        ],

      ),

    );

  }

}



class _EmptyInsight extends StatelessWidget {

  const _EmptyInsight({required this.hint});



  final String hint;



  @override

  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: HomeV35Design.surface.withValues(alpha: 0.8),

        borderRadius: BorderRadius.circular(HomeV35Design.cardRadius),

      ),

      child: Text(

        hint,

        style: const TextStyle(

          fontSize: 14,

          height: 1.5,

          color: HomeV35Design.textSecondary,

        ),

      ),

    );

  }

}


