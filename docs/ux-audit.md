# Defog UX audit

Expert walkthrough and source review, 28 September 2026. Baseline: `live-view` at `11ba317`. This is formative design evidence, not a usability study or a measured improvement.

The existing app builds and the local capture → preview → review → save flow succeeds with synthetic content. The original goal-overlap finding was withdrawn after a clean-launch recheck; see the correction record below. The redesign should preserve lightweight capture and gentle progress tracking while clarifying what will be saved and which processing mode is active.

## Evidence and limits

The walkthrough used a fresh iPhone 17 Pro simulator, iOS 26.2, at 402 × 874 points. Microphone and speech permissions were declined, storage was device-only, and no API key was entered. Test content: “Buy groceries today”, “Call the dentist this week”, and “Learn guitar”. After reviewing a standard iPhone reference, the user confirmed retaining the existing **iPhone 17 Pro, 402 × 874 points** setup. Working Figma frames are rectangular, with a 62pt status region and a 34pt home-indicator region. Safe-area measurements are retained; corner clipping is presentation detail.

Evidence PNGs are in [the capture directory](evidence/2026-09-28/). Automation read accessibility labels; this was not a complete VoiceOver test. Voice recording, remote model output, CloudKit migration, notification delivery, Dark Mode and Dynamic Type remain unverified. A computer-use coordinate-click failure is a tooling limitation, not an app defect.

## Prioritized findings

| ID | Priority | Evidence type | Finding | Proposed response |
|---|---|---|---|---|
| UX-02 | High | Observed | Microphone and speech alerts appear before onboarding, although typing works without them. | Ask when the person first chooses voice capture. |
| UX-03 | Medium | Observed + source | A search-role tab opens an Add action instead of a destination. | Keep Home, Tasks and Goals as navigation; expose capture as a clearly labeled action. |
| UX-04 | Medium | Observed | Empty Home copy suggests adding something but offers no action in context. | Add “Start a brain dump” and short example content. |
| UX-05 | Medium | Design hypothesis | Live preview is followed by Process and another review screen; save status is unclear. | Keep a single deliberate review step, labeled “Review” then “Save 3 items”. |
| UX-06 | Medium | Observed + source | “AI Overview” is local statistics and infers a weekday pattern from one entry. | Use “Progress” and factual low-data states; avoid unsupported pattern claims. |
| UX-07 | Medium | Accessibility tree | Home toolbar names are “Brightness Higher” and “gearshape”. | Specify destination labels, “Daily summary” and “Settings”. |
| UX-08 | Medium | Observed | Model settings rely on BYOM jargon; populated endpoint/model fields have no persistent field labels. | Provide a named model settings screen with labeled fields, mode and connection status. |
| UX-09 | High | Source risk | Remote-model failure can fall back to local rules without a durable explanation. | Make active mode visible, preserve input, and offer retry or local processing. |
| UX-10 | High | Source risk | Local-to-iCloud migration does not restore task-to-goal relationships. | Treat relationship preservation and explicit migration outcomes as implementation acceptance criteria. |
| UX-11 | Medium | Source risk | Archiving a goal unlinks tasks, but the confirmation only mentions unarchiving. | Disclose the consequences before confirmation. |
| UX-12 | Medium | Source risk | Reopening a completed task leaves its automatically logged goal entry behind. | Define a coherent undo policy and communicate it. |

Source paths below beginning with `Views/` are relative to `defog iOS/`.

## Observed details and acceptance criteria

### Correction record — UX-01 withdrawn

The user challenged the Figma translation. After terminating and relaunching the same app without changing source, opening Guitar from Home showed the native Timeline/Calendar picker below the navigation bar, the timeline entry below it, and “Did something today” above the tab bar. [Capture 17](evidence/2026-09-28/17-goal-detail-reverified.png) records this settled state.

[Capture 10](evidence/2026-09-28/10-goal-detail-obscured.png) and [capture 11](evidence/2026-09-28/11-goal-progress-obscured.png) do show overlap, but its conditions and cause are unknown. They do not establish a persistent app defect. Do not infer an animation issue, app bug or repair from these images. UX-01 is removed from the prioritized findings; its ID remains in this correction record.

The Figma reconstruction copied those overlaps and introduced further errors: a hand-built substitute for the native picker, wrong navigation symbols, a missing goal/timeline marker, incorrect text styling and misplaced progress actions. Those are translation errors. The goal baseline is now corrected using capture 17 and an actual Apple segmented-control instance. The SwiftUI source already uses `.pickerStyle(.segmented)` in `defog iOS/Views/Goals/GoalDetailView.swift`.

The user-requested Figma bottom convention remains explicit: the tab component occupies y745–840 (95pt), followed by the home-indicator component at y840–874 (34pt). It differs from the runtime screenshot; the action row moves with its reserved layout space. Do not use this convention as evidence of a runtime defect or claim pixel identity.

### UX-02 — Permission timing

