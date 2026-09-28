# Defog — Product Notes

Snapshot: `live-view` commit `11ba317`, inspected 2026-09-28. Source paths below are relative to `defog iOS/` unless stated otherwise. Build and runtime evidence are tracked in [development.md](development.md) and [project-status.md](project-status.md).

## Purpose

Defog is a calm brain-dump-first iOS app. User types or speaks a free-form dump, sees a live preview of extracted items, taps Process for a final pass, then reviews and confirms into persisted data. See `BrainDumpView`, `BrainDumpViewModel`, `ProcessingView`, `ConfirmationView`.

## Task vs goal (code fact)

- Task (`Models/Task.swift`): finite one-off item. Fields: `text`, `completed`, `schedule` (today/thisWeek/someday), `source` (typed/voice), `createdAt`, `completedAt`, optional `linkedGoal` (nullify on goal delete).
- Goal (`Models/Goal.swift`): ongoing pursuit. Fields: `name`, `color` hex, `createdAt`, `archivedAt`, `entries` cascade.
- GoalEntry (`Models/GoalEntry.swift`): progress note. Fields: `text?`, `type` (quick/detailed), `createdAt`, `goal?`.
- Onboarding copy states it plainly: Tasks are finite; Goals are journeys (`Views/OnboardingView.swift`).
- Rule used by both LLM prompts and legacy engine: broad ongoing pursuit = goal; specific one-time activity = task even if aspirational; when in doubt, task.

## Core flow: live preview to Process to review/confirm

1. Compose in `BrainDumpView`: `TextEditor` + placeholder, mic button, Process button. Typing or `TranscriptionService.aggregatedText` drives `onTextChangedForLiveExtraction`.
2. Live preview (debounced 2.5s, `BrainDumpViewModel.scheduleLiveExtraction`): sections for Marking complete, Tasks, Goals, Goal updates. Loading row shows Understanding. Empty-with-text hint: Keep going — recognized tasks and goals show up here.
3. Process (`startProcessing`): cancels live debounce, fetches non-archived goals + open tasks, sends full text plus `LivePreviewContext` for reconciliation, waits 1s artificial delay, then navigates `ProcessingView` to `ConfirmationView` via `navigationDestination(item:)`. Button disabled when trimmed text empty. Recording is stopped first and `aggregatedText` copied into `text`.
4. Processing screen: spinner, Making sense..., `processingPathLabel` (e.g. Using local rules (no API key)). Cancel calls `cancelProcessing`.
5. Review and Confirm (`ConfirmationView`): editable lists for completions, tasks, new goals, goal updates. Header hint: Tap x to remove, tap tag to reschedule, tap goal chip to reassign. Drag and drop between Tasks and New goals. `Looks Good!` saves via `ConfirmationViewModel.save`, records activity, dismisses. Back arrow returns to editor without saving. Empty result shows Hmm, I could not find any tasks or goals. Try rephrasing?

## Task completion and goal progress (code fact)

- Completing a goal-linked task in `TaskCardView.toggleCompletion` sets `completedAt`, inserts detailed `GoalEntry` with task text, toasts Task done plus goal name, records activity.
- Confirming a detected completion in `ConfirmationViewModel.save` does the same for each matched persisted task.
- Uncompleting clears `completedAt` and toasts Task reopened; it does not remove the auto-created entry.
- Goal logging in `GoalDetailView`: `Did something today` appends quick entry; pencil button reveals `What did you do today?` detailed entry with Save Entry. Both record activity.
- Streak, timeline, heatmap, and overview all derive from `goal.entries` dates; see architecture notes.

## Editing and scheduling (code fact)

