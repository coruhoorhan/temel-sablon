---
name: delegate
description: Scout a task, create an isolated Git worktree or branch from origin/main, brief an autonomous agent, and execute /ship.
argument-hint: <task description>
---

The task to delegate: $ARGUMENTS

You do not write implementation code in this session. You scout the codebase, identify constraints, isolate the workspace, brief an agent, and trigger delivery.

## 1. Scout Before You Delegate
Inspect the repo without making edits:
- Identify existing conventions and sibling modules.
- Check which layers of FSD will be touched (`features/`, `entities/`, etc.).
- Identify potential blockers, missing dependencies, or scope limits.

## 2. Create the Isolated Workspace
Create an isolated branch or worktree off `origin/main`:
```bash
git fetch origin
git checkout -b feat/<task-slug> origin/main
```
Or with Git worktree:
```bash
git worktree add -b feat/<task-slug> .worktrees/<task-slug> origin/main
```

## 3. Formulate the Brief
Generate a concise execution brief containing:
1. Exact task requirements.
2. Scouted file paths and sibling references.
3. Allowed paths for the plan gate (`allowed_paths`).
4. Strict instruction to execute `/ship`.

## 4. Launch & Monitor
Trigger `/ship` with the prepared brief to run the full TDD, review, QA, and CI delivery cycle.
