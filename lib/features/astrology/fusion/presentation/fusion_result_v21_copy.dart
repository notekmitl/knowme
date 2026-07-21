/// V2.1 presentation copy — enriched human-facing text only.
abstract final class FusionResultV21Copy {
  static const footerTitle = '✦ KnowMe Reflection';
  static const footerBody =
      'การรวมพลังของหลายศาสตร์\n'
      'ไม่ได้มีเป้าหมายเพื่อทำนายอนาคต\n'
      'แต่ช่วยให้คุณเข้าใจตัวเองได้ชัดเจนขึ้น\n'
      'เพื่อการตัดสินใจที่ดีขึ้นในวันนี้';

  static const agreementSupportPrefix = 'สนับสนุนเรื่อง';

  static const lensEnrichedFallback = {
    'western_natal':
        'การพึ่งพาตัวเอง\nและการกำหนดทิศทางชีวิต',
    'chinese_bazi':
        'ความเป็นตัวของตัวเอง\nและการเลือกอย่างตั้งใจ',
    'thai_astrology':
        'การตัดสินใจด้วยตัวเอง\nและความกล้าหาญ',
  };

  static String enrichedAgreementMeaning(String lensId, String rawSummary) {
    final fallback = lensEnrichedFallback[lensId];
    if (rawSummary.trim().isEmpty) {
      return fallback == null ? '' : '$agreementSupportPrefix\n$fallback';
    }

    var themes = rawSummary.trim();
    if (themes.startsWith('สะท้อน')) {
      themes = themes.substring('สะท้อน'.length).trim();
    }
    if (themes.startsWith('และ')) {
      themes = themes.substring('และ'.length).trim();
    }

    if (themes.isEmpty && fallback != null) {
      return '$agreementSupportPrefix\n$fallback';
    }

    final lines = themes
        .split(RegExp(r'\s+และ'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (lines.isEmpty && fallback != null) {
      return '$agreementSupportPrefix\n$fallback';
    }

    if (lines.length == 1) {
      return '$agreementSupportPrefix\n${lines.first}';
    }

    return '$agreementSupportPrefix\n${lines.first}\nและ${lines.sublist(1).join('\nและ')}';
  }

  static String strengthInsightTitle(String signalTitle) {
    if (signalTitle.contains('อิสระ') || signalTitle.contains('พึ่งพาตัวเอง')) {
      return 'การตัดสินใจ';
    }
    if (signalTitle.contains('แสดงออก')) {
      return 'การแสดงออก';
    }
    if (signalTitle.contains('เติบโต') || signalTitle.contains('เรียนรู้')) {
      return 'การเรียนรู้จากประสบการณ์';
    }
    if (signalTitle.contains('ทบทวน')) {
      return 'การทบทวนตัวเอง';
    }
    if (signalTitle.contains('โครงสร้าง') || signalTitle.contains('รับผิดชอบ')) {
      return 'ความมั่นคงในการลงมือทำ';
    }
    if (signalTitle.contains('ความสัมพันธ์')) {
      return 'การเชื่อมต่อกับผู้อื่น';
    }
    return signalTitle.split('และ').first.trim();
  }

  static String strengthInsightDescription(
    String signalTitle,
    String growthPotential,
  ) {
    if (signalTitle.contains('อิสระ') || signalTitle.contains('พึ่งพาตัวเอง')) {
      return 'คุณกล้าตัดสินใจ\nและรับผิดชอบเส้นทางของตัวเอง';
    }
    if (signalTitle.contains('แสดงออก')) {
      return 'คุณสามารถสื่อสาร\nสิ่งที่คิดและรู้สึกได้ชัดเจน';
    }
    if (signalTitle.contains('เติบโต')) {
      return 'คุณเติบโตจากสิ่งที่ได้ลงมือทำจริง';
    }
    if (signalTitle.contains('ทบทวน')) {
      return 'คุณใช้เวลาทำความเข้าใจตัวเอง\nก่อนตัดสินใจสำคัญ';
    }
    return growthPotential.replaceAll(' ', '\n');
  }
}

/// Illustrated growth card visual identity — V2.1.
enum FusionGrowthVisualStyle {
  nightSky,
  nebulaFlow,
  moonReflection,
}
