---
name: sentry-issues
description: Autonomous self-healing loop — triage production Sentry issues, reproduce via TDD, patch under mechanical gates, and open verified PRs.
argument-hint: "(run periodically or via /loop, e.g. `/loop 2h /sentry-issues`)"
---

Scan production issues in Sentry, prioritize actionable bugs affecting users, and autonomously generate safe, verified hotfix PRs.

There is no human in the loop during execution. Act autonomously, but obey all mechanical repository gates strictly.

## 1. Fetch & Triage Issues
Run the Sentry fetch utility:
```bash
bash .archcore/bin/sentry-fetch.sh issues 5
```
Filter for issues that:
- Are unhandled runtime errors (`TypeError`, `ReferenceError`, unhandled API rejection).
- Have a clear stack trace pointing to files in `src/`.
- Have a non-trivial event count or recent occurrence.

## 2. Isolate the Hotfix
For each issue to fix, hand off to an isolated branch based strictly on `origin/main`:
```bash
git fetch origin
git checkout -b fix/sentry-<issue-id> origin/main
```
Never stack a hotfix on top of an in-flight feature branch.

## 3. Self-Healing Execution under Harness (`/ship`)
Execute the full delivery cycle with the **`ship`** skill:
1. **Plan Authorization**: Create a quick plan in `.archcore/plans/sentry-<id>.plan.md` defining the targeted scope, and approve it via `.archcore/bin/approve-plan sentry-<id>`.
2. **TDD Reproduction (Red)**: Write a failing Vitest or Playwright test that directly reproduces the Sentry stack trace.
3. **Patch (Green)**: Apply the minimal fix:
   - Obey the 150-line rule (75 lines for `src/app/**/page.tsx`).
   - Zero `any`, zero unhandled null/undefined checks.
   - Respect FSD layer boundaries.
4. **Dual Review**: Run `technical-review` and `product-review` subagents.
5. **QA Proof**: Run `qa-change` (Playwright E2E or unit tests). Mechanical pre-commit gate will reject commits touching UI without test/artifact proof.
6. **Commit & Push**:
   ```bash
   git commit -m "fix(sentry): resolve <issue-id> <short-description>

   plan: sentry-<issue-id>"
   git push origin fix/sentry-<issue-id>
   ```

## 4. PR & Auto-Merge Decision
Open the PR with Sentry permalink and diagnostic evidence:
- **Low complexity & high confidence**: If the root cause was obvious (e.g. missing optional chaining or fallback prop) and reproduction test passes:
  ```bash
  gh pr create --title "fix(prod): resolve Sentry issue #<id>" --body "Closes Sentry issue: <permalink>\n\nReproduction test verified in CI."
  gh pr merge --auto --squash
  ```
- **High complexity or architectural risk**: Create the PR as a **Draft** for human review:
  ```bash
  gh pr create --draft --title "fix(prod): investigate Sentry issue #<id>" --body "Draft hotfix for <permalink>. Awaiting human sign-off."
  ```

Run `pr-ci` to watch checks until green before closing the loop.
