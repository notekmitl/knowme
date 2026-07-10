# KnowMe AI Worker — Operation

**Purpose:** Describe how the external KnowMe AI Worker runs automated implementation jobs against the KnowMe repository.
**Audience:** Developers and operators who submit tasks or inspect worker output.
**Last updated:** July 2026

For repository setup and development workflow, see [`HANDOFF.md`](HANDOFF.md). For current project status, see [`CURRENT_STATUS.md`](CURRENT_STATUS.md).

---

## Overview

The KnowMe AI Worker is an **external automation** that sits outside the main repository. It accepts a task description, implements the work in an isolated Git worktree using **Cursor Agent**, runs independent checks, and has the result reviewed by the **OpenAI API**. When review passes and the main repository is still clean, the worker commits the work and fast-forward merges it into the active KnowMe checkout.

The obsolete in-repo `ai-worker/` directory is gitignored and must not be used. The active worker lives at a separate path (see below).

---

## Paths

| Role | Path |
|------|------|
| **Active KnowMe repository** | `C:\Users\USER\knowme` |
| **External AI Worker** | `C:\Users\USER\knowme-ai-worker` |
| **Isolated worktrees** | `C:\Users\USER\knowme-ai-worktrees` |
| **Job logs** | `C:\Users\USER\knowme-ai-worker\logs\<job-id>\` |

Each job receives a unique job ID (timestamp + token). Its worktree is created under `knowme-ai-worktrees\<job-id>\`, and its logs are written under `knowme-ai-worker\logs\<job-id>\`.

---

## Prerequisites

Before starting a job:

1. **Clean Git working tree** — The active KnowMe repository at `C:\Users\USER\knowme` must have no uncommitted changes. The worker refuses to start if `git status --porcelain` is non-empty. Commit or stash local work in Cursor first.
2. **Task file** — Write the task in `C:\Users\USER\knowme-ai-worker\task.txt` (replace any placeholder text).
3. **Environment** — Git, Cursor Agent, and `OPENAI_API_KEY` must be available to the worker process. API keys belong in environment variables only — never in task files, source files, or logs.

---

## End-to-End Flow

```
Operator writes task.txt
        ↓
Worker verifies main repo is clean
        ↓
Worker creates isolated Git worktree + branch
        ↓
┌───────────────────────────────────────────┐
│  Review loop (up to max_rounds, default 3) │
│                                           │
│  1. Cursor Agent implements / revises     │
│  2. Worker checkpoints changes in branch  │
│  3. Independent checks run                │
│  4. OpenAI API reviews diff + test output │
│                                           │
│  REVISE → feedback sent back to Cursor  │
│  PASS   → exit loop                       │
└───────────────────────────────────────────┘
        ↓
Worker squashes to one final commit
        ↓
If main repo still clean → fast-forward merge
If main repo dirty     → commit stays on branch; no auto-merge
        ↓
