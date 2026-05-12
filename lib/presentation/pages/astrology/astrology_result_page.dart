import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
      final uid = FirebaseAuth.instance.currentUser!.uid;

      context.read<AstrologyProvider>().loadChart(uid);
    });
  }

  String translateSign(String sign, bool isThai) {
    if (!isThai) {
      return sign;
    }

    final signs = {
      'Aries': 'ราศีเมษ',
      'Taurus': 'ราศีพฤษภ',
      'Gemini': 'ราศีเมถุน',
      'Cancer': 'ราศีกรกฎ',
      'Leo': 'ราศีสิงห์',
      'Virgo': 'ราศีกันย์',
      'Libra': 'ราศีตุลย์',
      'Scorpio': 'ราศีพิจิก',
      'Sagittarius': 'ราศีธนู',
      'Capricorn': 'ราศีมังกร',
      'Aquarius': 'ราศีกุมภ์',
      'Pisces': 'ราศีมีน',
    };

    return signs[sign] ?? sign;
  }

  String translatePlanet(String planet, bool isThai) {
    if (!isThai) {
      return planet.toUpperCase();
    }

    final planets = {
      'sun': 'อาทิตย์',
      'moon': 'จันทร์',
      'mercury': 'พุธ',
      'venus': 'ศุกร์',
      'mars': 'อังคาร',
      'jupiter': 'พฤหัส',
      'saturn': 'เสาร์',
      'uranus': 'ยูเรนัส',
      'neptune': 'เนปจูน',
      'pluto': 'พลูโต',
    };

    return planets[planet.toLowerCase()] ?? planet;
  }

  String getPlanetInterpretation(
    String planet,
    Map<String, dynamic> data,
    bool isThai,
  ) {
    if (isThai) {
      final interpretations = {
        'mars':
            'คุณเป็นคนที่จัดการความขัดแย้งอย่างนุ่มนวล ไม่ชอบการปะทะตรงๆ พลังการลงมือทำของคุณเกี่ยวข้องกับบ้าน ครอบครัว และความมั่นคงทางอารมณ์',

        'venus':
            'คุณให้ความสำคัญกับความรักที่มั่นคง จริงใจ และปลอดภัยทางอารมณ์ มีเสน่ห์และรสนิยมเฉพาะตัว',

        'moon':
            'โลกอารมณ์ของคุณเต็มไปด้วยอิสระ ความฝัน และการค้นหาความหมายชีวิต คุณต้องการพื้นที่ในการเติบโตทางอารมณ์',

        'sun':
            'ตัวตนหลักของคุณขับเคลื่อนด้วยความอยากเรียนรู้ ความคิดสร้างสรรค์ และการสื่อสาร คุณเป็นคนปรับตัวเก่งและชอบสำรวจสิ่งใหม่',

        'mercury':
            'คุณมีวิธีคิดที่รวดเร็ว ช่างสังเกต และสามารถเชื่อมโยงข้อมูลได้ดี การสื่อสารคือจุดแข็งสำคัญของคุณ',

        'jupiter':
            'คุณเติบโตผ่านการเปลี่ยนแปลงภายใน การเข้าใจชีวิตเชิงลึก และการเรียนรู้ด้านจิตใจ',

        'saturn':
            'คุณให้ความสำคัญกับความรับผิดชอบ ความมั่นคง และการสร้างสมดุลในชีวิตอย่างจริงจัง',
      };

      return interpretations[planet.toLowerCase()] ??
          'ดาวดวงนี้สะท้อนพลังสำคัญบางอย่างในตัวคุณ';
    }

    final interpretations = {
      'mars':
          'You handle conflict gently and prefer diplomacy over confrontation. Your action energy connects strongly with emotional security and family life.',

      'venus':
          'You value loyalty, emotional security, and genuine relationships. Love must feel stable and sincere for you.',

      'moon':
          'Your emotional world seeks freedom, meaning, and emotional growth. You need space to explore your inner self.',

      'sun':
          'Your core identity is driven by curiosity, creativity, and communication. You adapt quickly and enjoy exploring new things.',

      'mercury':
          'Your mind is quick, observant, and highly communicative. Connecting ideas naturally is one of your strengths.',

      'jupiter':
          'You grow through deep transformation, emotional insight, and understanding life on a deeper level.',

      'saturn':
          'You take responsibility seriously and seek balance, stability, and long-term structure in life.',
    };

    return interpretations[planet.toLowerCase()] ??
        'This planet reflects an important part of your personality.';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstrologyProvider>();

    final chart = provider.chart;

    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        elevation: 0,

        title: Text(isThai ? 'โหราศาสตร์ KnowMe' : 'KnowMe Astrology'),

        actions: [
          TextButton(
            onPressed: () {
              context.read<LocaleProvider>().setLocale('th');
            },

            child: const Text('TH', style: TextStyle(color: Colors.white)),
          ),

          TextButton(
            onPressed: () {
              context.read<LocaleProvider>().setLocale('en');
            },

            child: const Text('EN', style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(width: 12),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(child: Text(provider.error!))
          : chart == null
          ? Center(
              child: Text(
                isThai ? 'ไม่พบข้อมูลดวง' : 'No astrology data found',

                style: const TextStyle(color: Colors.white),
              ),
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
                    const SizedBox(height: 16),

                    Text(
                      isThai
                          ? 'ตัวตนแห่งจักรวาลของคุณ'
                          : 'Your Cosmic Identity',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 34,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isThai
                          ? 'ขับเคลื่อนโดย KnowMe Insight Engine'
                          : 'Powered by KnowMe Insight Engine',

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      isThai ? 'แกนพลังหลักของคุณ' : 'Your Core Cosmic Energy',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 28,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isThai
                          ? 'บุคลิกหลักที่สะท้อนตัวตนและพลังงานภายในของคุณ'
                          : 'Your main personality energy from astrology',

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _big3Card(
                            '☀',

                            isThai ? 'ตัวตนภายนอก' : 'Outer Self',

                            translateSign(chart.big3['sun'], isThai),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _big3Card(
                            '🌙',

                            isThai ? 'อารมณ์ภายใน' : 'Inner Emotion',

                            translateSign(chart.big3['moon'], isThai),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _big3Card(
                            '⬆',

                            isThai ? 'ภาพลักษณ์' : 'First Impression',

                            translateSign(chart.big3['rising'], isThai),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Text(
                      isThai ? 'ภาพรวมบุคลิก' : 'Personality Insight',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 28,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Text(
                        isThai
                            ? chart.insight['th'] ?? chart.insight['en']
                            : chart.insight['en'],

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      isThai
                          ? 'ภาพรวมตัวตนเชิงลึก'
                          : 'Deep Personality Summary',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 28,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Text(
                        isThai
                            ? (chart.overallSummary['th'] ??
                                  chart.overallSummary['en'] ??
                                  '')
                            : (chart.overallSummary['en'] ?? ''),

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          height: 1.9,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    const SizedBox(height: 40),

                    Text(
                      isThai ? 'ตำแหน่งดาวสำคัญ' : 'Important Planet Positions',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 28,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isThai
                          ? 'พลังงานและอิทธิพลของดาวแต่ละดวงในชีวิตคุณ'
                          : 'How each planet influences your personality',

                      style: const TextStyle(
                        color: Colors.white70,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ...chart.planets.entries.map((entry) {
                      final planet = entry.key;

                      final data = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

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
                                color: Colors.purpleAccent.withOpacity(0.25),

                                borderRadius: BorderRadius.circular(16),
                              ),

                              child: Center(
                                child: Text(
                                  planet[0].toUpperCase(),

                                  style: const TextStyle(
                                    color: Colors.white,

                                    fontSize: 24,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    translatePlanet(planet, isThai),

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 20,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    isThai
                                        ? 'อยู่ใน${translateSign(data['sign'], isThai)} • เรือนที่ ${data['house']}'
                                        : '${data['sign']} • House ${data['house']}',

                                    style: const TextStyle(
                                      color: Colors.white70,

                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    getPlanetInterpretation(
                                      planet,
                                      data,
                                      isThai,
                                    ),

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
                  ],
                ),
              ),
            ),
    );
  }

  Widget _big3Card(String emoji, String title, String value) {
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
        ],
      ),
    );
  }
}
