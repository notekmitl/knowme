import 'package:knowme/features/astrology/thai/content/registry/thai_content_registry.dart';

/// Maps internal Thai content keys to human-readable Thai labels for UI.
abstract final class ThaiContentKeyHumanLabel {
  static String label(String contentKey, {String? contentTitle}) {
    final title = contentTitle?.trim();
    if (title != null && title.isNotEmpty && !_looksLikeInternalKey(title)) {
      return title;
    }

    final section = ThaiContentRegistry.resolve(contentKey);
    if (section != null && section.title.trim().isNotEmpty) {
      return section.title.trim();
    }

    return _fallbackLabel(contentKey);
  }

  static bool _looksLikeInternalKey(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.contains('_') &&
        (normalized.startsWith('lagna_') ||
            normalized.startsWith('mahabhuta_') ||
            normalized.startsWith('ramahabhuta_') ||
            normalized.startsWith('myanmar_seven_') ||
            normalized.startsWith('lagna_lord_') ||
            normalized.contains('evidence_key') ||
            normalized.contains('theme_key'));
  }

  static String _fallbackLabel(String contentKey) {
    final key = contentKey.trim().toLowerCase();
    if (key.startsWith('lagna_lord_')) {
      final planet = key.replaceFirst('lagna_lord_', '');
      return 'ดาว${_planetTh(planet)}เป็นเจ้าเรือนลัคนา';
    }
    if (key.startsWith('lagna_')) {
      final sign = key.replaceFirst('lagna_', '');
      return 'ลัคนาราศี${_signTh(sign)}';
    }
    if (key.startsWith('mahabhuta_')) {
      return 'ธาตุประจำตัว';
    }
    if (key.startsWith('ramahabhuta_')) {
      return 'มหาภูติ${_elementTh(key.replaceFirst('ramahabhuta_', ''))}';
    }
    if (key.startsWith('myanmar_seven_')) {
      final n = key.replaceFirst('myanmar_seven_', '');
      return 'พระเคราะห์ประจำตัว ($n)';
    }
    return 'ข้อมูลโหราศาสตร์';
  }

  static String _planetTh(String planet) {
    return switch (planet) {
      'sun' => 'อาทิตย์',
      'moon' => 'จันทร์',
      'mars' => 'อังคาร',
      'mercury' => 'พุธ',
      'jupiter' => 'พฤหัสบดี',
      'venus' => 'ศุกร์',
      'saturn' => 'เสาร์',
      _ => planet,
    };
  }

  static String _signTh(String sign) {
    return switch (sign) {
      'aries' => 'เมษ',
      'taurus' => 'พฤษภ',
      'gemini' => 'เมถุน',
      'cancer' => 'กรกฎ',
      'leo' => 'สิงห์',
      'virgo' => 'กันย์',
      'libra' => 'ตุลย์',
      'scorpio' => 'พิจิก',
      'sagittarius' => 'ธนู',
      'capricorn' => 'มกร',
      'aquarius' => 'กุมภ์',
      'pisces' => 'มีน',
      _ => sign,
    };
  }

  static String _elementTh(String element) {
    return switch (element) {
      'earth' => 'ดิน',
      'water' => 'น้ำ',
      'wind' => 'ลม',
      'fire' => 'ไฟ',
      _ => element,
    };
  }
}
