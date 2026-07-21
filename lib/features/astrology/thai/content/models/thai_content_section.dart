import 'content_status.dart';
import 'thai_content_defaults.dart';
import 'thai_content_type.dart';
import 'thai_theme_mapping.dart';

/// Readable content block for one Thai astrology interpretation key.
class ThaiContentSection {
  const ThaiContentSection({
    required this.key,
    required this.contentType,
    required this.title,
    required this.summary,
    required this.coreNature,
    required this.strengths,
    required this.challenges,
    required this.growthPath,
    required this.themeMappings,
    this.contentStatus = kThaiContentDefaultStatus,
    this.version = kDefaultThaiContentVersion,
  });

  final String key;
  final ThaiContentType contentType;
  final String title;
  final String summary;
  final String coreNature;
  final List<String> strengths;
  final List<String> challenges;
  final String growthPath;
  final List<ThaiThemeMapping> themeMappings;
  final ContentStatus contentStatus;
  final String version;

  factory ThaiContentSection.fromMap(Map<String, dynamic> map) {
    final key = map['key'];
    if (key is! String || key.trim().isEmpty) {
      throw FormatException('Invalid content key: $key');
    }

    final typeRaw = map['content_type'] ?? map['contentType'];
    ThaiContentType? contentType;
    if (typeRaw is String) {
      contentType = parseThaiContentType(typeRaw);
    } else if (typeRaw is ThaiContentType) {
      contentType = typeRaw;
    }
    if (contentType == null) {
      throw FormatException('Invalid content type: $typeRaw');
    }

    return ThaiContentSection(
      key: key.trim(),
      contentType: contentType,
      title: _requiredString(map['title'], 'title'),
      summary: _requiredString(map['summary'], 'summary'),
      coreNature: _requiredString(map['core_nature'] ?? map['coreNature'], 'coreNature'),
      strengths: _stringList(map['strengths']),
      challenges: _stringList(map['challenges']),
      growthPath: _requiredString(map['growth_path'] ?? map['growthPath'], 'growthPath'),
      themeMappings: _themeMappings(map['theme_mappings'] ?? map['themeMappings']),
      contentStatus: _parseContentStatus(map['content_status'] ?? map['contentStatus']),
      version: _parseVersion(map['version']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'content_type': contentType.id,
      'title': title,
      'summary': summary,
      'core_nature': coreNature,
      'strengths': strengths,
      'challenges': challenges,
      'growth_path': growthPath,
      'theme_mappings': themeMappings.map((m) => m.toMap()).toList(),
      'content_status': contentStatus.id,
      'version': version,
    };
  }

  static ContentStatus _parseContentStatus(dynamic raw) {
    if (raw == null) return kThaiContentDefaultStatus;

    if (raw is ContentStatus) return raw;

    if (raw is String) {
      final parsed = parseContentStatus(raw);
      if (parsed != null) return parsed;
    }

    throw FormatException('Invalid content status: $raw');
  }

  static String _parseVersion(dynamic raw) {
    if (raw == null) return kDefaultThaiContentVersion;

    if (raw is String && raw.trim().isNotEmpty) return raw.trim();

    throw FormatException('Invalid content version: $raw');
  }

  static String _requiredString(dynamic raw, String field) {
    if (raw is! String || raw.trim().isEmpty) {
      throw FormatException('Invalid $field: $raw');
    }
    return raw.trim();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<ThaiThemeMapping> _themeMappings(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => ThaiThemeMapping.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
