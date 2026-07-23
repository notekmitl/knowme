/// Curated Thai narrative block library for V1.1.
library;

import 'thai_beta_curated_narrative_block.dart';
import 'thai_beta_narrative_domain.dart';

abstract final class ThaiBetaCuratedNarrativeBlocks {
  static final all = <CuratedNarrativeBlock>[
    ..._heroBlocks,
    ..._strengthBlocks,
    ..._domainBlocks,
    ..._dashboardBlocks,
    ..._adviceBlocks,
    ..._fallbackBlocks,
  ];

  // --- Hero blocks (3–5 sentences, distinct facet pairs) --------------------

  static const _heroBlocks = <CuratedNarrativeBlock>[
    CuratedNarrativeBlock(
      id: 'hero_structure_thinking_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['structure'],
      secondarySemanticTags: ['thinking'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณเป็นคนรับผิดชอบและพึ่งพาได้',
        'แต่เบื้องหลังความนิ่งนั้น คุณมักคิดหลายรอบ เพราะไม่อยากให้การตัดสินใจของตัวเองสร้างภาระให้ใคร',
        'ถึงอย่างนั้น เมื่อไม่มีใครกล้าตัดสินใจ คุณกลับเป็นคนที่ก้าวออกมารับหน้าที่ก่อนเสมอ',
        'ในที่ประชุม คุณมักเป็นคนที่ขอข้อมูลอีกนิดก่อนออกความเห็น ทั้งที่ในใจเริ่มมีคำตอบแล้ว',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['structure', 'thinking'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_thinking_action_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['thinking'],
      secondarySemanticTags: ['action'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนรอบตัวมักมองว่าคุณเป็นคนคิดอย่างรอบคอบก่อนพูดหรือตัดสินใจ และไม่รีบสรุป',
        'เบื้องหลังนั้น คุณอยากมั่นใจว่าคิดมาดีพอแล้วค่อยตัดสินใจ',
        'แต่พอเห็นว่าทิศทางชัดและมีคนรออยู่ คุณก็ลงมือได้เร็วกว่าที่หลายคนคาด',
        'เวลาต้องเลือก คุณมักลิสต์ข้อดีข้อเสียในหัวอยู่เงียบ ๆ ก่อนเสมอ',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['thinking', 'action'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_drive_thinking_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['drive'],
      secondarySemanticTags: ['thinking'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณมุ่งมั่นและไม่ยอมแพ้ง่าย ๆ',
        'เบื้องหลังความเข้มแข็งนั้น คุณมักชั่งใจหลายรอบก่อนจะลงมือจริง',
        'เมื่อเป้าหมายชัดและมีผลกระทบต่อคนอื่น คุณจะยอมรอให้แผนพร้อมก่อนเริ่ม',
        'เวลามีคนถามความเห็นเรื่องสำคัญ คุณอาจตอบว่า "ขอคิดดูก่อนนะ" ทั้งที่ใจเริ่มมีคำตอบแล้ว',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['drive', 'thinking'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_people_independent_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['people'],
      secondarySemanticTags: ['independent'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนรอบตัวมักเห็นว่าคุณใส่ใจและพร้อมช่วยเมื่อใครต้องการ',
        'เบื้องหลังนั้น คุณยังต้องการพื้นที่ของตัวเองเพื่อคิดและฟื้นพลัง',
        'เมื่อสถานการณ์กดดันและต้องตัดสินใจคนเดียว คุณกลับทำได้ดีกว่าเมื่อได้เวลาคิดเงียบ ๆ',
        'เวลาคนใกล้ตัวมีปัญหา คุณมักไม่รอให้เขาขอ แต่ลงมือช่วยจัดการให้เลย',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['people', 'independent'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_action_caution_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['action'],
      secondarySemanticTags: ['caution'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณลงมือเร็วและไม่ชอบปล่อยให้เรื่องค้าง',
        'เบื้องหลังนั้น คุณยังมีจุดที่ระวังและไม่อยากเสี่ยงเกินจำเป็น',
        'เมื่อเรื่องมีผลระยะยาวหรือกระทบคนอื่น คุณจะชะลอลงและตรวจอีกรอบก่อนเริ่ม',
        'ในที่ประชุม พอได้ข้อสรุป คุณมักเป็นคนแรกที่ถามว่า "แล้วเราเริ่มกันเมื่อไหร่"',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['action', 'caution'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_novelty_structure_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['novelty'],
      secondarySemanticTags: ['structure'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนรอบตัวมักเห็นว่าคุณเปิดรับสิ่งใหม่และชอบลองวิธีที่แตกต่าง',
        'เบื้องหลังนั้น คุณยังต้องการโครงสร้างที่ชัดก่อนจะลงมือจริง',
        'เมื่อเห็นว่าทิศทางชัดและมีแผนรองรับ คุณจะลองได้เต็มที่โดยไม่ลังเล',
        'เวลาว่าง คุณมักหาอะไรใหม่ ๆ มาลอง แต่จะจดไว้ว่าอะไรใช้ได้จริง',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['novelty', 'structure'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_emotion_drive_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['emotion'],
      secondarySemanticTags: ['drive'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณอ่อนโยนและใส่ใจความรู้สึกของคนรอบตัว',
        'เบื้องหลังนั้น คุณยังมีแรงผลักดันที่อยากให้สิ่งที่สำคัญเดินหน้า',
        'เมื่อเรื่องกระทบคนที่คุณแคร์ คุณจะลุกขึ้นมาทำให้เสร็จแม้จะเหนื่อย',
        'เวลามีคนถามความเห็นเรื่องสำคัญ คุณอาจตอบช้ากว่าที่คิด เพราะอยากฟังให้ครบก่อน',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['emotion', 'drive'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_leadership_people_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['leadership'],
      secondarySemanticTags: ['people'],
      relationshipType: CuratedRelationshipType.tension,
      heroSentences: [
        'คนรอบตัวมักเห็นว่าคุณนำทีมได้ดีและกล้าตัดสินใจเมื่อจำเป็น',
        'เบื้องหลังนั้น คุณยังใส่ใจว่าทุกคนในทีมรู้สึกอย่างไร',
        'เมื่อทีมลังเลและไม่มีใครกล้าเริ่ม คุณมักเป็นคนแรกที่ก้าวออกมารับหน้าที่',
        'ในที่ประชุม คุณมักฟังทุกฝ่ายก่อนสรุป เพื่อให้ทุกคนรู้สึกว่าได้มีส่วนร่วม',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['leadership', 'people'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_resilient_analytical_v1',
      section: CuratedNarrativeSection.hero,
      primaryTraitIds: ['resilient'],
      secondaryTraitIds: ['analytical'],
      relationshipType: CuratedRelationshipType.primarySecondary,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณฟื้นตัวจากความยากลำบากได้เร็วและไม่ยอมแพ้ง่าย ๆ',
        'เบื้องหลังนั้น คุณมักใคร่ครวญและวิเคราะห์ก่อนจะลุกขึ้นไปต่อ',
        'เมื่อเจอเรื่องยาก คุณมักใช้เวลาไม่นานในการตั้งหลัก จากนั้นจะเริ่มมองหาว่าขั้นต่อไปทำอะไรได้บ้าง',
        'คนรอบตัวจึงมักเห็นคุณเป็นคนที่พึ่งพาได้ในวันที่สถานการณ์ไม่เป็นใจ',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['resilient', 'analytical'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_disciplined_curious_v1',
      section: CuratedNarrativeSection.hero,
      primaryTraitIds: ['disciplined'],
      secondaryTraitIds: ['curious'],
      relationshipType: CuratedRelationshipType.primarySecondary,
      heroSentences: [
        'คนอื่นมักเห็นว่าคุณมีวินัยและทำตามสัญญาได้สม่ำเสมอ',
        'เบื้องหลังนั้น คุณยังอยากรู้และเปิดรับสิ่งใหม่ที่ช่วยให้ทำงานได้ดีขึ้น',
        'เมื่อเห็นว่าวิธีใหม่มีประโยชน์จริง คุณจะลองและปรับใช้โดยไม่ทิ้งความรับผิดชอบเดิม',
        'เวลาต้องเลือก คุณมักตั้งกรอบชัดก่อน แล้วค่อยเปิดพื้นที่ให้ลองในขอบเขตนั้น',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['disciplined', 'curious'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_primary_only_thinking_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['thinking'],
      relationshipType: CuratedRelationshipType.primaryOnly,
      heroSentences: [
        'คนรอบตัวมักมองว่าคุณเป็นคนคิดอย่างรอบคอบก่อนพูดหรือตัดสินใจ และไม่รีบสรุป',
        'เบื้องหลังนั้น คุณอยากมั่นใจว่าคิดมาดีพอแล้วค่อยตัดสินใจ',
        'เมื่อมีเวลาให้ทบทวน คุณมักเห็นจุดที่คนอื่นมองข้าม',
        'เวลาต้องเลือก คุณมักลิสต์ข้อดีข้อเสียในหัวอยู่เงียบ ๆ ก่อนเสมอ',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['thinking'],
    ),
    CuratedNarrativeBlock(
      id: 'hero_no_time_cautious_v1',
      section: CuratedNarrativeSection.hero,
      primarySemanticTags: ['structure'],
      relationshipType: CuratedRelationshipType.primaryOnly,
      requiresBirthTime: false,
      safeWithoutBirthTime: true,
      minimumConfidence: 0.0,
      heroSentences: [
        'ภาพรวมจากวันเกิดสะท้อนว่า คนรอบตัวมักเห็นคุณเป็นคนที่มีแนวทางชัดและทำตามที่ตั้งใจ',
        'คุณอาจมีแนวโน้มคิดรอบก่อนลงมือ โดยเฉพาะเรื่องที่มีผลต่อคนอื่น',
        'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกสบายใจเมื่อไหร่ที่แผนชัด',
        'เมื่อไม่มีใครกล้าตัดสินใจ คุณอาจเป็นคนที่ก้าวออกมารับหน้าที่ก่อน',
        'โดยไม่มีเวลาเกิด รายงานนี้เน้นภาพรวมจากวันเกิด และไม่ลงลึกเรื่องจังหวะชีวิตรายชั่วโมง',
      ],
      sourceSignalIds: ['structure'],
    ),
  ];

  // --- Strength blocks (3-part: behavior, value, caution) -------------------

  static const _strengthBlocks = <CuratedNarrativeBlock>[
    CuratedNarrativeBlock(
      id: 'strength_resilient_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['resilient'],
      primarySemanticTags: ['drive'],
      observableBehavior:
          'เมื่อเจอเรื่องยาก คุณมักใช้เวลาไม่นานในการตั้งหลัก จากนั้นจะเริ่มมองหาว่าขั้นต่อไปทำอะไรได้บ้าง',
      strengthText:
          'คนรอบตัวจึงมักเห็นคุณเป็นคนที่พึ่งพาได้ในวันที่สถานการณ์ไม่เป็นใจ',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจรีบลุกขึ้นไปต่อ จนไม่ได้ยอมรับว่าตัวเองก็เหนื่อยเหมือนกัน',
      sourceSignalIds: ['resilient'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_analytical_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['analytical'],
      primarySemanticTags: ['thinking'],
      observableBehavior:
          'เวลาต้องเลือก คุณมักลิสต์ข้อดีข้อเสียในหัวอยู่เงียบ ๆ ก่อนเสมอ',
      strengthText:
          'ทำให้คนรอบตัวตัดสินใจได้อย่างวางใจ เพราะรู้ว่าคุณคิดมารอบแล้ว',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจใช้เวลาตรวจซ้ำหลังข้อมูลเพียงพอแล้ว',
      sourceSignalIds: ['analytical'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_disciplined_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['disciplined'],
      primarySemanticTags: ['structure'],
      observableBehavior:
          'คุณมักทำตามสัญญาและไม่ทิ้งงานค้างกลางทาง แม้ไม่มีใครคอยเตือน',
      strengthText: 'คนรอบตัวจึงมักไว้ใจให้คุณรับผิดชอบเรื่องสำคัญ',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจแบกงานเพิ่มเพราะไม่อยากทำให้ใครผิดหวัง',
      sourceSignalIds: ['disciplined'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_curious_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['curious'],
      primarySemanticTags: ['novelty'],
      observableBehavior:
          'คุณมักถาม ชอบลอง และเปิดรับสิ่งใหม่ที่ช่วยให้เข้าใจเรื่องลึกขึ้น',
      strengthText: 'ทำให้ทีมหรือคนรอบตัวเห็นมุมที่ไม่เคยนึกถึง',
      tensionText: 'จุดที่ควรระวังคือ คุณอาจกระจายความสนใจไปหลายเรื่องพร้อมกัน',
      sourceSignalIds: ['curious'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_practical_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['practical'],
      primarySemanticTags: ['action'],
      observableBehavior: 'พอเห็นว่าควรทำ คุณมักเริ่มเลยไม่รอจังหวะที่สมบูรณ์',
      strengthText: 'ทำให้สิ่งต่าง ๆ รอบตัวขยับและเดินหน้าได้จริง',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจลงมือเร็วก่อนจะได้ฟังมุมอื่นที่สำคัญ',
      sourceSignalIds: ['practical'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_ambitious_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['ambitious'],
      primarySemanticTags: ['drive'],
      observableBehavior:
          'เมื่อมีเป้าหมายชัด คุณมักทุ่มเทและไม่ยอมแพ้ง่าย ๆ แม้เจออุปสรรค',
      strengthText: 'คนรอบตัวจึงมักเห็นคุณเป็นคนที่ผลักดันให้สิ่งสำคัญเกิดขึ้น',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจลืมพักเพราะอยากให้ถึงเส้นชัยเร็วเกินไป',
      sourceSignalIds: ['ambitious'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_empathetic_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['empathetic', 'supportive'],
      primarySemanticTags: ['people'],
      observableBehavior:
          'เวลาคนใกล้ตัวมีปัญหา คุณมักไม่รอให้เขาขอ แต่ลงมือช่วยจัดการให้เลย',
      strengthText: 'ทำให้คนรอบตัวรู้สึกว่ามีคุณอยู่แล้วอุ่นใจ',
      tensionText: 'จุดที่ควรระวังคือ คุณอาจแบกความรู้สึกของคนอื่นไว้นานเกินไป',
      sourceSignalIds: ['empathetic'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_adaptable_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['adaptable'],
      primarySemanticTags: ['novelty'],
      observableBehavior:
          'เมื่อแผนเปลี่ยน คุณมักปรับตัวได้เร็วและหาทางใหม่โดยไม่ติดกับของเดิม',
      strengthText:
          'ทำให้ทีมหรือครอบครัวรู้สึกว่ามีคนช่วยรับมือกับความไม่แน่นอน',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจปรับตัวเร็วจนลืมถามว่าตัวเองต้องการอะไรจริง ๆ',
      sourceSignalIds: ['adaptable'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_grounded_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['grounded'],
      primarySemanticTags: ['structure'],
      observableBehavior:
          'คุณมักวางแผนและทำตามขั้นตอนที่คิดไว้ ไม่รีบเปลี่ยนทิศทางโดยไม่จำเป็น',
      strengthText: 'ทำให้คนรอบตัวรู้สึกมั่นใจว่ามีโครงสร้างรองรับ',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจต้านการเปลี่ยนแปลงที่จำเป็นเพราะอยากคงความมั่นคง',
      sourceSignalIds: ['grounded'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_independent_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['independent'],
      primarySemanticTags: ['independent'],
      observableBehavior:
          'คุณมักชอบทำเองและตัดสินใจได้เมื่อมีพื้นที่คิดของตัวเอง',
      strengthText: 'ทำให้คุณลงมือได้เต็มที่โดยไม่ต้องรอใคร',
      tensionText: 'จุดที่ควรระวังคือ คุณอาจไม่ขอความช่วยเหลือแม้จะเหนื่อย',
      sourceSignalIds: ['independent'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_protective_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['protective'],
      primarySemanticTags: ['people'],
      observableBehavior:
          'เมื่อคนที่คุณแคร์เจอปัญหา คุณมักเป็นคนแรกที่ยืนข้างและช่วยกันหาแนวทาง',
      strengthText: 'ทำให้คนใกล้ตัวรู้สึกว่ามีใครคอยดูแล',
      tensionText: 'จุดที่ควรระวังคือ คุณอาจลืมดูแลตัวเองเพราะโฟกัสที่คนอื่น',
      sourceSignalIds: ['protective'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_leader_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['leader', 'leadership'],
      primarySemanticTags: ['leadership'],
      observableBehavior:
          'เมื่อทีมลังเล คุณมักเป็นคนแรกที่ก้าวออกมารับหน้าที่และกำหนดทิศทาง',
      strengthText: 'ทำให้คนรอบตัวรู้สึกว่ามีใครนำทางเมื่อสถานการณ์ไม่ชัด',
      tensionText:
          'จุดที่ควรระวังคือ คุณอาจรับงานมากเกินเพราะคิดว่าต้องเป็นคนนำเสมอ',
      sourceSignalIds: ['leader'],
    ),
  ];

  // --- Domain narrative blocks ----------------------------------------------

  static final _domainBlocks = <CuratedNarrativeBlock>[
    ..._domainBlocksForTag('thinking', _thinkingDomain),
    ..._domainBlocksForTag('structure', _structureDomain),
    ..._domainBlocksForTag('action', _actionDomain),
    ..._domainBlocksForTag('drive', _driveDomain),
    ..._domainBlocksForTag('people', _peopleDomain),
    ..._domainBlocksForTag('emotion', _emotionDomain),
    ..._domainBlocksForTag('novelty', _noveltyDomain),
    ..._domainBlocksForTag('leadership', _leadershipDomain),
    ..._domainBlocksForTag('caution', _cautionDomain),
    ..._domainBlocksForTag('independent', _independentDomain),
  ];

  static List<CuratedNarrativeBlock> _domainBlocksForTag(
    String tag,
    Map<ThaiBetaLifeDomain, ({String overview, String why})> copy,
  ) {
    return copy.entries.map((e) {
      return CuratedNarrativeBlock(
        id: 'domain_${tag}_${e.key.aspectKey}_v1',
        section: CuratedNarrativeSection.domain,
        domain: e.key,
        primarySemanticTags: [tag],
        relationshipType: CuratedRelationshipType.domainPrimary,
        // Domain copy is day-based observation, not birth-time dependent.
        safeWithoutBirthTime: true,
        domainOverview: e.value.overview,
        domainWhy: e.value.why,
        sourceSignalIds: [tag, e.key.aspectKey],
      );
    }).toList();
  }

  static const _thinkingDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักชอบทำความเข้าใจก่อนลงมือ และไม่รีบสรุปเมื่อข้อมูลยังไม่ครบ',
      why: 'เพราะคุณอยากมั่นใจว่าการตัดสินใจมีผลต่อทีมและเป้าหมายระยะยาว',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักเปรียบเทียบตัวเลือกและคิดถึงผลในระยะยาวก่อนตัดสินใจ',
      why: 'เพราะคุณไม่อยากเสี่ยงกับสิ่งที่ยังไม่เข้าใจพอ',
    ),
    ThaiBetaLifeDomain.love: (
      overview: 'ในความสัมพันธ์ คุณมักฟังและทำความเข้าใจก่อนจะตอบสนอง',
      why: 'เพราะคุณอยากรู้ว่าอีกฝ่ายต้องการอะไรจริง ๆ ก่อนจะแสดงออก',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักสังเกตสัญญาณของตัวเองและไม่รีบดันต่อเมื่อรู้สึกว่ายังไม่พร้อม',
      why: 'เพราะคุณรู้ว่าการฟื้นตัวต้องเริ่มจากการเข้าใจตัวเองก่อน',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักมองหลายมุมก่อนจะตัดสินใจรับหรือปฏิเสธ',
      why: 'เพราะคุณอยากรู้ว่าโอกาสนั้นเข้ากับแผนที่มีอยู่หรือไม่',
    ),
  };

  static const _structureDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักวางแผนและทำตามขั้นตอนที่คิดไว้ ไม่รีบเปลี่ยนทิศทางโดยไม่จำเป็น',
      why: 'เพราะคุณรู้สึกสบายใจเมื่อมีโครงสร้างและความรับผิดชอบที่ชัด',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักวางแผนการใช้จ่ายและออม ไม่ใช้เงินแบบไม่มีกรอบ',
      why: 'เพราะความมั่นคงทางการเงินช่วยให้คุณตัดสินใจเรื่องอื่นได้สบายใจ',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักแสดงความรักด้วยการทำตามสัญญาและดูแลเรื่องที่สำคัญร่วมกัน',
      why: 'เพราะคุณเชื่อว่าความไว้ใจสร้างจากความสม่ำเสมอมากกว่าคำพูดหวาน',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักสร้างกิจวัตรที่ช่วยให้ร่างกายและใจฟื้นตัวได้สม่ำเสมอ',
      why: 'เพราะคุณรู้ว่าการดูแลตัวเองต้องทำเป็นประจำ ไม่ใช่รอจนเหนื่อย',
    ),
    ThaiBetaLifeDomain.luck: (
      overview:
          'เรื่องโอกาส คุณมักเตรียมพื้นฐานไว้ก่อน แล้วค่อยต่อยอดเมื่อจังหวะมา',
      why: 'เพราะคุณเชื่อว่าโอกาสที่ยั่งยืนต้องมีรากฐานรองรับ',
    ),
  };

  static const _actionDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักลงมือเร็วเมื่อเห็นว่าควรทำ และไม่ชอบปล่อยให้เรื่องค้าง',
      why: 'เพราะคุณอยากเห็นผลลัพธ์จริง ไม่ใช่แค่แผนบนกระดาษ',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักตัดสินใจใช้จ่ายหรือลงทุนได้เร็วเมื่อเห็นว่าคุ้มค่า',
      why: 'เพราะคุณเชื่อว่าการรอนานเกินไปอาจพลาดโอกาสที่ดี',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักแสดงความรักด้วยการลงมือช่วยและอยู่ข้าง ๆ เมื่อจำเป็น',
      why: 'เพราะคุณรู้สึกว่าการกระทำพูดแทนคำพูดได้ในหลายช่วง',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักลงมือดูแลตัวเองทันทีเมื่อรู้สึกว่าร่างกายหรือใจเริ่มล้า',
      why: 'เพราะคุณไม่อยากปล่อยให้ความเหนื่อยสะสมจนกลายเป็นปัญหาใหญ่',
    ),
    ThaiBetaLifeDomain.luck: (
      overview:
          'เรื่องโอกาส คุณมักลงมือทันทีเมื่อเห็นว่าพร้อม ไม่รอจังหวะที่สมบูรณ์',
      why: 'เพราะคุณเชื่อว่าการเริ่มก่อนจะช่วยให้เห็นทางที่ชัดขึ้น',
    ),
  };

  static const _driveDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักมุ่งมั่นและไม่ยอมแพ้ง่าย ๆ เมื่อมีเป้าหมายที่สำคัญ',
      why: 'เพราะคุณอยากเห็นสิ่งที่ตั้งใจเกิดขึ้นจริง',
    ),
    ThaiBetaLifeDomain.money: (
      overview: 'เรื่องเงิน คุณมักทุ่มเทเพื่อสร้างความมั่นคงและโอกาสในอนาคต',
      why: 'เพราะคุณรู้สึกว่าการลงทุนในระยะยาวคุ้มกว่าการใช้แบบสั้น ๆ',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักทุ่มเทและไม่ยอมแพ้เมื่อความสัมพันธ์มีความหมาย',
      why: 'เพราะคุณเชื่อว่าความรักต้องดูแลและลงมือแก้ไข ไม่ใช่แค่รอ',
    ),
    ThaiBetaLifeDomain.health: (
      overview: 'ด้านพลังใจ คุณมักฟื้นตัวจากความยากลำบากได้เร็วและกลับมาทำต่อ',
      why: 'เพราะคุณมีแรงผลักดันที่อยากก้าวข้ามอุปสรรค',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักกล้าลงทุนเวลาและพลังเมื่อเห็นว่ามีโอกาสจริง',
      why: 'เพราะคุณเชื่อว่าโอกาสที่ดีต้องจับให้ทัน',
    ),
  };

  static const _peopleDomain = {
    ThaiBetaLifeDomain.work: (
      overview: 'ในงาน คุณมักใส่ใจคนในทีมและช่วยให้ทุกคนรู้สึกว่าได้มีส่วนร่วม',
      why: 'เพราะคุณรู้ว่างานที่ดีต้องมีคนทำงานร่วมกันได้',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักใช้เงินเพื่อคนสำคัญและคิดถึงผลกระทบต่อครอบครัวหรือคนใกล้ตัว',
      why: 'เพราะความมั่นคงของคนรอบตัวมีความหมายกับคุณ',
    ),
    ThaiBetaLifeDomain.love: (
      overview: 'ในความสัมพันธ์ คุณมักเปิดใจและแสดงความห่วงใยด้วยการอยู่ข้าง ๆ',
      why: 'เพราะคุณรู้สึกว่าความใกล้ชิดสร้างจากการดูแลกันเป็นประจำ',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักฟื้นพลังได้ดีเมื่อได้คุยหรืออยู่กับคนที่เข้าใจ',
      why: 'เพราะความสัมพันธ์ที่ดีช่วยให้คุณรู้สึกว่าไม่ต้องแบกคนเดียว',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักเห็นโอกาสผ่านคนและเครือข่ายที่ไว้ใจได้',
      why: 'เพราะคุณเชื่อว่าคนที่เหมาะสมช่วยเปิดทางได้',
    ),
  };

  static const _emotionDomain = {
    ThaiBetaLifeDomain.work: (
      overview: 'ในงาน คุณมักใส่ใจบรรยากาศและความรู้สึกของทีม ไม่ใช่แค่ผลลัพธ์',
      why: 'เพราะคุณรู้ว่าคนที่รู้สึกดีทำงานได้ดีกว่า',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักตัดสินใจใช้จ่ายตามความรู้สึกและค่านิยมส่วนตัว',
      why: 'เพราะเงินกับคุณไม่ใช่แค่ตัวเลข แต่คือสิ่งที่สะท้อนความสำคัญ',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักแสดงความรักด้วยการเข้าใจความรู้สึกที่ไม่ได้พูดออกมา',
      why: 'เพราะคุณไวต่ออารมณ์และอยากให้อีกฝ่ายรู้สึกว่าได้รับการมองเห็น',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักรู้สึกถึงความเครียดและความเหนื่อยทางอารมณ์ก่อนร่างกาย',
      why: 'เพราะคุณไวต่อสัญญาณภายในและรู้ว่าต้องพักเมื่อใจล้า',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักรู้สึกถึงจังหวะที่เหมาะก่อนจะตัดสินใจลงมือ',
      why: 'เพราะคุณเชื่อว่าความรู้สึกที่สบายใจบอกได้ว่าโอกาสนั้นใช่หรือไม่',
    ),
  };

  static const _noveltyDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักเปิดรับวิธีใหม่และชอบเรียนรู้สิ่งที่ช่วยให้ทำงานได้ดีขึ้น',
      why: 'เพราะคุณรู้สึกตื่นเต้นเมื่อได้ลองและปรับปรุง',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักเปิดรับโอกาสการลงทุนหรือวิธีออมใหม่ที่น่าสนใจ',
      why: 'เพราะคุณอยากให้เงินทำงานและเติบโตไปกับคุณ',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักเปิดใจลองวิธีสื่อสารและแสดงความรักที่แตกต่าง',
      why: 'เพราะคุณอยากให้ความสัมพันธ์ไม่ติดกับรูปแบบเดิมจนเบื่อ',
    ),
    ThaiBetaLifeDomain.health: (
      overview: 'ด้านพลังใจ คุณมักลองวิธีพักผ่อนและดูแลตัวเองที่แตกต่าง',
      why: 'เพราะคุณรู้ว่าร่างกายและใจต้องการการเปลี่ยนแปลงบ้าง',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักมองเห็นโอกาสที่คนอื่นอาจมองข้าม',
      why: 'เพราะคุณชอบลองและปรับตัวเมื่อสถานการณ์เปลี่ยน',
    ),
  };

  static const _leadershipDomain = {
    ThaiBetaLifeDomain.work: (
      overview: 'ในงาน คุณมักนำทีมและตัดสินใจได้เมื่อสถานการณ์ไม่ชัด',
      why: 'เพราะคุณรู้สึกว่ามีหน้าที่ช่วยให้ทุกคนเดินหน้าได้',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักวางแผนการเงินของครอบครัวหรือทีมอย่างรับผิดชอบ',
      why: 'เพราะคุณอยากให้ทุกคนมีความมั่นคง',
    ),
    ThaiBetaLifeDomain.love: (
      overview:
          'ในความสัมพันธ์ คุณมักเป็นคนที่กำหนดทิศทางและดูแลเรื่องสำคัญร่วมกัน',
      why: 'เพราะคุณรู้สึกว่าความรักต้องมีคนดูแลให้เดินหน้า',
    ),
    ThaiBetaLifeDomain.health: (
      overview: 'ด้านพลังใจ คุณมักเป็นคนที่ดูแลคนรอบตัวจนบางครั้งลืมพักตัวเอง',
      why: 'เพราะคุณรู้สึกว่ามีหน้าที่ดูแลคนที่พึ่งพาได้',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักเป็นคนที่กล้าตัดสินใจและชวนคนอื่นลงมือด้วย',
      why: 'เพราะคุณเชื่อว่าโอกาสดีต้องมีคนนำให้เกิดขึ้น',
    ),
  };

  static const _cautionDomain = {
    ThaiBetaLifeDomain.work: (
      overview:
          'ในงาน คุณมักระวังและไม่รีบสรุปเมื่อยังมีความเสี่ยงที่มองไม่เห็น',
      why: 'เพราะคุณอยากให้ผลลัพธ์มั่นคงมากกว่าเร็ว',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักไม่ใช้จ่ายแบบหุนหันพลัน และคิดถึงความเสี่ยงก่อนลงทุน',
      why: 'เพราะความมั่นคงทางการเงินสำคัญกับคุณ',
    ),
    ThaiBetaLifeDomain.love: (
      overview: 'ในความสัมพันธ์ คุณมักใช้เวลาสร้างความไว้ใจก่อนเปิดใจเต็มที่',
      why: 'เพราะคุณไม่อยากเสี่ยงกับความรู้สึกที่ยังไม่มั่นใจ',
    ),
    ThaiBetaLifeDomain.health: (
      overview: 'ด้านพลังใจ คุณมักสังเกตสัญญาณเตือนและไม่ดันตัวเองเกินไป',
      why: 'เพราะคุณรู้ว่าร่างกายและใจต้องการการดูแลอย่างสม่ำเสมอ',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักประเมินความเสี่ยงก่อนตัดสินใจรับหรือปฏิเสธ',
      why: 'เพราะคุณอยากให้โอกาสที่เลือกมีพื้นฐานรองรับ',
    ),
  };

  static const _independentDomain = {
    ThaiBetaLifeDomain.work: (
      overview: 'ในงาน คุณมักชอบทำเองและตัดสินใจได้เมื่อมีพื้นที่คิดของตัวเอง',
      why: 'เพราะคุณรู้สึกว่าทำงานได้เต็มที่เมื่อไม่ต้องรอใคร',
    ),
    ThaiBetaLifeDomain.money: (
      overview:
          'เรื่องเงิน คุณมักจัดการการเงินส่วนตัวด้วยตัวเองและไม่พึ่งพาใครมากเกิน',
      why: 'เพราะความเป็นอิสระทางการเงินสำคัญกับคุณ',
    ),
    ThaiBetaLifeDomain.love: (
      overview: 'ในความสัมพันธ์ คุณมักต้องการพื้นที่ส่วนตัวและไม่ชอบถูกควบคุม',
      why: 'เพราะคุณรู้สึกว่าความใกล้ชิดต้องมีความเคารพในความเป็นตัวเอง',
    ),
    ThaiBetaLifeDomain.health: (
      overview:
          'ด้านพลังใจ คุณมักฟื้นพลังได้ดีเมื่อได้อยู่คนเดียวหรือทำสิ่งที่ชอบ',
      why: 'เพราะคุณต้องการเวลาเพื่อเติมพลังก่อนกลับไปดูแลคนอื่น',
    ),
    ThaiBetaLifeDomain.luck: (
      overview: 'เรื่องโอกาส คุณมักตัดสินใจเองและไม่รอให้ใครมาบอกว่าควรทำอะไร',
      why: 'เพราะคุณเชื่อว่าโอกาสที่ใช่ต้องมาจากการเลือกของตัวเอง',
    ),
  };

  // --- Dashboard blocks (current + why per domain/tag) ----------------------

  static final _dashboardBlocks = <CuratedNarrativeBlock>[
    for (final block in _domainBlocks)
      CuratedNarrativeBlock(
        id: 'dashboard_${block.id.replaceFirst('domain_', '')}',
        section: CuratedNarrativeSection.dashboard,
        domain: block.domain,
        primarySemanticTags: block.primarySemanticTags,
        primaryTraitIds: block.primaryTraitIds,
        relationshipType: CuratedRelationshipType.domainPrimary,
        safeWithoutBirthTime: true,
        dashboardCurrent: block.domainOverview,
        dashboardWhy: block.domainWhy,
        sourceSignalIds: block.sourceSignalIds,
      ),
  ];

  // --- Advice blocks (complete curated sentences) ---------------------------

  static const _adviceBlocks = <CuratedNarrativeBlock>[
    CuratedNarrativeBlock(
      id: 'advice_work_decision_time_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.work,
      primarySemanticTags: ['thinking', 'structure'],
      adviceText:
          'ลองกำหนดเวลาตัดสินใจให้เรื่องสำคัญในงาน เมื่อข้อมูลครบแล้ว เพื่อไม่ให้การตรวจซ้ำกินพลังเกินจำเป็น',
      sourceSignalIds: ['work', 'thinking'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_work_delegate_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.work,
      primarySemanticTags: ['drive', 'leadership'],
      adviceText:
          'ลองเว้นช่วงสั้น ๆ ก่อนตอบรับงานเพิ่ม เพื่อเช็กว่าคุณยังมีแรงพอรับผิดชอบสิ่งที่มีอยู่ในงานหรือไม่',
      sourceSignalIds: ['work', 'drive'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_money_plan_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.money,
      primarySemanticTags: ['structure', 'caution'],
      adviceText:
          'ลองจดรายการใช้จ่ายสัปดาห์นี้ เพื่อดูว่าเงินไหลไปกับอะไรที่สำคัญจริง ๆ',
      sourceSignalIds: ['money', 'structure'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_money_emotion_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.money,
      primarySemanticTags: ['emotion'],
      adviceText:
          'ลองหยุดสักครู่ก่อนตัดสินใจใช้เงินใหญ่ เพื่อแยกว่าเป็นเพราะต้องการจริงหรือเพราะอารมณ์ชั่วคราว',
      sourceSignalIds: ['money', 'emotion'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_love_communicate_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.love,
      primarySemanticTags: ['people', 'emotion'],
      adviceText:
          'ลองถามอีกฝ่ายในความสัมพันธ์ว่าวันนี้ต้องการอะไรจากคุณ เพื่อลดความเข้าใจผิดที่ไม่ได้พูดออกมา',
      sourceSignalIds: ['love', 'people'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_love_space_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.love,
      primarySemanticTags: ['independent'],
      adviceText:
          'ลองบอกพื้นที่ส่วนตัวที่ต้องการในความสัมพันธ์อย่างตรงไปตรงมา เพื่อให้ทั้งสองฝ่ายสบายใจ',
      sourceSignalIds: ['love', 'independent'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_health_rest_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.health,
      primarySemanticTags: ['emotion', 'drive'],
      adviceText:
          'ลองพักสั้น ๆ ก่อนเริ่มงานใหม่ เพื่อเช็กพลังงานและความเครียดว่ายังพอมีแรงหรือไม่',
      sourceSignalIds: ['health', 'emotion'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_health_stress_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.health,
      primarySemanticTags: ['caution', 'thinking'],
      adviceText:
          'ลองสังเกตว่าคุณเริ่มเครียดเมื่อไหร่ เพื่อหยุดก่อนที่จะแบกต่อจนเหนื่อยเกินไป',
      sourceSignalIds: ['health', 'caution'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_luck_try_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.luck,
      primarySemanticTags: ['novelty', 'action'],
      adviceText:
          'ลองเริ่มจากขั้นเล็ก ๆ ของโอกาสที่สนใจ เพื่อดูว่าเข้ากับแผนที่มีอยู่หรือไม่',
      sourceSignalIds: ['luck', 'novelty'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_luck_network_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.luck,
      primarySemanticTags: ['people'],
      adviceText:
          'ลองปรึกษาคนที่ไว้ใจได้ก่อนตัดสินใจรับโอกาสใหม่ เพื่อได้มุมมองที่คุณอาจมองข้าม',
      sourceSignalIds: ['luck', 'people'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_work_alt_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.work,
      primarySemanticTags: ['structure', 'thinking'],
      adviceText:
          'ลองแยกงานที่ต้องทำให้เสร็จวันนี้ ออกจากงานที่แค่รู้สึกว่าควรทำ เพื่อลดภาระที่สะสมโดยไม่จำเป็น',
      sourceSignalIds: ['work', 'structure'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_money_alt_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.money,
      primarySemanticTags: ['caution', 'structure'],
      adviceText:
          'ลองตั้งงบสำหรับสิ่งที่สำคัญสัปดาห์นี้ก่อน แล้วค่อยดูรายการอื่นที่ยังยืดหยุ่นได้',
      sourceSignalIds: ['money', 'caution'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_love_alt_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.love,
      primarySemanticTags: ['emotion', 'people'],
      adviceText:
          'ลองเว้นเวลาเงียบ ๆ คู่กันสักครู่ โดยไม่ต้องแก้ปัญหาทันที เพื่อให้ทั้งสองฝ่ายได้หายใจ',
      sourceSignalIds: ['love', 'emotion'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_health_alt_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.health,
      primarySemanticTags: ['caution', 'drive'],
      adviceText:
          'ลองสังเกตสัญญาณเหนื่อยของร่างกายหลังงานหนัก แล้วจัดเวลาพักให้ชัดก่อนเริ่มรอบใหม่',
      sourceSignalIds: ['health', 'caution'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_luck_alt_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.luck,
      primarySemanticTags: ['novelty', 'action'],
      adviceText:
          'ลองเปิดรับข้อมูลใหม่ของโอกาสที่สนใจ โดยยังไม่ต้องตัดสินใจใหญ่ในวันเดียวกัน',
      sourceSignalIds: ['luck', 'novelty'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_work_fallback_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.work,
      relationshipType: CuratedRelationshipType.fallback,
      adviceText:
          'ลองกำหนดเวลาตัดสินใจให้เรื่องสำคัญในงาน เมื่อข้อมูลครบแล้ว เพื่อไม่ให้การตรวจซ้ำกินพลังเกินจำเป็น',
      sourceSignalIds: ['work', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_money_fallback_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.money,
      relationshipType: CuratedRelationshipType.fallback,
      adviceText:
          'ลองจดรายการใช้จ่ายสัปดาห์นี้ เพื่อดูว่าเงินไหลไปกับอะไรที่สำคัญจริง ๆ',
      sourceSignalIds: ['money', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_love_fallback_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.love,
      relationshipType: CuratedRelationshipType.fallback,
      adviceText:
          'ลองถามอีกฝ่ายในความสัมพันธ์ว่าวันนี้ต้องการอะไรจากคุณ เพื่อลดความเข้าใจผิดที่ไม่ได้พูดออกมา',
      sourceSignalIds: ['love', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_health_fallback_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.health,
      relationshipType: CuratedRelationshipType.fallback,
      adviceText:
          'ลองพักสั้น ๆ ก่อนเริ่มงานใหม่ เพื่อเช็กพลังงานและความเครียดว่ายังพอมีแรงหรือไม่',
      sourceSignalIds: ['health', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_luck_fallback_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      domain: ThaiBetaLifeDomain.luck,
      relationshipType: CuratedRelationshipType.fallback,
      adviceText:
          'ลองเริ่มจากขั้นเล็ก ๆ ของโอกาสที่สนใจ เพื่อดูว่าเข้ากับแผนที่มีอยู่หรือไม่',
      sourceSignalIds: ['luck', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'advice_general_reflect_v1',
      section: CuratedNarrativeSection.advice,
      safeWithoutBirthTime: true,
      adviceText:
          'ลองทบทวนสิ่งที่รู้สึกตรงที่สุดจากรายงานนี้ เพื่อเลือกจุดเดียวที่อยากลองปรับในสัปดาห์นี้',
      relationshipType: CuratedRelationshipType.fallback,
      sourceSignalIds: ['general'],
    ),
  ];

  // --- Domain fallbacks (cautious language — safe without birth time) -------

  static const _fallbackBlocks = <CuratedNarrativeBlock>[
    CuratedNarrativeBlock(
      id: 'fallback_hero_v1',
      section: CuratedNarrativeSection.hero,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: false,
      heroSentences: [
        'คนรอบตัวมักเห็นว่าคุณมีแนวทางชัดและทำตามที่ตั้งใจ',
        'เบื้องหลังนั้น คุณมักคิดรอบก่อนลงมือ โดยเฉพาะเรื่องที่มีผลต่อคนอื่น',
        'เมื่อไม่มีใครกล้าตัดสินใจ คุณอาจเป็นคนที่ก้าวออกมารับหน้าที่ก่อน',
        'ถ้าอ่านแล้วรู้สึกว่าบางส่วนตรง บางส่วนยังไม่ใช่ทั้งหมด — ใช้เฉพาะที่สะท้อนชีวิตจริงของคุณก็พอ',
      ],
      sourceSignalIds: ['hero', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_strength_v1',
      section: CuratedNarrativeSection.strength,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: false,
      observableBehavior:
          'เวลาเจอเรื่องสำคัญ คุณมักใช้เวลาสั้น ๆ ในการตั้งหลัก แล้วค่อยมองหาขั้นต่อไป',
      strengthText: 'ทำให้คนรอบตัวรู้สึกว่าคุณพึ่งพาได้เมื่อสถานการณ์ไม่เป็นใจ',
      tensionText:
          'จุดที่ควรระวังคือ อย่ารีบลุกขึ้นไปต่อจนลืมเช็กว่าตัวเองยังมีแรงพอหรือไม่',
      sourceSignalIds: ['strength', 'fallback'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_leader_no_time_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['leader', 'leadership'],
      primarySemanticTags: ['leadership'],
      relationshipType: CuratedRelationshipType.primaryOnly,
      requiresBirthTime: false,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มก้าวออกมารับบทบาทนำเมื่อทีมลังเล',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกมั่นใจเมื่อไหร่ที่ได้ช่วยกำหนดทิศทาง',
      tensionText:
          'จุดที่ควรระวังคือ อย่ารับงานมากเกินเพราะคิดว่าต้องเป็นคนนำเสมอ',
      sourceSignalIds: ['leader', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_disciplined_no_time_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['disciplined'],
      primarySemanticTags: ['structure'],
      relationshipType: CuratedRelationshipType.primaryOnly,
      requiresBirthTime: false,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มทำตามสิ่งที่ตั้งใจและไม่ทิ้งงานค้างกลางทาง',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกสบายใจเมื่อไหร่ที่มีแผนชัด',
      tensionText:
          'จุดที่ควรระวังคือ อย่าแบกทุกอย่างเองจนลืมขอความช่วยเหลือเมื่อเริ่มเหนื่อย',
      sourceSignalIds: ['disciplined', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'strength_reflective_no_time_v1',
      section: CuratedNarrativeSection.strength,
      primaryTraitIds: ['reflective'],
      primarySemanticTags: ['thinking'],
      relationshipType: CuratedRelationshipType.primaryOnly,
      requiresBirthTime: false,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มคิดทบทวนก่อนตอบหรือก่อนลงมือ',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกมั่นใจเมื่อไหร่ที่ได้ใช้เวลาคิดรอบ',
      tensionText: 'จุดที่ควรระวังคือ อย่าใช้เวลาตรวจซ้ำหลังข้อมูลเพียงพอแล้ว',
      sourceSignalIds: ['reflective', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_strength_no_time_2',
      section: CuratedNarrativeSection.strength,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มใส่ใจผลลัพธ์ก่อนจะลงมือจริง',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกพร้อมเมื่อไหร่ที่เห็นภาพรวมชัด',
      tensionText:
          'จุดที่ควรระวังคือ อย่าใช้ข้อความนี้แทนการสังเกตพฤติกรรมจริงในชีวิตประจำวัน',
      sourceSignalIds: ['strength', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_strength_no_time_3',
      section: CuratedNarrativeSection.strength,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มปรับตัวเมื่อแผนเปลี่ยน',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกยืดหยุ่นเมื่อไหร่ที่ยังเห็นเป้าหมายชัด',
      tensionText:
          'จุดที่ควรระวังคือ อย่าปรับตัวเร็วจนลืมถามว่าตัวเองต้องการอะไรจริง ๆ',
      sourceSignalIds: ['strength', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_strength_no_time',
      section: CuratedNarrativeSection.strength,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      observableBehavior:
          'ภาพรวมจากวันเกิดสะท้อนว่า คุณอาจมีแนวโน้มลงมือเมื่อเห็นว่าเรื่องนั้นสำคัญ',
      strengthText:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกมั่นใจเมื่อไหร่ที่ทิศทางชัด',
      tensionText:
          'จุดที่ควรระวังคือ อย่าใช้ข้อความนี้แทนการสังเกตพฤติกรรมจริงในชีวิตประจำวัน',
      sourceSignalIds: ['strength', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_work_domain',
      section: CuratedNarrativeSection.domain,
      domain: ThaiBetaLifeDomain.work,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      domainOverview:
          'ภาพรวมจากวันเกิดสะท้อนว่า ในด้านการงาน คุณอาจมีแนวโน้มชอบทำตามแนวทางของตัวเองเมื่อเห็นว่าเรื่องนั้นสำคัญ',
      domainWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกมีพลังเมื่อไหร่ที่งานมีทิศทางชัด',
      sourceSignalIds: ['work', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_money_domain',
      section: CuratedNarrativeSection.domain,
      domain: ThaiBetaLifeDomain.money,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      domainOverview:
          'ภาพรวมจากวันเกิดสะท้อนว่า เรื่องเงิน คุณอาจมีแนวโน้มคิดถึงความมั่นคงและใช้จ่ายตามลำดับความสำคัญ',
      domainWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกสบายใจเมื่อไหร่ที่การเงินมีกรอบชัด',
      sourceSignalIds: ['money', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_love_domain',
      section: CuratedNarrativeSection.domain,
      domain: ThaiBetaLifeDomain.love,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      domainOverview:
          'ภาพรวมจากวันเกิดสะท้อนว่า ในความสัมพันธ์ คุณอาจมีแนวโน้มใส่ใจและอยากให้คนใกล้ตัวรู้สึกว่าได้รับการดูแล',
      domainWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกใกล้ชิดเมื่อไหร่ที่มีการสื่อสารที่ชัด',
      sourceSignalIds: ['love', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_health_domain',
      section: CuratedNarrativeSection.domain,
      domain: ThaiBetaLifeDomain.health,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      domainOverview:
          'ภาพรวมจากวันเกิดสะท้อนว่า ด้านพลังใจ คุณอาจมีแนวโน้มรู้สึกเมื่อร่างกายหรือใจเริ่มล้า และอยากมีเวลาฟื้น',
      domainWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณเริ่มเหนื่อยเมื่อไหร่และต้องการพักแค่ไหน',
      sourceSignalIds: ['health', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_luck_domain',
      section: CuratedNarrativeSection.domain,
      domain: ThaiBetaLifeDomain.luck,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      domainOverview:
          'ภาพรวมจากวันเกิดสะท้อนว่า เรื่องโอกาส คุณอาจมีแนวโน้มมองหาจังหวะที่เหมาะก่อนจะลงมือ',
      domainWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกพร้อมรับโอกาสเมื่อไหร่',
      sourceSignalIds: ['luck', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_work_dashboard',
      section: CuratedNarrativeSection.dashboard,
      domain: ThaiBetaLifeDomain.work,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      dashboardCurrent:
          'ภาพรวมจากวันเกิดสะท้อนว่า ในด้านการงาน คุณอาจมีแนวโน้มชอบทำตามแนวทางของตัวเองเมื่อเห็นว่าเรื่องนั้นสำคัญ',
      dashboardWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกมีพลังเมื่อไหร่ที่งานมีทิศทางชัด',
      sourceSignalIds: ['work', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_money_dashboard',
      section: CuratedNarrativeSection.dashboard,
      domain: ThaiBetaLifeDomain.money,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      dashboardCurrent:
          'ภาพรวมจากวันเกิดสะท้อนว่า เรื่องเงิน คุณอาจมีแนวโน้มคิดถึงความมั่นคงและใช้จ่ายตามลำดับความสำคัญ',
      dashboardWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกสบายใจเมื่อไหร่ที่การเงินมีกรอบชัด',
      sourceSignalIds: ['money', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_love_dashboard',
      section: CuratedNarrativeSection.dashboard,
      domain: ThaiBetaLifeDomain.love,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      dashboardCurrent:
          'ภาพรวมจากวันเกิดสะท้อนว่า ในความสัมพันธ์ คุณอาจมีแนวโน้มใส่ใจและอยากให้คนใกล้ตัวรู้สึกว่าได้รับการดูแล',
      dashboardWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกใกล้ชิดเมื่อไหร่ที่มีการสื่อสารที่ชัด',
      sourceSignalIds: ['love', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_health_dashboard',
      section: CuratedNarrativeSection.dashboard,
      domain: ThaiBetaLifeDomain.health,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      dashboardCurrent:
          'ภาพรวมจากวันเกิดสะท้อนว่า ด้านพลังใจ คุณอาจมีแนวโน้มรู้สึกเมื่อร่างกายหรือใจเริ่มล้า และอยากมีเวลาฟื้น',
      dashboardWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณเริ่มเหนื่อยเมื่อไหร่และต้องการพักแค่ไหน',
      sourceSignalIds: ['health', 'fallback', 'no_time'],
    ),
    CuratedNarrativeBlock(
      id: 'fallback_luck_dashboard',
      section: CuratedNarrativeSection.dashboard,
      domain: ThaiBetaLifeDomain.luck,
      relationshipType: CuratedRelationshipType.fallback,
      safeWithoutBirthTime: true,
      dashboardCurrent:
          'ภาพรวมจากวันเกิดสะท้อนว่า เรื่องโอกาส คุณอาจมีแนวโน้มมองหาจังหวะที่เหมาะก่อนจะลงมือ',
      dashboardWhy:
          'ประเด็นนี้เหมาะสำหรับใช้สังเกตตัวเองว่า คุณรู้สึกพร้อมรับโอกาสเมื่อไหร่',
      sourceSignalIds: ['luck', 'fallback', 'no_time'],
    ),
  ];
}
