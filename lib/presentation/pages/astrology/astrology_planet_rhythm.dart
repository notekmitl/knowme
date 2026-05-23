// Sentence rhythm patterns for planet cards (deterministic; post-polish, pre-clamp).
import 'astrology_planet_interpretation_polish.dart';
import 'astrology_planet_subject_cleanup.dart';

enum _TailStyle { plain, doey, and, which }

abstract final class AstrologyPlanetRhythm {
  static String finish({
    required String polishedCore,
    required String houseTail,
    required String lang,
    required String planet,
    required String sign,
    int? house,
  }) {
    final stripped = AstrologyPlanetInterpretationPolish.stripLead(polishedCore, lang);
    final core = AstrologyPlanetSubjectCleanup.neutralizeCoreBody(stripped, lang);
    final tail = houseTail.trim();
    if (tail.isEmpty) {
      return AstrologyPlanetSubjectCleanup.normalize(
        _finalize(_coreOnly(core, lang, planet, sign, house), lang),
        lang,
      );
    }

    final bare = _stripAllConnectors(_tailBare(tail, lang), lang);
    final idx = _patternIndex(planet, sign, house);
    final text = _applyPattern(idx, core, bare, lang);
    return AstrologyPlanetSubjectCleanup.normalize(_finalize(text, lang), lang);
  }

  static int _patternIndex(String planet, String sign, int? house) {
    final h = house ?? 0;
    final sub = _hash('$planet|$sign') % 3;
    if (h == 12) return [2, 3, 1][sub];
    if (h == 7) return [4, 1, 5][sub];
    if (h == 4) return [6, 1, 3][sub];
    return _hash('$planet|$sign|$h') % 7;
  }

  static String _applyPattern(int idx, String core, String bare, String lang) {
    if (lang == 'th') {
      return switch (idx) {
        0 => 'คุณอาจ$core${_joinThTail(bare, style: _TailStyle.doey)}',
        1 => 'เวลาบางเรื่องสำคัญ คุณมัก$core${_joinThTail(bare, style: _TailStyle.and)}',
        2 =>
            'หลายครั้งสิ่งนี้${_joinThTail(bare, style: _TailStyle.plain)} ในขณะที่คุณอาจ$core',
        3 => 'คุณมัก$core${_joinThTail(bare, style: _TailStyle.and)}',
        4 => 'ในความสัมพันธ์ใกล้ชิด $core${_joinThTail(bare, style: _TailStyle.plain)}',
        5 => 'เมื่อบางอย่างสำคัญกับใจ คุณอาจ$core${_joinThTail(bare, style: _TailStyle.and)}',
        _ => 'จังหวะที่รู้สึกปลอดภัย คุณมัก$core${_joinThTail(bare, style: _TailStyle.and)}',
      };
    }
    return switch (idx) {
      0 => 'You may $core${_joinEnTail(bare)}',
      1 => 'When something matters, you often $core${_joinEnTail(bare)}',
      2 => 'Often this ${_enClause(bare)} while you $core',
      3 => 'You often $core${_joinEnTail(bare)}',
      4 => 'In close bonds, $core${_joinEnTail(bare)}',
      5 => 'When it touches real feeling, you may $core${_joinEnTail(bare)}',
      _ => 'In moments of safety, you often $core${_joinEnTail(bare)}',
    };
  }

  static String _coreOnly(
    String core,
    String lang,
    String planet,
    String sign,
    int? house,
  ) {
    final idx = _patternIndex(planet, sign, house) % 4;
    if (lang == 'th') {
      return switch (idx) {
        0 => 'คุณอาจ$core',
        1 => 'เวลาสำคัญขึ้น คุณมัก$core',
        2 => 'หลายครั้ง$core',
        _ => 'เรื่องบางอย่าง คุณอาจ$core',
      };
    }
    return switch (idx) {
      0 => 'You may $core',
      1 => 'When it counts, you often $core',
      2 => 'Often you $core',
      _ => 'In some situations you may $core',
    };
  }

  static String _joinThTail(String bare, {required _TailStyle style}) {
    if (bare.isEmpty) return '';
    if (bare.startsWith('มัก')) return ' $bare';
    return switch (style) {
      _TailStyle.plain => ' $bare',
      _TailStyle.doey => ' โดยหลายครั้ง$bare',
      _TailStyle.and => ' และ$bare',
      _TailStyle.which => ' ซึ่ง$bare',
    };
  }

  static String _joinEnTail(String bare) {
    if (bare.isEmpty) return '';
    if (bare.startsWith('often ')) return ', $bare';
    return ', often $bare';
  }

  static String _enClause(String bare) {
    if (bare.isEmpty) return 'shows up quietly';
    if (bare.startsWith('often ')) return bare.substring(6);
    return bare;
  }

  static String _tailBare(String tail, String lang) {
    var t = tail.trim();
    if (lang == 'th') {
      for (final p in ['ซึ่งมัก', 'โดยหลายครั้ง', 'ซึ่ง', 'โดย']) {
        if (t.startsWith(p)) {
          t = t.substring(p.length).trimLeft();
          break;
        }
      }
      return t;
    }
    if (t.startsWith(',')) t = t.substring(1).trim();
    if (t.startsWith('often ')) t = t.substring(6).trim();
    return t;
  }

  static String _stripAllConnectors(String bare, String lang) {
    if (lang != 'th') return bare.trim();
    var s = bare.trim();
    const prefixes = ['ซึ่งมัก', 'โดยหลายครั้ง', 'ซึ่ง', 'โดย', 'หลายครั้ง'];
    var changed = true;
    while (changed) {
      changed = false;
      for (final p in prefixes) {
        if (s.startsWith(p)) {
          s = s.substring(p.length).trimLeft();
          changed = true;
        }
      }
    }
    return s;
  }

  /// Collapse duplicate connectors / stitched rhythm (TH + EN).
  static String _finalize(String text, String lang) {
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (lang == 'th') {
      const collapse = {
        'โดยหลายครั้งโดยหลายครั้ง': 'โดยหลายครั้ง',
        'หลายครั้งสิ่งนี้โดยหลายครั้ง': 'หลายครั้งสิ่งนี้',
        'หลายครั้งหลายครั้ง': 'หลายครั้ง',
        'ซึ่งมักซึ่งมัก': 'ซึ่งมัก',
        'มักมัก': 'มัก',
        'ค่อยๆ ค่อยๆ': 'ค่อยๆ',
        'และและ': 'และ',
        '  และ': ' และ',
      };
      for (final e in collapse.entries) {
        t = t.replaceAll(e.key, e.value);
      }
      t = t.replaceAll(RegExp(r'(คุณมัก[^\.]+?) ซึ่งมัก'), r'$1 และ');
      t = t.replaceAll(RegExp(r'(คุณอาจ[^\.]+?) ซึ่งมัก'), r'$1 และ');
      t = t.replaceAll(RegExp(r'(มัก[^\.]{3,40}?) ซึ่งมัก'), r'$1 และ');
      if (t.contains('หลายครั้งสิ่งนี้โดย')) {
        t = t.replaceFirst('หลายครั้งสิ่งนี้โดยหลายครั้ง', 'หลายครั้งสิ่งนี้');
        t = t.replaceFirst('หลายครั้งสิ่งนี้โดย', 'หลายครั้งสิ่งนี้ ');
      }
    } else {
      t = t.replaceAll('often often', 'often');
      t = t.replaceAll(', ,', ',');
    }
    return t;
  }

  static int _hash(String key) {
    var h = 17;
    for (final u in key.codeUnits) {
      h = (h * 31 + u) & 0x7fffffff;
    }
    return h;
  }
}
