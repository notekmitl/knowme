# Immutable build and safety scan

The Production application build command was run exactly once: `flutter build web --release --no-pub` using Flutter 3.41.1 / Dart 3.11.0 at source `642069f0f298bc8a1f86b795f043e02e914aa97d`.

- all local build files: 78 files / 44,183,692 bytes;
- all-file sums identity: `F28F4846AD6DAB12488EEE3AFE32AC23043691B269B4DA0C7E0B415CF496688E`;
- Firebase Hosting deploy set: 77 files / 44,183,660 bytes;
- Hosting sums identity: `2AB8447EC1358F739BC7CDFCE8BC6BAE2C297A5400A64E144BD9A57385389B1A`;
- build manifest SHA-256: `C2F4A41A8EED42ACAF53C8B9AC1DD2A3E454734C276930D210E897CB19DC3D81`;
- Hosting manifest SHA-256: `A1A7EAB6260D1168C5229FF3FAAB7324BF0567AF4300DC79D885041D2319091D`;
- private-key/token-pattern matches: 0;
- local-user/workspace-path matches: 0;
- source-map files: 0;
- `sourceMappingURL` comments: 2, both point to absent `flutter.js.map` and disclose no source;
- unexpected `.env`, key, PEM, log, Markdown, `.git`, or `.dart_tool` files: 0.

Firebase ignores the 32-byte `.last_build_id` dotfile, producing the explicit 77-file Hosting set. Preview and Production must use this same frozen `build/web` without rebuild.
