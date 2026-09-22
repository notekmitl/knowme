# Western Reader V2 — Thai Readability Revision

Status: **DRAFT PR — OWNER REVIEW REQUIRED — NOT MERGED — NOT DEPLOYED**

## Scope and source of the old wording

The Western reading is deterministic. The awkward Production phrases came from
`backend/app/services/astrology/reader.py`, not from an AI prompt. This revision
changes only the Western Thai composer and its presentation. Tropical Zodiac,
Swiss Ephemeris, planets, Ascendant, Placidus houses, aspects, normalized input,
Auth, Firestore paths, Fusion, Thai astrology, and BaZi remain unchanged.

The primary reading now leads with observable behavior, likely consequences,
and a caution or practical use. Exact signs, houses, and aspects appear in the
secondary `ที่มาทางโหราศาสตร์` line. Detailed chart structure is collapsed by
default on the result page.

## Cache revision

- Chart schema remains `western_natal_v2`.
- Contract remains `knowme_western_reader_v2`.
- Thai reader revision changes from `western_reader_th_v2` to
  `western_reader_th_v2_r2`.
- A cached chart with the old reader revision fails the client freshness gate
  once, performs one authenticated generation POST, and overwrites the same
  `users/{uid}/astrology/western_natal` document through the existing backend
  save path.
- The newly saved revision is accepted on the next visit, so the normal cache
  hit remains one `western_natal` read and zero POSTs.

No Firestore schema or cache document path changes.

## Owner case — generated sample

This sample is generated from the candidate source, not handwritten separately.

- Birth: 6 June 1982, 00:03, Chiang Mai
- Local civil: `1982-06-06T00:03:00+07:00`
- UTC: `1982-06-05T17:03:00Z`
- Big Three: Gemini Sun / Sagittarius Moon / Pisces Rising
- Reader revision: `western_reader_th_v2_r2`

### ภาพรวม

คุณเป็นคนช่างสงสัย เรียนรู้เร็ว และสนใจหลายเรื่อง ลึก ๆ ต้องการอิสระในการคิด แต่ภาพแรกที่คนอื่นเห็นเป็นคนอ่อนโยนและปรับตัวเก่ง จึงอาจมีคนคิดว่าคุณตามใจง่าย ทั้งที่จริงคุณมีความคิดเห็นและต้องการพื้นที่ตัดสินใจของตัวเอง

### ตัวตนและวิธีตัดสินใจ

คุณเป็นคนช่างสงสัย เรียนรู้เร็ว และสนใจหลายเรื่อง เมื่อเป็นเรื่องส่วนตัว คุณต้องการอิสระในการคิด แต่ภาพแรกที่คนอื่นเห็นเป็นคนอ่อนโยนและปรับตัวเก่ง จึงมีคนคิดว่าคุณตามใจง่าย ทั้งที่จริงคุณมีความคิดเห็นและต้องการพื้นที่ตัดสินใจของตัวเอง จุดที่ควรระวังคือปล่อยให้ภาพแรกกลบความต้องการจริง หากบอกความเห็นและขอบเขตตั้งแต่ต้น คนรอบตัวจะเข้าใจทั้งท่าทีภายนอกและความต้องการจริงของคุณได้ครบกว่าเดิม

ที่มาทางโหราศาสตร์: ดวงอาทิตย์ราศีเมถุน · ดวงจันทร์ราศีธนู · ลัคนาราศีมีน

### การงานและวิธีทำงาน

เวลาทำงาน คุณเรียนรู้ไว เชื่อมข้อมูลหลายชุด และอธิบายเรื่องยากให้คนตามทัน เมื่อต้องผลักงานให้เดิน คุณขับเคลื่อนผ่านการเจรจาและการแบ่งบทบาทที่เป็นธรรม คุณทำงานได้ดีเมื่อได้แก้โจทย์ เรียนรู้เร็ว เปลี่ยนบทบาท หรือเชื่อมหลายฝ่าย ผลจะชัดที่สุดเมื่อบทบาทและผลลัพธ์ที่ต้องส่งมอบถูกระบุไว้ตรงกัน จุดที่ควรระวังคือการรับโจทย์ตามจังหวะถนัดจนลืมเกณฑ์จบงาน ทางที่ช่วยคือกำหนดงานหลักหนึ่งชิ้นและเกณฑ์จบให้ชัดเพื่อไม่ให้การปรับตัวกลายเป็นงานกระจาย

ที่มาทางโหราศาสตร์: ดาวพุธราศีเมถุน · ดาวอังคารราศีตุลย์

### การเงินและการใช้ทรัพยากร

เรื่องเงิน คุณให้ค่ากับคุณภาพ ความสบาย และสิ่งที่อยู่ได้นาน จึงมักยอมจ่ายมากขึ้นเมื่อเชื่อว่าของนั้นคุ้มและใช้จริง รายได้ ทรัพยากรส่วนตัว และความรู้สึกว่าตนมีคุณค่าเชื่อมกันมากขึ้น การตั้งราคาหรือเกณฑ์ใช้เงินให้ชัดจึงสำคัญ จุดที่ควรระวังคือการตัดสินใจตามคุณค่าที่รู้สึกในขณะนั้นมากกว่าแผนรวม วิธีที่ช่วยคือแยกคำว่าใช้ได้นานออกจากการสะสมเกินจำเป็น

ที่มาทางโหราศาสตร์: ดาวศุกร์ราศีพฤษภ · ดาวศุกร์ในเรือน 2

### ความรักและการอยู่ร่วมกัน

