import 'dart:convert';

/// Parsed Firestore export row for real-user validation.
class RealUserExportRecord {
  const RealUserExportRecord({
    required this.uid,
    required this.userRoot,
    required this.profile,
    required this.results,
    required this.astrology,
  });

  final String uid;
  final Map<String, dynamic> userRoot;
  final Map<String, dynamic>? profile;
  final Map<String, Map<String, dynamic>> results;
  final Map<String, Map<String, dynamic>> astrology;

  bool get hasProfile => profile != null;

  bool get hasThaiBirthInput =>
      profile != null &&
      (profile!['birthDate']?.toString().isNotEmpty ?? false);

  bool get hasBaziChart =>
      astrology.containsKey('chinese_bazi') ||
      results.containsKey('chinese_bazi');

  bool get hasWesternChart => astrology.containsKey('western_natal');

  bool get hasMbti => results.keys.any(
        (key) =>
            key == 'mbti_mini' ||
            key == 'mbti_accurate' ||
            key == 'mbti_cognitive',
      );

  bool get hasBigFive =>
      results.containsKey('big_five') || results.containsKey('bigfive');

  bool get hasEq => results.keys.any(
        (key) => key == 'eq' || key.startsWith('eq_'),
      );

  bool get looksLikeAutomationAccount {
    final lower = uid.toLowerCase();
    return lower.contains('test') ||
        lower.contains('verify') ||
        lower.contains('cors') ||
        lower.contains('e2e') ||
        lower.contains('audit');
  }

  Map<String, dynamic>? baziChartMap() {
    return astrology['chinese_bazi'] ?? results['chinese_bazi'];
  }

  static RealUserExportExportFile parseFile(String jsonText) {
    final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
    final users = (decoded['users'] as List<dynamic>)
        .map(
          (item) => RealUserExportRecord.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);

    return RealUserExportExportFile(
      exportedAt: decoded['exportedAt'] as String? ?? '',
      populationSize: decoded['populationSize'] as int? ?? users.length,
      users: users,
    );
  }

  factory RealUserExportRecord.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as Map<String, dynamic>? ?? const {};
    final rawAstrology = json['astrology'] as Map<String, dynamic>? ?? const {};

    return RealUserExportRecord(
      uid: json['uid'] as String? ?? '',
      userRoot: Map<String, dynamic>.from(
        json['userRoot'] as Map<String, dynamic>? ?? const {},
      ),
      profile: json['profile'] == null
          ? null
          : Map<String, dynamic>.from(json['profile'] as Map),
      results: {
        for (final entry in rawResults.entries)
          entry.key: Map<String, dynamic>.from(entry.value as Map),
      },
      astrology: {
        for (final entry in rawAstrology.entries)
          entry.key: Map<String, dynamic>.from(entry.value as Map),
      },
    );
  }
}

class RealUserExportExportFile {
  const RealUserExportExportFile({
    required this.exportedAt,
    required this.populationSize,
    required this.users,
  });

  final String exportedAt;
  final int populationSize;
  final List<RealUserExportRecord> users;

  static RealUserExportExportFile parseFile(String jsonText) =>
      RealUserExportRecord.parseFile(jsonText);
}
