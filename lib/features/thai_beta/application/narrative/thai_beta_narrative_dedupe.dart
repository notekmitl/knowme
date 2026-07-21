/// Presentation-layer deduplication for Thai Beta narrative V1.1.
library;

import 'thai_beta_narrative_forbidden.dart';
import 'thai_beta_narrative_formatting.dart';

abstract final class ThaiBetaNarrativeDedupe {
  static const _fixedTemplatePatterns = <String>[
    'และนั่นคือสิ่งที่ทำให้คนรอบตัวรู้สึกว่ามีคุณอยู่แล้วอุ่นใจ',
    'แต่บางครั้งก็แบกมันไว้คนเดียวนานเกินไป',
    'นี่อาจเป็นเหตุผล',
    'พอเป็นแบบนี้คุณเลย',
    'สิ่งที่คนมักสัมผัสได้จากคุณก่อนเลยคือ',
    'อย่างเช่น เมื่อต้องใช้',
    'ตัวอย่างที่พบได้บ่อยคือเมื่อต้องใช้',
    'ภาพรวมค่อนข้างเอื้อ',
    'ถ้าจะเข้าใจคุณ แค่เรื่องเดียว',
    'ในขณะที่อีกด้านหนึ่ง',
    'แต่เมื่อต้องตัดสินใจ คุณยัง',
  ];

  static const _allowedRepeatedDisclaimers = <String>{
    'นี่ไม่ใช่คำฟันธง',
    'บางอย่างอาจใช่ บางอย่างอาจไม่',
    'ลองอ่านช้า ๆ',
    'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง',
    'โดยไม่มีเวลาเกิด',
  };

  /// Removes duplicates within [paragraphs] and against [globalUsed].
  static List<String> dedupeParagraphs({
    required String sectionId,
    required List<String> paragraphs,
    required Set<String> globalUsed,
    String? sectionTitle,
  }) {
    final out = <String>[];
    final sectionUsed = <String>{};

    for (final raw in paragraphs) {
      final polished = ThaiBetaNarrativeFormatting.normalize(raw);
      if (polished.isEmpty) continue;
      if (sectionTitle != null && polished == sectionTitle) continue;
      if (ThaiBetaNarrativeForbidden.findForbidden(polished).isNotEmpty) {
        continue;
      }

      final key = ThaiBetaNarrativeFormatting.normalizedKey(polished);
      if (key.length < 8) {
        out.add(polished);
        continue;
      }

      if (_isSemanticLeadDuplicate(polished, sectionUsed)) continue;
      if (sectionUsed.contains(key)) {
        if (_isAllowedRepeat(polished)) {
          out.add(polished);
        }
        continue;
      }
      if (globalUsed.contains(key) && !_isAllowedRepeat(polished)) continue;
      if (_isSemanticDuplicateOfTitle(polished, sectionTitle)) continue;
      if (_matchesFixedTemplateOveruse(polished, globalUsed)) continue;

      out.add(polished);
      sectionUsed.add(key);
      globalUsed.add(key);
      _recordFixedTemplateKeys(polished, globalUsed);
    }
    return out;
  }

  static bool _isSemanticLeadDuplicate(String text, Set<String> sectionUsed) {
    for (final existing in sectionUsed) {
      if (ThaiBetaNarrativeForbidden.isSemanticVariant(text, existing)) {
        return true;
      }
    }
    return false;
  }

  static void _recordFixedTemplateKeys(String text, Set<String> used) {
    for (final pattern in _fixedTemplatePatterns) {
      if (!text.contains(pattern)) continue;
      used.add(ThaiBetaNarrativeFormatting.normalizedKey(pattern));
    }
  }

  static String? dedupeAgainstUsed(String text, Set<String> used, {String? alt}) {
    final polished = ThaiBetaNarrativeFormatting.normalize(text);
    if (ThaiBetaNarrativeForbidden.findForbidden(polished).isNotEmpty) {
      if (alt != null) return dedupeAgainstUsed(alt, used);
      return null;
    }
    final key = ThaiBetaNarrativeFormatting.normalizedKey(polished);
    if (!used.contains(key)) {
      used.add(key);
      _recordFixedTemplateKeys(polished, used);
      return polished;
    }
    if (alt != null) {
      final altPolished = ThaiBetaNarrativeFormatting.normalize(alt);
      final altKey = ThaiBetaNarrativeFormatting.normalizedKey(altPolished);
      if (!used.contains(altKey)) {
        used.add(altKey);
        _recordFixedTemplateKeys(altPolished, used);
        return altPolished;
      }
    }
    return null;
  }

  /// Picks the first unused candidate; never reintroduces a duplicate [text].
  static String resolveUnique({
    required String text,
    required Set<String> used,
    List<String> fallbacks = const [],
  }) {
    final primary = dedupeAgainstUsed(text, used);
    if (primary != null) return primary;
    for (final fallback in fallbacks) {
      final resolved = dedupeAgainstUsed(fallback, used);
      if (resolved != null) return resolved;
    }
    return '';
  }

  static bool _isAllowedRepeat(String text) {
    return _allowedRepeatedDisclaimers.any(text.contains);
  }

  static bool _isSemanticDuplicateOfTitle(String text, String? title) {
    if (title == null || title.trim().isEmpty) return false;
    final titleKey = ThaiBetaNarrativeFormatting.normalizedKey(title);
    final textKey = ThaiBetaNarrativeFormatting.normalizedKey(text);
    if (textKey == titleKey) return true;
    if (textKey.startsWith(titleKey) && textKey.length - titleKey.length < 12) {
      return true;
    }
    return false;
  }

  static bool _matchesFixedTemplateOveruse(String text, Set<String> globalUsed) {
    for (final pattern in _fixedTemplatePatterns) {
      if (!text.contains(pattern)) continue;
      final patternKey = ThaiBetaNarrativeFormatting.normalizedKey(pattern);
      if (globalUsed.contains(patternKey)) return true;
    }
    return false;
  }

  /// Builds strength expanded body from curated 3-part block text.
  static String buildStrengthExpanded({
    required String title,
    required String expandedBody,
    required Set<String> used,
  }) {
    var body = ThaiBetaNarrativeFormatting.normalize(expandedBody);
    body = body.replaceAll('**', '');

    final titleNorm = ThaiBetaNarrativeFormatting.normalizedKey(title);
    final paragraphs = body.split(RegExp(r'\n\n+'));
    final out = <String>[];

    for (final p in paragraphs) {
      var para = p.trim();
      if (para.isEmpty) continue;

      if (ThaiBetaNarrativeForbidden.findForbidden(para).isNotEmpty) continue;

      final key = ThaiBetaNarrativeFormatting.normalizedKey(para);
      if (titleNorm == key) continue;
      if (used.contains(key)) continue;
      if (_isSemanticLeadDuplicate(para, used)) continue;

      out.add(para);
      used.add(key);
    }

    if (out.isEmpty) return body;
    return out.join('\n\n');
  }

  /// @deprecated Use [buildStrengthExpanded].
  static String rewriteStrengthExpanded({
    required String title,
    required String expandedBody,
    required Set<String> used,
  }) =>
      buildStrengthExpanded(
        title: title,
        expandedBody: expandedBody,
        used: used,
      );
}
