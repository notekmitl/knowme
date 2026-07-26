import 'life_map_verdict_semantics.dart';

/// V1.3.0 — turns structured life claims into short plain Thai for the UI.
///
/// Keeps meaning from [LifeMapVerdictSemantics]; never invents events.
/// Does not dump internal domain labels, and never prefixes every sentence
/// with the same time marker.
abstract final class LifeMapPlainThaiRenderer {
  /// Full Past card body (2–3 short sentences). Harder/advice stay empty.
  static String renderPastBody(LifeMapVerdictSemantics semantics) {
    final slots = _buildSlots(semantics, LifeMapVerdictTense.past);
    return slots.map((s) => s.text).join('\n\n');
  }

  /// Current / Future card fields.
  static ({
    String summary,
    String whatChanges,
    String harder,
    String advice,
  })
  renderPresentFuture(LifeMapVerdictSemantics semantics) {
    final slots = _buildSlots(semantics, semantics.tense);
    final summary = slots.isNotEmpty ? slots[0].text : '';
    final harder = slots.length > 1 ? slots[1].text : '';
    final advice = slots.length > 2 ? slots[2].text : '';
    return (
      summary: summary,
      whatChanges: '', // avoid paraphrase of summary
      harder: harder,
      advice: advice,
    );
  }

  static List<_Slot> _buildSlots(
    LifeMapVerdictSemantics semantics,
    LifeMapVerdictTense tense,
  ) {
    final primary = semantics.primary;
    final pressure = semantics.pressure;
    final consequence = semantics.consequence;

    final raw = <_Slot>[
      _Slot(
        role: _SlotRole.situation,
        text: _plainSituation(tense, primary.situationTh),
        key: 'sit:${primary.situationId}|${primary.domainId}',
      ),
    ];

    if (pressure != null &&
        pressure.pressureTh.trim().isNotEmpty &&
        !_sameMeaning(pressure.pressureTh, primary.situationTh)) {
      raw.add(
        _Slot(
          role: _SlotRole.pressure,
          text: _stripSystemPhrases(pressure.pressureTh),
          key: 'prs:${pressure.pressureId}|${pressure.domainId}',
        ),
      );
    }

    if (consequence != null &&
        consequence.consequenceTh.trim().isNotEmpty &&
        !_sameMeaning(consequence.consequenceTh, primary.situationTh) &&
        (pressure == null ||
            !_sameMeaning(consequence.consequenceTh, pressure.pressureTh))) {
      raw.add(
        _Slot(
          role: _SlotRole.consequence,
          text: _plainConsequence(tense, consequence.consequenceTh),
          key: 'cons:${consequence.consequenceId}|${consequence.domainId}',
        ),
      );
    }

    // Deduplicate by normalized meaning; keep order situation → pressure → consequence.
    final kept = <_Slot>[];
    for (final slot in raw) {
      if (kept.any((k) => _sameMeaning(k.text, slot.text))) continue;
      kept.add(slot);
    }

    // At most one time marker across the whole card.
    return _limitTimeMarkers(kept, tense);
  }

  static String _plainSituation(LifeMapVerdictTense tense, String body) {
    final clean = _stripSystemPhrases(body);
    // Prefer opening with the event itself. Time marker only when tense needs it.
    switch (tense) {
      case LifeMapVerdictTense.past:
        return clean;
      case LifeMapVerdictTense.current:
        if (_startsWithTimeMarker(clean)) return clean;
        return 'ตอนนี้$clean';
      case LifeMapVerdictTense.future:
        if (_startsWithTimeMarker(clean)) return clean;
        return 'ต่อไป$clean';
    }
  }

  static String _plainConsequence(LifeMapVerdictTense tense, String body) {
    var clean = _stripSystemPhrases(body);
    clean = clean
        .replaceFirst(RegExp(r'^ผลของช่วงนั้น(คือ|ทำให้คุณ)'), '')
        .replaceFirst(RegExp(r'^ผลที่ตามมาคือ'), '')
        .replaceFirst(RegExp(r'^สภาพใหม่ที่ตามมาคือ'), '')
        .replaceFirst(RegExp(r'^ผลต่อชีวิตคือ'), '')
        .trim();
    if (clean.isEmpty) return body.trim();
    // Bodies are already complete plain sentences; only add a soft past lead
    // when the line has no actor yet.
    if (tense == LifeMapVerdictTense.past &&
        !clean.startsWith('คุณ') &&
        !clean.startsWith('ผล') &&
        !clean.startsWith('ชีวิต') &&
        !clean.startsWith('คน') &&
        !clean.startsWith('ทักษะ')) {
      return 'ผลจากเรื่องนี้ทำให้$clean';
    }
    return clean;
  }

