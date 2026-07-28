# Task: Fix anonymous Thai Beta route preservation

Production re-check confirmed that the anonymous `/beta/thai` flow renders and
completes, but its dedicated app shell registers the landing page as `/`. This
rewrites the browser address to root and makes reload leave the Thai Beta route.

Preserve `/beta/thai` as the shell's initial Navigator route, add focused
regression coverage, and make no other application, feature-flag, invite-list,
Firebase configuration, narrative, or production behavior changes.
