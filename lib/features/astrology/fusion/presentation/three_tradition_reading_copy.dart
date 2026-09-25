import '../adapters/lens_theme_output.dart';
import '../application/three_tradition_consensus.dart';
import '../domain/entities/astrology_lens.dart';
import 'reading_evidence_text.dart';

/// Reader-facing prose composed only from selected, traceable lens outputs.
abstract final class ThreeTraditionReadingCopy {
  static final _thai = AstrologyLens.thaiAstrology.lensId;
  static final _chinese = AstrologyLens.chineseBazi.lensId;
  static final _western = AstrologyLens.westernNatal.lensId;

  static String overview(ThreeTraditionReading reading) {
    if (reading.agreements.isNotEmpty) {
      return _supportedOverview(reading, reading.agreements.first);
    }

    final clauses = <String>[
      if (_first(reading, _thai) case final source?)
        'ดวงไทยสะท้อน${ReadingEvidenceText.theme(source.themeId)}'
            'จาก${ReadingEvidenceText.evidencePhrase(source, prose: true)}',
      if (_first(reading, _chinese) case final source?)
        'ดวงจีนชี้ให้เห็น${ReadingEvidenceText.theme(source.themeId)}'
            'จาก${ReadingEvidenceText.evidencePhrase(source, prose: true)}',
      if (_first(reading, _western) case final source?)
        'ดวงตะวันตกเพิ่มมุมของ${ReadingEvidenceText.theme(source.themeId)}'
            'จาก${ReadingEvidenceText.evidencePhrase(source, prose: true)}',
    ];
    if (clauses.isEmpty) {
      return 'ข้อมูลที่มีอยู่ยังไม่พอจะอ่านภาพรวมจากสามศาสตร์ได้';
    }
    if (clauses.length == 1) return '${clauses.single}.';
    if (clauses.length == 2) {
      return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน ${clauses.first}. '
          'อีกมุมหนึ่ง ${clauses.last}.';
    }
    return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน ${clauses[0]}. '
        '${clauses[1]}. ส่วน${clauses[2]}.';
  }

  static String _supportedOverview(
    ThreeTraditionReading reading,
    ThreeTraditionAgreement agreement,
  ) {
    final common = agreement.exact
        ? ReadingEvidenceText.theme(agreement.sources.values.first.themeId)
        : 'การกำหนดทิศทางด้วยตนเอง';
    final participants = _joinLenses(agreement.sources.keys);
    final missing = ThreeTraditionConsensus.lensOrder
        .where((lens) => !agreement.sources.containsKey(lens))
        .toList();
    final other = <String>[];
    for (final lens in missing) {
      final source = _first(reading, lens);
      if (source == null) continue;
      other.add(
        'ดวง${_lensName(lens)}ให้มุมเรื่อง'
        '${ReadingEvidenceText.theme(source.themeId)}จาก'
        '${ReadingEvidenceText.evidencePhrase(source, prose: true)}',
      );
    }
    return 'เมื่ออ่านพื้นดวงนี้ร่วมกัน $participantsสอดคล้องกัน'
        'เรื่อง$common.'
        '${other.isEmpty ? '' : ' อีกมุมหนึ่ง ${other.join(' ขณะที่')} ซึ่งยังไม่นับร่วมในประเด็นนี้.'}';
  }

  static LensThemeOutput? _first(ThreeTraditionReading reading, String lens) {
    final outputs = reading.byLens[lens];
    return outputs == null || outputs.isEmpty ? null : outputs.first;
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
