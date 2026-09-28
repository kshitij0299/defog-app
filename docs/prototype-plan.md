# Defog proposed prototype — coordinator plan

**PAUSED — 2026-09-29.** This is a future proposal. Eight unwired draft screens exist on Figma page `1024:2614`; the owner requested audit review and design-system agreement first. The current deliverable is the [Components workbench](components-review.md). Resume screen work only after that agreement.

Proposal only. No implementation changes until owner approval. The initial state list was drafted by free Muse; the coordinator removed suggestions to keep silent fallback, keep the ambiguous Process label, add a Completed destination, or move archived goals into the main Goals list without evidence.

## Core review path

1. Home empty: useful explanation, Start a brain dump, native Home/Tasks/Goals tabs.
2. Capture empty: editable text, optional voice action, visible Local processing mode; no permission on launch.
3. Capture with preview: recognized tasks/goals labeled Preview · not saved; Review action.
4. Review: editable items, explicit categories and schedules, Back preserves input; Save 3 items.
5. Home populated: saved items; separate new-capture action, Daily summary and Settings.
6. Tasks: existing Today/This Week/Someday buckets; native menus and clear goal links.
7. Goals: existing active pursuits and entry counts.
8. Goal timeline: native Timeline/Calendar switch, quick progress and Add note, factual Progress link.
9. Goal calendar: matching selected state and the same progress actions.
10. Progress sheet: one-entry factual state; no AI label or weekday inference.
11. Add progress note: editable note with Cancel and Save entry.
12. Settings: concise overview of processing, appearance, storage and archive.
13. Model settings: persistent endpoint/key/model labels, provider disclosure and Test connection.
14. Model failure: preserve configuration and input, offer Retry or deliberate local processing.
15. Contextual voice permission/denied state: typing remains available; system prompt only after the microphone action.
16. Archive confirmation: disclose current task unlinking behavior before confirmation; no invented reversible linkage.

Additional empty/loading/discard/undo states can be variants or overlays. They must be reachable, not merely placed beside the flow. Prototype interactions illustrate proposed behavior and cannot establish runtime persistence, speech quality or model connectivity.

## Design requirements

- Use available Apple iOS27 library instances, properties, variants and slots. Retain 402×874 rectangular iPhone17Pro frames; status62, tab95 at y745–840, home34 at y840–874.
- Preserve existing content semantics. SF Pro for body and native device chrome; SF Pro Rounded throughout app titles, headings and button labels. Full tokenization waits for system agreement.
- Keep full component bounds in reserved layout space. Validate each representative composed screen visually before expanding the pattern.
- Create a separate page from the editable current-app baseline and audit.
- Wire the capture/review/save loop and tab navigation; preserve origin on cancel where the prototype mechanism allows. Label scenario shortcuts outside phone frames.
- Keep hypotheses and runtime risks out of claims of measured improvement.
