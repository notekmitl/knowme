import 'package:knowme/features/human_pattern/domain/pattern_activation.dart';

import '../domain/narrative_mode.dart';
import '../intelligence/narrative_interaction_type.dart';
import '../intelligence/narrative_pattern_interaction_catalog.dart';

/// Deterministic Thai narrative copy keyed by pattern + mode.
abstract final class NarrativePatternCopy {
  static bool hasSpecificCopy(String patternId) {
    for (final modeCopy in _specificCopy.values) {
      if (modeCopy.containsKey(patternId)) return true;
    }
    return _blindSpotCopy.containsKey(patternId);
  }

  static String copyGroupForText(String text) {
    final normalized = text.trim().toLowerCase();
    for (final entry in _textToCopyGroup.entries) {
      if (normalized == entry.key) return entry.value;
    }
    if (normalized.startsWith('แบบ')) {
      return 'interaction_fallback';
    }
    if (normalized.startsWith('หลายมุมของ')) {
      return 'compressed_family';
    }
    for (final mode in NarrativeMode.values) {
      final prefix = _genericPrefix[mode];
      if (prefix != null && normalized.startsWith(prefix)) {
        return 'generic_${mode.key}';
      }
    }
    return 'unknown';
  }

  static String insight({
    required NarrativeMode mode,
    required NarrativeInteractionType interactionType,
    required String themeKey,
    required PatternActivation primary,
    required List<PatternActivation> contributing,
  }) {
    if (interactionType == NarrativeInteractionType.single) {
      return paragraph(
        mode: mode,
        patternId: primary.patternId,
        patternLabel: primary.label,
      );
    }

    if (interactionType == NarrativeInteractionType.blindSpot) {
      return _blindSpotCopy[primary.patternId] ??
          paragraph(
            mode: mode,
            patternId: primary.patternId,
            patternLabel: primary.label,
          );
    }

    if (interactionType == NarrativeInteractionType.compressed) {
      final familyId = themeKey.replaceFirst('family_', '');
      final familyCopy = _compressedFamilyCopy[familyId];
      if (familyCopy != null) return familyCopy;

      final familyLabel =
          NarrativeFamilyCompressionCatalog.familyLabels[familyId] ?? 'แนวโน้ม';
      final labels = [primary.label, ...contributing.map((item) => item.label)]
          .take(3)
          .join(', ');
      return 'หลายมุมของ$familyLabelในตัวคุณสอดคล้องกัน ($labels) — '
          'นี่คือภาพที่ชัดขึ้นเมื่อมองรวมแทนการแยกจุดเดียว';
    }

    if (contributing.isNotEmpty) {
      final pairKey = _pairKey(primary.patternId, contributing.first.patternId);
      final pairCopy = _pairInteractionCopy[interactionType]?[pairKey];
      if (pairCopy != null) return pairCopy;

      final themeCopy = _interactionCopy[interactionType]?[themeKey];
      if (themeCopy != null) return themeCopy;

      final primaryLabel = primary.label;
      final secondaryLabel = contributing.first.label;
      return switch (interactionType) {
        NarrativeInteractionType.agreement =>
          'แบบ$primaryLabel และ$secondaryLabel สอดคล้องกันในตัวคุณ — '
              'สิ่งที่คุณเป็นและวิธีที่คุณลงมือเสริมกันอย่างเป็นธรรมชาติ',
        NarrativeInteractionType.tension =>
          'แบบ$primaryLabel กับ$secondaryLabel ดึงไปคนละทิศในตัวคุณ — '
              'ความตึงนี้ไม่ใช่ข้อบกพร่อง แต่คือจุดที่ต้องถ่วงดุล',
        NarrativeInteractionType.growthEdge =>
          'แบบ$primaryLabel กับ$secondaryLabel บอกว่าคุณอยู่ระหว่างการลงมือกับการไตร่ตรอง — '
              'การเติบโตครั้งต่อไปคือการเลือกจังหวะที่ใช่',
        _ => paragraph(
            mode: mode,
            patternId: primary.patternId,
            patternLabel: primary.label,
          ),
      };
    }

    final interactionCopy = _interactionCopy[interactionType]?[themeKey];
    if (interactionCopy != null) return interactionCopy;

    return paragraph(
      mode: mode,
      patternId: primary.patternId,
      patternLabel: primary.label,
    );
  }

