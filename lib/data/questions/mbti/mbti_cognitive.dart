import '../../questions/likert_options.dart';
import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

final List<TestQuestion> mbtiCognitiveQuestions = [
  /// Ni (Introverted Intuition)
  TestQuestion(
    id: "cog_1",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I often have sudden insights about how things will unfold.",
      "th":
          "ฉันมักมีความเข้าใจบางอย่างขึ้นมาอย่างฉับพลันเกี่ยวกับอนาคตหรือผลลัพธ์ของสิ่งต่าง ๆ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_2",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I tend to focus on the deeper meaning behind events.",
      "th": "ฉันมักมองหาความหมายที่ลึกกว่าสิ่งที่เกิดขึ้น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_3",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I trust my intuition about the future.",
      "th": "ฉันเชื่อสัญชาตญาณของตัวเองเกี่ยวกับอนาคต",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_4",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I often see patterns that others might miss.",
      "th": "ฉันมักเห็นรูปแบบหรือความเชื่อมโยงที่คนอื่นอาจไม่ทันสังเกต",
    },
    options: likert5,
  ),

  /// Ne (Extraverted Intuition)
  TestQuestion(
    id: "cog_5",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I enjoy brainstorming many different ideas.",
      "th": "ฉันชอบระดมความคิดและคิดไอเดียใหม่ ๆ หลายแบบ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_6",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I quickly see many possibilities in a situation.",
      "th": "ฉันมองเห็นความเป็นไปได้หลายทางในสถานการณ์เดียวกัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_7",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I enjoy exploring unconventional ideas.",
      "th": "ฉันชอบสำรวจแนวคิดที่แปลกใหม่",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_8",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "My mind often jumps from one idea to another.",
      "th": "ความคิดของฉันมักเชื่อมโยงจากไอเดียหนึ่งไปอีกไอเดียหนึ่ง",
    },
    options: likert5,
  ),

  /// Si (Introverted Sensing)
  TestQuestion(
    id: "cog_9",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I rely on past experiences when making decisions.",
      "th": "ฉันมักใช้ประสบการณ์ที่ผ่านมาในการตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_10",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I remember details from past events clearly.",
      "th": "ฉันจำรายละเอียดจากเหตุการณ์ในอดีตได้ค่อนข้างชัดเจน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_11",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I feel comfortable following familiar routines.",
      "th": "ฉันรู้สึกสบายใจกับกิจวัตรหรือสิ่งที่คุ้นเคย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_12",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I trust methods that have worked before.",
      "th": "ฉันเชื่อในวิธีการที่เคยใช้ได้ผลมาแล้ว",
    },
    options: likert5,
  ),

  /// Se (Extraverted Sensing)
  TestQuestion(
    id: "cog_13",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I enjoy engaging with my surroundings in the present moment.",
      "th": "ฉันชอบมีส่วนร่วมกับสิ่งรอบตัวในปัจจุบัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_14",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I like experiences that involve action or excitement.",
      "th": "ฉันชอบประสบการณ์ที่ตื่นเต้นหรือได้ลงมือทำจริง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_15",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I notice what is happening around me immediately.",
      "th": "ฉันสังเกตสิ่งที่เกิดขึ้นรอบตัวได้อย่างรวดเร็ว",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_16",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I enjoy living in the moment.",
      "th": "ฉันชอบใช้ชีวิตอยู่กับปัจจุบัน",
    },
    options: likert5,
  ),

  /// Ti (Introverted Thinking)
  TestQuestion(
    id: "cog_17",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I enjoy analyzing how things work internally.",
      "th": "ฉันชอบวิเคราะห์ว่าระบบหรือสิ่งต่าง ๆ ทำงานอย่างไร",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_18",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I like building logical frameworks in my mind.",
      "th": "ฉันชอบสร้างโครงสร้างความคิดที่เป็นตรรกะในหัวของตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_19",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I question ideas until they make logical sense to me.",
      "th": "ฉันมักตั้งคำถามกับแนวคิดต่าง ๆ จนกว่าจะเข้าใจอย่างมีเหตุผล",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_20",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "Understanding principles is more important than memorizing facts.",
      "th": "การเข้าใจหลักการสำคัญกว่าการจำข้อมูล",
    },
    options: likert5,
  ),

  /// Te (Extraverted Thinking)
  TestQuestion(
    id: "cog_21",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I focus on efficiency and results when solving problems.",
      "th": "เมื่อแก้ปัญหา ฉันมักเน้นประสิทธิภาพและผลลัพธ์",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_22",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I like organizing people and systems to achieve goals.",
      "th": "ฉันชอบจัดระบบหรือจัดการคนเพื่อให้บรรลุเป้าหมาย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_23",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I prefer clear plans and structured processes.",
      "th": "ฉันชอบแผนที่ชัดเจนและกระบวนการที่เป็นระบบ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_24",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I measure success by tangible outcomes.",
      "th": "ฉันวัดความสำเร็จจากผลลัพธ์ที่เห็นได้จริง",
    },
    options: likert5,
  ),

  /// Fi (Introverted Feeling)
  TestQuestion(
    id: "cog_25",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I make decisions based on my personal values.",
      "th": "ฉันตัดสินใจโดยยึดตามคุณค่าหรือความเชื่อส่วนตัว",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_26",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "Staying true to myself is very important to me.",
      "th":
          "การเป็นตัวของตัวเองและซื่อสัตย์กับความรู้สึกของตัวเองสำคัญมากสำหรับฉัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_27",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I often reflect on what feels right or wrong to me.",
      "th": "ฉันมักทบทวนว่าอะไรถูกหรือผิดตามความรู้สึกของตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_28",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I value authenticity and individuality.",
      "th": "ฉันให้ความสำคัญกับความจริงใจและความเป็นตัวของตัวเอง",
    },
    options: likert5,
  ),

  /// Fe (Extraverted Feeling)
  TestQuestion(
    id: "cog_29",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I naturally notice how others are feeling.",
      "th": "ฉันมักสังเกตได้ว่าคนรอบตัวกำลังรู้สึกอย่างไร",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_30",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "Maintaining harmony in groups matters to me.",
      "th": "การรักษาบรรยากาศที่ดีในกลุ่มสำคัญสำหรับฉัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_31",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I often adjust my behavior to support others emotionally.",
      "th": "ฉันมักปรับพฤติกรรมของตัวเองเพื่อช่วยให้คนอื่นรู้สึกดีขึ้น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "cog_32",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I care about how my actions affect people around me.",
      "th": "ฉันใส่ใจว่าการกระทำของฉันส่งผลต่อคนรอบตัวอย่างไร",
    },
    options: likert5,
  ),

  /// Progressive bank extensions (cog_33–80) — 6 per function for 80-item run.
  TestQuestion(
    id: "cog_33",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I connect present events to long-term implications.",
      "th": "ฉันเชื่อมสิ่งที่เกิดขึ้นตอนนี้กับผลในระยะยาว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_34",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I prefer a few deep interpretations over many surface facts.",
      "th": "ฉันชอบตีความลึกๆ มากกว่ารายละเอียดผิวเผิน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_35",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I often imagine how a situation will evolve.",
      "th": "ฉันมักจินตนาการว่าสถานการณ์จะเปลี่ยนไปอย่างไร",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_36",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I trust hunches that point toward an underlying theme.",
      "th": "ฉันเชื่อสัญชาตญาณที่ชี้ไปยังธีมหลักที่ซ่อนอยู่",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_37",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I simplify complexity by finding one core idea.",
      "th": "ฉันลดความซับซ้อนโดยหาแก่นความคิดหลักเดียว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_38",
    moduleId: "mbti_cognitive",
    trait: "Ni",
    reverse: false,
    text: {
      "en": "I reflect on symbols or metaphors to understand things.",
      "th": "ฉันใช้สัญลักษณ์หรืออุปมาเพื่อทำความเข้าใจสิ่งต่างๆ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_39",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I enjoy linking unrelated topics into new concepts.",
      "th": "ฉันชอบเชื่อมหัวข้อที่ต่างกันให้กลายเป็นไอเดียใหม่",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_40",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I get energy from exploring what-if scenarios.",
      "th": "ฉันมีพลังเมื่อได้สำรวจสถานการณ์สมมติ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_41",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I spot opportunities others might overlook.",
      "th": "ฉันมองเห็นโอกาสที่คนอื่นอาจมองข้าม",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_42",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I like starting projects before the plan is final.",
      "th": "ฉันชอบเริ่มลงมือก่อนที่แผนจะสมบูรณ์",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_43",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I adapt quickly when plans change unexpectedly.",
      "th": "ฉันปรับตัวได้เร็วเมื่อแผนเปลี่ยนกะทันหัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_44",
    moduleId: "mbti_cognitive",
    trait: "Ne",
    reverse: false,
    text: {
      "en": "I enjoy playful experimentation with ideas.",
      "th": "ฉันสนุกกับการทดลองไอเดียอย่างสร้างสรรค์",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_45",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I notice small changes from how things used to be.",
      "th": "ฉันสังเกตความเปลี่ยนเล็กน้อยเมื่อเทียบกับอดีต",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_46",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I prefer step-by-step methods I have used successfully.",
      "th": "ฉันชอบขั้นตอนที่เคยใช้แล้วได้ผล",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_47",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I compare new situations to similar past experiences.",
      "th": "ฉันเทียบสถานการณ์ใหม่กับประสบการณ์ที่คล้ายกัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_48",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I value consistency and reliability in daily habits.",
      "th": "ฉันให้ความสำคัญกับความสม่ำเสมอในกิจวัตร",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_49",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I store practical details that might be useful later.",
      "th": "ฉันเก็บรายละเอียดที่อาจมีประโยชน์ในอนาคต",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_50",
    moduleId: "mbti_cognitive",
    trait: "Si",
    reverse: false,
    text: {
      "en": "I feel grounded when routines are stable.",
      "th": "ฉันรู้สึกมั่นคงเมื่อกิจวัตรคงที่",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_51",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I respond quickly to what I see and hear right now.",
      "th": "ฉันตอบสนองต่อสิ่งที่เห็นและได้ยินในตอนนี้อย่างรวดเร็ว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_52",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I enjoy hands-on activities more than long theory.",
      "th": "ฉันชอบลงมือทำมากกว่าทฤษฎียาวๆ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_53",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I notice aesthetics, texture, and physical cues easily.",
      "th": "ฉันสังเกตสีสัน สัมผัส และสัญญาณทางกายภาพได้ง่าย",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_54",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I prefer concrete facts over abstract speculation.",
      "th": "ฉันชอบข้อเท็จจริงจริงมากกว่าการคาดเดาเชิงนามธรรม",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_55",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I improvise well when situations demand immediate action.",
      "th": "ฉันปรับตัวได้ดีเมื่อต้องลงมือทันที",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_56",
    moduleId: "mbti_cognitive",
    trait: "Se",
    reverse: false,
    text: {
      "en": "I stay alert to opportunities in the physical environment.",
      "th": "ฉันตื่นตัวกับโอกาสในสภาพแวดล้อมรอบตัว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_57",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I refine ideas by testing them against internal logic.",
      "th": "ฉันขัดเกลาไอเดียด้วยตรรกะภายใน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_58",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I enjoy defining precise terms before discussing a topic.",
      "th": "ฉันชอบนิยามคำให้ชัดก่อนคุยประเด็น",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_59",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I spot inconsistencies in arguments quickly.",
      "th": "ฉันเห็นความไม่สอดคล้องในข้อโต้แย้งได้เร็ว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_60",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I prefer solving problems by understanding root causes.",
      "th": "ฉันแก้ปัญหาโดยเข้าใจสาเหตุหลัก",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_61",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I categorize information into clean mental models.",
      "th": "ฉันจัดข้อมูลเป็นโมเดลในหัวอย่างเป็นระบบ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_62",
    moduleId: "mbti_cognitive",
    trait: "Ti",
    reverse: false,
    text: {
      "en": "I am skeptical until an idea fits my internal framework.",
      "th": "ฉันสงสัยจนกว่าไอเดียจะเข้ากับกรอบความคิดของฉัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_63",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I set clear metrics to track progress.",
      "th": "ฉันตั้งตัวชี้วัดที่ชัดเจนเพื่อติดตามความคืบหน้า",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_64",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I delegate tasks to keep projects moving efficiently.",
      "th": "ฉันมอบหมายงานเพื่อให้โปรเจกต์เดินต่ออย่างมีประสิทธิภาพ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_65",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I prioritize objective criteria over personal preference.",
      "th": "ฉันให้ความสำคัญกับเกณฑ์ที่วัดได้มากกว่าความชอบส่วนตัว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_66",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I streamline workflows to remove wasted steps.",
      "th": "ฉันปรับกระบวนการเพื่อตัดขั้นตอนที่ไม่จำเป็น",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_67",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I communicate decisions with direct, factual language.",
      "th": "ฉันสื่อสารการตัดสินใจด้วยภาษาที่ตรงและมีข้อเท็จจริง",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_68",
    moduleId: "mbti_cognitive",
    trait: "Te",
    reverse: false,
    text: {
      "en": "I prefer efficient systems over improvised approaches.",
      "th": "ฉันชอบระบบที่มีประสิทธิภาพมากกว่าการทำแบบฉับพลัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_69",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I need time alone to understand how I truly feel.",
      "th": "ฉันต้องการเวลาส่วนตัวเพื่อเข้าใจความรู้สึกที่แท้จริง",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_70",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I judge choices by whether they align with my values.",
      "th": "ฉันตัดสินใจจากว่าสอดคล้องกับคุณค่าของฉันหรือไม่",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_71",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I feel strongly when something violates my principles.",
      "th": "ฉันรู้สึกแรงเมื่อมีสิ่งที่ขัดกับหลักการของฉัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_72",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I express myself best through personal, sincere communication.",
      "th": "ฉันแสดงออกได้ดีผ่านการสื่อสารที่จริงใจ",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_73",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I protect my inner boundaries when pressured to conform.",
      "th": "ฉันรักษาขอบเขตส่วนตัวเมื่อถูกกดดันให้ยอมตาม",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_74",
    moduleId: "mbti_cognitive",
    trait: "Fi",
    reverse: false,
    text: {
      "en": "I seek meaning in work that reflects who I am.",
      "th": "ฉันมองหาความหมายในงานที่สะท้อนตัวตนของฉัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_75",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I help groups reach consensus on emotional concerns.",
      "th": "ฉันช่วยให้กลุ่มหาข้อสรุปเรื่องความรู้สึกได้",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_76",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I express appreciation openly to strengthen relationships.",
      "th": "ฉันแสดงความขอบคุณอย่างเปิดเผยเพื่อเสริมความสัมพันธ์",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_77",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I read social cues to guide how I respond.",
      "th": "ฉันอ่านสัญญาณทางสังคมเพื่อตอบสนองอย่างเหมาะสม",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_78",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I prioritize the group's mood when making plans.",
      "th": "ฉันใส่ใจบรรยากาศของกลุ่มเมื่อวางแผน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_79",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I mediate tension so people feel heard.",
      "th": "ฉันช่วยคลี่แนวตั้งเพื่อให้ทุกคนรู้สึกว่าถูกรับฟัง",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "cog_80",
    moduleId: "mbti_cognitive",
    trait: "Fe",
    reverse: false,
    text: {
      "en": "I motivate others by acknowledging their feelings.",
      "th": "ฉันจูงใจผู้อื่นโดยรับรู้ความรู้สึกของพวกเขา",
    },
    options: likert5,
  ),
];
