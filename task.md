# Task: Thai Mirror QA Screenshot Golden Baseline Repair V1

Repair the stale Thai Mirror QA screenshot baselines from immutable
`origin/main` commit `fdf2cb3ccdbdacb8cd33bd0c41e6ff1fe35fe2d8` using
Flutter 3.41.1. Regenerate only the existing QA harness PNG baselines, verify
deterministic output and visual/story coverage, and restore the screenshot
regression as an active Local Gate.

This prerequisite is isolated from Thai Beta Past-to-Future Narrative V3. It
must not change production source, comparator tolerance, tests, Gate scripts,
Engine, Canon, Birth Normalization, or any V3 worktree content.

## Approved task-local exception

The scoped required suite excludes the separate standalone golden
`test/goldens/thai_mirror_consumer_page.png`. On unchanged `origin/main` it
already fails by 32.63% / 305,379 pixels, so it is not a regression caused by
this repair. This does not mark that golden as passing and does not authorize
changing, disabling, deleting, or relaxing it. A separate repair task is
required.
