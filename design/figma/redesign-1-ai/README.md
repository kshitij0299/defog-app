> Superseded by [revision 2](revision-2/README.md), based on owner feedback. This file records the original eight-screen delivery.

# Redesign 1 by AI

[Open the Figma page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1095-368) · [Play the core flow](https://www.figma.com/proto/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1097-516&starting-point-node-id=1097%3A516)

Created 29 September 2026 at the owner's request. This is a fresh visual proposal, not an approved design or an app implementation. All older pages and owner work areas were preserved.

## Starting context

Read [current-app-context.md](../../../docs/design-briefs/current-app-context.md) for three Mermaid diagrams, 12 baseline-screen mappings and basic structural wireframes. It separates visible Figma content, synthetic walkthrough observations and source-derived behavior. The baseline itself has no interaction wiring and has translation artifacts, so its arrows are supplemented from source. The [standalone Mermaid flow](../../../docs/design-briefs/current-app-flow.mmd) and [agent brief](../../../docs/design-briefs/redesign-1-ai.md) can be handed to another designer/agent without using older designs as visual templates.

## Design direction and editable system

Warm off-white, plum, restrained lilac/peach/sage, Rounded typography and small SF Symbols give the app a softer personality. The hierarchy starts with today's task and then ongoing pursuits. Capture is a labeled action separate from the three destination tabs. Preview explicitly says it is unsaved; review and save have separate labels. These are hypotheses for review, not validated improvements.

The top board contains 15 families and 20 main components including variants: status, home indicator, tabs, navigation action, buttons, segmented control, menu, field, switch, settings row, task row, goal card, preview item, thought editor and progress entry. Edit these local mains to update the screens. Matching Apple controls remain attached as nested instances with editable properties. Use the new mains, not the old Components page, for changes to this exploration.

Seven text styles emphasize SF Pro Rounded for titles, headings, captions and buttons. Body/input uses SF Pro; device chrome remains native. Eight paint styles record the palette. Spacing is based on 8/12/16/24/32, with 20pt content corners and native control shapes. Full variables, appearance modes and production tokens are deferred by owner preference.

The loaded Apple iOS27 kit supplied native primitives; the app's verified runtime remains iOS26.2. Kit availability does not establish implementation compatibility. The multiline composer and Defog-specific cards are local compositions. These rely on native SwiftUI behavior when eventually implemented; a Figma component does not supply that behavior.

## Screen and prototype inventory

| Screen | Node | Scenario |
|---|---|---|
| Home empty | `1097:516` | First capture invitation |
| Home populated | `1097:589` | One Today task and newly created Guitar goal |
| Brain dump | `1097:685` | Typed synthetic input and three unsaved interpretations |
| Review | `1097:745` | Two tasks and one new goal, before saving |
| Tasks | `1097:823` | Today / This Week / Someday |
| Goals | `1097:919` | Newly created Guitar goal, no entries |
| Goal detail | `1097:991` | Empty timeline with progress affordances |
| Settings | `1097:1082` | Local rules, model fields, scrollable preferences |

Start with **Start here · capture and review** or **Explore saved items**. There are 25 navigation/back links. Home empty → Brain dump → Review → Save reaches Home populated; then tabs, goal cards and Settings work. The new goal consistently has no logged entries. Goal detail's native timeline/calendar control and quick/written progress actions are visible, but do not simulate progress logging yet. The system board also shows a populated progress-entry specimen.

The prototype uses fixed sample content. It does not accept input, call a model, mutate tasks, remember originating-tab save behavior or persist data. Initial empty-state tabs, task editing/menus/completion, voice, Calendar, progress actions, summary, settings controls and other unwired actions are visual specimens. Dedicated keyboard, permission, processing/cancel, no-result, completion/update review, lifecycle, storage-migration and connection-error states remain. Notes below the screens disclose this scope.

## Verification

- All eight screens and the system board were visually rendered. Updated Home, Goals and Goal detail were rendered again after aligning the zero-entry scenario.
- The core Start → Capture → Review → Save route and Home → Settings were clicked in the Figma browser player. Settings scrolls to Storage, Archived goals and App tour. Other links were checked structurally, not exhaustively click-tested.
- All 228 component instances resolved to main components. A temporary goal-card radius change updated all three screen instances, then restored their original 20pt radius. See [validation.json](validation.json).
- All phones are 402×874. Status occupies 0–62; navigation 62–106; tabbed screens reserve 745–840 for the complete tab component and 840–874 for home indicator. Content and primary actions use separate regions above tabs. This is the agreed Figma canvas convention, not a claim of runtime pixel identity.
- Basic palette contrast was calculated; Dynamic Type, VoiceOver, dark appearance, keyboard behavior and all touch/error states need later review. No accessibility conformance or usability-improvement claim is made.
- No app code changed. Documentation/JSON/script checks are appropriate for this milestone; an app build would not validate these Figma changes.

## Muse use and review

Muse Spark 1.3 Free (`opencode/muse-spark-1.3-contributor-free`, xhigh) reviewed selected context documents through OpenCode. The completed run reported zero model cost. Its feedback on missing review categories, archive/undo/migration consequences and Settings routes was incorporated into the brief or explicitly deferred-state notes. No blocking contradiction remained. The coordinator authored the visual direction, constructed the Figma system/screens, checked them and integrated Git. No separate user-owned task or child agent was created.

Recent earlier Muse runs covered component inventory and a first documentation review, also reporting zero model cost. Muse did not perform the recent Figma visual work.

## Artifact safety

Scripts are historical MCP construction records, **not** an idempotent regeneration pipeline. Inspect the live page before any reuse; do not replay them over owner edits. `foundation.json`, `system-state.json` and `screens-state.json` record creation; `validation.json` records final corrections, links, bounds and propagation. `baseline-read.json` is the fresh baseline extraction. No keys, simulator data or local worker event logs are included.
