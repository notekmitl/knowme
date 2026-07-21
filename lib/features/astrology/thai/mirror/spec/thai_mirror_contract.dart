/// Locked output contract for Thai Mirror V1.
abstract final class ThaiMirrorContract {
  static const version = 'v1';
  static const positioning = 'self_understanding';

  /// Default reflective disclaimers — not predictive.
  static const defaultDisclaimers = <String>[
    'This mirror reflects patterns that may resonate — not fixed predictions.',
    'Themes describe tendencies you might notice in yourself, not destiny.',
    'Birth time quality affects lagna-related themes when time is missing.',
  ];

  static const defaultDisclaimersTh = <String>[
    'กระจกนี้สะท้อนแนวโน้มที่อาจสัมผัสได้ — ไม่ใช่การทำนายที่แน่นอน',
    'ธีมอธิบายแนวโน้มที่คุณอาจสังเกตในตัวเอง ไม่ใช่ชะตากรรม',
    'คุณภาพเวลาเกิดมีผลต่อธีมที่เกี่ยวกับลัคนาเมื่อไม่มีเวลาเกิด',
  ];
}
