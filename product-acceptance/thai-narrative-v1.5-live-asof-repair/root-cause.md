# Root cause

## Proven conclusion

The Production text mismatch was not caused by the analysis date. It was caused by runtime-dependent hashing in reader-visible content selection.

1. The accepted Dart VM replay at explicit `asOf = 2026-08-07` produced canonical SHA-256 `08F446D1B72A10F985B80C34702785A4DE61AB96DE5DC01374837876D32396E3` for `owner-known-0035`.
2. Replaying the narrowest Production evidence interval (`2026-08-16T16:15:15.572116` through `16:19:44.454535` Asia/Bangkok) in the VM produced the same accepted phrases and same canonical hash throughout the sampled range. Therefore Clock B did not reproduce either Production mismatch phrase.
3. The pre-repair compiled Web application, using the same V1.5 source and exact fixture, reproduced the rollback Production extracted text byte-for-byte. The original Production extraction and local compiled-Web extraction share SHA-256 `6BAD114543DF6163357F25F51A4594927FC3E6E846571AA6C356A6E6BD2DC800`.
4. Presentation seeds used `String.hashCode` and `Object.hash`. Dart does not promise those values across runtimes. The VM and compiled JavaScript selected different reader-visible variants even though engine facts, periods, input and source were unchanged.
5. Replacing every affected selection hash with the stable compatibility hash restored the accepted presenter seed `28924034132` and accepted phrases in compiled Web. There is no random, PDF, font, cache, or exporter cause.

## Exact mismatch

- Production finance: `ด้านการเงินคุณต้องคิดเรื่องเก็บเงินและความมั่นคงก่อนเรื่องอื่น`
- Accepted finance: `ด้านการเงินคุณอยากใช้เงินวันนี้ แต่ยังต้องเก็บเพื่อแผนระยะยาว`
- Production next transition: `ต่อไปงานที่เคยทำแบบเดิมเริ่มเปลี่ยนไป`
- Accepted next transition: `ต่อไปงานและหน้าที่บังคับให้คุณจัดลำดับชีวิตใหม่`

The mismatch is reproduced only by the pre-repair compiled-JavaScript selection path, not by changing `asOf` in the VM.

## Repair

`ThaiMirrorStableHash` reproduces the Dart 3.11 VM string hash algorithm used when R7.1 was accepted. All affected `String.hashCode` and `Object.hash` selection sites now use it. Two semantically identical structured opportunity forms are normalized to the cautious sentence already present in accepted V1.5 output; no new claim is introduced.

Separately, the release clock contract now records submit time once, resolves it to an Asia/Bangkok civil timestamp, stores it as `analysis.asOf`, and passes that same value to the pipeline, presenter and narrative context. This prevents future verification from conflating session duration with analysis date.
