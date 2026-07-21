import '../domain/fusion_constants.dart';

/// Deterministic reflective prompts (not quiz, no answers required).
abstract final class FusionReflectionCopy {
  static String t(String lang, String th, String en) => lang == 'th' ? th : en;

  static String sectionTitle(String lang) => t(
        lang,
        'ลองถามตัวเองดู',
        'Pause and ask yourself',
      );

  static String explorationStructure(String lang) => t(
        lang,
        'โดยเฉพาะเวลามีทางใหม่ที่ยังไม่คุ้น '
            'คุณเคยรู้สึกไหมว่า อยากลองก่อน แต่ภายในก็อยากให้ตัวเองมั่นใจก่อนผูกมัดจริงๆ',
        'When a new path still feels unfamiliar, '
            'have you felt you want to try first—'
            'and also want to feel sure before you really commit?',
      );

  static String? forTheme(String themeId, String lang) => switch (themeId) {
        FusionThemeIds.exploration => t(
            lang,
            'เวลาเจออะไรที่ยังไม่คุ้น '
                'คุณเคยรู้สึกไหมว่า บางครั้งเหมือนอยากแค่เข้าไปดูก่อน '
                'แล้วค่อยดูว่ามันใช่กับชีวิตคุณไหม',
            'When something still feels new to you, '
                'have you felt you want to look first—'
                'then see if it really fits your life?',
          ),
        FusionThemeIds.thinkingStyle => t(
            lang,
            'เวลาต้องเลือกเรื่องสำคัญ '
                'คุณเคยรู้สึกไหมว่า บางครั้งเหมือนอยากคิดให้พอ '
                'หรือหาเหตุผลให้ตัวเองมั่นใจก่อนค่อยไปต่อ',
            'When an important choice is on the line, '
                'have you felt you need to think it through—'
                'or find a reason that lets you move forward?',
          ),
        FusionThemeIds.emotion => t(
            lang,
            'เวลาเรื่องบางอย่างกระทบใจ '
                'คุณเคยปล่อยให้ตัวเองอยู่กับความรู้สึกนั้นสักพัก '
                'ก่อนค่อยหาคำตอบให้ตัวเองไหม',
            'When something really lands on you, '
                'have you given yourself a little time with that feeling '
                'before you look for your answer?',
          ),
        FusionThemeIds.socialExpression => t(
            lang,
            'เวลาอยู่กับคนบางกลุ่ม '
                'คุณเคยรู้สึกไหมว่า ตัวเองค่อยๆ เปิดออกมาเองมากกว่าที่ตั้งใจ',
            'With some people, '
                'have you felt you open up more on your own than you planned?',
          ),
        _ => null,
      };

  static String gentleFallback(String lang) => t(
        lang,
        'ลองนึกครั้งล่าสุดที่รู้สึกว่า “นี่แหละ เหมือนตัวเอง” —'
            'คุณเคยมีช่วงแบบนั้นไหม',
        'Think of the last time something felt unmistakably like you—'
            'does a moment like that come to mind?',
      );
}
