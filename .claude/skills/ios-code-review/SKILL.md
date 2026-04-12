---
name: ios-code-review
description: >
  Review Swift/iOS code for correctness, architecture, and project conventions.
  Use this skill when asked to "review this file", "check this before I push",
  "is this code ok?", or any Swift code review request in CardsTracker.
---

# iOS Code Review

Review the provided Swift file(s) for issues across five areas: correctness,
Swift best practices, MVVM architecture, async/await, and UI/UX standards.

## Step 1 — Read context

Read `CLAUDE.md` at the project root to load the current architecture rules,
conventions, and SwiftLint thresholds before reviewing any file.

## Step 2 — Review the code

### ❌ Hard errors (must fix before pushing)
- Force unwrap (`!`) — always use `guard`, `if let`, or `??`
- Feature module importing another feature module directly
- `print()` statements — use `Logger` instead
- Missing `weak self` in closures that capture `self` strongly
- Hardcoded bundle IDs or URLs that should be constants

### ⚠️ Warnings (should fix)
- Function body over 60 lines
- Type body over 300 lines
- Line over 130 characters
- ViewModel not hiding dependencies behind a protocol
- Logic inside a View (should live in the ViewModel)
- Missing error handling on `async throws` calls
- `@ObservableObject` usage — prefer `@Observable` (iOS 17+)
- Data loading in `init` — prefer `viewDidLoad` / `task` modifier
- Missing `final` on classes that don't need inheritance
- `class` used where a `struct` would be more appropriate
- Missing or incorrect access control (`private`, `fileprivate`, `public`)
- Missing `@MainActor` or `await MainActor.run` for UI updates from async context
- Missing task cancellation support where long-running tasks are involved

### 💡 Suggestions (nice to have)
- `async let` or `TaskGroup` for operations that could run concurrently
- Accessibility — VoiceOver labels, Dynamic Type support
- Dark mode compatibility
- Colors not using `Palette` / fonts not using `Fonts` from ResourcesUI
- Missing `Equatable` / `Hashable` conformance where it would help
- Naming inconsistencies with the rest of the module
- Missing documentation on public APIs
- Test coverage gaps — if the file has no corresponding test file

## Step 3 — Output format

Structure your review as follows:

```
## Code Review Summary
✅ Strengths: [List positive aspects]
⚠️ Issues Found: [Count by severity]

## Critical Issues 🔴
[If any, list with explanations and fixes]

## Warning Issues 🟡
[List with explanations and recommended solutions]

## Suggestion Issues 🟢
[List with suggestions]

## Recommendations
[Additional improvements and optimizations]
```
