# Synthetic readability fixtures

Two complete calculation-only responses captured on 2026-11-10 from the
existing `knowme-overall-pr149-preview-00004-kt9` service. These are synthetic
inputs drawn from the repository's local Overall E2E / BaZi owner fixtures:

- A: 2001-01-15 12:34, Bangkok, female, Asia/Bangkok.
- B: 1990-05-12 08:15, Chiang Mai, female, Asia/Bangkok.

Only `/v1/calculate-bazi` and `/v1/calculate-chart` were called, with calculation
fields only. No identity, saved-chart or database route was used. The full
unchanged responses support deterministic paragraph review without a network
request during tests. Test `asOf` is fixed at 2026-11-10T03:00:00Z; response
generation timestamps remain as captured. No source content is a real person's
birth data. Existing unknown-time owner fixtures and conflict tests supplement
these known-time cases.
