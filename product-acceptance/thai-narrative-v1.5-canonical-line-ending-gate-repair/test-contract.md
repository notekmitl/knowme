# Canonical exact-text test contract

This is a test/comparison contract repair. It does not change application code, canonical content, expected outputs, goldens, PDFs, ZIPs, or reader-visible text.

The helper reads the fixture as raw UTF-8 bytes, records its raw SHA-256, decodes it, replaces only `CRLF` with `LF` and then standalone `CR` with `LF`, records the normalized UTF-8 SHA-256, asserts that pipeline text contains no `CR`, and performs exact string equality against the normalized fixture.

It does not trim, remove a trailing newline, collapse spaces or blank lines, normalize Unicode, change punctuation or case, replace words, use tolerance, hard-code a profile, skip a test, suppress a mismatch, or use an allowlist.

The 11/11 helper vectors cover LF, CRLF, standalone CR, mixed endings, blank lines, trailing newline, leading/trailing spaces, Thai Unicode, accepted line-ending-only variation, rejected pipeline CR, wording mismatch, and punctuation mismatch.
