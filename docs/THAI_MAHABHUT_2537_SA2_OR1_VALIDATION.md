# PR112 SA2 OR1 Semantic Validation Report

Status: **PASS — CANDIDATE 0009 PENDING OWNER CONTENT RE-REVIEW**

## Counts

- context placement mappings: 49
- life-period placement records: 392
- source-direct claims: 7
- general-rule applications: 3
- Owner-authorized product interpretations: 5
- OCR discovery keyword hits: 182; event evidence: 0
- reader claims: 11 total; prediction claims: 7

## Positive validation

All 25 computed error counters are 0, including evidence/rule ownership,
inspected pages, product labels, context/period/domain matching, unsupported
event/timing, duplicate owner/meaning, prediction-to-advice conversion, advice
inside predictions, methodology and Known-to-Unknown leakage.

The 300-profile deterministic audit passes 300/300, covers 49 contexts and 160
context-period signatures, and makes no predictive-accuracy claim. The 00:03,
00:35 and Unknown fixture separation remains intact.

## Negative controls

All six controls fail in the intended way:

1. promotion in October: unsupported event 1, unsupported timing 1;
2. finance sentence on work owner: domain mismatch 1;
3. removed owner: claim-without-evidence 1;
4. Known sentence copied to Unknown: leakage 2;
5. repeated sentence/owner: repeated meaning 1, duplicate owner 1;
6. advice inserted into prediction: conversion 1, advice-in-prediction 1.

Candidate 0008 separately returns FAIL with missing owner 20, advice leakage 6
and methodology leakage 9. Candidate 0009 returns PASS.
