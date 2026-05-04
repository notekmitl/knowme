class MbtiLogic {
  final Map<String, double> scores = {
    "E": 0,
    "I": 0,
    "S": 0,
    "N": 0,
    "T": 0,
    "F": 0,
    "J": 0,
    "P": 0,
  };

  /// 🔥 เอาคำตอบไปคำนวณ
  void applyAnswer(Map<String, int> dimension, int value) {
    dimension.forEach((key, weight) {
      scores[key] = (scores[key] ?? 0) + (value * weight);
    });
  }

  /// 🔥 สร้าง type (INTJ / ENFP)
  String getType() {
    return _pick("I", "E") +
        _pick("N", "S") +
        _pick("T", "F") +
        _pick("J", "P");
  }

  String _pick(String a, String b) {
    return (scores[a]! > scores[b]!) ? a : b;
  }
}
