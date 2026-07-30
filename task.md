# Task: Thai Beta Birth Hour State Hotfix

Fix the Production form bug where a valid hour displayed by the Material
`DropdownMenu` is not always committed to the parent form state. A selected or
valid typed hour from `00` through `23` must reach `ThaiBetaInput`, including
midnight, while the explicit unknown-time path remains fail-closed.

Keep the existing UI, Thai astrology Engine, Canon, normalization, Timeline,
authentication, audience, feature flags, Firebase configuration, and report
content unchanged. Add focused widget/domain regression coverage and do not
refactor unrelated code.
