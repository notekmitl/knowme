import '../../domain/models/mbti_type.dart';

final Map<String, MbtiType> mbtiTypes = {
  "INTJ": MbtiType(
    type: "INTJ",

    title: {"en": "Architect", "th": "นักวางกลยุทธ์"},

    description: {
      "en":
          "Strategic thinkers who love complex problems and long-term planning.",
      "th": "นักคิดเชิงกลยุทธ์ที่ชอบแก้ปัญหาซับซ้อนและวางแผนระยะยาว",
    },

    strengths: [
      {"en": "Strategic thinking", "th": "คิดเชิงกลยุทธ์"},
      {"en": "Independent", "th": "เป็นอิสระ"},
      {"en": "Analytical", "th": "วิเคราะห์เก่ง"},
      {"en": "Visionary", "th": "มองภาพอนาคตได้ดี"},
    ],

    weaknesses: [
      {"en": "Overly critical", "th": "วิจารณ์มากเกินไป"},
      {"en": "Impatient", "th": "ใจร้อน"},
      {"en": "Perfectionist", "th": "สมบูรณ์แบบเกินไป"},
    ],

    careers: [
      {"en": "Scientist", "th": "นักวิทยาศาสตร์"},
      {"en": "Engineer", "th": "วิศวกร"},
      {"en": "Strategist", "th": "นักวางกลยุทธ์"},
      {"en": "Architect", "th": "สถาปนิก"},
    ],

    relationships: [
      {
        "en": "Values intellectual connection",
        "th": "ให้ความสำคัญกับการเชื่อมต่อทางความคิด",
      },
      {"en": "Prefers deep conversations", "th": "ชอบการสนทนาที่ลึกซึ้ง"},
    ],
  ),

  "INTP": MbtiType(
    type: "INTP",

    title: {"en": "Thinker", "th": "นักคิด"},

    description: {
      "en": "Curious analysts who enjoy exploring theories and ideas.",
      "th": "นักวิเคราะห์ที่อยากรู้อยากเห็นและชอบสำรวจแนวคิดใหม่",
    },

    strengths: [
      {"en": "Logical", "th": "มีตรรกะ"},
      {"en": "Curious", "th": "อยากรู้อยากเห็น"},
      {"en": "Creative thinker", "th": "คิดสร้างสรรค์"},
      {"en": "Analytical", "th": "วิเคราะห์เก่ง"},
    ],

    weaknesses: [
      {"en": "Overthinking", "th": "คิดมาก"},
      {"en": "Detached", "th": "ดูห่างเหิน"},
      {"en": "Procrastination", "th": "ผัดวันประกันพรุ่ง"},
    ],

    careers: [
      {"en": "Researcher", "th": "นักวิจัย"},
      {"en": "Programmer", "th": "โปรแกรมเมอร์"},
      {"en": "Data scientist", "th": "นักวิเคราะห์ข้อมูล"},
      {"en": "Philosopher", "th": "นักปรัชญา"},
    ],

    relationships: [
      {
        "en": "Needs intellectual partner",
        "th": "ต้องการคู่ที่เข้าใจทางความคิด",
      },
      {"en": "Values independence", "th": "ให้ความสำคัญกับอิสระ"},
    ],
  ),

  "ENTJ": MbtiType(
    type: "ENTJ",

    title: {"en": "Commander", "th": "ผู้นำ"},

    description: {
      "en": "Bold leaders who enjoy organizing people and resources.",
      "th": "ผู้นำที่กล้าหาญและชอบจัดการผู้คนและทรัพยากร",
    },

    strengths: [
      {"en": "Leadership", "th": "ความเป็นผู้นำ"},
      {"en": "Confidence", "th": "มั่นใจ"},
      {"en": "Strategic", "th": "วางแผนเก่ง"},
      {"en": "Efficient", "th": "มีประสิทธิภาพ"},
    ],

    weaknesses: [
      {"en": "Dominating", "th": "ควบคุมมากเกินไป"},
      {"en": "Impatient", "th": "ใจร้อน"},
      {"en": "Insensitive", "th": "ไม่ค่อยสนใจความรู้สึกผู้อื่น"},
    ],

    careers: [
      {"en": "CEO", "th": "ผู้บริหาร"},
      {"en": "Entrepreneur", "th": "ผู้ประกอบการ"},
      {"en": "Manager", "th": "ผู้จัดการ"},
      {"en": "Consultant", "th": "ที่ปรึกษา"},
    ],

    relationships: [
      {"en": "Values ambition", "th": "ชอบคนมีเป้าหมาย"},
      {"en": "Supports partner growth", "th": "สนับสนุนการเติบโตของคู่"},
    ],
  ),

  "ENTP": MbtiType(
    type: "ENTP",

    title: {"en": "Debater", "th": "นักโต้วาที"},

    description: {
      "en": "Innovative thinkers who enjoy intellectual challenges.",
      "th": "นักคิดที่สร้างสรรค์และชอบการท้าทายทางความคิด",
    },

    strengths: [
      {"en": "Creative", "th": "สร้างสรรค์"},
      {"en": "Quick thinker", "th": "คิดเร็ว"},
      {"en": "Charismatic", "th": "มีเสน่ห์"},
      {"en": "Innovative", "th": "ชอบนวัตกรรม"},
    ],

    weaknesses: [
      {"en": "Argumentative", "th": "ชอบโต้แย้ง"},
      {"en": "Easily bored", "th": "เบื่อง่าย"},
      {"en": "Impulsive", "th": "หุนหันพลันแล่น"},
    ],

    careers: [
      {"en": "Entrepreneur", "th": "ผู้ประกอบการ"},
      {"en": "Inventor", "th": "นักประดิษฐ์"},
      {"en": "Marketing strategist", "th": "นักการตลาด"},
      {"en": "Consultant", "th": "ที่ปรึกษา"},
    ],

    relationships: [
      {"en": "Needs excitement", "th": "ต้องการความตื่นเต้น"},
      {"en": "Enjoys intellectual debates", "th": "ชอบการแลกเปลี่ยนความคิด"},
    ],
  ),

  /// ตัวอย่างต่อไปจะใช้โครงสร้างเดียวกัน
  /// ด้านล่างคือ type ที่เหลือทั้งหมด
  "INFJ": MbtiType(
    type: "INFJ",
    title: {"en": "Advocate", "th": "ผู้สนับสนุน"},
    description: {
      "en": "Insightful and inspiring idealists.",
      "th": "ผู้มองโลกเชิงอุดมคติที่เข้าใจผู้คน",
    },
    strengths: [
      {"en": "Empathetic", "th": "เข้าใจผู้อื่น"},
      {"en": "Insightful", "th": "มีสัญชาตญาณดี"},
      {"en": "Creative", "th": "สร้างสรรค์"},
    ],
    weaknesses: [
      {"en": "Sensitive", "th": "อ่อนไหว"},
      {"en": "Perfectionist", "th": "สมบูรณ์แบบเกินไป"},
    ],
    careers: [
      {"en": "Psychologist", "th": "นักจิตวิทยา"},
      {"en": "Writer", "th": "นักเขียน"},
      {"en": "Counselor", "th": "ที่ปรึกษา"},
    ],
    relationships: [
      {"en": "Deep emotional connection", "th": "ต้องการความสัมพันธ์ลึกซึ้ง"},
    ],
  ),

  "INFP": MbtiType(
    type: "INFP",
    title: {"en": "Mediator", "th": "ผู้ไกล่เกลี่ย"},
    description: {
      "en": "Idealistic and compassionate dreamers.",
      "th": "นักฝันที่มีความเห็นอกเห็นใจ",
    },
    strengths: [
      {"en": "Creative", "th": "สร้างสรรค์"},
      {"en": "Empathetic", "th": "เข้าใจผู้อื่น"},
    ],
    weaknesses: [
      {"en": "Overly idealistic", "th": "อุดมคติมากเกินไป"},
    ],
    careers: [
      {"en": "Artist", "th": "ศิลปิน"},
      {"en": "Writer", "th": "นักเขียน"},
    ],
    relationships: [
      {"en": "Seeks authentic love", "th": "ต้องการรักแท้"},
    ],
  ),

  "ENFJ": MbtiType(
    type: "ENFJ",
    title: {"en": "Protagonist", "th": "ผู้นำทางสังคม"},
    description: {
      "en": "Charismatic leaders focused on helping others.",
      "th": "ผู้นำที่มีเสน่ห์และช่วยเหลือผู้อื่น",
    },
    strengths: [
      {"en": "Leadership", "th": "ความเป็นผู้นำ"},
      {"en": "Empathy", "th": "เข้าใจผู้อื่น"},
    ],
    weaknesses: [
      {"en": "People pleasing", "th": "เอาใจคนมากเกินไป"},
    ],
    careers: [
      {"en": "Teacher", "th": "ครู"},
      {"en": "Coach", "th": "โค้ช"},
    ],
    relationships: [
      {"en": "Supportive partner", "th": "คู่ที่สนับสนุน"},
    ],
  ),

  "ENFP": MbtiType(
    type: "ENFP",
    title: {"en": "Campaigner", "th": "นักรณรงค์"},
    description: {
      "en": "Enthusiastic and imaginative free spirits.",
      "th": "ผู้มีพลังและจินตนาการ",
    },
    strengths: [
      {"en": "Energetic", "th": "มีพลัง"},
      {"en": "Creative", "th": "สร้างสรรค์"},
    ],
    weaknesses: [
      {"en": "Distracted easily", "th": "วอกแวกง่าย"},
    ],
    careers: [
      {"en": "Marketing", "th": "การตลาด"},
      {"en": "Performer", "th": "นักแสดง"},
    ],
    relationships: [
      {"en": "Passionate", "th": "รักอย่างมีพลัง"},
    ],
  ),

  /// S Types
  "ISTJ": MbtiType(
    type: "ISTJ",
    title: {"en": "Logistician", "th": "นักจัดระบบ"},
    description: {
      "en": "Responsible and detail-oriented planners.",
      "th": "ผู้วางแผนที่มีระเบียบ",
    },
    strengths: [
      {"en": "Reliable", "th": "เชื่อถือได้"},
      {"en": "Organized", "th": "เป็นระเบียบ"},
    ],
    weaknesses: [
      {"en": "Rigid", "th": "ยืดหยุ่นน้อย"},
    ],
    careers: [
      {"en": "Accountant", "th": "นักบัญชี"},
      {"en": "Administrator", "th": "ผู้บริหารงาน"},
    ],
    relationships: [
      {"en": "Loyal partner", "th": "ซื่อสัตย์ต่อคู่"},
    ],
  ),

  "ISFJ": MbtiType(
    type: "ISFJ",
    title: {"en": "Defender", "th": "ผู้ปกป้อง"},
    description: {
      "en": "Warm protectors who value tradition.",
      "th": "ผู้ดูแลที่อบอุ่น",
    },
    strengths: [
      {"en": "Supportive", "th": "สนับสนุนผู้อื่น"},
      {"en": "Reliable", "th": "เชื่อถือได้"},
    ],
    weaknesses: [
      {"en": "Overcommitted", "th": "รับภาระมากเกินไป"},
    ],
    careers: [
      {"en": "Nurse", "th": "พยาบาล"},
      {"en": "Teacher", "th": "ครู"},
    ],
    relationships: [
      {"en": "Caring partner", "th": "ดูแลคู่รักดี"},
    ],
  ),

  "ESTJ": MbtiType(
    type: "ESTJ",
    title: {"en": "Executive", "th": "ผู้บริหาร"},
    description: {
      "en": "Organized leaders who value structure.",
      "th": "ผู้นำที่มีระบบ",
    },
    strengths: [
      {"en": "Leadership", "th": "ผู้นำ"},
      {"en": "Efficient", "th": "มีประสิทธิภาพ"},
    ],
    weaknesses: [
      {"en": "Stubborn", "th": "ดื้อ"},
    ],
    careers: [
      {"en": "Manager", "th": "ผู้จัดการ"},
      {"en": "Administrator", "th": "ผู้บริหาร"},
    ],
    relationships: [
      {"en": "Stable partner", "th": "คู่ที่มั่นคง"},
    ],
  ),

  "ESFJ": MbtiType(
    type: "ESFJ",
    title: {"en": "Consul", "th": "ผู้ดูแลสังคม"},
    description: {
      "en": "Caring social organizers.",
      "th": "ผู้ดูแลสังคมที่อบอุ่น",
    },
    strengths: [
      {"en": "Friendly", "th": "เป็นมิตร"},
      {"en": "Supportive", "th": "สนับสนุนผู้อื่น"},
    ],
    weaknesses: [
      {"en": "Needs approval", "th": "ต้องการการยอมรับ"},
    ],
    careers: [
      {"en": "HR", "th": "ทรัพยากรบุคคล"},
      {"en": "Teacher", "th": "ครู"},
    ],
    relationships: [
      {"en": "Warm partner", "th": "คู่ที่อบอุ่น"},
    ],
  ),

  "ISTP": MbtiType(
    type: "ISTP",
    title: {"en": "Virtuoso", "th": "นักปฏิบัติ"},
    description: {
      "en": "Practical experimenters who love tools.",
      "th": "นักทดลองเชิงปฏิบัติ",
    },
    strengths: [
      {"en": "Practical", "th": "ปฏิบัติจริง"},
      {"en": "Calm under pressure", "th": "นิ่งภายใต้แรงกดดัน"},
    ],
    weaknesses: [
      {"en": "Risk-taking", "th": "ชอบเสี่ยง"},
    ],
    careers: [
      {"en": "Engineer", "th": "วิศวกร"},
      {"en": "Mechanic", "th": "ช่างเทคนิค"},
    ],
    relationships: [
      {"en": "Needs freedom", "th": "ต้องการอิสระ"},
    ],
  ),

  "ISFP": MbtiType(
    type: "ISFP",
    title: {"en": "Adventurer", "th": "นักผจญภัย"},
    description: {
      "en": "Gentle artists who love beauty.",
      "th": "ศิลปินผู้รักอิสระ",
    },
    strengths: [
      {"en": "Creative", "th": "สร้างสรรค์"},
      {"en": "Sensitive", "th": "อ่อนไหว"},
    ],
    weaknesses: [
      {"en": "Avoids conflict", "th": "หลีกเลี่ยงความขัดแย้ง"},
    ],
    careers: [
      {"en": "Artist", "th": "ศิลปิน"},
      {"en": "Designer", "th": "นักออกแบบ"},
    ],
    relationships: [
      {"en": "Affectionate partner", "th": "คู่รักที่อ่อนโยน"},
    ],
  ),

  "ESTP": MbtiType(
    type: "ESTP",
    title: {"en": "Entrepreneur", "th": "นักเสี่ยง"},
    description: {
      "en": "Energetic thrill-seekers.",
      "th": "ผู้รักความตื่นเต้น",
    },
    strengths: [
      {"en": "Energetic", "th": "มีพลัง"},
      {"en": "Bold", "th": "กล้า"},
    ],
    weaknesses: [
      {"en": "Impulsive", "th": "หุนหันพลันแล่น"},
    ],
    careers: [
      {"en": "Sales", "th": "การขาย"},
      {"en": "Entrepreneur", "th": "ผู้ประกอบการ"},
    ],
    relationships: [
      {"en": "Exciting partner", "th": "คู่ที่สนุก"},
    ],
  ),

  "ESFP": MbtiType(
    type: "ESFP",
    title: {"en": "Entertainer", "th": "นักสร้างความสนุก"},
    description: {
      "en": "Fun-loving performers who enjoy life.",
      "th": "ผู้สร้างสีสันให้สังคม",
    },
    strengths: [
      {"en": "Friendly", "th": "เป็นมิตร"},
      {"en": "Energetic", "th": "มีพลัง"},
    ],
    weaknesses: [
      {"en": "Attention-seeking", "th": "ต้องการความสนใจ"},
    ],
    careers: [
      {"en": "Performer", "th": "นักแสดง"},
      {"en": "Event organizer", "th": "ผู้จัดงาน"},
    ],
    relationships: [
      {"en": "Romantic", "th": "โรแมนติก"},
    ],
  ),
};
