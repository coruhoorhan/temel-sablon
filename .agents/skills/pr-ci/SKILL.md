---
name: pr-ci
description: Watch PR CI checks until green, fetch failed logs, categorize failures, and autonomously patch PR-related issues.
argument-hint: "[PR-number or empty for current branch]"
---

Babysit CI checks for the current PR ($ARGUMENTS). Do not abandon the task when a PR is opened; stay with it until CI verifies full compliance.

## Process

### 1. Watch CI Status
Monitor check suites using GitHub CLI:
```bash
gh pr checks $ARGUMENTS --watch --fail-fast
```

### 2. Diagnose Failures
If any required check fails, fetch the exact error logs:
```bash
# View failed job logs
gh run view --log-failed
```

### 3. Triage & Classify Root Cause
Categorize the failure into one of three buckets based on log evidence:
1. **PR Diff Issue** (Your responsibility):
   - Lint error, type mismatch, broken unit/E2E test, FSD Steiger failure, or coverage drop caused by changes in this PR.
   - **Autonomous Action**: Reproduce locally (`npm run verify` / `npm run arch:check`), apply fix, commit with valid plan trailer (`plan: <id>`), push, and restart CI watch.
2. **Flaky Test / Transient Infra Glitch**:
   - Network timeout, socket hangup, rate-limit, runner crash with no logical link to code changes.
   - **Action**: Trigger rerun via `gh run rerun <run-id> --failed` and continue watching.
3. **Upstream / Main Branch Breakage**:
   - The failure originates from `main` or an unmerged dependency unrelated to your PR.
   - **Action**: DO NOT modify unrelated files. Notify the user with exact log citations, and recommend rebasing once upstream is fixed.

### 4. Guardrails During CI Autofix
- NEVER force-push to shared branches unless performing an explicit rebase.
- Never bypass pre-commit or pre-push gates (`--no-verify` will be soft-reset by `post-commit`).
- Every fix commit MUST reference the approved plan trailer (`plan: <id>`).