Fresh launch shows [microphone](evidence/2026-09-28/01-launch-microphone-permission.png) and [speech recognition](evidence/2026-09-28/02-launch-speech-permission.png) alerts before [onboarding](evidence/2026-09-28/03-onboarding.png). The typed capture path subsequently worked with both denied. Apple's [privacy guidance](https://developer.apple.com/design/human-interface-guidelines/privacy/) recommends requesting access in the context of the feature that needs it. Proposal: let people reach capture first and trigger the system request from the microphone action; a separate persuasion screen is unnecessary. Acceptance: no voice permission on a fresh typed-only path, and denial leaves typing available.

### UX-03 — Capture action in navigation

`Views/MainTabView.swift` uses a `.search`-role tab for Add and intercepts its selection to present a full-screen cover. The [populated Home capture](evidence/2026-09-28/09-home-populated.png) shows the isolated plus button. Apple's [tab-bar guidance](https://developer.apple.com/design/human-interface-guidelines/tab-bars) describes tabs as navigation between sections and directs actions to toolbars. Proposal: native Home/Tasks/Goals tabs and an explicitly labeled capture action. Acceptance: tab selection preserves each destination; starting or cancelling capture leaves the current destination intact.

### UX-04 and UX-05 — First-use guidance and save clarity

The [empty Home](evidence/2026-09-28/05-home-empty.png) has passive instructions. [Empty capture](evidence/2026-09-28/06-brain-dump-empty.png) devotes most of the viewport to an empty preview. Typed content then produces [live results](evidence/2026-09-28/07-live-preview.png), followed by [Review & Confirm](evidence/2026-09-28/08-review-confirm.png). This sequence worked, but the labels leave users to infer whether live results are already saved. That confusion is a design hypothesis to test, not an observed user error.

Relevant source: `Views/Home/HomeView.swift`, `Views/BrainDump/BrainDumpView.swift`, `Views/BrainDump/ConfirmationView.swift`. Proposal: useful starter examples, editable input, “Preview · not saved”, one explicit Review step, and an item-count Save action. Acceptance: a prototype participant can identify what is saved, change an incorrect category and cancel without saving. Preserve the ability to review AI interpretation before persistence.

### UX-06 — Honest progress feedback

With one quick entry, [AI Overview](evidence/2026-09-28/12-progress-overview.png) shows “You're on a roll!” and “Most active on Monday”. `Views/Goals/AIOverviewSheet.swift` computes local statistics; there is no model call. Proposal: “Progress”, “Your first step is logged”, entry counts and recent activity. Acceptance: 0/1/many-entry states describe evidence without suggesting a statistically meaningful pattern from one event.

### UX-07 — Accessibility names

The accessibility tree exposes the Home sun as “Brightness Higher” and the gear as “gearshape”. Task controls already expose descriptive labels and hints: completion, task text, schedule and linked goal. Preserve those strengths. Relevant source: `Views/Home/HomeView.swift`, `Views/Tasks/TaskCardView.swift`, and the other tab toolbars. Acceptance in the future build: actual VoiceOver navigation announces destinations and actions, logical focus order is maintained, and all controls remain reachable with large text.

### UX-08 — Model configuration

[Settings](evidence/2026-09-28/13-settings-model.png) shows a truncated endpoint, API-key placeholder, raw model ID, disabled test button and a footer explaining “legacy local rules”. The defaults are OpenRouter and `openai/gpt-4o-mini`; no real key was used. Proposal: an overview row “AI processing · Local mode”, leading to a focused screen with persistent labels, a disclosure that text is sent to the configured provider, validation and clear connection results. Acceptance: people can distinguish device storage, speech processing and model processing; a failure is actionable without exposing credentials.

## Source risks requiring future runtime checks

UX-09 comes from the extraction/fallback flow described in [architecture](architecture.md). UX-10 is the unused goal-ID mapping and absent link restoration in migration. UX-11 comes from the archive alert in `defog iOS/Views/Goals/GoalDetailView.swift`, and UX-12 from `TaskCardView.toggleCompletion()`. These are code-supported risks; they have not been reproduced as end-to-end failures in this walkthrough. Figma will show expected error, archive and undo interactions. Implementation must verify them with synthetic data after design approval.

Voice stopping/finalization and repeated daily prompts are additional verification items in [the screen inventory](screen-inventory.md), not yet prioritized as observed failures.

## Design references and validation boundary

The planned redesign will use the current [Apple design resources](https://developer.apple.com/design/resources/), including iOS 27 components. Layout decisions follow [safe-area guidance](https://developer.apple.com/design/human-interface-guidelines/layout). Glass is used for native navigation and controls; ordinary content remains readable on solid surfaces, following [materials guidance](https://developer.apple.com/design/human-interface-guidelines/materials).

Figma review can verify hierarchy, geometry, state coverage and navigation links. It cannot establish speech accuracy, AI extraction quality, data persistence, CloudKit correctness, Dynamic Type behavior or actual VoiceOver output. Those require the implemented app. No success metric or user validation is claimed yet.
