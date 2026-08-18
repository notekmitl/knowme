import 'life_map_verdict_semantics.dart';

/// V1.3.0 — turns structured life claims into short plain Thai for the UI.
///
/// Keeps meaning from [LifeMapVerdictSemantics]; never invents events.
/// Does not dump internal domain labels, and never prefixes every sentence
/// with the same time marker.
abstract final class LifeMapPlainThaiRenderer {
  /// Full Past card body — flowing story of 4–6 short sentences when evidence
  /// supports; fewer when sparse. Grouped into 2–3 paragraphs (not bullet list).
  static String renderPastBody(LifeMapVerdictSemantics semantics) {
    final beats = semantics.beats;
    var sentences = <String>[];
    if (beats.isNotEmpty) {
      for (final beat in beats) {
        final t = _stripPastSoftOpener(_stripSystemPhrases(beat.textTh));
        if (t.isEmpty) continue;
        if (_omitVagueClaim(t)) continue;
        if (sentences.any((s) => _sameMeaning(s, t))) continue;
        sentences.add(t);
      }
    } else {
      for (final slot in _buildSlots(semantics, LifeMapVerdictTense.past)) {
        if (slot.text.isEmpty) continue;
        sentences.add(slot.text);
      }
    }
    if (sentences.isEmpty) return '';

    // V1.3.2: never soft-open Past with "ในช่วงนั้น" / similar filler.
    sentences = [
      for (final s in sentences) _stripPastSoftOpener(s),
    ].where((s) => s.isNotEmpty).toList();
    if (sentences.isEmpty) return '';

    List<String> paragraphs;
    if (sentences.length <= 2) {
      paragraphs = [sentences.join(' ')];
      // Matrix + UX still expect ≥2 paragraphs when we have ≥2 beats.
      if (sentences.length == 2) {
        paragraphs = [sentences.first, sentences.last];
      }
    } else if (sentences.length == 3) {
      paragraphs = ['${sentences[0]} ${sentences[1]}', sentences[2]];
    } else if (sentences.length == 4) {
      paragraphs = [
        '${sentences[0]} ${sentences[1]}',
        '${sentences[2]} ${sentences[3]}',
      ];
    } else {
      // 5–6: three paragraphs of story beats.
      paragraphs = [
        '${sentences[0]} ${sentences[1]}',
        '${sentences[2]} ${sentences[3]}',
        sentences.skip(4).join(' '),
      ];
    }
    return paragraphs.where((p) => p.trim().isNotEmpty).join('\n\n');
  }

  /// Current / Future card fields.
  static ({String summary, String whatChanges, String harder, String advice})
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

    final situationText = _plainSituation(tense, primary.situationTh);
    final raw = <_Slot>[
      if (situationText.isNotEmpty)
        _Slot(
          role: _SlotRole.situation,
          text: situationText,
          key: 'sit:${primary.situationId}|${primary.domainId}',
        ),
    ];

    if (pressure != null &&
        pressure.pressureTh.trim().isNotEmpty &&
        !_nearDuplicate(pressure.pressureTh, primary.situationTh)) {
      final cleaned = _stripSystemPhrases(pressure.pressureTh);
      if (!_omitVagueClaim(cleaned)) {
        raw.add(
          _Slot(
            role: _SlotRole.pressure,
            text: cleaned,
            key: 'prs:${pressure.pressureId}|${pressure.domainId}',
          ),
        );
      }
    }

    if (consequence != null &&
        consequence.consequenceTh.trim().isNotEmpty &&
        !_nearDuplicate(consequence.consequenceTh, primary.situationTh) &&
        (pressure == null ||
            !_nearDuplicate(consequence.consequenceTh, pressure.pressureTh))) {
      final cleaned = _plainConsequence(tense, consequence.consequenceTh);
      if (!_omitVagueClaim(cleaned)) {
        raw.add(
          _Slot(
            role: _SlotRole.consequence,
            text: cleaned,
            key: 'cons:${consequence.consequenceId}|${consequence.domainId}',
          ),
        );
      }
    }

    // Deduplicate by normalized meaning; keep order situation → pressure → consequence.
    final kept = <_Slot>[];
    for (final slot in raw) {
      if (slot.text.trim().isEmpty) continue;
      if (_omitVagueClaim(slot.text)) continue;
      if (kept.any((k) => _nearDuplicate(k.text, slot.text))) continue;
      kept.add(slot);
    }

