# Root cause

R4 ประกอบ Past ด้วยประโยคสองแม่แบบ แล้วแทนค่า phase, age, keyword และ domain title จึงทำให้ช่วงวัย 1–10 และ 1–6 กล่าวถึงการงาน/การเงิน และทำให้ pair similarity สูง ตัว audit เดิมตรวจเฉพาะ forecast body ด้วย character n-gram ที่ไม่ได้ normalize Past slots จึงรายงานศูนย์ผิดขอบเขต

Freshness อีกเส้นทางหนึ่ง split canonical text เป็นบรรทัด ขณะที่ `consumer-unit-audit.json` นับ structured document units จึงได้ 220 กับ 235 คนละ denominator และ static labels บางรายการถูกนับเป็น narrative

R5 แก้ที่ต้นเหตุ:

- resolver เลือกบริบทวัยจาก overlap มากที่สุดในช่วง 1–10, 11–17, 18–29 และ 30+
- theme/question ของแต่ละวัยใช้โครงความคิดต่างกันและถามให้เทียบกับความทรงจำ
- Unknown current work/finance/health ใช้ conditional observable framing
- similarity ตัด prefix, age, phase และ theme slots แล้วใช้ Unicode character trigrams พร้อม skeleton equality
- metrics อ่าน counted units และ unit IDs จาก consumer audit เท่านั้น พร้อม invariant checks
