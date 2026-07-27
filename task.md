# Task: Restore accepted Thai Life Map customer-facing report

Remove the V1.3.5 `_DetailedEvidenceReport` evidence/debug dump from the ordinary
user render path on `/beta/thai`. Restore the last accepted pre-V1.3.5 human-
readable Life Map (baseline merge `7a3d07d` / docs tip `14ed096`). Keep V1.3.5
evidence models and calculations as internal infrastructure only.
