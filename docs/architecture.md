# Defog — Architecture Notes

Source: native SwiftUI code in `defog iOS/` at `11ba317`. This describes implementation, not proof of runtime correctness. See [development.md](development.md) for verified runs.

## Screen / service / data map

- Bootstrap: `defog_iOSApp` (App, container setup, transcription env, dark mode) to `ContentView` to `RootView` plus `RootViewModel` (onboarding, storage, daily prompt).
- Navigation: `MainTabView` (TabView sidebarAdaptable, per-tab NavigationPath, Add-tab intercept, settings and brain-dump covers, `setTabBarHidden` and `openSettings` env keys).
- Screens: `HomeView`, `DailySummaryView`, `TasksView`, `TaskCardView`, `GoalsView`, `GoalCardView`, `GoalDetailView`, `TimelineTabView`, `CalendarTabView`, `AIOverviewSheet`, `BrainDumpView`, `ProcessingView`, `ConfirmationView`, `OnboardingView`, `StorageChoiceView`, `SettingsView`, `ArchivedGoalsView`, plus components `TaskCardChrome`, `TaskPillView`, `ToastModifier`, `DailyPromptOverlay`, schedule extensions.
- Services: `OpenRouterCategorizationEngine`, `LegacyRuleBasedCategorizationEngine`, `TranscriptionService` plus `SFSpeechTranscriptionEngine`, `NotificationService`, `StorageMigrationService`, `UserPreferences`, `GoalDisplayNameFormatting`.
- Data: `Task`, `Goal`, `GoalEntry`, enums `TaskSchedule`, `InputSource`, `EntryType`, `StorageMode`.
- View models: `BrainDumpViewModel` (live + final orchestration), `ConfirmationViewModel` (review edits + save).
- Contracts: `Protocols.swift` (`CategorizationEngine`, `CategorizationResult`, `LiveExtractionResponse`, `LivePreviewContext`, `LivePreviewTaskLine`, `LiveVoiceCommand`, `ExistingOpenTaskSummary`, `CategorizationSource`, categorized structs).

## Principal data flow

1. `BrainDumpView` owns `BrainDumpViewModel` and reads `TranscriptionService` from environment plus `activeGoals` and `storedTasks` via `@Query`.
2. Text edits call `onTextChangedForLiveExtraction(modelContext:)`; transcription aggregate changes assign to `text` then call the same entry point.
3. Live path fetches non-archived goals and open tasks, builds `LivePreviewContext`, calls `categorizeLive`, merges, and renders `liveTasks`, `liveNewGoals`, `liveGoalUpdates`, `liveTaskCompletions`.
4. Process calls `startProcessing(modelContext:)` with the same fetches plus current live snapshot, awaits `categorize`, then publishes `categorizationResult`, which drives `ProcessingView.navigationDestination(item:)` to `ConfirmationView`.
5. `ConfirmationViewModel.save(modelContext:)` writes completions first, then new goals, then tasks with link resolution, then goal-update entries, then `modelContext.save`. Confirm also calls `NotificationService.shared.recordActivity`.
6. Lists elsewhere are reactive `@Query` views: Home incomplete tasks, Tasks all tasks, Goals non-archived goals, Archived only-archived goals, Daily Summary all tasks and goals filtered in memory by `isDateInToday`.

## Live extraction state management

- Debounce: `liveDebounceNanoseconds = 2_500_000_000`; each keystroke cancels prior `liveDebounceTask`, bumps `liveExtractionGeneration`, sleeps, then runs only if generation still current.
- Snapshot sent to LLM: `pendingNewGoalNames` plus `liveTasks` as `LivePreviewTaskLine` (text, schedule, linkedGoalName) via `livePreviewPromptBlock`.
- Merge preserves SwiftUI identity: `mergeTasksPreservingIds`, `mergeNewGoalsPreservingIds`, `mergeGoalUpdatesPreservingIds` match on normalized text or name (exact, then substring either direction) and reuse old `UUID`; otherwise keep fresh IDs. Goal merge also preserves prior display name.
- Goal-delete guards: `shouldRecoverEmptySnapshot` reuses prior tasks and goals when model returns both empty alongside a `delete_goal` command; `mergeTasksPreservingIdsWithGoalDeleteGuard` re-appends prior tasks dropped by the model unless explicitly targeted by `delete_task`.
- Synthetic fallback: `syntheticGoalDeleteCommandsIfNeeded` emits `delete_goal` when text contains removal phrasing plus a pending goal mention and no model command exists.
- Link resolution: `resolveLiveLinkedGoalName` prefers existing goal canonical name, then pending new goal, then formatted raw string. `ensureLiveNewGoal` creates pending goals for `link_goal` and `move_task_to_goal`.
- Commands applied in `applyVoiceCommands`: delete_task, rename_task, set_schedule, link_goal, delete_goal (unlinks tasks), rename_goal (renames links), move_task_to_goal, move_goal_to_task. Op parsing lowercases and converts hyphens to underscores; unknown ops ignored.
- Animation: alternating `taskInsertionFromLeading` and `goalInsertionFromLeading` maps drive asymmetric leading/trailing slide plus opacity; state updates wrapped in spring 0.42/0.86.
- Failure surface: `liveExtractionLoading` shows Understanding; `liveExtractionError` exists but is never assigned a message in current code.

## Identities, dedup, cancellation

