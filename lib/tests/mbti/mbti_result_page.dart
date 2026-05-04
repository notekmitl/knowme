import 'package:flutter/material.dart';

class MbtiResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const MbtiResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String type = data["type"];
    final Map<String, double> scores = Map<String, double>.from(data["scores"]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Result"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// ======================
            /// TYPE
            /// ======================
            Center(
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                _getTitle(type),
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 30),

            /// ======================
            /// DIMENSIONS
            /// ======================
            _buildBar("E vs I", scores["E"]!, scores["I"]!),
            _buildBar("N vs S", scores["N"]!, scores["S"]!),
            _buildBar("T vs F", scores["T"]!, scores["F"]!),
            _buildBar("J vs P", scores["J"]!, scores["P"]!),

            const SizedBox(height: 30),

            /// ======================
            /// INSIGHT
            /// ======================
            const Text(
              "Insight",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(_getDescription(type)),
          ],
        ),
      ),
    );
  }

  /// ======================
  /// BAR UI
  /// ======================
  Widget _buildBar(String label, double a, double b) {
    final total = a.abs() + b.abs();
    final aPercent = total == 0 ? 0.5 : a.abs() / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: (aPercent * 100).toInt(),
              child: Container(height: 10, color: Colors.deepPurple),
            ),
            Expanded(
              flex: ((1 - aPercent) * 100).toInt(),
              child: Container(height: 10, color: Colors.grey[300]),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  /// ======================
  /// TITLE
  /// ======================
  String _getTitle(String type) {
    switch (type) {
      case "INTJ":
        return "The Strategist";
      case "ENFP":
        return "The Inspirer";
      default:
        return "Personality Type";
    }
  }

  /// ======================
  /// DESCRIPTION
  /// ======================
  String _getDescription(String type) {
    switch (type) {
      case "INTJ":
        return "คุณเป็นคนที่มีการวางแผน มองไกล และคิดเชิงกลยุทธ์";
      case "ENFP":
        return "คุณเป็นคนที่มีพลัง สร้างสรรค์ และรักอิสระ";
      default:
        return "คุณมีบุคลิกเฉพาะตัวที่น่าสนใจ";
    }
  }
}
