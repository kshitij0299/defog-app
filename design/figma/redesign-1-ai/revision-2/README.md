# Revision 2 — owner feedback

[Figma page](https://www.figma.com/design/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1095-368) · [Onboarding prototype](https://www.figma.com/proto/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1097-516&starting-point-node-id=1097%3A516&scaling=scale-down) · [Everyday prototype](https://www.figma.com/proto/v6VyKHrnxzBtkDuCl8nneS/defog?node-id=1097-589&starting-point-node-id=1097%3A589&scaling=scale-down)

The owner's September 29 feedback is applied to the existing exploration page. Older Figma pages remain preserved. No Swift application files changed.

## Scope

- 27 screen/state frames and five native-menu/alert overlays, all 402×874. The two extra goal details and quick-entry result are supporting examples.
- Separate introduction and storage selection, then Brain Dump. Four destination tabs, Brain Dump last.
- Empty/typed/keyboard/recording/transcript capture; task and goal groups; Review with shared identity/count badges.
- Seven sample tasks, three goals, Home, Tasks, Goals, Your Day and professional Settings/model setup.
- Native menu instances for schedule, goal link, overflow and delete confirmation. State variables support completion, removal, schedule groups, goal links and guidance dismissal. Prototype variables are separate from design tokens.
- Single SF Symbols for goals; 30 light-mode design variables across primitives/semantic roles, plus seven existing type styles. SF Pro Rounded leads headings and buttons. Native Apple variable bindings remain intact.

The new component board is `1116:1002`. The original system board remains at `1096:368`; actual screens reference its masters. Edit a main component to change its instances.

## Validation

Verified the no-tab introduction → storage → Brain Dump → microphone → recording → Done → transcript → Review → Save path in the Figma player. Review overflow opens a native popup; removing a task changes 2 to 1 and Save 3 items to Save 2 items. Completion changes the open count from 7 to 6. Schedule selection updates the chosen task; Home and Tasks use shared schedule slots. Guidance dismisses, and Your Day opens from Home. Source and scope reviews used Muse Spark 1.3 Free/xhigh twice with zero reported model cost.

Programmatic checks confirm every phone frame's 402×874 size, status62, home34 at y840 and tabs95 at y745 where present. A temporary master-opacity edit propagated to all 26 task instances and was restored. The initial strict float comparison falsely failed at 0.9700000286; the corrected tolerance check passed. Native menus, keyboard, Settings, Review, Home, Goals, onboarding and recording received visual inspection.

`final-validation.json` records frame slots and copy. `copy-checks.json` records Unslop scans. Phrase scanning passed; prose-length/repetition warnings are protected UI labels. `docs/design-skills.md` explains the provenance and review decisions. Screenshots use synthetic content.

## Prototype limits

Figma does not record speech, accept arbitrary keyboard input, contact model endpoints, migrate storage, deliver notifications or implement dark mode. Those controls/state examples are design specimens. Connection success/failure and permission recovery are explicitly documented specimens. Some browser-player variable text triggered Figma's missing-font substitution notice; the canvas retains SF fonts. Use Fit width and height in the player.

Your Day and goal progress examples use fixed sample history; they are not a complete simulation of all task actions. Editing screens demonstrate the route and selected text rather than saving arbitrary edits. Goal Calendar, review completion/update categories, drag linking, undo/archive/restore and migration consequences need further state design before implementation. Automatic goal-icon selection is proposed in the brief, not implemented by this Figma work.

Scripts and JSON ledgers are construction records, not a safe replay command. Later corrections supersede earlier snapshots; inspect current canvas IDs before reusing a script. Figma native-slot property edits can change descendant IDs, and hidden-instance traversal requires `skipInvisibleInstanceChildren=false` when auditing inactive states. `schedule-bindings.json` records the final replacement of inactive task instances with explicitly wired fresh instances.

Final player check: rescheduling Buy groceries to This Week removes it from Home's Today group and places it under This Week in Tasks with the correct native label. `native-label-bindings.js` records the final native-property binding correction. The browser player was checked again after that correction.
