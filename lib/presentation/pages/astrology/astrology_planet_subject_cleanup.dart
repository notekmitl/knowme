// Subject / modal dedupe for planet card copy (TH focus).
abstract final class AstrologyPlanetSubjectCleanup {
  /// Remove subject leads so rhythm templates can add exactly one.
  static String neutralizeCoreBody(String core, String lang) {
    if (lang != 'th') return _neutralizeEnCore(core);
    var c = core.trim();
    var changed = true;
    while (changed) {
      changed = false;
      for (final p in _thSubjectPrefixes) {
        if (c.startsWith(p)) {
          c = c.substring(p.length).trimLeft();
          changed = true;
          break;
        }
      }
    }
    return c;
  }

  /// After compose + connector finalize.
  static String normalize(String text, String lang) {
    if (lang != 'th') return _normalizeEn(text);
    var t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    for (var i = 0; i < 6; i++) {
      final next = _normalizeThPass(t);
      if (next == t) break;
      t = next;
    }
    return t;
  }

  static const _thSubjectPrefixes = [
    'คุณอาจ',
    'คุณมัก',
    'คุณ',
    'อาจ',
    'มัก',
  ];

  static String _normalizeThPass(String t) {
    const replacements = <String, String>{
      'คุณมักคุณอาจ': 'คุณอาจ',
      'คุณมักคุณมัก': 'คุณมัก',
      'คุณอาจคุณมัก': 'คุณอาจ',
      'คุณอาจคุณอาจ': 'คุณอาจ',
      'คุณมักคุณ': 'คุณมัก',
      'คุณอาจคุณ': 'คุณอาจ',
      'คุณมักอาจ': 'คุณอาจ',
      'คุณอาจมัก': 'คุณมัก',
      'คุณคุณอาจ': 'คุณอาจ',
      'คุณคุณมัก': 'คุณมัก',
      'คุณคุณ': 'คุณ',
      'ในขณะที่คุณคุณอาจ': 'ในขณะที่คุณอาจ',
      'ในขณะที่คุณคุณมัก': 'ในขณะที่คุณมัก',
      'ในขณะที่คุณคุณ': 'ในขณะที่คุณ',
      'เวลาบางเรื่องสำคัญ คุณคุณมัก': 'เวลาบางเรื่องสำคัญ คุณมัก',
      'เวลาบางเรื่องสำคัญ คุณคุณอาจ': 'เวลาบางเรื่องสำคัญ คุณอาจ',
      'เวลาบางเรื่องสำคัญ คุณคุณ': 'เวลาบางเรื่องสำคัญ คุณ',
      'เมื่อบางอย่างสำคัญกับใจ คุณอาจคุณอาจ': 'เมื่อบางอย่างสำคัญกับใจ คุณอาจ',
      'เมื่อบางอย่างสำคัญกับใจ คุณอาจคุณ': 'เมื่อบางอย่างสำคัญกับใจ คุณอาจ',
      'จังหวะที่รู้สึกปลอดภัย คุณมักคุณอาจ': 'จังหวะที่รู้สึกปลอดภัย คุณอาจ',
      'จังหวะที่รู้สึกปลอดภัย คุณมักคุณมัก': 'จังหวะที่รู้สึกปลอดภัย คุณมัก',
      'เรื่องบางอย่างคุณอาจคุณอาจ': 'เรื่องบางอย่างคุณอาจ',
      'หลายครั้งคุณอาจ': 'หลายครั้ง',
      'หลายครั้งคุณมัก': 'หลายครั้ง',
    };

    var out = t;
    for (final e in replacements.entries) {
      out = out.replaceAll(e.key, e.value);
    }

    out = out.replaceAllMapped(
      RegExp(r'ในขณะที่คุณ(คุณ)+'),
      (_) => 'ในขณะที่คุณ',
    );
    out = out.replaceAllMapped(
      RegExp(r'(เวลาบางเรื่องสำคัญ )คุณ(คุณ)+'),
      (_) => 'เวลาบางเรื่องสำคัญ คุณ',
    );

    return out;
  }

  static String _neutralizeEnCore(String core) {
    var c = core.trim();
    for (final p in ['You may often ', 'You may ', 'You often ', 'often ']) {
      if (c.startsWith(p)) {
        c = c.substring(p.length).trimLeft();
      }
    }
    if (c.isNotEmpty) {
      c = '${c[0].toLowerCase()}${c.substring(1)}';
    }
    return c;
  }

  static String _normalizeEn(String t) {
    var out = t;
    out = out.replaceAll('You may You may', 'You may');
    out = out.replaceAll('You often You often', 'You often');
    out = out.replaceAll('you you ', 'you ');
    out = out.replaceAll('often often', 'often');
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
