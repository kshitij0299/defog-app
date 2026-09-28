# Components review workbench

[Open Components in Figma](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1053-375). Built 29 September 2026 for owner review. Redesign and implementation are paused until the owner agrees on the system, then the screens.

## How to edit

The left column holds **local main components**. Edit these to change linked examples on the right. Matching Apple controls remain attached as nested instances; use their exposed properties and variants. Each family has two blank areas, **Your version A** and **Your version B**, for alternatives. Copy a main component into a blank area to explore. An alternative does not automatically replace the current master; once chosen, connect the examples to it.

The workbench contains 30 families, 55 main components including variants, 60 blank areas, seven text styles, eleven full 402×874 screen examples and three smaller context details. Examples retain current-app content and structure while testing candidate components. They are not pixel-identical simulator reconstructions, approved screen redesigns, or a wired prototype.

## Inventory

| Group | Families | Context |
|---|---|---|
| Navigation | Status bar, home indicator, tab bar, navigation action, section heading, large title, inline navigation, Home toolbar | Home |
| Tasks | Menu trigger, schedule control, goal link pill, task card | Tasks, Delete task |
| Goals | Segmented control, goal card, timeline entry, calendar day, progress actions | Goal timeline, rolling calendar, Goals list detail |
| Capture | Action button, goal preview row, capture composer | Brain Dump, Processing |
| Settings | Text field, switch, list row, labeled field | Settings, labeled BYOM field exploration |
| Feedback | Page control, alert, loading indicator, toast, empty state, daily prompt | Onboarding, empty Goals, daily prompt, task feedback detail |

The loaded Apple iOS27 kit provides standard primitives. Runtime baseline is iOS26.2; kit availability does not establish runtime appearance or OS compatibility. Defog-specific cards, timeline, rolling 35-day calendar and multiline composer are local compositions. A date-input picker is not equivalent to the progress calendar, and a single-line text field is not a multiline TextEditor.

Current source references: `defog iOS/Views/Tasks/TaskCardView.swift`, `Views/Goals/GoalCardView.swift`, `Views/Goals/TimelineTabView.swift`, `Views/Goals/CalendarTabView.swift`, `Views/BrainDump/BrainDumpView.swift`, `Views/SettingsView.swift`, `Views/Goals/GoalsView.swift` (all under `defog iOS/`). The inventory worker supplied source analysis; coordinator owns component choices and visual checks.

## Typography and layout

SF Pro Rounded is the intended app voice: Large title 34/41 Bold, Title 22/28 Bold, Headline and Button 17/22 Semibold, Caption 12/16 Regular. Body 17/22 and Callout 15/20 use SF Pro Regular. Device chrome and SF Symbol glyphs retain native fonts. These seven named text styles are a starting point; full tokenization is deferred by owner request. No new custom variable collection was created. Native Apple semantic bindings and existing legacy variables are preserved.

Phone frames are rectangular 402×874. Status occupies 0–62; where present, tabs occupy 745–840 and home indicator 840–874. These are the owner's full-component canvas slots, not a claim about exact runtime measurements. Standard controls retain their native visual bounds; implementation must retain native hit areas, Dynamic Type and accessibility behavior. The 28pt switch visual sits in a 57pt context row.

## Validation and review limits

- Visual review covered the six boards and eleven examples; modal centering, segmented-control selection/opacity, duplicate bottom inset, content defaults and typography were corrected.
- A temporary master change propagated to Home/Tasks title sizes, a task-card radius, and a nested progress button's font weight. The original values were restored. Exact results are in `design/figma/components/propagation-test.json`.
- All eleven phone frames have the agreed status/home regions; tabbed examples have the agreed tab region. Every family has a description and two owner areas. See `design/figma/components/validation.json`.
- Free Muse xhigh completed the first documentation review with zero reported model cost. Coordinator resolved its questions: the 35pt/Bold values were temporary propagation-test values; a readback confirmed restored 34pt Bold titles and 17pt Semibold action labels. The row-height statement was corrected. `review-resolution.json` records restored values, line heights and every family-to-workspace ID mapping.
- Native segmented controls returned 0.5 opacity after selecting the enabled variant. Local wrapper instances explicitly restore opacity to 1; the attached native component and selected option properties are preserved.
- The labeled field is an exploration of audit UX-08. Other candidate styling, such as Rounded labels and native action styling, is also not implemented. Source-only states are labeled; they are not new runtime observations.
- Small metadata, contrast across appearances, Dynamic Type, VoiceOver, keyboard behavior, all interaction states and full responsive layouts still need review. This pass does not establish accessibility conformance. Custom literal values remain until tokenization is agreed; Code Connect publication is deferred.

Historical construction scripts are an execution record, not an idempotent regeneration tool. Do not replay them over owner edits. Use the saved node ledgers for targeted changes; `validation.json` supersedes earlier construction dimensions/counts.

## Research used

[Apple Design Resources](https://developer.apple.com/design/resources/) supplies the native component kit; [Apple HIG layout](https://developer.apple.com/design/human-interface-guidelines/layout) and [typography](https://developer.apple.com/design/human-interface-guidelines/typography) inform the review. [Figma component properties](https://help.figma.com/hc/en-us/articles/5579474826519-Explore-component-properties) supports the editable property/variant approach. Owner preferences determine the Rounded emphasis, single-page workbench, example screens and deferred tokenization.
