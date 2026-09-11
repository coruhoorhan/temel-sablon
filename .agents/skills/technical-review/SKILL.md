---
name: technical-review
description: Deep technical review of a diff — Fowler 12 code smells, FSD architectural hierarchy, cognitive complexity, and type soundness.
argument-hint: "[ref or PR to review — defaults to working diff]"
---

Review the diff between the current working branch and the base branch (or the specified ref in `$ARGUMENTS`).

Focus strictly on code architecture, maintainability, and clean code principles. Match findings against these concrete standards:

## 1. Fowler's 12 Code Smells
Match each smell against the diff, quote the offending hunk, and suggest the fix:
- **Mysterious Name**: Names that fail to reveal intent or mislead. → Rename cleanly.
- **Duplicated Code**: Identical or near-identical logic across files. → Extract shared utility or hook.
- **Feature Envy**: A function reaching excessively into another module's data. → Move function closer to the data.
- **Data Clumps**: Parameters or fields that constantly travel together. → Group into a dedicated type.
- **Primitive Obsession**: Raw primitives representing domain entities (e.g. raw string for currency or email). → Wrap in a domain type.
- **Repeated Switches**: Recurring `switch` or `if-else` chains on the same enum/type. → Use polymorphism or lookup map.
- **Shotgun Surgery**: A single conceptual change forcing edits across multiple distant files. → Consolidate co-changing logic.
- **Divergent Change**: A single module modified for multiple unrelated reasons. → Split module by responsibility.
- **Speculative Generality**: Over-engineered abstractions, unused generics, or premature flexibility. → Inline and simplify.
- **Message Chains**: Deep nested access chains (`a.b().c().d()`). → Law of Demeter; hide the traversal.
- **Middle Man**: Functions or classes that only forward calls without adding value. → Remove intermediate proxy.
- **Refused Bequest**: Inheritors or implementers that ignore inherited functionality. → Favor composition over inheritance.

## 2. FSD Architectural Hierarchy
- Check import directions: Imports must strictly flow downward (`app` → `pages` → `widgets` → `features` → `entities` → `shared`).
- Cross-imports on the same layer are strictly forbidden (e.g. `features/a` must never import `features/b`).
- UI purity: Components in `*/ui/` must not execute direct global `fetch` calls or hold heavy business logic; data fetching must be in `model/` or `api/`.

## 3. Complexity & Limits
- Are any non-test files exceeding 150 lines? (75 lines for `src/app/**/page.tsx`).
- Are any functions exceeding cyclomatic complexity 10 or 3 parameters?
- Are there any `any` types or unsafe type assertions (`as Type`)?

Output a concise, categorized report with clear file/line references and actionable recommendations.
