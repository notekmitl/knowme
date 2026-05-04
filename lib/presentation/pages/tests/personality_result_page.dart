import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/personality_provider.dart';
import 'package:knowme/services//personality_insight_service.dart';
import 'package:knowme/astrology/providers/astrology_provider.dart';
import 'package:knowme/services//combined_insight_service.dart';

class PersonalityResultPage extends StatelessWidget {
  const PersonalityResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result = context.watch<PersonalityProvider>().result;
    final astrology = context.watch<AstrologyProvider>().result;
    if (result == null || astrology == null) {
      return const Scaffold(body: Center(child: Text("No Result")));
    }
    final combinedInsight = CombinedInsightService.generate(
      astrology: astrology,
      personality: result,
    );
    final insight = PersonalityInsightService.generateInsight(result);

    final values = [
      result.openness / 10,
      result.conscientiousness / 10,
      result.extraversion / 10,
      result.agreeableness / 10,
      result.neuroticism / 10,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ผลบุคลิกภาพ"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Big Five Personality",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// Radar Chart
              SizedBox(
                height: 300,
                child: RadarChart(
                  RadarChartData(
                    radarBorderData: const BorderSide(color: Colors.grey),
                    titleTextStyle: const TextStyle(fontSize: 14),
                    radarShape: RadarShape.polygon,
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(fontSize: 10),
                    dataSets: [
                      RadarDataSet(
                        fillColor: Colors.deepPurple.withOpacity(0.4),
                        borderColor: Colors.deepPurple,
                        entryRadius: 3,
                        dataEntries: values
                            .map((v) => RadarEntry(value: v))
                            .toList(),
                      ),
                    ],
                    getTitle: (index, angle) {
                      const titles = [
                        "Openness",
                        "Conscientious",
                        "Extraversion",
                        "Agreeable",
                        "Neurotic",
                      ];
                      return RadarChartTitle(text: titles[index]);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Insight
              const Text(
                "Insight",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  insight,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              /// Combined Insight
              const Text(
                "Astrology + Personality Insight",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  combinedInsight,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              /// Scores
              const Text(
                "Scores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Openness: ${result.openness.toStringAsFixed(1)}%"),
                  Text(
                    "Conscientiousness: ${result.conscientiousness.toStringAsFixed(1)}%",
                  ),
                  Text(
                    "Extraversion: ${result.extraversion.toStringAsFixed(1)}%",
                  ),
                  Text(
                    "Agreeableness: ${result.agreeableness.toStringAsFixed(1)}%",
                  ),
                  Text(
                    "Neuroticism: ${result.neuroticism.toStringAsFixed(1)}%",
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
