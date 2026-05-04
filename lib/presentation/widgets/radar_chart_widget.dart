import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RadarChartWidget extends StatelessWidget {
  final double openness;
  final double conscientiousness;
  final double extraversion;
  final double agreeableness;
  final double neuroticism;

  const RadarChartWidget({
    super.key,
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  @override
  Widget build(BuildContext context) {
    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        dataSets: [
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.3),
            borderColor: Colors.blue,
            entryRadius: 3,
            dataEntries: [
              RadarEntry(value: openness),
              RadarEntry(value: conscientiousness),
              RadarEntry(value: extraversion),
              RadarEntry(value: agreeableness),
              RadarEntry(value: neuroticism),
            ],
          ),
        ],
        titleTextStyle: const TextStyle(fontSize: 12),
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return const RadarChartTitle(text: 'Openness');
            case 1:
              return const RadarChartTitle(text: 'Conscientious');
            case 2:
              return const RadarChartTitle(text: 'Extraversion');
            case 3:
              return const RadarChartTitle(text: 'Agreeable');
            case 4:
              return const RadarChartTitle(text: 'Neurotic');
            default:
              return const RadarChartTitle(text: '');
          }
        },
      ),
    );
  }
}
