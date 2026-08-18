# Byte-level root-cause report

The four mandatory-gate failures were caused only by Windows checkout line-ending conversion. The repository Git blobs contain LF; the system Git configuration has `core.autocrlf=true`; and the relevant paths have `text`, `eol`, and `working-tree-encoding` all unspecified. Consequently, the Windows worktree and Dart fixture loader contain CRLF while the pipeline contains LF.

The raw failure log is unchanged and hashes to `1DE1F3A65C944BB2503483581C1DC8833837F0407791CC87EDDE79790E573491`.

Across all ten canonical Web/PDF comparisons:

- the first raw difference is zero-based byte/code-unit offset 22 (`CR`, 13, versus `LF`, 10); matcher displays offset 23;
- the worktree contains only CRLF, with no standalone CR or LF;
- the pipeline contains only LF and no CR;
- trailing newline and the one intentional blank line remain present;
- replacing `CRLF` with `LF`, then standalone `CR` with `LF`, makes every comparison byte-exact;
- normalized worktree bytes equal the Git blob and pipeline bytes in all 10/10 cases;
- hidden space, punctuation, Unicode, wording, omission, addition, or semantic differences: 0.

Machine-readable evidence is in `byte-level-root-cause-probe.json` and `git-blob-worktree-loader-comparison.json`. The latter contains Git-blob, worktree, loader, normalized, and pipeline byte counts, SHA-256 values, line-ending counts, code-point counts, trailing-newline state, and blank-line state for every comparison.
