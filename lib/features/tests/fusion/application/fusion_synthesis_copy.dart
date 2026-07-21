import '../domain/fusion_constants.dart';
import '../domain/fusion_models.dart';

/// Deterministic TH/EN copy (precision + resonance V1 — concise, human).
abstract final class FusionSynthesisCopy {
  static String t(String lang, String th, String en) => lang == 'th' ? th : en;

  // --- Hero (2–4 sentences, lived + precise) ---

  static String heroFallback(String lang) => t(
        lang,
        'ตอนนี้อาจยังเห็นภาพรวมไม่ครบ '
            'ถ้าทำแบบทดสอบเพิ่มเล็กน้อย ดวงและผลที่คุณทำไว้อาจช่วยให้เห็นว่าหลายอย่างในตัวคุณสอดคล้องกันอย่างไร',
        'The overview may still be thin. '
            'A few more tests can show how your chart and results line up in you.',
      );

  static String heroExplorationStructure(String lang) => t(
        lang,
        'ดูเหมือนว่าคุณอาจเปิดรับทางเลือกใหม่ได้พอสมควร '
            'และหลายครั้งอยากลองสิ่งที่ยังไม่คุ้นเคย\n'
            'แต่โดยเฉพาะเมื่อเรื่องนั้นสำคัญ คุณอาจอยากมีเหตุผลหรือความชัดเจนก่อนผูกมัด '
            'เหมือนมีส่วนที่อยากลองเร็ว กับส่วนที่อยากมั่นใจก่อนตัดสินใจ',
        'You may open to new paths more than you expect, '
            'and often want to try what still feels unfamiliar.\n'
            'Especially when it matters, you may want some reason or clarity before you commit—'
            'as if one part of you wants to explore and another wants to feel sure.',
      );

  static String heroExplorationThinking(String lang) => t(
        lang,
        'เวลาต้องเลือกงาน ทิศทาง หรือความสัมพันธ์ '
            'คุณอาจลองหลายทางก่อน และหลายครั้งอยากคิดทบทวนก่อนลงมือจริงจัง\n'
            'ดูเหมือนว่าคุณอาจไม่รีบตัดสินใจจนกว่ารู้สึกว่าทางนั้นเข้ากับตัวคุณ',
        'When work, direction, or a relationship is on the line, '
            'you may try more than one path and often want to think before you act.\n'
            'You may not rush the final call until it feels like you.',
      );

  static String heroExplorationPrimary(String lang) => t(
        lang,
        'คุณอาจเปิดรับสิ่งใหม่ได้ง่ายกว่าที่คิด '
            'และหลายครั้งความเป็นไปได้ใหม่ๆ อาจดึงคุณเข้าไปได้ไม่ยาก\n'
            'โดยเฉพาะเมื่อรู้สึกว่ามีพื้นที่ลอง '
            'คุณอาจลองก่อนแล้วค่อยดูว่ามันเข้ากับชีวิตคุณหรือไม่',
        'You may take in what is new more easily than you expect, '
            'and fresh possibilities can pull you in.\n'
            'When there is room to try, you may test first—then see if it fits your life.',
      );

  static String heroThinkingPrimary(String lang) => t(
        lang,
        'เวลาต้องตัดสินใจ คุณอาจอยากหยุดคิดก่อน '
            'และหลายครั้งสบายใจขึ้นเมื่อเห็นเหตุผลหรือทิศทางชัดขึ้น\n'
            'แต่ในบางเรื่อง ดูเหมือนว่าคุณอาจไม่ต้องการความสมบูรณ์แบบ '
            'แค่อยากให้การเลือกรู้สึกใช่พอที่จะลงมือ',
        'When you decide, you may pause to think '
            'and often feel steadier once something makes sense.\n'
            'On some matters you may not need perfection—just enough of a yes to move.',
      );

  static String heroEmotionPrimary(String lang) => t(
        lang,
        'เมื่อเรื่องใกล้ชิด คุณอาจรับรู้ความรู้สึกของตัวเองได้ชัด '
            'และหลายครั้งอารมณ์อาจบอกว่าอะไรสำคัญกับคุณจริงๆ\n'
            'แต่หลายครั้งคุณอาจไม่ตัดสินใจจากอารมณ์อย่างเดียว '
            'ดูเหมือนว่าคุณอาจฟังความรู้สึกก่อน แล้วค่อยเลือกทาง',
        'When something feels close, you may notice your feelings clearly, '
            'and mood can tell you what matters.\n'
            'You may not decide from emotion alone—you may listen first, then choose.',
      );

