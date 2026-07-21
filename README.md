# KnowMe

A personalized astrology-inspired self-understanding platform built with Flutter.

KnowMe combines multiple lenses — Thai / Western / Chinese astrology plus structured
personality tests (MBTI, EQ, Big Five) — into progressively deeper, human-readable
reflection. It is a *digital mirror for self-understanding*, not a horoscope app, a
quiz app, or an MBTI clone.

- **Front door:** feels like astrology that understands you.
- **Core:** deterministic engines (no LLM dependency in core paths) produce
  explainable, reproducible insight.

## Live deployment

- Public beta: https://knowme-app-694e1.web.app
- Firebase project: `knowme-app-694e1`
- Deploy: `./scripts/deploy_web.ps1` (see [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md))

## Start here (documentation)

**The master index is [`docs/PROJECT_INDEX.md`](docs/PROJECT_INDEX.md)** — it classifies
every document and defines the reading order. AI agents must start with
[`docs/AI_ALIGNMENT_CONTEXT.md`](docs/AI_ALIGNMENT_CONTEXT.md).

| Document | Purpose |
|----------|---------|
| [`docs/PROJECT_INDEX.md`](docs/PROJECT_INDEX.md) | Master documentation map + classification + reading order |
| [`docs/AI_ALIGNMENT_CONTEXT.md`](docs/AI_ALIGNMENT_CONTEXT.md) | Permanent AI alignment: rules, reading order, never-do |
| [`docs/EXECUTIVE_SUMMARY.md`](docs/EXECUTIVE_SUMMARY.md) | Fastest full-project understanding: architecture, freeze map, tech debt, roadmap |
| [`docs/DOMAIN_MODEL.md`](docs/DOMAIN_MODEL.md) | Highest-level conceptual model: engines, ownership, data flow (diagrams) |
| [`docs/DECISION_LOG.md`](docs/DECISION_LOG.md) | Why major architectural/product decisions were made |
| [`docs/KNOWME_MASTER_CONTEXT.md`](docs/KNOWME_MASTER_CONTEXT.md) | Vision, philosophy, subsystem map (canonical reference) |
| [`docs/CURRENT_STATUS.md`](docs/CURRENT_STATUS.md) | What's done, active focus, risks, deployment |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Pipeline layers and code organization |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Evidence-based completed / active / future |
| [`docs/GOVERNANCE.md`](docs/GOVERNANCE.md) + [`docs/PROJECT_FREEZE.md`](docs/PROJECT_FREEZE.md) | Freeze policy + per-system freeze registry |
| [`docs/HANDOFF.md`](docs/HANDOFF.md) | Setup, routing, validation commands, agent rules |

## Project layout

```
lib/
  core/           # Shared app logic (i18n, theme, web launch routing)
  data/           # Shared static data (question banks, test modules)
  features/       # Feature-owned logic (preferred architecture)
  presentation/   # Legacy/general UI — coexistence expected
  services/       # App-wide services (profile, question service)
docs/             # Architecture, specs, validation records
test/             # Unit, widget, golden, and synthetic validation suites
scripts/          # Deploy + maintenance scripts (PowerShell)
backend/          # BaZi astrology API (separate from Flutter app)
```

## Flutter getting started

This is a standard Flutter project. With the Flutter SDK installed:

```bash
flutter pub get
flutter run            # run on a device/emulator
flutter test           # run the test suite
```

For Flutter fundamentals, see the [online documentation](https://docs.flutter.dev/).
