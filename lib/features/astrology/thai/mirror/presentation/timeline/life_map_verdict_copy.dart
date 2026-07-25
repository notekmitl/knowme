/// Shared Life Map V1.2.8 verdict-narrative copy policy (presentation only).
///
/// Bans hedge / coaching language in period summaries so users can judge
/// “ตรงหรือไม่ตรง”. Does not invent Canon meanings.
library;

/// Presentation policy for Past Verdict / Current Reality / Future Forecast.
abstract final class LifeMapVerdictCopy {
  /// Softeners banned from primary period narrative bodies.
  static const bannedHedges = <String>[
    'อาจ',
    'น่าจะ',
    'มีแนวโน้ม',
    'เป็นไปได้ว่า',
    'ในบางคน',
    'ถ้าคุณรู้สึกว่า',
    'ลองพิจารณาว่า',
    'ชวนให้ทบทวน',
    'คุณอาจพบว่า',
  ];

  /// Coaching / retrospective prompts banned from primary narrative bodies.
  static const bannedCoaching = <String>[
    'ลองนึกย้อน',
    'ลองทบทวน',
    'ลองสังเกต',
    'คุณอาจลองนึก',
    'ลองนึกถึง',
    'ลองพิจารณาว่า',
    'ชวนให้ทบทวน',
    'ถ้าคุณรู้สึกว่า',
  ];

  /// Catastrophic / sensitive claims never invented without direct Canon support.
  static const bannedCatastrophic = <String>[
    'เสียชีวิต',
    'หย่าร้าง',
    'อุบัติเหตุ',
    'โรคร้าย',
    'ตั้งครรภ์',
    'ถูกจับ',
    'ได้เงินก้อน',
  ];

  static bool containsBannedHedge(String text) =>
      bannedHedges.any(text.contains);

  static bool containsBannedCoaching(String text) =>
      bannedCoaching.any(text.contains);

  static bool containsCatastrophicClaim(String text) =>
      bannedCatastrophic.any(text.contains);

  /// Primary period body: no hedges, coaching prompts, or invented catastrophes.
  static bool violatesPrimaryBody(String text) {
    if (text.trim().isEmpty) return false;
    return containsBannedHedge(text) ||
        containsBannedCoaching(text) ||
        containsCatastrophicClaim(text);
  }
}