- Tasks tab groups by Today / This Week / Someday plus collapsible Completed (`Views/Tasks/TasksView.swift`). Home shows Active Goals carousel + up to 3 Today tasks + more link.
- `TaskCardView`: inline `TextField` edit (reverts on empty, saves on submit or focus loss), schedule `Menu` (Today / This Week / Someday), goal `Menu` (No goal + active goals), delete `Menu` with confirmation alert, toasts for every mutation.
- Confirmation rows: schedule tag menu, goal link menu, remove buttons, drag payloads `task:UUID`, `newGoal:UUID`, `goalUpdate:UUID`.
- Goal detail menu: Rename (alert), Archive (sets `archivedAt`, nulls `linkedGoal` on related tasks), Delete (cascade deletes entries). Archived list supports Unarchive and swipe-delete.
- Daily prompt (`RootViewModel.checkDailyPrompt`): on foreground, if any incomplete Today task was created before today and no prompt shown today, overlay offers Move to This Week / Keep in Today / Not now. Dismiss-only path may re-show same day.

## BYOM and failures (code fact)

- Bring-your-own-model in Settings: Endpoint URL, API Key, Model ID. Defaults point at OpenRouter chat completions with `openai/gpt-4o-mini`. Keys stored in `UserDefaults` via `UserPreferences` with legacy key compat.
- Test BYOM Connection sends a small health-check prompt, checks HTTP 2xx plus `choices` substring, shows pass/fail, collapses section on pass. Not simulator-verified in this snapshot task.
- No key means legacy local rules with label Using local rules (no API key). Any request exception falls back to legacy with label Using local rules (connection failed). Live path falls back silently to legacy snapshot with no commands.
- Strict validation drops unknown links and unmatched goal updates on the final pass; live pass preserves raw labels for display. Invalid completion IDs are ignored and duplicates deduped.

## Voice (code fact)

- `TranscriptionService` wraps `SFSpeechRecognizer` en-US plus `AVAudioEngine`, streaming partial results into `aggregatedText = baseText + transcript`.
- Brain dump mic toggles recording; typed prefix is preserved with a trailing space. Permission-denied banner offers Enable in Settings.
- Current code sets `requiresOnDeviceRecognition = false`, so server recognition is allowed. This contradicts any on-device-only README claim.
- `stop()` always returns empty string after 200 ms, so final text falls back to last partial transcript. `isProcessing` flag is never set true, so Finalizing transcription copy is currently unreachable.

## Storage and onboarding (code fact)

- First launch order in `RootView`: Onboarding (3 slides, Skip/Next/Get Started) then Storage choice (Use iCloud recommended / This device only), then `MainTabView`.
- Storage choice checks `ubiquityIdentityToken` for iCloud; failure shows iCloud Unavailable alert. Local-to-iCloud upgrade in Settings copies goals, entries, and tasks with preserved IDs but does not copy task-to-goal links. iCloud-to-local is not offered.
- Persistence is SwiftData `Task`, `Goal`, `GoalEntry`. Local config is default store; iCloud config is named Cloud with `cloudKitDatabase: .automatic`. Container rebuilds on storage-mode change; init failure falls back to in-memory.
- Preferences in `UserDefaults`: onboarding, storage, dark mode, reminders, AI endpoint/key/model, last activity and prompt dates. Dark mode applies via `preferredColorScheme`. Reminders toggle requests notification permission and schedules a 3-day inactivity nudge.

## Capabilities vs limitations

Implemented: dump to live preview to confirm; task scheduling and goal linking; quick/detailed goal logging; completion auto-logging; timeline + 35-day heatmap + streak; local rule-based overview; daily summary; archive/unarchive; toasts; dark mode; local persistence; optional CloudKit container config.

Limitations: no remote sync verification in this task; no remote AI verification; legacy engine never emits completions or voice commands; saved tasks always store `source = .typed`; migration drops links; transcription final relies on partials; overview is deterministic stats, not an LLM call despite the sparkle affordance.

## Design intent and proposed work (separate from facts)

README describes calm productivity, momentum, and encouragement copy. Those intentions match visible strings (e.g. A little goes a long way, You showed up today) but no user research is cited in code. Figma prototype approval is pending and no application changes are authorized; treat any redesign as proposed, not implemented.
