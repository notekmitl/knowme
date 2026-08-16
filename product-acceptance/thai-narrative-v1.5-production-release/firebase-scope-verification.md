# Firebase scope verification

- Authorized project/site: `knowme-app-694e1` / `knowme-app-694e1`.
- Authenticated account: `note018@gmail.com`.
- Deployment command contained `--only hosting` and targeted project `knowme-app-694e1`.
- Firebase deploy log enumerates only `deploying hosting`, `hosting[knowme-app-694e1]`, version finalization, and live release.
- Firebase Console rollback targeted only Hosting release history for site `knowme-app-694e1` and exact version `10af10c6d960d590`.
- Firestore rules/indexes: not deployed or edited.
- Firebase Auth: not changed.
- Functions: not deployed or changed.
- Storage rules: not deployed or changed.
- Remote Config: not changed.
- Firebase project configuration, secrets, and environment variables: not changed.
- Android/iOS builds: not run.
- Application source, tests, goldens, and R1–R7.1 accepted artifacts: not changed.

Result: `PASS — Hosting was the only Firebase service changed, followed by Hosting-only rollback`.
