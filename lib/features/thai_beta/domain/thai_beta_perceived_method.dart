/// "What do you think this system is using to analyze you?" — research signal
/// on how users perceive the engine (deterministic Thai astrology vs. AI/name).
enum ThaiBetaPerceivedMethod {
  birthDate('birth_date', 'วันเกิด'),
  birthDateAndTime('birth_date_time', 'วันเกิด + เวลาเกิด'),
  name('name', 'ชื่อ'),
  ai('ai', 'AI'),
  notSure('not_sure', 'ไม่แน่ใจ'),
  other('other', 'อื่น ๆ');

  const ThaiBetaPerceivedMethod(this.wireId, this.labelTh);

  /// Stable id stored in Firestore (never localized).
  final String wireId;

  /// Thai display label.
  final String labelTh;

  static ThaiBetaPerceivedMethod fromWireId(String? id) {
    return ThaiBetaPerceivedMethod.values.firstWhere(
      (m) => m.wireId == id,
      orElse: () => ThaiBetaPerceivedMethod.notSure,
    );
  }
}
