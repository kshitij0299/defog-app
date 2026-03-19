# Defog

Defog is a calm, brain-dump-first iOS productivity app. Users dump thoughts (text or voice), and on-device AI categorizes them into **Tasks** (finite checklist items) and **Goals** (ongoing pursuits). The app is built natively for iOS 17+ using SwiftUI and SwiftData.

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

- **Language:** Swift 5.9+
- **UI:** SwiftUI
- **Persistence:** SwiftData (local) + CloudKit (optional iCloud sync)
- **AI categorization:** OpenRouter BYOM (any OpenAI-compatible endpoint) with `LegacyRuleBasedCategorizationEngine` fallback
- **Voice transcription:** `SFSpeechRecognizer` (immediate)
- **Minimum deployment:** iOS 17

## Getting started

1. Open `defog.xcodeproj` in Xcode 15+
2. Select a simulator or device running iOS 17+
3. Build and run (`⌘R`)
4. (Optional) Add an OpenRouter API key in **Settings → AI Settings** to enable LLM-powered categorization

## Key features

- Brain dump input (text or voice) → AI categorization → editable confirmation screen
- Tasks with soft scheduling (Today / This Week / Someday) and optional goal linking
- Goals with quick logging ("Did something today") and detailed entry logging
- Completing a goal-linked task auto-logs a detailed entry to that goal
- Goal timeline view + calendar heatmap + momentum indicator
- Per-goal AI Overview (activity patterns, encouragement, highlights)
- Daily summary screen
- iCloud sync (optional, chosen at first launch; local-only mode available)
- Inactivity nudge notification (3 days of no activity)
- Dark mode support

## Configuration

- **AI:** Settings → AI Settings → paste any OpenRouter-compatible API key + choose model. Falls back to on-device rule-based categorization if no key is set.
- **Voice:** Settings → Voice. Voice transcription is handled by Apple's SFSpeech framework.
- **Sync:** Chosen at first launch. Local → iCloud upgrade available in Settings. iCloud → local is not supported.
