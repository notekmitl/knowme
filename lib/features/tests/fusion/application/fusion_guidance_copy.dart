import '../domain/fusion_constants.dart';

/// Deterministic growth tips (suggestive, not prescriptive).
abstract final class FusionGuidanceCopy {
  static String t(String lang, String th, String en) => lang == 'th' ? th : en;

  static String sectionTitle(String lang) => t(
        lang,
        'สิ่งที่อาจช่วยคุณได้',
        'What might help',
      );

  static String explorationStructure(String lang) => t(
        lang,
        'ลองทดลองแบบเล็กๆ ก่อนผูกมัดเต็มที่ '
            'อาจช่วยให้ตัวเองมั่นใจขึ้นโดยไม่ต้องตัดสินใจครั้งใหญ่ทันที',
        'Trying something small before you fully commit '
            'may help you feel steadier without one big leap.',
      );

  static List<String> tipsForTheme(String themeId, String lang) =>
      switch (themeId) {
        FusionThemeIds.exploration => [
            t(
              lang,
              'ถ้ายังไม่แน่ใจ ลองทำแบบเล็กๆ ก่อน '
                  'เช่นลองสักระยะสั้น แล้วค่อยดูว่าอยากไปต่อไหม',
              'If you are not sure yet, a small try first—'
                  'a short stretch—may show whether you want to go on.',
            ),
          ],
        FusionThemeIds.thinkingStyle => [
            t(
              lang,
              'บางครั้งการคิดซ้ำอาจทำให้ยังไม่ไปไหน —'
                  'ลองสังเกตว่าตอนไหนคุณเริ่มวนซ้ำ '
                  'แล้วถามตัวเองว่าข้อมูลที่มีพอสำหรับการเลือกครั้งนี้หรือยัง',
              'Sometimes looping thoughts keep you in place—'
                  'notice when that starts and ask if you already have enough to choose.',
            ),
            t(
              lang,
              'ถ้าเรื่องไม่เร่งมาก อาจช่วยได้ถ้าตั้งเวลาสั้นๆ ให้ตัวเองตัดสินใจ —'
                  'พอถึงเวลาก็เลือกจากสิ่งที่เห็นชัดที่สุดตอนนั้น',
              'When it is not urgent, a short deadline for yourself '
                  'may help—you pick from what feels clearest then.',
            ),
          ],
        FusionThemeIds.emotion => [
            t(
              lang,
              'บางครั้งการให้เวลากับความรู้สึกสักพัก '
                  'อาจช่วยให้เห็นว่าอะไรสำคัญจริงๆ —ไม่ต้องรีบหาคำตอบทันที',
              'A little time with what you feel '
                  'may show what matters—you do not need an answer right away.',
            ),
            t(
              lang,
              'ถ้ามีคนที่ไว้ใจ การคุยออกมาอาจช่วยจัดเรื่องในหัวได้ง่ายขึ้น',
              'If someone feels safe to you, talking it through '
                  'may help you sort what is in your head.',
            ),
          ],
        FusionThemeIds.socialExpression => [
            t(
              lang,
              'บางครั้งคนใกล้ชิดอาจมองเห็นคุณจากมุมที่คุณมองไม่เห็น —'
                  'ลองขอฟังความเห็นจากคนที่คุณสบายใจได้',
              'People close to you sometimes see you from another angle—'
                  'you might ask someone you trust how it looks to them.',
            ),
          ],
        _ => const <String>[],
      };

  static String gentleFallback(String lang) => t(
        lang,
        'ลองสังเกตช่วงในชีวิตที่รู้สึกว่าตัวเองไปได้ดี '
            'แล้วดูว่ามีอะไรในตอนนั้นที่อาจเอามาใช้กับเรื่องตอนนี้ได้',
        'Notice a stretch when things felt workable for you—'
            'see if something from then might fit what you face now.',
      );
}
