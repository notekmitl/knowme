# Task: Migrate KnowMe primary executor from Cursor to Codex

Update the repository's current documentation and operational prompt so Codex is
the sole end-to-end executor for one task branch/worktree at a time. Preserve the
existing Single-Agent + Local Gate controls exactly: allowlist, forbidden-file and
forbidden-text checks, analyze/focused/full-test policy, PreCommit, and PostCommit.

Do not change application code, Firebase runtime/configuration, feature flags,
invited-beta access, product status, or Production deployment state. Historical
documents may retain Cursor references when clearly classified as historical and
must not instruct current work.
