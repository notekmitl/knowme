# Root Cause

## Authorized compatibility defect

The former 14 branch-only Life Map V1.2.6-V1.3.2 failures were caused by four copy regressions in `life_map_semantic_mapper.dart`. The replacement copy introduced hedging, questions and abstract framing that violated the frozen product-language contracts. Restoring the exact main-branch copy makes the isolated scope pass 67/67 and the production-path matrix pass 864/864 with every weekday at 108/108.

This was a four-string compatibility defect, not a conflict across the V1.5 narrative system. The four rejected strings do not occur in the ten accepted R7.1 canonical Web/PDF text files.

## New full-suite blocker

The repaired branch has 18 branch-only screenshot failures:

- Profiles A, D, E, F, G and H.
- Desktop, tablet and mobile for each profile.
- All failures are in `test/validation/thai_mirror_qa_harness/screenshot_regression_test.dart` and target the Life Timeline section.

The same 18 golden PNG paths differ between starting branch HEAD and main. The previous gate recorded no screenshot branch-only failures. The four restored strings change the rendered Life Timeline against those branch-specific V1.5 goldens, while the main baseline retains its 39 unrelated failures.

## Required repair boundary

This task explicitly prohibits test changes and render/golden regeneration, so no golden was updated. A separate Owner-authorized repair must regenerate and manually inspect exactly the 18 affected Life Timeline goldens, prove that no other golden changes, and rerun every final gate. Until then the correct status is `BLOCKED`; PR #92 remains Draft, unmerged and undeployed.