ในความสัมพันธ์ คุณแสดงความรักผ่านความสม่ำเสมอ การสัมผัส และการดูแลที่จับต้องได้ และขณะเดียวกันคุณต้องการอิสระในการคิด ความสัมพันธ์มั่นคงเมื่อคำพูดตรงกับการกระทำ คุณเชื่อมความต้องการกับการแสดงออกได้ค่อนข้างเป็นธรรมชาติ เมื่อบอกให้ชัดอีกฝ่ายจึงเข้าใจความรู้สึกของคุณได้ง่ายขึ้น จุดที่ควรระวังคือการคาดหวังให้อีกฝ่ายเข้าใจจังหวะนี้เอง ทางที่ช่วยคือพูดเรื่องที่ไม่สบายใจก่อนความเงียบจะกลายเป็นการยื้อ

ที่มาทางโหราศาสตร์: ดาวศุกร์ราศีพฤษภ · ดวงจันทร์ราศีธนู · ดวงจันทร์ทำมุม 60°ดาวอังคาร

### การดูแลพลังใจและกิจวัตร

คุณฟื้นพลังได้ดีเมื่อได้เปลี่ยนบรรยากาศ เรียนรู้ หรือมองเรื่องนั้นจากภาพใหญ่ ใจกลับมามีพลังเมื่อเห็นว่าตนยังมีทางเลือก กิจวัตรที่สม่ำเสมอจะช่วยไม่ให้อารมณ์หรือแรงกระตุ้นพาแผนทั้งวันเปลี่ยนไป จุดที่ควรระวังคือการคิดหลายทางพร้อมกันอาจทำให้เรื่องสำคัญค้างอยู่ในขั้นวิเคราะห์ ทางที่ช่วยคืออย่ารีบหนีรายละเอียดที่ยังต้องรับผิดชอบ คำอ่านนี้กล่าวถึงรูปแบบการใช้พลัง ไม่ใช่การวินิจฉัยสุขภาพ

ที่มาทางโหราศาสตร์: ดวงจันทร์ราศีธนู · ธาตุลม

### จุดแข็ง

คุณเรียนรู้ไว เห็นหลายมุม และเชื่อมข้อมูลหรือผู้คนเข้าหากันได้ จุดแข็งนี้เด่นขึ้นเมื่อคุณใช้การตัดสินใจจากตัวตนและเป้าหมาย จึงมักเกิดผลดีเมื่อคุณรับบทที่ได้ใช้ความสามารถนี้กับปัญหาชัดเจน รักษาขอบเขตของงานแล้ววัดผลจากสิ่งที่เกิดขึ้นจริง

ที่มาทางโหราศาสตร์: ธาตุลม · ดาวเด่น ดวงอาทิตย์

### รูปแบบที่ควรระวัง

การคิดหลายทางพร้อมกันอาจทำให้เรื่องสำคัญค้างอยู่ในขั้นวิเคราะห์ เมื่อแรงขับสองด้านต้องการคำตอบคนละแบบ คุณอาจรีบตอบสนองด้านหนึ่งก่อนเข้าใจอีกด้าน จุดที่ควรระวังคือการตัดสินใจเพื่อจบความไม่สบายใจเร็วเกินไป ทางที่ช่วยคือเว้นจังหวะ ตั้งชื่อสิ่งที่กำลังขัดกัน แล้วเลือกการตอบที่รับผิดชอบได้

ที่มาทางโหราศาสตร์: ธาตุลม · ดวงจันทร์ทำมุม 180°ดาวพุธ

### แนวทางนำไปใช้

แยกช่วงสำรวจออกจากช่วงตัดสินใจและกำหนดเส้นตายให้ทางเลือกหลัก วิธีนี้ช่วยให้ความสามารถหลักของคุณเปลี่ยนจากความถนัดเป็นผลลัพธ์ที่คนอื่นเข้าใจและร่วมมือได้ ทบทวนหลังจบแต่ละช่วงว่าอะไรได้ผล อะไรควรหยุด และเรื่องใดควรเป็นลำดับถัดไป

ที่มาทางโหราศาสตร์: ธาตุลม · จังหวะปรับตัว

### วิธีคำนวณและข้อจำกัด

คำนวณแบบ Tropical Zodiac ด้วย Swiss Ephemeris ใช้เวลาเกิดท้องถิ่น เขตเวลา IANA พิกัดเกิด ระบบเรือน Placidus และมุมสัมพันธ์หลัก

ผลนี้เป็นการอ่านแนวโน้มจากดวงกำเนิดเพื่อช่วยทบทวนและวางแผน ไม่ใช่ข้อยืนยันว่าเหตุการณ์ใดต้องเกิดขึ้น

## Validation summary

- Owner UTC and Big Three are unchanged.
- Backend suite passes `48/48`; the focused Flutter scope passes `24/24`; and
  the full Flutter suite passes `3,097/3,097`.
- Repository analyzer policy exits `0` with `275` inherited non-fatal
  diagnostics; analysis of the changed Dart source and tests reports no issues.
- The Production Web release build passes with the current Production API base
  URL. This build was a local verification artifact only and was not deployed.
- Eight deterministic fixtures cover fire, earth, air, water and cardinal,
  fixed, mutable. Their readings remain distinct after sign names are removed.
- Tests verify that every displayed planet/sign, relevant house, and aspect basis
  exists in the actual calculated chart.
- The banned phrases are absent, and the five primary section bodies do not
  insert sign/house/aspect labels into the reader-first prose.
- Same-machine reader microbenchmark: baseline `0.002342 ms`, revision
  `0.006885 ms`, absolute delta `0.004543 ms` per composition.
- Full chart benchmark: three cases × 500 iterations, medians
  `0.202–0.204 ms`, below the `25 ms` gate.

This document is candidate evidence only. Production remains on application
commit `de0a83bdfbb18532471ba58e539e7d0b6cf553a4`, Hosting release
`1789977665171000`, version `4065a55e03f5aa1e` until Owner approval and a
separately authorized merge/deployment flow.