  static String heroSocialPrimary(String lang) => t(
        lang,
        'เวลาอยู่กับคนที่คุณไว้ใจ คุณอาจแสดงออกได้ชัด '
            'และหลายครั้งความสัมพันธ์อาจมีอิทธิพลต่อการตัดสินใจ\n'
            'แต่ในบางเรื่องคุณอาจยังอยากมีพื้นที่คิดเอง '
            'ดูเหมือนว่าคุณอาจใช้ทั้งคนรอบข้างและความชัดในตัวไปด้วยกัน',
        'With people you trust, you may show up clearly, '
            'and ties can sway real choices.\n'
            'You may still want room to think for yourself—people and your own clarity together.',
      );

  static String heroExplorationEmotion(String lang) => t(
        lang,
        'คุณอาจเปิดรับประสบการณ์ใหม่ได้ดี '
            'และหลายครั้งสิ่งที่ไม่คุ้นเคยอาจดึงความสนใจได้\n'
            'แต่หลังจากนั้นคุณอาจต้องใช้เวลาปรับใจก่อนรู้สึกมั่นใจ '
            'ดูเหมือนว่าการลองอาจมาก่อน ความสบายใจอาจตามมาทีหลัง',
        'You may take in new experiences readily, '
            'and the unfamiliar can catch your attention.\n'
            'Afterward you may need time to settle before you feel sure—try first, steadiness later.',
      );

  static String heroThinkingSocial(String lang) => t(
        lang,
        'หลายครั้งคุณอาจคิดก่อนพูดหรือลงมือ '
            'และการทบทวนภายในอาจช่วยให้เห็นทางเลือกชัดขึ้น\n'
            'แต่เมื่ออยู่กับผู้คน การคุยหรือสังเกตบรรยากาศอาจเติมสิ่งที่คิดเองยังไม่เห็น '
            'ดูเหมือนว่าคุณอาจใช้ทั้งการคิดเองและคนรอบข้างไปด้วยกัน',
        'You may often think before you speak or act, '
            'and inner reflection can clarify your options.\n'
            'With people, talk or the room itself may add what thinking alone missed—'
            'your own read and the human moment together.',
      );

  // --- Patterns ---

  static String patternTitle(String themeId, String lang) => switch (themeId) {
        FusionThemeIds.exploration => t(
            lang, 'เวลาเจอสิ่งไม่คุ้นเคย', 'Opening to what is new'),
        FusionThemeIds.thinkingStyle => t(
            lang, 'วิธีที่คุณมักใช้คิด', 'Thinking and deciding'),
        FusionThemeIds.emotion => t(
            lang, 'เวลาอารมณ์มีบทบาท', 'Relationship with emotion'),
        FusionThemeIds.socialExpression => t(
            lang, 'เวลาอยู่กับผู้คน', 'Relating to people'),
        _ => t(lang, 'แนวโน้มที่สะท้อนในตัวคุณ', 'Visible tendency'),
      };

  static String patternSummary(
    String themeId,
    FusionSignalStrength peak,
    String lang,
  ) {
    final high = peak == FusionSignalStrength.high;
    return switch (themeId) {
      FusionThemeIds.exploration => high
          ? t(
              lang,
              'เวลาเจอสิ่งไม่คุ้นเคย คุณอาจอยากลองดูก่อน '
                  'โดยเฉพาะเมื่อรู้สึกว่ายังไม่ถูกเร่งให้ตัดสินใจทันที',
              'When something unfamiliar shows up, you may want to try it first—'
                  'especially when you do not feel pushed to decide right away.',
            )
          : t(
              lang,
              'คุณอาจเปิดรับสิ่งใหม่ได้บ้าง '
                  'โดยเฉพาะเมื่อมีเวลาให้ลองก่อนผูกมัดกับทางใดทางหนึ่ง',
              'You may open to what is new in small ways—'
                  'especially when there is time to try before you commit.',
            ),
      FusionThemeIds.thinkingStyle => high
          ? t(
              lang,
              'เวลาต้องตัดสินใจ คุณอาจหยุดคิดก่อน '
                  'และหลายครั้งรู้สึกโล่งขึ้นเมื่อเห็นทิศทางชัดขึ้น',
              'When a choice is on the line, you may pause to think—'
                  'and often feel lighter once the direction makes sense.',
            )
          : t(
              lang,
              'ในบางเรื่องที่สำคัญ คุณอาจคิดก่อนลงมือมากกว่าเรื่องเล็กๆ',
              'On what matters, you may think before acting more than on small things.',
            ),
      FusionThemeIds.emotion => high
          ? t(
              lang,
              'เมื่อเรื่องแตะหัวใจ คุณอาจรู้สึกได้ชัดว่าอะไรสำคัญ '
                  'และหลายครั้งอารมณ์อาจนำทางก่อนที่เหตุผลจะตามมา',
              'When something touches you, you may feel clearly what matters—'
                  'and mood can lead before reason catches up.',
            )
          : t(
              lang,
              'คุณอาจใส่ใจความรู้สึกเป็นบางครั้ง '
                  'โดยเฉพาะเมื่อเรื่องนั้นแตะค่าหรือคนสำคัญ',
              'You may attend to feelings at times, '
                  'especially when values or key people are involved.',
            ),
      FusionThemeIds.socialExpression => high
          ? t(
              lang,
              'เวลาอยู่กับคนที่คุณไว้ใจ คุณอาจพูดหรือแสดงออกได้ชัด '
                  'และหลายครั้งบทสนทนานั้นอาจมีผลต่อการตัดสินใจของคุณ',
              'With people you trust, you may speak or show up clearly—'
                  'and that exchange can sway what you decide next.',
            )
          : t(
              lang,
              'เมื่อรู้สึกปลอดภัย คุณอาจเปิดมากขึ้น '
                  'และความสัมพันธ์อาจค่อยๆ มีบทบาทในชีวิตประจำวัน',
              'When you feel safe, you may open up more—'
                  'and relationships can quietly shape your days.',
            ),
      _ => t(
          lang,
          'แนวโน้มจากดวงและผลทดสอบของคุณ '
              'อาจค่อยๆ แสดงในชีวิตประจำวัน',
          'A tendency from your chart and tests may show in daily life.',
        ),
    };
  }

