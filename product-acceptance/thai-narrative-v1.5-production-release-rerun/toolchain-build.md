# Toolchain and build

- Pinned toolchain: Flutter 3.41.1, framework `582a0e7c55`; Dart 3.11.0.
- Firebase CLI: 15.16.0.
- Dependency restore: passed; raw log `pub-get-result.txt`.
- Intended build command: `flutter build web --release --no-wasm-dry-run --dart-define=ASTROLOGY_API_BASE_URL=<verified production API URL> --dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=public_beta`, using the pinned Flutter binary.
- Build result: **NOT RUN** because the mandatory pre-deploy test gate failed first.
- Build directory: not created by this release task.
- Preview/Production immutable build identity: not applicable.

No secret value or production API URL is recorded in this packet.
