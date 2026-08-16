# Canonical diffs

## Rollback Production vs frozen R7.1

The original rollback Production PDF is 39,370 bytes, SHA-256 `5F706E04462DEA15716F09C3B8230C03DA34D2CF02B9C0C3E11BBBFCDC47C49B`. The pre-repair local compiled-Web PDF is also 39,370 bytes; its PDF binary differs, but its extracted text is byte-identical to Production. Both extracted texts have SHA-256 `6BAD114543DF6163357F25F51A4594927FC3E6E846571AA6C356A6E6BD2DC800`.

Materially differing excerpts:

| Location | Rollback Production / pre-repair compiled Web | Frozen accepted / post-repair |
|---|---|---|
| Current finance | `ด้านการเงินคุณต้องคิดเรื่องเก็บเงินและความมั่นคงก่อนเรื่องอื่น` | `ด้านการเงินคุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว` |
| Next transition | `ต่อไปงานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป` | `ต่อไปงานและหน้าที่บังคับให้คุณจัดลำดับชีวิตใหม่` |

The two phrases are reproduced by the pre-repair compiled Web runtime. Explicit VM Clock B does not reproduce them.

## Post-repair

- Owner Known canonical Web/PDF SHA-256: `08F446D1B72A10F985B80C34702785A4DE61AB96DE5DC01374837876D32396E3`.
- Frozen accepted Web/PDF exact: 5/5.
- Live-date Web/PDF exact: 5/5.
- Same live `asOf`, repeated analysis with a different session start: exact 5/5.

The binary PDF SHA is not used as a cross-date canonical gate because PDF metadata can differ. Extracted canonical text is compared to the same-source, same-`asOf` oracle.
