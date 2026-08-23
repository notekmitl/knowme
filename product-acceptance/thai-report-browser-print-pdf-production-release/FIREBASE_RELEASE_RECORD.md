# Firebase Hosting Release Record

## Authorized mutations

Only Firebase Hosting was mutated.

| Action | Release | Version | Result |
| --- | --- | --- | --- |
| Rollback-readiness clone | `1787481157491000` | `5f98dfffef913e38` | PASS; old Production retained on Preview channel |
| Repair Preview | `1787481247171000` | `dedf5b2acf6e17c4` | PASS |
| Production deploy | `1787482140137000` | `e563b9b6df94ef81` | PASS |

Production release time is `2026-08-23T10:49:00.137Z`. The deployed source is
repair merge `05c233a6759730d29b6cf7170d16b738e760d4b7`. The Production
verification gate passed, so the rollback clone was not promoted to live.

Firestore, Auth, Functions, Storage, Remote Config, Rules and Indexes were not
changed. The first Preview CLI attempt that supplied an invalid Hosting target
filter failed before upload; it is retained as a diagnostic and did not create
a release. No rebuild occurred after that CLI-only correction.

