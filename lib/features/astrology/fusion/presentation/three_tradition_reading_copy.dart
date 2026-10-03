import '../adapters/lens_theme_output.dart';
import '../application/three_tradition_consensus.dart';
import '../domain/entities/astrology_lens.dart';
import 'reading_evidence_text.dart';

/// Reader-facing prose composed only from traceable lens outputs.
abstract final class ThreeTraditionReadingCopy {
  static final _thai = AstrologyLens.thaiAstrology.lensId;
  static final _chinese = AstrologyLens.chineseBazi.lensId;
  static final _western = AstrologyLens.westernNatal.lensId;

  static String overview(ThreeTraditionReading reading) {
    // Review every observation before choosing a narrative path. The three
    // roles describe different parts of a decision, not matching themes.
    if (reading.agreements.isEmpty) {
      final arc = _decisionArc(reading);
      if (arc != null) return arc;
      if (reading.byLens.values.every((items) => items.isEmpty)) {
        return 'ข้อมูลที่มีอยู่ยังไม่พอจะอ่านภาพรวมจากสามศาสตร์ได้';
      }
      return 'หลักฐานของแต่ละศาสตร์ในกรณีนี้ยังไม่เชื่อมเป็นเรื่องเดียว'
          'ได้อย่างมีเหตุผล จึงควรอ่านข้อสังเกตของแต่ละศาสตร์แยกกัน'
          'จากหลักฐานด้านล่าง โดยไม่สรุปเป็นจุดร่วมหรือเติมความหมายที่หลักฐานไม่มี';
    }
    final independent = _agreement(reading, 'independent');
    final growth = _agreement(reading, 'growth_focused');
    if (independent != null && growth != null) {
      return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน ${_joinLenses(independent.sources.keys)}'
          'สอดคล้องกันเรื่อง${ReadingEvidenceText.theme('independent')} '
          'และ${_joinLenses(growth.sources.keys)}สอดคล้องกันอีกเรื่องคือ'
          '${ReadingEvidenceText.theme('growth_focused')}. '
          'สองประเด็นนี้ชวนพิจารณาว่าการเลือกทางของตนเองสัมพันธ์กับ'
          'การเรียนรู้อย่างไรในชีวิตจริง แต่หลักฐานไม่ได้บอกว่า'
          'ประเด็นทั้งสองเป็นเหตุเป็นผลต่อกัน หรือเป็นจุดร่วมเดียวของสามศาสตร์.';
    }
    final reliable = _agreement(reading, 'reliable');
    if (reliable != null && reliable.sourceCount == 2) {
      final missing = ThreeTraditionConsensus.lensOrder
          .where((lens) => !reliable.sources.containsKey(lens))
          .single;
      final thinking = _pick(reading, missing, const {
        'analytical',
        'structured',
        'intuitive',
      });
      if (thinking != null) {
        return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน ${_joinLenses(reliable.sources.keys)}'
            'สอดคล้องกันเรื่อง${ReadingEvidenceText.theme('reliable')}. '
            'ดวง${_lensName(missing)}ให้มุมของ'
            '${ReadingEvidenceText.theme(thinking.themeId)}จาก'
            '${ReadingEvidenceText.evidencePhrase(thinking, prose: true)}. '
            'เมื่อนำมาอ่านประกอบกัน จึงชวนแยกดูวิธีพิจารณาเรื่องหนึ่ง'
            'กับการลงมือทำอย่างสม่ำเสมอ โดยไม่ได้สรุปว่า'
            'มุมของดวง${_lensName(missing)}เป็นหลักฐานของจุดร่วมนี้.';
      }
    }
    if (reading.agreements.length > 1) {
      final points = reading.agreements
          .map((item) {
            final theme = item.exact
                ? ReadingEvidenceText.theme(item.sources.values.first.themeId)
                : 'การกำหนดทิศทางด้วยตนเอง';
            return '${_joinLenses(item.sources.keys)}สอดคล้องกันเรื่อง$theme';
          })
          .join(' และ');
      return 'หลักฐานรองรับจุดร่วมแยกกันหลายเรื่อง: $points '
          'แต่ยังไม่มีหลักฐานพอจะบอกว่าจุดร่วมเหล่านี้สัมพันธ์กันอย่างไร '
          'จึงไม่เรียบเรียงเป็นเรื่องเดียวหรืออ้างว่าเป็นจุดร่วมของสามศาสตร์.';
    }
    return _supportedOverview(reading.agreements.first);
  }

