# Defog

Defog is a calm, brain-dump-first iOS productivity app. Users dump thoughts (text or voice), and an optional remote model or local rules categorize them into **Tasks** (finite checklist items) and **Goals** (ongoing pursuits). The app is built natively for iOS 26.1+ using SwiftUI and SwiftData.

## Start here

- [Agent and Git workflow](AGENTS.md)
- [Product behavior and limitations](docs/product.md)
- [Architecture](docs/architecture.md)
- [Build and verification](docs/development.md)
- [Screen inventory](docs/screen-inventory.md)
- [Design history](docs/design-history.md) and [case-study evidence](docs/case-study-evidence.md)
- [Current redesign status](docs/project-status.md)

## Repository structure

| Path | Description |
|---|---|
| `defog iOS/` | Native iOS app — all source code |
| `defog iOS/Models/` | SwiftData models: `Task`, `Goal`, `GoalEntry`, `Enums` |
| `defog iOS/Services/` | `CategorizationEngine` (OpenRouter BYOM + legacy fallback), `TranscriptionService` (SFSpeech), `NotificationService`, `StorageMigrationService`, `UserPreferences` |
| `defog iOS/ViewModels/` | `ConfirmationViewModel` and related in-flight models |
| `defog iOS/Views/` | All SwiftUI screens — BrainDump, Confirmation, Tasks, Goals, Home, Settings, Onboarding |
| `defog.xcodeproj/` | Xcode project file |
| `ui_shell_prototype_legacy/` | Legacy Figma-exported React prototype (reference only, not the product) |

## Tech stack

- **Language:** Swift (Swift 5 language mode)
- **UI:** SwiftUI
- **Persistence:** SwiftData (local) + CloudKit (optional iCloud sync)
- **AI categorization:** OpenRouter BYOM (any OpenAI-compatible endpoint) with `LegacyRuleBasedCategorizationEngine` fallback
- **Voice transcription:** `SFSpeechRecognizer` (immediate)
- **Minimum deployment:** iOS 26.1

## Getting started

1. Open `defog.xcodeproj` in Xcode 26.2 (verified)
2. Select the shared `defog-cli` scheme and a simulator or device running iOS 26.1+
3. Build and run (`⌘R`)
4. (Optional) Add an OpenRouter API key in **Settings → AI Settings** to enable LLM-powered categorization

## Key features

- Brain dump input (text or voice) → AI categorization → editable confirmation screen
- Tasks with soft scheduling (Today / This Week / Someday) and optional goal linking
- Goals with quick logging ("Did something today") and detailed entry logging
- Completing a goal-linked task auto-logs a detailed entry to that goal
- Goal timeline view + calendar heatmap + momentum indicator
- Per-goal progress overview (labeled AI Overview in the app; implemented as local statistics without a model call)
- Daily summary screen
- Optional CloudKit storage configuration (chosen at first launch; local-only mode available). Sync has not been validated in the current baseline review.
- Inactivity nudge notification (3 days of no activity)
- Dark mode support

## Configuration

- **AI:** Settings → AI Settings → paste any OpenRouter-compatible API key + choose model. Falls back to on-device rule-based categorization if no key is set.
- **Voice:** Settings → Voice. Transcription uses Apple's SFSpeech framework; server recognition is permitted, so it is not guaranteed to stay on-device.
- **Sync:** Chosen at first launch. Local → iCloud upgrade is available in Settings, but the current migration omits task-to-goal links. iCloud → local is not supported. See the development notes before testing migration with meaningful data.
