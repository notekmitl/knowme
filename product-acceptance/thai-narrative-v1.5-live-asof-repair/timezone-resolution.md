# Timezone resolution

The Thai engine consumes an Asia/Bangkok civil timestamp. `ThaiBetaAnalysisClock.asBangkokCivil` converts an absolute instant to UTC, adds the fixed Thailand offset `+07:00`, then returns a timezone-free civil `DateTime` containing those Bangkok fields. Thailand has no daylight-saving transition in the supported product range, so no large timezone dependency is required.

Contract:

- `startedAt`: original instant used to measure the research session.
- `submittedAt`: read once by the form when a valid submission occurs.
- `asOf`: Bangkok civil representation of `submittedAt`; stored on the analysis and used for all date-aware astrology/presentation work.
- Web/PDF: never call `DateTime.now()` during export and reuse `analysis.asOf`.

The UTC midnight tests prove the Bangkok date changes at 17:00 UTC, not at the device's local midnight. The production entry path therefore does not depend on device timezone.
