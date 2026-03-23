# CardsTracker

An iOS application for tracking credit and debit card expenses. CardsTracker lets users visualize their cards, monitor spending against limits, and keep track of upcoming due dates.

> **Note:** This is a work-in-progress example project. Several features are still under development, including transaction detail views, limit management screens, and more.

---

## Features (current)

- Card list view displaying all registered cards
- Visual card component supporting multiple card types (credit/debit, plastic/virtual)
- Color-coded cards with gradient themes (Green, Purple, Pink, Violet, Orange, White)
- Paused card state indicator
- Skeleton loading state for async data
- Custom SF Pro Rounded typography
- Adaptive color palette with light/dark mode support

## Planned Features

- Transaction detail view
- Spending limit management
- Due date reminders
- Card detail screen
- Data persistence

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Minimum iOS | iOS 17.0 |
| Project Generation | [Tuist](https://tuist.io) |
| Dependency Injection | [Factory](https://github.com/hmlongco/Factory) 2.4+ |

---

## Project Structure

```
CardsTracker/
├── CardsTracker/
│   └── Sources/
│       ├── CardsTrackerApp.swift       # App entry point
│       ├── Models/
│       │   └── Card.swift              # Card data model
│       ├── List/
│       │   ├── ListView.swift          # Main card list screen
│       │   ├── ListViewModel.swift     # List business logic
│       │   └── Subviews/
│       │       └── CardListItem/       # Individual card row
│       ├── Components/
│       │   ├── CardView/               # Reusable card visual component
│       │   └── NavigationBarView/      # Custom navigation bar
│       └── Utilities/
│           ├── Palette.swift           # Design system colors
│           ├── Fonts.swift             # Typography
│           ├── Haptic.swift            # Haptic feedback
│           ├── Skeleton.swift          # Loading skeleton modifier
│           └── Extensions.swift       # Swift/SwiftUI extensions
├── CardsTrackerResources/              # Assets, fonts, images
├── CardsTrackerTests/                  # Unit tests
├── Project.swift                       # Tuist project definition
├── Package.swift                       # SPM dependencies
└── Tuist.swift                         # Tuist configuration
```

---

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15 or later
- [Tuist](https://tuist.io) — project generation tool
- [Mise](https://mise.jdx.dev) *(optional but recommended)* — tool version manager

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/sebastianburrieza/cards-tracker.git
cd cards-tracker
```

### 2. Install Tuist

Tuist is required to generate the Xcode project. The recommended way is via Mise:

```bash
# Install Mise (if not already installed)
curl https://mise.run | sh

# Install Tuist through Mise
mise install tuist
```

Alternatively, install Tuist directly:

```bash
curl -Ls https://install.tuist.io | bash
```

Verify the installation:

```bash
tuist version
```

### 3. Fetch dependencies and generate the Xcode project

From the root of the repository, run:

```bash
tuist install
tuist generate
```

- `tuist install` — resolves and fetches all Swift Package Manager dependencies (e.g. Factory).
- `tuist generate` — generates the `CardsTracker.xcworkspace` file from `Project.swift`.

### 4. Open the project

```bash
open CardsTracker.xcworkspace
```

> Always open the `.xcworkspace` file, not the `.xcodeproj`, to ensure all dependencies are loaded correctly.

### 5. Select a simulator and run

In Xcode:
1. Select the `CardsTracker` scheme from the scheme picker.
2. Choose an iOS 17+ simulator (e.g. iPhone 15).
3. Press `Cmd + R` to build and run.

---

## Regenerating the project

Whenever `Project.swift` or `Package.swift` changes (e.g. after adding a new dependency or target), regenerate the Xcode project:

```bash
tuist generate
```

---

## Running Tests

Select the `CardsTrackerTests` scheme in Xcode and press `Cmd + U`, or run from the terminal:

```bash
tuist test
```
