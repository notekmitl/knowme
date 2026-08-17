# Reader-visible hash usage audit

Audit scope: `lib/features/astrology/thai/mirror/` and `lib/features/thai_beta/`, using `rg` for `.hashCode`, `Object.hash`, `Object.hashAll`, seeds, variants, modulo selection, score nuance, headlines, cards and domains.

## Result

All reader-visible selection paths in scope now use an application-owned stable-hash contract. No reader-visible path still consumes Dart runtime `String.hashCode`, `Object.hash` or `Object.hashAll`.

The affected selection paths are Mirror profile/content seeds, theme and headline variants, consumer/report copy, evidence copy, timeline seeds and nuances, and Thai Beta narrative selection/fallback seeds. These paths now use `ThaiMirrorStableHash` or `ThaiBetaNarrativeStableHash`, with explicit exact arithmetic where a seed can be wider than 32 bits.

## Remaining findings and classification

- `models/thai_mirror_evidence.dart`, `thai_mirror_section.dart`, `thai_narrative_metadata.dart`, `thai_mirror_profile_context.dart`, `thai_mirror_theme_ref.dart`, and `thai_mirror_result.dart`: value equality / collection identity only.
- `presentation/thai_mirror_view_state.dart` and the presentation model `hashCode` implementations: value equality / framework collection identity only.
- `test/validation/thai_beta/live_asof/thai_beta_live_asof_diagnostic_test.dart`: test/evidence-only reconstruction of the pre-repair runtime-dependent algorithm.
- `test/validation/thai_beta/live_asof/thai_beta_cross_runtime_seed_test.dart`: test/evidence-only capture of runtime `String.hashCode` to prove why it cannot be the release contract.

No equality/hashCode implementation on a value object was changed. The remaining findings are not inputs to content selection, score nuance, variant choice, or canonical text.

## Final gate caveat

Hash selection itself is deterministic in the fixed vectors and in both repeated 300-profile runs. The final cross-runtime gate is nevertheless blocked by a one-ULP engine fact difference for S008 before hashing; see `cross-runtime-blocker.md`.
