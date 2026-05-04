class MbtiQuestion {
  final String id;
  final String textKey;

  /// 🔥 สำคัญ: ใช้บอกว่าข้อนี้วัด dimension ไหน
  /// เช่น {"E":1} หรือ {"I":1}
  final Map<String, int> dimension;

  MbtiQuestion({
    required this.id,
    required this.textKey,
    required this.dimension,
  });
}
