/// V2.2 presentation copy — story hero + personal growth narratives only.
abstract final class FusionResultV22Copy {
  static const exploreCta = 'ดูรายละเอียดทั้งหมด';
  static const fusionEvidenceLabel = 'Fusion Evidence';
  static const consensusAlignedSuffix = 'ศาสตร์';
  static const consensusSectionTitle = 'หลายศาสตร์เห็นตรงกันว่า...';

  static String consensusAlignedLabel(int aligned, int total) {
    return 'เห็นตรงกัน $aligned/$total $consensusAlignedSuffix';
  }

  /// Transforms engine growth copy into a personal second-person narrative.
  static String personalGrowthNarrative({
    required String title,
    required String description,
  }) {
    final key = _normalizeKey('$title $description');

    if (key.contains('อิสระ') ||
        key.contains('พึ่งพาตัวเอง') ||
        key.contains('ตัดสินใจ')) {
      return 'เมื่อคุณเชื่อมั่นในเสียงของตัวเอง\n'
          'และเลิกกังวลว่าคนอื่นจะมองอย่างไร\n\n'
          'คุณมักค้นพบเส้นทางที่เหมาะกับตัวเองที่สุด';
    }

    if (key.contains('แสดงออก') || key.contains('สื่อสาร')) {
      return 'เมื่อคุณกล้าแสดงตัวตนอย่างตรงไปตรงมา\n'
          'โลกรอบตัวมักตอบสนองด้วยความเข้าใจที่แท้จริง\n\n'
          'นี่คือพลังที่ช่วยให้คุณเชื่อมต่อกับผู้อื่นได้ลึกขึ้น';
    }

    if (key.contains('ทบทวน') || key.contains('สะท้อน')) {
      return 'คุณไม่ได้เติบโตจากการเดินเร็วที่สุด\n\n'
          'แต่เติบโตจากการหยุดมองย้อนกลับ\n'
          'แล้วเลือกเดินต่ออย่างมีสติ';
    }

    if (key.contains('เติบโต') || key.contains('เรียนรู้')) {
      return 'ทุกครั้งที่คุณลงมือทำจริง\n'
          'ประสบการณ์นั้นกลายเป็นบทเรียนที่หาไม่ได้จากที่อื่น\n\n'
          'นี่คือวิธีที่คุณสร้างความมั่นใจในตัวเองทีละน้อย';
    }

    if (key.contains('โครงสร้าง') || key.contains('รับผิดชอบ')) {
      return 'เมื่อคุณยึดโยงกับสิ่งที่สำคัญจริง ๆ\n'
          'และรักษาความมั่นคงในสิ่งที่ลงมือทำ\n\n'
          'คุณมักสร้างผลลัพธ์ที่ยั่งยืนกว่าที่คาดไว้';
    }

    if (key.contains('ความสัมพันธ์') || key.contains('เชื่อมต่อ')) {
      return 'เมื่อคุณเปิดใจรับฟังและให้พื้นที่กับผู้อื่น\n'
          'ความสัมพันธ์ที่มีคุณภาพมักเกิดขึ้นเอง\n\n'
          'โดยไม่ต้องแลกความเป็นตัวเองทิ้งไป';
    }

    final trimmed = description.trim();
    if (trimmed.isNotEmpty) {
      return trimmed.replaceAll('มีโอกาสเมื่อ', 'เมื่อคุณ');
    }

    return 'เมื่อคุณให้ความสำคัญกับ$title\n'
        'คุณมักพบว่าตัวเองเติบโตในทิศทางที่รู้สึกถูกต้องที่สุด';
  }

  static String narrativeTitle(String title) {
    final key = _normalizeKey(title);
    if (key.contains('อิสระ') || key.contains('พึ่งพาตัวเอง')) {
      return 'อิสระและการพึ่งพาตัวเอง';
    }
    if (key.contains('แสดงออก')) return 'การแสดงออก';
    if (key.contains('ทบทวน')) return 'การทบทวน';
    return title;
  }

  static String _normalizeKey(String value) => value.toLowerCase();
}