  static String? _decisionArc(ThreeTraditionReading reading) {
    for (final thinker in ThreeTraditionConsensus.lensOrder) {
      final thought = _pick(reading, thinker, const {
        'analytical',
        'structured',
        'intuitive',
      });
      if (thought == null) continue;
      for (final anchor in ThreeTraditionConsensus.lensOrder) {
        if (anchor == thinker) continue;
        final stability = _pick(reading, anchor, const {
          'grounded',
          'reliable',
        });
        if (stability == null) continue;
        final responder = ThreeTraditionConsensus.lensOrder.singleWhere(
          (lens) => lens != thinker && lens != anchor,
        );
        final change = _pick(reading, responder, const {
          'adaptable',
          'flexible',
        });
        if (change == null) continue;
        return 'เมื่อนำหลักฐานสามศาสตร์มาอ่านประกอบกัน ภาพรวมชวนถามว่า'
            'เวลาเลือกทาง จะใช้วิธีคิดชั่งน้ำหนักสิ่งที่อยากรักษาไว้ '
            'แล้วปรับวิธีอย่างไรเมื่อเงื่อนไขเปลี่ยน คำถามนี้อาศัย'
            'คนละมุมของหลักฐาน: ดวง${_lensName(thinker)}ให้มุมของ'
            '${ReadingEvidenceText.theme(thought.themeId)}จาก'
            '${ReadingEvidenceText.evidencePhrase(thought, prose: true)} '
            'สำหรับวิธีพิจารณา ดวง${_lensName(anchor)}ให้มุมของ'
            '${ReadingEvidenceText.theme(stability.themeId)}จาก'
            '${ReadingEvidenceText.evidencePhrase(stability, prose: true)} '
            'สำหรับสิ่งที่อาจให้ค่าน้ำหนัก และดวง${_lensName(responder)}'
            'ให้มุมของ${ReadingEvidenceText.theme(change.themeId)}จาก'
            '${ReadingEvidenceText.evidencePhrase(change, prose: true)} '
            'สำหรับวิธีตอบต่อความเปลี่ยนแปลง นี่เป็นการอ่านประกอบกัน '
            'ไม่ใช่จุดร่วมที่พิสูจน์แล้ว หรือคำยืนยันว่าทั้งสามมุมเกิดขึ้น'
            'พร้อมกันในชีวิตจริง.';
      }
    }
    return null;
  }

  static ThreeTraditionAgreement? _agreement(
    ThreeTraditionReading reading,
    String key,
  ) {
    for (final item in reading.agreements) {
      if (item.exact && item.key == key) return item;
    }
    return null;
  }

  static LensThemeOutput? _pick(
    ThreeTraditionReading reading,
    String lens,
    Set<String> themes,
  ) {
    for (final item in reading.byLens[lens] ?? const <LensThemeOutput>[]) {
      if (themes.contains(item.themeId)) return item;
    }
    return null;
  }

  static String _supportedOverview(ThreeTraditionAgreement agreement) {
    final common = agreement.exact
        ? ReadingEvidenceText.theme(agreement.sources.values.first.themeId)
        : 'การกำหนดทิศทางด้วยตนเอง';
    final participants = _joinLenses(agreement.sources.keys);
    final missing = ThreeTraditionConsensus.lensOrder
        .where((lens) => !agreement.sources.containsKey(lens))
        .toList();
    return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน $participantsสอดคล้องกัน'
        'เรื่อง$common.'
        '${missing.isEmpty ? '' : ' ดวง${_lensName(missing.single)}ยังไม่มีหลักฐานที่เชื่อมมุมของตนเข้ากับเรื่องนี้อย่างมีเหตุผล จึงแสดงข้อสังเกตของศาสตร์นั้นแยกไว้ด้านล่าง.'}';
  }

  static String _lensName(String lens) {
    if (lens == _thai) return 'ไทย';
    if (lens == _chinese) return 'จีน';
    if (lens == _western) return 'ตะวันตก';
    return lens;
  }

  static String _joinLenses(Iterable<String> lenses) {
    final names = lenses.map(_lensName).toList();
    if (names.length <= 1) return names.join();
    if (names.length == 2) return '${names.first}กับ${names.last}';
    return '${names.take(names.length - 1).join(' ')} และ${names.last}';
  }
}