  /// Light join for multi-pattern lists (no essay connectives).
  static String patternSummaryCohesive(
    String themeId,
    FusionSignalStrength peak,
    String lang, {
    required int index,
    required int total,
  }) {
    final core = patternSummary(themeId, peak, lang);
    if (index == 0 || total <= 1) return core;
    return t(lang, 'และ$core', 'And $core');
  }

  // --- Why (human, transparent) ---

  static String whyForSignalGroup(
    List<String> signalIds,
    List<FusionSignalSource> contributors,
    String lang,
  ) {
    if (signalIds.isEmpty) {
      return t(
        lang,
        'น่าจะสะท้อนจากผลที่คุณทำไว้หลายชุด',
        'This likely reflects the tests you have done.',
      );
    }
    if (signalIds.length == 1) {
      return whyForSignal(signalIds.first, contributors, lang);
    }

    final id = signalIds.first;
    final combined = _whyCombined[_combinedKey(id, contributors)]?.call(lang);
    if (combined != null && combined.isNotEmpty) return combined;

    final clause = _whyClause(id, lang);
    if (clause == null || clause.isEmpty) {
      return whyForSignal(id, contributors, lang);
    }
    return _whyHumanLine(contributors, clause, lang);
  }

  static String whyForSignal(
    String signalId,
    List<FusionSignalSource> contributors,
    String lang,
  ) {
    final combined = _whyCombined[_combinedKey(signalId, contributors)]?.call(lang);
    if (combined != null && combined.isNotEmpty) return combined;

    final clause = _whyClause(signalId, lang);
    if (clause == null || clause.isEmpty) {
      return t(
        lang,
        'น่าจะสะท้อนจากผลที่คุณทำไว้หลายชุด',
        'This likely reflects the tests you have done.',
      );
    }

    return _whyHumanLine(contributors, clause, lang);
  }

  static String _whyHumanLine(
    List<FusionSignalSource> sources,
    String clause,
    String lang,
  ) {
    final hasA = sources.contains(FusionSignalSource.astrology);
    final hasM = sources.contains(FusionSignalSource.mbti);
    final hasC = sources.contains(FusionSignalSource.cognitive);

    if (hasA && hasM && hasC) {
      return t(
        lang,
        'จากดวงของคุณ ผล MBTI และ Cognitive ดูเหมือนว่า $clause',
        'From your chart, MBTI, and Cognitive, it seems $clause',
      );
    }
    if (hasA && hasM) {
      return t(
        lang,
        'จากดวงของคุณและผล MBTI หลายครั้ง $clause',
        'From your chart and MBTI, $clause',
      );
    }
    if (hasA && hasC) {
      return t(
        lang,
        'จากดวงของคุณและ Cognitive ดูเหมือนว่า $clause',
        'From your chart and Cognitive, it seems $clause',
      );
    }
    if (hasM && hasC) {
      return t(
        lang,
        'จากผล MBTI และ Cognitive หลายครั้ง $clause',
        'From MBTI and Cognitive, $clause',
      );
    }
    if (hasA) {
      return t(lang, 'จากดวงของคุณ ดูเหมือนว่า $clause', 'From your chart, it seems $clause');
    }
    if (hasM) {
      return t(lang, 'จากผล MBTI หลายครั้ง $clause', 'From your MBTI, $clause');
    }
    if (hasC) {
      return t(lang, 'จาก Cognitive ดูเหมือนว่า $clause', 'From Cognitive, it seems $clause');
    }
    return clause;
  }