  static List<_Slot> _limitTimeMarkers(
    List<_Slot> slots,
    LifeMapVerdictTense tense,
  ) {
    final marker = switch (tense) {
      LifeMapVerdictTense.past => 'ช่วงนั้น',
      LifeMapVerdictTense.current => 'ตอนนี้',
      LifeMapVerdictTense.future => 'ต่อไป',
    };
    var seen = false;
    return [
      for (final slot in slots)
        () {
          var text = slot.text;
          final count = marker.allMatches(text).length;
          if (count == 0) return slot;
          if (!seen) {
            seen = true;
            // Keep first occurrence only inside this sentence.
            if (count > 1) {
              final first = text.indexOf(marker);
              text =
                  text.substring(0, first + marker.length) +
                  text.substring(first + marker.length).replaceAll(marker, '');
            }
            return _Slot(role: slot.role, text: text, key: slot.key);
          }
          text = text.replaceAll(marker, '').replaceAll(RegExp(r'\s+'), ' ').trim();
          return _Slot(role: slot.role, text: text, key: slot.key);
        }(),
    ];
  }

  static bool _startsWithTimeMarker(String text) {
    return text.startsWith('ช่วงนั้น') ||
        text.startsWith('ตอนนี้') ||
        text.startsWith('ต่อไป') ||
        text.startsWith('ขณะนี้') ||
        text.startsWith('ช่วงถัดไป');
  }

  static String _stripSystemPhrases(String text) {
    var t = text.trim();
    const bannedPrefixes = [
      'ผลกระทบหลักอยู่ที่',
      'โดยกระทบ',
      'ควบคู่กับด้าน',
      'ด้านที่ได้รับผลชัดคือ',
      'แรงกดดันหลักอยู่ที่',
      'แรงกดดันหลักคือ',
      'ความขัดแย้งหลักอยู่ที่',
    ];
    for (final p in bannedPrefixes) {
      t = t.replaceAll(p, '');
    }
    t = t
        .replaceAll(RegExp(r'โดยตรง\s*$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return t;
  }

  /// Loose meaning compare for duplicate slots (not string equality alone).
  static bool _sameMeaning(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) {
      final shorter = na.length < nb.length ? na : nb;
      return shorter.length >= 12;
    }
    // Token overlap on content words.
    final ta = na.split(RegExp(r'[และหรือกับจนให้ที่ของใน]'));
    final tb = nb.split(RegExp(r'[และหรือกับจนให้ที่ของใน]'));
    final sa = ta.where((w) => w.length >= 3).toSet();
    final sb = tb.where((w) => w.length >= 3).toSet();
    if (sa.isEmpty || sb.isEmpty) return false;
    final inter = sa.intersection(sb).length;
    final union = sa.union(sb).length;
    return inter / union >= 0.72;
  }

  static String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('ช่วงนั้น', '')
        .replaceAll('ตอนนี้', '')
        .replaceAll('ต่อไป', '')
        .replaceAll('ขณะนี้', '')
        .replaceAll('ช่วงถัดไป', '')
        .replaceAll('ผลจากเรื่องนี้ทำให้', '')
        .replaceAll('ผลของช่วงนั้นคือ', '')
        .replaceAll('ผลที่ตามมาคือ', '');
  }

  /// Product Language Gate helpers (UI-visible text).
  static int countMarker(String cardText, String marker) =>
      marker.allMatches(cardText).length;

  static bool hasDomainDumpTail(String text) {
    const dumps = [
      'ผลกระทบหลักอยู่ที่',
      'ควบคู่กับด้าน',
      'โดยกระทบ',
      'ด้านที่ได้รับผลชัดคือ',
      'เป้าหมายเปลี่ยนไปสู่',
    ];
    return dumps.any(text.contains);
  }

  static bool hasHardJargon(String text) {
    const jargon = [
      'โครงสร้างชีวิต',
      'ขอบเขตงาน',
      'ขยายบทบาท',
      'โอกาสและการขยายบทบาท',
      'งานและบทบาท',
      'บ้านและครอบครัว',
      'ความมั่นคงทางใจผูกกับ',
      'บทบาทถูกจัดใหม่',
      'รับผิดชอบผลเอง',
      'รูปแบบเดิม',
      'เส้นทางเดิม',
      'การเปลี่ยนผ่าน',
      'ผลกระทบหลักอยู่ที่',
    ];
    return jargon.any(text.contains);
  }

  static int approxClauseCount(String sentence) {
    // Count only spaced Thai conjunctions — bare character splits over-count.
    final parts = sentence.split(RegExp(r'\s+(และ|หรือ|แต่|จึง|จน)\s+'));
    return parts.where((p) => p.trim().isNotEmpty).length;
  }
}

enum _SlotRole { situation, pressure, consequence }

class _Slot {
  const _Slot({required this.role, required this.text, required this.key});
  final _SlotRole role;
  final String text;
  final String key;
}