    // At most one time marker across the whole card.
    return _limitTimeMarkers(kept, tense);
  }

  static String _plainSituation(LifeMapVerdictTense tense, String body) {
    var clean = _stripSystemPhrases(body);
    clean = _stripPastSoftOpener(clean);
    if (_omitVagueClaim(clean)) return '';
    // Prefer opening with the event itself. Time marker only when tense needs it.
    switch (tense) {
      case LifeMapVerdictTense.past:
        return clean;
      case LifeMapVerdictTense.current:
        if (_startsWithTimeMarker(clean)) return clean;
        return clean.isEmpty ? '' : 'ตอนนี้$clean';
      case LifeMapVerdictTense.future:
        if (_startsWithTimeMarker(clean)) return clean;
        return clean.isEmpty ? '' : 'ต่อไป$clean';
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
    // V1.3.2: Past must not keep soft "ช่วงนั้น" fillers at all.
    if (tense == LifeMapVerdictTense.past) {
      return [
        for (final slot in slots)
          _Slot(
            role: slot.role,
            text: _stripPastSoftOpener(slot.text),
            key: slot.key,
          ),
      ].where((s) => s.text.isNotEmpty && !_omitVagueClaim(s.text)).toList();
    }

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
          if (_omitVagueClaim(text)) {
            return _Slot(role: slot.role, text: '', key: slot.key);
          }
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
          text = text
              .replaceAll(marker, '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
          return _Slot(role: slot.role, text: text, key: slot.key);
        }(),
    ].where((s) => s.text.isNotEmpty).toList();
  }

  /// Strip Past soft openers that add no event information.
  static String stripPastSoftOpenerPublic(String text) =>
      _stripPastSoftOpener(text);

  /// Strip Past soft openers that add no event information.
  static String _stripPastSoftOpener(String text) {
    var t = text.trim();
    t = t.replaceFirst(
      RegExp(r'^(ในช่วงนั้น|ช่วงนั้น|ณ ช่วงเวลานั้น|ในเวลานั้น)\s*'),
      '',
    );
    t = t
        .replaceAll('ในช่วงนั้น', '')
        .replaceAll('ณ ช่วงเวลานั้น', '')
        .replaceAll(RegExp(r'(^|\s)ช่วงนั้น\s*'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return t;
  }

  /// Omit claims that stay abstract without a concrete life action.
  static bool _omitVagueClaim(String text) => hasVagueRelationshipForm(text);

  static bool _startsWithTimeMarker(String text) {
    return text.startsWith('ช่วงนั้น') ||
        text.startsWith('ตอนนี้') ||
        text.startsWith('ช่วงนี้') ||
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

  /// Strict near-duplicate for cross-slot dedupe (not loose token overlap).
  /// Keeps distinct claims that share a few words but say different actions.
  static bool _nearDuplicate(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (na.contains(nb) || nb.contains(na)) {
      final shorter = na.length < nb.length ? na : nb;
      return shorter.length >= 18;
    }
    return false;
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

  /// Public duplicate check for mapper past-beat assembly.
  static bool sameMeaningPublic(String a, String b) => _sameMeaning(a, b);

  /// True when prose uses abstract "A กับ B แย่งกัน" without a clear actor.
  static bool hasAbstractDuel(String text) {
    if (text.contains('แย่งกัน')) return true;
    return RegExp(r'[^。\n]{4,}กับ[^。\n]{4,}(แย่ง|แข่ง|สู้กัน)').hasMatch(text);
  }

  /// Vague relationship form-change / boundary jargon without a concrete act.
  static bool hasVagueRelationshipForm(String text) {
    if (text.contains('รูปแบบความรักเปลี่ยน')) return true;
    if (text.contains('รูปแบบความใกล้ชิดเปลี่ยน')) return true;
    if (text.contains('ตั้งขอบเขตใหม่') || text.contains('ต้องตั้งขอบเขต')) {
      return true;
    }
    if (RegExp(r'รูปแบบ.{0,16}เปลี่ยน').hasMatch(text) &&
        (text.contains('ความรัก') ||
            text.contains('ใกล้ชิด') ||
            text.contains('ความสัมพันธ์') ||
            text.contains('ผูกพัน'))) {
      return true;
    }
    return false;
  }

  /// Past soft opener fillers that add no event data.
  static bool hasPastSoftOpener(String text) {
    return text.contains('ในช่วงนั้น') ||
        text.contains('ณ ช่วงเวลานั้น') ||
        RegExp(r'(^|\n|\s)ในเวลานั้น\b').hasMatch(text) ||
        RegExp(r'(^|\n)ช่วงนั้น').hasMatch(text);
  }

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
