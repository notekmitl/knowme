# Pre-deploy verification

## Passed provenance gates

- Final main, merged PRs, application tree and clean isolated checkout: passed.
- Production baseline: live V1.4 version `10af10c6d960d590`, release `1786872330369000`.
- Rollback capability: exact V1.4 version cloned to a seven-day Preview channel.
- Authoritative accepted packet: 332 files / 480,630,900 bytes / missing 0 / mismatch 0.
- R7.1 identity: checksums 79/79, immutable 63/63, modified paths 0.

## Blocking fresh gate

Command: pinned Flutter 3.41.1 `test --no-pub --reporter expanded test/validation/thai_beta/live_asof`.

Result: 21 passed / 4 failed, exit code 1. Raw log SHA-256: `1DE1F3A65C944BB2503483581C1DC8833837F0407791CC87EDDE79790E573491`.

All four failures begin at text offset 23 and show accepted CRLF versus generated LF. No application source, test, accepted text or artifact was changed. The pre-deploy gate is blocked.