  static String paragraph({
    required NarrativeMode mode,
    required String patternId,
    required String patternLabel,
  }) {
    final specific = _specificCopy[mode]?[patternId];
    if (specific != null) return specific;

    return switch (mode) {
      NarrativeMode.identity =>
        'คุณมีลักษณะเด่นในแบบ$patternLabel — ตัวตนของคุณถูกกำหนดจากการเลือกและทิศทางที่คุณยึดถืออย่างสม่ำเสมอ',
      NarrativeMode.relationship =>
        'ในมิติความสัมพันธ์ คุณมักแสดงแบบ$patternLabel — วิธีที่คุณเชื่อมต่อกับคนรอบข้างมีเอกลักษณ์ของตัวเอง',
      NarrativeMode.decision =>
        'เวลาต้องตัดสินใจ คุณมักใช้แนว$patternLabel — นี่คือวิธีที่คุณลงมือและเลือกทิศทางในชีวิตจริง',
      NarrativeMode.growth =>
        'เส้นทางเติบโตของคุณสะท้อนแบบ$patternLabel — คุณพัฒนาตัวเองผ่านการเรียนรู้และปรับตัวอย่างต่อเนื่อง',
    };
  }

  static String _pairKey(String primaryId, String secondaryId) =>
      '$primaryId+$secondaryId';

  static const _genericPrefix = {
    NarrativeMode.identity: 'คุณมีลักษณะเด่นในแบบ',
    NarrativeMode.relationship: 'ในมิติความสัมพันธ์ คุณมักแสดงแบบ',
    NarrativeMode.decision: 'เวลาต้องตัดสินใจ คุณมักใช้แนว',
    NarrativeMode.growth: 'เส้นทางเติบโตของคุณสะท้อนแบบ',
  };

  static const _blindSpotCopy = {
    'relational_hidden_potential':
        'คุณมีศักยภาพในความสัมพันธ์ที่ยังไม่ได้แสดงเต็มที่ — การเปิดใจจะช่วยให้คุณเชื่อมต่อลึกขึ้น',
    'ignored_emotional_dimension':
        'คุณมักให้น้ำหนักกับมิติอื่นมากกว่าอารมณ์ภายใน — การรับรู้ความรู้สึกของตัวเองจะทำให้การตัดสินใจและความสัมพันธ์ลึกขึ้น',
    'asymmetric_identity_development':
        'ตัวตนของคุณพัฒนาไม่สมดุลระหว่างด้านที่คนเห็นกับด้านที่คุณรู้สึกภายใน — การเชื่อมสองด้านนี้จะทำให้คุณเป็นตัวเองได้ครบขึ้น',
  };

  static const _compressedFamilyCopy = {
    'identity_style':
        'หลายมุมของตัวตนในตัวคุณชี้ไปทางเดียวกัน — คุณไม่ได้มีแค่หน้าเดียว แต่ทุกหน้าสะท้อนว่าคุณเลือกเป็นเจ้าของชีวิตตัวเอง',
    'meaning_style':
        'ความหมายในชีวิตของคุณไม่ได้มาจากจุดเดียว — หลายแหล่งสัญญาณบอกว่าคุณยึดทิศทางและความเชื่อเป็นหลักในการนำทางตัวเอง',
    'thinking_style':
        'วิธีคิดของคุณมีหลายชั้นแต่ทำงานร่วมกัน — คุณวิเคราะห์ สร้าง และสำรวจไปพร้อมกัน ไม่ใช่แค่คิดอย่างเดียวหรือทำอย่างเดียว',
    'emotional_style':
        'อารมณ์ของคุณมีทั้งความลึกและความสงบ — คุณรับรู้ความรู้สึกได้ชัด แต่ก็รู้วิธีควบคุมจังหวะเมื่อสถานการณ์ต้องการ',
    'relationship_style':
        'ความสัมพันธ์ของคุณมีหลายจุดแข็งที่เสริมกัน — คุณทั้งมั่นคง สนับสนุน และประนีประนอมได้ตามบริบท',
    'decision_style':
        'การตัดสินใจของคุณผสมทั้งอิสระ เป็นระบบ และรวดเร็ว — คุณไม่ติดอยู่กับสไตล์เดียว แต่เลือกใช้ตามสถานการณ์',
    'growth_style':
        'การเติบโตของคุณเกิดจากหลายเส้นทางพร้อมกัน — คุณสร้างต่อเนื่อง ปรับตัว และเปิดรับการเปลี่ยนแปลงในเวลาเดียวกัน',
    'growth_edge_pattern':
        'คุณอยู่ในจุดที่พร้อมก้าวข้ามขีดจำกัด — ทั้งความแข็งแกร่งที่สะสมและความตึงที่รู้สึกชี้ไปทางการเติบโตครั้งใหญ่',
    'motivation_style':
        'แรงจูงใจของคุณมีหลายแหล่งที่สอดคล้องกัน — ทั้งเป้าหมาย ทรัพยากร และพลังสร้างสรรค์ผลักให้คุณเคลื่อนไหวไปข้างหน้า',
    'theme_coverage_pattern':
        'หลายธีมในตัวคุณทำงานร่วมกัน — คุณทั้งสร้าง รับผิดชอบ และนำทางผู้อื่นได้ในเวลาเดียวกัน',
  };

