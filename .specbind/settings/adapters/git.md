---
type: SpecBind Git Adapter
---

# Git adapter

This file is project policy for local workflow checkpoints. The sections below
contain a working default. Replace them when the project wants different commit
grouping, messages, or publication behavior.

This file sets policy, not permission. It cannot grant authority SpecBind does
not otherwise have, and it never changes when work becomes eligible to commit:
approvals, task completion, and repository safety stay SpecBind's contracts. A
checkpoint never includes unapproved, rejected, or unrelated work.

Emptying or removing this file means SpecBind commits nothing on its own.

## When to checkpoint

Create one local commit after each eligible workflow unit: completed Discovery,
each approved Requirements, Design, or Tasks gate, an accepted Contract review,
each completed implementation Task, a confirmed one-time Release adapter
bootstrap, and successful release finalization. Keep completion and finalized
release metadata in their own checkpoints when those workflows require one. A
completed `sb-steering` change is one Steering checkpoint. A completed
`sb-configure` change and its required or authorized aftercare form one
configuration checkpoint; declined optional aftercare is not included.
The explicit SpecBind update procedure is the exception: its binary-selection
change and product-asset refresh are two separate checkpoints so the refresh
starts from the clean worktree required by the installer.

A completed scoped shared Contract proposal preparation is also one eligible
checkpoint, before consumer Design or Contract review.

## What to include

Stage only the paths produced by that workflow unit. Leave unrelated work in the
worktree exactly as it is. If the intended paths cannot be separated safely,
stop before committing and report the accepted work as uncommitted.

## Commit messages

Use a concise, outcome-oriented summary in the project's language. Name the
Spec or Direct item when that makes the checkpoint easier to identify. Do not
amend, rebase, squash, or otherwise rewrite history by default; record a later
correction as an additional commit.

## TEMEL plan-gate bridge (project requirement, overrides message shape)

This repository enforces plan-gated commits: the commit-msg hook rejects any
commit without a `plan: <id>` trailer pointing at an accepted
`.archcore/plans/<id>.plan.md`. Therefore every SpecBind checkpoint commit in
this project MUST:

1. Correspond to an accepted `.archcore` plan (open one per Milestone, e.g.
   `plan: <milestone>-delivery`), with the checkpoint's paths inside that
   plan's `allowed_paths`.
2. Carry the trailer as the last line of the message body:
   `<summary>\n\nplan: <id>`.
3. If no accepted plan covers the checkpoint, stop before committing and report
   the accepted work as uncommitted — never commit without the trailer.

In a conflict between SpecBind checkpoint policy and the plan-gate, the
plan-gate wins; a rejected commit is not a SpecBind failure.

## Branches and pushing

Stay on the current branch. Do not create or switch branches solely for a
checkpoint. Do not push unless the user explicitly requested it for the current
run or an applicable project instruction separately requires it. Never
force-push or bypass a protected branch.
