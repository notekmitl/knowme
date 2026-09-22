# Western Reader V2 — Thai Readability Revision

Status: **OWNER-ACCEPTED — PR #146 MERGED AND DEPLOYED — LATENCY CLOSEOUT PENDING**

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

คุณเป็นคนช่างสงสัย เรียนรู้เร็ว และสนใจหลายเรื่อง คุณต้องการอิสระในการคิด คนรอบตัวมักเห็นคุณเป็นคนอ่อนโยนและปรับตัวเก่งก่อน จึงอาจคิดว่าคุณตามใจง่าย ทั้งที่จริงคุณมีความคิดเห็นและต้องการพื้นที่ตัดสินใจของตัวเอง

### ตัวตนและวิธีตัดสินใจ

เมื่อมีหลายทางให้เลือก คุณมักเก็บข้อมูลและเปรียบเทียบหลายทางเพื่อให้เห็นข้อดีข้อเสียครบ ถ้าความคิดกับความรู้สึกไม่ตรงกัน คุณอาจเก็บทุกทางเลือกไว้เพราะยังไม่อยากเสียอิสระในการตัดสินใจ ท่าทีที่อ่อนโยนอาจทำให้คนอื่นเร่งให้คุณตอบหรือคิดว่าคุณยอมตาม ทั้งที่คุณยังประเมินทางเลือกอยู่ จุดที่ควรระวังคือปล่อยให้จำนวนทางเลือกหรือความเห็นของคนอื่นยืดเวลาตัดสินใจ วิธีที่เหมาะคือลดให้เหลือไม่เกินสามทาง เขียนผลดีผลเสียของแต่ละทาง แล้วบอกเหตุผลของคุณให้คนที่เกี่ยวข้องรู้

ที่มาทางโหราศาสตร์: ดวงอาทิตย์ราศีเมถุน · ดวงจันทร์ราศีธนู · ลัคนาราศีมีน

### การงานและวิธีทำงาน

เวลาทำงาน คุณเรียนรู้ไว เชื่อมข้อมูลหลายชุด และอธิบายเรื่องยากให้คนตามทัน เมื่อต้องผลักงานให้เดิน คุณขับเคลื่อนผ่านการเจรจาและการแบ่งบทบาทที่เป็นธรรม คุณทำงานได้ดีเมื่อได้แก้โจทย์ เรียนรู้เร็ว เปลี่ยนบทบาท หรือเชื่อมหลายฝ่าย ผลจะชัดที่สุดเมื่อบทบาทและผลลัพธ์ที่ต้องส่งมอบถูกระบุไว้ตรงกัน จุดที่ควรระวังคือการรับโจทย์ตามจังหวะถนัดจนลืมเกณฑ์จบงาน ทางที่ช่วยคือกำหนดงานหลักหนึ่งชิ้นและเกณฑ์จบให้ชัดเพื่อไม่ให้การปรับตัวกลายเป็นงานกระจาย

ที่มาทางโหราศาสตร์: ดาวพุธราศีเมถุน · ดาวอังคารราศีตุลย์

### การเงินและการใช้ทรัพยากร

เรื่องเงิน คุณให้ค่ากับคุณภาพ ความสบาย และสิ่งที่อยู่ได้นาน จึงมักยอมจ่ายมากขึ้นเมื่อเชื่อว่าของนั้นคุ้มและใช้จริง คุณอาจรู้สึกมั่นใจขึ้นเมื่อการเงินมั่นคง การมีเงินสำรองและวงเงินใช้จ่ายที่ชัดจึงช่วยให้ตัดสินใจได้โดยไม่กังวลเกินไป ก่อนซื้อให้แยกว่าเป็นของที่ใช้บ่อยจริง หรือซื้อเพราะรู้สึกว่าเก็บไว้แล้วอุ่นใจ

ที่มาทางโหราศาสตร์: ดาวศุกร์ราศีพฤษภ · ดาวศุกร์ในเรือน 2

