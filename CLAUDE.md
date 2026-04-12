# CardsTracker — Claude Instructions

## Project Overview

CardsTracker is a modular iOS app for tracking credit/debit card expenses. It uses Tuist for project generation and follows a feature-based modular architecture.

- **Architecture**: MVVM with async/await
- **UI Framework**: SwiftUI
- **Build System**: Tuist for project generation and modularization
- **Dependencies**: Swift Package Manager
- **Language**: Swift 5.9+
- **Min iOS**: 17.0
- **Dependency injection**: Factory 2.5.3
- **Code quality**: SwiftLint

---

### Modular Architecture

The project follows a modular architecture with three main categories:

1. **Features** (`Projects/Features/`): Independent feature modules
   - Each feature has its own Framework, Interface and Tests targets
   - **Reference Module**: `CardsList` - use as template for new features
   
2. **Dependencies** (`Projects/Dependencies/`): Shared utility modules
   - `ResourcesUI`: Design system for UI components
   - `ComponentsUI`: UI components in SwiftUI
   - `CoreModels`: Data models and business logic
   - `CoreServices`: Network services and API clients
   - `Navigation`: Router, Coordinator and Depplinks
   - `Utilities`: Common utilities and extensions

3. **Main App** (`Projects/CardsTracker/`): Main application target with extensions
   - App delegate, navigation, and startup logic


## Key Commands

```bash
tuist install          # Fetch SPM dependencies
tuist generate         # (Re)generate Xcode workspace — run after any Project.swift or Package.swift change
tuist test             # Run all tests
open CardsTracker.xcworkspace  # Always use the workspace, never .xcodeproj
```

---

## Project Structure

```
CardsTracker/
├── Projects/
│   ├── CardsTracker/              # Main app target
│   ├── Features/
│   │   └── CardsList/             # Feature module (interface + tests)
│   └── Dependencies/              # Shared modules
│       ├── Navigation/
│       ├── CoreServices/
│       ├── CoreModels/
│       ├── ComponentsUI/
│       ├── ResourcesUI/
│       ├── Utilities/
│       └── Extensions/
├── Tuist/
│   └── ProjectDescriptionHelpers/ # Build config helpers
├── Package.swift                  # External SPM deps (Factory only)
├── Workspace.swift                # Tuist workspace definition
└── .swiftlint.yml                 # SwiftLint rules
```

---

## Architecture

- **Coordinator + Router + DeepLinkHandler** for navigation across all features
- **Factory** for dependency injection — registered in `AppRouter.swift`
- Modules follow two patterns:
  - `frameworkWithInterface()` — framework + public interface target + tests (used by most deps and features)
  - `singleFramework()` — single target, no interface (Navigation)
- Feature modules depend only on dependency modules, never on each other
- Bundle prefix: `com.cardsTracker`

---

## Adding a New Feature Module

1. Create `Projects/Features/<FeatureName>/` with `Project.swift` using `frameworkWithInterface()`
2. Register the feature in `Tuist/ProjectDescriptionHelpers/Features.swift`
3. Wire up routes/deep links in `AppRouter.swift`
4. Run `tuist generate`

## Adding a New Dependency Module

1. Create `Projects/Dependencies/<ModuleName>/` with `Project.swift`
2. Register it in `Tuist/ProjectDescriptionHelpers/Dependencies.swift`
3. Run `tuist generate`

---

## Swift Conventions

- **Never use force unwrap (`!`)** — always use `guard`, `if let`, or `??` to handle optionals safely

---


## SwiftLint Rules (key thresholds)

- Line length: 130 (warning), 200 (error)
- File length: 400 (warning), 600 (error)
- Function body: 60 lines (warning), 100 (error)
- Type body: 300 lines (warning), 400 (error)
- No `print` statements — use `Logger` instead (custom rule)
- Tests and `Derived/` folders are excluded

---

## Git & GitHub

Remote: `https://github.com/sebastianburrieza/cards-tracker.git`

After pushing a new branch, provide:
1. A short PR description (1–3 sentences)
2. Direct link to open the PR: `https://github.com/sebastianburrieza/cards-tracker/pull/new/BRANCH_NAME`

## Tuist

### Cache Management Rules
- Execute `tuist clean` only if explicit error related to external dependencies, cache corruption, or package installation issues appears
- Don't use `tuist clean` as standard step in each generation cycle, as it can be expensive and doesn't add value if there are no dependency errors
- If error is module configuration, internal dependencies, or cycles, fix the code and execute `tuist generate --no-open` directly
- Clean `.build` folder or caches manually only if error requires it (e.g., persistent "Bus error" after fixing external dependencies)
- If add new modules, target or folder always execute `tuist generate` directly
