# V1.5 production release after canonical line-ending repair

Result: PASS. V1.5 is deployed and verified on Firebase Hosting.

## Provenance

- Repair commit / PR: `c321172864033f1ea3b1a834519685a1d6823c67` / #98
- Repair merge and deploy source: `642069f0f298bc8a1f86b795f043e02e914aa97d`
- Toolchain: Flutter 3.41.1 / Dart 3.11.0
- Accepted application paths versus accepted tree: changed 0
- R1–R7.1 modified paths: 0

## Fresh release gate

- Focused live-asOf/line-ending suite: 36/36
- Copy semantic audit: 300/300; semantic, reader-visible, omission, addition, prediction-to-advice and Web/PDF mismatches 0
- VM x2 / real Chrome x2: 300 profiles per run; nondeterminism 0; canonical mismatch 0
- Scoped analyzer: no issues
- Accepted evidence packet: 332/332, 480,630,900 bytes, missing 0, mismatch 0, manifest SHA-256 `2E04DDC4D219203074AACD972D7FEDB2102B134E6DBFA8B2B6C0E493E5EE6DE5`
- R7.1 ZIP: 10,709,328 bytes, 80 entries, 79/79 checksums, 63/63 immutable, SHA-256 `9E541F21C68FDAD93BC595C55BD0BE23600F88454CFBA7FAB6C713FE53F79E58`

## Immutable build and Preview

- Build count: one; command `flutter build web --release --no-pub`
- Hosting set: 77 files / 44,183,660 bytes
- Hosting manifest SHA-256: `A1A7EAB6260D1168C5229FF3FAAB7324BF0567AF4300DC79D885041D2319091D`
- Hosting sums SHA-256: `2AB8447EC1358F739BC7CDFCE8BC6BAE2C297A5400A64E144BD9A57385389B1A`
- Preview URL: `https://knowme-app-694e1--v15-line-ending-release-45bzkvyc.web.app`
- Preview release/version: `1787036689380000` / `95bbd383a56dee39`
- Preview expiry: `2026-08-25T07:04:41.889497446Z`
- Preview assets/routes: 77/77 and 2/2 exact
- Preview desktop/mobile/application console: PASS / PASS / errors 0
- Preview PDF semantic/visual: 5/5 exact, 34/34 pages

## Production

- URL: `https://knowme-app-694e1.web.app`
- Release/version: `1787038542564000` / `5f98dfffef913e38`
- Release time: `2026-08-18T07:35:42.564Z`
- Production assets/routes: 77/77 and 2/2 exact
- Desktop/mobile/application console: PASS / PASS / errors 0
- Frozen/live canonical Web/PDF: 5/5
- S008 canonical mismatch: 0
- Reader-visible delta: 0
- Traceability: 170/170
- Owner Known / regression 00:03: Aquarius 19°19′ / 9°24′
- Unknown: fail-closed
- Production PDF semantic/visual: 5/5 exact, 34/34 pages
- Rollback: not required; channel `v15-rerun-v14-rollback` remains on V1.4 `10af10c6d960d590`
- Firebase scope: Hosting only; all non-Hosting services unchanged

Raw logs, manifests, browser snapshots, real Preview/Production PDFs, extracted text, rasterized pages, contact sheets, and structured comparisons are stored alongside this README.