- Persisted identity is `UUID` (`Task.id`, `Goal.id`, `GoalEntry.id`). Live rows mint fresh `UUID` per LLM snapshot, then merge reattaches stable IDs for animation and command targeting.
- Completion dedup: `mapOutput` and `mapLiveOutput` keep a `seenCompletionIds` set, require `UUID(uuidString:)` plus membership in `validTaskIds` from open tasks.
- Goal matching: normalize by lowercase plus punctuation trim; exact, then substring either way, then Levenshtein similarity at 0.78 for BYOM and 0.75 for legacy task-to-goal linking.
- Cancellation: `cancelLiveDebouncing` cancels debounce; `cancelProcessing` cancels `processingTask`; both live and final paths check `Task.isCancelled` and generation before publishing. `TranscriptionService` cancels `recordingTask` on stop.

## Persistence

- Schema is `Schema([Task.self, Goal.self, GoalEntry.self])` in `defog_iOSApp.setupContainer`. Local uses default `ModelConfiguration(isStoredInMemoryOnly: false)`; iCloud uses `ModelConfiguration(Cloud, schema:, cloudKitDatabase: .automatic)`. Errors fall back to in-memory with a console print.
- Relationships: `Task.linkedGoal` nullify; `Goal.entries` cascade with inverse `GoalEntry.goal`. Goal delete therefore removes entries; archiving is soft via `archivedAt` plus manual unlink of related tasks.
- Migration (`StorageMigrationService.migrate` actor, `AsyncStream<MigrationProgress>`): copies goals with IDs, dates, colors, archived state plus entries, then tasks with IDs, text, schedule, source, completed flags. Known gap: task `linkedGoal` is not restored and `goalIdMap` is unused; entry count excluded from progress total. No error is thrown to callers; failures print and finish the stream.
- `SettingsView.startMigration` guards local mode plus `ubiquityIdentityToken`, builds a `CloudMigration` container, consumes progress, then flips `UserPreferences.storageMode` to iCloud, which triggers container rebuild. CloudKit behavior itself is not verified in this docs task.

## AI request contract, retries, fallback

- Contract: POST `UserPreferences.aiEndpoint` with `OpenRouterRequest` (model, temperature 0.1, optional `response_format: json_object`, system + user messages). Timeout 45s final and live, 30s for Settings health check. OpenRouter hosts add `HTTP-Referer: https://defog.app` and `X-Title: Defog iOS`.
- Final prompt labels itself FINAL pass and asks to reconcile live preview; live prompt labels input IN-PROGRESS and documents command ops plus paraphrases for goal removal. Both request tasks, newGoals, goalUpdates, taskCompletions; live also requests commands. Schedules constrained to today, thisWeek, someday.
- Retry: first attempt includes `response_format`; on HTTP 400/422 retry without it; on any other throw, code performs one more attempt without it, then lets the error bubble to legacy fallback. Effective max two attempts per call.
- Decode hardening: `stripCodeFences`, `firstJSONObjectString` brace scan respecting quoted strings and escapes, tolerant camelCase plus snake_case keys, single-string fallbacks, plus a loose repair replacing newlines, tabs, and single quotes.
- Mapping differences: final `mapOutput` drops unknown goal links and unmatched goal updates; live `mapLiveOutput` preserves unknown links as display strings and keeps goal updates as name strings via `LivePreviewGoalUpdate`.
- Fallback: empty key uses legacy immediately; empty live text returns empty response; exceptions use `LegacyRuleBasedCategorizationEngine` and mark source `legacyLocal(reason:)` with no API key, connection failed, empty, or default path.
- Legacy engine (`NaturalLanguage`): sentence tokenize, clause split on commas/semicolons plus verb boundaries, preamble cleanup, finite vs ongoing verb sets, schedule keywords, imperative first-word hint, noun-based goal linking, quantifier and determiner checks to demote goals to tasks. It ignores `livePreview`.

## Transcription behavior

- Permissions via `SFSpeechRecognizer.requestAuthorization` and `AVAudioApplication.requestRecordPermission`, tracked as `isSpeechAuthorized`, `isMicrophoneAuthorized`, `permissionDenied`.
- Streaming via `transcribeStream` (`AsyncThrowingStream`): record category, measurement mode, duckOthers, partial results true, `requiresOnDeviceRecognition = false`, 1024-frame tap, yields `bestTranscription.formattedString` until final or error, then tears down engine and tap.
- Aggregation keeps user-typed `baseText` plus streaming suffix. Stop cancels the consumer task, ends audio, sleeps 200 ms, returns empty, so caller retains last partial as final.
- `isRecording` gates start; `isProcessing` is defined but never set, so the Finalizing UI branch is dead code paths today.

## Goal overview implementation

- `AIOverviewSheet` is local statistics, not a model call: most-active weekday by entry count, last-30-day count, encouragement tiers by days since last entry (on a roll under 3, still going up to 7, ready when idle), focus suggestion, and up to 3 recent detailed highlights. Empty state prompts Start logging to see patterns.
- Entry point is a sparkle FAB in `GoalDetailView`, visible only when entries exist. Presented as a sheet inside `NavigationView` with dismiss button. Do not describe it as remote AI; code has no network path there.
- Related computed views: `GoalCardView.calculateStreak` and `GoalDetailView.currentStreak` count consecutive unique entry days ending today or yesterday; momentum shown only at two plus days. `CalendarTabView` groups entries by start-of-day over a rolling 35 days; `TimelineTabView` sorts newest first with quick vs detailed rendering.
