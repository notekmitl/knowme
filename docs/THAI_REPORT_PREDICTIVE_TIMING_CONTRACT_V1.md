# Thai Report Predictive Timing Contract V1

สถานะ: **PROPOSED CONTRACT — NO APPROVED WITHIN-YEAR CALCULATION — `monthlyTimelineAvailable=false`**

## Current capability

ระบบคำนวณ rolling horizon จาก `asOf` ได้เป็นช่วงเดียว และคำนวณ life-period/annual-Taksa boundary ได้ แต่ยังไม่มี approved Canon rule ที่แบ่ง 12 เดือนเป็นช่วงต้น กลาง ท้าย หรือเดือน พร้อม event evidence เฉพาะช่วง การตัดปีเป็นสามส่วนเท่ากันไม่ใช่หลักฐานโหราศาสตร์และห้ามใช้

## Required deterministic timing output

```text
PredictiveTimingWindow {
  timingWindowId: String
  horizon: next12Months
  startBoundary: ZonedInstant
  endBoundary: ZonedInstant
  timezone: Asia/Bangkok
  asOf: ZonedInstant
  calculationBasis: String
  sourcePath: List<String>
  supportedEventFamilies: Set<EventFamily>
  evidenceAtomIds: List<String>
  priority: Integer[0..100]
  conflictResolutionTrace: List<String>
  knownTimeRequired: Boolean
  unknownBehavior: omit | useApprovedDateOnlyWindow
}
```

## Boundary rules

1. Rolling horizon เริ่มที่ `asOf` ใน `Asia/Bangkok` และสิ้นสุดก่อน anniversary เดียวกันของปีถัดไปหนึ่งหน่วยเวลาที่ presentation ใช้ เอกสาร Phase 1 fixture ใช้ 29 ส.ค. 2569 – 28 ส.ค. 2570
2. Subwindow เริ่ม/จบได้เฉพาะ boundary ที่ calculation method อนุมัติส่งออก เช่น exact transition, annual-Taksa boundary หรือวิธีใหม่ที่ Owner อนุมัติ
3. ห้ามใช้เลขเดือนแบบสุ่ม ห้ามหาร 12 เดือนเป็นสามส่วน และห้ามย้าย boundary เพื่อให้ตรง Golden
4. Birth timezone, place และ Thai-day basis ต้องมาจาก normalized input เดียวกับ report
5. `asOf` ต้องถูก pin ใน test fixture และเป็นค่าปัจจุบันจริงใน production ตาม horizon contract ที่มีอยู่

## Event selection

1. Window เลือกได้เฉพาะ atom ที่ `startBoundary/endBoundary` อยู่ในหรือ intersect window ตามกฎที่ระบุ
2. Event family ต้องมี status `CURRENTLY_DERIVABLE` หรือ rule ที่ Owner อนุมัติแล้ว
3. หาก score สูงแต่ไม่มี event resolver ให้แสดง domain tendency ที่ horizon รวม ห้ามตั้งชื่อเหตุการณ์
4. เลือก primary event ด้วย deterministic `priority`, `strength`, `certaintyRole`, source order และ stable ID ตามลำดับ ห้าม random
5. Advice ไม่เข้าร่วม event selection และห้ามสร้าง timing ใหม่

## Conflict resolution

ลำดับตัดสิน: direct calculated fact > approved event atom > approved risk/opportunity atom > domain tendency ต่าง certainty กันต้องไม่รวมเป็นประโยคเดียว หาก atoms ขัดกัน ให้เก็บทั้งสองเป็น tension พร้อม trace หรือ omit ตาม approved rule ห้ามให้ copywriterเลือกว่าอันใดจริง

## Empty-bucket behavior

- ไม่มี atom ใน window: ไม่สร้างข้อความแทน ไม่ยืมข้อความจาก horizon อื่น และไม่แสดง bucket ว่าง
- มีเพียง domain score: แสดงเฉพาะ rolling 12-month tendency รวม
- ไม่มี approved subwindow ทั้งระบบ: `monthlyTimelineAvailable=false` และไม่มี early/middle/late cards

## Known / Unknown

- Known ใช้ time-dependent window ได้เฉพาะเมื่อ atom ระบุ `knownTimeRequired=true` และ provenance ครบ
- Unknown ตัด atom ที่ต้องใช้เวลาเกิดก่อน selection; ห้ามใช้ noon fallback, ascendant, houses หรือ Thai-day assertion
- Date-only rule สำหรับ Unknown ต้องได้รับอนุมัติแยกและระบุ `knownTimeRequired=false`; มิฉะนั้นแสดง horizon รวมที่มี evidence เท่านั้น

## Traceability and fixture safety

ทุก window ต้อง trace ไปยัง calculation method, source path, input hash, timezone, asOf, boundary และ atom IDs การทดสอบต้องมีอย่างน้อย Known 00:03, Known 00:35, Unknown และ population audit ห้าม branch ตามชื่อ fixture วันเกิด เวลา พิกัด expected degree หรือ Golden sentence

## Owner decision gate

ยังไม่มี Canon basis ที่อนุมัติสำหรับ within-year event timing จึงไม่มี proposed implementation algorithm ในเอกสารนี้ สิ่งที่ต้องตัดสินก่อน implement คือ calculation basis, event resolver, conflict policy, Unknown availability และ certainty wording จนกว่าจะครบ ให้คง rolling range เดียวและ `monthlyTimelineAvailable=false`
