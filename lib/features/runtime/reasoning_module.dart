/// V17 — the catalog of reasoning *systems* the global runtime can host.
///
/// Each module is a distinct body of knowledge with its own provider. Only
/// [thaiAstrology] is implemented in V17 (via `ThaiRuntimeAdapter`); the rest are
/// declared so capability detection and future provider registration have a
/// stable vocabulary. This enum is **system identity only** — no behaviour, no
/// copy.
enum ReasoningModule {
  thaiAstrology,
  westernAstrology,
  bazi,
  mbti,
  bigFive,
  eq,
  compatibility,
}
