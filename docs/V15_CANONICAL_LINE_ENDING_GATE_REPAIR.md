# V1.5 Canonical Line-Ending Gate Repair

Date: 2026-08-18

Base: `bb85b07c643bc35cef076df066cb191f2f0a7d24`

Scope: test/comparison contract only

The mandatory exact-text gate failed on Windows because canonical fixture Git blobs use LF, the generated pipeline uses LF, and the system Git configuration materializes unspecified text paths with CRLF. A ten-comparison byte probe proved that replacing only CRLF and standalone CR with LF yields exact Git-blob/pipeline identity with no other character or semantic change.

The repair introduces a narrow test helper that records raw and normalized hashes, canonicalizes only line endings, rejects any pipeline CR, and retains exact equality for all remaining content. Vector tests prove that blank lines, trailing newline, spaces, Thai Unicode, wording, and punctuation remain strict.

Fresh validation on Flutter 3.41.1 / Dart 3.11.0 passes: helper 11/11, focused 36/36, frozen/live canonical 5/5, copy audit 300/300 with reader-visible and semantic deltas 0, VM×2/Chrome×2 canonical parity 0, analyzers 299/299/delta 0, and full-suite shared baseline 39 with branch-only/main-only 0. R7.1 remains 10,709,328 bytes / 80 entries / SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`, internal checksums 79/79 and immutable comparison 63/63.

No application source, canonical text, golden, expected output, PDF, ZIP, or R1–R7.1 path changed. Production remains V1.4 version `10af10c6d960d590`. Production release must restart from a clean checkout only after this repair is merged.
