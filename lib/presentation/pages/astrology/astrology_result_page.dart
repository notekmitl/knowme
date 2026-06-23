import 'package:flutter/material.dart';



import 'package:provider/provider.dart';



import 'package:firebase_auth/firebase_auth.dart';

import 'package:knowme/core/i18n/app_text.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_state.dart';
import 'package:knowme/features/astrology/shared/astrology_flow_widgets.dart';
import 'package:knowme/presentation/pages/profile/edit_profile_page_v1.dart';
import 'package:knowme/data/models/astrology_chart_model.dart';

import 'package:knowme/features/tests/mbti/mbti_routes.dart';



import 'astrology_big3_microcopy.dart';
import 'astrology_deep_lens.dart';
import 'astrology_hero_synthesis.dart';
import 'astrology_result_copy.dart';
import 'astrology_result_locale.dart';

import '../../providers/astrology_provider.dart';

import '../../providers/locale_provider.dart';



class AstrologyResultPage extends StatefulWidget {

  const AstrologyResultPage({super.key});



  @override

  State<AstrologyResultPage> createState() => _AstrologyResultPageState();

}



class _AstrologyResultPageState extends State<AstrologyResultPage> {

  @override

  void initState() {

    super.initState();



    Future.microtask(() {

      if (!mounted) return;

      AstrologyResultLocale.apply(

        context.read<LocaleProvider>().locale.languageCode,

      );



      final uid = FirebaseAuth.instance.currentUser!.uid;

      context.read<AstrologyProvider>().loadChart(uid);

    });

  }



  void _setLanguage(String languageCode) {

    context.read<LocaleProvider>().setLocale(languageCode);

    AstrologyResultLocale.apply(languageCode);

    setState(() {});

  }



  String _planetPlacementLine(Map<String, dynamic> data, String lang) {

    final sign = AstrologyResultCopy.signLabel('${data['sign'] ?? ''}', lang);

    final house = '${data['house'] ?? '—'}';

    return AppText.t('astro_planet_placement')

        .replaceAll('{sign}', sign)

        .replaceAll('{house}', house);

  }



