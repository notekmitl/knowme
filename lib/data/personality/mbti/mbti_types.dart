import '../../../domain/models/personality/mbti_type_profile.dart';

final Map<String, MbtiTypeProfile> mbtiTypes = {
  "INTJ": MbtiTypeProfile(
    name: {"en": "INTJ", "th": "INTJ"},

    nickname: {"en": "The Architect", "th": "นักวางกลยุทธ์"},

    description: {
      "en":
          "INTJs are strategic thinkers who enjoy understanding complex systems and planning for the future. They tend to see patterns quickly and often think several steps ahead.",

      "th":
          "INTJ เป็นคนที่คิดเชิงกลยุทธ์ ชอบทำความเข้าใจระบบที่ซับซ้อน และมองไปข้างหน้าเสมอ พวกเขามักเห็นรูปแบบหรือแนวโน้มก่อนคนอื่น",
    },

    strengths: {
      "en":
          "Strategic thinking, independence, strong analytical ability, long-term planning.",

      "th":
          "คิดเชิงกลยุทธ์เก่ง วิเคราะห์ลึก วางแผนระยะยาวได้ดี และมีความเป็นอิสระสูง",
    },

    weaknesses: {
      "en":
          "Can appear distant, overly critical, and impatient with inefficiency.",

      "th":
          "บางครั้งอาจดูห่างเหิน วิจารณ์มากเกินไป หรือหงุดหงิดกับความไม่มีประสิทธิภาพ",
    },

    careers: {
      "en": "Scientist, engineer, strategist, software architect, researcher.",

      "th": "นักวิจัย วิศวกร นักวางกลยุทธ์ นักพัฒนาซอฟต์แวร์ นักวิเคราะห์ระบบ",
    },

    relationships: {
      "en":
          "INTJs value deep intellectual connections. They may not express emotions frequently but tend to show care through actions.",

      "th":
          "INTJ ให้ความสำคัญกับความสัมพันธ์ที่ลึกซึ้งทางความคิด แม้จะไม่แสดงอารมณ์บ่อย แต่จะแสดงความใส่ใจผ่านการกระทำ",
    },
  ),

  // ------------------------------------------------------------
  "INFJ": MbtiTypeProfile(
    name: {"en": "INFJ", "th": "INFJ"},

    nickname: {"en": "The Advocate", "th": "ผู้ให้คำปรึกษา"},

    description: {
      "en":
          "INFJs are insightful and idealistic individuals who seek meaning and purpose in life. They often understand people's emotions deeply.",

      "th":
          "INFJ เป็นคนที่มีความเข้าใจลึกซึ้ง ชอบค้นหาความหมายของชีวิต และเข้าใจความรู้สึกของผู้คนได้ดี",
    },

    strengths: {
      "en": "Empathy, insight, creativity, strong intuition.",

      "th":
          "เข้าใจผู้อื่นดี มีสัญชาตญาณสูง มีความคิดสร้างสรรค์ และมองเห็นภาพรวมของผู้คน",
    },

    weaknesses: {
      "en":
          "May become overwhelmed by others' emotions and struggle with boundaries.",

      "th": "อาจรับอารมณ์ของคนอื่นมากเกินไป และมีปัญหาในการตั้งขอบเขต",
    },

    careers: {
      "en": "Psychologist, counselor, writer, teacher, social worker.",

      "th": "นักจิตวิทยา ที่ปรึกษา นักเขียน ครู นักสังคมสงเคราะห์",
    },

    relationships: {
      "en": "INFJs seek meaningful and emotionally deep relationships.",

      "th": "INFJ มองหาความสัมพันธ์ที่ลึกซึ้งและจริงใจ",
    },
  ),

  // ------------------------------------------------------------
  "ENTJ": MbtiTypeProfile(
    name: {"en": "ENTJ", "th": "ENTJ"},

    nickname: {"en": "The Commander", "th": "ผู้นำ"},

    description: {
      "en":
          "ENTJs are natural leaders who enjoy organizing systems and people to achieve ambitious goals.",

      "th":
          "ENTJ เป็นผู้นำโดยธรรมชาติ ชอบจัดระบบและนำทีมเพื่อบรรลุเป้าหมายที่ท้าทาย",
    },

    strengths: {
      "en": "Leadership, strategic planning, decisiveness, efficiency.",

      "th": "ภาวะผู้นำสูง วางกลยุทธ์เก่ง ตัดสินใจเด็ดขาด และเน้นประสิทธิภาพ",
    },

    weaknesses: {
      "en": "May appear too direct, controlling, or impatient.",

      "th": "บางครั้งอาจตรงเกินไป ควบคุมมากเกินไป หรือใจร้อน",
    },

    careers: {
      "en": "CEO, entrepreneur, manager, strategist, executive.",

      "th": "ผู้บริหาร ผู้ประกอบการ ผู้จัดการ นักวางกลยุทธ์",
    },

    relationships: {
      "en": "ENTJs respect competence and loyalty in relationships.",

      "th": "ENTJ ให้ความสำคัญกับความสามารถและความภักดีในความสัมพันธ์",
    },
  ),

  // ------------------------------------------------------------
  "ENFJ": MbtiTypeProfile(
    name: {"en": "ENFJ", "th": "ENFJ"},

    nickname: {"en": "The Protagonist", "th": "ผู้นำที่สร้างแรงบันดาลใจ"},

    description: {
      "en": "ENFJs are charismatic individuals who inspire and support others.",

      "th": "ENFJ เป็นคนที่มีเสน่ห์และสามารถสร้างแรงบันดาลใจให้กับผู้อื่น",
    },

    strengths: {
      "en": "Empathy, leadership, communication, inspiration.",

      "th": "เข้าใจผู้อื่นดี สื่อสารเก่ง เป็นผู้นำ และสร้างแรงบันดาลใจ",
    },

    weaknesses: {
      "en": "May neglect their own needs while helping others.",

      "th": "อาจละเลยความต้องการของตัวเองเพื่อช่วยเหลือผู้อื่น",
    },

    careers: {
      "en": "Teacher, coach, leader, counselor, HR.",

      "th": "ครู โค้ช ผู้นำองค์กร ที่ปรึกษา HR",
    },

    relationships: {
      "en": "ENFJs thrive in supportive and emotionally open relationships.",

      "th": "ENFJ ต้องการความสัมพันธ์ที่เปิดเผยและสนับสนุนกัน",
    },
  ),

  // ------------------------------------------------------------
  "INFP": MbtiTypeProfile(
    name: {"en": "INFP", "th": "INFP"},

    nickname: {"en": "The Mediator", "th": "นักอุดมคติ"},

    description: {
      "en":
          "INFPs are idealistic and deeply thoughtful individuals. They care strongly about personal values and often seek meaning and authenticity in everything they do.",

      "th":
          "INFP เป็นคนที่มีอุดมคติสูงและคิดลึก พวกเขาให้ความสำคัญกับคุณค่าและความหมายของชีวิต และมักพยายามทำสิ่งที่สอดคล้องกับความเชื่อของตนเอง",
    },

    strengths: {
      "en": "Empathy, creativity, authenticity, strong personal values.",

      "th":
          "เข้าใจผู้อื่นดี มีความคิดสร้างสรรค์ ซื่อสัตย์ต่อความรู้สึก และมีคุณค่าภายในที่ชัดเจน",
    },

    weaknesses: {
      "en": "May become overly idealistic or sensitive to criticism.",

      "th": "บางครั้งอาจมีอุดมคติสูงเกินไป หรืออ่อนไหวต่อคำวิจารณ์",
    },

    careers: {
      "en": "Writer, artist, counselor, psychologist, designer.",

      "th": "นักเขียน ศิลปิน นักจิตวิทยา ที่ปรึกษา นักออกแบบ",
    },

    relationships: {
      "en":
          "INFPs seek deep emotional connections and meaningful relationships.",

      "th": "INFP มองหาความสัมพันธ์ที่ลึกซึ้ง จริงใจ และมีความหมาย",
    },
  ),

  // ------------------------------------------------------------
  "INTP": MbtiTypeProfile(
    name: {"en": "INTP", "th": "INTP"},

    nickname: {"en": "The Thinker", "th": "นักวิเคราะห์"},

    description: {
      "en":
          "INTPs are analytical thinkers who enjoy exploring ideas and understanding how systems work. They are curious and often question assumptions.",

      "th":
          "INTP เป็นนักคิดที่ชอบวิเคราะห์ ชอบสำรวจแนวคิดใหม่ ๆ และทำความเข้าใจว่าระบบต่าง ๆ ทำงานอย่างไร",
    },

    strengths: {
      "en": "Analytical thinking, curiosity, logical reasoning, innovation.",

      "th": "คิดวิเคราะห์เก่ง ช่างสงสัย มีตรรกะ และคิดนวัตกรรมได้ดี",
    },

    weaknesses: {
      "en": "May appear detached or struggle with routine tasks.",

      "th": "บางครั้งอาจดูห่างเหิน หรือไม่ชอบงานที่ซ้ำซาก",
    },

    careers: {
      "en": "Scientist, programmer, researcher, analyst.",

      "th": "นักวิทยาศาสตร์ โปรแกรมเมอร์ นักวิจัย นักวิเคราะห์ข้อมูล",
    },

    relationships: {
      "en": "INTPs value intellectual conversations and independence.",

      "th": "INTP ให้ความสำคัญกับการพูดคุยเชิงความคิดและอิสระส่วนตัว",
    },
  ),

  // ------------------------------------------------------------
  "ENFP": MbtiTypeProfile(
    name: {"en": "ENFP", "th": "ENFP"},

    nickname: {"en": "The Campaigner", "th": "นักสร้างแรงบันดาลใจ"},

    description: {
      "en":
          "ENFPs are energetic, creative, and enthusiastic individuals who enjoy exploring possibilities and inspiring others.",

      "th":
          "ENFP เป็นคนที่มีพลัง ความคิดสร้างสรรค์ และชอบสำรวจความเป็นไปได้ใหม่ ๆ พร้อมทั้งสร้างแรงบันดาลใจให้คนรอบตัว",
    },

    strengths: {
      "en": "Creativity, enthusiasm, communication, adaptability.",

      "th": "ความคิดสร้างสรรค์สูง กระตือรือร้น สื่อสารเก่ง และปรับตัวได้ดี",
    },

    weaknesses: {
      "en": "May struggle with focus or follow-through on long projects.",

      "th": "บางครั้งอาจมีปัญหาในการโฟกัสหรือทำงานระยะยาวให้เสร็จ",
    },

    careers: {
      "en": "Entrepreneur, marketer, performer, writer.",

      "th": "ผู้ประกอบการ นักการตลาด นักแสดง นักเขียน",
    },

    relationships: {
      "en": "ENFPs enjoy lively and emotionally expressive relationships.",

      "th": "ENFP ชอบความสัมพันธ์ที่มีพลัง สนุก และเปิดเผยความรู้สึก",
    },
  ),

  // ------------------------------------------------------------
  "ENTP": MbtiTypeProfile(
    name: {"en": "ENTP", "th": "ENTP"},

    nickname: {"en": "The Debater", "th": "นักคิดเชิงนวัตกรรม"},

    description: {
      "en":
          "ENTPs are curious and innovative thinkers who enjoy debating ideas and exploring new possibilities.",

      "th":
          "ENTP เป็นคนที่ช่างสงสัยและมีไอเดียใหม่ ๆ ชอบถกเถียงแนวคิดและสำรวจความเป็นไปได้",
    },

    strengths: {
      "en": "Innovation, quick thinking, creativity, debate skills.",

      "th": "คิดเร็ว มีนวัตกรรม ความคิดสร้างสรรค์สูง และถกเถียงเก่ง",
    },

    weaknesses: {
      "en": "May become argumentative or lose interest quickly.",

      "th": "บางครั้งอาจโต้แย้งมากเกินไป หรือเบื่อสิ่งต่าง ๆ ได้ง่าย",
    },

    careers: {
      "en": "Entrepreneur, innovator, strategist, consultant.",

      "th": "ผู้ประกอบการ นักนวัตกรรม นักกลยุทธ์ ที่ปรึกษา",
    },

    relationships: {
      "en":
          "ENTPs enjoy stimulating conversations and intellectually engaging partners.",

      "th": "ENTP ชอบคู่สนทนาที่ฉลาดและมีการแลกเปลี่ยนความคิด",
    },
  ),

  // ------------------------------------------------------------
  "ISFJ": MbtiTypeProfile(
    name: {"en": "ISFJ", "th": "ISFJ"},

    nickname: {"en": "The Protector", "th": "ผู้ดูแล"},

    description: {
      "en":
          "ISFJs are dependable and caring individuals who value stability and helping others. They often work quietly behind the scenes to support people around them.",

      "th":
          "ISFJ เป็นคนที่มีความรับผิดชอบสูง อบอุ่น และชอบช่วยเหลือผู้อื่น พวกเขามักทำงานอย่างเงียบ ๆ เพื่อดูแลคนรอบตัว",
    },

    strengths: {
      "en": "Loyalty, responsibility, empathy, attention to detail.",

      "th":
          "มีความรับผิดชอบสูง ซื่อสัตย์ ใส่ใจรายละเอียด และเข้าใจความรู้สึกผู้อื่น",
    },

    weaknesses: {
      "en": "May put others' needs before their own and avoid conflict.",

      "th": "อาจให้ความสำคัญกับคนอื่นมากกว่าตัวเอง และหลีกเลี่ยงความขัดแย้ง",
    },

    careers: {
      "en": "Nurse, teacher, administrator, healthcare worker.",

      "th": "พยาบาล ครู เจ้าหน้าที่บริหาร งานด้านสุขภาพ",
    },

    relationships: {
      "en": "ISFJs value loyalty and stability in relationships.",

      "th": "ISFJ ให้ความสำคัญกับความมั่นคงและความซื่อสัตย์ในความสัมพันธ์",
    },
  ),

  // ------------------------------------------------------------
  "ISTJ": MbtiTypeProfile(
    name: {"en": "ISTJ", "th": "ISTJ"},

    nickname: {"en": "The Logistician", "th": "นักจัดระบบ"},

    description: {
      "en":
          "ISTJs are practical and responsible individuals who value structure, rules, and reliability.",

      "th":
          "ISTJ เป็นคนที่มีระเบียบ ชอบความชัดเจน และให้ความสำคัญกับความรับผิดชอบ",
    },

    strengths: {
      "en": "Reliability, organization, discipline, practicality.",

      "th": "มีวินัยสูง จัดระบบเก่ง เชื่อถือได้ และปฏิบัติจริง",
    },

    weaknesses: {
      "en": "May resist change and appear overly rigid.",

      "th": "บางครั้งอาจไม่ชอบการเปลี่ยนแปลง และยึดติดกับกฎเกณฑ์มากเกินไป",
    },

    careers: {
      "en": "Accountant, engineer, administrator, manager.",

      "th": "นักบัญชี วิศวกร ผู้จัดการ งานบริหาร",
    },

    relationships: {
      "en": "ISTJs show care through responsibility and commitment.",

      "th": "ISTJ แสดงความรักผ่านความรับผิดชอบและความมั่นคง",
    },
  ),

  // ------------------------------------------------------------
  "ESFJ": MbtiTypeProfile(
    name: {"en": "ESFJ", "th": "ESFJ"},

    nickname: {"en": "The Consul", "th": "ผู้ดูแลสังคม"},

    description: {
      "en":
          "ESFJs are warm and sociable individuals who enjoy supporting and connecting people.",

      "th": "ESFJ เป็นคนอบอุ่น เข้าสังคมเก่ง และชอบดูแลคนรอบตัว",
    },

    strengths: {
      "en": "Communication, empathy, teamwork, responsibility.",

      "th": "สื่อสารเก่ง เข้าใจผู้อื่น ทำงานเป็นทีมดี และมีความรับผิดชอบ",
    },

    weaknesses: {
      "en": "May become overly concerned with others' approval.",

      "th": "บางครั้งอาจกังวลกับความคิดเห็นของคนอื่นมากเกินไป",
    },

    careers: {
      "en": "Teacher, HR, community manager, healthcare.",

      "th": "ครู HR ผู้ดูแลชุมชน งานด้านสุขภาพ",
    },

    relationships: {
      "en": "ESFJs thrive in warm and supportive relationships.",

      "th": "ESFJ ชอบความสัมพันธ์ที่อบอุ่นและสนับสนุนกัน",
    },
  ),

  // ------------------------------------------------------------
  "ESTJ": MbtiTypeProfile(
    name: {"en": "ESTJ", "th": "ESTJ"},

    nickname: {"en": "The Executive", "th": "ผู้บริหาร"},

    description: {
      "en":
          "ESTJs are organized leaders who value efficiency, order, and clear systems.",

      "th": "ESTJ เป็นผู้นำที่มีระเบียบ ชอบระบบที่ชัดเจน และเน้นประสิทธิภาพ",
    },

    strengths: {
      "en": "Leadership, organization, discipline, practicality.",

      "th": "ภาวะผู้นำสูง จัดระบบเก่ง มีวินัย และลงมือทำจริง",
    },

    weaknesses: {
      "en": "May appear too strict or controlling.",

      "th": "บางครั้งอาจดูเข้มงวดหรือควบคุมมากเกินไป",
    },

    careers: {
      "en": "Manager, executive, entrepreneur, administrator.",

      "th": "ผู้จัดการ ผู้บริหาร ผู้ประกอบการ งานบริหาร",
    },

    relationships: {
      "en": "ESTJs value loyalty, responsibility, and stability.",

      "th": "ESTJ ให้ความสำคัญกับความซื่อสัตย์ ความรับผิดชอบ และความมั่นคง",
    },
  ),

  // ------------------------------------------------------------
  "ISFP": MbtiTypeProfile(
    name: {"en": "ISFP", "th": "ISFP"},

    nickname: {"en": "The Adventurer", "th": "นักสร้างสรรค์อิสระ"},

    description: {
      "en":
          "ISFPs are gentle and creative individuals who enjoy expressing themselves and experiencing life in their own unique way.",

      "th":
          "ISFP เป็นคนที่อ่อนโยน มีความคิดสร้างสรรค์ และชอบแสดงตัวตนผ่านสิ่งที่รัก เช่น ศิลปะ ดนตรี หรือประสบการณ์ชีวิต",
    },

    strengths: {
      "en": "Creativity, authenticity, sensitivity, artistic expression.",

      "th":
          "มีความคิดสร้างสรรค์สูง เป็นตัวของตัวเอง เข้าใจอารมณ์ และแสดงออกผ่านศิลปะได้ดี",
    },

    weaknesses: {
      "en": "May avoid conflict and struggle with long-term planning.",

      "th": "บางครั้งอาจหลีกเลี่ยงความขัดแย้ง และไม่ชอบการวางแผนระยะยาว",
    },

    careers: {
      "en": "Artist, designer, musician, photographer.",

      "th": "ศิลปิน นักออกแบบ นักดนตรี ช่างภาพ",
    },

    relationships: {
      "en": "ISFPs seek genuine and emotionally meaningful relationships.",

      "th": "ISFP มองหาความสัมพันธ์ที่จริงใจและมีความหมายทางอารมณ์",
    },
  ),

  // ------------------------------------------------------------
  "ISTP": MbtiTypeProfile(
    name: {"en": "ISTP", "th": "ISTP"},

    nickname: {"en": "The Virtuoso", "th": "นักแก้ปัญหา"},

    description: {
      "en":
          "ISTPs are practical problem-solvers who enjoy understanding how things work and fixing complex issues.",

      "th":
          "ISTP เป็นคนที่ชอบแก้ปัญหา ชอบเข้าใจกลไกของสิ่งต่าง ๆ และมักเก่งในการแก้สถานการณ์เฉพาะหน้า",
    },

    strengths: {
      "en": "Practical thinking, adaptability, technical skill, independence.",

      "th": "คิดเชิงปฏิบัติ ปรับตัวเก่ง มีทักษะทางเทคนิค และรักอิสระ",
    },

    weaknesses: {
      "en": "May appear reserved and avoid emotional conversations.",

      "th": "บางครั้งอาจดูเงียบ หรือไม่ถนัดการพูดคุยเรื่องอารมณ์",
    },

    careers: {
      "en": "Engineer, mechanic, technician, pilot.",

      "th": "วิศวกร ช่างเทคนิค นักบิน ช่างเครื่อง",
    },

    relationships: {
      "en":
          "ISTPs prefer relationships that allow independence and mutual respect.",

      "th": "ISTP ต้องการความสัมพันธ์ที่ให้พื้นที่ส่วนตัวและเคารพกัน",
    },
  ),

  // ------------------------------------------------------------
  "ESFP": MbtiTypeProfile(
    name: {"en": "ESFP", "th": "ESFP"},

    nickname: {"en": "The Entertainer", "th": "ผู้สร้างความสนุก"},

    description: {
      "en":
          "ESFPs are energetic and spontaneous individuals who enjoy bringing joy and excitement to people around them.",

      "th":
          "ESFP เป็นคนที่มีพลัง สนุกสนาน และชอบสร้างบรรยากาศที่มีชีวิตชีวาให้กับคนรอบตัว",
    },

    strengths: {
      "en": "Energy, social skills, enthusiasm, adaptability.",

      "th": "มีพลัง เข้าสังคมเก่ง สนุกสนาน และปรับตัวได้ดี",
    },

    weaknesses: {
      "en": "May avoid long-term planning and become easily distracted.",

      "th": "บางครั้งอาจไม่ชอบการวางแผนระยะยาว หรือวอกแวกได้ง่าย",
    },

    careers: {
      "en": "Performer, host, entertainer, event organizer.",

      "th": "นักแสดง พิธีกร นักจัดอีเวนต์ นักบันเทิง",
    },

    relationships: {
      "en": "ESFPs thrive in lively and emotionally expressive relationships.",

      "th": "ESFP ชอบความสัมพันธ์ที่สนุก มีพลัง และแสดงอารมณ์ได้อย่างเปิดเผย",
    },
  ),

  // ------------------------------------------------------------
  "ESTP": MbtiTypeProfile(
    name: {"en": "ESTP", "th": "ESTP"},

    nickname: {"en": "The Entrepreneur", "th": "นักลงมือทำ"},

    description: {
      "en":
          "ESTPs are action-oriented individuals who enjoy solving problems quickly and experiencing life directly.",

      "th":
          "ESTP เป็นคนที่เน้นการลงมือทำ ชอบแก้ปัญหาอย่างรวดเร็ว และชอบประสบการณ์จริง",
    },

    strengths: {
      "en": "Boldness, adaptability, practical thinking, quick decisions.",

      "th": "กล้าตัดสินใจ ปรับตัวเก่ง คิดเชิงปฏิบัติ และแก้ปัญหาเฉพาะหน้าได้ดี",
    },

    weaknesses: {
      "en": "May take risks too quickly and avoid routine tasks.",

      "th": "บางครั้งอาจตัดสินใจเร็วเกินไป หรือไม่ชอบงานที่ซ้ำซาก",
    },

    careers: {
      "en": "Entrepreneur, salesperson, athlete, emergency responder.",

      "th": "ผู้ประกอบการ นักขาย นักกีฬา เจ้าหน้าที่ฉุกเฉิน",
    },

    relationships: {
      "en":
          "ESTPs enjoy exciting relationships that involve shared experiences.",

      "th": "ESTP ชอบความสัมพันธ์ที่มีประสบการณ์ร่วมกันและมีความตื่นเต้น",
    },
  ),
};
