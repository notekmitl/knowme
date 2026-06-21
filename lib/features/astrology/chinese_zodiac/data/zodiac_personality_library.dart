import '../domain/zodiac_personality_profile.dart';

/// Deterministic Year Animal personality content (TH / EN).
abstract final class ZodiacPersonalityLibrary {
  static const supportedAnimals = [
    'rat',
    'ox',
    'tiger',
    'rabbit',
    'dragon',
    'snake',
    'horse',
    'goat',
    'monkey',
    'rooster',
    'dog',
    'pig',
  ];

  static ZodiacPersonalityProfile? lookup(String animalKey, String lang) {
    final key = animalKey.trim().toLowerCase();
    final locale = lang == 'th' ? 'th' : 'en';
    return _profiles[locale]?[key];
  }

  static const Map<String, Map<String, ZodiacPersonalityProfile>> _profiles = {
    'th': {
      'rat': ZodiacPersonalityProfile(
        animalKey: 'rat',
        coreTraits:
            'มักเชื่อว่าความปลอดภัยทางจิตใจมาจากการมองเห็นทางเลือกและจังหวะก่อนที่สถานการณ์จะกดดัน '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อถูกบังคับให้ตัดสินใจโดยยังไม่เห็นภาพรวม '
            'หรือเมื่อทางออกเดียวถูกปิดไปก่อนที่จะได้พิจารณา',
        workStyle:
            'มักรู้สึกว่าตัวเองทำงานได้ดีที่สุดเมื่อได้ประเมินความเสี่ยง จัดลำดับทางเลือก '
            'และใช้สิ่งที่มีอยู่ให้เกิดประโยชน์สูงสุด มากกว่าการเร่งผลลัพธ์โดยไม่มีแผนสำรอง '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องอ่านสถานการณ์และปรับทิศทางก่อนที่จะสายเกินไป',
        relationshipStyle:
            'มักสร้างความใกล้ชิดผ่านการแลกเปลี่ยนความคิด เป้าหมายร่วม และความรู้สึกว่า '
            'ทั้งสองฝ่ายยังมีทางเลือกในการอยู่ร่วมกัน หลายครั้งอาจรู้สึกห่างเมื่อความสัมพันธ์ '
            'กลายเป็นเรื่องที่ถูกกำหนดให้เป็นแบบเดียวโดยไม่มีพื้นที่ปรับตัว',
        strengths: [
          'มักแยกได้ว่าอะไรเป็นความกังวลล่วงหน้า อะไรเป็นสัญญาณที่ต้องตอบสนองจริง',
          'มักมองเห็นช่องว่างหรือทางเลือกที่คนอื่นอาจมองข้ามในช่วงที่ยังไม่ชัด',
          'มักใช้ทรัพยากรจำกัดอย่างมีเหตุผล แทนการใช้พลังงานกับสิ่งที่ยังไม่จำเป็น',
        ],
        challenges: [
          'อาจใช้เวลานานกว่าจะลงมือ เพราะต้องการความมั่นใจว่าได้พิจารณาครบแล้ว',
          'อาจรู้สึกกังวลเมื่ออนาคตดูเปิดกว้างเกินไปจนไม่มีจุดยึด',
          'อาจกระจายความสนใจไปหลายทางเลือกพร้อมกัน จนลืมลงลึกในทางใดทางหนึ่ง',
        ],
        growthSuggestions: [
          'ลองถามตัวเองว่า "ข้อมูลนี้เพียงพอสำหรับก้าวถัดไปหรือยัง" แทนการรอให้แน่ใจทุกอย่าง',
          'ฝึกเลือกโฟกัสหนึ่งเรื่องในแต่ละช่วง เพื่อให้พลังงานไม่ถูกแบ่งจนไม่เหลือผลลัพธ์',
          'เมื่อรู้สึกกังวล ลองเขียนแยกว่าอะไรควบคุมได้ อะไรควบคุมไม่ได้',
        ],
      ),
      'ox': ZodiacPersonalityProfile(
        animalKey: 'ox',
        coreTraits:
            'มักเชื่อว่าความก้าวหน้าที่แท้จริงมาจากความสม่ำเสมอมากกว่าการเปลี่ยนแปลงครั้งใหญ่ '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อถูกเร่งให้เปลี่ยนทิศทางก่อนที่จะทำสิ่งเดิมให้มั่นคง '
            'หรือเมื่อคนรอบตัวต้องการผลลัพธ์เร็วกว่าจังหวะที่ตัวเองรับได้',
        workStyle:
            'มักรู้สึกว่าคุณภาพของงานมาจากการทำซ้ำ ๆ อย่างตั้งใจและรักษามาตรฐานที่ตั้งไว้ '
            'มากกว่าการกระโดดไปเรื่องใหม่เรื่อย ๆ หลายครั้งอาจโดดเด่นในบทบาทที่ต้องความอดทน '
            'ความรับผิดชอบ และการทำให้สิ่งที่เริ่มไว้จบลงจริง',
        relationshipStyle:
            'มักแสดงความรักผ่านการอยู่เคียงข้าง ทำตามสัญญา และไม่หายไปเมื่อความสัมพันธ์เข้าสู่ช่วงยาก '
            'หลายครั้งอาจไม่พูดคำหวาน แต่มักให้ความรู้สึกว่า "ยังอยู่ตรงนี้" อย่างสม่ำเสมอ '
            'อาจใช้เวลานานกว่าจะเปิดใจ แต่เมื่อไว้ใจแล้วมักให้ความมั่นใจผ่านการกระทำมากกว่าคำพูด',
        strengths: [
          'มักทำสิ่งที่สัญญาไว้ได้ แม้ในช่วงที่คนอื่นเริ่มลดความพยายาม',
          'มักไม่ตื่นเต้นกับการเปลี่ยนแปลงเร็ว ๆ ที่ยังไม่พิสูจน์ความมั่นคง',
          'มักสร้างความน่าเชื่อถือผ่านความสม่ำเสมอ ไม่ใช่แค่ช่วงที่รู้สึกดี',
        ],
        challenges: [
          'อาจยึดติดกับวิธีเดิม เพราะเชื่อว่ามันพิสูจน์แล้วว่าใช้ได้ แม้บริบทจะเปลี่ยน',
          'อาจเก็บความรู้สึกไว้ในใจ เพราะคิดว่าการพูดออกมาอาจทำให้ความสัมพันธ์ไม่มั่นคง',
          'อาจรู้สึกเหนื่อยเมื่อถูกคาดหวังให้ปรับตัวเร็วกว่าที่ตัวเองพร้อม',
        ],
        growthSuggestions: [
          'ลองถามว่า "อะไรในวิธีเดิมยังคุ้มค่า อะไรควรปรับ" แทนการยึดหรือทิ้งทั้งหมด',
          'ฝึกแบ่งปันความรู้สึกเล็ก ๆ กับคนที่ไว้ใจ ก่อนที่มันจะกลายเป็นความหนักในใจ',
          'ให้ตัวเองพักและปรับจังหวะได้ แม้งานยังไม่จบ — ความสม่ำเสมอต้องการพลังงานที่ฟื้นได้',
        ],
      ),
      'tiger': ZodiacPersonalityProfile(
        animalKey: 'tiger',
        coreTraits:
            'มักรู้สึกมีชีวิตชีวาเมื่อการกระทำสอดคล้องกับสิ่งที่ตัวเองเชื่อว่าสำคัญ '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อถูกจำกัดให้ทำในสิ่งที่ขัดกับค่านิยม '
            'หรือเมื่อต้องรออนุมัติจากคนที่ไม่เข้าใจว่าทำไมเรื่องนี้จึงมีความหมาย',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อได้เห็นว่างานมีผลต่อสิ่งที่ใหญ่กว่าตัวเอง '
            'และมีอิสระในการตัดสินใจว่าจะลงมืออย่างไร หลายครั้งอาจโดดเด่นในบทบาทที่ต้อง '
            'กล้าตั้งคำถาม กล้าผลักดัน หรือกล้ายืนหยัดเมื่อคนอื่นลังเล',
        relationshipStyle:
            'มักแสดงความรักผ่านการปกป้อง การยืนข้าง และการไม่ทำเป็นเหมือนไม่สนใจ '
            'หลายครั้งอาจต้องการพื้นที่ส่วนตัวเพื่อฟื้นพลัง แต่เมื่อไว้วางใจแล้ว '
            'มักให้ความรู้สึกว่ามีใครคนหนึ่งที่จะไม่หลีกเลี่ยงเมื่อเรื่องสำคัญเกิดขึ้น',
        strengths: [
          'มักลงมือได้เมื่อคนอื่นยังลังเล เพราะเห็นว่าเรื่องนี้ไม่ควรถูกเลื่อนออกไป',
          'มักยืนหยัดตามค่านิยมของตัวเอง แม้จะไม่เป็นที่นิยมในขณะนั้น',
          'มักสร้างแรงจูงใจให้คนรอบข้างเมื่อเป้าหมายมีความหมายชัด',
        ],
        challenges: [
          'อาจใช้พลังงานมากเกินไปในช่วงที่สถานการณ์ยังไม่พร้อมรับความเร็วนั้น',
          'อาจรู้สึกหงุดหงิดเมื่อถูกควบคุมหรือถูกมองว่า "ใจร้อน" ทั้งที่เห็นว่าเรื่องเร่งด่วน',
          'อาจตัดสินใจเร็วก่อนฟังมุมมองที่อาจเปลี่ยนทิศทางได้',
        ],
        growthSuggestions: [
          'ก่อนลงมือเรื่องสำคัญ ลองถามว่า "ใครยังไม่ได้พูด และมุมมองนั้นอาจเปลี่ยนอะไร"',
          'แบ่งเป้าหมายใหญ่เป็นขั้นตอน เพื่อลดแรงกดดันที่มาจากการอยากเห็นผลทันที',
          'ฝึกแยกว่าอะไรเป็นเรื่องของค่านิยม อะไรเป็นเรื่องของอารมณ์ในขณะนั้น',
        ],
      ),
      'rabbit': ZodiacPersonalityProfile(
        animalKey: 'rabbit',
        coreTraits:
            'มักรับรู้บรรยากาศและความรู้สึกของคนรอบตัวก่อนที่จะตัดสินใจว่าจะเปิดเผยตัวเองแค่ไหน '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อถูกดึงเข้าสู่ความขัดแย้งโดยตรง '
            'หรือเมื่อสภาพแวดล้อมรู้สึกแข่งขันและไม่มีพื้นที่ให้ฟังกัน',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อมีความไว้วางใจในทีม และสามารถดูแลรายละเอียด '
            'ที่คนอื่นอาจมองข้าม หลายครั้งอาจโดดเด่นในบทบาทที่ต้องประสานงาน '
            'อ่านความรู้สึกของคน และสร้างบรรยากาศที่ทำให้งานเดินต่อได้',
        relationshipStyle:
            'มักสร้างความใกล้ชิดผ่านการฟัง การอยู่เคียงข้างอย่างอ่อนโยน '
            'และการไม่เร่งให้เปิดใจเร็วกว่าที่พร้อม หลายครั้งอาจใช้เวลานานกว่าจะไว้ใจ '
            'แต่เมื่อไว้ใจแล้วมักให้ความรู้สึกปลอดภัยที่หาได้ยาก',
        strengths: [
          'มักสังเกตได้ว่าใครกำลังไม่สบายใจ แม้ยังไม่ได้พูดออกมา',
          'มักหลีกเลี่ยงความขัดแย้งที่ไม่จำเป็น โดยไม่ต้องทำลายความสัมพันธ์',
          'มักใส่ใจรายละเอียดเล็ก ๆ ที่ทำให้คนรอบข้างรู้สึกว่าถูกมองเห็น',
        ],
        challenges: [
          'อาจเก็บความรู้สึกไว้ในใจ เพราะกลัวว่าการพูดออกมาจะทำให้บรรยากาศแย่ลง',
          'อาจลังเลนานเมื่อต้องตัดสินใจเรื่องที่กระทบความรู้สึกของคนอื่น',
          'อาจรู้สึกเหนื่อยในสภาพแวดล้อมที่กดดัน แข่งขัน หรือไม่ให้พื้นที่ฟัง',
        ],
        growthSuggestions: [
          'ฝึกพูดความต้องการหรือขอบเขตอย่างอ่อนโยน ก่อนที่ความรู้สึกจะสะสมจนล้น',
          'ลองรับความไม่สบายเล็กน้อยเมื่อต้องพูดเรื่องสำคัญ — ไม่ใช่ทุกความขัดแย้งจะทำลายความสัมพันธ์',
          'เลือกสภาพแวดล้อมที่สนับสนุน แต่ไม่หลบทุกความท้าทายที่ช่วยให้เติบโต',
        ],
      ),
      'dragon': ZodiacPersonalityProfile(
        animalKey: 'dragon',
        coreTraits:
            'มักมองโลกผ่านเลนส์ของ "สิ่งที่เป็นไปได้" มากกว่า "สิ่งที่เป็นอยู่" '
            'หลายครั้งอาจรู้สึกมีพลังเมื่อได้ผลักดันสิ่งที่เชื่อว่ามีความหมาย '
            'และอาจรู้สึกหงุดหงิดเมื่อต้องติดอยู่กับงานซ้ำ ๆ ที่ไม่เห็นภาพใหญ่',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อได้เห็นว่างานมีผลกระทบ และมีโอกาสรวมพลังคน '
            'เข้าสู่ทิศทางเดียวกัน หลายครั้งอาจโดดเด่นในบทบาทที่ต้องวิสัยทัศน์ '
            'การสร้างแรงบันดาลใจ และการเริ่มสิ่งที่ยังไม่มีใครลอง',
        relationshipStyle:
            'มักแสดงความใส่ใจผ่านการมองเห็นศักยภาพของคนรอบตัว และการสนับสนุนให้ก้าวไปข้างหน้า '
            'หลายครั้งอาจต้องการคนที่เข้าใจว่าความทะเยอทะยานไม่ได้หมายถึงการไม่สนใจคนอื่น '
            'แต่เป็นการอยากเห็นทุกคนเติบโตไปด้วยกัน',
        strengths: [
          'มักมองเห็นโอกาสหรือทิศทางที่คนอื่นอาจมองข้ามในช่วงที่ยังไม่ชัด',
          'มักสร้างแรงบันดาลใจให้คนรอบข้างเมื่อเป้าหมายมีความหมายจริง',
          'มักไม่ยอมจมอยู่กับสถานการณ์ปัจจุบัน ถ้าเห็นว่ายังมีทางที่ดีกว่า',
        ],
        challenges: [
          'อาจตั้งเป้าหมายสูงเกินกว่าจังหวะหรือทรัพยากรที่มีในขณะนั้น',
          'อาจรู้สึกหงุดหงิดเมื่องานเล็ก ๆ ดึงความสนใจจากภาพใหญ่ที่อยากทำ',
          'อาจคาดหวังจากตัวเองหรือคนอื่นสูง จนลืมชื่นชมความคืบหน้าเล็ก ๆ',
        ],
        growthSuggestions: [
          'แบ่งวิสัยทัศน์ใหญ่เป็นเป้าหมายย่อยที่ทำได้จริงในแต่ละช่วง',
          'ฝึกชื่นชมความคืบหน้าเล็ก ๆ — ภาพใหญ่สร้างจากขั้นตอนเล็ก ๆ หลายครั้ง',
          'ลองฟังมุมมองที่เน้นรายละเอียด เพื่อให้วิสัยทัศน์แข็งแรงและทำได้จริง',
        ],
      ),
      'snake': ZodiacPersonalityProfile(
        animalKey: 'snake',
        coreTraits:
            'มักเชื่อว่าการตัดสินใจที่ดีมาจากการเข้าใจลึก ไม่ใช่การตอบสนองเร็ว '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อถูกเร่งให้ตัดสินใจโดยยังไม่ได้ประมวลผล '
            'หรือเมื่อคนรอบตัวต้องการคำตอบก่อนที่ตัวเองจะเห็นภาพครบ',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อได้เวลาวิเคราะห์ วางแผน และเลือกจังหวะก่อนลงมือ '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องมองเห็นความเสี่ยงที่ซ่อนอยู่ '
            'และตัดสินใจในจุดที่คนอื่นอาจยังไม่เห็น',
        relationshipStyle:
            'มักสร้างความสัมพันธ์อย่างค่อยเป็นค่อยไป และลึกซึ้งมากกว่ากว้างแต่ตื้น '
            'หลายครั้งอาจไม่แสดงออกมากในตอนแรก แต่เมื่อไว้วางใจแล้ว '
            'มักให้ความจริงใจที่ไม่เปลี่ยนตามอารมณ์ชั่วคราว',
        strengths: [
          'มักมองเห็นแง่มุมหรือความเสี่ยงที่คนอื่นอาจมองข้ามในช่วงแรก',
          'มักไม่ลงมือเร็วเกินไปในสิ่งที่ยังไม่เข้าใจพอ',
          'มักมีสมาธิและความอดทนในเรื่องที่ต้องใช้เวลาคิดลึก',
        ],
        challenges: [
          'อาจใช้เวลานานกว่าจะเปิดใจ เพราะต้องการมั่นใจว่าความไว้วางใจมีเหตุผล',
          'อาจวิเคราะห์มากจนลังเล หรือพลาดจังหวะที่การลงมือเร็วกว่านี้ก็พอ',
          'อาจรู้สึกไม่สบายในสภาพแวดล้อมที่เร่งรีบ ตื้น หรือไม่ให้เวลาคิด',
        ],
        growthSuggestions: [
          'ฝึกแบ่งปันความคิดบางส่วนก่อนที่จะมั่นใจครบทุกอย่าง — ไม่ต้องรอให้สมบูรณ์แบบ',
          'ตั้งเวลาตัดสินใจ เพื่อลดการวิเคราะห์วนไปเรื่อย ๆ โดยไม่มีจุดจบ',
          'ลองเข้าร่วมกิจกรรมที่ไม่ต้องควบคุมทุกรายละเอียด เพื่อฝึกความยืดหยุ่น',
        ],
      ),
      'horse': ZodiacPersonalityProfile(
        animalKey: 'horse',
        coreTraits:
            'มักรู้สึกมีชีวิตชีวาเมื่อได้เคลื่อนไหว เรียนรู้ และเห็นทิศทางใหม่ '
            'หลายครั้งอาจรู้สึกอึดอัดเมื่อถูกจำกัดให้อยู่กับงานเดิมนาน ๆ '
            'หรือเมื่อไม่เห็นว่าสิ่งที่ทำอยู่จะพาไปไหนต่อ',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อมีอิสระในการเลือกวิธี และเห็นว่างานมีทิศทาง '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องสื่อสาร ขับเคลื่อน และสร้างแรงจูงใจ '
            'มากกว่าบทบาทที่ต้องทำซ้ำ ๆ โดยไม่เห็นความหมาย',
        relationshipStyle:
            'มักสร้างความใกล้ชิดผ่านการแบ่งปันประสบการณ์ ความตรงไปตรงมา '
            'และพลังงานที่มีเมื่ออยู่ด้วยกัน หลายครั้งอาจต้องการพื้นที่ส่วนตัว '
            'เพื่อฟื้นพลัง แต่เมื่ออยู่ด้วยกันมักให้ความรู้สึกมีชีวิตชีวา',
        strengths: [
          'มักเรียนรู้จากประสบการณ์ใหม่ได้เร็ว และนำไปใช้ในทิศทางถัดไป',
          'มักสื่อสารและสร้างแรงบันดาลใจให้คนรอบข้างเมื่อทิศทางชัด',
          'มักไม่ยอมจมอยู่กับสถานการณ์ที่รู้สึกว่าไม่มีทางออก',
        ],
        challenges: [
          'อาจเบื่อเร็วเมื่องานซ้ำหรือไม่มีความท้าทายใหม่ที่ให้ความหมาย',
          'อาจเร่งจังหวะจนลืมพักหรือทบทวนว่ากำลังไปในทิศทางที่ต้องการจริงหรือไม่',
          'อาจรู้สึกอึดอัดเมื่อถูกจำกัดหรือต้องรออนุมัตินานเกินไป',
        ],
        growthSuggestions: [
          'ฝึกหยุดพักและถามว่า "ทิศทางนี้ยังใช่กับตัวเองหรือไม่" ก่อนเร่งไปต่อ',
          'ลองทำงานที่ต้องความอดทนบางส่วน เพื่อให้ความชอบเคลื่อนไหวไม่กลายเป็นหลบ',
          'เลือกเป้าหมายที่มีความหมาย ไม่ใช่แค่ความเร็วหรือความใหม่',
        ],
      ),
      'goat': ZodiacPersonalityProfile(
        animalKey: 'goat',
        coreTraits:
            'มักรับรู้และใส่ใจความสมดุลทางอารมณ์รอบตัวอย่างลึกซึ้ง '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อบรรยากาศตึงเครียด แข่งขัน หรือขาดความอบอุ่น '
            'และมักให้ความสำคัญกับว่าคนรอบตัวรู้สึกอย่างไร ไม่ใช่แค่ผลลัพธ์ของงาน',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อมีความร่วมมือ ความไว้วางใจ และพื้นที่ให้แสดงความคิดสร้างสรรค์ '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องดูแลคน สร้างบรรยากาศ '
            'และทำให้งานที่มีคุณภาพเกิดขึ้นในทีมที่รู้สึกดี',
        relationshipStyle:
            'มักแสดงความรักผ่านการฟัง การดูแล และการอยู่เคียงข้างเมื่อคนอื่นอ่อนแอ '
            'หลายครั้งอาจต้องการความอบอุ่นและการยืนยันจากคนที่รัก '
            'และอาจรู้สึกเจ็บเมื่อความสัมพันธ์ขาดความอ่อนโยน',
        strengths: [
          'มักสร้างบรรยากาศที่ทำให้คนรอบข้างรู้สึกปลอดภัยที่จะเปิดใจ',
          'มักมองเห็นความงามหรือมิติที่ละเอียดอ่อนในสิ่งที่คนอื่นอาจมองข้าม',
          'มักประนีประนอมได้โดยไม่ต้องทำลายความสัมพันธ์',
        ],
        challenges: [
          'อาจใส่ใจความรู้สึกของคนอื่นมากจนลืมดูแลความต้องการของตัวเอง',
          'อาจลังเลเมื่อต้องตัดสินใจเรื่องที่อาจทำให้ใครสักคนไม่พอใจ',
          'อาจรู้สึกเหนื่อยในสภาพแวดล้อมที่แข่งขันหรือไม่ให้พื้นที่อ่อนโยน',
        ],
        growthSuggestions: [
          'ฝึกตั้งขอบเขตและดูแลความต้องการของตัวเองให้ชัด — การดูแลตัวเองไม่ใช่ความเห็นแก่',
          'ลองแสดงความคิดเห็นของตัวเอง แม้จะกระทบความสมดุลบ้างในช่วงสั้น',
          'เลือกสภาพแวดล้อมที่ให้ทั้งความอบอุ่นและโอกาสเติบโต',
        ],
      ),
      'monkey': ZodiacPersonalityProfile(
        animalKey: 'monkey',
        coreTraits:
            'มักรู้สึกมีชีวิตชีวาเมื่อได้คิดนอกกรอบ ทดลอง และหาทางออกที่ไม่ซ้ำเดิม '
            'หลายครั้งอาจใช้อารมณ์ขันหรือความคิดเก่งเป็นทางลัด '
            'เมื่อสถานการณ์เริ่มรู้สึกน่าเบื่อหรือกดดันเกินไป',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อมีปัญหาใหม่ ๆ ให้แก้ และพื้นที่ให้ลองวิธีที่แตกต่าง '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องคิดเร็ว ปรับตัว '
            'และหาทางออกที่คนอื่นอาจยังไม่เห็น',
        relationshipStyle:
            'มักสร้างความใกล้ชิดผ่านการแลกเปลี่ยนความคิด อารมณ์ขัน และความสนุกร่วมกัน '
            'หลายครั้งอาจชอบความสัมพันธ์ที่มีชีวิตชีวา แต่อาจใช้ความสนุก '
            'เป็นที่พักเมื่อเรื่องลึก ๆ เริ่มรู้สึกหนักเกินไป',
        strengths: [
          'มักหาทางแก้ปัญหาได้ด้วยวิธีที่คนอื่นอาจไม่คิดถึง',
          'มักเรียนรู้เร็วและปรับตัวกับสถานการณ์ใหม่ได้ดี',
          'มักสร้างบรรยากาศที่ทำให้คนรอบข้างรู้สึกว่าปัญหาไม่ใหญ่เกินไป',
        ],
        challenges: [
          'อาจเบื่อเร็วเมื่องานซ้ำหรือไม่มีความท้าทายใหม่ที่กระตุ้นความสนใจ',
          'อาจกระจายความสนใจไปหลายเรื่องพร้อมกัน จนไม่ลงลึกในทางใดทางหนึ่ง',
          'อาจใช้ความคิดเก่งแทนการฟังความรู้สึกของคนอื่นเมื่อสถานการณ์ละเอียดอ่อน',
        ],
        growthSuggestions: [
          'ฝึกทำงานหนึ่งเรื่องให้ลึกก่อนขยับไปเรื่องใหม่ — ความลึกก็เป็นรางวัลได้',
          'เมื่อคนรอบตัวแชร์ความรู้สึก ลองฟังก่อนเสนอทางแก้',
          'เลือกโครงการที่มีทั้งความท้าทายและความหมายระยะยาว ไม่ใช่แค่ความใหม่',
        ],
      ),
      'rooster': ZodiacPersonalityProfile(
        animalKey: 'rooster',
        coreTraits:
            'มักใช้มาตรฐานและความชัดเจนเป็นวิธีจัดการความไม่แน่นอนในชีวิต '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่องานหรือความสัมพันธ์รู้สึกหลวม ไม่เป็นระเบียบ '
            'หรือเมื่อคนอื่นไม่ใส่ใจรายละเอียดที่ตัวเองมองว่าสำคัญ',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อมีเป้าหมายชัด เกณฑ์วัดผลที่เข้าใจได้ '
            'และพื้นที่ให้ดูแลคุณภาพจริง ๆ หลายครั้งอาจโดดเด่นในบทบาทที่ต้องวางแผน '
            'ตรวจสอบ และทำให้สิ่งที่เริ่มไว้มีมาตรฐานจนจบ',
        relationshipStyle:
            'มักแสดงความใส่ใจผ่านการดูแล การแนะนำ และการอยู่เคียงข้างอย่างจริงจัง '
            'หลายครั้งอาจตรงไปตรงมา เพราะเชื่อว่าความซื่อสัตย์สำคัญกว่าการทำให้พอใจชั่วคราว '
            'และอาจต้องการความจริงใจจากคนรอบตัวเช่นกัน',
        strengths: [
          'มักทำให้งานที่เริ่มไว้มีคุณภาพจนจบ ไม่ใช่แค่เริ่มแล้วทิ้ง',
          'มักมองเห็นรายละเอียดที่อาจกลายเป็นปัญหาใหญ่ถ้าไม่จัดการตั้งแต่แรก',
          'มักพูดตรงในสิ่งที่คิด เพื่อไม่ให้ความเข้าใจผิดค้างอยู่',
        ],
        challenges: [
          'อาจเข้มงวดกับตัวเองหรือคนอื่นมากเกินไป เมื่อมาตรฐานไม่ถูกตาม',
          'อาจรู้สึกไม่สบายเมื่องานหรือคนอื่นไม่เป็นไปตามที่คาดไว้',
          'อาจพูดตรงเกินไปจนกระทบความรู้สึก โดยไม่ได้ตั้งใจทำร้าย',
        ],
        growthSuggestions: [
          'ฝึกยืดหยุ่นกับความไม่สมบูรณ์แบบที่ยังยอมรับได้ — มาตรฐานดีไม่จำเป็นต้องสมบูรณ์แบบ',
          'ก่อนตัดสินหรือแนะนำ ลองฟังว่าคนอื่นมองเหตุผลอย่างไร',
          'ชื่นชมความคืบหน้า ไม่ใช่แค่สิ่งที่ยังขาด — การมองเห็นสิ่งที่ทำได้แล้วก็เป็นมาตรฐานได้',
        ],
      ),
      'dog': ZodiacPersonalityProfile(
        animalKey: 'dog',
        coreTraits:
            'มักให้ความสำคัญกับความยุติธรรม ความจริงใจ และความไว้วางใจในความสัมพันธ์ '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อเห็นความไม่ยุติธรรม การหลอกลวง '
            'หรือเมื่อคนสำคัญทำสิ่งที่ขัดกับค่านิยมที่ตัวเองยึดถือ',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่อเห็นว่างานสอดคล้องกับค่านิยมของตัวเอง '
            'และมีทีมที่ให้ความไว้วางใจซึ่งกันและกัน หลายครั้งอาจโดดเด่นในบทบาทที่ต้อง '
            'ความน่าเชื่อถือ ความรับผิดชอบ และการยืนข้างเมื่อเรื่องสำคัญเกิดขึ้น',
        relationshipStyle:
            'มักแสดงความรักผ่านความจริงใจ การอยู่เคียงข้าง และการไม่ทำเป็นเหมือนไม่เห็น '
            'เมื่อคนที่รักต้องการการสนับสนุน หลายครั้งอาจใช้เวลานานกว่าจะไว้วางใจ '
            'แต่เมื่อผูกพันแล้วมักให้ความมั่นใจที่ไม่เปลี่ยนตามอารมณ์ชั่วคราว',
        strengths: [
          'มักยืนหยัดตามค่านิยมของตัวเอง แม้จะไม่สะดวกในขณะนั้น',
          'มักเป็นที่พึ่งที่คนรอบตัวรู้ว่า "จะไม่หายไป" เมื่อเรื่องยากเกิดขึ้น',
          'มักทำงานอย่างจริงจังเมื่อเชื่อว่างานมีความหมายและยุติธรรม',
        ],
        challenges: [
          'อาจกังวลเรื่องความยุติธรรมหรือความไว้วางใจมากเกินไป จนลืมให้โอกาสคนอื่น',
          'อาจรู้สึกผิดหวังเมื่อคนอื่นไม่ตรงกับมาตรฐานที่ตัวเองยึดถือ',
          'อาจเก็บความรู้สึกเจ็บไว้ในใจ แทนการพูดออกมาว่าอะไรทำให้ไว้ใจลดลง',
        ],
        growthSuggestions: [
          'ฝึกแบ่งปันความกังวลกับคนที่ไว้ใจ ก่อนที่มันจะกลายเป็นความห่างที่ไม่จำเป็น',
          'ลองถามว่าคนอื่นอาจมีเหตุผลอะไร แทนการตัดสินว่า "ไม่ยุติธรรม" ทันที',
          'เลือกสภาพแวดล้อมที่ให้ความไว้วางใจและความยุติธรรมจริง ไม่ใช่แค่คำพูด',
        ],
      ),
      'pig': ZodiacPersonalityProfile(
        animalKey: 'pig',
        coreTraits:
            'มักให้ความสำคัญกับความสบายใจ ความจริงใจ และความสัมพันธ์ที่ลึก '
            'หลายครั้งอาจรู้สึกไม่สบายเมื่อบรรยากาศกดดัน ขาดความอบอุ่น '
            'หรือเมื่อต้องแข่งขันในลักษณะที่ทำให้คนรอบตัวรู้สึกไม่ดี',
        workStyle:
            'มักทำงานได้ดีที่สุดเมื่องานมีความหมายกับตัวเอง และมีทีมที่ให้ความไว้วางใจ '
            'หลายครั้งอาจโดดเด่นในบทบาทที่ต้องความร่วมมือ การดูแล '
            'และการสร้างบรรยากาศที่ทำให้ทุกคนทำงานได้อย่างยั่งยืน',
        relationshipStyle:
            'มักสร้างความใกล้ชิดผ่านความจริงใจ ความอบอุ่น และการอยู่เคียงข้างอย่างไม่ทำเป็น '
            'หลายครั้งอาจให้ความสำคัญกับความสัมพันธ์ที่ลึกและยั่งยืน '
            'มากกว่าความสัมพันธ์ที่กว้างแต่ตื้น',
        strengths: [
          'มักสร้างความสบายใจให้คนรอบข้างรู้สึกว่าไม่ต้องแสดงเป็นคนอื่น',
          'มักให้ความสำคัญกับความสัมพันธ์จริง ๆ ไม่ใช่แค่ผลลัพธ์หรือสถานะ',
          'มักทำงานได้ดีในทีมที่มีความไว้วางใจและความจริงใจ',
        ],
        challenges: [
          'อาจใส่ใจความสบายของคนอื่นมากจนลืมขอบเขตของตัวเอง',
          'อาจเลี่ยงความขัดแย้งหรือสถานการณ์กดดัน แม้การเผชิญจะช่วยให้เติบโต',
          'อาจใช้เวลานานกว่าจะตัดสินใจเรื่องที่กระทบความสัมพันธ์ที่รัก',
        ],
        growthSuggestions: [
          'ฝึกแสดงความต้องการและขอบเขตของตัวเองอย่างชัด — ความอ่อนโยนไม่ต้องหมายถึงการยอมทุกอย่าง',
          'ลองรับความท้าทายเล็ก ๆ ที่ช่วยให้เติบโต แม้จะไม่สบายในตอนแรก',
          'เลือกสภาพแวดล้อมที่ให้ทั้งความอบอุ่นและโอกาสพัฒนาตัวเอง',
        ],
      ),
    },
    'en': {
      'rat': ZodiacPersonalityProfile(
        animalKey: 'rat',
        coreTraits:
            'You often believe emotional safety comes from seeing options and timing '
            'before pressure builds. You may feel uncomfortable when forced to decide '
            'before the full picture is clear, or when a single path is closed before '
            'you have had room to consider alternatives.',
        workStyle:
            'You often feel you work best when assessing risk, prioritizing options, '
            'and making limited resources count — rather than rushing outcomes without '
            'a backup plan. You may stand out in roles that require reading situations '
            'and adjusting direction before it is too late.',
        relationshipStyle:
            'You often build closeness through exchange of ideas, shared goals, and '
            'the sense that both people still have room to choose how they stay together. '
            'You may feel distant when a relationship becomes fixed in one shape '
            'with no space to adapt.',
        strengths: [
          'You often distinguish between future worry and signals that truly need a response',
          'You often notice gaps or options others may overlook while things are still unclear',
          'You often use limited resources wisely instead of spending energy on what is not yet necessary',
        ],
        challenges: [
          'You may take longer to act because you want confidence that you have considered enough',
          'You may feel uneasy when the future feels too open with nothing to anchor to',
          'You may spread attention across many options at once and forget to go deep on one',
        ],
        growthSuggestions: [
          'Ask whether information is enough for the next step, instead of waiting for total certainty',
          'Choose one focus per stretch of time so energy does not scatter without results',
          'When worry rises, write down what you can control and what you cannot',
        ],
      ),
      'ox': ZodiacPersonalityProfile(
        animalKey: 'ox',
        coreTraits:
            'You often believe real progress comes from consistency rather than dramatic change. '
            'You may feel uncomfortable when pushed to shift direction before what you started '
            'feels stable, or when others want results faster than your pace allows.',
        workStyle:
            'You often feel quality comes from deliberate repetition and maintaining standards '
            'you set — more than jumping to new tasks repeatedly. You may stand out in roles '
            'that need endurance, responsibility, and finishing what was started.',
        relationshipStyle:
            'You often show love by staying present, keeping promises, and not disappearing '
            'when relationships enter difficult phases. You may not speak warmly often, '
            'but you often offer reassurance through steady action rather than words alone.',
        strengths: [
          'You often follow through on commitments even when others start reducing effort',
          'You often resist quick changes that have not yet proven stability',
          'You often build trust through consistency, not only during good moods',
        ],
        challenges: [
          'You may hold to familiar methods because they have worked before, even as context shifts',
          'You may keep feelings inside, believing that speaking might unsettle the relationship',
          'You may feel drained when expected to adapt faster than you are ready for',
        ],
        growthSuggestions: [
          'Ask what in the old way still holds value and what should adjust, instead of all-or-nothing',
          'Share small feelings with people you trust before they become heavy silence',
          'Allow rest and pacing even when work is unfinished — consistency needs renewable energy',
        ],
      ),
      'tiger': ZodiacPersonalityProfile(
        animalKey: 'tiger',
        coreTraits:
            'You often feel most alive when action aligns with what you believe matters. '
            'You may feel uncomfortable when asked to act against your values, or when you '
            'must wait for approval from people who do not see why something feels urgent.',
        workStyle:
            'You often work best when you can see that work affects something larger than yourself '
            'and when you have freedom to decide how to act. You may stand out in roles that require '
            'questioning, pushing forward, or standing firm when others hesitate.',
        relationshipStyle:
            'You often show love through protection, standing beside someone, and not pretending '
            'not to care. You may need personal space to recover energy, but once trust is there '
            'you often offer the sense that someone will not look away when it matters.',
        strengths: [
          'You often act when others still hesitate because you see that delay would cost something important',
          'You often stay aligned with your values even when that is not popular in the moment',
          'You often motivate people around you when a goal has genuine meaning',
        ],
        challenges: [
          'You may spend more energy than the situation can absorb in that moment',
          'You may feel frustrated when controlled or labeled impatient while you see real urgency',
          'You may decide quickly before hearing views that could change direction',
        ],
        growthSuggestions: [
          'Before major action, ask who has not yet spoken and what their view might change',
          'Break large goals into steps to reduce pressure from wanting immediate results',
          'Separate what belongs to values from what belongs to mood in the moment',
        ],
      ),
      'rabbit': ZodiacPersonalityProfile(
        animalKey: 'rabbit',
        coreTraits:
            'You often sense atmosphere and how people around you feel before deciding '
            'how much to reveal. You may feel uncomfortable when pulled into direct conflict '
            'or when the environment feels competitive with no room to listen.',
        workStyle:
            'You often work best when there is trust on the team and room to care for details '
            'others may overlook. You may stand out in roles that require coordination, '
            'reading people, and creating conditions where work can continue.',
        relationshipStyle:
            'You often build closeness through listening, gentle presence, and not rushing '
            'openness faster than you are ready. You may take time to trust, but once you do '
            'you often create a sense of safety that is hard to find elsewhere.',
        strengths: [
          'You often notice when someone is uneasy even before they say so',
          'You often avoid unnecessary conflict without destroying the relationship',
          'You often attend to small details that help others feel seen',
        ],
        challenges: [
          'You may hold feelings inside, fearing that speaking will worsen the atmosphere',
          'You may hesitate for a long time when decisions affect other people’s feelings',
          'You may feel drained in competitive or pressuring environments with little room to listen',
        ],
        growthSuggestions: [
          'Express needs or boundaries gently before feelings accumulate past capacity',
          'Allow small discomfort when something important must be said — not every conflict destroys connection',
          'Choose supportive environments without avoiding every challenge that helps you grow',
        ],
      ),
      'dragon': ZodiacPersonalityProfile(
        animalKey: 'dragon',
        coreTraits:
            'You often see the world through what could be rather than what already is. '
            'You may feel energized when pushing something that feels meaningful, and frustrated '
            'when stuck in repetitive work that hides the bigger picture.',
        workStyle:
            'You often work best when you can see impact and bring people toward a shared direction. '
            'You may stand out in roles that need vision, inspiration, and starting what no one has tried yet.',
        relationshipStyle:
            'You often show care by seeing others’ potential and supporting forward movement. '
            'You may want people who understand that ambition does not mean neglect — '
            'but a wish to see everyone grow together.',
        strengths: [
          'You often see opportunity or direction others may miss while things are still unclear',
          'You often inspire people around you when a goal has real meaning',
          'You often refuse to settle for the current situation when you see a better path',
        ],
        challenges: [
          'You may set goals higher than current pace or resources allow',
          'You may feel frustrated when small tasks pull focus from the big picture you want to build',
          'You may expect too much from yourself or others and forget to honor small progress',
        ],
        growthSuggestions: [
          'Break large vision into achievable steps for each phase',
          'Acknowledge small progress — big pictures are built from many small moves',
          'Listen to detail-oriented views so vision becomes strong enough to execute',
        ],
      ),
      'snake': ZodiacPersonalityProfile(
        animalKey: 'snake',
        coreTraits:
            'You often believe good decisions come from deep understanding, not fast reaction. '
            'You may feel uncomfortable when rushed to decide before processing, or when others '
            'want answers before you see the full picture.',
        workStyle:
            'You often work best with time to analyze, plan, and choose timing before acting. '
            'You may stand out in roles that require seeing hidden risk and deciding at points '
            'others have not reached yet.',
        relationshipStyle:
            'You often build connection gradually and deeply rather than widely but shallowly. '
            'You may not show much at first, but once trust is there you often offer sincerity '
            'that does not shift with temporary mood.',
        strengths: [
          'You often see angles or risks others may miss in early stages',
          'You often avoid acting too soon on what you do not yet understand enough',
          'You often sustain focus on matters that require deep thinking',
        ],
        challenges: [
          'You may take longer to open up because you want trust to feel earned',
          'You may analyze so much that you hesitate or miss timing when sooner action would suffice',
          'You may feel uneasy in rushed, shallow environments with no time to think',
        ],
        growthSuggestions: [
          'Share some thoughts before everything feels fully settled — perfection is not required to speak',
          'Set decision deadlines to reduce endless analysis loops',
          'Join activities where not every detail must be controlled, to practice flexibility',
        ],
      ),
      'horse': ZodiacPersonalityProfile(
        animalKey: 'horse',
        coreTraits:
            'You often feel most alive when moving, learning, and seeing new direction. '
            'You may feel constrained when stuck with the same work too long, or when you '
            'cannot see where current effort leads next.',
        workStyle:
            'You often work best with freedom to choose method and a clear sense of direction. '
            'You may stand out in roles that require communication, momentum, and motivation '
            'more than repetition without meaning.',
        relationshipStyle:
            'You often build closeness through shared experience, openness, and lively energy together. '
            'You may need personal space to recover, but when together you often bring a sense of aliveness.',
        strengths: [
          'You often learn quickly from new experience and apply it to the next direction',
          'You often communicate and motivate others when direction feels clear',
          'You often refuse to stay stuck in situations that feel like dead ends',
        ],
        challenges: [
          'You may lose interest when work repeats or lacks meaningful new challenge',
          'You may move fast and forget to rest or check whether direction still fits you',
          'You may feel constrained when restricted or waiting too long for approval',
        ],
        growthSuggestions: [
          'Pause to ask whether this direction still fits you before rushing forward',
          'Balance love of movement with some sustained effort so motion does not become escape',
          'Choose goals with meaning, not only speed or novelty',
        ],
      ),
      'goat': ZodiacPersonalityProfile(
        animalKey: 'goat',
        coreTraits:
            'You often sense and care for emotional balance around you deeply. '
            'You may feel uncomfortable in tense, competitive, or cold atmospheres, '
            'and you often care how people feel — not only what work produces.',
        workStyle:
            'You often work best with cooperation, trust, and room for creative expression. '
            'You may stand out in roles that nurture people, shape atmosphere, '
            'and help quality work happen on teams that feel safe.',
        relationshipStyle:
            'You often show love through listening, caring, and staying beside someone when they are vulnerable. '
            'You may want warmth and reassurance from people you love, and may feel hurt '
            'when relationships lack gentleness.',
        strengths: [
          'You often create atmosphere where others feel safe enough to open up',
          'You often notice beauty or subtle dimensions others may overlook',
          'You often navigate differences without destroying connection',
        ],
        challenges: [
          'You may care for others’ feelings so much that you neglect your own needs',
          'You may hesitate when decisions might disappoint someone',
          'You may feel drained in competitive environments with little room for gentleness',
        ],
        growthSuggestions: [
          'Set clearer boundaries and honor your own needs — self-care is not selfishness',
          'Share your own views even when it briefly disturbs balance',
          'Choose environments that offer both warmth and room to grow',
        ],
      ),
      'monkey': ZodiacPersonalityProfile(
        animalKey: 'monkey',
        coreTraits:
            'You often feel most alive when thinking outside routine, experimenting, '
            'and finding paths that are not repeated. You may use humor or cleverness '
            'as a shortcut when situations start to feel boring or overly pressuring.',
        workStyle:
            'You often work best with fresh problems to solve and room to try different approaches. '
            'You may stand out in roles that require quick thinking, adaptation, '
            'and solutions others have not yet seen.',
        relationshipStyle:
            'You often build closeness through idea exchange, humor, and shared fun. '
            'You may prefer lively relationships, but sometimes use playfulness '
            'as refuge when deeper matters start to feel too heavy.',
        strengths: [
          'You often solve problems in ways others may not think to try',
          'You often learn quickly and adapt well to new situations',
          'You often create atmosphere where problems feel less overwhelming',
        ],
        challenges: [
          'You may lose interest when work repeats or lacks stimulating new challenge',
          'You may spread attention across many interests and fail to go deep on one',
          'You may rely on clever thinking instead of listening to feelings when situations are delicate',
        ],
        growthSuggestions: [
          'Go deeper on one thing before jumping to the next — depth can be its own reward',
          'When others share feelings, listen before offering solutions',
          'Choose projects with both challenge and longer-term meaning, not only novelty',
        ],
      ),
      'rooster': ZodiacPersonalityProfile(
        animalKey: 'rooster',
        coreTraits:
            'You often use standards and clarity to manage uncertainty in life. '
            'You may feel uncomfortable when work or relationships feel loose, disorganized, '
            'or when others ignore details you consider important.',
        workStyle:
            'You often work best with clear goals, understandable criteria, and room to protect quality. '
            'You may stand out in roles that require planning, checking, '
            'and bringing started work to a reliable finish.',
        relationshipStyle:
            'You often show care through attention, guidance, and steady seriousness. '
            'You may be direct because you believe honesty matters more than temporary comfort, '
            'and you often want sincerity from others as well.',
        strengths: [
          'You often bring started work to quality completion, not just a strong beginning',
          'You often see details that could become larger problems if ignored early',
          'You often speak directly to prevent misunderstanding from lingering',
        ],
        challenges: [
          'You may be strict with yourself or others when standards are not met',
          'You may feel uneasy when work or people fall below what you expected',
          'You may speak so directly that it affects feelings without intending harm',
        ],
        growthSuggestions: [
          'Allow workable imperfection — good standards do not require perfect form',
          'Listen to how others see their reasons before judging or advising',
          'Acknowledge progress, not only what is still missing — seeing what is done is also a standard',
        ],
      ),
      'dog': ZodiacPersonalityProfile(
        animalKey: 'dog',
        coreTraits:
            'You often care deeply about fairness, sincerity, and trust in relationships. '
            'You may feel uncomfortable witnessing injustice, dishonesty, or when people '
            'you care about act against values you hold.',
        workStyle:
            'You often work best when work aligns with your values and the team offers mutual trust. '
            'You may stand out in roles that require reliability, responsibility, '
            'and standing beside others when something important happens.',
        relationshipStyle:
            'You often show love through sincerity, steady presence, and not pretending not to see '
            'when someone you love needs support. You may take time to trust, but once bonded '
            'you often offer confidence that does not shift with temporary mood.',
        strengths: [
          'You often stand by your values even when inconvenient',
          'You often become someone others know will not disappear when things get hard',
          'You often work seriously when you believe the work is meaningful and fair',
        ],
        challenges: [
          'You may worry about fairness or trust so much that you forget to give others room',
          'You may feel disappointed when others fall short of standards you hold',
          'You may keep hurt inside instead of saying what reduced your trust',
        ],
        growthSuggestions: [
          'Share concerns with people you trust before distance becomes unnecessary',
          'Ask what reasons others might have instead of judging unfairness immediately',
          'Choose environments that offer genuine trust and fairness, not only words',
        ],
      ),
      'pig': ZodiacPersonalityProfile(
        animalKey: 'pig',
        coreTraits:
            'You often care about comfort, sincerity, and relationships that feel deep. '
            'You may feel uncomfortable in pressuring atmospheres lacking warmth, '
            'or when competition makes people around you feel worse.',
        workStyle:
            'You often work best when work feels meaningful and the team offers trust. '
            'You may stand out in roles that require cooperation, care, '
            'and building atmosphere where everyone can work sustainably.',
        relationshipStyle:
            'You often build closeness through sincerity, warmth, and steady presence without pretense. '
            'You may value relationships that feel deep and lasting more than wide but shallow connection.',
        strengths: [
          'You often create ease so others feel they do not have to perform a different self',
          'You often prioritize real connection over status or surface outcomes',
          'You often work well on teams built on trust and sincerity',
        ],
        challenges: [
          'You may prioritize others’ comfort over your own boundaries',
          'You may avoid conflict or pressure even when facing them would support growth',
          'You may take longer to decide when relationships you value are affected',
        ],
        growthSuggestions: [
          'Express your needs and boundaries clearly — gentleness does not require agreeing to everything',
          'Accept small challenges that support growth even if uncomfortable at first',
          'Choose settings that offer both warmth and room to develop',
        ],
      ),
    },
  };
}
