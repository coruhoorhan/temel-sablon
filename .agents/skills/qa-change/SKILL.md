---
name: qa-change
description: Live QA verification with mandatory visual/log evidence — Playwright browser testing with video/screenshots for UI, or live execution logs for backend.
argument-hint: "[focus area — defaults to working diff]"
---

Verify the changes in your working branch by executing them in a real runtime environment and capturing deterministic proof.

Unverified assertions ("I reviewed the code and it works") are strictly prohibited by repo commandments and mechanically blocked by Git gates.

## 1. Classify the Surface Under Test

Inspect the diff:
- **UI Surface**: Files in `src/**/ui/**`, `src/app/**`, `src/pages/**`, or `.tsx` components.
- **Backend / Non-UI Surface**: API handlers, database queries, CLI scripts, utility logic.

## 2. Execution for UI Surfaces (Mandatory Visual Proof)

For any task touching UI components:
1. **Run Playwright E2E Tests**:
   ```bash
   npm run test:e2e
   ```
2. **Capture Visual Evidence**:
   - Save screenshots (`.png`) or recorded interaction videos (`.mp4`) into `.scratch/qa/`.
   - Provide Before / After screenshots for visual redesigns or component refactors.
   - For interactive flows (modals, dropdowns, forms), ensure a video or multi-state snapshot is recorded.
3. **Mechanical Guardrail**:
   - The pre-commit hook `.archcore/bin/verify-qa-evidence.sh` will actively reject your commit if UI files are modified without either an E2E test (`e2e/*.spec.ts`) or a recent visual artifact in `.scratch/qa/`.

## 3. Execution for Backend / Non-UI Surfaces

For backend, CLI, or infrastructure tasks:
1. Execute the actual command or endpoint in the terminal.
2. Inspect the database state or returned payload.
3. Save the terminal verification transcript into `.scratch/qa/backend-verification.log`.

## 4. Prepare Evidence for PR

Ensure evidence is referenced so that `ship` can attach it to the PR:
- Write a short summary of tested flows in `.scratch/qa/pr-body.md`.
- Ensure media files are present in `.scratch/qa/` so `gh pr create --attach` can upload them.