  Widget _sectionTitle(String title, {String? subtitle}) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: const TextStyle(

            color: Colors.white,

            fontSize: 26,

            fontWeight: FontWeight.bold,

          ),

        ),

        if (subtitle != null) ...[

          const SizedBox(height: 10),

          Text(

            subtitle,

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 15,

              height: 1.45,

            ),

          ),

        ],

      ],

    );

  }



  String _deepLensText(AstrologyChartModel chart, String lang) {
    final local = AstrologyDeepLens.fromBig3(chart.big3, lang);
    if (local.trim().isNotEmpty) return local.trim();
    return AstrologyResultLocale.bilingualField(
      chart.overallSummary,
      lang,
      preparingKey: 'astro_deep_preparing',
    );
  }

  Widget _mirrorCard(String body, String lang, String debugLabel) {

    AstrologyResultLocale.assertLocaleIntegrity(lang, debugLabel, body);

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.08),

        borderRadius: BorderRadius.circular(24),

      ),

      child: Text(

        body,

        style: const TextStyle(

          color: Colors.white,

          fontSize: 17,

          height: 1.75,

        ),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    final provider = context.watch<AstrologyProvider>();

    final localeProvider = context.watch<LocaleProvider>();

    final chart = provider.chart;

    final lang = AstrologyResultLocale.langFromProvider(localeProvider);

    final planetInterpretations = chart != null
        ? AstrologyResultLocale.planetInterpretationsMap(chart, lang)
        : const <String, String>{};

    return Scaffold(

      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        title: Text(AppText.t('astro_app_bar_title')),

        actions: [

          TextButton(

            onPressed: () => _setLanguage('th'),

            child: Text(

              'TH',

              style: TextStyle(

                color: lang == 'th' ? Colors.white : Colors.white54,

                fontWeight:

                    lang == 'th' ? FontWeight.bold : FontWeight.normal,

              ),

            ),

          ),

          TextButton(

            onPressed: () => _setLanguage('en'),

            child: Text(

              'EN',

              style: TextStyle(

                color: lang == 'en' ? Colors.white : Colors.white54,

                fontWeight:

                    lang == 'en' ? FontWeight.bold : FontWeight.normal,

              ),

            ),

          ),

          const SizedBox(width: 12),

        ],

      ),

      body: provider.isLoading
          ? AstrologyGenerationBody(
              title: AstrologyFlowCopy.generationTitle('ดวงตะวันตก'),
              body: AstrologyFlowCopy.generationBody('ดวงตะวันตก'),
            )
          : provider.error != null
              ? AstrologyFlowStateBody(
                  state: AstrologyFlowState.firstGeneration,
                  onPrimaryAction: () {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    context.read<AstrologyProvider>().loadChart(uid);
                  },
                  primaryActionLabel: AstrologyFlowCopy.retryCta,
                )
              : chart == null
                  ? AstrologyFlowStateBody(
                      state: AstrologyFlowState.firstGeneration,
                      onPrimaryAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePageV1(),
                        ),
                      ),
                      primaryActionLabel: AstrologyFlowCopy.generateCta,
                    )
                  : Container(

                      decoration: const BoxDecoration(

                        gradient: LinearGradient(

                          colors: [

                            Color(0xFF0B1020),

                            Color(0xFF1A2340),

                            Color(0xFF2D1B4E),

                          ],

                          begin: Alignment.topCenter,

                          end: Alignment.bottomCenter,

                        ),

                      ),

                      child: SingleChildScrollView(

                        padding: const EdgeInsets.all(24),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            const SizedBox(height: 8),

                            Text(

                              AppText.t('astro_hero_eyebrow'),

                              style: TextStyle(

                                color: Colors.purple.shade100.withOpacity(0.9),

                                fontSize: 13,

                                fontWeight: FontWeight.w600,

                                letterSpacing: 0.6,

                              ),

                            ),

                            const SizedBox(height: 8),

                            Text(

                              AppText.t('astro_hero_supporting'),

                              style: const TextStyle(

                                color: Colors.white60,

                                fontSize: 15,

                              ),

                            ),

                            const SizedBox(height: 20),

                            Builder(

                              builder: (context) {

                                final hero = AstrologyHeroSynthesis.build(

                                  chart,

                                  lang: lang,

                                );

                                AstrologyResultLocale.assertLocaleIntegrity(

                                  lang,

                                  'hero',

                                  hero,

                                );

                                return Text(

                                  hero,

                                  style: TextStyle(

                                    color: Colors.white.withOpacity(0.92),

                                    fontSize: 19,

                                    height: 1.65,

                                    fontWeight: FontWeight.w400,

                                  ),

                                );

                              },

                            ),

                            const SizedBox(height: 44),

                            _sectionTitle(

                              AppText.t('astro_big3_title'),

                              subtitle: AppText.t('astro_big3_subtitle'),

                            ),

                            const SizedBox(height: 22),

                            Row(

                              children: [

                                Expanded(

                                  child: _big3Card(

                                    '☀',

                                    AppText.t('astro_big3_sun'),

                                    AstrologyResultCopy.signLabel(

                                      chart.big3['sun']?.toString(),

                                      lang,

                                    ),

                                    AstrologyBig3Microcopy.forRole(

                                      AstroBig3Role.sun,

                                      chart.big3['sun'],

                                      lang,

                                    ),

                                  ),

                                ),

                                const SizedBox(width: 12),

                                Expanded(

                                  child: _big3Card(

                                    '🌙',

                                    AppText.t('astro_big3_inner'),

                                    AstrologyResultCopy.signLabel(

                                      chart.big3['moon']?.toString(),

                                      lang,

                                    ),

                                    AstrologyBig3Microcopy.forRole(

                                      AstroBig3Role.moon,

                                      chart.big3['moon'],

                                      lang,

                                    ),

                                  ),

                                ),

                                const SizedBox(width: 12),

                                Expanded(

                                  child: _big3Card(

                                    '⬆',

                                    AppText.t('astro_big3_rising'),

                                    AstrologyResultCopy.signLabel(

                                      chart.big3['rising']?.toString(),

                                      lang,

                                    ),

                                    AstrologyBig3Microcopy.forRole(

                                      AstroBig3Role.rising,

                                      chart.big3['rising'],

                                      lang,

                                    ),

                                  ),

                                ),

                              ],

                            ),

                            const SizedBox(height: 40),

                            _sectionTitle(

                              AppText.t('astro_insight_title'),

                              subtitle: AppText.t('astro_insight_subtitle'),

                            ),

                            const SizedBox(height: 18),

                            _mirrorCard(

                              AstrologyResultLocale.bilingualField(

                                chart.insight,

                                lang,

                                preparingKey: 'astro_insight_preparing',

                              ),

                              lang,

                              'insight',

                            ),

                            const SizedBox(height: 36),

                            _sectionTitle(

                              AppText.t('astro_deep_title'),

                              subtitle: AppText.t('astro_deep_subtitle'),

                            ),

                            const SizedBox(height: 18),

                            _mirrorCard(

                              _deepLensText(chart, lang),

                              lang,

                              'overall_summary',

                            ),

                            const SizedBox(height: 44),

                            _sectionTitle(

                              AppText.t('astro_planets_title'),

                              subtitle: AppText.t('astro_planets_subtitle'),

                            ),

                            const SizedBox(height: 14),

                            Text(

                              AppText.t('astro_planets_intro'),

                              style: const TextStyle(

                                color: Colors.white54,

                                fontSize: 14,

                                height: 1.4,

                              ),

                            ),

                            const SizedBox(height: 28),

                            ...chart.planets.entries.map((entry) {

                              final planet = entry.key;

                              final data = entry.value;

                              final planetName =

                                  AstrologyResultCopy.planetLabel(planet, lang);

                              final interpretation =

                                  AstrologyResultLocale.planetInterpretation(

                                chart,

                                planet,

                                lang,

                                planetData: data,

                                precomputedBig7: planetInterpretations,

                              );

                              AstrologyResultLocale.assertLocaleIntegrity(

                                lang,

                                'planet_$planet',

                                interpretation,

                              );



                              return Container(

                                margin: const EdgeInsets.only(bottom: 20),

                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(

                                  color: Colors.white.withOpacity(0.08),

                                  borderRadius: BorderRadius.circular(20),

                                ),

                                child: Row(

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [

                                    Container(

                                      width: 52,

                                      height: 52,

                                      decoration: BoxDecoration(

                                        color: Colors.purpleAccent

                                            .withOpacity(0.25),

                                        borderRadius: BorderRadius.circular(16),

                                      ),

                                      child: Center(

                                        child: Text(

                                          planetName.isNotEmpty

                                              ? planetName[0]

                                              : '?',

                                          style: const TextStyle(

                                            color: Colors.white,

                                            fontSize: 22,

                                            fontWeight: FontWeight.bold,

                                          ),

                                        ),

                                      ),

                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(

                                      child: Column(

                                        crossAxisAlignment:

                                            CrossAxisAlignment.start,

                                        children: [

                                          Text(

                                            planetName,

                                            style: const TextStyle(

                                              color: Colors.white,

                                              fontSize: 20,

                                              fontWeight: FontWeight.bold,

                                            ),

                                          ),

                                          const SizedBox(height: 6),

                                          Text(

                                            _planetPlacementLine(data, lang),

                                            style: const TextStyle(

                                              color: Colors.white70,

                                              fontSize: 15,

                                            ),

                                          ),

                                          const SizedBox(height: 14),

                                          Text(

                                            interpretation,

                                            style: const TextStyle(

                                              color: Colors.white,

                                              fontSize: 15,

                                              height: 1.7,

                                            ),

                                          ),

                                        ],

                                      ),

                                    ),

                                  ],

                                ),

                              );

                            }),

                            const SizedBox(height: 48),

                            Text(

                              AppText.t('astro_result_cta_mbti'),

                              style: const TextStyle(

                                color: Colors.white,

                                fontSize: 20,

                                fontWeight: FontWeight.w600,

                                height: 1.4,

                              ),

                            ),

                            const SizedBox(height: 10),

                            Text(

                              AppText.t('astro_result_cta_mbti_support'),

                              style: const TextStyle(

                                color: Colors.white70,

                                fontSize: 15,

                                height: 1.5,

                              ),

                            ),

                            const SizedBox(height: 18),

                            SizedBox(

                              width: double.infinity,

                              child: ElevatedButton(

                                onPressed: () {

                                  Navigator.push(

                                    context,

                                    MbtiRoutes.miniTestRoute(),

                                  );

                                },

                                style: ElevatedButton.styleFrom(

                                  backgroundColor: Colors.purpleAccent,

                                  foregroundColor: Colors.white,

                                  padding: const EdgeInsets.symmetric(

                                    vertical: 16,

                                  ),

                                  shape: RoundedRectangleBorder(

                                    borderRadius: BorderRadius.circular(16),

                                  ),

                                ),

                                child: Text(

                                  AppText.t('astro_result_cta_mbti_action'),

                                ),

                              ),

                            ),

                            const SizedBox(height: 24),

                          ],

                        ),

                      ),

                    ),

    );

  }



  Widget _big3Card(
    String emoji,
    String title,
    String value,
    String microInsight,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (microInsight.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              microInsight,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

}


