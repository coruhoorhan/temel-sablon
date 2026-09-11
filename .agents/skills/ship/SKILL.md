---
name: ship
description: End-to-end task implementation and delivery orchestrator with parallel reviews, visual QA evidence, and autonomous CI babysitting behind mechanical Git gates.
argument-hint: <task description>
---

Your task: $ARGUMENTS

You are executing a complete, senior-grade engineering delivery cycle. You do not stop at "code is written"; you verify, review, test with proof, commit under mechanical gates, open a PR with evidence, and watch CI until green.

## 0. Clean Starting Point & Plan Gate (Before Touching Code)

1. **Git Status**:
   - Run `git status --porcelain`. If there are uncommitted changes or stashes unrelated to this task, stop and resolve them.
   - Run `git branch --show-current`. You MUST NOT be on `main` or `master`. If you are, create a feature branch: `git checkout -b feat/<task-slug>`.
2. **Plan Gate**:
   - Check `.archcore/plans/`. A task must have an accepted plan file (`<id>.plan.md`) with valid `plan_hash` and `allowed_paths`.
   - If missing, draft the plan, verify allowed paths, and approve it via `.archcore/bin/approve-plan <id>`.

## 1. Implementation (TDD & FSD Discipline)

- **TDD (Red-Green-Refactor)**: Write failing tests first. Vitest anti-cheat is mechanically enforced: empty tests, missing `expect`, and skipped tests (`test.skip`) will fail the build.
- **Architectural Constraints**:
  - Max 150 lines per file (max 75 lines for `src/app/**/page.tsx`).
  - Max cyclomatic complexity: 10. Max parameters: 3. Max nested callbacks: 3.
  - Zero `any`, zero unexhausted switches, zero direct `fetch` in `ui/`.
  - FSD layers only (`src/{app,pages,widgets,features,entities,shared}`). Flat `src/components` is mechanically blocked by Steiger.

## 2. Two Parallel Reviews

Once code is written and tests pass, launch **two parallel subagents** over the diff (`git diff HEAD~1` or working changes):

1. **`technical-review`**: Fowler 12 code smells, FSD layer purity, type soundness, dead code.
2. **`product-review`**: Regressions, empty states, error states, loading states, mobile/responsive UX, accessibility.

Triage the findings: apply fixes for valid issues before proceeding.

## 3. Real QA & Proof of Function (`qa-change`)

Run the **`qa-change`** skill:
- **UI Surfaces**: Real browser testing via Playwright (`npm run test:e2e`). Produce visual proof (screenshot or `.mp4` video) in `.scratch/qa/`.
- **Backend / CLI Surfaces**: Execute the command or endpoint, capture output logs.
- **Mechanical Gate**: The Git hook `verify-qa-evidence.sh` will actively reject any commit touching UI files if neither a UI/E2E test nor a `.scratch/qa/` artifact exists.

## 4. Local Mechanical Verification & Commit

Execute the full verification suite:
```bash
npm run verify       # tsc --noEmit + eslint + vitest
npm run arch:check   # steiger FSD + knip
npm run coverage     # 80% line, 75% branch coverage
```

Commit your changes with the conventional commit format and required `plan` trailer:
```bash
git add <files>
git commit -m "feat(<scope>): <description>

plan: <plan-id>"
```
*Note: Any attempt to use `git commit --no-verify` will be caught by `post-commit` and immediately rolled back via `git reset --soft HEAD~1`.*

## 5. Push, PR & CI Babysitter (`pr-ci`)

1. **Push Branch**:
   ```bash
   git push origin <branch-name>
   ```
   *(Pre-push hook `verify-push` validates plan hash, coverage, and allowed paths).*

2. **Open PR with Attachments**:
   If visual QA artifacts were captured:
   ```bash
   gh pr create --title "feat(<scope>): <description>" --body-file .scratch/qa/pr-body.md --attach '.scratch/qa/screenshot.png'
   ```

3. **CI Babysitting**:
   Run the **`pr-ci`** skill:
   - Poll checks with `gh pr checks --watch --fail-fast`.
   - On failure, fetch logs with `gh run view --log-failed`.
   - If related to your PR: fix, commit with `plan: <id>`, push, and re-watch.
   - Only declare the task complete when all required checks are 100% green.
