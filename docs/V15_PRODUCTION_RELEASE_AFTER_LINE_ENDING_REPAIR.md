# V1.5 production release after canonical line-ending repair

## Repair provenance

- Repair commit: `c321172864033f1ea3b1a834519685a1d6823c67`
- Repair PR: #98
- Repair merge commit / final deploy source: `642069f0f298bc8a1f86b795f043e02e914aa97d`
- Merge parents: `bb85b07c643bc35cef076df066cb191f2f0a7d24` and `c321172864033f1ea3b1a834519685a1d6823c67`
- Repair scope: test/comparison helper, its tests, Markdown, and evidence only
- Accepted application tree: unchanged; application/canonical/golden/expected/R1–R7.1 change count 0

The repaired exact-text contract canonicalizes only `CRLF` and standalone `CR` to `LF`. It does not trim, collapse whitespace, normalize Unicode, change punctuation/wording, or apply tolerance. The helper tests pass 11/11 and the focused release gate passes 36/36.

## Release identity

- Toolchain: Flutter 3.41.1 / Dart 3.11.0
- Build command: `flutter build web --release --no-pub`
- Build count: one
- Hosting deploy set: 77 files / 44,183,660 bytes
- Hosting manifest SHA-256: `A1A7EAB6260D1168C5229FF3FAAB7324BF0567AF4300DC79D885041D2319091D`
- Hosting sums SHA-256: `2AB8447EC1358F739BC7CDFCE8BC6BAE2C297A5400A64E144BD9A57385389B1A`
- Preview release/version: `1787036689380000` / `95bbd383a56dee39`
- Production release/version: `1787038542564000` / `5f98dfffef913e38`
- Production release time: `2026-08-18T07:35:42.564Z`
- Production URL: `https://knowme-app-694e1.web.app`

## Verification

- Production assets: 77/77 exact; routes `/` and `/beta/thai`: 2/2 exact
- Desktop/mobile application console errors: 0
- Canonical frozen/live Web/PDF: 5/5 exact
- S008 canonical mismatch: 0; disclosed raw VM/Chrome difference remains one ULP only
- Copy semantic audit: 300/300; semantic/reader-visible/omission/addition/prediction-to-advice/Web-PDF mismatch 0
- Owner Known: Aquarius 19°19′
- Regression 00:03: Aquarius 9°24′
- Unknown: fail-closed
- Claim traceability: 170/170
- Production PDFs: 5 fixtures, 34 pages, extracted/canonical exact 5/5, substantive differences 0, every page visually passed
- R7.1: 10,709,328 bytes, 80 entries, checksums 79/79, immutable 63/63, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`

Only Firebase Hosting was deployed. Firestore, Auth, Functions, Storage, Remote Config, rules, indexes, mobile builds, and accepted artifacts were not changed. The V1.4 rollback Preview remains available at version `10af10c6d960d590`; no rollback was required.
