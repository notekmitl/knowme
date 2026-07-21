import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../presentation/fusion_presentation_copy.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Recurring life patterns from fusion themes/signals — V5.
class FusionLifePattern {
  const FusionLifePattern({
    required this.intro,
    required this.patternInsight,
    required this.recurringQuestions,
    required this.closing,
  });

  final String intro;
  final String patternInsight;
  final List<String> recurringQuestions;
  final String closing;

  String get formattedBody {
    final questions = recurringQuestions.map((q) => '• $q').join('\n');
    return '$intro\n\n'
        '$patternInsight\n\n'
        'คุณอาจพบว่า\n'
        'คำถามเดิมมักกลับมาในรูปแบบใหม่\n'
        'เช่น\n\n'
        '$questions\n\n'
        '$closing';
  }
}

abstract final class FusionLifePatternBuilder {
  static FusionLifePattern? build(AstrologyFusionResult result) {
    if (result.signals.isEmpty && result.topThemes.isEmpty) return null;

    final profile = _resolveProfile(result);
    return _patterns[profile]?.call(result) ?? _defaultPattern(result);
  }

  static String _resolveProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'independent') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'driven')) {
      return 'autonomy';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'expressive') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'openness')) {
      return 'expression';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'intuitive')) {
      return 'reflection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'supportive') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'loyal')) {
      return 'connection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.growth) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'growth_focused')) {
      return 'growth';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.structure) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'structured')) {
      return 'structure';
    }

    final themeId = FusionMeaningSignalHelpers.primaryThemeId(result);
    if (themeId != null) return 'theme:$themeId';

    final signal = FusionMeaningSignalHelpers.primarySignalType(result);
    return signal?.name ?? 'default';
  }

  static final Map<String, FusionLifePattern Function(AstrologyFusionResult)>
      _patterns = {
    'autonomy': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'ช่วงเวลาสำคัญในชีวิตของคุณ\n'
              'มักเกิดขึ้นเมื่อคุณต้องเลือกด้วยตัวเอง\n'
              'มากกว่าตอนที่มีคนกำหนดทางให้',
          recurringQuestions: [
            'จะเชื่อเสียงตัวเองหรือไม่',
            'จะกล้ารับผิดชอบทางเลือกหรือไม่',
            'จะเดินตามความคาดหวังหรือไม่',
          ],
          closing:
              'สิ่งที่เปลี่ยนไปมีเพียงสถานการณ์\n'
              'แต่แก่นของคำถามยังคล้ายเดิม',
        ),
    'expression': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'ช่วงเปลี่ยนแปลงในชีวิตของคุณ\n'
              'มักมาพร้อมคำถามว่าจะพูดความจริงแค่ไหน\n'
              'และจะรักษาความสัมพันธ์อย่างไร',
          recurringQuestions: [
            'จะแสดงตัวตนอย่างตรงไปตรงมาหรือไม่',
            'จะเก็บความคิดไว้เพื่อความสงบหรือไม่',
            'จะยอมเป็นคนที่คนอื่นคาดหวังหรือไม่',
          ],
          closing:
              'บทบาทและคนรอบตัวเปลี่ยนไป\n'
              'แต่คำถามเรื่องความจริงของตัวเองยังวนกลับมา',
        ),
    'reflection': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'จุดหักมุมในชีวิตของคุณ\n'
              'มักเกิดหลังช่วงที่คุณหยุดทบทวน\n'
              'มากกว่าช่วงที่รีบตัดสินใจ',
          recurringQuestions: [
            'จะให้เวลาตัวเองมากพอหรือไม่',
            'จะรีบตอบสนองความคาดหวังหรือไม่',
            'จะฟังเสียงภายในหรือเสียงภายนอกก่อน',
          ],
          closing:
              'เหตุการณ์ต่างกันในแต่ละครั้ง\n'
              'แต่จังหวะของการหยุดมองย้อนกลับยังคล้ายเดิม',
        ),
    'connection': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'ช่วงที่คุณรู้สึกมีความหมายมากที่สุด\n'
              'มักเกี่ยวข้องกับการหาจุดสมดุล\n'
              'ระหว่างตัวเองกับคนรอบตัว',
          recurringQuestions: [
            'จะให้พื้นที่ตัวเองมากแค่ไหน',
            'จะใส่ใจความรู้สึกของคนอื่นแค่ไหน',
            'จะเลือกความสัมพันธ์หรือทิศทางของตัวเอง',
          ],
          closing:
              'คนและบริบทเปลี่ยนไป\n'
              'แต่คำถามเรื่องความผูกพันกับตัวตนยังวนกลับมา',
        ),
    'growth': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'ช่วงที่คุณเติบโตมากที่สุด\n'
              'มักเริ่มจากการลงมือทำสิ่งที่ยังไม่มั่นใจ\n'
              'มากกว่าการรอให้พร้อมสมบูรณ์',
          recurringQuestions: [
            'จะกล้าเริ่มต้นใหม่หรือไม่',
            'จะยอมผิดพลาดเพื่อเรียนรู้หรือไม่',
            'จะเลือกความสบายหรือการเติบโต',
          ],
          closing:
              'เวทีชีวิตเปลี่ยนไป\n'
              'แต่บทเรียนเรื่องการก้าวออกจากโซนที่คุ้นเคยยังคล้ายเดิม',
        ),
    'structure': (_) => const FusionLifePattern(
          intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
          patternInsight:
              'ช่วงที่คุณมั่นคงที่สุด\n'
              'มักเกิดเมื่อมีโครงสร้างชัดเจน\n'
              'แต่ยังเหลือพื้นที่ให้ตัวเองหายใจ',
          recurringQuestions: [
            'จะยึดกรอบเดิมหรือปรับให้ยืดหยุ่น',
            'จะรับผิดชอบมากเกินไปหรือไม่',
            'จะปล่อยให้สิ่งบางอย่างไหลตามธรรมชาติหรือไม่',
          ],
          closing:
              'สถานการณ์ต่างกัน\n'
              'แต่คำถามเรื่องความมั่นคงกับความยืดหยุ่นยังวนกลับมา',
        ),
  };

  static FusionLifePattern _defaultPattern(AstrologyFusionResult result) {
    final themeId = FusionMeaningSignalHelpers.primaryThemeId(result);
    final themePhrase = themeId != null
        ? FusionPresentationCopy.themePhrase(themeId)
        : 'แก่นแท้ของตัวตน';

    return FusionLifePattern(
      intro: 'หลายศาสตร์สะท้อนตรงกันว่า',
      patternInsight:
          'ช่วงสำคัญในชีวิตของคุณ\n'
          'มักเกี่ยวข้องกับ$themePhrase\n'
          'ในรูปแบบที่เปลี่ยนไปตามบริบท',
      recurringQuestions: const [
        'จะยึดตามสิ่งที่คุ้นเคยหรือไม่',
        'จะเปิดรับมุมมองใหม่หรือไม่',
        'จะเลือกเส้นทางที่สอดคล้องกับตัวเองหรือไม่',
      ],
      closing:
          'รายละเอียดของชีวิตเปลี่ยนไป\n'
          'แต่แก่นของคำถามยังคล้ายเดิม',
    );
  }
}
