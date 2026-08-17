# Copy-normalization impact

Decision: **retained, PR remains Draft pending Owner review**.

The normalization changes only the `summary` field, replacing `ต่อไปมีโอกาสใหม่เข้ามาจากงานหรือคนรู้จัก` with the accepted cautious opportunity wording (or removing the duplicate when allocation already owns the idea). It is a reader-visible product-copy change, separate from stable hashing.

Disabling this normalization with the repaired hash/arithmetic code makes the accepted frozen `owner-unknown` canonical fixture fail. It therefore cannot be removed while preserving frozen R7.1 exact 5/5. Raw failure: `copy-normalization-disabled-failure.log`.

Across the deterministic 300 cases, the exact scope is 93 profiles and 112 fields; all 112 are `summary` fields. Structured profile facts and period score signatures are unchanged. The affected case IDs are:

`S004, S008, S009, S011, S012, S014, S018, S019, S021, S022, S028, S030, S032, S038, S040, S041, S048, S049, S050, S051, S057, S059, S061, S073, S080, S084, S086, S087, S090, S094, S098, S100, S102, S104, S108, S114, S118, S120, S121, S123, S124, S126, S127, S129, S131, S135, S139, S141, S143, S145, S149, S155, S156, S158, S160, S164, S166, S169, S170, S180, S186, S188, S193, S200, S201, S207, S209, S211, S213, S215, S219, S223, S231, S236, S237, S238, S239, S242, S246, S250, S252, S264, S266, S268, S270, S273, S275, S279, S280, S283, S289, S291, S297`.

The normalization is deterministic and the final VM/Chrome impact manifests match exactly. S008's raw one-ULP audit value remains disclosed, while its fixed-point degree, snapshot, report hash and narrative now match exactly across runtimes. Because the copy scope is reader-visible, this PR must remain Draft until Owner review even though the technical cross-runtime gate passes. The complete profile/section/period/source/before/after ledger is `copy-normalization-owner-review-ledger-s008.json`; the concise decision packet is `copy-normalization-owner-review-s008.md`.