  static String _combinedKey(
    String signalId,
    List<FusionSignalSource> sources,
  ) {
    final sorted = [...sources]..sort((a, b) => a.index.compareTo(b.index));
    return '$signalId|${sorted.map((s) => s.name).join('+')}';
  }

  static String? _whyClause(String signalId, String lang) =>
      _whyClauses[signalId]?.call(lang);

  static final Map<String, String Function(String lang)> _whyClauses = {
    FusionSignalIds.exploration: (l) => t(
          l,
          'คุณอาจมักมองหลายทางเลือกก่อนตัดสินใจ',
          'you may often scan options before deciding',
        ),
    FusionSignalIds.openness: (l) => t(
          l,
          'คุณอาจยืดหยุ่นกับสิ่งที่ไม่คุ้นเคยได้ดี',
          'flexes well toward the unfamiliar',
        ),
    FusionSignalIds.curiosity: (l) => t(
          l,
          'คุณอาอาอาอาอาจอยากลองสิ่งใหม่เมื่อความอยากรู้ขึ้น',
          'you may want to try something new when curiosity rises',
        ),
    FusionSignalIds.structure: (l) => t(
          l,
          'คุณอาจสบายใจขึ้นเมื่อมีแผนหรือกรอบก่อนลงมือ',
          'feels steadier with a plan or boundary first',
        ),
    FusionSignalIds.reflection: (l) => t(
          l,
          'คุณอาจมักทบทวนก่อนตอบสนอง',
          'often reflects before responding',
        ),
    FusionSignalIds.logicOrientation: (l) => t(
          l,
          'คุณอาจอยากเห็นเหตุผลก่อนตัดสินใจ',
          'wants a reason before deciding',
        ),
    FusionSignalIds.intuition: (l) => t(
          l,
          'คุณอาจมักมองภาพรวมและความหมายในสิ่งที่เกิดขึ้น',
          'often reads the bigger picture and meaning',
        ),
    FusionSignalIds.emotionalProcessing: (l) => t(
          l,
          'คุณอาจใส่ใจความรู้สึกเวลาเลือก',
          'weighs feelings when choosing',
        ),
    FusionSignalIds.emotionalSensitivity: (l) => t(
          l,
          'อารมณ์และบรรยากาศอาจมีอิทธิพลต่อมุมมองของคุณ',
          'mood and atmosphere shape your view',
        ),
    FusionSignalIds.socialExpression: (l) => t(
          l,
          'คุณอาจแสดงออกกับผู้คนได้ชัด',
          'shows up clearly with others',
        ),
  };

  static final Map<String, String Function(String lang)> _whyCombined = {
    '${FusionSignalIds.exploration}|astrology+mbti': (l) => t(
          l,
          'จากดวงของคุณและผล MBTI หลายครั้งคุณอาจเปิดรับทางเลือกใหม่ก่อนตัดสินใจจริงจัง',
          'From your chart and MBTI, you may often open to new options before you commit.',
        ),
    '${FusionSignalIds.exploration}|mbti+cognitive': (l) => t(
          l,
          'จากผล MBTI และ Cognitive ดูเหมือนว่าคุณอาจมองหลายทางเลือกก่อนเลือกทิศทาง',
          'From MBTI and Cognitive, you may scan several paths before you choose.',
        ),
    '${FusionSignalIds.structure}|astrology+mbti': (l) => t(
          l,
          'จากดวงของคุณและผล MBTI คุณอาจอยากมีความชัดเจนก่อนผูกมัดกับทางใดทางหนึ่ง',
          'From your chart and MBTI, you may want clarity before you commit to one path.',
        ),
    '${FusionSignalIds.reflection}|astrology+mbti': (l) => t(
          l,
          'จากดวงของคุณและผล MBTI หลายครั้งคุณอาจคิดทบทวนก่อนลงมือ',
          'From your chart and MBTI, you may often reflect before you act.',
        ),
    '${FusionSignalIds.logicOrientation}|mbti+cognitive': (l) => t(
          l,
          'จากผล MBTI และ Cognitive คุณอาจอยากเห็นเหตุผลก่อนตัดสินใจ',
          'From MBTI and Cognitive, you may want a clear reason before deciding.',
        ),
    '${FusionSignalIds.emotionalSensitivity}|astrology+mbti': (l) => t(
          l,
          'จากดวงของคุณและผล MBTI ความรู้สึกและบรรยากาศอาจมีอิทธิพลต่อมุมมองของคุณพอสมควร',
          'From your chart and MBTI, feelings and atmosphere may shape how you see things.',
        ),
    '${FusionSignalIds.socialExpression}|mbti+cognitive': (l) => t(
          l,
          'จากผล MBTI และ Cognitive หลายครั้งคุณอาจอ่านบรรยากาศทางสังคมและแสดงออกกับผู้คนได้ชัด',
          'From MBTI and Cognitive, you may read the room and show up clearly with others.',
        ),
  };
}
