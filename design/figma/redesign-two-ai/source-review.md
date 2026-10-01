**Redesign Two — reminder-first pilot, source review. Notes out of scope. Date/time alerts pending owner decision, excluded.**

**1. Current manual creation vs missing entry points**

Current:
* Sole creation path is `BrainDumpView` composer: `TextEditor(text:$viewModel.text)` + mic via `toggleRecording()` + `Process` button gated by `canProcess` non-empty trim check calling `viewModel.startProcessing(modelContext:)`. Source: `BrainDumpView.composerSection/canProcess`.
* Review path is `ConfirmationView` + `ProcessingView`: live preview is not persisted; save only via `ConfirmationViewModel.save(modelContext:)` on `Looks Good!`, then `rootIsActive=false/onConfirmed()`. Back sets `rootIsActive=false` to return to composer unsaved. Edits limited to `removeTask/removeNewGoal/removeGoalUpdate/removeTaskCompletion/updateTaskGoal/moveToTasks/moveToGoals/moveGoalUpdateToTasks/handleDrop`. Source: `ConfirmationView.body/handleDrop`, `BrainDumpView.ProcessingView`.
* Model supports `Task.init(text:schedule:source:linkedGoal:)` with `TaskSchedule` Today/This Week/Someday and optional `linkedGoal`, and `Goal.init(name:color:)`. These are only populated via Brain Dump review in observed files.
* `TasksView.taskSection/TaskCardView` and `GoalsView.body/GoalCardView` are read/edit/link/complete only. No text field, add button, or create method present. `GoalsView` empty state explicitly says `Add one via brain dump`.

Missing:
* No direct task/reminder create entry in `TasksView` or Home.
* No direct goal create entry in `GoalsView`.
* No standalone link picker outside `ConfirmationView.ConfirmationItemRow` goal `Menu`.
* No manual save bypassing interpretation/review.

**2. 8 Brain Dump edge cases — retained-input/recovery [Current → Proposed]**

1. Empty/whitespace Process: Current `canProcess=false/disabled`. Proposed: retain disabled, no error toast.
2. No recognized items: Current `ConfirmationViewModel.isEmpty` shows `Hmm, I couldn't find any tasks or goals / Try rephrasing?`. Proposed: retain full composer text, one action back to `Compose`.
3. Cancel during `ProcessingView`: Current `onCancel/viewModel.cancelProcessing()`. Proposed: always return to composer with text intact, never clear.
4. Back from Review without saving: Current `rootIsActive=false`. Proposed: explicitly retain composer text and live preview state.
5. Mic denied/interrupted: Current `transcriptionService.permissionDenied/isProcessing` warning + `Enable in Settings`. Proposed: retain typed prefix `baseText`, keep typed entry usable, no overwrite by partial transcript.
6. All review items removed: Current `isEmpty` hides `Looks Good!`. Proposed: retain as no-op, offer return to composer; do not persist empty save.
7. Mis-categorized drag: Current `handleDrop/moveToTasks/moveToGoals`. Proposed: retain dragged text verbatim, allow reverse move, no loss on failed drop.
8. Dismiss Brain Dump mid-compose: Current `dismiss()` via leading arrow. Proposed: retain draft for session return; explicit discard only, never silent clear.

**3. Proposed minimal direct-create without AI [Proposed, not current]**

* Task: from Tasks list, new entry with required text + schedule default Today, optional active-goal link. Save creates `Task` directly; cancel discards. No interpretation, no preview, no auto-assign.
* Goal: from Goals list, new entry with required name + color choice. Save creates `Goal` directly; cancel discards.
* Link: task row link/unlink active goal at create and later edit; archiving behavior unchanged per `current-app-context.md`.
* Rules: empty text cannot save; failed validation retains input; success returns to originating list. No notes, no slogans, no alerts until owner clarifies.