### ความรักและการอยู่ร่วมกัน

ในความสัมพันธ์ คุณแสดงความรักผ่านความสม่ำเสมอ การสัมผัส และการดูแลที่จับต้องได้ และขณะเดียวกันคุณต้องการอิสระในการคิด ความสัมพันธ์มั่นคงเมื่อคำพูดตรงกับการกระทำ เวลาต้องการการดูแล คุณมักบอกออกมาและตอบรับอีกฝ่ายด้วยการกระทำ จึงลดโอกาสเข้าใจผิด คุณควรบอกตรง ๆ ว่าอะไรไม่สบายใจ แทนการเงียบรอให้อีกฝ่ายเดา

ที่มาทางโหราศาสตร์: ดาวศุกร์ราศีพฤษภ · ดวงจันทร์ราศีธนู · ดวงจันทร์ทำมุม 60°ดาวอังคาร

### การดูแลพลังใจและกิจวัตร

คุณฟื้นพลังได้ดีเมื่อได้เปลี่ยนบรรยากาศ เรียนรู้ หรือมองเรื่องนั้นจากภาพใหญ่ ใจกลับมามีพลังเมื่อเห็นว่าตนยังมีทางเลือก กิจวัตรที่สม่ำเสมอจะช่วยไม่ให้อารมณ์หรือแรงกระตุ้นพาแผนทั้งวันเปลี่ยนไป การเปลี่ยนบรรยากาศช่วยพักใจได้ แต่ควรกำหนดเวลากลับมาจัดการเรื่องที่ยังค้าง

ที่มาทางโหราศาสตร์: ดวงจันทร์ราศีธนู · ธาตุลม

### จุดแข็ง

คุณเรียนรู้ไว เห็นหลายมุม และเชื่อมข้อมูลหรือผู้คนเข้าหากันได้ คุณจึงเหมาะกับงานหรือบทบาทที่ต้องกำหนดทิศทาง ตัดสินใจ และรับผิดชอบเป้าหมายร่วม ก่อนรับงาน ควรถามว่าคุณต้องตัดสินใจเรื่องใด และใครจะนำผลจากงานนั้นไปใช้ต่อ

ที่มาทางโหราศาสตร์: ธาตุลม · ดาวเด่น ดวงอาทิตย์

### รูปแบบที่ควรระวัง

การคิดหลายทางพร้อมกันอาจทำให้เรื่องสำคัญค้างอยู่ในขั้นวิเคราะห์ บางครั้งสิ่งที่คิดว่าควรทำกับสิ่งที่รู้สึกจริงอาจไม่ตรงกัน เมื่อเกิดความลังเล คุณอาจรีบเลือกเพื่อให้ความอึดอัดจบลง ควรเขียนว่าส่วนใดเป็นข้อเท็จจริงและส่วนใดเป็นความรู้สึกก่อนตอบ

ที่มาทางโหราศาสตร์: ธาตุลม · ดวงจันทร์ทำมุม 180°ดาวพุธ

### แนวทางนำไปใช้

กำหนดเวลาหาข้อมูลและวันที่ต้องตัดสินใจ เมื่อเลือกแล้วให้ทำทีละเรื่อง ทบทวนผลก่อนเริ่มทางเลือกใหม่

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
- The overview is shorter than and not contained in identity. Regression tests
  require the Owner-requested behavioral phrases and reject the superseded
  abstract phrases at deterministic-composer output.
- Same-machine feedback benchmark: pre-feedback PR HEAD `0.006662 ms`, revised
  composer `0.006576 ms`, delta `-0.000086 ms` per composition.
- Full chart benchmark: three cases × 500 iterations, medians
  `0.204681–0.206452 ms`, below the `25 ms` gate.

This document is candidate evidence only. Production remains on application
commit `de0a83bdfbb18532471ba58e539e7d0b6cf553a4`, Hosting release
`1789977665171000`, version `4065a55e03f5aa1e` until Owner approval and a
separately authorized merge/deployment flow.