  static const _specificCopy = {
    NarrativeMode.identity: {
      'self_directed_identity':
          'คุณเป็นคนที่มักเลือกสร้างเส้นทางของตัวเองมากกว่าการเดินตามสิ่งที่คนอื่นกำหนด',
      'expressive_identity':
          'คุณแสดงตัวตนผ่านการสื่อสารและการปรากฏตัวอย่างชัดเจน — สิ่งที่คุณเป็นมักเห็นได้จากภายนอก',
      'visible_identity':
          'คุณใส่ใจกับภาพลักษณ์และการปรากฏตัวต่อสาธารณะ — ตัวตนของคุณเติบโตเมื่อได้รับการมองเห็น',
      'meaning_seeker':
          'คุณมองหาความหมายเบื้องหลังชีวิต — ตัวตนของคุณเชื่อมโยงกับสิ่งที่คุณเชื่อและให้คุณค่า',
      'belief_meaning':
          'ความเชื่อของคุณเป็นโครงสร้างที่ยึดตัวตน — คุณไม่ได้แค่มีความคิด แต่สร้างความหมายจากสิ่งที่ยึดมั่น',
      'directional_meaning':
          'คุณมีเข็มทิศภายในที่ชัด — ตัวตนของคุณถูกนำทางโดยทิศทางชีวิตที่คุณเลือกเอง',
      'purpose_guide':
          'คุณมักกลายเป็นผู้ชี้ทางให้คนอื่น — ตัวตนของคุณเชื่อมกับบทบาทผู้นำทางด้วยความหมาย',
      'stable_orientation':
          'ทิศทางชีวิตของคุณมั่นคงแม้สถานการณ์เปลี่ยน — ตัวตนของคุณยึดหลักที่ได้รับการยืนยันจากหลายแหล่ง',
      'identity_dual_signal':
          'ตัวตนของคุณมีสองสัญญาณที่ดึงไปคนละทาง — คุณไม่ได้ขัดแย้งกับตัวเอง แต่กำลังเรียนรู้ว่าจะรวมทั้งสองด้านอย่างไร',
    },
    NarrativeMode.relationship: {
      'relationship_stabilizer':
          'คุณมักเป็นที่พึ่งที่มั่นคงในความสัมพันธ์ — คนรอบข้างรู้สึกได้ถึงความมั่นคงจากคุณ',
      'supportive_connector':
          'คุณเชื่อมต่อกับคนอื่นผ่านการสนับสนุนและการอยู่เคียงข้าง — ความสัมพันธ์คือพื้นที่ที่คุณให้พลัง',
      'diplomatic_binder':
          'คุณถนัดในการประนีประนอมและสร้างสมดุลระหว่างคน — คุณช่วยให้ความสัมพันธ์ไม่แตกหักง่าย',
      'relational_hidden_potential':
          'คุณมีศักยภาพในความสัมพันธ์ที่ยังไม่ได้แสดงเต็มที่ — การเปิดใจจะช่วยให้คุณเชื่อมต่อลึกขึ้น',
      'emotional_depth':
          'คุณรับรู้อารมณ์ได้ลึก — ความสัมพันธ์ของคุณมักมีมิติที่คนอื่นอาจมองไม่เห็น',
      'responsive_feeler':
          'คุณไวต่ออารมณ์ของคนรอบข้าง — คุณปรับการเชื่อมต่อตามสัญญาณที่รับรู้ได้ทันที',
      'calm_regulator':
          'คุณช่วยให้บรรยากาศในความสัมพันธ์สงบลง — คุณเป็นจุดสมดุลเมื่อความรู้สึกรุนแรง',
      'ignored_emotional_dimension':
          'คุณมักให้น้ำหนักกับมิติอื่นมากกว่าอารมณ์ภายใน — การรับรู้ความรู้สึกของตัวเองจะทำให้การตัดสินใจและความสัมพันธ์ลึกขึ้น',
      'asymmetric_identity_development':
          'ตัวตนของคุณพัฒนาไม่สมดุลระหว่างด้านที่คนเห็นกับด้านที่คุณรู้สึกภายใน — การเชื่อมสองด้านนี้จะทำให้คุณเป็นตัวเองได้ครบขึ้น',
    },
    NarrativeMode.decision: {
      'independent_decision_maker':
          'คุณตัดสินใจด้วยตัวเองและไม่พึ่งพาความเห็นของคนอื่นเป็นหลัก — นี่คือจุดแข็งในการเลือกทิศทาง',
      'structured_operator':
          'คุณตัดสินใจอย่างเป็นระบบและมีโครงสร้าง — คุณชอบวางแผนก่อนลงมือ',
      'decisive_actor':
          'คุณลงมือเร็วเมื่อเห็นทางชัด — การตัดสินใจของคุณมักนำไปสู่การกระทำจริง',
      'accountable_operator':
          'คุณรับผิดชอบผลลัพธ์จากการตัดสินใจของตัวเอง — ความน่าเชื่อถือมาจากการทำตามคำพูด',
      'constructive_builder':
          'คุณตัดสินใจผ่านการสร้าง — ทุกการเลือกของคุณมุ่งไปสู่สิ่งที่สร้างได้จริง',
      'structured_explorer':
          'คุณตัดสินใจโดยสำรวจภายในกรอบ — คุณไม่กระโดดมื้อเปล่า แต่ทดลองอย่างมีโครงสร้าง',
      'reflective_builder':
          'คุณไตร่ตรองก่อนลงมือ แล้วสร้างจากสิ่งที่เข้าใจ — การตัดสินใจของคุณผสมความลึกกับการกระทำ',
      'analytical_thinker':
          'คุณวิเคราะห์อย่างละเอียดก่อนตัดสินใจ — ข้อมูลและเหตุผลคือเครื่องมือหลักของคุณ',
      'belief_architect':
          'คุณจัดระบบความเชื่อก่อนเลือกทาง — การตัดสินใจของคุณยึดโครงสร้างความคิดที่สร้างไว้',
      'structured_builder_thinker':
          'คุณคิดเป็นระบบและสร้างจากแผน — การตัดสินใจของคุณเชื่อมโครงสร้างกับผลลัพธ์จริง',
      'dual_nature_actor':
          'การตัดสินใจของคุณมีสองแรงดึง — คุณอาจลงมือเร็วในครั้งหนึ่งและชะลอในครั้งถัดไป ขึ้นกับบริบท',
      'internal_conflict_thinker':
          'ความคิดของคุณมักถกเถียงกันเองก่อนตัดสินใจ — ความขัดแย้งภายในนี้ช่วยให้คุณเห็นหลายมุม',
    },
    NarrativeMode.growth: {
      'progressive_builder':
          'คุณเติบโตผ่านการสร้างสิ่งใหม่อย่างต่อเนื่อง — ทุกก้าวคือการพัฒนาที่สะสม',
      'transformation_seeker':
          'คุณเปิดรับการเปลี่ยนแปลงและมองหาโอกาสในการพัฒนาตัวเอง — การเติบโตคือเป้าหมายของคุณ',
      'adaptive_growth':
          'คุณปรับตัวได้ดีเมื่อสถานการณ์เปลี่ยน — ความยืดหยุ่นช่วยให้คุณเติบโตในทุกบริบท',
      'growth_edge_builder':
          'คุณอยู่ในจุดที่พร้อมก้าวข้ามขีดจำกัดเดิม — การเติบโตครั้งต่อไปอยู่ไม่ไกลจากตัวคุณ',
      'growth_edge_from_tension':
          'ความตึงเครียดภายในช่วยผลักให้คุณเติบโต — คุณเรียนรู้จากความขัดแย้งและกลายเป็นคนที่แข็งแกร่งขึ้น',
      'purpose_driven_motivation':
          'แรงจูงใจของคุณมาจากเป้าหมายชีวิต — คุณเติบโตเมื่อรู้ว่ากำลังไปทางไหนและทำไม',
      'resource_oriented_motivation':
          'คุณเติบโตโดยใช้ทรัพยากรที่มีอย่างชาญฉลาด — ความมั่นคงเป็นฐานที่ให้คุณกล้าพัฒนาต่อ',
      'adaptive_creator':
          'คุณสร้างสิ่งใหม่และปรับตัวไปพร้อมกัน — การเติบโตของคุณเกิดจากการทดลองและสร้างจริง',
      'reinforced_strength':
          'จุดแข็งของคุณได้รับการยืนยันจากหลายแหล่ง — พลังที่สะสมนี้เป็นฐานสำหรับการเติบโตต่อไป',
      'guiding_teacher':
          'คุณเติบโตผ่านการสอนและนำทางผู้อื่น — การแบ่งปันความรู้ช่วยให้คุณพัฒนาตัวเองไปพร้อมกัน',
      'stable_accountability':
          'คุณเติบโตด้วยความรับผิดชอบที่มั่นคง — คุณไม่แค่ตั้งเป้า แต่ยึดมั่นกับสิ่งที่สัญญาไว้',
    },
  };

