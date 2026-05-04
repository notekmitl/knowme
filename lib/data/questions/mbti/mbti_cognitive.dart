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
];
