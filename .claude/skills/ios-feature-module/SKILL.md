---
name: ios-feature-module
description: Use whenever the user wants to create a new feature module in CardsTracker. Triggers on any request like "add a new feature", "create a [name] module", "new screen for [something]", "add [feature] to the app" — even if the user doesn't say "module" explicitly. Always use this skill when a new feature needs to be wired into the app.
---

# Create a New Feature Module

This skill generates the complete boilerplate for a new feature module in CardsTracker, following the same structure as `CardsList` (the reference module).

## Before Starting

Read `references/templates.md` — it contains the exact code templates for every file. Do not invent structure or patterns; adapt the templates to the requested feature name.

## Step 1: Gather Information

Ask the user for:
1. **Feature name** (PascalCase, e.g. `CardSettings`, `TransactionHistory`) — this becomes the module name
2. **Model name** (PascalCase, e.g. `Setting`, `Transaction`) — the main data model for this feature
3. **Dependencies needed** — ask if the feature needs anything beyond the defaults (`Utilities`, `Extensions`, `Navigation`, `ComponentsUI`, `ResourcesUI`, `CoreServices`, `CoreModels`)

If the user says "same as CardsList" or "default", use the standard set.

## Step 2: Derive Naming Conventions

From the feature name (e.g. `CardSettings`), derive:
- `{{FeatureName}}` → `CardSettings` (PascalCase — used in class names, file names)
- `{{featureName}}` → `cardSettings` (camelCase — used in enum cases, variables)
- `{{feature-name}}` → `card-settings` (kebab-case — used in deep link URL hosts)
- `{{ModelName}}` → the model name provided (e.g. `Setting`)
- `{{modelName}}` → camelCase of model name (e.g. `setting`)

## Step 3: Create the File Structure

Create all files and folders under `Projects/Features/{{FeatureName}}/`. Use the templates from `references/templates.md`, substituting all placeholders.

File structure to create:
```
Projects/Features/{{FeatureName}}/
├── Project.swift
└── Sources/
    ├── {{FeatureName}}/
    │   ├── {{FeatureName}}Strings.swift
    │   ├── Models/
    │   │   └── {{ModelName}}.swift
    │   ├── Repository/
    │   │   ├── {{FeatureName}}Repository.swift
    │   │   └── {{FeatureName}}RepositoryProtocol.swift
    │   ├── List/
    │   │   ├── ListViewModel.swift
    │   │   ├── ListView.swift
    │   │   └── ListViewController.swift
    │   ├── Detail/
    │   │   ├── {{FeatureName}}DetailViewModel.swift
    │   │   ├── {{FeatureName}}DetailView.swift
    │   │   └── {{FeatureName}}DetailViewController.swift
    │   └── Navigation/
    │       ├── {{FeatureName}}RouteHandler.swift
    │       ├── Coordinator/
    │       │   ├── ListCoordinator.swift
    │       │   └── {{FeatureName}}DetailCoordinator.swift
    │       └── DeepLink/
    │           ├── {{FeatureName}}DeepLinkAction.swift
    │           └── {{FeatureName}}DeepLinkParser.swift
    ├── {{FeatureName}}Interface/
    │   └── {{FeatureName}}RouteRegistry.swift
    └── {{FeatureName}}Tests/
        └── {{FeatureName}}Tests.swift
```

## Step 4: Register the Feature

Before editing, **read both files first** to understand their current structure:

```
Read: Tuist/ProjectDescriptionHelpers/Features.swift
Read: Projects/CardsTracker/Sources/CardsTracker/App/AppRouter.swift
```

Then make the edits:

**1. `Tuist/ProjectDescriptionHelpers/Features.swift`** — add a new case to the `Feature` enum, following the exact same pattern as existing cases:
```swift
case {{featureName}}
```

**2. `Projects/CardsTracker/Sources/CardsTracker/App/AppRouter.swift`** — register the route handler and deep link parser:
- Add `import {{FeatureName}}` at the top alongside other feature imports
- Add `Container.shared.routerService().register(routeHandler: {{FeatureName}}RouteHandler())` in `registerAllRouteHandlers()`, following the same pattern as existing registrations
- Add the deep link parser registration in `registerAllDeepLinkParsers()`, following the same pattern

## Step 5: Verify Created Files

After creating all files, re-read the three most critical ones and verify:
- `Project.swift` — `{{FeatureName}}` placeholder fully replaced, no leftover `{{` or `}}`
- `ListViewModel.swift` — uses `@Observable`, has `@ObservationIgnored` before `@Injected`
- `{{FeatureName}}RouteRegistry.swift` — correct module name in the import

If any placeholder remains unreplaced, fix it before continuing.

## Step 6: Generate the Project

Run:
```bash
cd /path/to/CardsTracker && tuist generate --no-open
```

Then confirm to the user that the module is ready and list all files created.

## Important Rules

- Never use force unwrap (`!`) — follow the project's Swift conventions
- All imports must be present in every generated file — verify before writing
- ViewModels use `@Observable` (iOS 17+) — NOT `ObservableObject` or `@Published`
- Use `@ObservationIgnored` before `@Injected` properties in `@Observable` classes
- Repository methods return `Result<T, ServerError>` — never throw directly to the ViewModel
- Keep the same file naming conventions as `CardsList`