  static const _interactionCopy = {
    NarrativeInteractionType.agreement: {
      'consistency_theme':
          'คุณลงมืออย่างเป็นระบบและรับผิดชอบผลลัพธ์ — ความสม่ำเสมอระหว่างการวางแผนกับการทำตามสิ่งที่ตั้งใจคือจุดแข็งที่คนรอบข้างไว้วางใจ',
      'relational_stability':
          'คุณให้ทั้งความมั่นคงและการสนับสนุนในความสัมพันธ์ — คนใกล้ตัวรู้สึกได้ว่าคุณอยู่เคียงข้างและยึดโครงสร้างร่วมกัน',
      'autonomy_theme':
          'คุณยึดตัวตนและการตัดสินใจของตัวเองอย่างชัดเจน — ทิศทางชีวิตมาจากการเลือกที่คุณเป็นเจ้าของจริง',
      'building_theme':
          'คุณเติบโตผ่านการสร้างอย่างต่อเนื่อง — ทั้งการลงมือและการพัฒนาใหม่เสริมกันเป็นเส้นทางเดียวกัน',
    },
    NarrativeInteractionType.tension: {
      'autonomy_vs_harmony':
          'คุณให้ความสำคัญกับอิสระ ในขณะที่ความสัมพันธ์ต้องการความกลมกลืน — จุดถ่วงดุลนี้คือพื้นที่ที่คุณเรียนรู้การเลือกอย่างมีสติ',
      'analysis_vs_action':
          'คุณคิดลึกก่อนลงมือ แต่เมื่อเห็นทางชัดก็พร้อมเคลื่อนไหวเร็ว — ความตึงระหว่างการวิเคราะห์กับการกระทำคือจุดแข็งที่ต้องจัดสรรพลังงาน',
      'speed_vs_balance':
          'คุณมักลงมือเร็ว แต่ก็ใส่ใจสมดุลของคนรอบข้าง — การเรียนรู้คือรู้ว่าเมื่อไหร่ควรเร่งและเมื่อไหร่ควรชะลอ',
    },
    NarrativeInteractionType.growthEdge: {
      'action_vs_reflection':
          'คุณอยู่ระหว่างการไตร่ตรองกับการลงมือ — การเติบโตครั้งต่อไปคือการเลือกจังหวะที่ทำให้ทั้งสองด้านทำงานร่วมกัน',
      'growth_through_structure':
          'ความตึงที่คุณรู้สึกช่วยให้เติบโตผ่านโครงสร้าง — คุณพัฒนาได้ดีเมื่อมีกรอบที่ชัดและพื้นที่ทดลอง',
    },
  };

