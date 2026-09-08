# PR115 OR5 — Actual sentinel containment blocker

Status: BLOCKED — runtime defect observed, not a request to remove the internal sentinel.

Base: `8e6d168baf8378068260fbbb39500d5eb4491b37`. No application source change.

## Reproduction and scope

The test-only `SentinelAnalysis` implements the existing analysis interface because its production constructor is private. It replaces only the Thai normalized context and recomputes the existing engine/presenter/report snapshot downstream. Raw Unknown input, location, sunrise, date, gender and asOf are unchanged. No mocked reader output, no copy replacement, no golden substitution. Western/BaZi contexts are unchanged and not consumed by the Thai path under test.

Fixture: 1982-06-06, Chiang Mai, male, Unknown time, asOf 2026-08-29 Bangkok civil date. The actual runner's internal 12:00 is the reference. Adapter injections are 00:00, 12:00, 23:59 with hasBirthTime=false throughout. The injected 12:00 reproduces the reference exactly, validating the test seam. Injection occurs before the existing ThaiBirthAdapter day-boundary calculation; freezing its derived day would conceal the precise failure Owner requested testing.

## Actual results

| Internal placeholder | Public comparison against actual runner | Internal derived day |
| --- | --- | --- |
| 00:00 | FAIL: export text, sections, persisted reader snapshot change | 1982-06-05 / Saturday |
| 12:00 | Exact match | 1982-06-06 / Sunday |
| 23:59 | Exact match | 1982-06-06 / Sunday |

Concrete public differences from the same Unknown input:

- The source explanation says `วันที่เกิดตามปฏิทิน: วันอาทิตย์` at 12:00 but `วันที่เกิดตามปฏิทิน: วันเสาร์` at 00:00. The raw civil birth date remains 1982-06-06.
- First past heading changes from `ช่วงเปล่งประกาย (1–6)` to `ช่วงวางรากฐาน (1–10)`.
- `คำชี้หลักจากพื้นดวง` appears in the 00:00 variant, while `จุดแข็งและความเสี่ยงจากพื้นดวง: ยังสรุปไม่ได้เพราะข้อมูลไม่ครบ` disappears from its omitted-topics list.
- V2 decisions and prediction count remain empty/zero, proving that this single counter does not certify the entire public report.

Raw evidence with complete text and per-variant hashes: [OR5_SENTINEL_CONTAINMENT.json](../build/or5/OR5_SENTINEL_CONTAINMENT.json). All reproduced runtime reader text is labelled `UNTRUSTED_OR2_RUNTIME_COPY — NOT CONTENT AUTHORITY`.

The responsible data path is visible in existing source: BirthNormalizer creates a sentinel; ThaiBirthAdapter derives bornBeforeSunrise/astrologicalDate without using hasBirthTime to suppress that calculation; ThaiMirrorPipeline constructs LifePeriodEngine input from birthData; consumer and fallback candidate export retain resulting report content. This is a local metamorphic finding, not a Production QA claim. No source in this path was edited.

## Gate and handoff

Dedicated tests remain 4 passed / 1 failed. The former literal-noon assertion was replaced only as authorized; the stronger public invariance assertion now fails. 49-context/300-profile extraction, 301 deterministic pairs, 10 negative controls and Candidate0011 immutable hash regression pass independently. Authority matrix is not adjudicated. Do not report 0/22 or 22/22 from these observations.

Stop as Owner instructed. Do not change runtime, certify containment, create an acceptance package, commit/push a failed gate, mark Ready, merge or deploy. Full suite, analyzer and repository commit gates are deferred until the blocking source/contract decision is resolved. Six status Markdown files record the blocked state; all OR5 changes remain local and uncommitted. Old OR3/OR4 packages are untouched.