Logs written; operator notified
```

### Step-by-step

1. **Start** — Run `START_WORKER.bat` in `C:\Users\USER\knowme-ai-worker` (or invoke `worker.py` directly).
2. **Validate** — Worker confirms the main repo exists, the task is non-empty, Git is available, Cursor Agent is installed, and `OPENAI_API_KEY` is set.
3. **Worktree** — Worker runs `git worktree add` from `C:\Users\USER\knowme`, creating a new branch and an isolated checkout under `C:\Users\USER\knowme-ai-worktrees\<job-id>\`. All implementation happens here — not in the main repo.
4. **Implement** — **Cursor Agent** receives the task (plus selected KnowMe context docs) and edits files in the worktree. The agent does not commit; the worker manages checkpoints.
5. **Check** — The worker runs independent checks against the checkpoint:
   - **Docs-only changes** (`docs/*.md`): `git diff --check`
   - **Code/config/test changes**: configured commands (default: `flutter analyze`, `flutter test`) in a separate detached validation worktree so generated artifacts do not pollute the implementation diff
6. **Review** — The **OpenAI API** (independent of Cursor) receives the task, changed files, diff, check results, and the agent's completion report. It returns `pass` or `revise` with specific feedback.
7. **Retry** — If the verdict is `revise`, the worker sends the feedback and latest check output back to Cursor Agent automatically. This repeats until review passes or the configured **maximum rounds** is reached (default: 3 in `worker_config.json`).
8. **Commit** — On `pass`, the worker squashes round checkpoints into a single commit on the job branch (e.g. `AI worker: <task summary>`).
9. **Merge** — The worker fast-forward merges the job branch into `C:\Users\USER\knowme` **only if** the main repository working tree is still clean. If the operator modified the main repo while the worker was running, auto-merge is skipped to prevent conflicts.
10. **Cleanup** — On successful merge, the worktree is removed and the job branch is deleted locally.

---

## Roles

| Component | Responsibility |
|-----------|----------------|
| **Operator** | Keeps main repo clean before start; writes `task.txt`; avoids editing main repo during a run |
| **Cursor Agent** | Reads KnowMe docs, implements or revises code/docs in the isolated worktree, runs relevant checks, reports results |
| **Worker (`worker.py`)** | Orchestrates worktrees, checkpoints, independent checks, review loop, commit, and merge |
| **OpenAI API** | Independent senior review of diff, scope, frozen boundaries, and check appropriateness |

Cursor implements; OpenAI reviews. Neither role is a substitute for human judgment on high-risk or architectural changes.

---

## Logs

Each job writes artifacts under:

```
C:\Users\USER\knowme-ai-worker\logs\<job-id>\
```

Typical files per round:

| File | Contents |
|------|----------|
| `task.txt` | Original task text |
| `base_sha.txt` | Starting commit SHA |
| `round_N_cursor.json` | Cursor Agent output |
| `round_N_status.txt` | Git name-status for the diff |
| `round_N_diff.patch` | Unified diff |
| `round_N_checks.txt` | Independent check output |
| `round_N_review.json` | OpenAI review verdict, summary, feedback |
| `final_result.json` | Job outcome (commit SHA, merge status, duration) |

Use these logs to audit what changed, why a review failed, and whether merge succeeded.

---

## Configuration

Worker settings live in `C:\Users\USER\knowme-ai-worker\worker_config.json`:

| Setting | Default | Meaning |
|---------|---------|---------|
| `project_path` | `C:\Users\USER\knowme` | Active KnowMe repository |
| `max_rounds` | `3` | Maximum implement → review cycles |
| `review_model` | `gpt-5.5` | OpenAI model for independent review |
| `test_commands` | `flutter analyze`, `flutter test` | Full check profile for non-docs changes |
| `auto_merge_when_safe` | `true` | Fast-forward merge when main repo is clean |

---

## Security Rules

- **Never** store API keys, tokens, or other secrets in:
  - `task.txt`
  - KnowMe source files
  - Worker log files
- Provide `OPENAI_API_KEY` via environment variables only.
- Do not paste credentials into task descriptions — the task file and logs may be retained for debugging.
- Follow existing KnowMe secret handling: never commit `serviceAccountKey.json`, `.env`, or Firestore user exports (see [`HANDOFF.md`](HANDOFF.md) §1).

---

## Operator Checklist

| Step | Action |
|------|--------|
| 1 | Commit or stash all changes in `C:\Users\USER\knowme` |
| 2 | Confirm `git status` is clean |
| 3 | Write a clear, scoped task in `knowme-ai-worker\task.txt` |
| 4 | Run `START_WORKER.bat` |
| 5 | Do not edit the main repo until the job finishes |
| 6 | Inspect `logs\<job-id>\` if review fails or merge is skipped |
| 7 | If auto-merge was skipped, manually merge the `ai-worker/<job-id>-*` branch from the worktree path |

---

## Related Documentation

| Document | Relevance |
|----------|-----------|
| [`HANDOFF.md`](HANDOFF.md) | Repository setup; notes external worker path |
| [`CURRENT_STATUS.md`](CURRENT_STATUS.md) | Pre-AI-worker baseline and active branch |
| [`AI_ALIGNMENT_CONTEXT.md`](AI_ALIGNMENT_CONTEXT.md) | Rules Cursor Agent must follow during implementation |
| [`GOVERNANCE.md`](GOVERNANCE.md) | Frozen systems the reviewer enforces |