  static const _pairInteractionCopy = {
    NarrativeInteractionType.agreement: {
      'structured_operator+accountable_operator':
          'คุณวางแผนเป็นระบบและทำตามที่สัญญา — คนรอบข้างไว้วางใจเพราะคุณไม่แค่คิด แต่ทำจริงและรับผิดชอบผล',
      'accountable_operator+structured_operator':
          'คุณรับผิดชอบผลลัพธ์และมีโครงสร้างรองรับ — ความน่าเชื่อถือของคุณมาจากทั้งวินัยและความเป็นระบบ',
      'supportive_connector+relationship_stabilizer':
          'คุณทั้งสนับสนุนและมั่นคงในความสัมพันธ์ — คนใกล้ตัวรู้สึกได้ว่าคุณอยู่เคียงข้างและไม่หายไปเมื่อสถานการณ์ยาก',
      'relationship_stabilizer+supportive_connector':
          'คุณเป็นหลักให้ความสัมพันธ์และให้พลังใจ — คุณไม่แค่ยึดโครงสร้าง แต่ยังดูแลความรู้สึกของคนรอบข้าง',
      'self_directed_identity+independent_decision_maker':
          'คุณเป็นเจ้าของทั้งตัวตนและการตัดสินใจ — ไม่มีใครกำหนดทิศทางให้คุณ และคุณเลือกเองอย่างมั่นใจ',
      'independent_decision_maker+self_directed_identity':
          'คุณตัดสินใจด้วยตัวเองและยึดเส้นทางที่เลือก — อิสระของคุณไม่ใช่การหลบ แต่เป็นการเป็นเจ้าของชีวิต',
      'constructive_builder+progressive_builder':
          'คุณสร้างทีละน้อยและสร้างต่อเนื่อง — ทุกชิ้นงานสะสมเป็นหลักฐานของการเติบโตที่แท้จริง',
      'progressive_builder+constructive_builder':
          'คุณเติบโตผ่านการสร้างที่ไม่หยุด — แต่ละขั้นเชื่อมกับขั้นถัดไปเป็นเส้นทางเดียว',
    },
    NarrativeInteractionType.tension: {
      'independent_decision_maker+relationship_stabilizer':
          'คุณต้องการอิสระในการตัดสินใจ แต่ก็อยากให้ความสัมพันธ์มั่นคง — จุดถ่วงดุลคือการเลือกอย่างมีสติโดยไม่ทิ้งคนสำคัญ',
      'relationship_stabilizer+independent_decision_maker':
          'คุณมั่นคงในความสัมพันธ์ แต่ก็ต้องการพื้นที่ตัดสินใจเอง — ความท้าทายคือการรักษาทั้งสองอย่างพร้อมกัน',
      'analytical_thinker+decisive_actor':
          'คุณคิดลึกก่อนลงมือ แต่เมื่อเห็นทางชัดก็พร้อมเคลื่อนไหวเร็ว — พลังงานของคุณต้องจัดสรรระหว่างการวิเคราะห์กับการกระทำ',
      'decisive_actor+analytical_thinker':
          'คุณลงมือเร็วเมื่อมั่นใจ แต่ก็รู้ว่าบางครั้งต้องหยุดคิด — ความตึงนี้ทำให้คุณไม่ลงมือมั่ว แต่ก็ไม่คิดจนพลาดจังหวะ',
    },
    NarrativeInteractionType.growthEdge: {
      'growth_edge_builder+analytical_thinker':
          'คุณอยู่ขอบเขตการเติบโตและยังคิดวิเคราะห์อยู่ — ก้าวต่อไปคือการเลือกว่าจะลงมือหรือไตร่ตรองต่อ',
      'analytical_thinker+growth_edge_builder':
          'คุณวิเคราะห์จนถึงจุดที่พร้อมก้าวข้าม — การเติบโตครั้งต่อไปต้องการทั้งความเข้าใจและความกล้า',
      'growth_edge_from_tension+structured_operator':
          'ความตึงผลักให้คุณเติบโต และโครงสร้างช่วยให้ไม่หลงทาง — คุณพัฒนาได้ดีเมื่อมีกรอบที่ชัดและพื้นที่ทดลอง',
      'structured_operator+growth_edge_from_tension':
          'คุณมีระบบรองรับและความตึงที่ผลักให้ก้าวต่อ — การเติบโตของคุณเกิดจากทั้งวินัยและแรงกดดันที่ยอมรับได้',
    },
  };

  static final Map<String, String> _textToCopyGroup = _buildTextToCopyGroup();

  static Map<String, String> _buildTextToCopyGroup() {
    final map = <String, String>{};

    void register(String text, String group) {
      map[text.trim().toLowerCase()] = group;
    }

    for (final entry in _blindSpotCopy.entries) {
      register(entry.value, 'blind_spot_${entry.key}');
    }
    for (final entry in _compressedFamilyCopy.entries) {
      register(entry.value, 'compressed_${entry.key}');
    }
    for (final modeEntry in _specificCopy.entries) {
      for (final patternEntry in modeEntry.value.entries) {
        register(patternEntry.value, 'specific_${patternEntry.key}');
      }
    }
    for (final typeEntry in _interactionCopy.entries) {
      for (final themeEntry in typeEntry.value.entries) {
        register(themeEntry.value, 'theme_${typeEntry.key.key}_${themeEntry.key}');
      }
    }
    for (final typeEntry in _pairInteractionCopy.entries) {
      for (final pairEntry in typeEntry.value.entries) {
        register(pairEntry.value, 'pair_${typeEntry.key.key}_${pairEntry.key}');
      }
    }

    return map;
  }
}
