import '../domain/entities/astrology_fusion_result.dart';
import '../domain/entities/fusion_signal.dart';
import '../presentation/fusion_presentation_copy.dart';
import 'fusion_meaning_signal_helpers.dart';

/// Why lenses agree on a central theme — V5.
class FusionLensNarrative {
  const FusionLensNarrative({
    required this.lensId,
    required this.lensTitle,
    required this.narrative,
  });

  final String lensId;
  final String lensTitle;
  final String narrative;
}

class FusionConsensusNarrative {
  const FusionConsensusNarrative({
    required this.sectionLabel,
    required this.lensNarratives,
    required this.themeConclusion,
  });

  final String sectionLabel;
  final List<FusionLensNarrative> lensNarratives;
  final String themeConclusion;
}

abstract final class FusionConsensusNarrativeBuilder {
  static const _lensOrder = [
    'western_natal',
    'chinese_bazi',
    'thai_astrology',
  ];

  static FusionConsensusNarrative? build(
    AstrologyFusionResult result, {
    required String centralThemeLabel,
  }) {
    if (result.lensOrigins.isEmpty && result.signals.isEmpty) return null;

    final profile = _resolveProfile(result);
    final narratives = _narrativesForProfile(profile);
    final available = result.lensOrigins.map((o) => o.lensId).toSet();

    final lensNarratives = <FusionLensNarrative>[];
    for (final lensId in _lensOrder) {
      if (available.isNotEmpty && !available.contains(lensId)) continue;
      final narrative = narratives[lensId];
      if (narrative == null) continue;
      lensNarratives.add(
        FusionLensNarrative(
          lensId: lensId,
          lensTitle: FusionPresentationCopy.lensTitle(lensId),
          narrative: narrative,
        ),
      );
    }

    if (lensNarratives.isEmpty) return null;

    return FusionConsensusNarrative(
      sectionLabel: 'ทำไมหลายศาสตร์เห็นตรงกัน',
      lensNarratives: lensNarratives,
      themeConclusion:
          'จึงเกิดเป็น Theme กลาง\n'
          '"$centralThemeLabel"',
    );
  }

  static String _resolveProfile(AstrologyFusionResult result) {
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.autonomy) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'independent') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'driven')) {
      return 'autonomy';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.expression) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'expressive')) {
      return 'expression';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.reflection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'analytical') ||
        FusionMeaningSignalHelpers.hasTheme(result, 'intuitive')) {
      return 'reflection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.connection) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'supportive')) {
      return 'connection';
    }
    if (FusionMeaningSignalHelpers.hasSignal(result, FusionSignalType.growth) ||
        FusionMeaningSignalHelpers.hasTheme(result, 'growth_focused')) {
      return 'growth';
    }
    return 'default';
  }

  static final Map<String, Map<String, String>> _profileNarratives = {
    'autonomy': {
      'western_natal':
          'มองเห็นแรงผลักให้คุณสร้างเส้นทางชีวิตด้วยตัวเอง',
      'chinese_bazi':
          'สะท้อนความสำคัญของการเลือกและความรับผิดชอบต่อทางเดินของตน',
      'thai_astrology':
          'เน้นบทเรียนเกี่ยวกับการตัดสินใจและการพึ่งพาตัวเอง',
    },
    'expression': {
      'western_natal':
          'มองเห็นพลังในการแสดงตัวตนและความตรงไปตรงมา',
      'chinese_bazi':
          'สะท้อนความสำคัญของการสื่อสารและการแสดงออกอย่างแท้จริง',
      'thai_astrology':
          'เน้นบทเรียนเรื่องการพูดความจริงและการเป็นตัวของตัวเอง',
    },
    'reflection': {
      'western_natal':
          'มองเห็นความลึกซึ้งที่เกิดจากการทบทวนและการมองภายใน',
      'chinese_bazi':
          'สะท้อนจังหวะของการคิดก่อนลงมือและการหาความชัดเจน',
      'thai_astrology':
          'เน้นบทเรียนเรื่องการหยุดพักและการฟังเสียงภายใน',
    },
    'connection': {
      'western_natal':
          'มองเห็นความสำคัญของความสัมพันธ์และการเชื่อมโยงกับผู้อื่น',
      'chinese_bazi':
          'สะท้อนบทบาทของความผูกพันและการดูแลซึ่งกันและกัน',
      'thai_astrology':
          'เน้นบทเรียนเรื่องความสมดุลระหว่างตัวเองกับคนรอบตัว',
    },
    'growth': {
      'western_natal':
          'มองเห็นแรงขับเคลื่อนให้เติบโตและเรียนรู้จากประสบการณ์',
      'chinese_bazi':
          'สะท้อนวัฏจักรของการพัฒนาและการก้าวข้ามขีดจำกัดเดิม',
      'thai_astrology':
          'เน้นบทเรียนเรื่องการเติบโตผ่านการลงมือทำจริง',
    },
    'default': {
      'western_natal':
          'มองเห็นแก่นแท้ของบุคลิกและทิศทางชีวิตของคุณ',
      'chinese_bazi':
          'สะท้อนโครงสร้างพลังและบทบาทที่คุณกำลังเดินอยู่',
      'thai_astrology':
          'เน้นบทเรียนชีวิตที่กำลังถ่ายทอดผ่านประสบการณ์ของคุณ',
    },
  };

  static Map<String, String> _narrativesForProfile(String profile) {
    return _profileNarratives[profile] ?? _profileNarratives['default']!;
  }
}
