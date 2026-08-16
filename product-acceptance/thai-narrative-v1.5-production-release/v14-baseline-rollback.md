# V1.4 Production baseline and rollback point

- Live channel: `projects/knowme-app-694e1/sites/knowme-app-694e1/channels/live`.
- Release ID: `1786522688560000`.
- Version ID: `10af10c6d960d590`.
- Release type: `DEPLOY`.
- Release time: `2026-08-12T08:18:08.560Z`.
- Finalize time: `2026-08-12T08:18:08.410754Z`.
- Release user: `note018@gmail.com`.
- Files: 79.
- Bytes: 14,326,570.
- Deployment tool label: `cli-firebase`.
- Firebase reports the live channel release as retained in Hosting history.

If V1.5 verification fails, use Firebase Hosting Release history to select this exact version and Rollback. Firebase CLI 15.16.0 `hosting:clone` accepts channels, not historical version IDs, so no unsupported version-clone syntax will be guessed.

## Actual rollback

- Trigger: `owner-known-0035` downloaded Production PDF canonical text mismatch.
- Method: Firebase Hosting Release history → exact `60d590` (`10af10c6d960d590`) → Rollback.
- Rollback release ID: `1786872330369000`.
- Rollback type: `ROLLBACK`.
- Rollback time: `2026-08-16T09:25:30.369Z`.
- Restored version ID: `10af10c6d960d590`.
- Restored version files/bytes: 79 / 14,326,570.
- Cache-bypassed V1.4 asset identity: 6/6 exact, mismatch 0.
- Fresh and existing-tab browser smoke: HTTP/UI ready, console warning/error 0.
- Final Production: V1.4.
