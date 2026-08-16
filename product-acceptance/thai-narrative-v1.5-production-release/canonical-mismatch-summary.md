# Canonical mismatch summary

Fixture: `owner-known-0035`

After removing only page-number markers and collapsing whitespace, the Production PDF extraction was not byte-identical to the accepted R7.1 PDF extraction or canonical reference. The character-level deterministic diff reported four replacement opcodes spanning two reader-facing passages:

1. Current-period finance
   - Production: `ด้านการเงินคุณต้องคิดเรื่องเก็บเงินและความมั่นคงก่อนเรื่องอื่น`
   - Accepted: `ด้านการเงินคุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว`
2. Next-period transition
   - Production: `ต่อไปงานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป`
   - Accepted: `ต่อไปงานและหน้าที่บังคับให้คุณจัดลำดับชีวิตใหม่`

The surrounding text, expected 7-page count, and Aquarius `19°19′` fact were retained, but the authorization requires exact accepted canonical output. This mismatch is therefore blocking regardless of the high overall sequence similarity.

The accepted artifact runner fixes `startedAt` to `2026-08-07`; the real Production form sets the analysis start/as-of value from the wall clock. That is a plausible divergence point, not a proven root cause. No source repair was attempted in this release task.
