# Production verification

- URL: `https://knowme-app-694e1.web.app`
- Release: `1787038542564000`
- Version: `5f98dfffef913e38`
- Release time: `2026-08-18T07:35:42.564Z`
- Source: `642069f0f298bc8a1f86b795f043e02e914aa97d`
- Remote assets: 77/77 exact, mismatch 0
- HTTP route rewrites: `/` and `/beta/thai`, 2/2 exact, mismatch 0
- Desktop/mobile isolated browser smoke: PASS; application console errors 0
- Frozen/live canonical Web/PDF: 5/5 exact
- Repeated Preview/Production output: PDF extracted text exact against one oracle for 5/5 in both environments; substantive delta 0
- Bangkok submit-time civil `asOf`: validated by the fresh live gate
- Unknown: fail-closed; no ascendant output
- Owner Known: Aquarius 19°19′
- Regression 00:03: Aquarius 9°24′
- S008: canonical mismatch 0; raw VM/Chrome one-ULP diagnostic retained
- Reader-visible delta: 0
- Traceability: 170/170
- Production PDF semantic gate: 5/5, 34 pages, substantive difference 0
- Production PDF visual gate: 34/34
- Rollback: not invoked; V1.4 rollback channel remains available

## Production PDF identities

| Fixture | Bytes | Pages | SHA-256 |
| --- | ---: | ---: | --- |
| owner-known-0035 | 39,391 | 7 | `C2BE05CB24BDAF1277B9A1B164E3EA754D13F9A555390FBC918C8FB9D670CDC6` |
| owner-unknown | 37,283 | 6 | `13818E1F73F80FE5B24AC4D182C85C132E5DF57F0DB072CED96809FF76E0D7D0` |
| regression-known-0003 | 39,390 | 7 | `26409D98728591B1D8C0E443C022ADF6BE34B1310FAEE4E1A0909A07C6F13438` |
| bangkok-known-1420 | 38,614 | 7 | `08DBE9387478427CD9CEBA71D1F9285314CA749678037502666FC980F4C42D8F` |
| khon-kaen-known-0645 | 39,111 | 7 | `9044A2CDFF1D20875F80DF30BF7A1B41D2F1865D1922AC6FF7AB7E1A885449E6` |

The corresponding Preview PDFs have the same byte counts, page counts, and exact extracted/canonical text. Their binary SHA-256 values differ because each PDF carries generation metadata; the semantic comparison does not substitute visual review for exact extracted-text comparison.

