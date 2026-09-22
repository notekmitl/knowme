# Western Astrology Reader V2 user-perceived performance closeout

Date: 2026-09-21

Status: **PASS — MEASUREMENT ARTIFACT CONFIRMED; APPLICATION AND HOSTING UNCHANGED**

This is the historical closeout for the PR #143 release. The later Reader r2
readability release and its authenticated-generation latency repair supersede
the Production identity below; current trace-correlated evidence is in
`docs/WESTERN_ASTROLOGY_READER_V2_LATENCY_REPAIR.md`.

## Frozen Production identity

- Application commit: `de0a83bdfbb18532471ba58e539e7d0b6cf553a4`
- Application tree: `f902d98d1d70ad39700df14e5406d07374d26f6a`
- Previous docs closeout merge: `6cc35542174707eb44dc88aa3b918695fdd31276`
- Hosting release: `1789977665171000`
- Hosting version: `4065a55e03f5aa1e`
- Live cache pin: `de0a83b`
- Contract: `knowme_western_reader_v2`

No application source, build, Backend, Hosting release, Firestore schema,
Auth, Functions, Storage, IAM, or other astrology flow changed during this
closeout.

## Root cause

The previously recorded mobile `14.662 s` and desktop `31.251 s`
click-to-readable values were not browser-runtime measurements. They included
Agent wait and visual-observation delay after the API completed. They are
retained only as superseded historical observations and must not be used as
latency evidence.

Production was remeasured with one browser clock and Chrome DevTools Protocol
events. The probe captured:

1. the Western button `click` event with `performance.now()`;
2. `Network.requestWillBeSent` for authenticated `POST /v1/generate-chart`;
3. `Network.responseReceived` for response headers;
4. `Network.loadingFinished` for response-body completion;
5. the first Flutter semantics mutation containing the Reader V2 contract,
   main reading heading, and all three Big Three labels as the browser-visible
   chart-state application marker; and
6. the first Chrome compositor `Page.screencastFrame` at or after that state
   marker as the first rendered readable frame.

The first desktop run was inspected frame by frame: loading remained visible
through the pre-application frames, and the first frame selected by the rule
above contained the complete Reader V2 hero, Gemini/Sagittarius/Pisces, and
the main reading heading. The same deterministic marker rule was then used for
all six accepted runs. Agent/tool wait time was excluded from every duration.

## Production generation measurements

All values are milliseconds. `Headers` and `Body` are independent CDP event
timestamps; sub-millisecond event-delivery ordering can make them appear
nearly simultaneous.

| Viewport | Run | Click→POST | POST→headers | POST→body | Body→state applied | State→readable frame | Body→readable | Click→readable |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Desktop 1535×863 | 1 | 1.968 | 2,869.933 | 2,869.369 | 70.963 | 10.987 | 81.950 | 2,953.287 |
| Desktop 1535×863 | 2 | 2.348 | 1,277.227 | 1,276.730 | 70.822 | 11.183 | 82.005 | 1,361.083 |
| Desktop 1535×863 | 3 | 1.040 | 919.284 | 922.459 | 68.801 | 12.190 | 80.991 | 1,004.490 |
| **Desktop median** |  | **1.968** | **1,277.227** | **1,276.730** | **70.822** | **11.183** | **81.950** | **1,361.083** |
| Mobile 390×844 | 1 | 2.176 | 1,158.828 | 1,158.861 | 81.963 | 8.186 | 90.149 | 1,251.186 |
| Mobile 390×844 | 2 | 1.291 | 1,197.786 | 1,197.277 | 79.232 | 8.753 | 87.985 | 1,286.553 |
| Mobile 390×844 | 3 | 1.296 | 1,052.334 | 1,051.777 | 69.027 | 10.751 | 79.778 | 1,132.851 |
| **Mobile median** |  | **1.296** | **1,158.828** | **1,158.861** | **79.232** | **8.753** | **87.985** | **1,251.186** |

Acceptance result:

- response-complete→readable median: desktop `81.950 ms`, mobile
  `87.985 ms` — both below `1.5 s`;
- response-complete→readable maximum: `90.149 ms` — below `3 s`;
- click→readable maximum: `2,953.287 ms` — below `7 s`;
- each generation run: authenticated POST `1`, `western_natal` browser read
  `0`, `astrology_fusion` browser traffic `0`, HTTP `200`, runtime/console
  errors `0`;
- preflight OPTIONS was `0/0/0` desktop and `0/1/0` mobile and did not create
  a duplicate generation request.

The first readable desktop and mobile frames were visually inspected. They had
normal wrapping and no overflow, stuck loading state, or error surface.

## Cache and correctness acceptance

The cache-hit path from Astrology Center produced:

- Firestore `western_natal` read `1`;
- authenticated generation POST `0`;
- browser `astrology_fusion` traffic `0`;
- runtime/console errors `0`; and
- a readable Reader V2 result.

The accepted generation response retained:

- schema `western_natal_v2`;
- contract `knowme_western_reader_v2`;
- engine `swiss_ephemeris_tropical_placidus_v2`;
- UTC instant `1982-06-05T17:03:00Z`;
- Gemini Sun, Sagittarius Moon, and Pisces Rising; and
- `Asia/Bangkok`, latitude `18.7883`, longitude `98.9853`.

## Validation disposition

Because the excess time was a measurement artifact, application changes and a
new deployment were prohibited and were not performed. The exact application
candidate remains covered by the accepted PR #143 validation: backend 46/46,
focused Flutter 52/52, complete Flutter 3,094/3,094, analyzer policy,
benchmark, and Production-configured Web build. This closeout changes Markdown
documentation only.
