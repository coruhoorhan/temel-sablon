---
name: product-review
description: Product, UX, and resilience review of a diff — regressions, empty/error/loading states, responsive design, and accessibility.
argument-hint: "[ref or PR to review — defaults to working diff]"
---

Review the diff between the current working branch and the base branch (or the specified ref in `$ARGUMENTS`).

Adopt the mindset of a Senior Product Engineer and QA Architect. Analyze how these code changes will actually behave for end users under real-world conditions.

## 1. Resilience & State Boundaries
- **Empty States**: What happens when an array is empty, a user has no data, or a list returns 0 results? Does the UI render a graceful placeholder or a broken blank box?
- **Loading & Pending States**: Are buttons disabled during submission to prevent double-clicks? Are skeletons or loading spinners present during asynchronous transitions?
- **Error States**: What happens if the network fails (offline, 500 status, timeout)? Is an actionable error message shown, or does the app crash silently / show unhandled error boundaries?
- **Regressions & Side-Effects**: Could this change inadvertently alter the behavior of other related flows or shared components?

## 2. UX & Responsiveness
- **Mobile vs Desktop**: Does the layout break on small viewports? Are tap targets at least 44x44px? Do inputs cause unexpected viewport zoom?
- **Interaction Feedback**: Is there immediate visual feedback when an interactive element is clicked, hovered, or focused?

## 3. Accessibility (a11y)
- **ARIA & Labels**: Do icon buttons have `aria-label`? Do form inputs have associated `<label>` or `aria-labelledby`?
- **Keyboard Navigation**: Can all interactive elements be reached and operated via `Tab` and `Enter` / `Space`?
- **Color Contrast & Focus Rings**: Are focus outlines preserved for keyboard users?

## 4. Spec Fit & Scope Creep
- Did the implementation deliver exactly what was specified?
- Are there unrequested features, dead experiments, or scope creep introduced in the diff?

Report findings categorized into:
- **Blockers** (must fix before shipping)
- **Improvements** (nice to have)
- **Confirmed Passes** (areas verified to be solid)
