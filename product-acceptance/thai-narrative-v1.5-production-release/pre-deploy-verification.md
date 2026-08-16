# Pre-deploy verification

- Clean isolated repository worktree: PASS.
- HEAD and `origin/main`: `7a2bdea4d88ebd3e87ee7268641a37a70a7a959f`.
- PR #92 and PR #93: MERGED.
- Final-main delta from product merge: exactly seven post-merge Markdown files.
- Final-main deployable product tree versus accepted V1.5 tree: byte-identical; only the same seven Markdown files differ.
- Flutter: 3.41.1, revision `582a0e7c5581dc0ca5f7bfd8662bb8db6f59d536`.
- Dart: 3.11.0.
- Firebase CLI: 15.16.0.
- Authenticated Firebase account: `note018@gmail.com`.
- Firebase project/site: `knowme-app-694e1` / `knowme-app-694e1`.
- Hosting public directory: `build/web`.
- Existing V1.4 browser session: reachable at `/beta/thai`; signed-out landing present; browser console warnings/errors 0.

Pre-deploy result: `PASS`. The later Production canonical-text failure and rollback do not invalidate these captured pre-deploy facts.
