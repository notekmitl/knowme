import 'package:knowme/domain/models/test_module.dart';
import 'package:knowme/domain/models/test_question.dart';

final List<TestQuestion> bfi44Questions = [
  /// EXTRAVERSION
  TestQuestion(
    id: "BFI1",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is talkative",
      "th": "ฉันเป็นคนช่างพูด",
    },
    trait: "extraversion",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI2",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who tends to be reserved",
      "th": "ฉันเป็นคนค่อนข้างเก็บตัว",
    },
    trait: "extraversion",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI3",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is full of energy",
      "th": "ฉันเป็นคนมีพลังและกระตือรือร้น",
    },
    trait: "extraversion",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI4",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who generates enthusiasm",
      "th": "ฉันมักสร้างความคึกคักให้กับคนรอบตัว",
    },
    trait: "extraversion",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI5",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who tends to be quiet",
      "th": "ฉันมักเป็นคนเงียบ ๆ",
    },
    trait: "extraversion",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI26",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is outgoing and sociable",
      "th": "ฉันเป็นคนเข้าสังคมง่าย",
    },
    trait: "extraversion",
    reverse: false,
  ),

  /// AGREEABLENESS
  TestQuestion(
    id: "BFI6",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is helpful and unselfish",
      "th": "ฉันเป็นคนช่วยเหลือผู้อื่นโดยไม่หวังผลตอบแทน",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI7",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who starts quarrels with others",
      "th": "ฉันมักมีปากเสียงหรือทะเลาะกับคนอื่น",
    },
    trait: "agreeableness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI8",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who has a forgiving nature",
      "th": "ฉันเป็นคนให้อภัยผู้อื่นได้ง่าย",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI9",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is generally trusting",
      "th": "ฉันมักเชื่อใจผู้อื่น",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI10",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be cold or distant",
      "th": "บางครั้งฉันอาจดูเย็นชา",
    },
    trait: "agreeableness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI27",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be rude to others",
      "th": "บางครั้งฉันอาจพูดจาไม่สุภาพกับผู้อื่น",
    },
    trait: "agreeableness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI28",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who likes to cooperate with others",
      "th": "ฉันชอบทำงานร่วมกับผู้อื่น",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI29",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be critical of others",
      "th": "ฉันมักวิจารณ์ผู้อื่น",
    },
    trait: "agreeableness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI30",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is considerate and kind",
      "th": "ฉันเป็นคนใจดีและเอาใจใส่ผู้อื่น",
    },
    trait: "agreeableness",
    reverse: false,
  ),

  /// CONSCIENTIOUSNESS
  TestQuestion(
    id: "BFI11",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who does a thorough job",
      "th": "ฉันเป็นคนทำงานอย่างละเอียดรอบคอบ",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI12",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be careless",
      "th": "บางครั้งฉันอาจทำงานสะเพร่า",
    },
    trait: "conscientiousness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI13",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is a reliable worker",
      "th": "ฉันเป็นคนที่ทำงานแล้วคนอื่นไว้ใจได้",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI14",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who tends to be disorganized",
      "th": "ฉันมักจัดการสิ่งต่าง ๆ ไม่ค่อยเป็นระเบียบ",
    },
    trait: "conscientiousness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI15",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who makes plans and follows them",
      "th": "ฉันมักวางแผนและทำตามแผนที่ตั้งไว้",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI31",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is dependable",
      "th": "ฉันเป็นคนที่พึ่งพาได้",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI32",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who tends to be lazy",
      "th": "ฉันมีแนวโน้มที่จะขี้เกียจ",
    },
    trait: "conscientiousness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI33",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who keeps working until tasks are done",
      "th": "ฉันพยายามทำงานจนเสร็จ",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI34",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who works efficiently",
      "th": "ฉันเป็นคนทำงานอย่างมีประสิทธิภาพ",
    },
    trait: "conscientiousness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI35",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be careless",
      "th": "ฉันมีแนวโน้มทำสิ่งต่าง ๆ แบบไม่ระวัง",
    },
    trait: "conscientiousness",
    reverse: true,
  ),

  /// NEUROTICISM
  TestQuestion(
    id: "BFI16",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who worries a lot",
      "th": "ฉันเป็นคนกังวลง่าย",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI17",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who handles stress well",
      "th": "ฉันรับมือกับความเครียดได้ดี",
    },
    trait: "neuroticism",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI18",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who gets nervous easily",
      "th": "ฉันประหม่าได้ง่าย",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI19",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who stays calm in tense situations",
      "th": "ฉันยังคงสงบในสถานการณ์กดดัน",
    },
    trait: "neuroticism",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI20",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who gets upset easily",
      "th": "ฉันอารมณ์เสียได้ง่าย",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI36",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who often feels tense",
      "th": "ฉันมักรู้สึกตึงเครียด",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI37",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is emotionally stable",
      "th": "ฉันเป็นคนที่อารมณ์มั่นคง",
    },
    trait: "neuroticism",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI38",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who can be moody",
      "th": "ฉันอารมณ์เปลี่ยนง่าย",
    },
    trait: "neuroticism",
    reverse: false,
  ),

  /// OPENNESS
  TestQuestion(
    id: "BFI21",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is curious about many things",
      "th": "ฉันอยากรู้อยากเห็นสิ่งต่าง ๆ",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI22",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is a deep thinker",
      "th": "ฉันเป็นคนคิดลึก",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI23",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who has an active imagination",
      "th": "ฉันมีจินตนาการสูง",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI24",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who values art and beauty",
      "th": "ฉันให้คุณค่ากับศิลปะและความสวยงาม",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI25",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who prefers routine work",
      "th": "ฉันชอบทำสิ่งเดิม ๆ เป็นประจำ",
    },
    trait: "openness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI39",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who comes up with new ideas",
      "th": "ฉันมักมีไอเดียใหม่ ๆ",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI40",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who enjoys aesthetic experiences",
      "th": "ฉันชอบประสบการณ์ด้านศิลปะและความงาม",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI41",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who prefers conventional ideas",
      "th": "ฉันชอบแนวคิดแบบเดิมมากกว่า",
    },
    trait: "openness",
    reverse: true,
  ),

  TestQuestion(
    id: "BFI42",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who is curious about many topics",
      "th": "ฉันสนใจเรียนรู้หลายเรื่อง",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI43",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who reflects deeply",
      "th": "ฉันชอบคิดใคร่ครวญอย่างลึกซึ้ง",
    },
    trait: "openness",
    reverse: false,
  ),

  TestQuestion(
    id: "BFI44",
    moduleId: "bigfive",
    text: {
      "en": "I see myself as someone who has few artistic interests",
      "th": "ฉันไม่ค่อยสนใจเรื่องศิลปะ",
    },
    trait: "openness",
    reverse: true,
  ),
];
