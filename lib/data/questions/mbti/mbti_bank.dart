import 'package:knowme/domain/models/test_question.dart';
import '../likert_options.dart';

final List<TestQuestion> mbtiBank = [
  TestQuestion(
    id: "mbti_acc_1",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I feel energized when interacting with many people.",
      "th": "ฉันรู้สึกมีพลังเมื่อได้พูดคุยหรือพบปะผู้คนจำนวนมาก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_2",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I prefer quiet time alone to recharge.",
      "th": "ฉันชอบใช้เวลาคนเดียวเงียบ ๆ เพื่อพักและเติมพลัง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_3",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I start conversations easily with strangers.",
      "th": "ฉันสามารถเริ่มคุยกับคนแปลกหน้าได้ง่าย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_4",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "Large social gatherings drain my energy.",
      "th": "การอยู่ในงานสังคมที่มีคนจำนวนมากทำให้ฉันหมดพลัง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_5",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I enjoy being the center of attention.",
      "th": "ฉันชอบเป็นจุดสนใจของคนในกลุ่ม",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_6",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I prefer listening rather than speaking in groups.",
      "th": "เวลาคุยกันเป็นกลุ่ม ฉันมักจะฟังมากกว่าพูด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_7",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I feel comfortable expressing myself openly.",
      "th": "ฉันรู้สึกสบายใจในการแสดงความคิดเห็นของตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_8",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I need time alone after social events.",
      "th": "หลังจากเข้าสังคม ฉันต้องการเวลาอยู่คนเดียวสักพัก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_9",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I enjoy working in teams.",
      "th": "ฉันชอบทำงานร่วมกับคนอื่นเป็นทีม",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_10",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I prefer small groups over large gatherings.",
      "th": "ฉันชอบอยู่กับกลุ่มเล็ก ๆ มากกว่างานที่มีคนจำนวนมาก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_11",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I enjoy meeting new people.",
      "th": "ฉันชอบทำความรู้จักกับคนใหม่ ๆ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_12",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I often keep my thoughts to myself.",
      "th": "ฉันมักเก็บความคิดของตัวเองไว้กับตัวเอง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_13",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I speak before thinking sometimes.",
      "th": "บางครั้งฉันพูดออกไปก่อนที่จะคิดให้ดี",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_14",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I think carefully before speaking.",
      "th": "ฉันมักคิดให้รอบคอบก่อนจะพูด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_15",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I enjoy lively environments.",
      "th": "ฉันชอบบรรยากาศที่คึกคักและมีชีวิตชีวา",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_16",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "Too much social interaction exhausts me.",
      "th": "การเข้าสังคมมากเกินไปทำให้ฉันรู้สึกเหนื่อยล้า",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_17",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I like sharing ideas out loud.",
      "th": "ฉันชอบพูดหรือแชร์ความคิดของตัวเองออกมา",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_18",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I prefer thinking internally.",
      "th": "ฉันชอบคิดทบทวนเงียบ ๆ อยู่ในใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_19",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: false,
    text: {
      "en": "I enjoy group discussions.",
      "th": "ฉันชอบการพูดคุยแลกเปลี่ยนความคิดเห็นเป็นกลุ่ม",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_20",
    moduleId: "mbti_accurate",
    trait: "E",
    reverse: true,
    text: {
      "en": "I prefer observing rather than participating.",
      "th": "ฉันมักชอบสังเกตมากกว่าการเข้าไปมีส่วนร่วม",
    },
    options: likert5,
  ),

  /// S / N
  TestQuestion(
    id: "mbti_acc_21",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I focus on concrete facts.",
      "th": "ฉันให้ความสำคัญกับข้อเท็จจริงที่จับต้องได้",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_22",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy imagining future possibilities.",
      "th": "ฉันชอบจินตนาการถึงความเป็นไปได้ในอนาคต",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_23",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I rely on practical solutions.",
      "th": "ฉันมักเลือกวิธีแก้ปัญหาที่ใช้ได้จริง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_24",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I like exploring abstract concepts.",
      "th": "ฉันชอบสำรวจแนวคิดหรือไอเดียเชิงนามธรรม",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_25",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "Details matter to me.",
      "th": "รายละเอียดเล็ก ๆ เป็นสิ่งสำคัญสำหรับฉัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_26",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I often think about big-picture ideas.",
      "th": "ฉันมักคิดถึงภาพรวมมากกว่ารายละเอียด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_27",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I trust proven methods.",
      "th": "ฉันเชื่อในวิธีที่ได้รับการพิสูจน์แล้ว",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "mbti_acc_28",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I like experimenting with new ideas.",
      "th": "ฉันชอบทดลองไอเดียหรือวิธีใหม่ ๆ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_29",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I prefer realistic thinking.",
      "th": "ฉันชอบการคิดที่อยู่บนพื้นฐานของความเป็นจริง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_30",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy connecting abstract ideas.",
      "th": "ฉันชอบเชื่อมโยงแนวคิดหรือไอเดียต่าง ๆ เข้าด้วยกัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_31",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I trust information I can verify.",
      "th": "ฉันเชื่อข้อมูลที่สามารถตรวจสอบหรือพิสูจน์ได้",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_32",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy thinking about theoretical ideas.",
      "th": "ฉันชอบคิดเกี่ยวกับแนวคิดเชิงทฤษฎีหรือแนวคิดลึก ๆ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_33",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I rely on past experiences.",
      "th": "ฉันมักใช้ประสบการณ์ที่ผ่านมาเป็นแนวทางในการตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_34",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy speculating about the future.",
      "th": "ฉันชอบคิดหรือคาดการณ์เกี่ยวกับอนาคต",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_35",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I value practical knowledge.",
      "th": "ฉันให้คุณค่ากับความรู้ที่สามารถนำไปใช้ได้จริง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_36",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy exploring possibilities.",
      "th": "ฉันชอบสำรวจความเป็นไปได้ใหม่ ๆ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_37",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I prefer step-by-step instructions.",
      "th": "ฉันชอบคำแนะนำที่เป็นขั้นตอนชัดเจน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_38",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I like exploring unconventional ideas.",
      "th": "ฉันชอบสำรวจแนวคิดใหม่ ๆ ที่ไม่เหมือนเดิม",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_39",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: false,
    text: {
      "en": "I value tangible results.",
      "th": "ฉันให้ความสำคัญกับผลลัพธ์ที่เห็นหรือจับต้องได้",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_40",
    moduleId: "mbti_accurate",
    trait: "S",
    reverse: true,
    text: {
      "en": "I enjoy thinking about new possibilities.",
      "th": "ฉันชอบคิดถึงความเป็นไปได้ใหม่ ๆ",
    },
    options: likert5,
  ),

  /// T / F
  TestQuestion(
    id: "mbti_acc_41",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I prioritize logic when making decisions.",
      "th": "เวลาตัดสินใจ ฉันให้ความสำคัญกับเหตุผลเป็นหลัก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_42",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "I consider people's feelings first.",
      "th": "ฉันมักคำนึงถึงความรู้สึกของคนอื่นก่อน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_43",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "Objective analysis is important to me.",
      "th": "การวิเคราะห์อย่างเป็นกลางเป็นสิ่งสำคัญสำหรับฉัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_44",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "Harmony between people matters most.",
      "th": "ความสัมพันธ์ที่ดีระหว่างผู้คนเป็นสิ่งสำคัญที่สุด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_45",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I value fairness over compassion.",
      "th": "ฉันให้ความสำคัญกับความยุติธรรมมากกว่าความเห็นใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_46",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "I easily empathize with others.",
      "th": "ฉันเข้าใจความรู้สึกของคนอื่นได้ง่าย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_47",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I prefer logical debates.",
      "th": "ฉันชอบการถกเถียงหรือแลกเปลี่ยนความคิดเห็นด้วยเหตุผล",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_48",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "I try to avoid hurting others.",
      "th": "ฉันพยายามหลีกเลี่ยงการทำร้ายความรู้สึกของคนอื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_49",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "Efficiency matters more than emotions.",
      "th": "ประสิทธิภาพของงานสำคัญกว่าอารมณ์ความรู้สึก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_50",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "Kindness should guide decisions.",
      "th": "ความเมตตาควรเป็นสิ่งที่ช่วยนำทางการตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_51",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I analyze problems objectively.",
      "th": "ฉันวิเคราะห์ปัญหาโดยใช้เหตุผลและความเป็นกลาง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_52",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "I prioritize compassion.",
      "th": "ฉันให้ความสำคัญกับความเห็นอกเห็นใจผู้อื่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_53",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I rely on logic under pressure.",
      "th": "เมื่ออยู่ภายใต้ความกดดัน ฉันยังคงใช้เหตุผลในการตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_54",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "Emotions influence my decisions.",
      "th": "อารมณ์มีผลต่อการตัดสินใจของฉัน",
    },
    options: likert5,
  ),
  TestQuestion(
    id: "mbti_acc_55",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "Logical consistency matters.",
      "th": "ความสอดคล้องและเหตุผลที่ชัดเจนเป็นสิ่งสำคัญสำหรับฉัน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_56",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "People's feelings should be considered.",
      "th": "ควรคำนึงถึงความรู้สึกของผู้คนเมื่อทำการตัดสินใจ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_57",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "I like solving logical puzzles.",
      "th": "ฉันชอบแก้ปัญหาหรือปริศนาที่ต้องใช้เหตุผล",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_58",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "I care deeply about others.",
      "th": "ฉันใส่ใจความรู้สึกของผู้อื่นอย่างลึกซึ้ง",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_59",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: false,
    text: {
      "en": "Clear logic convinces me.",
      "th": "เหตุผลที่ชัดเจนทำให้ฉันเชื่อหรือยอมรับได้ง่าย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_60",
    moduleId: "mbti_accurate",
    trait: "T",
    reverse: true,
    text: {
      "en": "Emotional understanding is essential.",
      "th": "การเข้าใจความรู้สึกของผู้อื่นเป็นสิ่งสำคัญ",
    },
    options: likert5,
  ),

  /// J / P
  TestQuestion(
    id: "mbti_acc_61",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I like planning things ahead.",
      "th": "ฉันชอบวางแผนสิ่งต่าง ๆ ล่วงหน้า",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_62",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I enjoy spontaneous decisions.",
      "th": "ฉันชอบการตัดสินใจแบบทันทีโดยไม่ต้องวางแผนมาก",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_63",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I feel satisfied finishing tasks early.",
      "th": "ฉันรู้สึกพอใจเมื่อทำงานเสร็จก่อนเวลา",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_64",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I adapt easily to last-minute changes.",
      "th": "ฉันสามารถปรับตัวกับการเปลี่ยนแปลงแบบกะทันหันได้ง่าย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_65",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I like organized environments.",
      "th": "ฉันชอบสภาพแวดล้อมที่เป็นระเบียบเรียบร้อย",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_66",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I prefer flexibility over structure.",
      "th": "ฉันชอบความยืดหยุ่นมากกว่าการมีโครงสร้างตายตัว",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_67",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I make to-do lists often.",
      "th": "ฉันมักทำรายการสิ่งที่ต้องทำ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_68",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I go with the flow.",
      "th": "ฉันมักปล่อยให้สิ่งต่าง ๆ เป็นไปตามสถานการณ์",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_69",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "Deadlines motivate me.",
      "th": "กำหนดเวลาช่วยกระตุ้นให้ฉันทำงาน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_70",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "Strict schedules feel limiting.",
      "th": "ตารางเวลาที่เข้มงวดทำให้ฉันรู้สึกอึดอัด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_71",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {"en": "I like clear plans.", "th": "ฉันชอบแผนที่ชัดเจนและเป็นระบบ"},
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_72",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I enjoy keeping things open-ended.",
      "th": "ฉันชอบปล่อยให้สิ่งต่าง ๆ เปิดกว้างและยืดหยุ่น",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_73",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I prefer finishing work before relaxing.",
      "th": "ฉันชอบทำงานให้เสร็จก่อนแล้วค่อยพักผ่อน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_74",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I act spontaneously.",
      "th": "ฉันมักทำสิ่งต่าง ๆ แบบทันทีโดยไม่ต้องคิดหรือวางแผนนาน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_75",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I enjoy organized schedules.",
      "th": "ฉันชอบตารางเวลาที่มีการจัดระเบียบชัดเจน",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_76",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I adapt plans frequently.",
      "th": "ฉันเปลี่ยนแผนได้บ่อยตามสถานการณ์",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_77",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "Structure helps me stay productive.",
      "th": "การมีโครงสร้างหรือระบบช่วยให้ฉันทำงานได้มีประสิทธิภาพ",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_78",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I prefer freedom over strict plans.",
      "th": "ฉันชอบอิสระมากกว่าแผนที่เข้มงวด",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_79",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: false,
    text: {
      "en": "I enjoy checking tasks off a list.",
      "th": "ฉันรู้สึกดีเมื่อทำเครื่องหมายว่างานในรายการเสร็จแล้ว",
    },
    options: likert5,
  ),

  TestQuestion(
    id: "mbti_acc_80",
    moduleId: "mbti_accurate",
    trait: "J",
    reverse: true,
    text: {
      "en": "I prefer improvising instead of planning.",
      "th": "ฉันชอบปรับตัวตามสถานการณ์มากกว่าการวางแผนล่วงหน้า",
    },
    options: likert5,
  ),
];
