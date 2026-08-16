# Root cause

R5 ตรวจ consumer unit ทั้งก้อน หลัง normalize slot บางชนิด จึงรายงานความแตกต่างเมื่อหัวประโยคต่างกันแม้ท้ายประโยคหรือ skeleton ยังซ้ำข้าม domain/horizon. Composer ยังให้แต่ละบล็อกสรุปด้วย suffix ร่วมกัน ทำให้ Hook, Current, 12 months และ Next phase เปลี่ยนคำนามแต่ไม่ได้เปลี่ยนหน้าที่ของข้อความ.

R6 แก้ที่โครงสร้าง:

- report plan กำหนด central thesis, primary/secondary motif, phase และ evidence signature ก่อนแต่งข้อความ
- Current เป็นการตัดสินใจและ observable boundary; 12 months เป็น trigger/if-then/checkpoint; Next phase เป็นทิศทางกับผลระยะยาว; Closing รวมเป็นการตัดสินใจเดียว
- แต่ละ forecast claim มี ownership ตาม domain และบริบทเฉพาะรายงาน จึงไม่ต้องพึ่ง random synonym
- Known Core แปลลัคนา/เจ้าเรือน/เรือนราย domain เป็นความหมายภาษาคน; Unknown ตัด time-dependent evidence ออกและใช้รูปแบบที่สังเกตได้
- audit แยก sentence/clause และตรวจ exact prefix, suffix, skeleton และ Unicode character similarity สำหรับ clause ที่ normalize แล้วยาวอย่างน้อย 18 อักขระ
- callbacks ต้องมี claim ต้นทางและ new information; consumer prose ไม่ถูก exclude เพื่อทำให้ gate ผ่าน
