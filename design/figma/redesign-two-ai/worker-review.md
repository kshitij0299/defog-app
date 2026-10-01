Review of `redesign-two-ai.md` + `manual-flows.js` as Figma prototype construction code only:

### Critical flow problems (fix in prototype logic/copy)

**1. Saved task is live-bound to draft vars — edit/discard mutates displayed task (`manual-flows.js:45,37,42`)**
`sch.Kind<>vSchedule`, `goal.Kind<>vGoal`, `visible<>vSaved`. After Save, opening `More actions -> filled` and changing Schedule/Goal or `Discard draft` instantly changes the already-saved Home/Tasks item, even before Save.
Fix: snapshot on Save to separate `savedSchedule/savedGoal` vars for display; keep `draft*` for editing only.

**2. Draw shows any saved task regardless of link (`manual-flows.js:45`)**
`draw` task `visible<>vSaved` only. Save with `No goal/Guitar/Read/Run` still appears in Draw.
Fix: gate `draw` instance on `draftGoal==Draw` (conditional or second `savedGoalIsDraw` boolean set on Save), keep on-demand disclosure.

**3. Origin lost: Home/Tasks/Draw all funnel to fixed targets (`manual-flows.js:36,37,42,43`)**
`empty Cancel->home`, `filled Save->tasks`, `leave-task Discard->home`, `draw New task->empty` (whose Back is `home`). Draw `New task > Save` strands user in Tasks, never returns to Draw to see linked task.
Fix: store `entryPoint` var on `New task` and branch `Save/Discard/Cancel` to it; do not change Today/This Week/Someday groups.

**4. `New task` doesn't reset `goalFromTask` (`manual-flows.js:35,43,40`)**
Home/Tasks `New task` resets Goal/Schedule/Date/Dated but not `vContext`; Draw `New task` also omits it. Stale `true` after a task-linked goal creation misroutes next `goal-cancel/goal-save`.
Fix: add `set(vContext,false)` to all `New task` entries; only `goal-picker New goal` sets `true`.

**5. Incomplete draft clear on Discard + Draw New task (`manual-flows.js:42,43`)**
`Discard draft` sets Goal/Schedule/Dated but omits `set(vDate,'None')`. Draw `New task` sets Goal/Schedule/Dated but omits Date. Stale `Oct 2` stays hidden then can resurface.
Fix: add `set(vDate,'None')` to both extras.

**6. `Remove date` leaves stale `This Week` (`manual-flows.js:39`)**
`Use date & time/Use date only` force `set(vSchedule,'This Week')`, but `Remove date` only clears Date/Dated. Result: `Someday/Today` intent shows as `This Week` with no date.
Fix: `Remove date` should also `set(vSchedule,'Today')` (keep dates on-demand).

**7. Misleading alert copy (`manual-flows.js:39`)**
`A date is enough. Add a time if you want an alert.` implies alerts work, but per `redesign-two-ai.md:9` dates/times/alerts are proposed, `note:51` says no persistence.
Fix: `A date is enough. Prototype only — no alert will be stored or sent.`

### Expected fixed-data limitations (label, don't fix as bugs)

**8. Single-task prototype, fixed placement**
One shared `vSaved/vCreated` instance inserted at fixed index `2`; second Save overwrites, `Draw Detail` stays `No entries yet` (`manual-flows.js:44-46`). Not a flow bug — keep honest board/note copy (`:25,51`) that this is fixed synthetic input with no storage/sorting into Today/This Week/Someday.
