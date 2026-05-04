import 'package:flutter/material.dart';

class TraitBar extends StatelessWidget {
  final String title;
  final double value;

  const TraitBar({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final double percent = (value / 5).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title ${(percent * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        LinearProgressIndicator(
          value: percent,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
