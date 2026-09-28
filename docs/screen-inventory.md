# Defog — Screen Inventory

Rows below are source-derived expectations. Runtime observations are tracked separately in the UX audit and evidence directory. Paths are under `defog iOS/Views/` unless stated otherwise.

| Screen | Source | Navigation | Important states |
|---|---|---|---|
| Root gate | `RootView.swift`, `ContentView.swift`, `defog_iOSApp.swift` | App to Content to Root; onboarding to storage to tabs | Initializing spinner; onboarding; storage choice; tabs plus daily overlay |
| Onboarding | `OnboardingView.swift` | First-run gate; read-only sheet from Settings | 3-page pager, Skip/Next/Get Started; read-only close button |
| Storage choice | `StorageChoiceView.swift` | Post-onboarding gate | iCloud/local buttons; iCloud-unavailable alert with Try Again / device-only |
| Main tabs | `MainTabView.swift` | Home / Tasks / Goals / Add intercept | Sidebar-adaptable tabs; bar hidden during brain dump, settings, or explicit child requests; goal detail retains the bar |
| Home | `Home/HomeView.swift` | Tab root; pushes `GoalDetailView`; MoreTasks pushes `TasksView`; sun button covers Daily Summary | Active-goals carousel; Today preview max 3; empty goals and tasks copy; toast |
| Daily Summary | `Home/DailySummaryView.swift` | Full-screen cover from Home | Empty sun state; completed-tasks list; per-goal today entries; encouraging footer |
| Tasks | `Tasks/TasksView.swift` | Tab root; also pushed from Home MoreTasks | Today / This Week / Someday sections with counts; collapsible Completed; per-task toasts |
| Task card | `Tasks/TaskCardView.swift`, components `TaskCardChrome.swift`, `TaskPillView.swift`, `TaskSchedule+TaskCard.swift` | Embedded in Home and Tasks | Inline edit; schedule menu; goal menu with accent bar; delete confirm; accessibility labels |
| Goals | `Goals/GoalsView.swift` | Tab root; pushes `GoalDetailView` | Empty target icon; goal cards with entry count and flame streak at 2+ days |
| Goal detail | `Goals/GoalDetailView.swift` | Pushed for `Goal` value | Segmented Timeline/Calendar; streak subtitle; quick + detailed entry bar; rename/archive/delete menu |
| Timeline | `Goals/TimelineTabView.swift` | Detail tab 0 | Empty clock state; dot-and-line rows; quick vs detailed rendering |
| Calendar | `Goals/CalendarTabView.swift` | Detail tab 1 | Last 35 Days grid; filled days by goal color; today outline |
| AI Overview | `Goals/AIOverviewSheet.swift` | Sheet FAB when entries exist | Local stats only; empty start-logging state; highlights; weekday and 30-day counts |
| Brain Dump | `BrainDump/BrainDumpView.swift`, `ViewModels/T3ViewModels.swift` | Full-screen cover from Add tab | Live preview sections; Understanding loader; keep-going hint; composer; mic; Process |
| Processing | `BrainDump/BrainDumpView.swift` `ProcessingView` | Pushed when `isProcessing`; hosts confirm destination | Spinner; Making sense; path label; Cancel; clears result on exit |
| Confirmation | `BrainDump/ConfirmationView.swift` | Pushed from Processing via result binding | Empty no-results state; completions; task schedule and goal menus; drag and drop; Looks Good |
| Settings | `SettingsView.swift` | Full-screen cover via `openSettings`; hosts Archived push | Tour, Appearance, BYOM, Reminders, Storage, Data Management; migration overlay |
| Archived Goals | `Settings/ArchivedGoalsView.swift` | Pushed from Settings | Empty copy; archived date; Unarchive; swipe delete |
| Daily prompt | `Components/DailyPromptOverlay.swift`, `RootView.swift` | Overlay over tabs on foreground | Stale-count copy; Move / Keep / Not now; backdrop dismiss may re-show |

## Cross-cutting states

- Empty: Home, Tasks sections, Goals, Timeline, Calendar (implicitly empty cells), Confirmation, Archived, Daily Summary all have explicit empty copy.
- Loading: app Initializing; live Understanding; Processing spinner; transcription Finalizing branch exists but unreachable because `isProcessing` never turns true; migration overlay with item counts.
- Errors: BYOM test fail message with status plus body prefix; migration failures only print; categorization failures fall back to legacy rather than showing errors; `liveExtractionError` never populated.
- Permissions: mic plus speech gating in brain dump with banner; notifications gating in Settings with Open Settings fallback; iCloud signed-in gating for storage choice and migration.
- Keyboard: brain-dump keyboard Done button; interactive scroll dismiss on brain dump, Home, and Tasks; task text submit on Done plus save on focus loss.
- Archive: soft `archivedAt` hides goals from main queries; detail archive unlinks tasks; archived list restores or permanently deletes with cascade entries.
- Settings: dark-mode switch, reminders switch, endpoint/key/model fields, storage mode readout plus Upgrade to iCloud, archived entry point, read-only tour replay.
- Daily Summary: derived from `completedAt` today and entry `createdAt` today; total counts one per task plus one per updated goal; footer tiers at 0, 1-2, 3+.

## Walkthrough checklist (simulator, no code changes)

1. Fresh install: confirm onboarding slides, Skip and Get Started paths, then storage choice.
2. Choose device-only; relaunch and confirm no repeat prompt.
3. Brain dump typed text with two intents; wait 3s and confirm live Tasks and Goals appear.
4. Tap Process; confirm Processing label; Cancel once, then Process again to Confirmation.
5. In Confirmation remove one row, change one schedule, link one task, drag goal to task, then Looks Good.
6. In Tasks edit text inline, try empty save, move schedule, link and unlink goal, delete with confirm.
7. Complete a linked task; confirm toast mentions goal; open goal Timeline for new entry.
8. In Goal detail add quick entry and one detailed entry; check Calendar cell and streak.
9. Open sparkle overview; verify local stats and empty-goal behavior on a fresh goal.
10. Home: verify Today preview limit, MoreTasks push, Daily Summary empty and non-empty states.
11. Settings: Test BYOM with empty key, bad URL, and valid key (do not record secrets); toggle dark mode and reminders; visit Archived Goals.
12. Archive a goal; verify tasks unlink; unarchive; delete an archived goal copy if expendable.
13. Background and foreground with a stale Today task; exercise Move, Keep, and backdrop dismiss.
14. Mic flow: deny then allow paths where safe; verify banner and typed-prefix preservation.
15. Record gaps: note CloudKit sync, remote AI, and notification delivery as unverified without asserting success.
