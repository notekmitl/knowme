/// Life Map invited-beta feedback domain (V1.2.5).
///
/// Privacy: stores scores + safe life-map reference only — never birth PII.
library;

/// Overall 1–5 scores for Life Map validation.
class ThaiLifeMapBetaScores {
  const ThaiLifeMapBetaScores({
    required this.lifeFit,
    required this.clarity,
    required this.trust,
    required this.usefulness,
  });

  /// Perceived relevance to real life (user opinion — not formula proof).
  final int lifeFit;
  final int clarity;
  final int trust;
  final int usefulness;

  static bool isValidScore(int value) => value >= 1 && value <= 5;

  bool get isComplete =>
      isValidScore(lifeFit) &&
      isValidScore(clarity) &&
      isValidScore(trust) &&
      isValidScore(usefulness);

  Map<String, int> toMap() => {
    'lifeFit': lifeFit,
    'clarity': clarity,
    'trust': trust,
    'usefulness': usefulness,
  };

  factory ThaiLifeMapBetaScores.fromMap(Map<String, dynamic> map) {
    return ThaiLifeMapBetaScores(
      lifeFit: (map['lifeFit'] as num?)?.toInt() ?? 0,
      clarity: (map['clarity'] as num?)?.toInt() ?? 0,
      trust: (map['trust'] as num?)?.toInt() ?? 0,
      usefulness: (map['usefulness'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Period-level perception category.
enum ThaiLifeMapPeriodFeedbackCategory {
  exact('exact', 'ตรงมาก'),
  mismatch('mismatch', 'ไม่ตรง'),
  ambiguous('ambiguous', 'กำกวม'),
  hardToRead('hard_to_read', 'อ่านไม่เข้าใจ');

  const ThaiLifeMapPeriodFeedbackCategory(this.wireId, this.labelTh);
  final String wireId;
  final String labelTh;

  static ThaiLifeMapPeriodFeedbackCategory? fromWireId(String? id) {
    for (final v in values) {
      if (v.wireId == id) return v;
    }
    return null;
  }
}

/// Optional UX friction chips.
enum ThaiLifeMapUxIssue {
  textTooLong('text_too_long', 'ข้อความยาวหรืออ่านยาก'),
  hardToFind('hard_to_find', 'หาข้อมูลสำคัญไม่เจอ'),
  overflow('overflow', 'ข้อมูลล้น/ตัด/ซ้อน'),
  unclearNav('unclear_nav', 'ปุ่มหรือการนำทางไม่ชัด'),
  other('other', 'อื่น ๆ');

  const ThaiLifeMapUxIssue(this.wireId, this.labelTh);
  final String wireId;
  final String labelTh;

  static ThaiLifeMapUxIssue? fromWireId(String? id) {
    for (final v in values) {
      if (v.wireId == id) return v;
    }
    return null;
  }
}

/// Overall feedback document (one per invited user; doc id = uid).
class ThaiLifeMapBetaFeedback {
  const ThaiLifeMapBetaFeedback({
    required this.userId,
    required this.scores,
    required this.lifeMapRef,
    required this.viewportClass,
    required this.buildVersion,
    required this.feedbackSchemaVersion,
    required this.sourcePath,
    required this.isQaTest,
    this.optionalComment,
    this.uxIssues = const [],
    this.createdAt,
    this.updatedAt,
  });

  static const int schemaVersion = 1;
  static const int maxCommentLength = 500;

  final String userId;
  final ThaiLifeMapBetaScores scores;

  /// Safe Life Map fingerprint (e.g. report hash) — not birth data.
  final String lifeMapRef;
  final String viewportClass; // mobile | desktop
  final String buildVersion;
  final int feedbackSchemaVersion;
  final String sourcePath;
  final bool isQaTest;
  final String? optionalComment;
  final List<ThaiLifeMapUxIssue> uxIssues;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Client-side validation mirroring firestore.rules constraints.
  static String? validate({
    required ThaiLifeMapBetaScores scores,
    required String lifeMapRef,
    required String viewportClass,
    required String buildVersion,
    String? optionalComment,
    List<ThaiLifeMapUxIssue> uxIssues = const [],
  }) {
    if (!scores.isComplete) {
      return 'กรุณาให้คะแนนครบทั้ง 4 ด้าน (1–5)';
    }
    if (lifeMapRef.isEmpty || lifeMapRef.length > 128) {
      return 'lifeMapRef ไม่ถูกต้อง';
    }
    if (viewportClass != 'mobile' && viewportClass != 'desktop') {
      return 'viewportClass ไม่ถูกต้อง';
    }
    if (buildVersion.trim().isEmpty) {
      return 'buildVersion ว่าง';
    }
    if (optionalComment != null && optionalComment.length > maxCommentLength) {
      return 'ความคิดเห็นยาวเกิน $maxCommentLength ตัวอักษร';
    }
    if (uxIssues.length > 8) {
      return 'เลือก UX issue ได้ไม่เกิน 8 รายการ';
    }
    return null;
  }

  Map<String, dynamic> toFirestoreMap({
    required bool isCreate,
    required DateTime now,
  }) {
    return {
      'userId': userId,
      'scores': scores.toMap(),
      'lifeMapRef': lifeMapRef,
      'viewportClass': viewportClass,
      'buildVersion': buildVersion,
      'feedbackSchemaVersion': feedbackSchemaVersion,
      'sourcePath': sourcePath,
      'isQaTest': isQaTest,
      if (optionalComment != null) 'optionalComment': optionalComment,
      'uxIssues': uxIssues.map((e) => e.wireId).toList(),
      'createdAt': isCreate ? now.toUtc() : (createdAt ?? now).toUtc(),
      'updatedAt': now.toUtc(),
    };
  }

  factory ThaiLifeMapBetaFeedback.fromMap(
    Map<String, dynamic> map, {
    String? userId,
  }) {
    final scoresRaw = map['scores'];
    final scoresMap = scoresRaw is Map
        ? Map<String, dynamic>.from(scoresRaw)
        : <String, dynamic>{};
    final uxRaw = map['uxIssues'];
    final ux = <ThaiLifeMapUxIssue>[];
    if (uxRaw is List) {
      for (final item in uxRaw) {
        final parsed = ThaiLifeMapUxIssue.fromWireId(item?.toString());
        if (parsed != null) ux.add(parsed);
      }
    }
    return ThaiLifeMapBetaFeedback(
      userId: userId ?? (map['userId'] ?? '').toString(),
      scores: ThaiLifeMapBetaScores.fromMap(scoresMap),
      lifeMapRef: (map['lifeMapRef'] ?? '').toString(),
      viewportClass: (map['viewportClass'] ?? '').toString(),
      buildVersion: (map['buildVersion'] ?? '').toString(),
      feedbackSchemaVersion:
          (map['feedbackSchemaVersion'] as num?)?.toInt() ?? 0,
      sourcePath: (map['sourcePath'] ?? '').toString(),
      isQaTest: map['isQaTest'] == true,
      optionalComment: map['optionalComment']?.toString(),
      uxIssues: ux,
      createdAt: _asDate(map['createdAt']),
      updatedAt: _asDate(map['updatedAt']),
    );
  }

  static DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    return null;
  }
}

/// Per-period feedback under the user's overall doc.
class ThaiLifeMapPeriodFeedback {
  const ThaiLifeMapPeriodFeedback({
    required this.periodIndex,
    required this.category,
    this.optionalComment,
    this.updatedAt,
  });

  final int periodIndex;
  final ThaiLifeMapPeriodFeedbackCategory category;
  final String? optionalComment;
  final DateTime? updatedAt;

  static String? validate({
    required int periodIndex,
    required ThaiLifeMapPeriodFeedbackCategory category,
    String? optionalComment,
  }) {
    if (periodIndex < 0 || periodIndex > 7) {
      return 'periodIndex ต้องอยู่ระหว่าง 0–7';
    }
    if (optionalComment != null &&
        optionalComment.length > ThaiLifeMapBetaFeedback.maxCommentLength) {
      return 'ความคิดเห็นยาวเกิน ${ThaiLifeMapBetaFeedback.maxCommentLength} ตัวอักษร';
    }
    return null;
  }

  Map<String, dynamic> toFirestoreMap({required DateTime now}) {
    return {
      'periodIndex': periodIndex,
      'category': category.wireId,
      if (optionalComment != null) 'optionalComment': optionalComment,
      'updatedAt': now.toUtc(),
    };
  }

  factory ThaiLifeMapPeriodFeedback.fromMap(Map<String, dynamic> map) {
    return ThaiLifeMapPeriodFeedback(
      periodIndex: (map['periodIndex'] as num?)?.toInt() ?? -1,
      category:
          ThaiLifeMapPeriodFeedbackCategory.fromWireId(
            map['category']?.toString(),
          ) ??
          ThaiLifeMapPeriodFeedbackCategory.ambiguous,
      optionalComment: map['optionalComment']?.toString(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : null,
    );
  }
}
